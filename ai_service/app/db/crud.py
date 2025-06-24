# app/db/crud.py
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional, Tuple, Any, Dict

from . import models  # models.py đã định nghĩa ở Giai đoạn 2
from app import schemas  # schemas.py đã định nghĩa ở Giai đoạn 2


# --- User CRUD ---
def get_user_by_id(db: Session, user_id: int) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_user_by_username(db: Session, username: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.username == username).first()


def get_users(db: Session, skip: int = 0, limit: int = 100) -> List[models.User]:
    return db.query(models.User).offset(skip).limit(limit).all()


def get_user_role_name(db: Session, user_id: int) -> Optional[str]:
    user = db.query(models.User).options(joinedload(models.User.role)).filter(models.User.id == user_id).first()
    if user and user.role:
        return user.role.name
    return None


# --- Profile & Related CRUD ---
def get_user_profile_raw_data(db: Session, user_id: int) -> Optional[Tuple[
    models.User,
    Optional[models.Profile],
    Optional[models.Location],
    List[str],  # pet names
    List[str],  # interest names
    List[str],  # language names
    Optional[str],  # body_type_name
    Optional[str],  # orientation_name
    Optional[str],  # job_industry_name
    Optional[str],  # drink_status_name
    Optional[str],  # smoke_status_name
    Optional[str]  # education_level_name
]]:
    """
    Lấy toàn bộ thông tin thô của user cần thiết cho ML model,
    bao gồm cả việc join và tổng hợp từ các bảng liên quan.
    Trả về một tuple chứa các đối tượng model hoặc list of strings.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None

    profile = db.query(models.Profile).options(
        joinedload(models.Profile.body_type),
        joinedload(models.Profile.orientation),
        joinedload(models.Profile.job_industry),
        joinedload(models.Profile.drink_status),
        joinedload(models.Profile.smoke_status),
        joinedload(models.Profile.education_level)
    ).filter(models.Profile.user_id == user_id).first()

    location = db.query(models.Location).filter(models.Location.user_id == user_id).first()

    pets_q = db.query(models.Pet.name).join(models.UserPet).filter(models.UserPet.user_id == user_id).all()
    pet_names = [p[0] for p in pets_q]

    interests_q = db.query(models.Interest.name).join(models.UserInterest).filter(
        models.UserInterest.user_id == user_id).all()
    interest_names = [i[0] for i in interests_q]

    languages_q = db.query(models.Language.name).join(models.UserLanguage).filter(
        models.UserLanguage.user_id == user_id).all()
    language_names = [l[0] for l in languages_q]

    # Thêm error handling cho relationship access
    try:
        body_type_name = profile.body_type.name if profile and profile.body_type else None
        orientation_name = profile.orientation.name if profile and profile.orientation else None
        job_industry_name = profile.job_industry.name if profile and profile.job_industry else None
        drink_status_name = profile.drink_status.name if profile and profile.drink_status else None
        smoke_status_name = profile.smoke_status.name if profile and profile.smoke_status else None
        education_level_name = profile.education_level.name if profile and profile.education_level else None
    except Exception as e:
        print(f"Error accessing profile relationships for user {user_id}: {e}")
        # Fallback values
        body_type_name = None
        orientation_name = None
        job_industry_name = None
        drink_status_name = None
        smoke_status_name = None
        education_level_name = None
    return (
        user,
        profile,
        location,
        pet_names,
        interest_names,
        language_names,
        body_type_name,
        orientation_name,
        job_industry_name,
        drink_status_name,
        smoke_status_name,
        education_level_name
    )


def get_all_other_user_ids_with_role(db: Session, current_user_id: int, role_name: str = "USER") -> List[int]:
    """
    Lấy ID của tất cả user khác có vai trò (role_name) cụ thể.
    """
    user_ids = db.query(models.User.id). \
        join(models.Role). \
        filter(models.Role.name == role_name, models.User.id != current_user_id). \
        all()
    return [uid[0] for uid in user_ids]


# --- Helper functions for reference tables (body_type, orientation, etc.) ---
# Bạn có thể thêm các hàm CRUD cho các bảng tham chiếu này nếu cần
# Ví dụ:
def get_body_type_by_name(db: Session, name: str) -> Optional[models.BodyType]:
    return db.query(models.BodyType).filter(models.BodyType.name == name).first()


# ... các hàm tương tự cho Orientation, JobIndustry, DrinkStatus, SmokeStatus, EducationLevel
# ... cũng như Pet, Interest, Language nếu bạn cần tạo mới chúng khi user nhập.

# --- Role CRUD (Ví dụ) ---
def get_role_by_name(db: Session, name: str) -> Optional[models.Role]:
    return db.query(models.Role).filter(models.Role.name == name).first()


def has_user_swiped(db: Session, initiator_id: int, target_user_id: int) -> bool:
    """
    Check if a user has already swiped (liked or disliked) another user.

    Args:
        db: Database session
        initiator_id: ID of the user who initiated the swipe
        target_user_id: ID of the user who was swiped on

    Returns:
        True if the user has already swiped on the target user, False otherwise
    """
    swipe = db.query(models.Swipe).filter(
        models.Swipe.initiator == initiator_id,
        models.Swipe.target_user == target_user_id
    ).first()

    return swipe is not None


def get_non_swiped_user_ids_with_role(db: Session, current_user_id: int, role_name: str = "USER", limit: int = 100) -> \
List[int]:
    """
    Get IDs of users with a specific role that the current user hasn't swiped on yet.

    Args:
        db: Database session
        current_user_id: ID of the current user
        role_name: Role name to filter users by
        limit: Maximum number of user IDs to return

    Returns:
        List of user IDs
    """
    # Subquery to get all user IDs that the current user has swiped on

    swiped_users_query = db.query(models.Swipe.target_user).filter(
        models.Swipe.initiator == current_user_id
    )

    # Query to get all other users with the specified role that haven't been swiped on

    user_ids = db.query(models.User.id). \
        join(models.Role). \
        filter(
        models.Role.name == role_name,
        models.User.id != current_user_id,
        ~models.User.id.in_(swiped_users_query)
    ). \
        limit(limit). \
        all()

    return [uid[0] for uid in user_ids]


def get_message_history(db: Session, user_id: int, other_user_id: int, limit: int = 50) -> List[models.Message]:
    """
    Get the message history between two users, ordered by creation time.

    Args:
        db: Database session
        user_id: ID of the first user
        other_user_id: ID of the second user
        limit: Maximum number of messages to return

    Returns:
        List of Message objects representing the conversation history
    """
    # Query messages where user_id is sender and other_user_id is receiver
    # OR user_id is receiver and other_user_id is sender
    messages = db.query(models.Message).filter(
        (
            (models.Message.sender_id == user_id) & 
            (models.Message.receiver_id == other_user_id)
        ) | 
        (
            (models.Message.sender_id == other_user_id) & 
            (models.Message.receiver_id == user_id)
        )
    ).order_by(models.Message.created_at).limit(limit).all()

    return messages


def format_messages_for_ai(messages: List[models.Message], current_user_id: int) -> List[Dict]:
    """
    Format a list of Message objects into a format suitable for AI processing.

    Args:
        messages: List of Message objects
        current_user_id: ID of the current user to determine message roles

    Returns:
        List of dictionaries with 'role' and 'content' keys
    """
    formatted_messages = []

    for message in messages:
        # Determine role based on who sent the message
        # If current user sent the message, it's "user"
        # If someone else sent the message, it's "assistant"
        role = "user" if message.sender_id == current_user_id else "assistant"
        formatted_messages.append({
            "role": role,
            "content": message.content
        })

    return formatted_messages
