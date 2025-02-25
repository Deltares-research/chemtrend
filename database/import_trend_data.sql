-- trend_locatie
truncate table public.trend_locatie;
insert into public.trend_locatie(meetpunt_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, kwaliteitsoordeel_id, datum, tijd, waarde_meting, ats_y, lowline_y, trend_conclusie, p_value_trend, theilsen_slope, rapportagegrens, ats_slope)
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
imp.ats_slope::numeric as ats_slope
-- TO DO: trend_period toevoegen
-- select count(*) --885279
from import."03_data_trend_ats_info" imp
join public.locatie l on l.meetpunt_code_2022=imp.meetpunt_code_2022
join public.parameter p on p.parameter_code=imp.parameter_code
join public.eenheid e on e.eenheid_code=imp.eenheid_code
join public.hoedanigheid h on h.hoedanigheid_code=imp.hoedanigheid_code
join public.compartiment c on c.compartiment_code=imp.compartiment_code
join public.kwaliteitsoordeel k on k.kwaliteitsoordeel_code=coalesce(imp.kwaliteitsoordeel_code,'00')
;

--  trend_regio: waterbeheerder
truncate table public.trend_regio;
insert into public.trend_regio (regio_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, datum, lowess_p0, lowess_p25, lowess_p75)
select
r.regio_id,
p.parameter_id,
e.eenheid_id,
h.hoedanigheid_id,
c.compartiment_id,
datum::date,
lowess_p0,
lowess_p25,
lowess_p75
-- TO DO: trend_period toevoegen
-- select count(*)      -- 188843
from import."05_data_trend_ats_waterbeheerder" imp
join public.regio r on r.regio_type_id=4 and r.bron_id=imp.waterbeheerder_code::int --125968; rijkswateren vallen weg
join public.parameter p on p.parameter_code=imp.parameter_code
join public.eenheid e on e.eenheid_code=imp.eenheid_code
join public.hoedanigheid h on h.hoedanigheid_code=imp.hoedanigheid_code
join public.compartiment c on c.compartiment_code=imp.compartiment_code
;

--  trend_regio: overig (provincie, waterlichaam, stroomgebied, landelijk)
insert into public.trend_regio (regio_id, parameter_id, eenheid_id, hoedanigheid_id, compartiment_id, datum, lowess_p0, lowess_p25, lowess_p75)
select
imp.regio_id,
p.parameter_id,
e.eenheid_id,
h.hoedanigheid_id,
c.compartiment_id,
datum::date,
lowess_p0,
lowess_p25,
lowess_p75
-- TO DO: trend_period toevoegen
from (
    select * from import."06_data_trend_ats_stroomgebied"
    union all
    select * from import."07_data_trend_ats_provincie"
    union all
    select * from import."08_data_trend_ats_waterlichaam"
) imp
join public.parameter p on p.parameter_code=imp.parameter_code
join public.eenheid e on e.eenheid_code=imp.eenheid_code
join public.hoedanigheid h on h.hoedanigheid_code=imp.hoedanigheid_code
join public.compartiment c on c.compartiment_code=imp.compartiment_code
;

