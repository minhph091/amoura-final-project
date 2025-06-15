# app/main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager
import nltk  # Để tải dữ liệu NLTK

from app.api.v1.api import api_router_v1
from app.core.config import settings
from app.db.session import engine  # Để tạo bảng (nếu cần, nhưng Alembic tốt hơn)
from app.db import base  # Import base để Base.metadata biết về các models


# --- NLTK Data Download ---
# Hàm này nên được gọi một lần. Trong production, nó có thể nằm trong Dockerfile
# hoặc một script setup riêng.

def download_nltk_data():
    try:
        nltk.data.find('tokenizers/punkt')
    except LookupError:
        nltk.download('punkt', quiet=True)

    try:
        nltk.data.find('corpora/stopwords')
    except LookupError:
        nltk.download('stopwords', quiet=True)

    try:
        nltk.data.find('corpora/wordnet')
    except LookupError:
        nltk.download('wordnet', quiet=True)

    print("NLTK data checked/downloaded.")

# --- Lifespan Events (cho FastAPI 0.90+) ---
# Dùng để thực hiện các tác vụ khi khởi động và tắt ứng dụng
# Ví dụ: tải model ML, kết nối DB, tải dữ liệu NLTK

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Code to run on app startup
    print("Application startup...")
    download_nltk_data()
    # base.Base.metadata.create_all(bind=engine) # Tạo bảng nếu chưa có, Alembic tốt hơn cho production

    # Khởi tạo MatchPredictor ở đây nếu muốn quản lý tập trung
    # app.state.match_predictor = MatchPredictor()
    # sau đó trong dependency get_match_service, bạn có thể lấy từ request.app.state.match_predictor
    # Hiện tại, MatchPredictor đang được khởi tạo ở global scope của matches.py

    print(f"Match probability threshold set to: {settings.MATCH_PROBABILITY_THRESHOLD}")
    yield
    # Code to run on app shutdown
    print("Application shutdown...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan
)

# Include router API v1 với prefix chung là /api/v1
# Router con matches.router đã có path đầy đủ "/users/{user_id}/potential-matches"
app.include_router(api_router_v1, prefix=settings.API_V1_STR)

@app.get("/", tags=["Root"])
async def read_root():
    return {"message": f"Welcome to {settings.PROJECT_NAME}!"}