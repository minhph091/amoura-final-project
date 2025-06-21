# app/schemas/match.py
from pydantic import BaseModel, Field
from typing import List

# Hiện tại API chỉ nhận user_id, không cần request body phức tạp
# class MatchPredictionRequest(BaseModel):
#     user1_id: int
# user2_id: int # Hoặc list user_ids để check

class PotentialMatchResponse(BaseModel):
    """
    Response model for potential matches endpoint.
    
    Contains the user ID and a list of potential match user IDs.
    """
    user_id: int = Field(..., description="ID of the user for whom matches were found")
    potential_match_ids: List[int] = Field(..., description="List of potential match user IDs")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": 1,
                "potential_match_ids": [2, 3, 5, 8, 12]
            }
        }


class MatchProbabilityResponse(BaseModel):
    """
    Response model for match probability endpoint.
    
    Contains match probability between two users and whether they are considered a match.
    """
    user1_id: int = Field(..., description="ID of the first user")
    user2_id: int = Field(..., description="ID of the second user")
    match_probability: float = Field(..., ge=0.0, le=1.0, description="Match probability between 0.0 and 1.0")
    is_match: bool = Field(..., description="Whether the users are considered a match based on threshold")
    threshold: float = Field(..., ge=0.0, le=1.0, description="Threshold used to determine if it's a match")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user1_id": 1,
                "user2_id": 2,
                "match_probability": 0.85,
                "is_match": True,
                "threshold": 0.5
            }
        }


class MatchRequest(BaseModel):
    """
    Request model for match-related operations.
    
    Currently not used but available for future endpoints that might need request bodies.
    """
    user1_id: int = Field(..., gt=0, description="ID of the first user")
    user2_id: int = Field(..., gt=0, description="ID of the second user")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user1_id": 1,
                "user2_id": 2
            }
        }