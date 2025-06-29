# app/db/models.py - Updated to match backend database schema
from sqlalchemy import (Column, Integer, String, Date, Boolean, Text, ForeignKey,
                        DECIMAL, TIMESTAMP, BigInteger, UniqueConstraint)
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func

Base = declarative_base()

class Role(Base):
    __tablename__ = "roles"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    description = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    users = relationship("User", back_populates="role")

class User(Base):
    __tablename__ = "users"
    id = Column(BigInteger, primary_key=True, index=True)
    username = Column(String(255), unique=True, index=True)
    password_hash = Column(String(255))
    email = Column(String(255), unique=True, index=True)
    phone_number = Column(String(50), unique=True, index=True)
    first_name = Column(String(255))
    last_name = Column(String(255))
    role_id = Column(BigInteger, ForeignKey("roles.id"))
    status = Column(String(20))  # 'active', 'inactive', 'suspend'
    last_login = Column(TIMESTAMP(timezone=False))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())
    refresh_token = Column(String(255))
    refresh_token_expiry_date = Column(TIMESTAMP(timezone=False))

    role = relationship("Role", back_populates="users")
    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    location = relationship("Location", back_populates="user", uselist=False, cascade="all, delete-orphan")
    pets = relationship("Pet", secondary="users_pets", back_populates="users")
    interests = relationship("Interest", secondary="users_interests", back_populates="users")
    languages = relationship("Language", secondary="users_languages", back_populates="users")

class BodyType(Base):
    __tablename__ = "body_types"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    profiles = relationship("Profile", back_populates="body_type")

class Orientation(Base):
    __tablename__ = "orientations"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    description = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    profiles = relationship("Profile", back_populates="orientation")

class JobIndustry(Base):
    __tablename__ = "job_industries"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    profiles = relationship("Profile", back_populates="job_industry")

class DrinkStatus(Base):
    __tablename__ = "drink_statuses"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    profiles = relationship("Profile", back_populates="drink_status")

class SmokeStatus(Base):
    __tablename__ = "smoke_statuses"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    profiles = relationship("Profile", back_populates="smoke_status")

class EducationLevel(Base):
    __tablename__ = "education_levels"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    profiles = relationship("Profile", back_populates="education_level")

class Pet(Base):
    __tablename__ = "pets"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255), unique=True)

    users = relationship("User", secondary="users_pets", back_populates="pets")

class Interest(Base):
    __tablename__ = "interests"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255), unique=True)

    users = relationship("User", secondary="users_interests", back_populates="interests")

class Language(Base):
    __tablename__ = "languages"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255), unique=True)

    users = relationship("User", secondary="users_languages", back_populates="languages")

class Profile(Base):
    __tablename__ = "profiles"
    user_id = Column(BigInteger, ForeignKey("users.id"), primary_key=True)
    date_of_birth = Column(Date)
    height = Column(Integer)
    body_type_id = Column(BigInteger, ForeignKey("body_types.id"))
    sex = Column(String(10))  # 'male', 'female', 'non-binary', 'prefer not to say'
    orientation_id = Column(BigInteger, ForeignKey("orientations.id"))
    job_industry_id = Column(BigInteger, ForeignKey("job_industries.id"))
    drink_status_id = Column(BigInteger, ForeignKey("drink_statuses.id"))
    smoke_status_id = Column(BigInteger, ForeignKey("smoke_statuses.id"))
    interested_in_new_language = Column(Boolean)
    education_level_id = Column(BigInteger, ForeignKey("education_levels.id"))
    drop_out = Column(Boolean)
    location_preference = Column(Integer)
    bio = Column(Text)

    user = relationship("User", back_populates="profile")
    body_type = relationship("BodyType", back_populates="profiles")
    orientation = relationship("Orientation", back_populates="profiles")
    job_industry = relationship("JobIndustry", back_populates="profiles")
    drink_status = relationship("DrinkStatus", back_populates="profiles")
    smoke_status = relationship("SmokeStatus", back_populates="profiles")
    education_level = relationship("EducationLevel", back_populates="profiles")

