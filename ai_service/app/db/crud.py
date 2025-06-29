# app/db/crud.py
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import select
from typing import List, Optional, Tuple, Any, Dict

from . import models


# --- User CRUD ---
def get_user_by_id(db: Session, user_id: int) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.id == user_id).first()


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


# --- Swipe CRUD ---
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


# --- Message CRUD ---
def get_message_history(db: Session, user_id: int, other_user_id: int, limit: int = 50) -> List[models.Message]:
    """
    Get the message history between two users via chat_rooms, ordered by creation time.

    Args:
        db: Database session
        user_id: ID of the first user
        other_user_id: ID of the second user
        limit: Maximum number of messages to return

    Returns:
        List of Message objects representing the conversation history
    """
    # First, find the chat room between the two users
    chat_room = db.query(models.ChatRoom).filter(
        (
            (models.ChatRoom.user1_id == user_id) & 
            (models.ChatRoom.user2_id == other_user_id)
        ) | 
        (
            (models.ChatRoom.user1_id == other_user_id) & 
            (models.ChatRoom.user2_id == user_id)
        )
    ).first()

    # If no chat room exists, return empty list
    if not chat_room:
        return []

    # Query messages for this chat room - get latest messages first, then reverse for chronological order
    messages = db.query(models.Message).filter(
        models.Message.chat_room_id == chat_room.id
    ).order_by(models.Message.created_at.desc()).limit(limit).all()

    # Reverse to get chronological order (oldest first) for AI context
    return list(reversed(messages))


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


def get_backup_recommendations(
    db: Session, 
    current_user_id: int, 
    limit: int = 10
) -> List[int]:
    """
    Lấy danh sách ID người dùng backup dựa trên giới tính và orientation.
    
    Args:
        db: Database session
        current_user_id: ID của người dùng hiện tại
        limit: Số lượng recommendations tối đa
        
    Returns:
        List of user IDs
    """
    # Lấy thông tin người dùng hiện tại
    current_user_data = get_user_profile_raw_data(db, current_user_id)
    if not current_user_data:
        return []
    
    user, profile, location, pet_names, interest_names, language_names, body_type_name, orientation_name, job_industry_name, drink_status_name, smoke_status_name, education_level_name = current_user_data
    
    if not profile or not profile.sex or not orientation_name:
        return []
    
    # Lấy danh sách user đã swipe
    swiped_user_ids = select(models.Swipe.target_user).where(
        models.Swipe.initiator == current_user_id
    )
    
    # Query để lấy người dùng phù hợp về giới tính và orientation
    # Sử dụng logic đồng nhất với ML preprocessing và dữ liệu thực tế
    compatible_sex = None
    compatible_orientation = None
    
    sex_lower = profile.sex.lower()
    orientation_lower = orientation_name.lower()
    
    if orientation_lower == "straight":
        if sex_lower == "male":
            compatible_sex = "female"
            compatible_orientation = "straight"
        elif sex_lower == "female":
            compatible_sex = "male"
            compatible_orientation = "straight"
        elif sex_lower == "non-binary":
            # Non-binary straight có thể match với male/female straight
            compatible_sex = None  # Không filter theo sex
            compatible_orientation = "straight"
    elif orientation_lower == "homosexual":
        # Homosexual tìm cùng giới tính
        compatible_sex = sex_lower  # Cùng giới tính
        compatible_orientation = "homosexual"
    elif orientation_lower == "bisexual":
        # Bisexual có thể match với tất cả
        compatible_sex = None
        compatible_orientation = None
    elif orientation_lower == "prefer not to say":
        # Prefer not to say chỉ match với bisexual hoặc prefer not to say
        compatible_sex = None
        compatible_orientation = None  # Sẽ filter sau
    else:
        # Trường hợp khác, không filter
        compatible_sex = None
        compatible_orientation = None
    
    # Query cơ bản
    query = db.query(models.User.id).join(models.Profile).join(models.Orientation).filter(
        models.User.id != current_user_id,
        models.User.status == "active",
        ~models.User.id.in_(swiped_user_ids)
    )
    
    # Thêm filter theo giới tính nếu có
    if compatible_sex:
        query = query.filter(models.Profile.sex == compatible_sex)
    
    # Thêm filter theo orientation nếu có
    if compatible_orientation:
        query = query.filter(models.Orientation.name == compatible_orientation)
    elif orientation_lower == "prefer not to say":
        # Prefer not to say chỉ match với bisexual hoặc prefer not to say
        query = query.filter(
            models.Orientation.name.in_(["bisexual", "prefer not to say"])
        )
    
    # Lấy kết quả
    user_ids = query.limit(limit).all()
    
    return [uid[0] for uid in user_ids]
