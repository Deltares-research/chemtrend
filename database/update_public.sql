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
where st_isempty(geometry)=false
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
insert into public.locatie_regio (meetpunt_id, regio_id)
select l.meetpunt_id, r.regio_id
from public.locatie l
join public.regio r on 1=1 and st_within(l.geom, r.geom_rd) and st_isempty(l.geom)=false
;
-- TO DO: uitzondering voor waterschap: rijkswateren vallen hier niet in


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

