# app/db/base.py
# Import all the models, so that Base has them before being
# imported by Alembic
from app.db.models import Base # noqa
from app.db.models import ( # noqa
    Role, User, BodyType, Orientation, JobIndustry,
    DrinkStatus, SmokeStatus, EducationLevel, Pet, Interest, Language,
    Profile, Location, UserPet, UserInterest, UserLanguage
)