# app/api/v1/endpoints/matches.py
"""
Match-related API endpoints for Amoura AI Service.

Provides a single comprehensive matching endpoint (ML + rules + fallback).
"""

from fastapi import APIRouter, HTTPException, status, Query, Path

from app import schemas
from app.core.logging import get_logger
from app.dependencies import MatchServiceDep

logger = get_logger(__name__)

router = APIRouter()


@router.get(
    "/users/{user_id}/matches",
    response_model=schemas.match.PotentialMatchResponse,
    summary="Get Comprehensive Matches for a User",
    description="""
    Returns a list of user IDs that the caller can swipe on, using a 3-tier cascade:

    1) Machine Learning predictions (Logistic Regression) on user features
    2) Gender/orientation compatibility filtering (business rules)
    3) Random users (final fallback)

    Rules: exclude already-swiped users and the current user; only include active users with role 'USER'.
    Target: returns up to 20 users (or fewer if data is limited).
    """,
    responses={
        200: {
            "description": "Successfully retrieved comprehensive matches",
            "content": {
                "application/json": {
                    "example": {
                        "user_id": 123,
                        "potential_match_ids": [456, 789, 101]
                    }
                }
            }
        },
        400: {"description": "Invalid user ID or request parameters"},
        404: {"description": "User not found or profile incomplete"},
        500: {"description": "Internal server error"}
    }
)
async def get_comprehensive_matches_for_user(
    match_service: MatchServiceDep,
    user_id: int = Path(..., gt=0, description="ID of the user to find matches for"),
    limit: int = Query(20, ge=1, le=50, description="Maximum number of matches to return (default: 20)")
):
    """
    Tìm comprehensive matches cho user với cascade logic.
    
    API này sử dụng 3-tier system để đảm bảo luôn có đủ matches:
    1. **ML Predictions** (primary)
    2. **Gender/Orientation filtering** (secondary)  
    3. **Random selection** (fallback)
    
    Args:
        user_id: ID của user cần tìm matches (phải > 0)
        limit: Số lượng matches tối đa (1-50, default: 20)
        match_service: Injected match service dependency
        
    Returns:
        PotentialMatchResponse với user ID và list of potential match IDs
        
    Raises:
        HTTPException: Nếu user không tồn tại, role không hợp lệ, hoặc lỗi khác
        
    Example:
        GET /api/v1/users/123/matches?limit=20
        
        Response:
        {
            "user_id": 123,
            "potential_match_ids": [456, 789, 101, ...]  // Up to 20 IDs
        }
    """
    logger.info(f"Getting comprehensive matches for user {user_id} with limit {limit}")
    
    try:
        potential_matches_ids = match_service.get_comprehensive_matches(
            current_user_id=user_id,
            limit=limit
        )
        
        logger.info(f"Found {len(potential_matches_ids)} comprehensive matches for user {user_id}")
        
        return schemas.match.PotentialMatchResponse(
            user_id=user_id,
            potential_match_ids=potential_matches_ids
        )
        
    except HTTPException:
        # Re-raise HTTP exceptions as they are
        raise
    except Exception as e:
        logger.error(f"Unexpected error getting comprehensive matches for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An unexpected error occurred while processing matches for user {user_id}."
        )

 