# app/ml/preprocessing.py
"""
Data preprocessing utilities for machine learning pipeline.

This module provides comprehensive data preprocessing functions for the Amoura AI service,
including text processing, feature engineering, and data transformation utilities.
It handles user profile data, geographic calculations, and compatibility assessments
for the matching algorithm.
"""

import ssl
import nltk
import pandas as pd
import numpy as np
import re
from datetime import datetime
import joblib
import os

from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics.pairwise import cosine_similarity

from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize
from unidecode import unidecode
from geopy.distance import geodesic

# Configuration and constants
from app.core.config import get_settings
settings = get_settings()
MODELS_DIR = str(settings.models_path)

# NLTK setup for text processing
# SSL context configuration for NLTK downloads
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    pass
else:
    ssl._create_default_https_context = _create_unverified_https_context

# Initialize NLTK components for text processing
try:
    stop_words_en = set(stopwords.words('english'))
    lemmatizer = WordNetLemmatizer()
    # Download required NLTK data for text processing
    nltk.download('punkt', quiet=True)
    nltk.download('stopwords', quiet=True)
    nltk.download('wordnet', quiet=True)
except LookupError:
    print("NLTK data not found. Please download them (punkt, stopwords, wordnet).")
    # Fallback initialization if NLTK data is unavailable
    stop_words_en = set()
    lemmatizer = None


def calculate_age(born_str: str) -> int | float:
    """
    Calculate age from date of birth string.
    
    Args:
        born_str: Date of birth in 'YYYY-MM-DD' format
        
    Returns:
        Age in years as integer, or NaN if parsing fails
        
    Example:
        >>> calculate_age('1990-01-01')
        34
    """
    try:
        born = datetime.strptime(str(born_str), '%Y-%m-%d')
        today = datetime.today()
        age = today.year - born.year - ((today.month, today.day) < (born.month, born.day))
        return age
    except (ValueError, TypeError):
        return np.nan


def preprocess_text(text: str | None, use_lemmatization: bool = True) -> str:
    """
    Preprocess text data for natural language processing.
    
    Performs comprehensive text cleaning including:
    - Unicode normalization and lowercase conversion
    - Punctuation and number removal
    - Stop word removal
    - Tokenization and lemmatization (optional)
    
    Args:
        text: Input text string to preprocess
        use_lemmatization: Whether to apply lemmatization to tokens
        
    Returns:
        Preprocessed text string
        
    Example:
        >>> preprocess_text("Hello, World! 123")
        'hello world'
    """
    if pd.isnull(text) or not lemmatizer:
        return ""
    
    # Normalize text: remove accents, convert to lowercase
    text_normalized = unidecode(str(text).lower())
    
    # Remove punctuation and numbers
    text_normalized = re.sub(r'[^\w\s]', '', text_normalized)
    text_normalized = re.sub(r'\d+', '', text_normalized)
    
    # Tokenize and filter
    tokens = word_tokenize(text_normalized)
    tokens = [word for word in tokens if word not in stop_words_en and len(word) > 1]
    
    # Apply lemmatization if requested
    if use_lemmatization:
        tokens = [lemmatizer.lemmatize(word) for word in tokens]
    
    return " ".join(tokens)


