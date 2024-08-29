drop schema if exists chemtrend cascade;
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
    , datum x_value -- NB dit is een datum, niet het aantal dagen
    , lowline_x x_days -- dagen sinds 1980?
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
--     where meetpunt_code='NL02_0037' and parameter_code='Cr'
) x
;

-- function to return closest location on given lon/lat (x,y)
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

drop function if exists chemtrend.trend(x decimal, y decimal);

-- grant access
GRANT ALL ON all tables in schema chemtrend TO waterkwaliteit_readonly;
alter schema chemtrend owner to waterkwaliteit_readonly;
