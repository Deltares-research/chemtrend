create schema if not exists voorbeelddata;

-- import csv with example data into voorbeelddata.trend

select * into voorbeelddata.test from voorbeelddata.trend where parameter_code='Ntot' and datum>='2000-01-01';
update voorbeelddata.test set parameter_code='Cr';
insert into voorbeelddata.trend select * from voorbeelddata.test;

alter table voorbeelddata.trend add trend_id serial;
alter table voorbeelddata.trend add geom geometry;
update voorbeelddata.trend set geom=st_transform(st_setsrid(st_point(x_rd, y_rd), 28992), 4326);

-- select distinct meetpunt_code,geom, skendall_trend from voorbeelddata.trend where parameter_code='Cr';

create index ix_meetpuntcode on voorbeelddata.trend (meetpunt_code);

-- create regional trend data
with p as (
    select * from chemtrend.region(5.019, 52.325)
)
, lr as (
    select * from chemtrend.location_region
    -- join p on p.region_id=lr.region_id
    where region_id in (select region_id from p)
)
select lr.region_id, tr.*
into voorbeelddata.trend_region_subset
from lr join chemtrend.trend tr on tr.location_code=lr.location_code
where tr.x_value>='2013-01-01'
;

select *
into chemtrend.location_region_table
from chemtrend.location_region;

alter table  voorbeelddata.trend_region_subset add region_description varchar;
update  voorbeelddata.trend_region_subset trs set region_description = reg.region_description from chemtrend.region reg where reg.region_id=trs.region_id;

drop table if exists voorbeelddata.trend_region_subset_zonder_locatie;

select region_id
     , null::varchar as location_code
    , substance_id, substance_code, category
     ,'chroom Rijn-West' as title
     , subtitle_1, subtitle_2, x_label, y_label, x_value, x_days, point_filled
     , null::decimal as y_value_meting
     , y_value_lowess
     , 1+y_value_theil_sen as y_value_theil_sen
     , h1_label, h1_value, h2_label, h2_value, region_description
into voorbeelddata.trend_region_subset_zonder_locatie
from voorbeelddata.trend_region_subset
where location_code='NL12_405002' and substance_id=517 and region_id=4346
;

delete from voorbeelddata.trend_region_subset where location_code is null;
insert into  voorbeelddata.trend_region_subset
select *
from voorbeelddata.trend_region_subset_zonder_locatie
;

-- grant access
GRANT ALL ON all tables in schema voorbeelddata TO waterkwaliteit_readonly;
alter schema voorbeelddata owner to waterkwaliteit_readonly;
