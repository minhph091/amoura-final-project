from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Annotated

from app import schemas
from app.services.message_service import MessageService
from app.db.session import get_db

router = APIRouter()


# Dependency to get MessageService
def get_message_service(
        db: Annotated[Session, Depends(get_db)]
) -> MessageService:
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
    - user_id: ID of the user requesting the edit
    - other_user_id: ID of the other user in the conversation
    
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
    
    **Parameters:**
    - **original_message**: The original message to edit (required)
    - **edit_prompt**: The user's instructions for editing (required)
    - **user_id**: ID of the user requesting the edit (required)
    - **other_user_id**: ID of the other user in the conversation (required)
    
    **Returns:**
    - **edited_message**: The AI-edited message
    - **original_message**: The original message for comparison
    
    **Note:** Conversation history is automatically retrieved from the database.
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

        edited_message = message_service.edit_message(
            original_message=request.original_message.strip(),
            edit_prompt=request.edit_prompt.strip(),
            user_id=request.user_id,
            other_user_id=request.other_user_id
        )

        return schemas.message.MessageEditResponse(
            edited_message=edited_message,
            original_message=request.original_message
        )
    except HTTPException:
        # Re-raise HTTP exceptions as they are
        raise
    except Exception as e:
        # Log the error
        print(f"Error editing message: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while editing the message. Please try again."
        )
