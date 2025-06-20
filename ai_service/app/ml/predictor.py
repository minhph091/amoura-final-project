# app/ml/predictor.py
import joblib
import os
import pandas as pd
import numpy as np
from typing import Dict, Any, Tuple, List

from ai_service.app.ml.preprocessing import (
    create_user_feature_vector,
    create_pairwise_features_vector,
    calculate_age,
    orientation_compatibility # Import thêm hàm này để dùng ở service
)
from sklearn.preprocessing import MinMaxScaler

# --- Constants ---
MODELS_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "ml_models")


class MatchPredictor:
    def __init__(self, models_dir: str = MODELS_DIR):
        self.models_dir = models_dir
        print(f"DEBUG: Attempting to load models from: {self.models_dir}")  # In đường dẫn khi khởi tạo
        try:
            self.model = joblib.load(os.path.join(self.models_dir, "best_overall_model.joblib"))
            self.pairwise_input_columns: List[str] = joblib.load(
                os.path.join(self.models_dir, "pairwise_model_input_columns.joblib"))
            self.user_feature_columns: List[str] = joblib.load(
                os.path.join(self.models_dir, "user_features_final_columns.joblib"))
            self.pairwise_features_scaler: MinMaxScaler = joblib.load(
                os.path.join(self.models_dir, "pairwise_features_scaler.joblib"))
        except FileNotFoundError as e:
            print(f"DEBUG ERROR: File not found during MatchPredictor init: {e}")
            raise e  # Ném lại lỗi để thấy rõ hơn
        except Exception as e:
            print(f"DEBUG ERROR: Generic error during MatchPredictor init: {e}")
            raise e

        # Các preprocessor này có thể không cần tải ở đây nếu create_user_feature_vector đã tự tải
        # Tuy nhiên, để minh bạch, có thể tải ở đây và truyền vào nếu cần.
        # Hiện tại, create_user_feature_vector đang tự tải.
        try:
            self.numerical_pairwise_cols_to_scale: List[str] = joblib.load(
                os.path.join(self.models_dir, "numerical_pairwise_cols_to_scale.joblib"))
        except FileNotFoundError:
            print(
                "WARNING: 'numerical_pairwise_cols_to_scale.joblib' not found. Falling back to a default list or attempting to infer.")
            # Fallback: Đây là danh sách từ cell [16] của notebook phase2
            self.numerical_pairwise_cols_to_scale = [
                'age_diff', 'height_diff', 'geo_distance_km',
                'user1_within_user2_loc_pref', 'user2_within_user1_loc_pref',
                'drink_match', 'smoke_match', 'education_match',
                'interests_jaccard', 'languages_jaccard',
                'user1_wants_learn_lang', 'user2_wants_learn_lang',
                'language_interest_match', 'pets_jaccard',
                'user_features_cosine_sim', 'user_features_mae_diff'
            ]
            # Quan trọng: Loại bỏ các cột boolean khỏi danh sách này nếu chúng không được scale
            boolean_cols_in_pairwise = [
                'orientation_compatible_user1_to_user2',
                'orientation_compatible_user2_to_user1',
                'orientation_compatible_final'
            ]
            self.numerical_pairwise_cols_to_scale = [
                col for col in self.numerical_pairwise_cols_to_scale
                if col not in boolean_cols_in_pairwise
            ]

    def _transform_raw_user_data_to_ml_input(
            self,
            user_id: int,
            profile_db: Any,  # SQLAlchemy Profile model
            location_db: Any,  # SQLAlchemy Location model
            pets_db: List[str],  # List of pet names
            interests_db: List[str],  # List of interest names
            languages_db: List[str],  # List of language names
            body_type_name: str | None,
            orientation_name: str | None,
            job_industry_name: str | None,
            drink_status_name: str | None,
            smoke_status_name: str | None,
            education_level_name: str | None
    ) -> Dict[str, Any]:
        """
        Chuyển đổi dữ liệu user từ DB (các SQLAlchemy models/list) thành dictionary
        có cấu trúc giống `profiles_df` trong notebook để dùng cho feature engineering.
        """
        raw_data = {
            'id': user_id,
            'date_of_birth': str(profile_db.date_of_birth) if profile_db and profile_db.date_of_birth else None,
            'height': profile_db.height if profile_db else None,
            'body_type': body_type_name,  # đã join từ ID
            'sex': profile_db.sex if profile_db else None,
            'orientation': orientation_name,  # đã join từ ID
            'job': job_industry_name,  # đã join từ ID
            'drink': drink_status_name,  # đã join từ ID
            'smoke': smoke_status_name,  # đã join từ ID
            'interested_in_new_language': profile_db.interested_in_new_language if profile_db else None,
            'education_level': education_level_name,  # đã join từ ID
            'dropped_out_school': profile_db.drop_out if profile_db else None,  # Sửa tên cột
            'location_preference': profile_db.location_preference if profile_db else None,
            'bio': profile_db.bio if profile_db else None,
            'latitude': float(location_db.latitudes) if location_db and location_db.latitudes is not None else None,
            'longitude': float(location_db.longitudes) if location_db and location_db.longitudes is not None else None,
            'country': location_db.country if location_db else None,  # Cần cho logic, không phải feature
            'state': location_db.state if location_db else None,  # Cần cho logic, không phải feature
            'city': location_db.city if location_db else None,  # Cần cho logic, không phải feature
            'pets': " - ".join(sorted(list(set(pets_db)))) if pets_db else None,
            'interests': " - ".join(sorted(list(set(interests_db)))) if interests_db else None,
            'languages': " - ".join(sorted(list(set(languages_db)))) if languages_db else None,
        }
        # Tính tuổi
        raw_data['age'] = calculate_age(raw_data['date_of_birth']) if raw_data['date_of_birth'] else np.nan
        return raw_data

    def _get_user_feature_vector(
            self,
            user_id: int,
            profile_db: Any, location_db: Any, pets_db: List[str],
            interests_db: List[str], languages_db: List[str],
            body_type_name: str | None, orientation_name: str | None, job_industry_name: str | None,
            drink_status_name: str | None, smoke_status_name: str | None, education_level_name: str | None
    ) -> pd.Series:
        user_raw_data = self._transform_raw_user_data_to_ml_input(
            user_id, profile_db, location_db, pets_db, interests_db, languages_db,
            body_type_name, orientation_name, job_industry_name,
            drink_status_name, smoke_status_name, education_level_name
        )
        feature_vector = create_user_feature_vector(user_raw_data)
        # Đảm bảo vector có đúng các cột và thứ tự như khi huấn luyện
        return feature_vector.reindex(self.user_feature_columns).fillna(0)

    def predict_match_proba(
            self,
            user1_data_tuple: Tuple,
            user2_data_tuple: Tuple
    ) -> float:
        u1_id, u1_prof, u1_loc, u1_pets, u1_ints, u1_langs, u1_body, u1_orient, u1_job, u1_drink, u1_smoke, u1_edu = user1_data_tuple
        u2_id, u2_prof, u2_loc, u2_pets, u2_ints, u2_langs, u2_body, u2_orient, u2_job, u2_drink, u2_smoke, u2_edu = user2_data_tuple

        user1_raw_for_pairwise = self._transform_raw_user_data_to_ml_input(
            u1_id, u1_prof, u1_loc, u1_pets, u1_ints, u1_langs, u1_body, u1_orient, u1_job, u1_drink, u1_smoke, u1_edu
        )
        user1_feature_vec = self._get_user_feature_vector(
            u1_id, u1_prof, u1_loc, u1_pets, u1_ints, u1_langs, u1_body, u1_orient, u1_job, u1_drink, u1_smoke, u1_edu
        )

        user2_raw_for_pairwise = self._transform_raw_user_data_to_ml_input(
            u2_id, u2_prof, u2_loc, u2_pets, u2_ints, u2_langs, u2_body, u2_orient, u2_job, u2_drink, u2_smoke, u2_edu
        )
        user2_feature_vec = self._get_user_feature_vector(
            u2_id, u2_prof, u2_loc, u2_pets, u2_ints, u2_langs, u2_body, u2_orient, u2_job, u2_drink, u2_smoke, u2_edu
        )

        pair_feature_vector_series = create_pairwise_features_vector(
            user1_raw_for_pairwise, user1_feature_vec,
            user2_raw_for_pairwise, user2_feature_vec,
            pairwise_input_columns_list=self.pairwise_input_columns,
            pairwise_features_scaler=self.pairwise_features_scaler,
            numerical_cols_to_scale_in_notebook=self.numerical_pairwise_cols_to_scale
        )

        # --- THAY ĐỔI CHÍNH Ở ĐÂY ---
        # Chuyển pd.Series thành pd.DataFrame một dòng, giữ nguyên tên cột
        # self.pairwise_input_columns là danh sách tên cột mà model mong đợi
        pair_feature_df_for_prediction = pd.DataFrame([pair_feature_vector_series.values],
                                                      columns=self.pairwise_input_columns)
        # Đảm bảo thứ tự cột của DataFrame này khớp với thứ tự khi fit model.
        # pair_feature_vector_series đã được trả về với index là self.pairwise_input_columns,
        # nên khi tạo DataFrame từ values và columns này thì thứ tự sẽ đúng.

        # Hoặc cách khác an toàn hơn:
        # pair_feature_df_for_prediction = pd.DataFrame(pair_feature_vector_series).T
        # # .T để chuyển Series thành DataFrame một dòng, cột là index của Series
        # # Sau đó, đảm bảo thứ tự cột khớp với lúc fit:
        # pair_feature_df_for_prediction = pair_feature_df_for_prediction[self.pairwise_input_columns]

        proba = self.model.predict_proba(pair_feature_df_for_prediction)  # Truyền DataFrame
        return float(proba[0, 1])