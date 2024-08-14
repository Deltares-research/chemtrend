from typing import List
from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from chemtrend.models import Substance
from chemtrend.database import metadata, database


app = FastAPI()

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

substances = metadata.tables["chemtrend.substance"]

@app.get("/substances/", response_model=List[Substance], tags=["substances"])
async def list_substances():
    query = substances.select()
    await database.connect()
    return await database.fetch_all(query)
