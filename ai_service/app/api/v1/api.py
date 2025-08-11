# app/api/v1/api.py
from fastapi import APIRouter

from app.api.v1.endpoints import matches, messages

api_router_v1 = APIRouter()

api_router_v1.include_router(matches.router, tags=["Match Predictions"])
api_router_v1.include_router(messages.router, tags=["Message Editing"])