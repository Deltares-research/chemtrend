drop schema if exists chemtrend cascade;
create schema if not exists chemtrend;

-- provinces
create or replace view chemtrend.province(province_id, province_code, province_description, geometry) as
SELECT pr."FID"           AS province_id,
       pr."Code"         AS province_code,
       pr."Provincien" AS province_description,
       st_transform(pr.geometry, 28992) as geometry
FROM public.provincies pr;

create or replace view chemtrend.province_geojson as
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(province)::json)) as geojson
from chemtrend.province;

-- waterboards
create or replace view chemtrend.waterboard(waterboard_id, waterboard_code, waterboard_description, geometry) as
SELECT wb.waterbeheerder_id          AS waterboard_id,
       wb.waterbeheerder_code         AS waterboard_code,
       wb.waterbeheerder_omschrijving AS waterboard_description,
       wb.geometry as geometry
FROM public.waterbeheerder wb
where st_isempty(geometry)=false;
;

create or replace view chemtrend.waterboard_geojson as
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(waterboard)::json)) as geojson
from chemtrend.waterboard;


-- sub catchments
create or replace view chemtrend.catchment(catchment_id, catchment_code, catchment_description_short, catchment_description_long, geometry) as
SELECT dsg."OBJECTID"          AS catchment_id,
       dsg."GAFIDENT"         AS catchment_code,
       dsg."GAFNAAM" AS catchment_description_short,
	   dsg."NAAM" AS catchment_description_long,
       dsg.geometry as geometry
FROM public.deelstroomgebieden dsg;

create or replace view chemtrend.catchment_geojson as
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(catchment)::json)) as geojson
from chemtrend.catchment;


-- KRW-waterbodies
create or replace view chemtrend.waterbody(KRWwaterbody_id, KRWwaterbody_code, KRWwaterbody_description, KRWwaterbody_namespace, catchment_code, KRWwaterbody_status, KRWwaterbody_type_code, geometry) as
SELECT wl.db_id_extern          AS "waterbody_id",
       wl.waterlichaam_code         AS "waterbody_code",
       wl.waterlichaam_omschrijving AS "waterbody_description",
	   wl."namespace" AS "waterbody_namespace",
	   wl.stroomgebied_code AS catchment_code,
	   wl.waterlichaam_status AS "waterbody_status",
	   wl."waterlichaam_KRWtype_code" AS "waterbody_type_code",
       wl.geometry as geometry
FROM public."KRW_waterlichaam" wl;

create or replace view chemtrend.waterbody_geojson as
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(waterbody)::json)) as geojson
from chemtrend.waterbody;

-- substances
create or replace view chemtrend.substance(substance_id, substance_code, substance_description, cas) as
SELECT p.parameter_id           AS substance_id,
       p.parameter_code         AS substance_code,
       p.parameter_omschrijving AS substance_description,
       p."CAS" as cas
FROM public.parameter p
join (select distinct parameter_id from public.trend_locatie) tlp on tlp.parameter_id=p.parameter_id
where p."CAS" <> 'NVT'
;

-- locations:
drop view if exists chemtrend.location cascade;
create or replace view chemtrend.location as
select l.meetpunt_id, l.meetpunt_id as location_id,
    l.meetpunt_code_2022 as location_code,
    st_transform(l.geom, 4326) as geom
from public.locatie l
join (select distinct meetpunt_id from public.trend_locatie) tlm on tlm.meetpunt_id=l.meetpunt_id
where st_isempty(l.geom)=false;

-- view with locations as geojson
drop view if exists chemtrend.location_geojson cascade;
create or replace view chemtrend.location_geojson as
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(location)::json)) as geojson
from chemtrend.location;

-- view with locations and its trend color per parameter
drop view if exists chemtrend.location_substance cascade;
create or replace view chemtrend.location_substance as
select l.location_code, tl.parameter_id as substance_id, s.substance_code
, case skendall_trend
        when 1 then 'red'
        when 0 then 'grey'
        when -1 then 'green'
    end as color
