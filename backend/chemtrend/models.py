from typing import Any, Dict, List, Optional, Type
from pydantic import BaseModel


class Substance(BaseModel):
    substance_id: int
    substance_code: str
    substance_description: str
    cas: str

class Period(BaseModel):
    trend_period: int
    trend_period_description: str

# class Location(BaseModel):
#     location_code: str
#     geom: Json
