# app/services/match_service.py
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi import HTTPException

from ai_service.app.db import crud, models
from ai_service.app.ml.predictor import MatchPredictor
from ai_service.app.core.config import settings
from ai_service.app.ml.preprocessing import orientation_compatibility  # Import trực tiếp để sử dụng


class MatchService:
    def __init__(self, db: Session, predictor: MatchPredictor):
        self.db = db
        self.predictor = predictor
        self.match_threshold = settings.MATCH_PROBABILITY_THRESHOLD

    def get_potential_matches(self, current_user_id: int) -> List[int]:
        current_user_data_tuple = crud.get_user_profile_raw_data(self.db, current_user_id)
        if not current_user_data_tuple or not current_user_data_tuple[0]:
            raise HTTPException(status_code=404,
                                detail=f"User with id {current_user_id} not found or profile incomplete.")

        current_user_role = crud.get_user_role_name(self.db, current_user_id)
        if current_user_role != "USER":
            raise HTTPException(status_code=403, detail=f"User with id {current_user_id} does not have 'USER' role.")

        other_user_ids = crud.get_all_other_user_ids_with_role(self.db, current_user_id, role_name="USER")
        if not other_user_ids:
            return []

        potential_matches_ids: List[int] = []

        # Lấy dữ liệu thô của current_user một lần để truyền vào hàm check orientation
        # và sau đó là predictor
        # current_user_raw_for_ml = self.predictor._transform_raw_user_data_to_ml_input(*current_user_data_tuple)
        # Đoạn trên không cần thiết nếu tuple đã đúng định dạng, nhưng cần sex và orientation name

        current_user_sex = current_user_data_tuple[1].sex if current_user_data_tuple[1] else None
        current_user_orientation_name = current_user_data_tuple[7]  # Lấy từ tuple

        for other_user_id in other_user_ids:
            other_user_data_tuple = crud.get_user_profile_raw_data(self.db, other_user_id)
            if not other_user_data_tuple or not other_user_data_tuple[0]:
                print(f"Skipping user id {other_user_id} due to missing data.")
                continue

            other_user_sex = other_user_data_tuple[1].sex if other_user_data_tuple[1] else None
            other_user_orientation_name = other_user_data_tuple[7]  # Lấy từ tuple

            # **Kiểm tra orientation compatibility trước**
            if not orientation_compatibility(
                    current_user_sex, current_user_orientation_name,
                    other_user_sex, other_user_orientation_name
            ):
                # print(f"Pair ({current_user_id}, {other_user_id}) not compatible by orientation. Skipping ML prediction.")
                continue  # Bỏ qua nếu không tương thích

            try:
                match_proba = self.predictor.predict_match_proba(
                    user1_data_tuple=current_user_data_tuple,
                    user2_data_tuple=other_user_data_tuple
                )
                if match_proba > self.match_threshold:
                    potential_matches_ids.append(other_user_id)

            except Exception as e:
                print(f"Error predicting match for pair ({current_user_id}, {other_user_id}): {e}")
                continue

        return potential_matches_ids