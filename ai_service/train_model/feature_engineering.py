import pandas as pd
import numpy as np
import os
import re
from datetime import datetime
import joblib
from sklearn.preprocessing import StandardScaler, MinMaxScaler, OneHotEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from unidecode import unidecode
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize
from geopy.distance import geodesic

# Đường dẫn
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
PROFILE_PATH = os.path.join(DATA_DIR, 'match_profiles.csv')
LABELED_PATH = os.path.join(DATA_DIR, 'labeled_pairs.csv')
MODELS_DIR = os.path.join(os.path.dirname(__file__), 'models')

# Tự động tải NLTK data nếu chưa có
def download_nltk_data():
    """Tải NLTK data cần thiết"""
    try:
        nltk.download('punkt', quiet=True)
        nltk.download('stopwords', quiet=True)
        nltk.download('wordnet', quiet=True)
        nltk.download('punkt_tab', quiet=True)
        print("NLTK data đã được tải thành công")
    except Exception as e:
        print(f"Lỗi khi tải NLTK data: {e}")
        print("Tiếp tục với NLTK data có sẵn...")

# Tải NLTK data
download_nltk_data()

# Download NLTK data
try:
    stop_words_en = set(stopwords.words('english'))
    lemmatizer = WordNetLemmatizer()
except:
    stop_words_en = set()
    lemmatizer = None

def calculate_age(born_str):
    """Tính tuổi từ ngày sinh"""
    try:
        born = datetime.strptime(str(born_str), '%Y-%m-%d')
        today = datetime.today()
        age = today.year - born.year - ((today.month, today.day) < (born.month, born.day))
        return age
    except:
        return np.nan

def preprocess_text(text, use_lemmatization=True):
    """Tiền xử lý text"""
    if pd.isnull(text) or not lemmatizer:
        return ""
    text_normalized = unidecode(str(text).lower())
    text_normalized = re.sub(r'[^\w\s]', '', text_normalized)
    text_normalized = re.sub(r'\d+', '', text_normalized)
    tokens = word_tokenize(text_normalized)
    tokens = [word for word in tokens if word not in stop_words_en and len(word) > 1]
    if use_lemmatization:
        tokens = [lemmatizer.lemmatize(word) for word in tokens]
    return " ".join(tokens)

def haversine_distance(lat1, lon1, lat2, lon2):
    """Tính khoảng cách địa lý"""
    try:
        return geodesic((lat1, lon1), (lat2, lon2)).kilometers
    except:
        return np.nan

def orientation_compatibility(sex1, orientation1, sex2, orientation2):
    """Kiểm tra tính tương thích orientation"""
    if pd.isna(sex1) or pd.isna(orientation1) or pd.isna(sex2) or pd.isna(orientation2):
        return False
    
    # Straight compatibility
    if orientation1 == 'straight' and orientation2 == 'straight':
        return sex1 != sex2
    
    # Homosexual compatibility
    if orientation1 == 'homosexual' and orientation2 == 'homosexual':
        return sex1 == sex2
    
    # Bisexual compatibility
    if orientation1 == 'bisexual' or orientation2 == 'bisexual':
        return True
    
    return False

def jaccard_similarity(list1_str, list2_str, separator='-'):
    """Tính Jaccard similarity"""
    if pd.isna(list1_str) or pd.isna(list2_str):
        return 0.0
    
    set1 = set(str(list1_str).split(separator))
    set2 = set(str(list2_str).split(separator))
    
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    
    return intersection / union if union > 0 else 0.0

