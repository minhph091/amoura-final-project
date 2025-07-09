#!/usr/bin/env python3
"""
Script để tạo file SQL chứa các câu lệnh INSERT dữ liệu
Thay vì insert trực tiếp vào DB, script này sinh ra file output.sql
"""

import pandas as pd
import hashlib
import os
from datetime import datetime
import logging
import sys
import glob

# Cấu hình logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

OUTPUT_SQL_FILE = "output.sql"

class SQLGenerator:
    def __init__(self, output_file=OUTPUT_SQL_FILE):
        self.output_file = output_file
        self.sql_file = None
        
    def open_file(self):
        """Mở file SQL để ghi"""
        try:
            self.sql_file = open(self.output_file, 'w', encoding='utf-8')
            self.sql_file.write("-- Generated SQL script for Amoura dating app\n")
            self.sql_file.write(f"-- Generated at: {datetime.now()}\n\n")
            logger.info(f"Đã tạo file SQL: {self.output_file}")
        except Exception as e:
            logger.error(f"Lỗi tạo file SQL: {e}")
            raise
    
    def close_file(self):
        """Đóng file SQL"""
        if self.sql_file:
            self.sql_file.close()
        logger.info(f"Đã đóng file SQL: {self.output_file}")
    
    def escape_sql_value(self, value):
        """Escape giá trị để an toàn trong SQL"""
        if value is None:
            return 'NULL'
        if isinstance(value, str):
            # Escape single quotes
            escaped = value.replace("'", "''")
            return f"'{escaped}'"
        if isinstance(value, bool):
            return 'TRUE' if value else 'FALSE'
        if isinstance(value, (int, float)):
            return str(value)
        if isinstance(value, datetime):
            return f"'{value.strftime('%Y-%m-%d %H:%M:%S')}'"
        return f"'{str(value)}'"
    
    def write_sql(self, sql_statement):
        """Ghi câu lệnh SQL vào file"""
        self.sql_file.write(sql_statement + '\n')
    
    def hash_password(self, password):
        """Hash password bằng SHA-256"""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def insert_reference_data(self):
        """Tạo SQL để chèn dữ liệu tham chiếu cơ bản"""
        logger.info("Tạo SQL cho dữ liệu tham chiếu...")
        
        self.write_sql("-- Insert reference data")
        self.write_sql("-- Body types")
        
        body_types = [
            'athletic', 'muscular', 'slim', 'curvy', 'plus-size', 
            'average', 'prefer not to say'
        ]
        
        for body_type in body_types:
            sql = f"INSERT INTO body_types (name) VALUES ({self.escape_sql_value(body_type)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("\n-- Orientations")
        orientations = [
            ('straight', 'Heterosexual'),
            ('homosexual', 'Homosexual'),
            ('bisexual', 'Bisexual')
        ]
        
        for name, description in orientations:
            sql = f"INSERT INTO orientations (name, description) VALUES ({self.escape_sql_value(name)}, {self.escape_sql_value(description)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("\n-- Job industries")
        job_industries = [
            'healthcare/medical', 'information technology (it)', 'finance/accounting',
            'education/training', 'art/creative', 'engineering/architecture',
            'business/management', 'government/legal', 'hospitality/tourism',
            'skilled trades/labor', 'student', 'unemployed', 'other',
            'prefer not to say'
        ]
        
        for industry in job_industries:
            sql = f"INSERT INTO job_industries (name) VALUES ({self.escape_sql_value(industry)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("\n-- Drink statuses")
        drink_statuses = [
            'socially', 'regularly', 'occasionally', 'never', 'prefer not to say'
        ]
        
        for status in drink_statuses:
            sql = f"INSERT INTO drink_statuses (name) VALUES ({self.escape_sql_value(status)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("\n-- Smoke statuses")
        smoke_statuses = [
            'regularly', 'occasionally', 'former smoker', 'never', 'prefer not to say'
        ]
        
        for status in smoke_statuses:
            sql = f"INSERT INTO smoke_statuses (name) VALUES ({self.escape_sql_value(status)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("\n-- Education levels")
        education_levels = [
            'high school', 'college diploma / associate degree', 'bachelor\'s degree',
            'master\'s degree', 'doctorate', 'prefer not to say'
        ]
        
        for level in education_levels:
            sql = f"INSERT INTO education_levels (name) VALUES ({self.escape_sql_value(level)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("")
        logger.info("Hoàn thành tạo SQL cho dữ liệu tham chiếu")
    
    def scan_and_generate_photos_sql(self):
        """Quét thư mục uploads/users và tạo SQL insert ảnh"""
        logger.info("Quét thư mục uploads và tạo SQL insert ảnh...")
        
        uploads_dir = "uploads/users"
        if not os.path.exists(uploads_dir):
            logger.warning(f"Thư mục {uploads_dir} không tồn tại, bỏ qua việc tạo SQL insert ảnh")
            return
        
        self.write_sql("-- Insert photos from uploads directory")
        photo_count = 0
        
        # Quét tất cả thư mục con trong uploads/users
        for user_folder in os.listdir(uploads_dir):
            user_folder_path = os.path.join(uploads_dir, user_folder)
            
            # Kiểm tra xem có phải là thư mục và tên là số không
            if not os.path.isdir(user_folder_path) or not user_folder.isdigit():
                continue
            
            user_id = int(user_folder)
            
            # Quét tất cả file trong thư mục user
            for filename in os.listdir(user_folder_path):
                file_path = os.path.join(user_folder_path, filename)
                
                # Chỉ xử lý file ảnh
                if not os.path.isfile(file_path) or not filename.lower().endswith(('.jpg', '.jpeg', '.png', '.gif')):
                    continue
                
                # Xác định loại ảnh dựa trên tên file
                photo_type = None
                if filename.lower().startswith('avatar'):
                    photo_type = 'avatar'
                elif filename.lower().startswith('profile_cover'):
                    photo_type = 'profile_cover'
                elif filename.lower().startswith('highlight'):
                    photo_type = 'highlight'
                else:
                    # Bỏ qua file không xác định được loại
                    continue
                
                # Tạo đường dẫn tương đối bắt đầu từ "users"
                relative_path = f"users/{user_folder}/{filename}"
                
                sql = f"""INSERT INTO photos (user_id, path, type, created_at) VALUES ({user_id}, {self.escape_sql_value(relative_path)}, {self.escape_sql_value(photo_type)}, {self.escape_sql_value(datetime.now())}) ON CONFLICT DO NOTHING;"""
                self.write_sql(sql)
                photo_count += 1
        
        self.write_sql("")
        logger.info(f"Hoàn thành tạo SQL cho {photo_count} ảnh")
    
    def collect_all_data_from_csv(self, csv_file):
        """Thu thập tất cả pets, interests, languages từ CSV để insert một lần"""
        logger.info(f"Thu thập dữ liệu từ {csv_file}...")
        
        try:
            df = pd.read_csv(csv_file)
            
            all_pets = set()
            all_interests = set()
            all_languages = set()
            
            for _, row in df.iterrows():
                # Thu thập pets
                if pd.notna(row['pets']) and row['pets']:
                    pets = [pet.strip() for pet in str(row['pets']).split(' - ') if pet.strip()]
                    all_pets.update(pets)
                
                # Thu thập interests
                if pd.notna(row['interests']) and row['interests']:
                    interests = [interest.strip() for interest in str(row['interests']).split(' - ') if interest.strip()]
                    all_interests.update(interests)
                
                # Thu thập languages
                if pd.notna(row['languages']) and row['languages']:
                    languages = [lang.strip() for lang in str(row['languages']).split(' - ') if lang.strip()]
                    all_languages.update(languages)
            
            return all_pets, all_interests, all_languages
            
        except Exception as e:
            logger.error(f"Lỗi thu thập dữ liệu từ {csv_file}: {e}")
            return set(), set(), set()
    
    def insert_pets_interests_languages(self, pets, interests, languages):
        """Insert tất cả pets, interests, languages một lần"""
        logger.info("Insert pets, interests, languages...")
        
        # Insert pets
        self.write_sql("-- Insert pets")
        for pet in sorted(pets):
            sql = f"INSERT INTO pets (name) VALUES ({self.escape_sql_value(pet)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        # Insert interests  
        self.write_sql("\n-- Insert interests")
        for interest in sorted(interests):
            sql = f"INSERT INTO interests (name) VALUES ({self.escape_sql_value(interest)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        # Insert languages
        self.write_sql("\n-- Insert languages")
        for language in sorted(languages):
            sql = f"INSERT INTO languages (name) VALUES ({self.escape_sql_value(language)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
        
        self.write_sql("")
        logger.info(f"Đã insert {len(pets)} pets, {len(interests)} interests, {len(languages)} languages")

    def generate_user_pets_sql(self, pets_str, user_id):
        """Tạo SQL cho user_pets relationship"""
        if not pets_str or pd.isna(pets_str):
            return
        
        pet_names = [pet.strip() for pet in str(pets_str).split(' - ') if pet.strip()]
        
        for pet_name in pet_names:
            sql = f"""INSERT INTO users_pets (user_id, pet_id) 
                     SELECT {user_id}, id FROM pets WHERE name = {self.escape_sql_value(pet_name)} 
                     ON CONFLICT DO NOTHING;"""
            self.write_sql(sql)
    
    def generate_user_interests_sql(self, interests_str, user_id):
        """Tạo SQL cho user_interests relationship"""
        if not interests_str or pd.isna(interests_str):
            return
        
        interest_names = [interest.strip() for interest in str(interests_str).split(' - ') if interest.strip()]
        
        for interest_name in interest_names:
            sql = f"""INSERT INTO users_interests (user_id, interest_id) 
                     SELECT {user_id}, id FROM interests WHERE name = {self.escape_sql_value(interest_name)} 
                     ON CONFLICT DO NOTHING;"""
            self.write_sql(sql)
    
    def generate_user_languages_sql(self, languages_str, user_id):
        """Tạo SQL cho user_languages relationship"""
        if not languages_str or pd.isna(languages_str):
            return
        
        language_names = [lang.strip() for lang in str(languages_str).split(' - ') if lang.strip()]
        
        for language_name in language_names:
            sql = f"""INSERT INTO users_languages (user_id, language_id) 
                     SELECT {user_id}, id FROM languages WHERE name = {self.escape_sql_value(language_name)} 
                     ON CONFLICT DO NOTHING;"""
            self.write_sql(sql)
    
    def generate_pets_sql(self, pets_str, user_id):
        """Tạo SQL cho pets và trả về list tên pets"""
        if not pets_str or pd.isna(pets_str):
            return []
        
        pet_names = [pet.strip() for pet in pets_str.split(' - ') if pet.strip()]
        
        for pet_name in pet_names:
            # Insert pet
            sql = f"INSERT INTO pets (name) VALUES ({self.escape_sql_value(pet_name)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
            
            # Insert user_pet relationship
            sql = f"""INSERT INTO users_pets (user_id, pet_id) 
                     SELECT {user_id}, id FROM pets WHERE name = {self.escape_sql_value(pet_name)} 
                     ON CONFLICT DO NOTHING;"""
            self.write_sql(sql)
        
        return pet_names
    
    def generate_interests_sql(self, interests_str, user_id):
        """Tạo SQL cho interests"""
        if not interests_str or pd.isna(interests_str):
            return []
        
        interest_names = [interest.strip() for interest in interests_str.split(' - ') if interest.strip()]
        
        for interest_name in interest_names:
            # Insert interest
            sql = f"INSERT INTO interests (name) VALUES ({self.escape_sql_value(interest_name)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
            
            # Insert user_interest relationship
            sql = f"""INSERT INTO users_interests (user_id, interest_id) 
                     SELECT {user_id}, id FROM interests WHERE name = {self.escape_sql_value(interest_name)} 
                     ON CONFLICT DO NOTHING;"""
            self.write_sql(sql)
        
        return interest_names
    
    def generate_languages_sql(self, languages_str, user_id):
        """Tạo SQL cho languages"""
        if not languages_str or pd.isna(languages_str):
            return []
        
        language_names = [lang.strip() for lang in languages_str.split(' - ') if lang.strip()]
        
        for language_name in language_names:
            # Insert language
            sql = f"INSERT INTO languages (name) VALUES ({self.escape_sql_value(language_name)}) ON CONFLICT DO NOTHING;"
            self.write_sql(sql)
            
            # Insert user_language relationship
            sql = f"""INSERT INTO users_languages (user_id, language_id) 
                     SELECT {user_id}, id FROM languages WHERE name = {self.escape_sql_value(language_name)} 
                     ON CONFLICT DO NOTHING;"""
            self.write_sql(sql)
        
        return language_names
    
    def import_match_profiles_sql(self, csv_file):
        """Tạo SQL từ match_profiles.csv"""
        logger.info(f"Tạo SQL từ {csv_file}")
        
        try:
            df = pd.read_csv(csv_file)
            logger.info(f"Đọc được {len(df)} records từ {csv_file}")
            
            self.write_sql("-- Insert users and profiles from match_profiles.csv")
            
            # Hash password cố định cho tất cả users
            password_hash = '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO'
            
            for index, row in df.iterrows():
                try:
                    # Insert user
                    sql = f"""INSERT INTO users (id, username, password_hash, email, phone_number, first_name, last_name, role_id, status, created_at) 
                             VALUES ({row['id']}, {self.escape_sql_value(row['username'])}, {self.escape_sql_value(password_hash)}, 
                                    {self.escape_sql_value(row['email'])}, {self.escape_sql_value(row['phone_number'])}, 
                                    {self.escape_sql_value(row['first_name'])}, {self.escape_sql_value(row['last_name'])}, 
                                    (SELECT id FROM roles WHERE name = 'USER'), 'active', {self.escape_sql_value(datetime.now())}) 
                             ON CONFLICT (id) DO NOTHING;"""
                    self.write_sql(sql)
                    
                    # Insert profile
                    sql = f"""INSERT INTO profiles (user_id, date_of_birth, height, body_type_id, sex, orientation_id, job_industry_id, 
                                                   drink_status_id, smoke_status_id, interested_in_new_language, education_level_id, 
                                                   drop_out, location_preference, bio) 
                             VALUES ({row['id']}, {self.escape_sql_value(row['date_of_birth'])}, {self.escape_sql_value(row['height'])}, 
                                    (SELECT id FROM body_types WHERE name = {self.escape_sql_value(row['body_type'])}), 
                                    {self.escape_sql_value(row['sex'])}, 
                                    (SELECT id FROM orientations WHERE name = {self.escape_sql_value(row['orientation'])}), 
                                    (SELECT id FROM job_industries WHERE name = {self.escape_sql_value(row['job'])}), 
                                    (SELECT id FROM drink_statuses WHERE name = {self.escape_sql_value(row['drink'])}), 
                                    (SELECT id FROM smoke_statuses WHERE name = {self.escape_sql_value(row['smoke'])}), 
                                    {self.escape_sql_value(bool(row['interested_in_new_language']))}, 
                                    (SELECT id FROM education_levels WHERE name = {self.escape_sql_value(row['education_level'])}), 
                                    {self.escape_sql_value(bool(row['dropped_out_school']))}, 
                                    {self.escape_sql_value(row['location_preference'])}, 
                                    {self.escape_sql_value(row['bio'])}) 
                             ON CONFLICT (user_id) DO NOTHING;"""
                    self.write_sql(sql)
                    
                    # Insert location
                    sql = f"""INSERT INTO locations (user_id, latitudes, longitudes, country, state, city) 
                             VALUES ({row['id']}, {self.escape_sql_value(row['latitude'])}, {self.escape_sql_value(row['longitude'])}, 
                                    {self.escape_sql_value(row['country'])}, {self.escape_sql_value(row['state'])}, 
                                    {self.escape_sql_value(row['city'])}) 
                             ON CONFLICT (user_id) DO NOTHING;"""
                    self.write_sql(sql)
                    
                    # Insert user relationships (không insert vào bảng chính nữa)
                    self.generate_user_pets_sql(row['pets'], row['id'])
                    self.generate_user_interests_sql(row['interests'], row['id']) 
                    self.generate_user_languages_sql(row['languages'], row['id'])
                    
                    if (index + 1) % 100 == 0:
                        logger.info(f"Đã xử lý {index + 1} records")
                
                except Exception as e:
                    logger.error(f"Lỗi xử lý record {index}: {e}")
                    continue
            
            self.write_sql("")
            logger.info(f"Hoàn thành tạo SQL từ {csv_file}")
            
        except Exception as e:
            logger.error(f"Lỗi đọc file {csv_file}: {e}")
            raise
    
    def import_matched_pairs_sql(self, csv_file):
        """Tạo SQL từ matched_pairs.csv"""
        logger.info(f"Tạo SQL từ {csv_file}")
        
        try:
            df = pd.read_csv(csv_file)
            logger.info(f"Đọc được {len(df)} records từ {csv_file}")
            
            self.write_sql("-- Insert matches from matched_pairs.csv")
            
            for index, row in df.iterrows():
                try:
                    sql = f"""INSERT INTO matches (user1_id, user2_id, status, matched_at) 
                             VALUES ({int(row['user_id_1'])}, {int(row['user_id_2'])}, 'active', {self.escape_sql_value(datetime.now())}) 
                             ON CONFLICT DO NOTHING;"""
                    self.write_sql(sql)
                    
                    if (index + 1) % 1000 == 0:
                        logger.info(f"Đã xử lý {index + 1} matches")
                
                except Exception as e:
                    logger.error(f"Lỗi xử lý match {index}: {e}")
                    continue
            
            self.write_sql("")
            logger.info(f"Hoàn thành tạo SQL từ {csv_file}")
            
        except Exception as e:
            logger.error(f"Lỗi đọc file {csv_file}: {e}")
            raise
    
    def create_swipes_sql(self):
        """Tạo SQL cho swipes dựa trên matches"""
        logger.info("Tạo SQL cho swipes...")
        
        self.write_sql("-- Create swipes for matches")
        sql = """INSERT INTO swipes (initiator, target_user, is_like, created_at)
SELECT user1_id, user2_id, TRUE, matched_at FROM matches
UNION ALL
SELECT user2_id, user1_id, TRUE, matched_at FROM matches
ON CONFLICT DO NOTHING;"""
        self.write_sql(sql)
        self.write_sql("")
        
        logger.info("Hoàn thành tạo SQL cho swipes")
    
    def create_chat_rooms_sql(self):
        """Tạo SQL cho chat rooms dựa trên matches"""
        logger.info("Tạo SQL cho chat rooms...")
        
        self.write_sql("-- Create chat rooms for matches")
        sql = """INSERT INTO chat_rooms (user1_id, user2_id, created_at, updated_at)
SELECT user1_id, user2_id, matched_at, matched_at FROM matches
ON CONFLICT DO NOTHING;"""
        self.write_sql(sql)
        self.write_sql("")
        
        logger.info("Hoàn thành tạo SQL cho chat rooms")
    
    def create_notifications_sql(self):
        """Tạo SQL cho notifications dựa trên matches"""
        logger.info("Tạo SQL cho notifications...")
        
        self.write_sql("-- Create match notifications")
        sql = """INSERT INTO notifications (user_id, type, content, created_at)
SELECT user1_id, 'MATCH', 'You have a new match!', matched_at FROM matches
UNION ALL
SELECT user2_id, 'MATCH', 'You have a new match!', matched_at FROM matches;"""
        self.write_sql(sql)
        self.write_sql("")
        
        logger.info("Hoàn thành tạo SQL cho notifications")
    
    def run(self):
        """Chạy toàn bộ quá trình tạo SQL"""
        try:
            logger.info("Bắt đầu quá trình tạo SQL...")
            
            # Thu thập tất cả dữ liệu từ CSV trước
            all_pets, all_interests, all_languages = self.collect_all_data_from_csv('data/match_profiles.csv')
            
            # Tạo SQL cho dữ liệu tham chiếu
            self.insert_reference_data()
            
            # Insert pets, interests, languages một lần
            self.insert_pets_interests_languages(all_pets, all_interests, all_languages)
            
            # Tạo SQL từ CSV files
            self.import_match_profiles_sql('data/match_profiles.csv')
            self.import_matched_pairs_sql('data/matched_pairs.csv')
            
            # Quét và tạo SQL cho ảnh từ thư mục uploads
            self.scan_and_generate_photos_sql()
            
            # Tạo SQL cho dữ liệu bổ sung
            self.create_swipes_sql()
            self.create_chat_rooms_sql()
            self.create_notifications_sql()
            
            logger.info("Hoàn thành toàn bộ quá trình tạo SQL")
            
        except Exception as e:
            logger.error(f"Lỗi trong quá trình tạo SQL: {e}")
            raise

def main():
    """Hàm main để chạy tạo SQL"""
    try:
        generator = SQLGenerator()
        generator.open_file()
        generator.run()
        logger.info(f"Kết thúc quá trình tạo SQL. File output: {generator.output_file}")
    except Exception as e:
        logger.error(f"Lỗi: {e}")
        sys.exit(1)
    finally:
        if 'generator' in locals():
            generator.close_file()

if __name__ == "__main__":
    main()