import databases
import sqlalchemy

DATABASE_URL = "postgresql://USER:PASSWORD@c-oet10550:5432/waterkwaliteit"


async def setup_connection(database):
    await database.connect()


database = databases.Database(DATABASE_URL)
engine = sqlalchemy.create_engine(DATABASE_URL)
setup_connection(database)

metadata = sqlalchemy.MetaData()
metadata.reflect(views=True, bind=engine, schema="chemtrend")