def _apply_top_n_categorical_encoding_single(value: str | None, top_categories: list, prefix: str) -> pd.Series:
    """
    Apply top-N categorical encoding for a single value.
    
    Creates binary features for each top category and an 'other' category.
    This function is used for encoding categorical variables like body type,
    orientation, job industry, etc.
    
    Args:
        value: The categorical value to encode
        top_categories: List of top categories to create features for
        prefix: Prefix for the generated feature names
        
    Returns:
        Pandas Series with binary encoded features
        
    Example:
        >>> _apply_top_n_categorical_encoding_single('slim', ['slim', 'average'], 'body_type')
        body_type_slim      1
        body_type_average   0
        body_type_other     0
    """
    encoded_features = {}
    value_normalized = str(value).strip().lower() if pd.notnull(value) else 'unknown'

    # Create binary features for each top category
    for category in top_categories:
        clean_category = unidecode(str(category)).lower().replace(' ', '_').replace('/', '_').replace('(', '').replace(
            ')', '').replace('.', '')
        col_name = f"{prefix}_{clean_category}"
        encoded_features[col_name] = 1 if value_normalized == str(category).strip().lower() else 0

    # Create 'other' category for values not in top categories
    clean_categories_lower = [str(cat).strip().lower() for cat in top_categories]
    col_name_other = f"{prefix}_other"
    encoded_features[col_name_other] = 1 if value_normalized not in clean_categories_lower else 0

    return pd.Series(encoded_features)


def _apply_multivalue_binary_features_single(value_str: str | None, top_items: list, separator: str,
                                             prefix: str) -> pd.Series:
    """
    Create binary features for multi-value string data.
    
    Converts a comma-separated string of values into binary features
    for each top item. Used for encoding interests, languages, pets, etc.
    
    Args:
        value_str: Comma-separated string of values
        top_items: List of top items to create features for
        separator: Character used to separate values in the string
        prefix: Prefix for the generated feature names
        
    Returns:
        Pandas Series with binary encoded features
        
    Example:
        >>> _apply_multivalue_binary_features_single('Hiking-Reading', ['Hiking', 'Music'], '-', 'interests')
        interests_hiking   1
        interests_music    0
        interests_other    1
    """
    binary_features = {}
    items_in_value = set()
    
    if pd.notnull(value_str):
        items_in_value = set(
            unidecode(item.strip().lower()) for item in str(value_str).split(separator) if item.strip())

    for item in top_items:
        clean_item = re.sub(r'\W+', '_', item)
        new_col_name = f"{prefix}_{clean_item}"
        binary_features[new_col_name] = 1 if item in items_in_value else 0
    return pd.Series(binary_features)


def haversine_distance(lat1: float | None, lon1: float | None, lat2: float | None, lon2: float | None) -> float:
    """
    Calculate haversine distance between two geographic coordinates.
    
    Uses the geodesic distance calculation to determine the great-circle
    distance between two points on Earth's surface.
    
    Args:
        lat1: Latitude of first point
        lon1: Longitude of first point
        lat2: Latitude of second point
        lon2: Longitude of second point
        
    Returns:
        Distance in kilometers, or 10000.0 for invalid coordinates
        
    Example:
        >>> haversine_distance(21.0285, 105.8542, 10.8231, 106.6297)
        1150.23
    """
    if pd.isna(lat1) or pd.isna(lon1) or pd.isna(lat2) or pd.isna(lon2):
        return 10000.0  # Default large distance for missing coordinates
    return geodesic((lat1, lon1), (lat2, lon2)).km


def _is_interested(sex_a: str | None, orientation_a: str | None, sex_b: str | None) -> bool:
    """
    Determine if person A is interested in person B based on sexual orientation.
    
    Evaluates compatibility based on sexual orientation rules:
    - Straight: interested in opposite sex
    - Homosexual: interested in same sex
    - Bisexual: interested in all sexes
    - Prefer not to say: compatible with bisexual or prefer not to say
    
    Args:
        sex_a: Sex of person A
        orientation_a: Sexual orientation of person A
        sex_b: Sex of person B
        
    Returns:
        True if person A is interested in person B, False otherwise
    """
    if None in [sex_a, orientation_a, sex_b]:
        return False  # Handle missing values

    sex_a_lower = sex_a.lower()
    orientation_a_lower = orientation_a.lower()
    sex_b_lower = sex_b.lower()

    if orientation_a_lower == 'straight':
        # Straight orientation: interested in opposite sex
        if (sex_a_lower == 'male' and sex_b_lower == 'female') or \
                (sex_a_lower == 'female' and sex_b_lower == 'male'):
            return True
        # Non-binary can be interested in male or female
        if sex_a_lower == 'non-binary' and sex_b_lower in ['male', 'female']:
            return True
        return False
    elif orientation_a_lower == 'homosexual':
        # Homosexual: interested in same sex
        return sex_a_lower == sex_b_lower
    elif orientation_a_lower == 'bisexual':
        # Bisexual: interested in all sexes
        return True
    elif orientation_a_lower == 'prefer not to say':
        # Prefer not to say: compatible with bisexual or prefer not to say
        return orientation_a_lower in ['bisexual', 'prefer not to say']
    return False


