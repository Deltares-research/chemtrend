drop schema if exists chemtrend cascade;
create schema if not exists chemtrend;

-- view that lists all trend periods:
drop view if exists chemtrend.trend_period;
create or replace view chemtrend.trend_period as
select 0::int as id, 'Alle data' as name, '01-01-1900'::date as start
union all
select 1::int as id, 'Vanaf 2009' as name, '01-01-2009'::date as start
;

-- locations with measurement data without trend
drop view if exists chemtrend.location_without_trend cascade;
create or replace view chemtrend.location_without_trend as
select meetpunt_id
from public.metingen
where trend=false
group by meetpunt_id
;

-- substances
create or replace view chemtrend.substance(substance_id, substance_code, substance_description, cas) as
SELECT p.parameter_id           AS substance_id,
       p.parameter_code         AS substance_code,
       p.parameter_omschrijving AS substance_description,
       p."CAS" as cas
FROM public.parameter p
         join (select distinct parameter_id from public.trend_locatie) tlp on tlp.parameter_id=p.parameter_id
-- TO DO: ook parameters toevoegen voor meetdata waarvoor uberhaupt geen trends zijn? (voorlopig niet)
where p."CAS" <> 'NVT'
;

-- locations:
drop view if exists chemtrend.location cascade;
create or replace view chemtrend.location as
select
    l.meetpunt_id,
    l.meetpunt_code_nieuw as location_code,
    l.meetpunt_omschrijving as omschrijving,
    w.waterbeheerder_omschrijving as waterbeheerder,
    st_transform(l.geometry, 4326) as geom
-- into chemtrend.location
from public.locatie l
left join public.waterbeheerder w on w.waterbeheerder_id=l.waterbeheerder_id
where st_isempty(l.geometry)=false
-- gebruik alleen locaties waarbij tenminste een trend of meting (zonder trend) bij is
 and l.trend_of_meting=true
;


-- create view with raw measurement data
drop view if exists chemtrend.measurement cascade;
create or replace view chemtrend.measurement as
select tr.meetpunt_id,l.location_code
     , s.substance_id, s.substance_code, s.substance_description
     , 'meting' as category
     , s.substance_description || ' ' || l.location_code as title
     , 'Metingen zonder trend' as subtitle_1
     , '' as subtitle_2
     , 'datum' as x_label
     , s.substance_code || ' [' || e.eenheid_code || ' ' || h.hoedanigheid_code || ']' as y_label -- TO DO: check occurence of multiple hoedanigheid (& compartiment?)
     , tr.datum x_value -- NB dit is een datum, niet het aantal dagen, ja een datum object onder de motorkap het aantal dagen sinds 1970-01-01
     , case when tr.limietsymbool is null then true else false end as point_filled -- TO DO: check how to derive rapportagegrens from the raw data
     , tr.waarden as y_value_meting
     , null::decimal as y_value_lowess
     , null::decimal y_value_theil_sen
     , 'MKN' as h1_label
     , null::numeric as h1_value -- TO DO
     , 'MAC' as h2_label
     , null::numeric as h2_value -- TO DO
     , null as color
     , 'notrend' as trend_direction
     , tp.id as trend_period
     , replace(e.eenheid_code, 'ug/l', 'μg/l') as unit -- TO DO: check occurence of other units
-- select *
from (
         -- all measurement data without trends for the combination location&parameter
        select * from public.metingen where trend=false
     ) tr
join chemtrend.substance s on s.substance_id=tr.parameter_id
join chemtrend.location l on l.meetpunt_id=tr.meetpunt_id
join public.eenheid e on e.eenheid_id=tr.eenheid_id
join public.hoedanigheid h on h.hoedanigheid_id=tr.hoedanigheid_id
join chemtrend.trend_period tp on tp.start <= tr.datum
;

-- view with locations as geojson
drop view if exists chemtrend.location_geojson cascade;
create or replace view chemtrend.location_geojson as
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(mp)::json)) as geojson
from (select location_code as meetpuntcode
      , omschrijving
      , waterbeheerder
      , geom
      from chemtrend.location) mp;

