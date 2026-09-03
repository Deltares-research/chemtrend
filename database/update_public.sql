-- voeg kenmerk toe aan parametertabel voor stoffen die getoond moeten worden in chemtrend:
alter table public.parameter add column if not exists chemtrend bool;
alter table public.parameter add column if not exists hoedanigheid_id int references public.hoedanigheid(hoedanigheid_id);
update public.parameter set chemtrend = false; -- reset
update public.parameter p
set chemtrend=true, hoedanigheid_id=h.hoedanigheid_id
from import.stof_hoedanigheid sh
join public.hoedanigheid h on h.hoedanigheid_code=sh.hoedanigheid_code
where sh.parameter_code=p.parameter_code
;

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
     , (3,'Deelstroomgebied')
     , (4,'Waterschap')
     , (5,'Waterlichaam')
     , (6, 'Rijkswater')
;


-- niveau Nederland in regio-tabel
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select 0 as bron_id, 1 as regio_type_id, 'Nederland' as regio_omschrijving, st_transform(geom, 4326) as geom, geom as geom_rd
from import.nederland_eez;

insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select "FID" as bron_id, 2 as region_type_id, "Provincien" as region_description, geometry as geom, st_transform(geometry, 28992) as geom_rd
from public.provincies
where st_isempty(geometry)=false
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select "OBJECTID" as bron_id, 3 as region_type_id, "NAAM" as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public.deelstroomgebieden
where st_isempty(geometry)=false
and ("COUNTRY" = 'NL' or "COUNTRY" is null)
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select waterbeheerder_id as bron_id, 4 as region_type_id, waterbeheerder_omschrijving as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public.waterbeheerder
where (st_isempty(geometry)=false and waterbeheerder_code<>'80')
;
update public.regio set geom=st_force2d(geom), geom_rd=st_force2d(geom_rd) where regio_type_id=4; -- only x & y (remove z=0)
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select db_id_extern as bron_id, 5 as region_type_id, waterlichaam_omschrijving as region_description, st_transform(geometry, 4326) as geom, geometry geom_rd
from public."KRW_waterlichaam"
where st_isempty(geometry)=false
;
insert into public.regio (bron_id, regio_type_id, regio_omschrijving, geom, geom_rd)
select waterbeheerder_id as bron_id, 6 as region_type_id, waterbeheerder_omschrijving as region_description
, q.geom as geom, st_transform(q.geom,28992) as geom_rd
from (
    select st_union(x.geom) as geom
    from (
        select geom from import.eez
        union
        select st_transform(st_union(geom),4326) geom from import.krw_oppwl
    ) x
) q
, (select * from public.waterbeheerder where waterbeheerder_code='80') wat
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
select r.regio_id, r.regio_omschrijving, rt.regio_type, l.meetpunt_id, l.meetpunt_code_nieuw as meetpunt_code, rt.regio_type_id
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
select l.meetpunt_id, l.meetpunt_code_nieuw, w.waterbeheerder_id, w.waterbeheerder_code, w.waterbeheerder_omschrijving, r.regio_id, r.bron_id, r.regio_omschrijving
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

------------------------ HIER: TREND-DATA IMPORTEREN -----------------------------
------------------------ draai hiervoor "import_trend_data.sql" ------------------

-- toevoegingen t.b.v. meetdata
alter table public.metingen add if not exists meting_id serial;

-- determine measurement data without trend
-- all measurement data without trends for the combination location&parameter
drop table if exists public._metingen_zonder_trend;
select met.meting_id
into public._metingen_zonder_trend
from public.metingen met
join (
    -- used parameters
    select parameter_id from public.parameter where chemtrend=true
) as tp on tp.parameter_id=met.parameter_id -- parameter must occur (=scope of trend calculations)
left join (
    -- all trend data: locations & parameters
    select meetpunt_id, parameter_id, count(*) aantal
    from public.trend_locatie tl
    group by meetpunt_id, parameter_id
) td on td.parameter_id=met.parameter_id and td.meetpunt_id=met.meetpunt_id
where td.meetpunt_id is null  -- no trends for combination of location&parameter
;

-- tbv performance: extra indicatie om aan te geven of er metingen zonder trends zijn (voor dezelfde combinaties van parameter en locatie):
-- NB: parameter nvt? -> trend=null
alter table public.metingen add if not exists trend bool;
-- update public.metingen set trend=null;   --repair
update public.metingen set trend = true where parameter_id in (select parameter_id from public.parameter where chemtrend=true);    -- reset
update public.metingen set trend = False where meting_id in (select meting_id from public._metingen_zonder_trend);

