"""
Pydantic schemas for match-related API responses.

This module defines the data models used for match-related API endpoints,
ensuring proper validation and documentation of request/response structures.
"""

from pydantic import BaseModel, Field
from typing import List


class PotentialMatchResponse(BaseModel):
    """
    Response model for potential matches endpoint.
    
    This schema defines the structure of the response returned by the
    potential matches API endpoint, containing the user ID and a list
    of potential match user IDs identified by the AI matching algorithm.
    
    Attributes:
        user_id: The ID of the user for whom potential matches were found
        potential_match_ids: List of user IDs that are potential matches
        
    Example:
        {
            "user_id": 1,
            "potential_match_ids": [2, 3, 5, 8, 12]
        }
    """
    user_id: int = Field(
        ..., 
        description="ID of the user for whom matches were found",
        gt=0
    )
    potential_match_ids: List[int] = Field(
        ..., 
        description="List of potential match user IDs identified by AI algorithm"
    )
    
    class Config:
        """Pydantic configuration for the schema."""
        json_schema_extra = {
            "example": {
                "user_id": 1,
                "potential_match_ids": [2, 3, 5, 8, 12]
            }
        }


 