-- view with locations and its trend color per parameter
drop view if exists chemtrend.location_substance cascade;
create or replace view chemtrend.location_substance as
select l.location_code, tl.parameter_id as substance_id, s.substance_code
, case trend_conclusie
        when 1 then 'red'
        when 0 then 'grey'
        when -1 then 'green'
        else 'yellow'
    end as color
, l.geom
, case trend_conclusie
        when 1 then 'upwards'
        when 0 then 'inconclusive'
        when -1 then 'downwards'
        else 'notrend'
    end as trend_direction
, trend_period
from (
    select tr.meetpunt_id, tr.parameter_id, tr.trend_conclusie, trend_period
    from public.trend_locatie tr
    group by tr.meetpunt_id, tr.parameter_id, tr.trend_conclusie, trend_period
    union all
    -- add measurement data here for 'notrend' locations
    select m.meetpunt_id, m.parameter_id, null::int trend_conclusie, tp.id as trend_period
    from public.metingen m
    join chemtrend.trend_period tp on tp.start <= m.datum
    where m.trend=false
    group by m.meetpunt_id, m.parameter_id, tp.id
) tl
join chemtrend.location l on l.meetpunt_id=tl.meetpunt_id
join chemtrend.substance s on s.substance_id=tl.parameter_id
;

-- functions that returns locations per substance
drop function if exists chemtrend.location_substance_geojson(substance_id int, trend_period int);
create or replace function chemtrend.location_substance_geojson(substance_id int, trend_period int)
    returns table (geojson json) as
$ff$
declare q text;
declare scid int = substance_id;
declare tp int = trend_period;
begin
select ($$
    select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(location_substance)::json)) as geojson
    from chemtrend.location_substance
    where substance_id = %1$s
    and trend_period = %2$s
    $$) into q;
q := format(q, scid, tp);
return query execute q;
end
$ff$ language plpgsql;

-- select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(location_substance)::json)) as geojson
-- from chemtrend.location_substance;

-- view with trend data (to plot the measurements and trends)
drop view if exists chemtrend.trend;
create or replace view chemtrend.trend as
select *
from (
    select tr.meetpunt_id,l.location_code
    , s.substance_id, s.substance_code, s.substance_description
    , 'meting' as category
    , s.substance_description || ' ' || l.location_code as title
    , 'Trendresultaat: '
          || case tr.trend_conclusie when -1 then 'trend neerwaarts' when 0 then 'geen trend' when 1 then 'trend opwaarts' else '' end
          || ' (p=' || round(tr.p_value_trend,4) || ')' as subtitle_1
    , 'Trendhelling: ' || round(tr.ats_slope * 365 * 10,4) || ' ' || replace(e.eenheid_code, 'ug/l', 'μg/l') || ' per decennium' as subtitle_2
    , 'datum' as x_label
    , s.substance_code || ' [' || e.eenheid_code || ' ' || h.hoedanigheid_code || ']' as y_label
    , datum x_value -- NB dit is een datum, niet het aantal dagen, ja een datum object onder de motorkap het aantal dagen sinds 1970-01-01
    , case when tr.rapportagegrens = true then false else true end point_filled
    , tr.waarde_meting as y_value_meting
    , tr.lowline_y as y_value_lowess
    , tr.ats_y y_value_theil_sen
    , 'MKN' as h1_label
    , null::numeric as h1_value -- TO DO
    , 'MAC' as h2_label
    , null::numeric as h2_value -- TO DO
    , case tr.trend_conclusie
        when 1 then 'red'
        when 0 then 'grey'
        when -1 then 'green'
        else ''
    end as color
    , case trend_conclusie
        when 1 then 'upwards'
        when 0 then 'inconclusive'
        when -1 then 'downwards'
    end as trend_direction
    , trend_period
    , replace(e.eenheid_code, 'ug/l', 'μg/l') as unit
    -- select *
    from (select * from public.trend_locatie) tr
    join chemtrend.substance s on s.substance_id=tr.parameter_id
    join chemtrend.location l on l.meetpunt_id=tr.meetpunt_id
    join public.eenheid e on e.eenheid_id=tr.eenheid_id
    join public.hoedanigheid h on h.hoedanigheid_id=tr.hoedanigheid_id
) x
;

-- view with all regions
drop view if exists chemtrend.region cascade;
create or replace view chemtrend.region as
select r.regio_id as region_id, rt.regio_type as region_type, r.bron_id as original_id, r.regio_omschrijving as region_description, geom, geom_rd
from public.regio r
join public.regio_type rt on rt.regio_type_id=r.regio_type_id
;