def orientation_compatibility(sex1: str | None, orientation1: str | None, sex2: str | None,
                              orientation2: str | None) -> bool:
    """
    Check mutual compatibility between two people based on their orientations.
    
    Two people are compatible if both are interested in each other
    according to their respective sexual orientations. Special handling
    is provided for 'prefer not to say' cases.
    
    Args:
        sex1: Sex of first person
        orientation1: Sexual orientation of first person
        sex2: Sex of second person
        orientation2: Sexual orientation of second person
        
    Returns:
        True if both people are mutually interested, False otherwise
    """
    if None in [sex1, orientation1, sex2, orientation2]:
        return False  # Handle missing values

    # Special handling for 'prefer not to say' cases
    if any(o.lower() == 'prefer not to say' for o in [sex1, sex2, orientation1, orientation2] if o):
        # Compatible if both are bisexual or prefer not to say orientation
        return (orientation1.lower() in ['bisexual', 'prefer not to say'] and
                orientation2.lower() in ['bisexual', 'prefer not to say'])

    # Check mutual interest
    user1_likes_user2 = _is_interested(sex1, orientation1, sex2)
    user2_likes_user1 = _is_interested(sex2, orientation2, sex1)
    return user1_likes_user2 and user2_likes_user1


def jaccard_similarity(list1_str: str | None, list2_str: str | None, separator: str = '-') -> float:
    """
    Calculate Jaccard similarity between two lists represented as strings.
    
    Jaccard similarity measures the overlap between two sets as the size
    of their intersection divided by the size of their union.
    
    Args:
        list1_str: First list as separator-delimited string
        list2_str: Second list as separator-delimited string
        separator: Character used to separate items in the strings
        
    Returns:
        Jaccard similarity score between 0.0 and 1.0
        
    Example:
        >>> jaccard_similarity('Hiking-Reading-Music', 'Hiking-Traveling')
        0.25
    """
    if pd.isna(list1_str) or pd.isna(list2_str):
        return 0.0
    
    # Convert strings to sets of lowercase items
    set1 = set(item.strip().lower() for item in str(list1_str).split(separator) if item.strip())
    set2 = set(item.strip().lower() for item in str(list2_str).split(separator) if item.strip())
    
    # Handle empty sets
    if not set1 and not set2:
        return 0.0  # Return 0.0 for empty sets
    
    # Calculate Jaccard similarity
    intersection_size = len(set1.intersection(set2))
    union_size = len(set1.union(set2))
    return intersection_size / union_size if union_size != 0 else 0.0


