# app/schemas/match.py
from pydantic import BaseModel, Field
from typing import List

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