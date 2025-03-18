from typing import List, Optional
from fastapi import FastAPI, Response
from starlette.middleware.cors import CORSMiddleware
from chemtrend.models import Substance, Period
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
periods = metadata.tables["chemtrend.trend_period"]
locations = metadata.tables["chemtrend.location_geojson"]

regions = [{
        "name": "Waterlichaam",
        "color": "#7e2954"
    }, {
        "name": "Waterschap",
        "color": "#dccd7d"
    }, {
        "name": "Provincie",
        "color": "#5da899"
    }, {
        "name": "Stroomgebied",
        "color": "#2e2585"
    }, {
        "name": "Rijkswater",
        "color": "#337538"
    }, {
        "name": "Nederland",
        "color": "#2f485b"
    }]

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
# @app.get("/locations/{substance_id}", tags=["Locations"])
async def get_locations_for_substance(substance_id: int, trend_period: int):
    """Retrieve all locations that have data for a given substance_id and trend period"""
    query = f"select geojson from chemtrend.location_substance_geojson({substance_id}, {trend_period});"
    await database.connect()
    result = await database.fetch_one(query)
    return Response(content=dict(result).get("geojson"), media_type="application/json")


@app.get("/periods/", response_model=List[Period], tags=["Trend periods"])
async def list_trend_periods():
    """List all trend periods"""
    query = periods.select()
    await database.connect()
    return await database.fetch_all(query)


@app.get("/trends/", tags=["Trends"])
async def get_trend_data(x: float, y: float, substance_id: int, trend_period: int):
    """Retrieve all trend data for a given location (lon, lat), substance_id and trend period"""
    query = f"select * from chemtrend.trend({x},{y},{substance_id},{trend_period});"
    await database.connect()
    result = await database.fetch_one(query)
    return Response(content=dict(result).get("geojson"), media_type="application/json")


@app.get("/trends_regions/", tags=["Trends_regions"])
async def get_trend_region_data(x: float, y: float, substance_id: int, trend_period: int):
    """Retrieve all trend data on regional level for a given location (lon, lat), substance_id and trend period"""
    query = f"select * from chemtrend.trend_region({x},{y},{substance_id},{trend_period});"
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