-- function to return regional polygons based on given coordinates
drop function if exists chemtrend.region(x decimal, y decimal);
create or replace function chemtrend.region(x decimal, y decimal)
	returns table(region_id int, region_type text, region_description text, geom geometry) as
--     returns setof chemtrend.region as
$ff$
declare q text;
declare srid_xy int = 4326;
declare srid_rd int = 28992;
begin
select ($$
--     select reg.region_id, reg.region_type, original_id, reg.region_description, geom, geom_rd
    select region_id, region_type::text, region_description::text, geom
    from chemtrend.region reg
    where st_within(st_transform(st_setsrid(st_makepoint(%1$s,%2$s),%3$s),%4$s), reg.geom_rd)
    $$) into q;
q := format(q, x, y, srid_xy, srid_rd);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.region(5.019, 52.325);

-- view with trend data (to plot the measurements and trends)
drop view if exists chemtrend.trend_region;
create or replace view chemtrend.trend_region as
-- twee delen: 1. regio trends (trend van de trends) 2. locatietrends (cf trend_locatie maar dan met regio_id)
select
    tr.regio_id
    , s.substance_id
    , 'trend' as category
    , s.substance_description || ' ' || r.regio_omschrijving as title
    , 'datum' as x_label
    , tr.datum as x_value
    , tr.y_value_lowess
    , tr.trend_label
    , rt.regio_type as region_type
    , tr.color
    , tr.trend_direction
    , tr.trend_period
    , tr.unit
from (
    -- deel 1:
    select regio_id, parameter_id, datum, lowess_p25 as y_value_lowess, 'p25'::varchar as trend_label, 'black' as color, 'other' trend_direction, trend_period, null::varchar unit
    from public.trend_regio
    union all
    select regio_id, parameter_id, datum, lowess_p50 as y_value_lowess, 'p50'::varchar as trend_label, 'black' as color, 'other' trend_direction, trend_period, null::varchar unit
    from public.trend_regio
    union all
    select regio_id, parameter_id, datum, lowess_p75 as y_value_lowess, 'p75'::varchar as trend_label, 'black' as color, 'other' trend_direction, trend_period, null::varchar unit
    from public.trend_regio
    union all
    -- deel 2:
    select r.regio_id, tl.parameter_id, datum, tl.lowline_y as y_value_lowess, l.meetpunt_code_nieuw as trend_label
    , case tl.trend_conclusie
        when 1 then 'red'
        when 0 then 'grey'
        when -1 then 'green'
    end as color
    , case trend_conclusie
        when 1 then 'upwards'
        when 0 then 'inconclusive'
        when -1 then 'downwards'
    end as trend_direction
    , trend_period
    , replace(eh.eenheid_code, 'ug/l', 'μg/l') as unit
    from public.trend_locatie tl
    join public.locatie l on l.meetpunt_id=tl.meetpunt_id
    join public.locatie_regio lr on lr.meetpunt_id=tl.meetpunt_id
    join public.regio r on r.regio_id=lr.regio_id
    join public.eenheid eh on eh.eenheid_id=tl.eenheid_id
) tr
join chemtrend.substance s on s.substance_id=tr.parameter_id
join public.regio r on r.regio_id=tr.regio_id
join public.regio_type rt on rt.regio_type_id=r.regio_type_id
;

-- function to return regional polygons based on given coordinates as geojson
drop function if exists chemtrend.region_geojson(x decimal, y decimal);
create or replace function chemtrend.region_geojson(x decimal, y decimal)
    returns table (geojson json) as
$ff$
declare q text;
declare srid_xy int = 4326;
-- declare srid_rd int = 28992;
begin
select ($$
    select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(region)::json)) as geojson
    from chemtrend.region(%1$s,%2$s)
    $$) into q;
q := format(q, x, y, srid_xy);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.region_geojson(5.019, 52.325);

-- function to return closest location on given lon/lat (x,y) within 100 meter
drop function if exists chemtrend.location(x decimal, y decimal);
create or replace function chemtrend.location(x decimal, y decimal)
	returns table(meetpunt_id int, location_code text, geom geometry) as
