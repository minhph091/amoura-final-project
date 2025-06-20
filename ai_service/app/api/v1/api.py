# app/api/v1/api.py
from fastapi import APIRouter

from ai_service.app.api.v1.endpoints import matches
# from app.api.v1.endpoints import users # Ví dụ nếu có thêm endpoint cho user

api_router_v1 = APIRouter()

# Chỉ include router matches MỘT LẦN.
# Prefix "/users" sẽ được thêm ở tầng app chính (main.py) khi include api_router_v1
# Hoặc bạn có thể định nghĩa prefix="/users" ngay trong matches.router
# Cách 1: Giữ matches.router không có prefix, prefix sẽ do router cha quản lý
# api_router_v1.include_router(matches.router) # Tag đã được định nghĩa trong matches.router là "matches"

# Cách 2: Nếu bạn muốn endpoint là /api/v1/users/... thì prefix "/users"
# nên được đặt khi include router này ở app/main.py hoặc trong chính matches.router.
# Để rõ ràng, ta sẽ bỏ prefix ở đây và quản lý ở main.py.
# Tag "Match Predictions" sẽ được sử dụng từ matches.router.
api_router_v1.include_router(matches.router, tags=["Match Predictions"]) # Giả sử tag đã được đặt trong matches.router

# Hoặc nếu muốn ghi đè/thêm tag ở đây:
# api_router_v1.include_router(matches.router, tags=["Match Predictions"])

# api_router_v1.include_router(users.router, prefix="/users", tags=["users"]) # Ví dụ