# app/api/v1/endpoints/matches.py
"""
Match-related API endpoints for Amoura AI Service.

This module provides endpoints for user matching functionality including
potential match discovery.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query, Path
from typing import Annotated

from app import schemas
from app.core.logging import get_logger
from app.dependencies import MatchServiceDep

logger = get_logger(__name__)

router = APIRouter()


@router.get(
    "/users/{user_id}/potential-matches",
    response_model=schemas.match.PotentialMatchResponse,
    summary="Get Potential Matches for a User",
    description="""
    Retrieves a list of user IDs that are potential matches for the given user_id.
    
    The matching algorithm considers:
    - User role validation (must have 'USER' role)
    - Orientation compatibility
    - ML model predictions based on user profiles
    - Match probability threshold
    
    Only returns users that the current user hasn't swiped on yet.
    """,
    responses={
        200: {
            "description": "Successfully retrieved potential matches",
            "content": {
                "application/json": {
                    "example": {
                        "user_id": 1,
                        "potential_match_ids": [2, 3, 5, 8, 12]
                    }
                }
            }
        },
        400: {
            "description": "Invalid user ID provided"
        },
        403: {
            "description": "User does not have 'USER' role"
        },
        404: {
            "description": "User not found or profile incomplete"
        },
        500: {
            "description": "Internal server error"
        }
    }
)
async def get_potential_matches_for_user(
    match_service: MatchServiceDep,
    user_id: int = Path(..., gt=0, description="ID of the user to find matches for"),
    limit: int = Query(10, ge=1, le=50, description="Maximum number of matches to return")
):
    """
    Get potential matches for a specific user.
    
    This endpoint uses AI/ML models to predict compatibility between users
    and returns a list of user IDs that are likely to be good matches.
    
    Args:
        user_id: The ID of the user for whom to find matches (must be positive)
        limit: Maximum number of matches to return (1-50, default: 10)
        match_service: Injected match service dependency
        
    Returns:
        PotentialMatchResponse containing the user ID and list of potential match IDs
        
    Raises:
        HTTPException: If user not found, invalid role, or other errors
    """
    logger.info(f"Getting potential matches for user {user_id} with limit {limit}")
    
    try:
        potential_matches_ids = match_service.get_potential_matches(
            current_user_id=user_id,
            limit=limit
        )
        
        logger.info(f"Found {len(potential_matches_ids)} potential matches for user {user_id}")
        
        return schemas.match.PotentialMatchResponse(
            user_id=user_id,
            potential_match_ids=potential_matches_ids
        )
        
    except HTTPException:
        # Re-raise HTTP exceptions as they are
        raise
    except Exception as e:
        logger.error(f"Unexpected error getting potential matches for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An unexpected error occurred while processing matches for user {user_id}."
        )