-- tbv performance: extra indicatie om aan te geven of de locatie tenminste een trend of een meting-zonder-trend heeft
alter table public.locatie add if not exists trend_of_meting bool;
update public.locatie set trend_of_meting = null;   -- reset
update public.locatie set trend_of_meting = true where meetpunt_id in (select distinct meetpunt_id from public.trend_locatie);
update public.locatie set trend_of_meting = true where meetpunt_id in (select distinct meetpunt_id from public.metingen where trend=false);

-- corrigeer normwaarde
update public.norm set waarde=replace(waarde, ',','.');

-- relatie tussen normen en stoffen (parameter)
drop view if exists public.norm_parameter cascade;
create or replace view public.norm_parameter as
select n.*, par.parameter_id, e.eenheid_id
    , row_number() over (partition by n.stofnaam, n.zoet, norm_type order by    -- NB desc sorteren, want false < true
--         case when wt.saltwater=true then n.saltwater else n.freshwater end desc,
         opgelost desc
        , totaal desc
        , mtr desc
        , indicatief desc
        , waterbeheerder desc, drinkwaterbedrijf desc, drinkwaterkwaliteitseis desc
        )::int as norm_volgorde
    -- o.b.v. normen Aquokit, deze uitzonderingen kenmerken:
    -- Voor 6 stoffen: altijd norm weglaten: Cd,Cu,NH4,Ni,Pb,Zn
    -- Voor 5 stoffen: norm weglaten igv M30/M31: As,B,Sn,U,V
    , case when par.parameter_code in ('Cd','Cu','NH4','Ni','Pb','Zn') then true else false end bijzondere_norm
    , case when par.parameter_code in ('As','B','Sn','U','V') then array['M30','M31'] end verberg_JG_voor_krwtype
    , case when par.parameter_code in ('As','B','Ba','Co','Hg','Mo','Ni','Pb','Sb','Se','Sn','U','Zn') then array['M30','M31'] end verberg_MAC_voor_krwtype
from (
    select *
    , case when compartiment like '%zoet%' then true else false end as zoet
    , case when compartiment like '%zout%' then true else false end as zout
    , case when norm ilike '%drinkwater%' then true else false end ::boolean drinkwaternorm
    , case when norm ilike '%MTR%' then true else false end ::boolean mtr
    , case when norm ilike '%indicatief%' then true else false end ::boolean indicatief
    , case when norm ilike '%opgelost%' then true else false end ::boolean opgelost
    , case when norm ilike '%totaal%' then true else false end ::boolean totaal
    , case when norm ilike '%waterbeheerder%' then true else false end ::boolean waterbeheerder
    , case when norm ilike '%drinkwaterbedrijf%' then true else false end ::boolean drinkwaterbedrijf
    , case when norm ilike '%drinkwaterkwaliteitseis%' then true else false end ::boolean drinkwaterkwaliteitseis
    , case  when norm like '%MAC-MKN%' then 'MAC-MKN'
            when norm like '%JG-MKN%' or norm like '%MTR%' then 'JG-MKN'
            when norm ilike '%drinkwater%' then 'drinkwater'
            else 'overig'
        end norm_type
    from public.norm
    where compartimentcode='OW'
)n
join public.parameter par on par.parameter_code=n.aquocode and par."CAS"=n.casnummer
left join public.eenheid e on e.eenheid_code=replace(n.eenheid, 'µg/l', 'ug/l')
;

drop table if exists public.norm_aquokit;
select *
into public.norm_aquokit
from (
    select 'ps_zoet' as bron, * from import.normen_ps_zoet
    union all
    select 'ps_zout' as bron, * from import.normen_ps_zout
    union all
    select 'svs_zoet' as bron, * from import.normen_svs_zoet
    union all
    select 'svs_zout' as bron, * from import.normen_svs_zout
) q;

-- gebruik krw_watertype om locaties te typeren als zoet/zout
alter table public.locatie add column if not exists krw_watertype_id int references public.krw_watertype(id);
create index if not exists ix_krw_wl on public."KRW_waterlichaam" using gist(geometry);
update public.locatie loc set krw_watertype_id=kwt.id
from public.krw_watertype kwt
join public."KRW_waterlichaam" kwl on kwl."waterlichaam_KRWtype_code"=kwt.code
where st_within(loc.geometry, kwl.geometry);

-- indexes tbv meetdata
create index if not exists ix_metingen_meetpunt_parameter on public.metingen(trend, parameter_id, meetpunt_id);
create index if not exists ix_trend_locatie_parameter on public.trend_locatie(parameter_id) include (trend_period, trend_conclusie, meetpunt_id);

-- add index to locatie table
create index if not exists ix_locatie_geom on public.locatie using gist(geometry);
create index if not exists ix_locatie_meetpunt on public.locatie(meetpunt_id, meetpunt_code_nieuw, trend_of_meting) include (geometry);

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
alter table public.norm owner to waterkwaliteit_readonly;