def create_and_save_scalers_encoders(profiles_df):
    """Tạo và lưu tất cả scaler, encoder, vectorizer cần thiết"""
    print("Đang tạo và lưu scalers, encoders, vectorizers...")
    
    # Tạo thư mục models nếu chưa có
    os.makedirs(MODELS_DIR, exist_ok=True)
    
    # 1. Age và Height scalers
    scaler_age = StandardScaler()
    scaler_height = StandardScaler()
    
    # Sử dụng DataFrame để có feature names
    age_df = profiles_df[['age']].dropna()
    height_df = profiles_df[['height']].dropna()
    
    scaler_age.fit(age_df)
    scaler_height.fit(height_df)
    
    joblib.dump(scaler_age, os.path.join(MODELS_DIR, 'scaler_age.joblib'))
    joblib.dump(scaler_height, os.path.join(MODELS_DIR, 'scaler_height.joblib'))
    print("Đã lưu age và height scalers")
    
    # 2. Categorical OneHotEncoder
    categorical_cols = ['sex', 'orientation', 'body_type', 'drink', 'smoke']
    onehot_encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')
    
    # Chuẩn bị dữ liệu categorical
    cat_data = profiles_df[categorical_cols].fillna('unknown')
    onehot_encoder.fit(cat_data)
    
    joblib.dump(onehot_encoder, os.path.join(MODELS_DIR, 'onehot_encoder_categorical.joblib'))
    print("Đã lưu categorical onehot encoder")
    
    # 3. Top categories cho job và education
    top_job_categories = profiles_df['job'].value_counts().head(10).index.tolist()
    top_edu_categories = profiles_df['education_level'].value_counts().head(10).index.tolist()
    
    joblib.dump(top_job_categories, os.path.join(MODELS_DIR, 'top_n_job_categories.joblib'))
    joblib.dump(top_edu_categories, os.path.join(MODELS_DIR, 'top_n_edu_categories.joblib'))
    print("Đã lưu top job và education categories")
    
    # 4. Top items cho interests, languages, pets
    # Interests
    all_interests = []
    for interests_str in profiles_df['interests'].dropna():
        all_interests.extend([item.strip() for item in str(interests_str).split('-')])
    top_interests = pd.Series(all_interests).value_counts().head(20).index.tolist()
    
    # Languages
    all_languages = []
    for languages_str in profiles_df['languages'].dropna():
        all_languages.extend([item.strip() for item in str(languages_str).split('-')])
    top_languages = pd.Series(all_languages).value_counts().head(10).index.tolist()
    
    # Pets
    all_pets = []
    for pets_str in profiles_df['pets'].dropna():
        all_pets.extend([item.strip() for item in str(pets_str).split('-')])
    top_pets = pd.Series(all_pets).value_counts().head(10).index.tolist()
    
    joblib.dump(top_interests, os.path.join(MODELS_DIR, 'top_interests_items.joblib'))
    joblib.dump(top_languages, os.path.join(MODELS_DIR, 'top_languages_items.joblib'))
    joblib.dump(top_pets, os.path.join(MODELS_DIR, 'top_pets_items.joblib'))
    print("Đã lưu top interests, languages, pets")
    
    # 5. TF-IDF Vectorizer cho bio
    processed_bios = profiles_df['bio'].dropna().apply(preprocess_text)
    tfidf_vectorizer = TfidfVectorizer(max_features=100, stop_words='english')
    tfidf_vectorizer.fit(processed_bios)
    
    joblib.dump(tfidf_vectorizer, os.path.join(MODELS_DIR, 'tfidf_vectorizer_bio.joblib'))
    print("Đã lưu TF-IDF vectorizer cho bio")
    
    # 6. Location scalers
    location_pref_scaler = StandardScaler()
    latitude_scaler = StandardScaler()
    longitude_scaler = StandardScaler()
    
    # Sử dụng DataFrame để có feature names - SỬA: Khớp với API
    # API sử dụng location_preference_km (0 nếu -1, otherwise giữ nguyên)
    loc_pref_km = profiles_df['location_preference'].replace(-1, 0)
    loc_pref_df = pd.DataFrame({'location_preference_km': loc_pref_km}).dropna()
    lat_df = profiles_df[['latitude']].dropna()
    lon_df = profiles_df[['longitude']].dropna()
    
    location_pref_scaler.fit(loc_pref_df)
    latitude_scaler.fit(lat_df)
    longitude_scaler.fit(lon_df)
    
    joblib.dump(location_pref_scaler, os.path.join(MODELS_DIR, 'location_preference_scaler.joblib'))
    joblib.dump(latitude_scaler, os.path.join(MODELS_DIR, 'latitude_scaler.joblib'))
    joblib.dump(longitude_scaler, os.path.join(MODELS_DIR, 'longitude_scaler.joblib'))
    print("Đã lưu location scalers")
    
    # 7. Tạo user features final columns (placeholder - sẽ được cập nhật sau)
    user_features_final_columns = [
        'age_scaled', 'height_scaled', 'dropped_out_school', 'interested_in_new_language',
        'loc_pref_is_everywhere', 'location_preference_km_scaled', 'latitude_scaled', 'longitude_scaled'
    ]
    
    # Thêm onehot encoded columns
    onehot_feature_names = onehot_encoder.get_feature_names_out(categorical_cols)
    user_features_final_columns.extend(onehot_feature_names)
    
    # Thêm job và education encoded columns
    for job_cat in top_job_categories:
        user_features_final_columns.append(f'job_{job_cat.lower().replace(" ", "_")}')
    user_features_final_columns.append('job_other')
    
    for edu_cat in top_edu_categories:
        user_features_final_columns.append(f'edu_{edu_cat.lower().replace(" ", "_")}')
    user_features_final_columns.append('edu_other')
    
    # Thêm interests, languages, pets encoded columns
    for interest in top_interests:
        user_features_final_columns.append(f'interest_{interest.lower().replace(" ", "_")}')
    user_features_final_columns.append('interest_other')
    
    for language in top_languages:
        user_features_final_columns.append(f'lang_{language.lower().replace(" ", "_")}')
    user_features_final_columns.append('lang_other')
    
    for pet in top_pets:
        user_features_final_columns.append(f'pet_{pet.lower().replace(" ", "_")}')
    user_features_final_columns.append('pet_other')
    
    # Thêm TF-IDF bio features
    for i in range(100):  # max_features=100
        user_features_final_columns.append(f'bio_tfidf_{i}')
    
    joblib.dump(user_features_final_columns, os.path.join(MODELS_DIR, 'user_features_final_columns.joblib'))
    print("Đã lưu user features final columns")
    
    print("✅ Đã tạo và lưu tất cả scalers, encoders, vectorizers")

