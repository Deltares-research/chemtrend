create schema if not exists voorbeelddata;

-- import csv with example data into voorbeelddata.trend

select * into voorbeelddata.test from voorbeelddata.trend where parameter_code='Ntot' and datum>='2000-01-01';
update voorbeelddata.test set parameter_code='Cr';
insert into voorbeelddata.trend select * from voorbeelddata.test;

alter table voorbeelddata.trend add trend_id serial;
alter table voorbeelddata.trend add geom geometry;
update voorbeelddata.trend set geom=st_transform(st_setsrid(st_point(x_rd, y_rd), 28992), 4326);

-- select distinct meetpunt_code,geom, skendall_trend from voorbeelddata.trend where parameter_code='Cr';



-- grant access
GRANT ALL ON all tables in schema voorbeelddata TO waterkwaliteit_readonly;
alter schema voorbeelddata owner to waterkwaliteit_readonly;