class Location(Base):
    __tablename__ = "locations"
    user_id = Column(BigInteger, ForeignKey("users.id"), primary_key=True)
    latitudes = Column(DECIMAL(9, 6))
    longitudes = Column(DECIMAL(9, 6))
    country = Column(String(255))
    state = Column(String(255))
    city = Column(String(255))
    version = Column(BigInteger, default=0)
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

    user = relationship("User", back_populates="location")

# --- Association Tables ---
class UserPet(Base):
    __tablename__ = "users_pets"
    user_id = Column(BigInteger, ForeignKey("users.id"), primary_key=True)
    pet_id = Column(BigInteger, ForeignKey("pets.id"), primary_key=True)
    __table_args__ = (UniqueConstraint('user_id', 'pet_id', name='uq_user_pet'),)

class UserInterest(Base):
    __tablename__ = "users_interests"
    user_id = Column(BigInteger, ForeignKey("users.id"), primary_key=True)
    interest_id = Column(BigInteger, ForeignKey("interests.id"), primary_key=True)
    __table_args__ = (UniqueConstraint('user_id', 'interest_id', name='uq_user_interest'),)

class UserLanguage(Base):
    __tablename__ = "users_languages"
    user_id = Column(BigInteger, ForeignKey("users.id"), primary_key=True)
    language_id = Column(BigInteger, ForeignKey("languages.id"), primary_key=True)
    __table_args__ = (UniqueConstraint('user_id', 'language_id', name='uq_user_language'),)

# Models cần thiết cho Chat Rooms (backend database có chat_rooms)
class ChatRoom(Base):
    __tablename__ = "chat_rooms"
    id = Column(BigInteger, primary_key=True, index=True)
    user1_id = Column(BigInteger, ForeignKey("users.id"))
    user2_id = Column(BigInteger, ForeignKey("users.id"))
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())

# Message model để khớp với backend database
class Message(Base):
    __tablename__ = "messages"
    id = Column(BigInteger, primary_key=True, index=True)
    chat_room_id = Column(BigInteger, ForeignKey("chat_rooms.id"))
    sender_id = Column(BigInteger, ForeignKey("users.id"))
    content = Column(Text)
    message_type = Column(String(20), default='TEXT')
    is_read = Column(Boolean, default=False)
    read_at = Column(TIMESTAMP(timezone=False))
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())
    image_url = Column(String(512))
    image_uploader_id = Column(BigInteger)
    recalled = Column(Boolean, default=False)
    recalled_at = Column(TIMESTAMP(timezone=False))

    chat_room = relationship("ChatRoom")
    sender = relationship("User", foreign_keys=[sender_id], backref="sent_messages")

class Swipe(Base):
    __tablename__ = "swipes"
    id = Column(BigInteger, primary_key=True, index=True)
    initiator = Column(BigInteger, ForeignKey("users.id"))
    target_user = Column(BigInteger, ForeignKey("users.id"))
    is_like = Column(Boolean)
    created_at = Column(TIMESTAMP(timezone=False), server_default=func.now())

    initiator_user = relationship("User", foreign_keys=[initiator], backref="initiated_swipes")
    target = relationship("User", foreign_keys=[target_user], backref="received_swipes")

class Match(Base):
    __tablename__ = "matches"
    id = Column(BigInteger, primary_key=True, index=True)
    user1_id = Column(BigInteger, ForeignKey("users.id"))
    user2_id = Column(BigInteger, ForeignKey("users.id"))
    status = Column(String(20))  # 'active', 'unmatched'
    matched_at = Column(TIMESTAMP(timezone=False), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), onupdate=func.now())
    __table_args__ = (UniqueConstraint('user1_id', 'user2_id', name='uq_match_pair'),)

    user1 = relationship("User", foreign_keys=[user1_id], backref="matches_as_user1")
    user2 = relationship("User", foreign_keys=[user2_id], backref="matches_as_user2")