def create_user_feature_vector(user_raw_data: dict) -> pd.Series:
    """
    Tạo vector đặc trưng cho một người dùng từ dữ liệu thô.
    Giống hệt như trong API để đảm bảo tính nhất quán.
    """
    user_features_dict = {}

    # 1. Age and Height
    age = user_raw_data.get('age', np.nan)
    height = user_raw_data.get('height', np.nan)

    scaler_age = joblib.load(os.path.join(MODELS_DIR, "scaler_age.joblib"))
    scaler_height = joblib.load(os.path.join(MODELS_DIR, "scaler_height.joblib"))

    age_median_fallback = 25
    height_median_fallback = 68

    # Tạo DataFrame một dòng, một cột để transform
    age_df_to_transform = pd.DataFrame({'age': [age if pd.notnull(age) else age_median_fallback]})
    height_df_to_transform = pd.DataFrame({'height': [height if pd.notnull(height) else height_median_fallback]})

    user_features_dict['age_scaled'] = scaler_age.transform(age_df_to_transform)[0, 0]
    user_features_dict['height_scaled'] = scaler_height.transform(height_df_to_transform)[0, 0]

    # 2. Categorical Features (OneHotEncoded)
    onehot_encoder_categorical = joblib.load(os.path.join(MODELS_DIR, "onehot_encoder_categorical.joblib"))
    categorical_cols_onehot = ['sex', 'orientation', 'body_type', 'drink', 'smoke']

    modes = {
        'sex': 'male', 'orientation': 'straight', 'body_type': 'average',
        'drink': 'socially', 'smoke': 'no'
    }

    user_cat_values_dict = {col: user_raw_data.get(col, modes.get(col)) for col in categorical_cols_onehot}
    cat_df_to_transform = pd.DataFrame([user_cat_values_dict], columns=categorical_cols_onehot)

    encoded_cat_array = onehot_encoder_categorical.transform(cat_df_to_transform)

    onehot_feature_names = onehot_encoder_categorical.get_feature_names_out(categorical_cols_onehot)
    for i, col_name in enumerate(onehot_feature_names):
        user_features_dict[col_name] = encoded_cat_array[0, i]

    # 3. High-Cardinality Categorical (Job, Education)
    top_n_job_categories = joblib.load(os.path.join(MODELS_DIR, "top_n_job_categories.joblib"))
    job_series = _apply_top_n_categorical_encoding_single(user_raw_data.get('job'), top_n_job_categories, 'job')
    user_features_dict.update(job_series.to_dict())

    top_n_edu_categories = joblib.load(os.path.join(MODELS_DIR, "top_n_edu_categories.joblib"))
    edu_series = _apply_top_n_categorical_encoding_single(user_raw_data.get('education_level'), top_n_edu_categories, 'edu')
    user_features_dict.update(edu_series.to_dict())

    # 4. Binary Indicators
    user_features_dict['dropped_out_school'] = int(user_raw_data.get('dropped_out_school', 0) or 0)
    user_features_dict['interested_in_new_language'] = int(user_raw_data.get('interested_in_new_language', 0) or 0)

    # 5. Multi-value text features (Interests, Languages, Pets)
    top_interests_items = joblib.load(os.path.join(MODELS_DIR, "top_interests_items.joblib"))
    interests_series = _apply_multivalue_binary_features_single(user_raw_data.get('interests'), top_interests_items, '-', 'interest')
    user_features_dict.update(interests_series.to_dict())

    top_languages_items = joblib.load(os.path.join(MODELS_DIR, "top_languages_items.joblib"))
    languages_series = _apply_multivalue_binary_features_single(user_raw_data.get('languages'), top_languages_items, '-', 'lang')
    user_features_dict.update(languages_series.to_dict())

    top_pets_items = joblib.load(os.path.join(MODELS_DIR, "top_pets_items.joblib"))
    pets_series = _apply_multivalue_binary_features_single(user_raw_data.get('pets'), top_pets_items, '-', 'pet')
    user_features_dict.update(pets_series.to_dict())

    # 6. TF-IDF for Bio
    tfidf_vectorizer_bio = joblib.load(os.path.join(MODELS_DIR, "tfidf_vectorizer_bio.joblib"))
    processed_bio = preprocess_text(user_raw_data.get('bio'))
    bio_tfidf_matrix = tfidf_vectorizer_bio.transform([processed_bio])
    bio_tfidf_array = bio_tfidf_matrix.toarray()[0]

    if hasattr(tfidf_vectorizer_bio, 'get_feature_names_out'):
        bio_feature_names = [f"bio_tfidf_{name.replace(' ', '_')}" for name in tfidf_vectorizer_bio.get_feature_names_out()]
        if len(bio_feature_names) == bio_tfidf_array.shape[0]:
            for i, col_name in enumerate(bio_feature_names):
                user_features_dict[col_name] = bio_tfidf_array[i]
        else:
            for i in range(bio_tfidf_array.shape[0]):
                user_features_dict[f"bio_tfidf_{i}"] = bio_tfidf_array[i]
    else:
        for i in range(bio_tfidf_array.shape[0]):
            user_features_dict[f"bio_tfidf_{i}"] = bio_tfidf_array[i]

    # 7. Geographic Features
    loc_pref_scaler = joblib.load(os.path.join(MODELS_DIR, "location_preference_scaler.joblib"))
    loc_pref = user_raw_data.get('location_preference', -1)
    user_features_dict['loc_pref_is_everywhere'] = 1 if loc_pref == -1 else 0
    loc_pref_km = 0 if loc_pref == -1 else loc_pref

    loc_pref_df_to_transform = pd.DataFrame({'location_preference_km': [loc_pref_km]})
    user_features_dict['location_preference_km_scaled'] = loc_pref_scaler.transform(loc_pref_df_to_transform)[0, 0]

    lat_scaler = joblib.load(os.path.join(MODELS_DIR, "latitude_scaler.joblib"))
    lon_scaler = joblib.load(os.path.join(MODELS_DIR, "longitude_scaler.joblib"))

    lat_median_fallback = 21.0
    lon_median_fallback = 105.8

    latitude = user_raw_data.get('latitude', lat_median_fallback)
    longitude = user_raw_data.get('longitude', lon_median_fallback)
    latitude = latitude if pd.notnull(latitude) else lat_median_fallback
    longitude = longitude if pd.notnull(longitude) else lon_median_fallback

    lat_df_to_transform = pd.DataFrame({'latitude': [latitude]})
    lon_df_to_transform = pd.DataFrame({'longitude': [longitude]})

    user_features_dict['latitude_scaled'] = lat_scaler.transform(lat_df_to_transform)[0, 0]
    user_features_dict['longitude_scaled'] = lon_scaler.transform(lon_df_to_transform)[0, 0]

    # Đảm bảo thứ tự cột và đầy đủ các cột như trong user_features_final_columns.joblib
    user_features_final_columns = joblib.load(os.path.join(MODELS_DIR, "user_features_final_columns.joblib"))

    final_feature_vector_data = {}
    for col in user_features_final_columns:
        final_feature_vector_data[col] = user_features_dict.get(col, 0.0)

    return pd.Series(final_feature_vector_data, index=user_features_final_columns)

