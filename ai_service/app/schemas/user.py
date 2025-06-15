# app/schemas/user.py
from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional, List
from datetime import date, datetime  # Thêm datetime cho created_at, updated_at


# --- Role Schemas ---
class RoleBase(BaseModel):
    name: str
    description: Optional[str] = None


class RoleCreate(RoleBase):
    pass  # Không cần thêm trường gì khi tạo, id tự tăng


class RoleResponse(RoleBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# --- User Schemas ---
class UserBase(BaseModel):
    username: str
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None


class UserCreate(UserBase):
    password: str
    role_id: int  # Hoặc str nếu bạn dùng tên role để lookup


class UserInDBBase(UserBase):
    id: int
    role_id: int
    # Thêm role để có thể trả về thông tin role cùng user
    role: Optional[RoleResponse] = None  # Quan trọng: sử dụng RoleResponse đã định nghĩa ở trên

    class Config:
        from_attributes = True


class UserResponse(UserInDBBase):
    pass


# --- Profile Schemas ---
class ProfileBase(BaseModel):
    date_of_birth: Optional[date] = None
    height: Optional[int] = None
    sex: Optional[str] = None
    interested_in_new_language: Optional[bool] = None
    drop_out: Optional[bool] = None
    location_preference: Optional[int] = None
    bio: Optional[str] = None


class ProfileCreate(ProfileBase):
    body_type_id: Optional[int] = None
    orientation_id: Optional[int] = None
    job_industry_id: Optional[int] = None
    drink_status_id: Optional[int] = None
    smoke_status_id: Optional[int] = None
    education_level_id: Optional[int] = None


class ProfileUpdate(ProfileCreate):
    pass


class ProfileResponse(ProfileBase):
    user_id: int
    body_type_name: Optional[str] = None
    orientation_name: Optional[str] = None
    job_industry_name: Optional[str] = None
    drink_status_name: Optional[str] = None
    smoke_status_name: Optional[str] = None
    education_level_name: Optional[str] = None
    age: Optional[int] = None

    class Config:
        from_attributes = True


# --- Location Schemas ---
class LocationBase(BaseModel):
    latitudes: Optional[float] = None
    longitudes: Optional[float] = None
    country: Optional[str] = None
    state: Optional[str] = None
    city: Optional[str] = None


class LocationCreate(LocationBase):
    pass


class LocationUpdate(LocationCreate):
    pass


class LocationResponse(LocationBase):
    user_id: int

    class Config:
        from_attributes = True


# --- Schemas for multi-valued attributes for ProfileDetail ---
class PetResponse(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True


class InterestResponse(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True


class LanguageResponse(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True


# --- Combined Profile Detail for ML input transformation ---
class ProfileDetailForML(ProfileResponse):
    pets: List[str] = []
    interests: List[str] = []
    languages: List[str] = []
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    class Config:
        from_attributes = True