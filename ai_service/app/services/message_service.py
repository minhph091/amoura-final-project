"""
Message service for Amoura AI Service.

This module provides the MessageService class for handling AI-powered
message editing using Google Gemini API.
"""

import google.generativeai as genai
from typing import Optional, Dict, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.core.config import get_settings
from app.core.exceptions import ExternalAPIError
from app.core.logging import LoggerMixin
from app.db import crud


class MessageService(LoggerMixin):
    """
    Service for AI-powered message editing.
    
    This service uses Google Gemini API to provide intelligent
    message editing capabilities with conversation context awareness.
    """
    
    def __init__(self, db: Session):
        """
        Initialize MessageService.
        
        Args:
            db: Database session
        """
        self.db = db
        self.settings = get_settings()
        
        # Configure Gemini API
        if not self.settings.GEMINI_API_KEY:
            raise ValueError("Gemini API key not configured")
        
        genai.configure(api_key=self.settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-2.5-flash')
        
        self.logger.info("MessageService initialized successfully")
    
    def edit_message(
        self, 
        original_message: str, 
        edit_prompt: str, 
        user_id: int, 
        other_user_id: int
    ) -> str:
        """
        Edit a message using Gemini AI based on the user's prompt.
        
        This method:
        1. Validates both users exist
        2. Retrieves conversation history from database
        3. Creates context-aware system prompt
        4. Uses Gemini AI to edit the message
        5. Returns the edited message
        
        Args:
            original_message: The original message to edit
            edit_prompt: The user's instructions for editing
            user_id: ID of the user requesting the edit
            other_user_id: ID of the other user in the conversation
            
        Returns:
            The edited message
            
        Raises:
            HTTPException: If users not found or editing fails
        """
        self.logger.info(f"Editing message for user {user_id} in conversation with user {other_user_id}")
        
        try:
            # Validate users exist
            self._validate_users_exist(user_id, other_user_id)
            
            # Retrieve conversation history
            messages = crud.get_message_history(self.db, user_id, other_user_id)
            conversation_history = crud.format_messages_for_ai(messages, user_id)
            
            if not messages:
                self.logger.warning(f"No conversation history found between users {user_id} and {other_user_id}")
            
            # Create system prompt with conversation context
            system_prompt = self._create_system_prompt(conversation_history)
            
            # Create user prompt
            user_prompt = self._create_user_prompt(original_message, edit_prompt)
            
            # Generate edited message using Gemini
            edited_message = self._generate_edited_message(system_prompt, user_prompt)
            
            self.logger.info(f"Successfully edited message for user {user_id}")
            return edited_message
            
        except HTTPException:
            raise
        except Exception as e:
            self.logger.error(f"Error editing message: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An error occurred while editing the message. Please try again."
            )
    
    def _validate_users_exist(self, user_id: int, other_user_id: int):
        """
        Validate that both users exist in the database.
        
        Args:
            user_id: First user ID
            other_user_id: Second user ID
            
        Raises:
            HTTPException: If either user not found
        """
        user = crud.get_user_by_id(self.db, user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} not found."
            )
        
        other_user = crud.get_user_by_id(self.db, other_user_id)
        if not other_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Other user with ID {other_user_id} not found."
            )
    
    def _create_system_prompt(self, conversation_history: Optional[List[Dict]] = None) -> str:
        """
        Create a system prompt for Gemini based on conversation context.
        
        Args:
            conversation_history: Optional conversation history for context
            
        Returns:
            The system prompt
        """
        system_prompt = """
        You are an expert dating coach and communication assistant helping users improve their messages in a dating app context. Your task is to edit the original message according to the user's instructions while maintaining authenticity and improving the message's effectiveness.

        CORE GUIDELINES:
        1. **Preserve Authenticity**: Keep the original intent and genuine personality of the user
        2. **Improve Communication**: Make the message clearer, more engaging, and more likely to get a response
        3. **Dating Context Awareness**: Consider this is a dating app conversation - be flirty but respectful, show interest, and encourage conversation
        4. **Follow User Instructions**: Implement the specific edits requested by the user
        5. **Grammar & Clarity**: Fix grammar, spelling, and improve readability while maintaining natural tone
        6. **Conversation Flow**: Ensure the edited message fits naturally in the ongoing conversation

        DATING APP BEST PRACTICES TO CONSIDER:
        - Be specific and show you've read their profile
        - Ask engaging questions that encourage responses
        - Keep it light and positive
        - Avoid generic messages
        - Show genuine interest without being overly intense
        - Use appropriate humor when suitable
        - Be respectful and considerate

        IMPORTANT RULES:
        - Return ONLY the edited message text, no explanations
        - Keep the message length appropriate (not too short, not too long)
        - Maintain the user's original tone and personality
        - If the user's instructions conflict with dating best practices, prioritize the user's instructions
        - Don't add emojis unless they were in the original message or specifically requested
        """
        
        if conversation_history and len(conversation_history) > 0:
            system_prompt += """

            CONVERSATION CONTEXT:
            You have access to the conversation history to understand the context and tone of the ongoing conversation. Use this to ensure your edit maintains consistency with the conversation flow and relationship dynamic.
            """
        
        return system_prompt
    
    def _create_user_prompt(self, original_message: str, edit_prompt: str) -> str:
        """
        Create the user prompt for Gemini.
        
        Args:
            original_message: The original message to edit
            edit_prompt: The user's instructions for editing
            
        Returns:
            The user prompt
        """
        return f"""
        Original message: {original_message}

        Edit instructions: {edit_prompt}
        
        Please provide only the edited message without any explanations or additional text.
        """
    
    def _generate_edited_message(self, system_prompt: str, user_prompt: str) -> str:
        """
        Generate edited message using Gemini AI.
        
        Args:
            system_prompt: System prompt for context
            user_prompt: User prompt with original message and instructions
            
        Returns:
            The edited message
            
        Raises:
            ExternalAPIError: If Gemini API call fails
        """
        try:
            # Combine system prompt and user prompt since Gemini doesn't support system role
            combined_prompt = f"{system_prompt}\n\n{user_prompt}"
            
            response = self.model.generate_content(combined_prompt)
            
            edited_message = response.text.strip()
            
            if not edited_message:
                raise ExternalAPIError(
                    api_name="Gemini",
                    error="Generated message is empty"
                )
            
            return edited_message
            
        except Exception as e:
            self.logger.error(f"Error generating response from Gemini: {e}")
            raise ExternalAPIError(
                api_name="Gemini",
                error=f"Failed to generate edited message: {e}"
            )
