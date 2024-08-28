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

-- TO DO: function o.b.v. deze view maken: chemtrend.trend(location_id, substance_id)
drop view if exists chemtrend.trend;
create or replace view chemtrend.trend as
select *
from (
    select 'meting' as category
    , tr.parameter_code || ' ' || meetpunt_code as title
    , 'Trendresultaat: ' || skendall_trend || ' (p=' || (p_value_skendall) || ')' as subtitle_1
    , 'Trendhelling: ' || (theilsen_slope * 365 * 10) || ' ug/l per decennium' as subtitle_2
    , 'datum' as x_label
    , parameter_code || ' [' || eenheid_code || ' ' || hoedanigheidcode || ']' as y_label
    , '1=meting, 2=Lowess, 3=Theil-Sen' as legend
    , datum x_value -- NB dit is een datum, niet het aantal dagen
    , lowline_x x_days -- dagen sinds 1980?
    , case meting when 'Boven detectielimiet' then true else false end as point_filled
    , waarde as y_value_1
    , lowline_y as y_value_2
    , theilsen_intercept y_value_3
    , 'MKN' as h1_label
    , norm_n as h1_value
    , 'MAC' as h2_label
    , norm_p as h2_value
    , 'black' as y_color_1
    , 'orange' as y_color_2
    , case skendall_trend
        when 'trend opwaarts' then 'red'
        when 'geen trend' then 'grey'
        when 'trend neerwaarts' then 'green'
    end as y_color_3
    , 'solid' as y_type_1
    , 'dashed' as y_type_2
    , 'curved' as y_type_3
    -- select *
    from voorbeelddata.trend tr
    where meetpunt_code='NL02_0037' and parameter_code='Cr'
) x
;

-- grant access to all users
GRANT ALL ON all tables in schema chemtrend TO vries_cy;
GRANT ALL ON all tables in schema chemtrend TO schoonve;
GRANT ALL ON all tables in schema chemtrend TO loos_sb;
GRANT ALL ON all tables in schema chemtrend TO rodrigue;
GRANT ALL ON all tables in schema chemtrend TO ouwerkerk;

