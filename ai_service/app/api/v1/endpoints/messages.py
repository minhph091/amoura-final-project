"""
Message-related API endpoints for Amoura AI Service.

This module provides endpoints for AI-powered message editing functionality,
allowing users to improve their messages using artificial intelligence.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Annotated

from app import schemas
from app.services.message_service import MessageService
from app.db.session import get_db

router = APIRouter()


def get_message_service(
        db: Annotated[Session, Depends(get_db)]
) -> MessageService:
    """
    Dependency injection for MessageService.
    
    Creates and returns a MessageService instance with the provided
    database session for message editing operations.
    
    Args:
        db: Database session from dependency injection
        
    Returns:
        MessageService instance configured with the database session
    """
    return MessageService(db=db)


@router.post(
    "/messages/edit",
    response_model=schemas.message.MessageEditResponse,
    summary="Edit a message using AI",
    description="""
    Edits a message using AI based on the user's prompt.
    
    **Required fields:**
    - original_message: The message to be edited
    - edit_prompt: User's instructions for editing the message
    - sender_id: ID of the user requesting the edit
    - receiver_id: ID of the other user in the conversation
    
    **Features:**
    - Conversation history is automatically retrieved from the database
    - AI considers the conversation context when editing
    - Maintains user's authentic personality while improving communication
    """
)
async def edit_message(
        request: schemas.message.MessageEditRequest,
        message_service: Annotated[MessageService, Depends(get_message_service)]
):
    """
    Endpoint to edit a message using AI.
    
    This endpoint uses Google Gemini AI to improve user messages based on
    conversation context and user-provided editing instructions. The AI
    considers the conversation history to maintain context and personality.
    
    Args:
        request: MessageEditRequest containing the original message, edit prompt,
                sender ID, and receiver ID
        message_service: Injected MessageService dependency
        
    Returns:
        MessageEditResponse containing both the original and edited messages
        
    Raises:
        HTTPException: If required fields are missing or AI processing fails
        
    Example:
        Request:
        {
            "original_message": "Hey, how are you?",
            "edit_prompt": "Make it more engaging and ask about their interests",
            "sender_id": 1,
            "receiver_id": 2
        }
        
        Response:
        {
            "edited_message": "Hey! How are you doing? I'd love to hear about your interests!",
            "original_message": "Hey, how are you?"
        }
    """
    try:
        # Validate required fields
        if not request.original_message or not request.original_message.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Original message is required and cannot be empty."
            )
        
        if not request.edit_prompt or not request.edit_prompt.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Edit prompt is required and cannot be empty."
            )

        # Process message editing through AI service
        edited_message = message_service.edit_message(
            original_message=request.original_message.strip(),
            edit_prompt=request.edit_prompt.strip(),
            user_id=request.sender_id,
            other_user_id=request.receiver_id
        )

        # Return both original and edited messages for comparison
        return schemas.message.MessageEditResponse(
            edited_message=edited_message,
            original_message=request.original_message
        )
        
    except HTTPException:
        # Re-raise HTTP exceptions as they are already properly formatted
        raise
    except Exception as e:
        # Log the error for debugging
        print(f"Error editing message: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while editing the message. Please try again."
        )
