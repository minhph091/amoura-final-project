# app/schemas/match.py
from pydantic import BaseModel
from typing import List

# Hiện tại API chỉ nhận user_id, không cần request body phức tạp
# class MatchPredictionRequest(BaseModel):
#     user1_id: int
# user2_id: int # Hoặc list user_ids để check

class PotentialMatchResponse(BaseModel):
    user_id: int
    potential_match_ids: List[int]