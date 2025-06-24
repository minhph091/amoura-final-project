from pydantic import BaseModel, Field, validator


class MessageEditRequest(BaseModel):
    original_message: str = Field(..., min_length=1, max_length=2000, description="The original message to edit")
    edit_prompt: str = Field(..., min_length=1, max_length=500, description="User's instructions for editing the message")
    sender_id: int = Field(..., description="ID của người gửi (người yêu cầu chỉnh sửa)")
    receiver_id: int = Field(..., description="ID của người nhận (người còn lại trong cuộc trò chuyện)")

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

    @validator('sender_id')
    def validate_sender_id(cls, v):
        if v <= 0:
            raise ValueError('Sender ID must be a positive integer')
        return v

    @validator('receiver_id')
    def validate_receiver_id(cls, v):
        if v <= 0:
            raise ValueError('Receiver ID must be a positive integer')
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "original_message": "Hey, how are you doing?",
                "edit_prompt": "Make it more engaging and ask about their interests",
                "sender_id": 1,
                "receiver_id": 2
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
