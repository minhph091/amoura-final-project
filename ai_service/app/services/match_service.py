# app/services/match_service.py
"""
Match service for Amoura AI Service.

This module provides the MatchService class for handling user matching
operations including potential match discovery and compatibility analysis.
"""

from sqlalchemy.orm import Session
from typing import List
from fastapi import HTTPException, status

from app.core.config import get_settings
from app.core.logging import LoggerMixin, get_logger
from app.db import crud
from app.ml.predictor import MatchPredictor
from app.ml.preprocessing import orientation_compatibility


class MatchService(LoggerMixin):
    """
    Service for handling user matching operations.
    
    This service coordinates between the database layer and ML predictor
    to provide intelligent match recommendations.
    """
    
    def __init__(self, db: Session, predictor: MatchPredictor):
        """
        Initialize MatchService.
        
        Args:
            db: Database session
            predictor: ML predictor instance
        """
        self.db = db
        self.predictor = predictor
        self.settings = get_settings()
        self.match_threshold = self.settings.MATCH_PROBABILITY_THRESHOLD
        
        self.logger.info(f"MatchService initialized with threshold: {self.match_threshold}")
    
    def get_potential_matches(self, current_user_id: int, limit: int = 10) -> List[int]:
        """
        Get potential matches for a user.
        
        This method finds users that are potential matches based on:
        - User role validation
        - Orientation compatibility
        - ML model predictions
        - Match probability threshold
        
        Args:
            current_user_id: ID of the user to find matches for
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
        """
        Get user data from database.
        
        Args:
            user_id: User ID
            
        Returns:
            Tuple containing user data
            
        Raises:
            HTTPException: If user not found or profile incomplete
        """
        user_data_tuple = crud.get_user_profile_raw_data(self.db, user_id)
        
        if not user_data_tuple or not user_data_tuple[0]:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {user_id} not found or profile incomplete"
            )
        
        return user_data_tuple
    
    def _validate_user_role(self, user_id: int):
        """
        Validate that user has 'USER' role.
        
        Args:
            user_id: User ID
            
        Raises:
            HTTPException: If user doesn't have 'USER' role
        """
        user_role = crud.get_user_role_name(self.db, user_id)
        
        if user_role != "USER":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"User with id {user_id} does not have 'USER' role"
            )
    
    def _get_candidate_users(self, current_user_id: int) -> List[int]:
        """
        Get candidate users that haven't been swiped on yet.
        
        Args:
            current_user_id: Current user ID
            
        Returns:
            List of candidate user IDs
        """
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