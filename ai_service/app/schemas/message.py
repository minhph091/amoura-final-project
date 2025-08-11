"""
Pydantic schemas for message-related API requests and responses.

This module defines the data models used for message editing API endpoints,
ensuring proper validation and documentation of request/response structures.
"""

from pydantic import BaseModel, Field, validator


class MessageEditRequest(BaseModel):
    """
    Request model for message editing endpoint.
    
    This schema defines the structure of the request sent to the message
    editing API endpoint, containing the original message, editing instructions,
    and user identification information.
    
    Attributes:
        original_message: The message to be edited by AI
        edit_prompt: User's instructions for how to edit the message
        sender_id: ID of the user requesting the edit
        receiver_id: ID of the other user in the conversation
        
    Example:
        {
            "original_message": "Hey, how are you doing?",
            "edit_prompt": "Make it more engaging and ask about their interests",
            "sender_id": 1,
            "receiver_id": 2
        }
    """
    original_message: str = Field(
        ..., 
        min_length=1, 
        max_length=2000, 
        description="The original message to be edited by AI"
    )
    edit_prompt: str = Field(
        ..., 
        min_length=1, 
        max_length=500, 
        description="User's instructions for editing the message"
    )
    sender_id: int = Field(
        ..., 
        description="ID of the sender (user requesting the edit)",
        gt=0
    )
    receiver_id: int = Field(
        ..., 
        description="ID of the receiver (other user in the conversation)",
        gt=0
    )

    @validator('original_message')
    def validate_original_message(cls, v):
        """
        Validate that the original message is not empty after trimming.
        
        Args:
            v: The original message value
            
        Returns:
            The trimmed original message
            
        Raises:
            ValueError: If the message is empty or contains only whitespace
        """
        if not v or not v.strip():
            raise ValueError('Original message cannot be empty')
        return v.strip()

    @validator('edit_prompt')
    def validate_edit_prompt(cls, v):
        """
        Validate that the edit prompt is not empty after trimming.
        
        Args:
            v: The edit prompt value
            
        Returns:
            The trimmed edit prompt
            
        Raises:
            ValueError: If the prompt is empty or contains only whitespace
        """
        if not v or not v.strip():
            raise ValueError('Edit prompt cannot be empty')
        return v.strip()

    @validator('sender_id')
    def validate_sender_id(cls, v):
        """
        Validate that the sender ID is a positive integer.
        
        Args:
            v: The sender ID value
            
        Returns:
            The validated sender ID
            
        Raises:
            ValueError: If the sender ID is not positive
        """
        if v <= 0:
            raise ValueError('Sender ID must be a positive integer')
        return v

    @validator('receiver_id')
    def validate_receiver_id(cls, v):
        """
        Validate that the receiver ID is a positive integer.
        
        Args:
            v: The receiver ID value
            
        Returns:
            The validated receiver ID
            
        Raises:
            ValueError: If the receiver ID is not positive
        """
        if v <= 0:
            raise ValueError('Receiver ID must be a positive integer')
        return v

    class Config:
        """Pydantic configuration for the schema."""
        json_schema_extra = {
            "example": {
                "original_message": "Hey, how are you doing?",
                "edit_prompt": "Make it more engaging and ask about their interests",
                "sender_id": 1,
                "receiver_id": 2
            }
        }


class MessageEditResponse(BaseModel):
    """
    Response model for message editing endpoint.
    
    This schema defines the structure of the response returned by the
    message editing API endpoint, containing both the original and
    AI-edited versions of the message for comparison.
    
    Attributes:
        edited_message: The AI-improved version of the message
        original_message: The original message that was submitted for editing
        
    Example:
        {
            "edited_message": "Hey! How are you doing? I noticed you love hiking - what's your favorite trail?",
            "original_message": "Hey, how are you doing?"
        }
    """
    edited_message: str = Field(
        ..., 
        description="The AI-edited version of the message"
    )
    original_message: str = Field(
        ..., 
        description="The original message that was submitted for editing"
    )

    class Config:
        """Pydantic configuration for the schema."""
        json_schema_extra = {
            "example": {
                "edited_message": "Hey! How are you doing? I noticed you love hiking - what's your favorite trail?",
                "original_message": "Hey, how are you doing?"
            }
        }
