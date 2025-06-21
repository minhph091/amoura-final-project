"""
Custom exceptions for Amoura AI Service.

This module defines application-specific exceptions and error handling
utilities for better error management and debugging.
"""

from typing import Any, Dict, Optional
from fastapi import HTTPException, status


class AmouraAIException(Exception):
    """Base exception for Amoura AI Service."""
    
    def __init__(
        self,
        message: str,
        error_code: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.error_code = error_code
        self.details = details or {}
        super().__init__(self.message)


class ModelLoadError(AmouraAIException):
    """Raised when ML model fails to load."""
    
    def __init__(self, model_name: str, error: str):
        super().__init__(
            message=f"Failed to load ML model '{model_name}': {error}",
            error_code="MODEL_LOAD_ERROR",
            details={"model_name": model_name, "original_error": error}
        )


class PredictionError(AmouraAIException):
    """Raised when ML prediction fails."""
    
    def __init__(self, operation: str, error: str):
        super().__init__(
            message=f"Prediction failed for operation '{operation}': {error}",
            error_code="PREDICTION_ERROR",
            details={"operation": operation, "original_error": error}
        )


class DataValidationError(AmouraAIException):
    """Raised when input data validation fails."""
    
    def __init__(self, field: str, value: Any, reason: str):
        super().__init__(
            message=f"Data validation failed for field '{field}': {reason}",
            error_code="DATA_VALIDATION_ERROR",
            details={"field": field, "value": value, "reason": reason}
        )


class ExternalAPIError(AmouraAIException):
    """Raised when external API calls fail."""
    
    def __init__(self, api_name: str, error: str, status_code: Optional[int] = None):
        super().__init__(
            message=f"External API '{api_name}' call failed: {error}",
            error_code="EXTERNAL_API_ERROR",
            details={"api_name": api_name, "original_error": error, "status_code": status_code}
        )


class DatabaseError(AmouraAIException):
    """Raised when database operations fail."""
    
    def __init__(self, operation: str, error: str):
        super().__init__(
            message=f"Database operation '{operation}' failed: {error}",
            error_code="DATABASE_ERROR",
            details={"operation": operation, "original_error": error}
        )


class ConfigurationError(AmouraAIException):
    """Raised when configuration is invalid or missing."""
    
    def __init__(self, config_key: str, reason: str):
        super().__init__(
            message=f"Configuration error for '{config_key}': {reason}",
            error_code="CONFIGURATION_ERROR",
            details={"config_key": config_key, "reason": reason}
        )


def convert_to_http_exception(exception: AmouraAIException) -> HTTPException:
    """
    Convert AmouraAIException to FastAPI HTTPException.
    
    Args:
        exception: AmouraAIException instance
    
    Returns:
        HTTPException with appropriate status code and detail
    """
    # Map error codes to HTTP status codes
    error_code_mapping = {
        "MODEL_LOAD_ERROR": status.HTTP_503_SERVICE_UNAVAILABLE,
        "PREDICTION_ERROR": status.HTTP_500_INTERNAL_SERVER_ERROR,
        "DATA_VALIDATION_ERROR": status.HTTP_400_BAD_REQUEST,
        "EXTERNAL_API_ERROR": status.HTTP_502_BAD_GATEWAY,
        "DATABASE_ERROR": status.HTTP_500_INTERNAL_SERVER_ERROR,
        "CONFIGURATION_ERROR": status.HTTP_500_INTERNAL_SERVER_ERROR,
    }
    
    status_code = error_code_mapping.get(
        exception.error_code, 
        status.HTTP_500_INTERNAL_SERVER_ERROR
    )
    
    return HTTPException(
        status_code=status_code,
        detail={
            "message": exception.message,
            "error_code": exception.error_code,
            "details": exception.details
        }
    )


def handle_exception(exception: Exception) -> HTTPException:
    """
    Generic exception handler that converts any exception to HTTPException.
    
    Args:
        exception: Any exception instance
    
    Returns:
        HTTPException with appropriate status code and detail
    """
    if isinstance(exception, AmouraAIException):
        return convert_to_http_exception(exception)
    
    # Handle other common exceptions
    if isinstance(exception, ValueError):
        return HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"message": str(exception), "error_code": "VALUE_ERROR"}
        )
    
    if isinstance(exception, FileNotFoundError):
        return HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"message": str(exception), "error_code": "FILE_NOT_FOUND"}
        )
    
    # Default case
    return HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail={
            "message": "An unexpected error occurred",
            "error_code": "INTERNAL_SERVER_ERROR",
            "details": {"original_error": str(exception)}
        }
    ) 