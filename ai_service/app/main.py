"""
Main FastAPI application for Amoura AI Service.

This module initializes the FastAPI application with proper configuration,
middleware, and lifecycle management.
"""

import nltk
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time

from app.core.config import get_settings
from app.core.logging import setup_logging, get_logger
from app.core.exceptions import AmouraAIException, handle_exception
from app.api.v1.api import api_router_v1


# Setup logging
logger = get_logger(__name__)


def download_nltk_data():
    """Download required NLTK data for text processing."""
    try:
        # Check and download required NLTK data
        required_data = ['punkt', 'stopwords', 'wordnet']
        
        for data_name in required_data:
            try:
                nltk.data.find(f'tokenizers/{data_name}' if data_name == 'punkt' else f'corpora/{data_name}')
                logger.debug(f"NLTK data '{data_name}' already available")
            except LookupError:
                logger.info(f"Downloading NLTK data: {data_name}")
                nltk.download(data_name, quiet=True)
                logger.info(f"NLTK data '{data_name}' downloaded successfully")
        
        logger.info("All required NLTK data verified/downloaded")
    except Exception as e:
        logger.error(f"Failed to download NLTK data: {e}")
        raise


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager for startup and shutdown events.
    
    Handles:
    - NLTK data download
    - Service initialization
    - Cleanup on shutdown
    """
    # Startup
    logger.info("Starting Amoura AI Service...")
    
    try:
        # Download NLTK data
        download_nltk_data()
        
        # Log configuration
        settings = get_settings()
        logger.info(f"Match probability threshold: {settings.MATCH_PROBABILITY_THRESHOLD}")
        logger.info(f"Environment: {'Development' if settings.is_development else 'Production'}")
        
        logger.info("Amoura AI Service started successfully")
        
    except Exception as e:
        logger.error(f"Failed to start application: {e}")
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down Amoura AI Service...")


def create_app() -> FastAPI:
    """
    Create and configure the FastAPI application.
    
    Returns:
        Configured FastAPI application instance
    """
    settings = get_settings()
    
    # Create FastAPI app
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description="AI-powered features for Amoura dating application",
        openapi_url=f"{settings.API_V1_STR}/openapi.json",
        docs_url="/docs" if settings.is_development else None,
        redoc_url="/redoc" if settings.is_development else None,
        lifespan=lifespan
    )
    
    # Add CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Configure appropriately for production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Add request timing middleware
    @app.middleware("http")
    async def add_process_time_header(request: Request, call_next):
        start_time = time.time()
        response = await call_next(request)
        process_time = time.time() - start_time
        response.headers["X-Process-Time"] = str(process_time)
        return response
    
    # Add exception handlers
    @app.exception_handler(AmouraAIException)
    async def amoura_exception_handler(request: Request, exc: AmouraAIException):
        logger.error(f"AmouraAIException: {exc.message}", extra=exc.details)
        return JSONResponse(
            status_code=500,
            content={
                "message": exc.message,
                "error_code": exc.error_code,
                "details": exc.details
            }
        )
    
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        logger.error(f"Unhandled exception: {exc}", exc_info=True)
        http_exc = handle_exception(exc)
        return JSONResponse(
            status_code=http_exc.status_code,
            content=http_exc.detail
        )
    
    # Include API routers
    app.include_router(api_router_v1, prefix=settings.API_V1_STR)
    
    return app


# Create app instance
app = create_app()


@app.get("/", tags=["Root"])
async def read_root():
    """Health check endpoint."""
    return {
        "message": f"Welcome to {get_settings().PROJECT_NAME}!",
        "version": get_settings().VERSION,
        "status": "healthy"
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Detailed health check endpoint."""
    settings = get_settings()
    
    health_status = {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": "development" if settings.is_development else "production",
        "timestamp": time.time()
    }
    
    return health_status


if __name__ == "__main__":
    import uvicorn
    
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.is_development,
        log_level=settings.LOG_LEVEL.lower()
    )