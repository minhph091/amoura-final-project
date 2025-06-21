"""
Machine Learning predictor for Amoura AI Service.

This module provides the MatchPredictor class for predicting match probabilities
between users using trained ML models.
"""

import joblib
import os
import pandas as pd
import numpy as np
from typing import Dict, Any, Tuple, List
from pathlib import Path

from app.core.exceptions import ModelLoadError, PredictionError
from app.core.logging import LoggerMixin, get_logger
from app.ml.preprocessing import (
    create_user_feature_vector,
    create_pairwise_features_vector,
    calculate_age,
    orientation_compatibility
)
from sklearn.preprocessing import MinMaxScaler


class MatchPredictor(LoggerMixin):
    """
    ML model predictor for user matching.
    
    This class handles loading trained ML models and making predictions
    for user compatibility matching.
    """
    
    def __init__(self, models_dir: str):
        """
        Initialize MatchPredictor with trained models.
        
        Args:
            models_dir: Directory containing trained ML models
            
        Raises:
            ModelLoadError: If model files cannot be loaded
        """
        self.models_dir = Path(models_dir)
        self.logger.info(f"Initializing MatchPredictor from: {self.models_dir}")
        
        # Model components
        self.model = None
        self.pairwise_input_columns: List[str] = []
        self.user_feature_columns: List[str] = []
        self.pairwise_features_scaler: MinMaxScaler = None
        self.numerical_pairwise_cols_to_scale: List[str] = []
        
        # Load all required models
        self._load_models()
        
        self.logger.info("MatchPredictor initialized successfully")
    
    def _load_models(self):
        """Load all required ML models and preprocessors."""
        try:
            # Load main model
            model_path = self.models_dir / "best_overall_model.joblib"
            self.model = joblib.load(model_path)
            self.logger.debug(f"Loaded main model from: {model_path}")
            
            # Load feature column definitions
            pairwise_cols_path = self.models_dir / "pairwise_model_input_columns.joblib"
            self.pairwise_input_columns = joblib.load(pairwise_cols_path)
            self.logger.debug(f"Loaded pairwise input columns: {len(self.pairwise_input_columns)} columns")
            
            user_cols_path = self.models_dir / "user_features_final_columns.joblib"
            self.user_feature_columns = joblib.load(user_cols_path)
            self.logger.debug(f"Loaded user feature columns: {len(self.user_feature_columns)} columns")
            
            # Load scalers
            scaler_path = self.models_dir / "pairwise_features_scaler.joblib"
            self.pairwise_features_scaler = joblib.load(scaler_path)
            self.logger.debug("Loaded pairwise features scaler")
            
            # Load numerical columns to scale
            try:
                numerical_cols_path = self.models_dir / "numerical_pairwise_cols_to_scale.joblib"
                self.numerical_pairwise_cols_to_scale = joblib.load(numerical_cols_path)
                self.logger.debug(f"Loaded numerical columns to scale: {len(self.numerical_pairwise_cols_to_scale)} columns")
            except FileNotFoundError:
                self.logger.warning("numerical_pairwise_cols_to_scale.joblib not found, using fallback")
                self._setup_fallback_numerical_columns()
                
        except FileNotFoundError as e:
            raise ModelLoadError(
                model_name=str(e),
                error=f"Model file not found: {e}"
            )
        except Exception as e:
            raise ModelLoadError(
                model_name="unknown",
                error=f"Failed to load models: {e}"
            )
    
    def _setup_fallback_numerical_columns(self):
        """Setup fallback numerical columns when the file is not available."""
        self.numerical_pairwise_cols_to_scale = [
            'age_diff', 'height_diff', 'geo_distance_km',
            'user1_within_user2_loc_pref', 'user2_within_user1_loc_pref',
            'drink_match', 'smoke_match', 'education_match',
            'interests_jaccard', 'languages_jaccard',
            'user1_wants_learn_lang', 'user2_wants_learn_lang',
            'language_interest_match', 'pets_jaccard',
            'user_features_cosine_sim', 'user_features_mae_diff'
        ]
        
        # Remove boolean columns that shouldn't be scaled
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
        Transform raw user data from database to ML input format.
        
        Args:
            user_id: User ID
            profile_db: Profile database object
            location_db: Location database object
            pets_db: List of pet names
            interests_db: List of interest names
            languages_db: List of language names
            body_type_name: Body type name
            orientation_name: Orientation name
            job_industry_name: Job industry name
            drink_status_name: Drink status name
            smoke_status_name: Smoke status name
            education_level_name: Education level name
            
        Returns:
            Dictionary with user data in ML input format
        """
        raw_data = {
            'id': user_id,
            'date_of_birth': str(profile_db.date_of_birth) if profile_db and profile_db.date_of_birth else None,
            'height': profile_db.height if profile_db else None,
            'body_type': body_type_name,
            'sex': profile_db.sex if profile_db else None,
            'orientation': orientation_name,
            'job': job_industry_name,
            'drink': drink_status_name,
            'smoke': smoke_status_name,
            'interested_in_new_language': profile_db.interested_in_new_language if profile_db else None,
            'education_level': education_level_name,
            'dropped_out_school': profile_db.drop_out if profile_db else None,
            'location_preference': profile_db.location_preference if profile_db else None,
            'bio': profile_db.bio if profile_db else None,
            'latitude': float(location_db.latitudes) if location_db and location_db.latitudes is not None else None,
            'longitude': float(location_db.longitudes) if location_db and location_db.longitudes is not None else None,
            'country': location_db.country if location_db else None,
            'state': location_db.state if location_db else None,
            'city': location_db.city if location_db else None,
            'pets': " - ".join(sorted(list(set(pets_db)))) if pets_db else None,
            'interests': " - ".join(sorted(list(set(interests_db)))) if interests_db else None,
            'languages': " - ".join(sorted(list(set(languages_db)))) if languages_db else None,
        }
        
        # Calculate age
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
        """
        Generate feature vector for a user.
        
        Args:
            user_id: User ID
            profile_db: Profile database object
            location_db: Location database object
            pets_db: List of pet names
            interests_db: List of interest names
            languages_db: List of language names
            body_type_name: Body type name
            orientation_name: Orientation name
            job_industry_name: Job industry name
            drink_status_name: Drink status name
            smoke_status_name: Smoke status name
            education_level_name: Education level name
            
        Returns:
            Feature vector as pandas Series
        """
        user_raw_data = self._transform_raw_user_data_to_ml_input(
            user_id, profile_db, location_db, pets_db, interests_db, languages_db,
            body_type_name, orientation_name, job_industry_name,
            drink_status_name, smoke_status_name, education_level_name
        )
        
        feature_vector = create_user_feature_vector(user_raw_data)
        
        # Ensure vector has correct columns and order
        return feature_vector.reindex(self.user_feature_columns).fillna(0)
    
    def predict_match_proba(
        self,
        user1_data_tuple: Tuple,
        user2_data_tuple: Tuple
    ) -> float:
        """
        Predict match probability between two users.
        
        Args:
            user1_data_tuple: Tuple containing user1 data from database
            user2_data_tuple: Tuple containing user2 data from database
            
        Returns:
            Match probability between 0.0 and 1.0
            
        Raises:
            PredictionError: If prediction fails
        """
        try:
            # Unpack user data tuples
            u1_id, u1_prof, u1_loc, u1_pets, u1_ints, u1_langs, u1_body, u1_orient, u1_job, u1_drink, u1_smoke, u1_edu = user1_data_tuple
            u2_id, u2_prof, u2_loc, u2_pets, u2_ints, u2_langs, u2_body, u2_orient, u2_job, u2_drink, u2_smoke, u2_edu = user2_data_tuple
            
            # Transform user data
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
            
            # Create pairwise features
            pair_feature_vector_series = create_pairwise_features_vector(
                user1_raw_for_pairwise, user1_feature_vec,
                user2_raw_for_pairwise, user2_feature_vec,
                pairwise_input_columns_list=self.pairwise_input_columns,
                pairwise_features_scaler=self.pairwise_features_scaler,
                numerical_cols_to_scale_in_notebook=self.numerical_pairwise_cols_to_scale
            )
            
            # Convert to DataFrame for prediction
            pair_feature_df_for_prediction = pd.DataFrame(
                [pair_feature_vector_series.values],
                columns=self.pairwise_input_columns
            )
            
            # Make prediction
            proba = self.model.predict_proba(pair_feature_df_for_prediction)
            match_probability = float(proba[0, 1])
            
            self.logger.debug(f"Predicted match probability for users {u1_id} and {u2_id}: {match_probability:.4f}")
            
            return match_probability
            
        except Exception as e:
            raise PredictionError(
                operation="match_prediction",
                error=f"Failed to predict match probability: {e}"
            )