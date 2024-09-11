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


@app.get("/waterbodies/", tags=["Waterbodies"])
async def get_all_waterbodies():
    """List all waterbodies"""
    # TODO: Magic again
    return test_waterbodies


# @app.get("/waterbodies/", tags=["Waterbodies"])
# async def list_drinkwater_segments_geojson(
#     longitude: Optional[float] = None, latitude: Optional[float] = None
# ):
#     # TODO: for now I used shapely to check if a coordinate falls
#     # inside one of the polygons.
#     print(longitude, latitude)
#     features = gpd.GeoDataFrame.from_features(test_selected_areas)
#     # features = gpd.read_file(str(test_selected_areas), driver="GEOJSON")
#     print(features)
#     df = pd.DataFrame({'longitude': [latitude], 'latitude': [longitude]})
#     point = gpd.GeoDataFrame(
#         df, geometry=gpd.points_from_xy(df.longitude, df.latitude)
#     )
#     result = gpd.sjoin(point, features, op='within')
#     print(result)
#     return result


# trend (for given location (lon/lat))
# note: the trends could be for both measurement locations and regions (like waterbodies)
# regions
# waterbodies (already in public, make available via 'chemtrend'
