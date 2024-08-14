from typing import List
from fastapi import FastAPI
from chemtrend.models import Substance
from chemtrend.database import metadata, database

app = FastAPI()

substances = metadata.tables["chemtrend.substance"]
locations = metadata.tables["chemtrend.location_geojson"]


@app.get("/substances/", response_model=List[Substance], tags=["substances"])
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


@app.get("/locations/", tags=["location"])
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
    return await database.fetch_all(query)
