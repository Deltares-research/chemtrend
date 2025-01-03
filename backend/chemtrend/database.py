import databases
import sqlalchemy
import configparser as confpars
from geoalchemy2 import Geometry
# import asyncio

confpars = confpars.RawConfigParser()
configFilePath = r"config.txt"
confpars.read_file(open(configFilePath))

DATABASE_URL = confpars.get("database", "DATABASE_URL")


async def setup_connection(database):
    await database.connect()


database = databases.Database(DATABASE_URL)
engine = sqlalchemy.create_engine(DATABASE_URL)
# asyncio.run(setup_connection(database))
setup_connection(database)

metadata = sqlalchemy.MetaData()
metadata.reflect(views=True, bind=engine, schema="chemtrend")
