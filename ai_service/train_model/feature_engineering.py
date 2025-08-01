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
    
    age_data = profiles_df['age'].dropna().values.reshape(-1, 1)
    height_data = profiles_df['height'].dropna().values.reshape(-1, 1)
    
    scaler_age.fit(age_data)
    scaler_height.fit(height_data)
    
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
    
    # Location preference (thay thế -1 bằng 0)
    loc_pref_data = profiles_df['location_preference'].replace(-1, 0).dropna().values.reshape(-1, 1)
    lat_data = profiles_df['latitude'].dropna().values.reshape(-1, 1)
    lon_data = profiles_df['longitude'].dropna().values.reshape(-1, 1)
    
    location_pref_scaler.fit(loc_pref_data)
    latitude_scaler.fit(lat_data)
    longitude_scaler.fit(lon_data)
    
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
    """Tạo đặc trưng cho cặp user"""
    features = {}
    
    # Basic differences
    features['age_diff'] = abs(user1_data.get('age', 0) - user2_data.get('age', 0))
    features['height_diff'] = abs(user1_data.get('height', 0) - user2_data.get('height', 0))
    
    # Geographical distance
    features['geo_distance_km'] = haversine_distance(
        user1_data.get('latitude'), user1_data.get('longitude'),
        user2_data.get('latitude'), user2_data.get('longitude')
    )
    
    # Location preference compatibility
    user1_loc_pref = user1_data.get('location_preference', -1.0)
    user2_loc_pref = user2_data.get('location_preference', -1.0)
    dist = features['geo_distance_km']
    
    features['user1_within_user2_loc_pref'] = 1.0 if user2_loc_pref == -1 or (dist is not None and dist <= user2_loc_pref) else 0.0
    features['user2_within_user1_loc_pref'] = 1.0 if user1_loc_pref == -1 or (dist is not None and dist <= user1_loc_pref) else 0.0
    
    # Orientation compatibility - tạo đúng tên như trong preprocessing.py
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
    
    # Similar habits
    features['drink_match'] = 1.0 if user1_data.get('drink') == user2_data.get('drink') else 0.0
    features['smoke_match'] = 1.0 if user1_data.get('smoke') == user2_data.get('smoke') else 0.0
    features['education_match'] = 1.0 if user1_data.get('education_level') == user2_data.get('education_level') else 0.0
    
    # Jaccard similarities
    features['interests_jaccard'] = jaccard_similarity(user1_data.get('interests'), user2_data.get('interests'))
    features['languages_jaccard'] = jaccard_similarity(user1_data.get('languages'), user2_data.get('languages'))
    features['pets_jaccard'] = jaccard_similarity(user1_data.get('pets'), user2_data.get('pets'))
    
    # Language interest match
    user1_wants_learn = 1.0 if user1_data.get('interested_in_new_language', False) else 0.0
    user2_wants_learn = 1.0 if user2_data.get('interested_in_new_language', False) else 0.0
    features['user1_wants_learn_lang'] = user1_wants_learn
    features['user2_wants_learn_lang'] = user2_wants_learn
    features['language_interest_match'] = 1.0 if user1_wants_learn == 1.0 and user2_wants_learn == 1.0 else 0.0
    
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
        
        # Tạo đặc trưng cặp
        pair_features = create_pairwise_features(user1_data, user2_data)
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