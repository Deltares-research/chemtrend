
---------- REGIO_ID CORRIGEREN OBV NAAM ---------
-- stroomgebied, provincie, waterlichaam
alter table import."08_data_trend_ats_waterlichaam" add column regio_id_new int;
alter table import."08B_data_trend_ats_waterlichaam_vanaf_2009" add column regio_id_new int;
alter table import."07_data_trend_ats_provincie" add column regio_id_new int;
alter table import."07B_data_trend_ats_provincie_vanaf_2009" add column regio_id_new int;
alter table import."06_data_trend_ats_stroomgebied" add column regio_id_new int;
alter table import."06B_data_trend_ats_stroomgebied_vanaf_2009" add column regio_id_new int;

update import."08_data_trend_ats_waterlichaam" imp set regio_id_new = r.regio_id from public.regio r where r.regio_omschrijving=imp.regio_omschrijving;
update import."08B_data_trend_ats_waterlichaam_vanaf_2009" imp set regio_id_new = r.regio_id from public.regio r where r.regio_omschrijving=imp.regio_omschrijving;
update import."07_data_trend_ats_provincie" imp set regio_id_new = r.regio_id from public.regio r where r.regio_omschrijving=imp.regio_omschrijving;
update import."07B_data_trend_ats_provincie_vanaf_2009" imp set regio_id_new = r.regio_id from public.regio r where r.regio_omschrijving=imp.regio_omschrijving;
update import."06_data_trend_ats_stroomgebied" imp set regio_id_new = r.regio_id from public.regio r where r.regio_omschrijving=imp.regio_omschrijving;
update import."06B_data_trend_ats_stroomgebied_vanaf_2009" imp set regio_id_new = r.regio_id from public.regio r where r.regio_omschrijving=imp.regio_omschrijving;

-- VUL REGIO_ID AAN IN LANDELIJKE TREND-TABEL
alter table import."04_data_trend_ats_landelijk" add regio_id int;
alter table import."04_data_trend_ats_landelijk" add regio_id_new int;
alter table import."04B_data_trend_ats_landelijk_vanaf_2009" add regio_id int;
alter table import."04B_data_trend_ats_landelijk_vanaf_2009" add regio_id_new int;
update import."04_data_trend_ats_landelijk" set regio_id = r.regio_id, regio_id_new = r.regio_id from public.regio r where r.regio_type_id=1;
update import."04B_data_trend_ats_landelijk_vanaf_2009" set regio_id = r.regio_id, regio_id_new = r.regio_id from public.regio r where r.regio_type_id=1;



-- trend_locatie: empty tabel
truncate table public.trend_locatie;
insert into public.trend_locatie(meetpunt_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, kwaliteitsoordeel_id, datum, tijd, waarde_meting, ats_y, lowline_y, trend_conclusie, p_value_trend, theilsen_slope, rapportagegrens, ats_slope, trend_period)
select
l.meetpunt_id meetpunt_id,
p.parameter_id,
e.eenheid_id,
h.hoedanigheid_id,
c.compartiment_id,
k.kwaliteitsoordeel_id,
imp.datum::date,
imp.tijd::time,
imp.waarden::numeric as waarde_meting,
imp.ats_y::numeric,
imp.lowline_y::numeric,
case imp.trend_conclusie
    when 'trend neerwaarts' then -1
    when 'geen trend' then 0
    when 'trend opwaarts' then 1
    end ::smallint as skendall_trend,