def _apply_top_n_categorical_encoding_single(value: str | None, top_categories: list, prefix: str) -> pd.Series:
    """Helper cho việc encode top-N cho một giá trị đơn lẻ."""
    encoded_features = {}
    value_normalized = str(value).strip().lower() if pd.notnull(value) else 'unknown'

    for category in top_categories:
        clean_category = unidecode(str(category)).lower().replace(' ', '_').replace('/', '_').replace('(', '').replace(
            ')', '').replace('.', '')
        col_name = f"{prefix}_{clean_category}"
        encoded_features[col_name] = 1 if value_normalized == str(category).strip().lower() else 0

    clean_categories_lower = [str(cat).strip().lower() for cat in top_categories]
    col_name_other = f"{prefix}_other"
    encoded_features[col_name_other] = 1 if value_normalized not in clean_categories_lower else 0

    return pd.Series(encoded_features)

def _apply_multivalue_binary_features_single(value_str: str | None, top_items: list, separator: str, prefix: str) -> pd.Series:
    """Helper cho việc tạo multi-value binary features cho một giá trị chuỗi đơn lẻ."""
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

def create_user_features(profiles_df):
    """Tạo đặc trưng cho từng user"""
    print("Đang tạo đặc trưng cho users...")
    
    # Tính tuổi
    profiles_df['age'] = profiles_df['date_of_birth'].apply(calculate_age)
    
    # Tiền xử lý bio
    profiles_df['bio_processed'] = profiles_df['bio'].apply(preprocess_text)
    
    # Tách các trường multi-value
    for col in ['pets', 'interests', 'languages']:
        profiles_df[f'{col}_count'] = profiles_df[col].apply(
            lambda x: len(str(x).split('-')) if pd.notna(x) else 0
        )
    
    return profiles_df

