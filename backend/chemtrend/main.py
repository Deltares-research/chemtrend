from typing import List
from fastapi import FastAPI
from chemtrend.models import Substance
from chemtrend.database import metadata, database

app = FastAPI()

substances = metadata.tables["chemtrend.substance"]


@app.get("/substances/", response_model=List[Substance], tags=["substances"])
async def list_substances():
    query = substances.select()
    await database.connect()
    return await database.fetch_all(query)