imp.p_value_trend::numeric,
imp.theilsen_slope::numeric,
imp.rg::bool as rapportagegrens,
imp.ats_slope::numeric as ats_slope,
imp.trend_period
from (
    -- select count(*) --1206053    --> 1202886 (=excl recs met meetpunt_code_2023=NULL)
    select *, 0::int as trend_period from import."03_data_trend_ats_info"
    union all
    -- select count(*) --969857 --> 966941
    select *, 1::int as trend_period from import."03B_data_trend_ats_info_vanaf_2009"
)imp
join public.locatie l on l.meetpunt_code_nieuw=imp.meetpunt_code_2023
join public.parameter p on p.parameter_code=imp.parameter_code
join public.eenheid e on e.eenheid_code=imp.eenheid_code
join public.hoedanigheid h on h.hoedanigheid_code=imp.hoedanigheid_code
join public.compartiment c on c.compartiment_code=imp.compartiment_code
join public.kwaliteitsoordeel k on k.kwaliteitsoordeel_code=coalesce(imp.kwaliteitsoordeel_code,'00')
;

--  trend_regio: waterbeheerder
truncate table public.trend_regio;
insert into public.trend_regio (regio_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, datum, lowess_p25, lowess_p50, lowess_p75, trend_period)
select
r.regio_id,
p.parameter_id,
e.eenheid_id,
h.hoedanigheid_id,
c.compartiment_id,
datum::date,
lowess_p25::decimal,
lowess_p0::decimal as lowess_p50,
lowess_p75::decimal,
trend_period
-- select count(*)      -- 544438
from (  select *, 0 as trend_period from import."05_data_trend_ats_waterbeheerder"
        union all
        select *, 1 as trend_period from import."05B_data_trend_ats_waterbeheerder_vanaf_2009"
) imp
join public.waterbeheerder wb on wb.waterbeheerder_code=imp.waterbeheerder_code
join public.regio r on r.bron_id=wb.waterbeheerder_id and r.regio_type_id in (4,6)
join public.parameter p on p.parameter_code=imp.parameter_code
join public.eenheid e on e.eenheid_code=imp.eenheid_code
join public.hoedanigheid h on h.hoedanigheid_code=imp.hoedanigheid_code
join public.compartiment c on c.compartiment_code=imp.compartiment_code
;

--  trend_regio: overig (provincie, waterlichaam, stroomgebied, landelijk)
insert into public.trend_regio (regio_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, datum, lowess_p25, lowess_p50, lowess_p75, trend_period)
select
r.regio_id,
p.parameter_id,
e.eenheid_id,
h.hoedanigheid_id,
c.compartiment_id,
datum::date,
lowess_p25::decimal,
lowess_p0::decimal as lowess_p50,
lowess_p75::decimal,
trend_period
-- select count(*)      -- 1941120
from (
    select regio_id, 'Nederland' as regio_omschrijving
        , parameter_code, eenheid_code, hoedanigheid_code, compartiment_code, datum, lowess_p0, lowess_p25, lowess_p75
        , regio_id_new, 1::int as trend_period from import."04B_data_trend_ats_landelijk_vanaf_2009"
    union all
    select regio_id, 'Nederland' as regio_omschrijving
        ,parameter_code, eenheid_code, hoedanigheid_code, compartiment_code, datum, lowess_p0, lowess_p25, lowess_p75
        , regio_id_new, 0::int as trend_period from import."04_data_trend_ats_landelijk"
    union all
    select *, 1::int as trend_period from import."06B_data_trend_ats_stroomgebied_vanaf_2009"
    union all
    select *, 0::int as trend_period from import."06_data_trend_ats_stroomgebied"
    union all
    select *, 1::int as trend_period from import."07B_data_trend_ats_provincie_vanaf_2009"
    union all
    select *, 0::int as trend_period from import."07_data_trend_ats_provincie"
    union all
    select *, 1::int as trend_period from import."08B_data_trend_ats_waterlichaam_vanaf_2009"
    union all
    select *, 0::int as trend_period from import."08_data_trend_ats_waterlichaam"
) imp
join public.parameter p on p.parameter_code=imp.parameter_code
join public.eenheid e on e.eenheid_code=imp.eenheid_code
join public.hoedanigheid h on h.hoedanigheid_code=imp.hoedanigheid_code
join public.compartiment c on c.compartiment_code=imp.compartiment_code
join public.regio r on r.regio_id=imp.regio_id_new  -- stroomgebied BE/DE weglaten
;


