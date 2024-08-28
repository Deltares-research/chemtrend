-- drop schema if exists chemtrend cascade;
create schema if not exists chemtrend;

-- substances
create or replace view chemtrend.substance(substance_id, substance_code, substance_description, cas) as
SELECT p.parameter_id           AS substance_id,
       p.parameter_code         AS substance_code,
       p.parameter_omschrijving AS substance_description,
       p."CAS" as cas
FROM parameter p join (select distinct parameter_code from voorbeelddata.trend) t on t.parameter_code=p.parameter_code
;

-- locations: FOR NOW: BASED ON EXAMPLE DATA
drop view if exists chemtrend.location cascade;
create or replace view chemtrend.location as
select distinct meetpunt_code as location_code, geom from voorbeelddata.trend;

drop view if exists chemtrend.location_geojson cascade;
create or replace view chemtrend.location_geojson as
-- select distinct meetpunt_code as location_code, st_asgeojson(geom) as geom from voorbeelddata.trend;
select json_build_object('type', 'FeatureCollection', 'features', json_agg(ST_AsGeoJSON(location)::json)) as geojson from chemtrend.location;

-- view with locations and its trend color per parameter
create or replace view chemtrend.location_substance as
select location_code, parameter_code, color, geom
from (
    select meetpunt_code as location_code
    , parameter_code
    , geom
    , case skendall_trend
        when 'trend opwaarts' then 'red'
        when 'geen trend' then 'grey'
        when 'trend neerwaarts' then 'green'
    end as color
    from voorbeelddata.trend tr
) x
group by location_code, parameter_code, color, geom
;

-- grant access to all users
GRANT ALL ON all tables in schema chemtrend TO vries_cy;
GRANT ALL ON all tables in schema chemtrend TO schoonve;
GRANT ALL ON all tables in schema chemtrend TO loos_sb;
GRANT ALL ON all tables in schema chemtrend TO rodrigue;
GRANT ALL ON all tables in schema chemtrend TO ouwerkerk;

