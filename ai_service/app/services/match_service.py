# app/services/match_service.py
"""
Match service for Amoura AI Service.

This module provides the MatchService class for handling AI-powered
match predictions using machine learning models.
"""

from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.core.logging import LoggerMixin
from app.core.config import get_settings
from app.db import crud
from app.ml.predictor import MatchPredictor
from app.ml.preprocessing import orientation_compatibility


class MatchService(LoggerMixin):
    """
    Service providing AI-powered match predictions.

    Combines ML predictions with business rules and practical fallbacks to
    return relevant, swipe-ready match candidates for a given user.
    """
    
    def __init__(self, db: Session, predictor=None, match_threshold: float = None):
        """
        Initialize MatchService.
        
        Args:
            db: Database session
            predictor: MatchPredictor instance
            match_threshold: Threshold for considering a match valid (from config if None)
        """
        self.db = db
        self.predictor = predictor
        
        # Get threshold from config if not provided
        if match_threshold is None:
            settings = get_settings()
            match_threshold = settings.MATCH_PROBABILITY_THRESHOLD
            
        self.match_threshold = match_threshold
        self.logger.info(f"MatchService initialized with threshold: {self.match_threshold}")
    
    def get_comprehensive_matches(self, current_user_id: int, limit: int = 20) -> List[int]:
        """
        Find matches for a user using a three-tier cascade:
        1) Machine Learning predictions (primary)
        2) Gender/orientation compatibility filtering (secondary)
        3) Random users (final fallback)

        Ensures results exclude already-swiped users and the current user.

        Args:
            current_user_id: Target user ID
            limit: Desired number of matches (default: 20)

        Returns:
            Up to `limit` user IDs

        Raises:
            HTTPException: If user not found, invalid role, or on internal errors
        """
        self.logger.info(f"Finding comprehensive matches for user {current_user_id} (target: {limit} users)")
        
        try:
            # Validate user exists and has correct role
            current_user_data_tuple = self._get_user_data(current_user_id)
            self._validate_user_role(current_user_id)
            
            final_matches = []
            
            # STEP 1: Machine Learning Predictions
            self.logger.info(f"Step 1: Getting ML-based matches for user {current_user_id}")
            ml_matches = self._get_ml_matches(current_user_id, current_user_data_tuple, limit)
            final_matches.extend(ml_matches)
            self.logger.info(f"ML matches found: {len(ml_matches)} users")
            
            # STEP 2: Gender/Orientation Compatibility (if needed)
            if len(final_matches) < limit:
                remaining_needed = limit - len(final_matches)
                self.logger.info(f"Step 2: Getting gender/orientation matches (need {remaining_needed} more)")
                
                gender_matches = self._get_gender_orientation_matches(current_user_id, remaining_needed, final_matches)
                final_matches.extend(gender_matches)
                self.logger.info(f"Gender/orientation matches found: {len(gender_matches)} users")
            
            # STEP 3: Random Users (final fallback)
            if len(final_matches) < limit:
                remaining_needed = limit - len(final_matches)
                self.logger.info(f"Step 3: Getting random matches (need {remaining_needed} more)")
                
                random_matches = self._get_random_matches(current_user_id, remaining_needed, final_matches)
                final_matches.extend(random_matches)
                self.logger.info(f"Random matches found: {len(random_matches)} users")
            
            # Ensure uniqueness and honor the limit
            final_matches = list(dict.fromkeys(final_matches))[:limit]
            
            self.logger.info(f"Total comprehensive matches for user {current_user_id}: {len(final_matches)} users")
            return final_matches
            
        except HTTPException:
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error finding comprehensive matches for user {current_user_id}: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to find matches for user {current_user_id}"
            )
    
    def _get_ml_matches(self, current_user_id: int, current_user_data_tuple: tuple, limit: int) -> List[int]:
        """
        Get matches using Machine Learning predictions only.

        Args:
            current_user_id: Current user ID
            current_user_data_tuple: Current user features tuple
            limit: Maximum matches to return

        Returns:
            List of user IDs from ML predictions
        """
        try:
            # Get all candidate users
            candidate_user_ids = self._get_candidate_users(current_user_id)
            
            if not candidate_user_ids:
                self.logger.info(f"No candidate users available for ML matching")
                return []
            
            # Find ML-based matches
            ml_matches = self._find_matches(current_user_id, current_user_data_tuple, candidate_user_ids, limit)
            return ml_matches
            
        except Exception as e:
            self.logger.warning(f"Error in ML matching for user {current_user_id}: {e}")
            return []
    
    def _get_gender_orientation_matches(self, current_user_id: int, limit: int, exclude_ids: List[int]) -> List[int]:
        """
        Get matches based on gender and orientation compatibility.

        Args:
            current_user_id: Current user ID
            limit: Maximum matches to return
            exclude_ids: User IDs to exclude

        Returns:
            List of user IDs filtered by compatibility
        """
        try:
            # Get backup recommendations (gender/orientation based)
            backup_matches = crud.get_backup_recommendations(self.db, current_user_id, limit * 2)  # Get more to filter
            
            # Filter out already found users
            filtered_matches = [uid for uid in backup_matches if uid not in exclude_ids]
            
            return filtered_matches[:limit]
            
        except Exception as e:
            self.logger.warning(f"Error in gender/orientation matching for user {current_user_id}: {e}")
            return []
    
    def _get_random_matches(self, current_user_id: int, limit: int, exclude_ids: List[int]) -> List[int]:
        """
        Get random matches as the final fallback.

        Args:
            current_user_id: Current user ID
            limit: Maximum matches to return
            exclude_ids: User IDs to exclude

        Returns:
            List of random user IDs
        """
        try:
            # Get random users
            random_matches = crud.get_random_users(self.db, current_user_id, limit * 2)  # Get more to filter
            
            # Filter out already found users
            filtered_matches = [uid for uid in random_matches if uid not in exclude_ids]
            
            return filtered_matches[:limit]
            
        except Exception as e:
            self.logger.warning(f"Error in random matching for user {current_user_id}: {e}")
            return []

    

    def get_potential_matches(self, current_user_id: int, limit: int = 10) -> List[int]:
        """
        Legacy method: ML-only potential matches (kept for backward compatibility).

        Args:
            current_user_id: Current user ID
            limit: Maximum number of matches to return

        Returns:
            List of user IDs that are potential matches

        Raises:
            HTTPException: If user not found, invalid role, or other errors
        """
        self.logger.info(f"Finding potential matches for user {current_user_id} (limit: {limit})")
        
        try:
            # Validate user exists and has complete profile
            current_user_data_tuple = self._get_user_data(current_user_id)
            
            # Validate user role
            self._validate_user_role(current_user_id)
            
            # Get candidate users
            candidate_user_ids = self._get_candidate_users(current_user_id)
            
            if not candidate_user_ids:
                self.logger.info(f"No candidate users found for user {current_user_id}")
                return []
            
            # Find matches
            potential_matches = self._find_matches(
                current_user_id, 
                current_user_data_tuple, 
                candidate_user_ids, 
                limit
            )
            
            self.logger.info(f"Found {len(potential_matches)} potential matches for user {current_user_id}")
            return potential_matches
            
        except HTTPException:
            # Re-raise HTTP exceptions as they are
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error finding matches for user {current_user_id}: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to find potential matches for user {current_user_id}"
            )
    
    def _get_user_data(self, user_id: int) -> tuple:
        """Fetch user data tuple required for ML and business checks.

        Raises HTTP 404 if missing/incomplete.
        """
        user_data_tuple = crud.get_user_profile_raw_data(self.db, user_id)
        
        if not user_data_tuple or not user_data_tuple[0]:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {user_id} not found or profile incomplete"
            )
        
        return user_data_tuple
    
    def _validate_user_role(self, user_id: int):
        """Validate that the user has the 'USER' role; else raise HTTP 403."""
        user_role = crud.get_user_role_name(self.db, user_id)
        
        if user_role != "USER":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"User with id {user_id} does not have 'USER' role"
            )
    
    def _get_candidate_users(self, current_user_id: int) -> List[int]:
        """Return candidate user IDs that the current user hasn't swiped yet."""
        return crud.get_non_swiped_user_ids_with_role(
            self.db, 
            current_user_id, 
            role_name="USER"
        )
    
    def _find_matches(
        self, 
        current_user_id: int, 
        current_user_data_tuple: tuple, 
        candidate_user_ids: List[int], 
        limit: int
    ) -> List[int]:
        """
        Find matches among candidate users.
        
        Args:
            current_user_id: Current user ID
            current_user_data_tuple: Current user data
            candidate_user_ids: List of candidate user IDs
            limit: Maximum number of matches to return
            
        Returns:
            List of matched user IDs
        """
        potential_matches_ids: List[int] = []
        
        # Extract current user information
        current_user_sex = current_user_data_tuple[1].sex if current_user_data_tuple[1] else None
        current_user_orientation_name = current_user_data_tuple[7]
        
        for other_user_id in candidate_user_ids:
            # Check if we already have enough matches
            if len(potential_matches_ids) >= limit:
                break
            
            try:
                # Get other user data
                other_user_data_tuple = self._get_user_data(other_user_id)
                
                # Extract other user information
                other_user_sex = other_user_data_tuple[1].sex if other_user_data_tuple[1] else None
                other_user_orientation_name = other_user_data_tuple[7]
                
                # Check orientation compatibility first
                if not orientation_compatibility(
                    current_user_sex, current_user_orientation_name,
                    other_user_sex, other_user_orientation_name
                ):
                    self.logger.debug(f"Users {current_user_id} and {other_user_id} not orientation compatible")
                    continue
                
                # Predict match probability
                match_proba = self.predictor.predict_match_proba(
                    user1_data_tuple=current_user_data_tuple,
                    user2_data_tuple=other_user_data_tuple
                )
                
                # Check if probability exceeds threshold
                if match_proba > self.match_threshold:
                    potential_matches_ids.append(other_user_id)
                    self.logger.debug(
                        f"Match found: users {current_user_id} and {other_user_id} "
                        f"(probability: {match_proba:.4f})"
                    )
                else:
                    self.logger.debug(
                        f"No match: users {current_user_id} and {other_user_id} "
                        f"(probability: {match_proba:.4f} < {self.match_threshold})"
                    )
                    
            except Exception as e:
                self.logger.warning(
                    f"Error processing candidate user {other_user_id} for user {current_user_id}: {e}"
                )
                continue
        
        return potential_matches_ids

    def get_backup_recommendations(self, user_id: int, limit: int = 10) -> List[int]:
        """
        Lấy danh sách ID người dùng backup dựa trên giới tính và orientation.
        
        Args:
            user_id: ID của người dùng hiện tại
            limit: Số lượng recommendations tối đa
            
        Returns:
            List of user IDs
        """
        self.logger.info(f"Getting backup recommendations for user {user_id}")
        
        try:
            # Lấy backup recommendations
            user_ids = crud.get_backup_recommendations(self.db, user_id, limit)
            
            self.logger.info(f"Found {len(user_ids)} backup recommendations for user {user_id}")
            return user_ids
            
        except Exception as e:
            self.logger.error(f"Error getting backup recommendations for user {user_id}: {e}")
            return []