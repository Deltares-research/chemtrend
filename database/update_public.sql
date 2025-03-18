-- regio type (tbv tabel regio)
drop table if exists public.regio_type cascade;
create table if not exists public.regio_type(
    regio_type_id int primary key,
    regio_type varchar
);

-- regio: verzameling van regionale polygonen van verschillende niveaus (provincie, waterschap, etc.) in één tabel
drop table if exists public.regio cascade;
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

insert into public.regio_type (regio_type_id, regio_type)
VALUES (1,'Nederland')
     , (2, 'Provincie')
     , (3,'Stroomgebied')
     , (4,'Waterschap')
     , (5,'Waterlichaam')
     , (6, 'Rijkswater')
;

-- niveau Nederland in regio-tabel
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select 0 as bron_id, 1 as regio_type_id, 'Nederland' as regio_omschrijving, st_transform(geometry, 4326) as geom, geometry as geom_rd
from public.nationaal_level_polygoon;

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
where (st_isempty(geometry)=false and waterbeheerder_code<>'80')
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select db_id_extern as bron_id, 5 as region_type_id, waterlichaam_omschrijving as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public."KRW_waterlichaam"
where st_isempty(geometry)=false
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select waterbeheerder_id as bron_id, 6 as region_type_id, waterbeheerder_omschrijving as region_description, st_transform(mp.geometry, 4326) as geom, mp.geometry geom_rd
from public.waterbeheerder wat
join (
    select wat.waterbeheerder_code, st_concavehull(st_union(loc.geometry) , 1) as geometry
    from public.locatie loc
    join public.waterbeheerder wat on wat.waterbeheerder_id=loc.waterbeheerder_id
    where wat.waterbeheerder_code = '80'    -- between '80' and '95'
    and st_isempty(loc.geometry)=false and loc.x_rd>0 and loc.x_rd<300000
    group by wat.waterbeheerder_code
) mp on mp.waterbeheerder_code=wat.waterbeheerder_code
;

--------- LOCATIES KOPPELEN AAN REGIO -----------
create schema if not exists temp;
-- 1. koppeltabel aanmaken
drop table if exists public.locatie_regio cascade;
create table public.locatie_regio (
    locatie_regio_id serial primary key,
    meetpunt_id int references public.locatie(meetpunt_id),
    regio_id int references public.regio(regio_id)
);
-- view to use for regional data
drop view if exists public.locatie_regio_info;
create or replace view public.locatie_regio_info as
select r.regio_id, r.regio_omschrijving, rt.regio_type, l.meetpunt_id, l.meetpunt_code_2023 as meetpunt_code, rt.regio_type_id
from public.regio r
join public.regio_type rt on r.regio_type_id = rt.regio_type_id
join public.locatie_regio lr on r.regio_id = lr.regio_id
join public.locatie l on lr.meetpunt_id = l.meetpunt_id
;

-- 2. locatiekoppeling o.b.v. geometrie
insert into public.locatie_regio (meetpunt_id, regio_id)
select l.meetpunt_id, r.regio_id
from public.locatie l
join public.regio r on 1=1 and st_within(l.geometry, r.geom_rd) and st_isempty(l.geometry)=false
--     uitgezonderd regio NL (want aparte query)
    and r.regio_type_id>1
;
-- 3. correctie: meetpunten op grensgebied of onder beheer van RWS:
drop table if exists temp.correctie_locatie_regio;
-- (vul temp tabel)
select l.meetpunt_id, l.meetpunt_code_2023, w.waterbeheerder_id, w.waterbeheerder_code, w.waterbeheerder_omschrijving, r.regio_id, r.bron_id, r.regio_omschrijving
, wr.regio_id as new_regio_id
into temp.correctie_locatie_regio
from public.locatie l
join public.waterbeheerder w on w.waterbeheerder_id=l.waterbeheerder_id
join public.regio wr on wr.bron_id=w.waterbeheerder_id and wr.regio_type_id in (4,6)
join public.locatie_regio lr on lr.meetpunt_id=l.meetpunt_id
join public.regio r on r.regio_id=lr.regio_id and r.regio_type_id in (4,6)
where r.bron_id<>w.waterbeheerder_id;
-- (update obv temp tabel)
update public.locatie_regio lr set regio_id=x.new_regio_id
from temp.correctie_locatie_regio x
where x.meetpunt_id=lr.meetpunt_id and x.regio_id=lr.regio_id;
-- 4. aanvulling: meetpunten die horen bij een waterbeheerder maar buiten polygoon vallen (en om die reden nog niet in koppeltabel toegevoegd)
drop table if exists temp.aanvulling_loc_reg;
select l.meetpunt_id, l.waterbeheerder_id, r2b.regio_id
into temp.aanvulling_loc_reg
from public.locatie l
left join public.locatie_regio_info lr on lr.meetpunt_id=l.meetpunt_id and lr.regio_type_id in (4,6)
join public.waterbeheerder w on l.waterbeheerder_id = w.waterbeheerder_id
join public.regio r2b on r2b.regio_type_id in (4,6) and r2b.bron_id=l.waterbeheerder_id
where lr.meetpunt_id is null
and st_isempty(l.geometry)=false
;
insert into public.locatie_regio (meetpunt_id, regio_id)
select meetpunt_id, regio_id from temp.aanvulling_loc_reg;

-- koppel alle meetpunten aan regio NL
insert into public.locatie_regio (meetpunt_id, regio_id)
select l.meetpunt_id, r.regio_id
from public.locatie l join public.regio r on 1=1 and r.regio_type_id=1
where st_isempty(l.geometry)=false;


-- trend data
drop table if exists public.trend_regio cascade;
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
    lowess_p75 numeric,
    trend_period int
);

drop table public.trend_locatie cascade;
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
    trend_conclusie smallint,
    p_value_trend numeric,
    theilsen_slope numeric,
    rapportagegrens bool,
    ats_slope numeric,
    trend_period int
);

-- add index to locatie table
create index if not exists ix_locatie3 on public.locatie(meetpunt_id, meetpunt_code_2023) include (geometry);

-- extra indexes:
create index if not exists ix_locatie_regio on public.locatie_regio(meetpunt_id, regio_id);
create index if not exists ix_regio_type on public.regio_type(regio_type, regio_type_id);
create index if not exists ix_regio on public.regio(regio_type_id,regio_id, regio_omschrijving);
create index if not exists ix_trend_locatie on public.trend_locatie(meetpunt_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, kwaliteitsoordeel_id);
create index if not exists ix_trend_regio on public.trend_regio(regio_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id);


-- grant access
GRANT ALL ON all tables in schema public TO waterkwaliteit_readonly;
alter table public.trend_locatie owner to waterkwaliteit_readonly;
alter table public.trend_regio owner to waterkwaliteit_readonly;
alter table public.regio_type owner to waterkwaliteit_readonly;
alter table public.regio owner to waterkwaliteit_readonly;
alter table public.locatie_regio owner to waterkwaliteit_readonly;