def create_pairwise_features(user1_data, user2_data):
    """Tạo đặc trưng cho cặp user với thứ tự cố định"""
    features = {}
    
    # 1. Basic differences
    features['age_diff'] = abs(user1_data.get('age', 0) - user2_data.get('age', 0))
    features['height_diff'] = abs(user1_data.get('height', 0) - user2_data.get('height', 0))
    
    # 2. Geographical distance
    features['geo_distance_km'] = haversine_distance(
        user1_data.get('latitude'), user1_data.get('longitude'),
        user2_data.get('latitude'), user2_data.get('longitude')
    )
    
    # 3. Location preference compatibility
    user1_loc_pref = user1_data.get('location_preference', -1.0)
    user2_loc_pref = user2_data.get('location_preference', -1.0)
    dist = features['geo_distance_km']
    
    features['user1_within_user2_loc_pref'] = 1.0 if user2_loc_pref == -1 or (dist is not None and dist <= user2_loc_pref) else 0.0
    features['user2_within_user1_loc_pref'] = 1.0 if user1_loc_pref == -1 or (dist is not None and dist <= user1_loc_pref) else 0.0
    
    # 4. Orientation compatibility
    comp_u1_u2 = orientation_compatibility(
        user1_data.get('sex'), user1_data.get('orientation'),
        user2_data.get('sex'), user2_data.get('orientation')
    )
    comp_u2_u1 = orientation_compatibility(
        user2_data.get('sex'), user2_data.get('orientation'),
        user1_data.get('sex'), user1_data.get('orientation')
    )
    features['orientation_compatible_user1_to_user2'] = 1.0 if comp_u1_u2 else 0.0
    features['orientation_compatible_user2_to_user1'] = 1.0 if comp_u2_u1 else 0.0
    features['orientation_compatible_final'] = 1.0 if max(comp_u1_u2, comp_u2_u1) else 0.0
    
    # 5. Similar habits
    features['drink_match'] = 1.0 if user1_data.get('drink') == user2_data.get('drink') else 0.0
    features['smoke_match'] = 1.0 if user1_data.get('smoke') == user2_data.get('smoke') else 0.0
    features['education_match'] = 1.0 if user1_data.get('education_level') == user2_data.get('education_level') else 0.0
    
    # 6. Jaccard similarities
    features['interests_jaccard'] = jaccard_similarity(user1_data.get('interests'), user2_data.get('interests'))
    features['languages_jaccard'] = jaccard_similarity(user1_data.get('languages'), user2_data.get('languages'))
    
    # 7. Language interest match
    user1_wants_learn = 1.0 if user1_data.get('interested_in_new_language', False) else 0.0
    user2_wants_learn = 1.0 if user2_data.get('interested_in_new_language', False) else 0.0
    features['user1_wants_learn_lang'] = user1_wants_learn
    features['user2_wants_learn_lang'] = user2_wants_learn
    features['language_interest_match'] = 1.0 if user1_wants_learn == 1.0 and user2_wants_learn == 1.0 else 0.0
    
    # 8. Pets jaccard (đặt sau language_interest_match để giống model ban đầu)
    features['pets_jaccard'] = jaccard_similarity(user1_data.get('pets'), user2_data.get('pets'))
    
    # Note: user_features_cosine_sim và user_features_mae_diff sẽ được thêm ở extract_features()
    
    return features

