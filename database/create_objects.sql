drop schema if exists chemtrend cascade;
create schema if not exists chemtrend;

-- provinces
create or replace view chemtrend.province(province_id, province_code, province_description, geometry) as
SELECT pr."FID"           AS province_id,
       pr."Code"         AS province_code,
       pr."Provincien" AS province_description,
       pr.geometry as geometry
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
FROM public.waterbeheerder wb;

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
FROM public.parameter p join (select distinct parameter_code from voorbeelddata.trend) t on t.parameter_code=p.parameter_code
;

-- locations: FOR NOW: BASED ON EXAMPLE DATA
drop view if exists chemtrend.location cascade;
create or replace view chemtrend.location as
select distinct meetpunt_code as location_code, geom from voorbeelddata.trend;

-- view with locations as geojson
drop view if exists chemtrend.location_geojson cascade;
create or replace view chemtrend.location_geojson as
-- select distinct meetpunt_code as location_code, st_asgeojson(geom) as geom from voorbeelddata.trend;
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(location)::json)) as geojson
from chemtrend.location;

-- view with locations and its trend color per parameter
drop view if exists chemtrend.location_substance cascade;
create or replace view chemtrend.location_substance as
select location_code, substance_id, substance_code, color, geom
from (
    select meetpunt_code as location_code
    , s.substance_id
    , s.substance_code
    , geom
    , case skendall_trend
        when 'trend opwaarts' then 'red'
        when 'geen trend' then 'grey'
        when 'trend neerwaarts' then 'green'
    end as color
    from voorbeelddata.trend tr
    join chemtrend.substance s on s.substance_code=tr.parameter_code
) x
group by location_code, substance_id, substance_code, color, geom
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
    select meetpunt_code as location_code
    , s.substance_id, s.substance_code
    , 'meting' as category
    , s.substance_description || ' ' || meetpunt_code as title
    , 'Trendresultaat: ' || skendall_trend || ' (p=' || (p_value_skendall) || ')' as subtitle_1
    , 'Trendhelling: ' || (theilsen_slope * 365 * 10) || ' ug/l per decennium' as subtitle_2
    , 'datum' as x_label
    , parameter_code || ' [' || eenheid_code || ' ' || hoedanigheidcode || ']' as y_label
    , datum x_value -- NB dit is een datum, niet het aantal dagen, ja een datum object onder de motorkap het aantal dagen sinds 1970-01-01
    , lowline_x x_days -- dagen sinds 1980? nee sinds 1970-01-01
    , case meting when 'Boven detectielimiet' then true else false end as point_filled
    , waarde as y_value_meting
    , lowline_y as y_value_lowess
    , theilsen_intercept y_value_theil_sen
    , 'MKN' as h1_label
    , norm_n as h1_value
    , 'MAC' as h2_label
    , norm_p as h2_value
    -- select *
    from voorbeelddata.trend tr
    join chemtrend.substance s  on substance_code=tr.parameter_code
--     where meetpunt_code='NL02_0037' and parameter_code='Cr'
) x
;


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
-- 	returns setof chemtrend.trend as  --set of chemtrend.trend?
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
            , json_agg(json_build_object('x_value', x_value
            , 'y_value_meting', y_value_meting
            , 'y_value_lowess', y_value_lowess
            , 'y_value_theil_sen', y_value_theil_sen
            ) order by x_value
        ) as timeseries
        from tr_detail trd
        group by title, subtitle_1, subtitle_2, h1_label, h1_value, h2_label, h2_value
    )
    , tr_final as (
        select json_agg(trg.*) as graph
        from tr_graph trg
    )
    -- select '{graph:'||right(left(graph, -1),-1)||'}'
    select *
    from tr_final
    $$) into q;
q := format(q, x, y, sid);
return query execute q;
end
$ff$ language plpgsql;
-- example: select * from chemtrend.trend(5.019, 52.325,517);

-- grant access
GRANT ALL ON all tables in schema chemtrend TO waterkwaliteit_readonly;
alter schema chemtrend owner to waterkwaliteit_readonly;
