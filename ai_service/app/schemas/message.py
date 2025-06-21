from pydantic import BaseModel, Field, validator
from typing import Optional


class MessageEditRequest(BaseModel):
    message_id: Optional[int] = Field(None, description="ID of the message to edit (optional)")
    original_message: str = Field(..., min_length=1, max_length=2000, description="The original message to edit")
    edit_prompt: str = Field(..., min_length=1, max_length=500, description="User's instructions for editing the message")
    user_id: int = Field(..., description="ID of the user requesting the edit")
    other_user_id: int = Field(..., description="ID of the other user in the conversation")

    @validator('original_message')
    def validate_original_message(cls, v):
        if not v or not v.strip():
            raise ValueError('Original message cannot be empty')
        return v.strip()

    @validator('edit_prompt')
    def validate_edit_prompt(cls, v):
        if not v or not v.strip():
            raise ValueError('Edit prompt cannot be empty')
        return v.strip()

    @validator('user_id')
    def validate_user_id(cls, v):
        if v <= 0:
            raise ValueError('User ID must be a positive integer')
        return v

    @validator('other_user_id')
    def validate_other_user_id(cls, v):
        if v <= 0:
            raise ValueError('Other user ID must be a positive integer')
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "original_message": "Hey, how are you doing?",
                "edit_prompt": "Make it more engaging and ask about their interests",
                "user_id": 1,
                "other_user_id": 2
            }
        }


class MessageEditResponse(BaseModel):
    edited_message: str = Field(..., description="The edited message")
    original_message: str = Field(..., description="The original message that was edited")

    class Config:
        json_schema_extra = {
            "example": {
                "edited_message": "Hey! How are you doing? I noticed you love hiking - what's your favorite trail?",
                "original_message": "Hey, how are you doing?"
            }
        }
