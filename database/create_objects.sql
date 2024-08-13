create schema if not exists chemtrend;

-- substances
create or replace view chemtrend.substance as
select parameter_id as substance_id
, parameter_code as substance_code
, parameter_omschrijving as substance_description
, "CAS"
from public.parameter;

-- locations: FOR NOW: BASED ON EXAMPLE DATA
create or replace view chemtrend.location as
select distinct meetpunt_code, geom from voorbeelddata.trend;


