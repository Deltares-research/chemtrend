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

alter table voorbeelddata.trend_region_subset add region_description varchar;
alter table voorbeelddata.trend_region_subset add region_type varchar;
alter table voorbeelddata.trend_region_subset add trend_label varchar;
alter table voorbeelddata.trend_region_subset add substance varchar;
update voorbeelddata.trend_region_subset trs set region_type = reg.region_type from chemtrend.region reg where reg.region_id=trs.region_id;
update voorbeelddata.trend_region_subset trs set substance=s.substance_description from chemtrend.substance s where s.substance_id=trs.substance_id;
update voorbeelddata.trend_region_subset trs set trend_label = coalesce(location_code, region_description);
update voorbeelddata.trend_region_subset trs set title = substance || ' ' || region_description;


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

-- create example data for trend periods
drop table if exists voorbeelddata.trend_data_periode;
select * into voorbeelddata.trend_data_periode from trend_locatie where meetpunt_id=22193 and parameter_id=333;
alter table voorbeelddata.trend_data_periode add trend_periode int;
insert into voorbeelddata.trend_data_periode
    select *, 1 as trend_periode
    from trend_locatie where meetpunt_id=22193 and parameter_id=333;
update voorbeelddata.trend_data_periode set trend_periode = 0 where trend_periode is null;
delete from voorbeelddata.trend_data_periode where left(datum::varchar,4)::int<2009 and trend_periode=1;
update voorbeelddata.trend_data_periode set p_value_trend=p_value_trend*1.2, ats_y=ats_y*1.2 where trend_periode=1;
delete from voorbeelddata.trend_data_periode where trend_periode=0;

-- grant access
GRANT ALL ON all tables in schema voorbeelddata TO waterkwaliteit_readonly;
alter schema voorbeelddata owner to waterkwaliteit_readonly;