, l.geom
from (
    select tr.meetpunt_id, tr.parameter_id, tr.skendall_trend
    from public.trend_locatie tr
    group by tr.meetpunt_id, tr.parameter_id, tr.skendall_trend
) tl
join chemtrend.location l on l.meetpunt_id=tl.meetpunt_id
join chemtrend.substance s on s.substance_id=tl.parameter_id
;

-- functions that returns locations per substance
drop function if exists chemtrend.location_substance_geojson(substance_id int);
create or replace function chemtrend.location_substance_geojson( substance_id int)
    returns table (geojson json) as
$ff$
declare q text;
declare scid int = substance_id;
begin
select ($$
    select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(location_substance)::json)) as geojson
    from chemtrend.location_substance
    where substance_id = %1$s
    $$) into q;
q := format(q, scid);
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
    select l.location_code
    , s.substance_id, s.substance_code
    , 'meting' as category
    , s.substance_description || ' ' || l.location_code as title
    , 'Trendresultaat: '
          || case tr.skendall_trend when -1 then 'trend neerwaarts' when 0 then 'geen trend' when 1 then 'trend opwaarts' else '' end
          || ' (p=' || (tr.p_value_skendall) || ')' as subtitle_1
    , 'Trendhelling: ' || (tr.theilsen_slope * 365 * 10) || ' ug/l per decennium' as subtitle_2
    , 'datum' as x_label
    , s.substance_code || ' [' || e.eenheid_code || ' ' || h.hoedanigheid_code || ']' as y_label
    , datum x_value -- NB dit is een datum, niet het aantal dagen, ja een datum object onder de motorkap het aantal dagen sinds 1970-01-01
    , tr.rapportagegrens point_filled
    , tr.waarde_meting as y_value_meting
    , tr.lowline_y as y_value_lowess
    , tr.ats_y y_value_theil_sen
    , 'MKN' as h1_label
    , null::numeric as h1_value -- TO DO
    , 'MAC' as h2_label
    , null::numeric as h2_value -- TO DO
    -- select *
    from public.trend_locatie tr
    join chemtrend.substance s on s.substance_id=tr.parameter_id
    join chemtrend.location l on l.meetpunt_id=tr.meetpunt_id
    join public.eenheid e on e.eenheid_id=tr.eenheid_id
    join public.hoedanigheid h on h.hoedanigheid_id=tr.hoedanigheid_id
) x
;

-- view with all regions
drop view if exists chemtrend.region cascade;
create or replace view chemtrend.region as
select province_id+1000 as region_id, 'Provincie'::varchar as region_type, province_id as original_id, province_description as region_description, geometry from chemtrend.province
union all
select waterboard_id+2000 as region_id, 'Waterschap'::varchar as region_type, waterboard_id as original_id, waterboard_description as region_description, geometry from chemtrend.waterboard
union all
select krwwaterbody_id+3000 as region_id, 'Waterlichaam'::varchar as region_type, krwwaterbody_id as original_id, krwwaterbody_description as region_description, geometry from chemtrend.waterbody
union all
select catchment_id+4000 as region_id, 'Stroomgebied'::varchar as region_type, catchment_id as original_id, catchment_description_short as region_description, geometry from chemtrend.catchment
;

-- function to return regional polygons based on given coordinates
drop function if exists chemtrend.region(x decimal, y decimal);
create or replace function chemtrend.region(x decimal, y decimal)
-- 	returns table(region_type text, region_id text, region_description text, geom geometry) as
    returns setof chemtrend.region as
$ff$
declare q text;
declare srid_xy int = 4326;
declare srid_rd int = 28992;
begin
select ($$
    select reg.region_id, reg.region_type, original_id, reg.region_description, st_transform(geometry, %3$s) as geometry
    from chemtrend.region reg
    where st_within(st_transform(st_setsrid(st_makepoint(%1$s,%2$s),%3$s),%4$s), reg.geometry)
    $$) into q;
q := format(q, x, y, srid_xy, srid_rd);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.region(5.019, 52.325);