def create_user_feature_vector(user_raw_data: dict) -> pd.Series:
    """
    Create a feature vector for a single user from raw data.
    
    This function transforms raw user profile data into a standardized
    feature vector that can be used by the machine learning model.
    The process includes scaling numerical features, encoding categorical
    variables, and processing text-based features.
    
    Args:
        user_raw_data: Dictionary containing user profile information.
                      Should include fields like age, height, sex, orientation,
                      body_type, drink, smoke, interests, languages, pets,
                      education_level, job_industry, and bio.
    
    Returns:
        Pandas Series containing the user's feature vector
        
    Example:
        >>> user_data = {
        ...     'age': 25, 'height': 170, 'sex': 'male',
        ...     'orientation': 'straight', 'interests': 'Hiking-Reading'
        ... }
        >>> features = create_user_feature_vector(user_data)
    """
    user_features_dict = {}  # Dictionary to store all features before converting to Series

    # 1. Age and Height Scaling
    age = user_raw_data.get('age', np.nan)
    height = user_raw_data.get('height', np.nan)

    # Load pre-trained scalers for age and height
    scaler_age = joblib.load(os.path.join(MODELS_DIR, "scaler_age.joblib"))
    scaler_height = joblib.load(os.path.join(MODELS_DIR, "scaler_height.joblib"))

    # Fallback values for missing data
    age_median_fallback = 25
    height_median_fallback = 68

    # Create single-row DataFrames for scaling
    age_df_to_transform = pd.DataFrame({'age': [age if pd.notnull(age) else age_median_fallback]})
    height_df_to_transform = pd.DataFrame({'height': [height if pd.notnull(height) else height_median_fallback]})

    # Apply scaling and store results
    user_features_dict['age_scaled'] = scaler_age.transform(age_df_to_transform)[0, 0]
    user_features_dict['height_scaled'] = scaler_height.transform(height_df_to_transform)[0, 0]

    # 2. Categorical Features (One-Hot Encoded)
    onehot_encoder_categorical = joblib.load(os.path.join(MODELS_DIR, "onehot_encoder_categorical.joblib"))
    categorical_cols_onehot = ['sex', 'orientation', 'body_type', 'drink', 'smoke']

    # Default values for missing categorical data
    modes = {
        'sex': 'male', 'orientation': 'straight', 'body_type': 'average',
        'drink': 'socially', 'smoke': 'no'
    }

    # Extract categorical values with fallbacks
    user_cat_values_dict = {col: user_raw_data.get(col, modes.get(col)) for col in categorical_cols_onehot}
    # Tạo DataFrame một dòng với các cột đúng tên
    cat_df_to_transform = pd.DataFrame([user_cat_values_dict], columns=categorical_cols_onehot)

    encoded_cat_array = onehot_encoder_categorical.transform(cat_df_to_transform)

    # Lấy tên cột từ onehot_encoder (đã được fit với tên)
    onehot_feature_names = onehot_encoder_categorical.get_feature_names_out(categorical_cols_onehot)
    for i, col_name in enumerate(onehot_feature_names):
        user_features_dict[col_name] = encoded_cat_array[0, i]

    # 3. High-Cardinality Categorical (Job, Education)
    # Job
    top_n_job_categories = joblib.load(os.path.join(MODELS_DIR, "top_n_job_categories.joblib"))
    job_series = _apply_top_n_categorical_encoding_single(user_raw_data.get('job'), top_n_job_categories, 'job')
    user_features_dict.update(job_series.to_dict())

    # Education
    top_n_edu_categories = joblib.load(os.path.join(MODELS_DIR, "top_n_edu_categories.joblib"))
    edu_series = _apply_top_n_categorical_encoding_single(user_raw_data.get('education_level'), top_n_edu_categories,
                                                          'edu')
    user_features_dict.update(edu_series.to_dict())

    # 4. Binary Indicators
    user_features_dict['dropped_out_school'] = int(user_raw_data.get('dropped_out_school', 0) or 0)
    user_features_dict['interested_in_new_language'] = int(user_raw_data.get('interested_in_new_language', 0) or 0)

    # 5. Multi-value text features (Interests, Languages, Pets)
    # Interests
    top_interests_items = joblib.load(os.path.join(MODELS_DIR, "top_interests_items.joblib"))
    interests_series = _apply_multivalue_binary_features_single(user_raw_data.get('interests'), top_interests_items,
                                                                '-', 'interest')
    user_features_dict.update(interests_series.to_dict())

    # Languages
    top_languages_items = joblib.load(os.path.join(MODELS_DIR, "top_languages_items.joblib"))
    languages_series = _apply_multivalue_binary_features_single(user_raw_data.get('languages'), top_languages_items,
                                                                '-', 'lang')
    user_features_dict.update(languages_series.to_dict())

    # Pets
    top_pets_items = joblib.load(os.path.join(MODELS_DIR, "top_pets_items.joblib"))
    pets_series = _apply_multivalue_binary_features_single(user_raw_data.get('pets'), top_pets_items, '-', 'pet')
    user_features_dict.update(pets_series.to_dict())

    # 6. TF-IDF for Bio
    tfidf_vectorizer_bio = joblib.load(os.path.join(MODELS_DIR, "tfidf_vectorizer_bio.joblib"))
    processed_bio = preprocess_text(user_raw_data.get('bio'))
    bio_tfidf_matrix = tfidf_vectorizer_bio.transform([processed_bio])
    bio_tfidf_array = bio_tfidf_matrix.toarray()[0]

    # Lấy tên cột từ TfidfVectorizer (nếu được lưu và có thể truy cập)
    # Hoặc giả định tên cột là bio_tfidf_0, bio_tfidf_1, ...
    # Để an toàn, ta sẽ dùng cách đặt tên theo index nếu không có feature_names_out
    if hasattr(tfidf_vectorizer_bio, 'get_feature_names_out'):
        bio_feature_names = [f"bio_tfidf_{name.replace(' ', '_')}" for name in
                             tfidf_vectorizer_bio.get_feature_names_out()]
        # Giới hạn số lượng nếu cần, hoặc sử dụng tên cột theo index
        if len(bio_feature_names) == bio_tfidf_array.shape[0]:
            for i, col_name in enumerate(bio_feature_names):
                user_features_dict[col_name] = bio_tfidf_array[i]  # Sửa ở đây
        else:  # Fallback nếu tên không khớp hoặc max_features làm thay đổi số cột
            for i in range(bio_tfidf_array.shape[0]):
                user_features_dict[f"bio_tfidf_{i}"] = bio_tfidf_array[i]
    else:  # Fallback cho scikit-learn phiên bản cũ hơn
        for i in range(bio_tfidf_array.shape[0]):
            user_features_dict[f"bio_tfidf_{i}"] = bio_tfidf_array[i]

    # 7. Geographic Features
    # Location Preference
    loc_pref_scaler = joblib.load(os.path.join(MODELS_DIR, "location_preference_scaler.joblib"))
    loc_pref = user_raw_data.get('location_preference', -1)
    user_features_dict['loc_pref_is_everywhere'] = 1 if loc_pref == -1 else 0
    loc_pref_km = 0 if loc_pref == -1 else loc_pref

    # Tạo DataFrame một dòng, một cột để transform
    loc_pref_df_to_transform = pd.DataFrame({'location_preference_km': [loc_pref_km]})
    user_features_dict['location_preference_km_scaled'] = loc_pref_scaler.transform(loc_pref_df_to_transform)[0, 0]

    # Latitude/Longitude
    lat_scaler = joblib.load(os.path.join(MODELS_DIR, "latitude_scaler.joblib"))
    lon_scaler = joblib.load(os.path.join(MODELS_DIR, "longitude_scaler.joblib"))

    lat_median_fallback = 21.0
    lon_median_fallback = 105.8

    latitude = user_raw_data.get('latitude', lat_median_fallback)
    longitude = user_raw_data.get('longitude', lon_median_fallback)
    latitude = latitude if pd.notnull(latitude) else lat_median_fallback
    longitude = longitude if pd.notnull(longitude) else lon_median_fallback

    # Tạo DataFrame một dòng, một cột để transform
    lat_df_to_transform = pd.DataFrame({'latitude': [latitude]})
    lon_df_to_transform = pd.DataFrame({'longitude': [longitude]})

    user_features_dict['latitude_scaled'] = lat_scaler.transform(lat_df_to_transform)[0, 0]
    user_features_dict['longitude_scaled'] = lon_scaler.transform(lon_df_to_transform)[0, 0]

    # Đảm bảo thứ tự cột và đầy đủ các cột như trong user_features_final_columns.joblib
    user_features_final_columns = joblib.load(os.path.join(MODELS_DIR, "user_features_final_columns.joblib"))

    final_feature_vector_data = {}
    for col in user_features_final_columns:
        final_feature_vector_data[col] = user_features_dict.get(col, 0.0)  # Fallback là 0 nếu thiếu

    return pd.Series(final_feature_vector_data, index=user_features_final_columns)


