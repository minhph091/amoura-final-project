"""
Logging configuration for Amoura AI Service.

This module provides structured logging with proper formatting,
log levels, and output handlers for different environments.
"""

import logging
import sys
from pathlib import Path
from typing import Optional

from app.core.config import get_settings


def setup_logging(
    log_level: Optional[str] = None,
    log_file: Optional[Path] = None,
    enable_console: bool = True
) -> logging.Logger:
    """
    Setup application logging with proper configuration.
    
    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Optional file path for logging output
        enable_console: Whether to enable console logging
    
    Returns:
        Configured logger instance
    """
    settings = get_settings()
    
    # Use provided log_level or default from settings
    level = log_level or settings.LOG_LEVEL
    log_level_num = getattr(logging, level.upper())
    
    # Create logger
    logger = logging.getLogger("amoura_ai_service")
    logger.setLevel(log_level_num)
    
    # Clear existing handlers to avoid duplicates
    logger.handlers.clear()
    
    # Create formatter
    formatter = logging.Formatter(settings.LOG_FORMAT)
    
    # Console handler
    if enable_console:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(log_level_num)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
    
    # File handler (if specified)
    if log_file:
        # Ensure log directory exists
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(log_level_num)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    # Prevent propagation to root logger
    logger.propagate = False
    
    return logger


def get_logger(name: str = "amoura_ai_service") -> logging.Logger:
    """
    Get a logger instance with the specified name.
    
    Args:
        name: Logger name (usually module name)
    
    Returns:
        Logger instance
    """
    return logging.getLogger(name)


# Create default logger
logger = get_logger()


class LoggerMixin:
    """Mixin class to add logging capabilities to any class."""
    
    @property
    def logger(self) -> logging.Logger:
        """Get logger for this class."""
        return get_logger(f"{self.__class__.__module__}.{self.__class__.__name__}")


def log_function_call(func):
    """
    Decorator to log function calls with parameters and execution time.
    
    Usage:
        @log_function_call
        def my_function(param1, param2):
            return result
    """
    def wrapper(*args, **kwargs):
        func_logger = get_logger(f"{func.__module__}.{func.__name__}")
        
        # Log function call
        func_logger.debug(
            f"Calling {func.__name__} with args={args}, kwargs={kwargs}"
        )
        
        try:
            result = func(*args, **kwargs)
            func_logger.debug(f"{func.__name__} completed successfully")
            return result
        except Exception as e:
            func_logger.error(f"{func.__name__} failed with error: {e}")
            raise
    
    return wrapper 