$ff$
declare q text;
declare srid_xy int = 4326;
declare srid_rd int = 28992;
begin
select ($$
    select loc.meetpunt_id, loc.location_code, loc.geom
    from (
        select meetpunt_id, location_code, geom
        , st_transform(geom,28992) geom_rd
        , st_transform(geom,%4$s) <-> st_transform(st_setsrid(st_makepoint(%1$s,%2$s),%3$s),%4$s) as distance
        from chemtrend.location
    ) loc
    where distance<100
    order by distance
    limit 1
    $$) into q;
q := format(q, x, y, srid_xy, srid_rd);
return query execute q;
end
$ff$ language plpgsql;

-- function that returns trend data based on a given location
-- drop function if exists chemtrend.trend(x decimal, y decimal, substance_id int);
drop function if exists chemtrend.trend(x decimal, y decimal, substance_id int, trend_period int);
create or replace function chemtrend.trend(x decimal, y decimal, substance_id int, trend_period int)
    returns table (geojson json) as
$ff$
declare q text;
declare sid text = substance_id;
declare tp text = case trend_period when null then 0 else trend_period end;
begin
select ($$
    with tr_base as (
        select * from chemtrend.trend
        union all
        select * from chemtrend.measurement
    )
    , tr_detail as (
        select *
        from tr_base
        where meetpunt_id = (select meetpunt_id from chemtrend.location(%1$s,%2$s))
        and substance_id = '%3$s'
        and trend_period = '%4$s'
    )
    , tr_graph as (
        select title, subtitle_1, subtitle_2, h1_label, h1_value, h2_label, h2_value, color, trend_direction, unit
        , json_agg(x_value order by x_value) x_value
        , json_agg(y_value_meting order by x_value) y_value_meting
        , json_agg(y_value_lowess order by x_value) y_value_lowess
        , json_agg(y_value_theil_sen order by x_value) y_value_theil_sen
        , json_agg(point_filled order by x_value) point_filled
        from tr_detail
        group by title, subtitle_1, subtitle_2, h1_label, h1_value, h2_label, h2_value, color, trend_direction, unit
    )
    select json_agg(trg.*) as graph
    from tr_graph trg
    $$) into q;
q := format(q, x, y, sid, tp);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.trend(5.113007176643064,52.02272937705282,333);
-- example: select * from chemtrend.trend(5.431838035583496,52.486543564119955,333,1);

-- function that returns trend data based on a given location
drop function if exists chemtrend.trend_region(x decimal, y decimal, substance_id int, trend_period int);
create or replace function chemtrend.trend_region(x decimal, y decimal, substance_id int, trend_period int)
    returns table (geojson json) as
$ff$
declare q text;
declare sid text = substance_id;
declare tp text = case trend_period when null then 0 else trend_period end;
begin
select ($$
    with tr_detail as (
        select *
        from chemtrend.trend_region
        where substance_id = '%3$s'
        and trend_period = '%4$s'
        and regio_id in (
            (select region_id from chemtrend.region(%1$s,%2$s))
            union all
            (select regio_id from public.locatie_regio lr
                          join chemtrend.location(%1$s,%2$s) loc on loc.meetpunt_id=lr.meetpunt_id)
        )
    )
    , tr_trends as (
        select region_type, title, min(unit) as unit, trend_label, color, trend_direction
        , json_agg(x_value order by x_value) as x_value
        , json_agg(y_value_lowess order by x_value) as y_value_lowess
        from tr_detail
        group by region_type, regio_id, trend_label, title, color, trend_direction
    )
    , tr_graph as (
        select region_type, title, min(unit) unit, json_agg((select x from (select tr.trend_label, tr.color, tr.trend_direction, tr.x_value, tr.y_value_lowess) as x)) as locations
        from tr_trends tr
        group by region_type, title
    )
    select json_agg(trg.*) as graph
    from tr_graph trg
    $$) into q;
q := format(q, x, y, sid, tp);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.trend_region(5.019, 52.325,517);
-- example: select * from chemtrend.trend_region(5.113007176643064,52.02272937705282,333,0);

-- grant access
GRANT ALL ON all tables in schema chemtrend TO waterkwaliteit_readonly;
alter schema chemtrend owner to waterkwaliteit_readonly;

