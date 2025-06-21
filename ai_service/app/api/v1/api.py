# app/api/v1/api.py
from fastapi import APIRouter

from app.api.v1.endpoints import matches, messages
# from app.api.v1.endpoints import users # Ví dụ nếu có thêm endpoint cho user

api_router_v1 = APIRouter()

api_router_v1.include_router(matches.router, tags=["Match Predictions"])
api_router_v1.include_router(messages.router, tags=["Message Editing"])

# Hoặc nếu muốn ghi đè/thêm tag ở đây:
# api_router_v1.include_router(matches.router, tags=["Match Predictions"])

# api_router_v1.include_router(users.router, prefix="/users", tags=["users"]) # Ví dụ