import google.generativeai as genai
from typing import List, Optional, Dict
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.core.config import settings
from app.db import crud


class MessageService:
    def __init__(self, db: Session):
        self.db = db
        # Configure the Gemini API
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-pro')

    def edit_message(self, original_message: str, edit_prompt: str, 
                     user_id: int, other_user_id: int) -> str:
        """
        Edit a message using Gemini AI based on the user's prompt.

        Args:
            original_message: The original message to edit
            edit_prompt: The user's instructions for editing
            user_id: ID of the user requesting the edit
            other_user_id: ID of the other user in the conversation

        Returns:
            The edited message
        """
        # Validate that both users exist
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

        # Always retrieve conversation history from database
        messages = crud.get_message_history(self.db, user_id, other_user_id)
        conversation_history = crud.format_messages_for_ai(messages, user_id)

        # Check if there's any conversation history (optional validation)
        if not messages:
            print(f"Warning: No conversation history found between user {user_id} and user {other_user_id}")

        # Create system prompt
        system_prompt = self._create_system_prompt(conversation_history)

        # Create the prompt for Gemini
        user_prompt = f"""
        Original message: {original_message}

        Edit instructions: {edit_prompt}
        
        Please provide only the edited message without any explanations or additional text.
        """

        try:
            # Generate the response from Gemini
            response = self.model.generate_content(
                [
                    {"role": "system", "parts": [system_prompt]},
                    {"role": "user", "parts": [user_prompt]}
                ]
            )

            # Return the edited message
            return response.text.strip()
        except Exception as e:
            # Log the error for debugging
            print(f"Error generating response from Gemini: {e}")
            raise Exception("Failed to generate edited message. Please try again.")

    def _create_system_prompt(self, conversation_history: Optional[List[Dict]] = None) -> str:
        """
        Create a system prompt for Gemini based on the conversation history.

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
