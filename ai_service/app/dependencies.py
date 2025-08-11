"""
Dependency injection for Amoura AI Service.

This module provides FastAPI dependencies for database sessions,
services, and other shared resources with proper error handling.
"""

from typing import Annotated
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.exceptions import ModelLoadError
from app.core.logging import get_logger
from app.db.session import get_db
from app.services.match_service import MatchService
from app.services.message_service import MessageService
from app.ml.predictor import MatchPredictor

logger = get_logger(__name__)


def get_match_predictor() -> MatchPredictor:
    """
    Dependency to get MatchPredictor instance.
    
    Returns:
        MatchPredictor instance
        
    Raises:
        HTTPException: If model loading fails
    """
    try:
        settings = get_settings()
        predictor = MatchPredictor(models_dir=str(settings.models_path))
        logger.info("MatchPredictor initialized successfully")
        return predictor
    except FileNotFoundError as e:
        logger.error(f"Model files not found: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "message": "ML models are not available",
                "error_code": "MODEL_LOAD_ERROR",
                "details": {"original_error": str(e)}
            }
        )
    except Exception as e:
        logger.error(f"Failed to initialize MatchPredictor: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "message": "Failed to initialize ML service",
                "error_code": "INITIALIZATION_ERROR",
                "details": {"original_error": str(e)}
            }
        )


def get_match_service(
    db: Annotated[Session, Depends(get_db)],
    predictor: Annotated[MatchPredictor, Depends(get_match_predictor)]
) -> MatchService:
    """
    Dependency to get MatchService instance.
    
    Args:
        db: Database session
        predictor: MatchPredictor instance
        
    Returns:
        MatchService instance
    """
    return MatchService(db=db, predictor=predictor)


def get_message_service(
    db: Annotated[Session, Depends(get_db)]
) -> MessageService:
    """
    Dependency to get MessageService instance.
    
    Args:
        db: Database session
        
    Returns:
        MessageService instance
        
    Raises:
        HTTPException: If Gemini API key is not configured
    """
    settings = get_settings()
    
    if not settings.GEMINI_API_KEY:
        logger.error("Gemini API key not configured")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "message": "Message editing service is not available",
                "error_code": "CONFIGURATION_ERROR",
                "details": {"reason": "Gemini API key not configured"}
            }
        )
    
    return MessageService(db=db)


# Type aliases for cleaner dependency injection
DatabaseSession = Annotated[Session, Depends(get_db)]
MatchPredictorDep = Annotated[MatchPredictor, Depends(get_match_predictor)]
MatchServiceDep = Annotated[MatchService, Depends(get_match_service)]
MessageServiceDep = Annotated[MessageService, Depends(get_message_service)]