def extract_features():
    """Trích xuất đặc trưng cho tất cả cặp user"""
    print("Đang đọc dữ liệu...")
    profiles = pd.read_csv(PROFILE_PATH)
    labeled_pairs = pd.read_csv(LABELED_PATH)
    
    # Tạo đặc trưng cho users
    profiles = create_user_features(profiles)
    
    # Tạo và lưu tất cả scalers, encoders, vectorizers
    create_and_save_scalers_encoders(profiles)
    
    # Tạo dictionary để truy cập nhanh
    profiles_dict = profiles.set_index('id').to_dict('index')
    
    print("Đang tạo đặc trưng cho các cặp...")
    features_list = []
    
    for idx, row in labeled_pairs.iterrows():
        if idx % 1000 == 0:
            print(f"Đã xử lý {idx}/{len(labeled_pairs)} cặp...")
        
        user1_id = row['user_id_1']
        user2_id = row['user_id_2']
        label = row['label']
        
        user1_data = profiles_dict.get(user1_id, {})
        user2_data = profiles_dict.get(user2_id, {})
        
        if not user1_data or not user2_data:
            continue
        
        # Tạo user feature vectors giống như trong API
        try:
            user1_feature_vector = create_user_feature_vector(user1_data)
            user2_feature_vector = create_user_feature_vector(user2_data)
        except Exception as e:
            print(f"Error creating feature vectors for users {user1_id}, {user2_id}: {e}")
            continue
        
        # Tạo đặc trưng cặp
        pair_features = create_pairwise_features(user1_data, user2_data)
        
        # Thêm user feature similarity (giống như trong API)
        vec1 = user1_feature_vector.fillna(0.0).values.reshape(1, -1)
        vec2 = user2_feature_vector.fillna(0.0).values.reshape(1, -1)
        
        from sklearn.metrics.pairwise import cosine_similarity
        pair_features['user_features_cosine_sim'] = cosine_similarity(vec1, vec2)[0, 0]
        pair_features['user_features_mae_diff'] = np.mean(np.abs(vec1 - vec2))
        
        pair_features['label'] = label
        pair_features['user_id_1'] = user1_id
        pair_features['user_id_2'] = user2_id
        
        features_list.append(pair_features)
    
    features_df = pd.DataFrame(features_list)
    
    print(f"Tổng số cặp có đặc trưng: {len(features_df)}")
    print(f"Số positive samples: {len(features_df[features_df['label'] == 1])}")
    print(f"Số negative samples: {len(features_df[features_df['label'] == 0])}")
    
    # Lưu kết quả
    output_path = os.path.join(DATA_DIR, 'pairwise_features.csv')
    features_df.to_csv(output_path, index=False)
    print(f"Đã lưu đặc trưng vào: {output_path}")
    
    return features_df

if __name__ == "__main__":
    features_df = extract_features() 