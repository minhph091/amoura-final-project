# app/core/config.py
from pydantic_settings import BaseSettings
import os
from dotenv import load_dotenv

# Tải các biến môi trường từ file .env (nếu có)
# Điều này hữu ích cho việc phát triển cục bộ
env_path = os.path.join(os.path.dirname(__file__), "..", "..", ".env")
load_dotenv(dotenv_path=env_path)

class Settings(BaseSettings):
    PROJECT_NAME: str = "Amoura AI Service"
    API_V1_STR: str = "/api/v1"

    # Database settings
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "youruser")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "yourpassword")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "amouradb")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432") # Port mặc định của Postgres

    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")

    @property
    def SQLALCHEMY_DATABASE_URL(self) -> str:
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    # ML Model paths (nếu cần thiết, nhưng hiện tại chúng ta đang dùng đường dẫn tương đối trong ml modules)
    # MODELS_DIR: str = os.getenv("MODELS_DIR", "ml_models")

    # Ngưỡng xác suất để coi là match
    MATCH_PROBABILITY_THRESHOLD: float = float(os.getenv("MATCH_PROBABILITY_THRESHOLD", 0.5))

    class Config:
        case_sensitive = True
        # env_file = ".env" # Nếu bạn muốn pydantic-settings tự động tải từ .env

settings = Settings()