# --- Hàm chính để tạo Pairwise Feature Vector ---
def create_pairwise_features_vector(
        user1_raw_data: dict, user1_feature_vector: pd.Series,
        user2_raw_data: dict, user2_feature_vector: pd.Series,
        pairwise_input_columns_list: list,  # Danh sách TẤT CẢ tên cột đầu vào cho model pairwise
        pairwise_features_scaler: MinMaxScaler,  # Scaler đã được tải
        # Thêm danh sách các cột đã được scale trong notebook
        numerical_cols_to_scale_in_notebook: list
) -> pd.Series:
    """
    Tạo vector đặc trưng cho một cặp người dùng.
    ...
    numerical_cols_to_scale_in_notebook: List các tên cột SỐ đã được scale trong notebook
                                        (chính là numerical_cols_to_scale_pairwise từ cell [16] của notebook)
    """
    pair_features_dict = {}

    # 1. Basic differences
    pair_features_dict['age_diff'] = abs(user1_raw_data.get('age', 0.0) - user2_raw_data.get('age', 0.0))
    pair_features_dict['height_diff'] = abs(user1_raw_data.get('height', 0.0) - user2_raw_data.get('height', 0.0))

    # 2. Geographical distance
    pair_features_dict['geo_distance_km'] = haversine_distance(
        user1_raw_data.get('latitude'), user1_raw_data.get('longitude'),
        user2_raw_data.get('latitude'), user2_raw_data.get('longitude')
    )

    # 3. Location preference compatibility
    user1_loc_pref = user1_raw_data.get('location_preference', -1.0)
    user2_loc_pref = user2_raw_data.get('location_preference', -1.0)
    dist = pair_features_dict['geo_distance_km']

    pair_features_dict['user1_within_user2_loc_pref'] = 1.0 if user2_loc_pref == -1 or (
                dist is not None and dist <= user2_loc_pref) else 0.0
    pair_features_dict['user2_within_user1_loc_pref'] = 1.0 if user1_loc_pref == -1 or (
                dist is not None and dist <= user1_loc_pref) else 0.0

    # 4. Sexual orientation compatibility (giữ nguyên kiểu float 0.0/1.0)
    comp_u1_u2 = orientation_compatibility(
        user1_raw_data.get('sex'), user1_raw_data.get('orientation'),
        user2_raw_data.get('sex'), user2_raw_data.get('orientation')
    )
    comp_u2_u1 = orientation_compatibility(
        user2_raw_data.get('sex'), user2_raw_data.get('orientation'),
        user1_raw_data.get('sex'), user1_raw_data.get('orientation')
    )
    pair_features_dict['orientation_compatible_user1_to_user2'] = 1.0 if comp_u1_u2 else 0.0
    pair_features_dict['orientation_compatible_user2_to_user1'] = 1.0 if comp_u2_u1 else 0.0
    pair_features_dict['orientation_compatible_final'] = 1.0 if max(comp_u1_u2, comp_u2_u1) else 0.0

    # 5. Similar habits
    pair_features_dict['drink_match'] = 1.0 if user1_raw_data.get('drink') == user2_raw_data.get('drink') else 0.0
    pair_features_dict['smoke_match'] = 1.0 if user1_raw_data.get('smoke') == user2_raw_data.get('smoke') else 0.0

    # 6. Education level match
    pair_features_dict['education_match'] = 1.0 if user1_raw_data.get('education_level') == user2_raw_data.get(
        'education_level') else 0.0

    # 7. Jaccard similarity
    pair_features_dict['interests_jaccard'] = jaccard_similarity(user1_raw_data.get('interests'),
                                                                 user2_raw_data.get('interests'), separator='-')
    pair_features_dict['languages_jaccard'] = jaccard_similarity(user1_raw_data.get('languages'),
                                                                 user2_raw_data.get('languages'), separator='-')
    pair_features_dict['pets_jaccard'] = jaccard_similarity(user1_raw_data.get('pets'), user2_raw_data.get('pets'),
                                                            separator='-')

    # 8. Language interest match
    user1_wants_learn = 1.0 if user1_raw_data.get('interested_in_new_language', False) else 0.0
    user2_wants_learn = 1.0 if user2_raw_data.get('interested_in_new_language', False) else 0.0
    pair_features_dict['user1_wants_learn_lang'] = user1_wants_learn
    pair_features_dict['user2_wants_learn_lang'] = user2_wants_learn
    pair_features_dict[
        'language_interest_match'] = 1.0 if user1_wants_learn == 1.0 and user2_wants_learn == 1.0 else 0.0

    # 9. Similarity of user feature vectors
    vec1 = user1_feature_vector.fillna(0.0).values.reshape(1, -1)
    vec2 = user2_feature_vector.fillna(0.0).values.reshape(1, -1)
    pair_features_dict['user_features_cosine_sim'] = cosine_similarity(vec1, vec2)[0, 0]
    pair_features_dict['user_features_mae_diff'] = np.mean(np.abs(vec1 - vec2))

    # --- Tạo DataFrame với đầy đủ các cột trước khi scaling ---
    # Đảm bảo tất cả các giá trị là float và đúng thứ tự
    df_for_model_data = {}
    for col in pairwise_input_columns_list:  # Đây là danh sách đầy đủ các cột model cần
        value = pair_features_dict.get(col)
        if pd.isna(value):
            df_for_model_data[col] = 0.0  # Fallback cho NaN
        else:
            try:
                df_for_model_data[col] = float(value)
            except ValueError:
                print(f"Warning: Cannot convert value for {col} to float: {value}. Using 0.0.")
                df_for_model_data[col] = 0.0

    pair_features_df_single_row = pd.DataFrame([df_for_model_data], columns=pairwise_input_columns_list)

    # --- Scaling CHỈ các cột số đã được scale trong notebook ---
    # numerical_cols_to_scale_in_notebook là danh sách các cột như 'age_diff', 'height_diff', 'geo_distance_km', ...
    # KHÔNG bao gồm các cột boolean như 'orientation_compatible_*'

    cols_to_scale_actually = [col for col in numerical_cols_to_scale_in_notebook if
                              col in pair_features_df_single_row.columns]

    if cols_to_scale_actually:
        try:
            # Lấy phần DataFrame cần scale
            df_subset_to_scale = pair_features_df_single_row[cols_to_scale_actually]

            # Thực hiện scaling
            scaled_values = pairwise_features_scaler.transform(df_subset_to_scale)

            # Tạo DataFrame từ scaled_values và gán lại vào các cột tương ứng
            scaled_df_temp = pd.DataFrame(scaled_values, columns=cols_to_scale_actually,
                                          index=pair_features_df_single_row.index)
            for col in cols_to_scale_actually:
                pair_features_df_single_row[col] = scaled_df_temp[col]
        except Exception as e:
            print(f"Error during scaling pairwise features: {e}")
            pass  # Bỏ qua scaling nếu có lỗi, model sẽ nhận giá trị chưa scale

    # Trả về Series với đúng các cột đầu vào của model
    # pair_features_df_single_row giờ đã có các cột số được scale, các cột boolean giữ nguyên (0.0/1.0)
    return pair_features_df_single_row.iloc[0]