-- view that couples locations and regions:
drop view if exists chemtrend.location_region cascade;
create or replace view chemtrend.location_region as
select loc.location_code, reg.region_id
from (select *, st_transform(geom, 28992) as geom_rd from chemtrend.location) loc
join chemtrend.region reg on 1=1
-- join (select * from chemtrend.region where region_id in (select region_id from chemtrend.region(5.019, 52.325))) reg on 1=1
where st_within(loc.geom_rd, reg.geometry)
;

-- view with trend data (to plot the measurements and trends)
drop view if exists chemtrend.trend_region;
create or replace view chemtrend.trend_region as
select *
from (
--     TO DO: deze view baseren op echte data conform de structuur van de view 'chemtrend.trend'
    select *
    , region_description as region
    , location_code as location
    , case when location_code is null then 'trend' else 'locations' end as trend_type
    from voorbeelddata.trend_region_subset tr
) x
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

-- function to return closest location on given lon/lat (x,y) within 1 km
drop function if exists chemtrend.location(x decimal, y decimal);
create or replace function chemtrend.location(x decimal, y decimal)
--     returns varchar as
	returns table(location_code text, geom geometry) as
$ff$
declare q text;
declare srid_xy int = 4326;
declare srid_rd int = 28992;
begin
select ($$
    select loc.location_code, loc.geom
    from (
        select location_code, geom
        , st_transform(geom,28992) geom_rd
        , st_transform(geom,%4$s) <-> st_transform(st_setsrid(st_makepoint(%1$s,%2$s),%3$s),%4$s) as distance
        from chemtrend.location
    ) loc
    where distance<1000
    order by distance
    limit 1
    $$) into q;
q := format(q, x, y, srid_xy, srid_rd);
return query execute q;
end
$ff$ language plpgsql;


-- function that returns trend data based on a given location
drop function if exists chemtrend.trend(x decimal, y decimal, substance_id int);
create or replace function chemtrend.trend(x decimal, y decimal, substance_id int)
    returns table (geojson json) as
$ff$
declare q text;
declare sid text = substance_id;
begin
select ($$
    with tr_detail as (
        select *
        from chemtrend.trend
        where location_code = (select location_code from chemtrend.location(%1$s,%2$s))
        and substance_id = '%3$s'
    )
    , tr_graph as (
        select title, subtitle_1, subtitle_2, h1_label, h1_value, h2_label, h2_value
        , json_agg(x_value order by x_value) x_value
        , json_agg(y_value_meting order by x_value) y_value_meting
        , json_agg(y_value_lowess order by x_value) y_value_lowess
        , json_agg(y_value_theil_sen order by x_value) y_value_theil_sen
        from tr_detail
        group by title, subtitle_1, subtitle_2, h1_label, h1_value, h2_label, h2_value
    )
    select json_agg(trg.*) as graph
    from tr_graph trg
    $$) into q;
q := format(q, x, y, sid);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.trend(5.019, 52.325,517);


-- function that returns trend data based on a given location
drop function if exists chemtrend.trend_region(x decimal, y decimal, substance_id int);
create or replace function chemtrend.trend_region(x decimal, y decimal, substance_id int)
    returns table (geojson json) as
$ff$
declare q text;
declare sid text = substance_id;
begin
select ($$
    with tr_detail as (
        select *
        from chemtrend.trend_region
        where region_id in (select region_id from chemtrend.region(%1$s,%2$s))
        and substance_id = '%3$s'
    )
    , tr_trends as (
        select region_type, title, trend_label
        , json_agg(x_value order by x_value) as x_value
        , json_agg(y_value_lowess order by x_value) as y_value_lowess
        from tr_detail
        group by region_type, region, trend_type, location, title, trend_label
    )
    , tr_graph as (
        select region_type, title, json_agg((select x from (select tr.trend_label, tr.x_value, tr.y_value_lowess) as x)) as locations
        from tr_trends tr
        group by region_type, title
    )
    select json_agg(trg.*) as graph
    from tr_graph trg
    $$) into q;
q := format(q, x, y, sid);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.trend_region(5.019, 52.325,517);

-- grant access
GRANT ALL ON all tables in schema chemtrend TO waterkwaliteit_readonly;
alter schema chemtrend owner to waterkwaliteit_readonly;
