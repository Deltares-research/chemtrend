-- regio type (tbv tabel regio)
drop table if exists public.regio_type;
create table if not exists public.regio_type(
    regio_type_id int primary key,
    regio_type varchar
);

-- regio: verzameling van regionale polygonen van verschillende niveaus (provincie, waterschap, etc.) in één tabel
drop table if exists public.regio;
create table if not exists public.regio (
    regio_id serial primary key,
    bron_id int,
    regio_type_id int not null references public.regio_type(regio_type_id),
    regio_omschrijving varchar,
    geom geometry,
    geom_rd geometry
);
create index ix_geom on public.regio using gist(geom);
create index ix_geom_rd on public.regio using gist(geom_rd);

insert into public.regio_type (regio_type_id, regio_type) VALUES (1,'Nederland'), (2, 'Provincie'), (3,'Stroomgebied'), (4,'Waterschap'), (5,'Waterlichaam');

insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select "FID" as bron_id, 2 as region_type_id, "Provincien" as region_description, geometry as geom, st_transform(geometry, 28992) as geom_rd
from public.provincies
where st_isempty(geometry)=false
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select "OBJECTID" as bron_id, 3 as region_type_id, "NAAM" as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public.deelstroomgebieden
where st_isempty(geometry)=false
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select waterbeheerder_id as bron_id, 4 as region_type_id, waterbeheerder_omschrijving as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public.waterbeheerder
where (st_isempty(geometry)=false or (waterbeheerder_code='80' and waterbeheerder_omschrijving='Rijkswaterstaat'))
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select db_id_extern as bron_id, 5 as region_type_id, waterlichaam_omschrijving as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public."KRW_waterlichaam"
where st_isempty(geometry)=false
;

-- locaties koppelen aan regio
create table public.locatie_regio (
    locatie_regio_id serial primary key,
    meetpunt_id int references public.locatie(meetpunt_id),
    regio_id int references public.regio(regio_id)
);
-- locatiekoppeling o.b.v. regio
insert into public.locatie_regio (meetpunt_id, regio_id)
select l.meetpunt_id, r.regio_id
from public.locatie l
join public.regio r on 1=1 and st_within(l.geom, r.geom_rd) and st_isempty(l.geom)=false
;
-- correctie: meetpunten op grensgebied of onder beheer van RWS:
drop table if exists public._temp_correctie_locatie_regio;
select l.meetpunt_id, l.meetpunt_code_2022, w.waterbeheerder_id, w.waterbeheerder_code, w.waterbeheerder_omschrijving, r.regio_id, r.bron_id, r.regio_omschrijving
, wr.regio_id as new_regio_id
into public._temp_correctie_locatie_regio
-- select count(*)
from public.locatie l
join public.waterbeheerder w on w.waterbeheerder_id=l.waterbeheerder_id
join public.regio wr on wr.bron_id=w.waterbeheerder_id and wr.regio_type_id=4
join public.locatie_regio lr on lr.meetpunt_id=l.meetpunt_id
join public.regio r on r.regio_id=lr.regio_id and r.regio_type_id=4
where r.bron_id<>w.waterbeheerder_id
-- and l.meetpunt_id=6237
-- and left(l.meetpunt_code_2022,2) != w.waterbeheerder_id::varchar
-- and l.meetpunt_id in (select distinct meetpunt_id from public.trend_locatie)
;
update public.locatie_regio lr set regio_id=x.new_regio_id
from public._temp_correctie_locatie_regio x
where x.meetpunt_id=lr.meetpunt_id and x.regio_id=lr.regio_id
;
drop table if exists public._temp_correctie_locatie_regio;

-- view to use for regional data
create or replace view public.locatie_regio_info as
select r.regio_id, r.regio_omschrijving, rt.regio_type, l.meetpunt_id, l.meetpunt_code_2022 as meetpunt_code
from public.regio r
join public.regio_type rt on r.regio_type_id = rt.regio_type_id
join public.locatie_regio lr on r.regio_id = lr.regio_id
join public.locatie l on lr.meetpunt_id = l.meetpunt_id
;

-- trend data
create table public.trend_regio (
    trend_regio_id serial primary key,
    regio_id int references public.regio (regio_id),
    parameter_id int references public.parameter(parameter_id),
    eenheid_id int references public.eenheid(eenheid_id),
    hoedanigheid_id int references public.hoedanigheid(hoedanigheid_id),
    compartiment_id int references public.compartiment(compartiment_id),
    datum date,
    lowess_p25 numeric,
    lowess_p50 numeric,--staat in importtabel als p0
    lowess_p75 numeric
);

-- drop table public.trend_locatie cascade;
create table public.trend_locatie (
    trend_locatie serial primary key,
    meetpunt_id int references public.locatie(meetpunt_id),
    parameter_id int references public.parameter(parameter_id),
    eenheid_id int references public.eenheid(eenheid_id),
    hoedanigheid_id int references public.hoedanigheid(hoedanigheid_id),
    compartiment_id int references public.compartiment(compartiment_id),
    kwaliteitsoordeel_id int references public.kwaliteitsoordeel(kwaliteitsoordeel_id),
    datum date,
    tijd time,
    waarde_meting numeric,
    ats_y numeric,
    lowline_y numeric,
    skendall_trend smallint,
    p_value_skendall numeric,
    theilsen_slope numeric,
    rapportagegrens bool,
    ats_slope numeric
);

-- add index to locatie table
create index ix_locatie3 on public.locatie(meetpunt_id, meetpunt_code_2022) include (geom);

-- grant access
GRANT ALL ON all tables in schema public TO waterkwaliteit_readonly;
alter table public.trend_locatie owner to waterkwaliteit_readonly;
alter table public.trend_regio owner to waterkwaliteit_readonly;
alter table public.regio_type owner to waterkwaliteit_readonly;
alter table public.regio owner to waterkwaliteit_readonly;
alter table public.locatie_regio owner to waterkwaliteit_readonly;

