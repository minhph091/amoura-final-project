# app/db/base.py
# Import all the models, so that Base has them before being
# imported by Alembic
from app.db.models import Base
from app.db.models import (
    Role, User, BodyType, Orientation, JobIndustry,
    DrinkStatus, SmokeStatus, EducationLevel, Pet, Interest, Language,
    Profile, Location, UserPet, UserInterest, UserLanguage,
    ChatRoom, Message, Swipe, Match
)