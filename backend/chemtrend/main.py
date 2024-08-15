from typing import List
from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from chemtrend.models import Substance
from chemtrend.database import metadata, database
from chemtrend.mockup_data import test_subset_locations

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

substances = metadata.tables["chemtrend.substance"]
locations = metadata.tables["chemtrend.location_geojson"]

@app.get("/substances/", response_model=List[Substance], tags=["Substances"])
async def list_substances():
    query = substances.select()
    await database.connect()
    return await database.fetch_all(query)


# @app.get("/locations/", response_model=List[LocationSimple], tags=["location"])
# async def list_locations(description: Optional[str] = None, limit: int = 10):
#     """Retrieve a list of locations."""
#     query = locations_json.select()
#     if description:
#         query = query.where(locations_json.c.description.ilike(f"%{description}%"))
#     return await database.fetch_all(query.limit(limit))


@app.get("/locations/", tags=["Locations"])
# @cached(ttl=settings.CACHE_TTL)
async def list_locations_geojson():
    # newer method using postgis v3:
    # query = """select * from chemtrend.location_geojson;"""
    # old method using older postgis version:
    # query = """SELECT row_to_json(fc) as geojson
    #         FROM
    #         (SELECT 'FeatureCollection' As type,
    #                 array_to_json(coalesce(array_agg(f), '{}')) As features
    #             FROM
    #             (SELECT 'Feature' As type ,
    #                     ST_AsGeoJSON(geom, 4)::json As geometry ,
    #                     row_to_json((SELECT l FROM (SELECT (location_id)) AS l)) As properties
    #                 FROM eitoets.location) As f) As fc;"""
    # record = await database.fetch_one(query)
    # return Response(content=dict(record).get("geojson"), media_type="application/json")
    query = locations.select()
    await database.connect()
    # TODO: should be fixed in the DB? (fetchall gives an array with: [{geojson: <THE PART I NEED>}])
    result = await database.fetch_one(query)
    return result.geojson

@app.get("/locations/{substance_id}", tags=["Locations"])
async def get_locations_for_substance(substance_id: int):
    """Retrieve all locations that have a substance_id"""
    print(f"Nice to have the substance_id: {substance_id}")
    # TODO: Wouter do your magic :)
    return test_subset_locations


# @app.get("/waterbodies/", tags=["Waterbodies"])
# async def list_waterbodies_geojson():
#     query = waterbodies.select()
#     await database.connect()
#     # TODO: should be fixed in the DB? (fetchall gives an array with: [{geojson: <THE PART I NEED>}])
#     result = await database.fetch_one(query)
#     return result.geojson



# location_substance (locations incl color for a given substance)
# trend (for given location (lon/lat))
# note: the trends could be for both measurement locations and regions (like waterbodies)
# regions
# waterbodies (already in public, make available via 'chemtrend'