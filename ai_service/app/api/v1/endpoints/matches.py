# app/api/v1/endpoints/matches.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Annotated # Annotated cho FastAPI 0.95+

from app import schemas
from app.services.match_service import MatchService
from app.ml.predictor import MatchPredictor
from app.db.session import get_db
from app.core.config import settings

router = APIRouter()

# --- Khởi tạo MatchPredictor ---
# Cách 1: Khởi tạo global (đơn giản cho ví dụ này, model tải 1 lần khi module import)
# Trong production, bạn có thể muốn quản lý instance này tốt hơn, ví dụ qua lifespan events
# hoặc một dependency phức tạp hơn nếu việc khởi tạo tốn nhiều tài nguyên.
try:
    match_predictor_instance = MatchPredictor()
    print("INFO: MatchPredictor initialized successfully.")
except FileNotFoundError as fnf_error:
    print(f"CRITICAL: FileNotFoundError during MatchPredictor initialization - {fnf_error}. Check model paths and file existence.")
    match_predictor_instance = None # Đảm bảo nó là None để get_match_service bắt được
except Exception as e:
    print(f"CRITICAL: Failed to initialize MatchPredictor due to an unexpected error: {e}")
    import traceback
    traceback.print_exc() # In chi tiết traceback để debug
    match_predictor_instance = None


# --- Dependency để lấy MatchService ---
def get_match_service(
    db: Annotated[Session, Depends(get_db)], # Python 3.9+
    # db: Session = Depends(get_db) # Python < 3.9
) -> MatchService:
    if not match_predictor_instance:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Match prediction service is not available due to model loading issues."
        )
    return MatchService(db=db, predictor=match_predictor_instance)


@router.get(
    # Path này sẽ được nối với prefix của router (nếu có) và prefix của router cha
    # Để đạt /users/{user_id}/potential-matches, và router này không có prefix
    # thì router cha (api_router_v1) cần được include với prefix /users
    # HOẶC path ở đây phải là "/users/{user_id}/potential-matches"
    "/users/{user_id}/potential-matches", # Giữ path đầy đủ ở đây cho đơn giản
    response_model=schemas.match.PotentialMatchResponse,
    summary="Get Potential Matches for a User",
    description="""
    Retrieves a list of user IDs that are potential matches for the given user_id.
    The user specified by `user_id` must have the 'USER' role.
    The matching is determined by the underlying AI/ML model.
    """
    # tags đã được định nghĩa khi tạo APIRouter ở trên
)
async def get_potential_matches_for_user(
    user_id: int,
    # match_service: MatchService = Depends(get_match_service) # Python < 3.9
    match_service: Annotated[MatchService, Depends(get_match_service)] # Python 3.9+
):
    """
    Endpoint to get potential matches for a specific user.
    - **user_id**: The ID of the user for whom to find matches.
    """
    if user_id <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User ID must be a positive integer.")

    try:
        potential_matches_ids = match_service.get_potential_matches(current_user_id=user_id)
        return schemas.match.PotentialMatchResponse(
            user_id=user_id,
            potential_match_ids=potential_matches_ids
        )
    except HTTPException as http_exc: # Bắt lại HTTPException từ service để trả về đúng status
        raise http_exc
    except FileNotFoundError as e: # Ví dụ lỗi nếu file model/preprocessor không tìm thấy
        print(f"Error during prediction for user {user_id}: {e}")
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="A required ML model file was not found.")
    except Exception as e:
        # Log lỗi chi tiết ở server
        print(f"Unexpected error getting potential matches for user {user_id}: {e}") # Nên dùng logger
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An unexpected error occurred while processing matches for user {user_id}."
        )