from fastapi import FastAPI
from fastapi import status
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from typing import List

# from database import engine, SessionLocal
import sqlalchemy
import databases
from chemtrend.models import Substance

# from sqlalchemy import create_engine, text, MetaData
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from pydantic import PostgresDsn

import psycopg2

app = FastAPI()


# async def setup_connection(connection):
#     """Enable hstore extension."""
#     await connection.set_builtin_type_codec("hstore", codec_name="pg_contrib.hstore")
async def setup_connection(database):
    await database.connect()


DATABASE_URL = "postgresql://USER:PASSWORD:5432/waterkwaliteit"

database = databases.Database(DATABASE_URL)
engine = sqlalchemy.create_engine(DATABASE_URL)
setup_connection(database)


metadata = sqlalchemy.MetaData()
metadata.reflect(views=True, bind=engine, schema="chemtrend")

substances = metadata.tables["chemtrend.substance"]


@app.get("/")
async def root():
    return {"message": "Hello World"}


# @app.get("/db")
# async def check_db():
#     mydb = get_db()
#     return {"message": "db = ok"}


# @app.get("/substances/")
@app.get("/substances/", response_model=List[Substance], tags=["substances"])
async def list_substances():
    # mydb = get_db()
    # query = text("""select * from chemtrend.substance;""")
    # query = "select * from chemtrend.substance;"
    # query = substances.select()
    # conn = engine.connect()
    # result = database.execute(query)
    # print(result)
    # result = conn.execute(query)
    # result = exe.fetchone()
    # conn.close()
    # print(result)
    # return result
    # return JSONResponse(content=jsonable_encoder(result))
    # return await database.fetch_all(query)
    query = substances.select()
    await database.connect()
    # result = database.fetch_one(query)
    return await database.fetch_all(query)
    # return result


# def get_db():
#     try:
#         db = SessionLocal()
#         yield db
#         print("yeah!")
#     finally:
#         db.close()
