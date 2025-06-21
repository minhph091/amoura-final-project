"""
Configuration management for Amoura AI Service.

This module handles all application configuration including environment variables,
database settings, API keys, and ML model configurations.
"""

import os
from typing import Optional
from pathlib import Path

from pydantic import Field, validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings with validation and environment variable support.
    
    All settings can be overridden using environment variables.
    For example: POSTGRES_SERVER=localhost
    """
    
    # Application metadata
    PROJECT_NAME: str = "Amoura AI Service"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = Field(default=False, description="Enable debug mode")
    
    # Database configuration
    POSTGRES_SERVER: str = Field(default="localhost", description="PostgreSQL server host")
    POSTGRES_USER: str = Field(default="youruser", description="PostgreSQL username")
    POSTGRES_PASSWORD: str = Field(default="yourpassword", description="PostgreSQL password")
    POSTGRES_DB: str = Field(default="amouradb", description="PostgreSQL database name")
    POSTGRES_PORT: str = Field(default="5432", description="PostgreSQL port")
    
    # External API keys
    GEMINI_API_KEY: str = Field(default="", description="Google Gemini API key for message editing")
    
    # ML Model configuration
    MODELS_DIR: str = Field(default="ml_models", description="Directory containing ML models")
    MATCH_PROBABILITY_THRESHOLD: float = Field(
        default=0.5, 
        ge=0.0, 
        le=1.0,
        description="Threshold for considering a match valid (0.0-1.0)"
    )
    
    # NLTK configuration
    NLTK_DATA_DIR: Optional[str] = Field(default=None, description="Custom NLTK data directory")
    
    # Logging configuration
    LOG_LEVEL: str = Field(default="INFO", description="Logging level")
    LOG_FORMAT: str = Field(
        default="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        description="Log format string"
    )
    
    @validator('POSTGRES_PORT')
    def validate_postgres_port(cls, v):
        """Validate PostgreSQL port is a valid port number."""
        try:
            port = int(v)
            if not (1 <= port <= 65535):
                raise ValueError("Port must be between 1 and 65535")
            return v
        except ValueError as e:
            raise ValueError(f"Invalid port number: {e}")
    
    @validator('MATCH_PROBABILITY_THRESHOLD')
    def validate_threshold(cls, v):
        """Validate match probability threshold is within valid range."""
        if not (0.0 <= v <= 1.0):
            raise ValueError("Match probability threshold must be between 0.0 and 1.0")
        return v
    
    @validator('LOG_LEVEL')
    def validate_log_level(cls, v):
        """Validate log level is a valid Python logging level."""
        valid_levels = {'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'}
        if v.upper() not in valid_levels:
            raise ValueError(f"Log level must be one of: {valid_levels}")
        return v.upper()
    
    @property
    def SQLALCHEMY_DATABASE_URL(self) -> str:
        """Generate PostgreSQL connection URL."""
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )
    
    @property
    def models_path(self) -> Path:
        """Get absolute path to models directory."""
        base_dir = Path(__file__).parent.parent.parent
        return base_dir / self.MODELS_DIR
    
    @property
    def is_development(self) -> bool:
        """Check if running in development mode."""
        return self.DEBUG or os.getenv("ENVIRONMENT", "").lower() == "development"
    
    @property
    def is_production(self) -> bool:
        """Check if running in production mode."""
        return os.getenv("ENVIRONMENT", "").lower() == "production"
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


# Global settings instance
settings = Settings()


def get_settings() -> Settings:
    """Dependency function to get settings instance."""
    return settings