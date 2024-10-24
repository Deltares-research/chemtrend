from typing import List, Optional
from fastapi import FastAPI, Response
from starlette.middleware.cors import CORSMiddleware
from chemtrend.models import Substance
from chemtrend.database import metadata, database
from chemtrend.mockup_data import test_subset_locations, test_waterbodies
from sqlalchemy import Integer, cast, column, func, select

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

regions = [{
        "name": "Waterschap",
        "color": "#32a852"
    }, {
        "name": "Waterlichaam",
        "color": "#3632a8"
    }, {
        "name": "Provincie",
        "color": "#a84832"
    }, {
        "name": "Stroomgebied",
        "color": "#a89932"
    }]

catchments = metadata.tables["chemtrend.catchment_geojson"]

# asyncio.run(setup_connection())

@app.get("/substances/", response_model=List[Substance], tags=["Substances"])
async def list_substances():
    """List all substances"""
    query = substances.select()
    await database.connect()
    return await database.fetch_all(query)


@app.get("/locations/", tags=["Locations"])
# @cached(ttl=settings.CACHE_TTL)
async def list_locations_all():
    """List all locations"""
    query = locations.select()
    await database.connect()
    result = await database.fetch_one(query)
    return result.geojson


@app.get("/locations/{substance_id}", tags=["Locations"])
async def get_locations_for_substance(substance_id: int):
    """Retrieve all locations that have data for a given substance_id"""
    query = f"select geojson from chemtrend.location_substance_geojson({substance_id});"
    await database.connect()
    result = await database.fetch_one(query)
    return Response(content=dict(result).get("geojson"), media_type="application/json")


@app.get("/trends/", tags=["Trends"])
async def get_trend_data(x: float, y: float, substance_id: int):
    """Retrieve all trend data for a given location (lon, lat) and substance_id"""
    query = f"select * from chemtrend.trend({x},{y},{substance_id});"
    await database.connect()
    result = await database.fetch_one(query)
    return Response(content=dict(result).get("geojson"), media_type="application/json")


@app.get("/trends_regions/", tags=["Trends_regions"])
async def get_trend_region_data(x: float, y: float, substance_id: int):
    """Retrieve all trend data on regional level for a given location (lon, lat) and substance_id"""
    query = f"select * from chemtrend.trend_region({x},{y},{substance_id});"
    await database.connect()
    result = await database.fetch_one(query)
    return Response(content=dict(result).get("geojson"), media_type="application/json")


@app.get("/list_regions/", tags=["Regions"])
async def get_all_regions():
    """List all available regions"""
    return regions

@app.get("/regions/", tags=["Regions"])
async def get_all_waterbodies(x: float, y: float):
    """Get regions from coordinates"""
    query = f"select * from chemtrend.region_geojson({x},{y});"
    await database.connect()
    result = await database.fetch_one(query)
    return Response(content=dict(result).get("geojson"), media_type="application/json")


@app.get("/catchments/", tags=["catchment"])
async def list_catchment_all():
    """List all catchment (=stroomgebied)"""
    query = catchments.select()
    await database.connect()
    result = await database.fetch_one(query)
    return result.geojson
