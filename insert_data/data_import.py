#!/usr/bin/env python3
"""
Script để nhập dữ liệu từ CSV files vào PostgreSQL database
Dữ liệu từ online dating app
"""

import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor
import hashlib
import os
from datetime import datetime
import logging
import sys

# Cấu hình logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Cấu hình database
DB_CONFIG = {
    'host': 'localhost',
    'database': 'amoura',
    'user': 'postgres',
    'password': '123456789',
    'port': 5432
}

class DataImporter:
    def __init__(self, db_config):
        self.db_config = db_config
        self.conn = None
        self.cursor = None
        
    def connect(self):
        """Kết nối đến database"""
        try:
            self.conn = psycopg2.connect(**self.db_config)
            self.cursor = self.conn.cursor()
            logger.info("Kết nối database thành công")
        except Exception as e:
            logger.error(f"Lỗi kết nối database: {e}")
            raise
    
    def disconnect(self):
        """Đóng kết nối database"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        logger.info("Đã đóng kết nối database")
    
    def hash_password(self, password):
        """Hash password bằng SHA-256"""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def insert_reference_data(self):
        """Chèn dữ liệu tham chiếu cơ bản"""
        logger.info("Bắt đầu chèn dữ liệu tham chiếu...")
        
        # Body types
        body_types = [
            'athletic', 'muscular', 'slim', 'curvy', 'plus-size', 
            'average', 'prefer not to say'
        ]
        
        for body_type in body_types:
            self.cursor.execute(
                "INSERT INTO body_types (name) VALUES (%s) ON CONFLICT DO NOTHING",
                (body_type,)
            )
        
        # Orientations
        orientations = [
            ('straight', 'Heterosexual'),
            ('homosexual', 'Homosexual'),
            ('bisexual', 'Bisexual')
        ]
        
        for name, description in orientations:
            self.cursor.execute(
                "INSERT INTO orientations (name, description) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                (name, description)
            )
        
        # Job industries
        job_industries = [
            'healthcare/medical', 'information technology (it)', 'finance/accounting',
            'education/training', 'art/creative', 'engineering/architecture',
            'business/management', 'government/legal', 'hospitality/tourism',
            'skilled trades/labor', 'student', 'unemployed', 'other',
            'prefer not to say'
        ]
        
        for industry in job_industries:
            self.cursor.execute(
                "INSERT INTO job_industries (name) VALUES (%s) ON CONFLICT DO NOTHING",
                (industry,)
            )
        
        # Drink statuses
        drink_statuses = [
            'socially', 'regularly', 'occasionally', 'never', 'prefer not to say'
        ]
        
        for status in drink_statuses:
            self.cursor.execute(
                "INSERT INTO drink_statuses (name) VALUES (%s) ON CONFLICT DO NOTHING",
                (status,)
            )
        
        # Smoke statuses
        smoke_statuses = [
            'regularly', 'occasionally', 'former smoker', 'never', 'prefer not to say'
        ]
        
        for status in smoke_statuses:
            self.cursor.execute(
                "INSERT INTO smoke_statuses (name) VALUES (%s) ON CONFLICT DO NOTHING",
                (status,)
            )
        
        # Education levels
        education_levels = [
            'high school', 'college diploma / associate degree', 'bachelor\'s degree',
            'master\'s degree', 'doctorate', 'prefer not to say'
        ]
        
        for level in education_levels:
            self.cursor.execute(
                "INSERT INTO education_levels (name) VALUES (%s) ON CONFLICT DO NOTHING",
                (level,)
            )
        
        # Note: Roles are already inserted by migration V4__create_role.sql
        # USER, MODERATOR, ADMIN roles are created there
        
        # Note: message_types and premium_plans are not inserted here
        # They should be inserted by migrations if needed
        
        self.conn.commit()
        logger.info("Hoàn thành chèn dữ liệu tham chiếu")
    
    def get_reference_id(self, table, name):
        """Lấy ID từ bảng tham chiếu"""
        self.cursor.execute(f"SELECT id FROM {table} WHERE name = %s", (name,))
        result = self.cursor.fetchone()
        return result[0] if result else None
    
    def insert_pets(self, pets_str):
        """Chèn pets và trả về list pet IDs"""
        if not pets_str or pd.isna(pets_str):
            return []
        
        pet_names = [pet.strip() for pet in pets_str.split(' - ') if pet.strip()]
        pet_ids = []
        
        for pet_name in pet_names:
            # Kiểm tra xem pet đã tồn tại chưa
            self.cursor.execute("SELECT id FROM pets WHERE name = %s", (pet_name,))
            result = self.cursor.fetchone()
            
            if result:
                pet_ids.append(result[0])
            else:
                # Chèn pet mới
                self.cursor.execute(
                    "INSERT INTO pets (name) VALUES (%s) RETURNING id",
                    (pet_name,)
                )
                pet_ids.append(self.cursor.fetchone()[0])
        
        return pet_ids
    
    def insert_interests(self, interests_str):
        """Chèn interests và trả về list interest IDs"""
        if not interests_str or pd.isna(interests_str):
            return []
        
        interest_names = [interest.strip() for interest in interests_str.split(' - ') if interest.strip()]
        interest_ids = []
        
        for interest_name in interest_names:
            # Kiểm tra xem interest đã tồn tại chưa
            self.cursor.execute("SELECT id FROM interests WHERE name = %s", (interest_name,))
            result = self.cursor.fetchone()
            
            if result:
                interest_ids.append(result[0])
            else:
                # Chèn interest mới
                self.cursor.execute(
                    "INSERT INTO interests (name) VALUES (%s) RETURNING id",
                    (interest_name,)
                )
                interest_ids.append(self.cursor.fetchone()[0])
        
        return interest_ids
    
    def insert_languages(self, languages_str):
        """Chèn languages và trả về list language IDs"""
        if not languages_str or pd.isna(languages_str):
            return []
        
        language_names = [lang.strip() for lang in languages_str.split(' - ') if lang.strip()]
        language_ids = []
        
        for language_name in language_names:
            # Kiểm tra xem language đã tồn tại chưa
            self.cursor.execute("SELECT id FROM languages WHERE name = %s", (language_name,))
            result = self.cursor.fetchone()
            
            if result:
                language_ids.append(result[0])
            else:
                # Chèn language mới
                self.cursor.execute(
                    "INSERT INTO languages (name) VALUES (%s) RETURNING id",
                    (language_name,)
                )
                language_ids.append(self.cursor.fetchone()[0])
        
        return language_ids
    
    def create_swipes_for_matches(self):
        """Tạo swipes cho các cặp đã match"""
        logger.info("Tạo swipes cho các cặp đã match...")
        
        try:
            # Lấy tất cả matches
            self.cursor.execute("SELECT user1_id, user2_id, matched_at FROM matches")
            matches = self.cursor.fetchall()
            
            for match in matches:
                user1_id, user2_id, matched_at = match
                
                # Tạo swipes cho cả 2 chiều (user1 like user2 và user2 like user1)
                # Swipe từ user1 đến user2
                self.cursor.execute("""
                    INSERT INTO swipes (initiator, target_user, is_like, created_at)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT DO NOTHING
                """, (user1_id, user2_id, True, matched_at))
                
                # Swipe từ user2 đến user1
                self.cursor.execute("""
                    INSERT INTO swipes (initiator, target_user, is_like, created_at)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT DO NOTHING
                """, (user2_id, user1_id, True, matched_at))
            
            self.conn.commit()
            logger.info(f"Đã tạo swipes cho {len(matches)} cặp match")
            
        except Exception as e:
            logger.error(f"Lỗi tạo swipes: {e}")
            raise
    
    def create_chat_rooms_for_matches(self):
        """Tạo chat rooms cho các cặp đã match"""
        logger.info("Tạo chat rooms cho các cặp đã match...")
        
        try:
            # Lấy tất cả matches
            self.cursor.execute("SELECT user1_id, user2_id, matched_at FROM matches")
            matches = self.cursor.fetchall()
            
            for match in matches:
                user1_id, user2_id, matched_at = match
                
                # Tạo chat room
                self.cursor.execute("""
                    INSERT INTO chat_rooms (user1_id, user2_id, created_at, updated_at)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT DO NOTHING
                """, (user1_id, user2_id, matched_at.replace(tzinfo=None), matched_at.replace(tzinfo=None)))
            
            self.conn.commit()
            logger.info(f"Đã tạo chat rooms cho {len(matches)} cặp match")
            
        except Exception as e:
            logger.error(f"Lỗi tạo chat rooms: {e}")
            raise
    
    def create_sample_notifications(self):
        """Tạo thông báo match cho các cặp đã match"""
        logger.info("Tạo thông báo match cho các cặp đã match...")
        
        try:
            # Lấy tất cả matches
            self.cursor.execute("SELECT user1_id, user2_id, matched_at FROM matches")
            matches = self.cursor.fetchall()
            
            notification_count = 0
            for match in matches:
                user1_id, user2_id, matched_at = match
                
                # Tạo thông báo match cho user1
                self.cursor.execute("""
                    INSERT INTO notifications (user_id, type, content, created_at)
                    VALUES (%s, %s, %s, %s)
                """, (user1_id, 'MATCH', 'You have a new match!', matched_at.replace(tzinfo=None)))
                
                # Tạo thông báo match cho user2
                self.cursor.execute("""
                    INSERT INTO notifications (user_id, type, content, created_at)
                    VALUES (%s, %s, %s, %s)
                """, (user2_id, 'MATCH', 'You have a new match!', matched_at.replace(tzinfo=None)))
                
                notification_count += 2
            
            self.conn.commit()
            logger.info(f"Đã tạo {notification_count} thông báo match")
            
        except Exception as e:
            logger.error(f"Lỗi tạo thông báo match: {e}")
            raise
    
    def import_match_profiles(self, csv_file):
        """Nhập dữ liệu từ match_profiles.csv"""
        logger.info(f"Bắt đầu nhập dữ liệu từ {csv_file}")
        
        try:
            df = pd.read_csv(csv_file)
            logger.info(f"Đọc được {len(df)} records từ {csv_file}")
            
            # Lấy role ID mặc định
            self.cursor.execute("SELECT id FROM roles WHERE name = 'USER'")
            default_role_id = self.cursor.fetchone()[0]
            
            for index, row in df.iterrows():
                try:
                    # Chèn user
                    self.cursor.execute("""
                        INSERT INTO users (id, username, password_hash, email, phone_number, 
                                         first_name, last_name, role_id, status, created_at)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO NOTHING
                    """, (
                        row['id'],
                        row['username'],
                        self.hash_password(row['password']),
                        row['email'],
                        row['phone_number'],
                        row['first_name'],
                        row['last_name'],
                        default_role_id,
                        'active',
                        datetime.now().replace(tzinfo=None)
                    ))
                    
                    # Chèn profile
                    body_type_id = self.get_reference_id('body_types', row['body_type'])
                    orientation_id = self.get_reference_id('orientations', row['orientation'])
                    job_industry_id = self.get_reference_id('job_industries', row['job'])
                    drink_status_id = self.get_reference_id('drink_statuses', row['drink'])
                    smoke_status_id = self.get_reference_id('smoke_statuses', row['smoke'])
                    education_level_id = self.get_reference_id('education_levels', row['education_level'])
                    
                    self.cursor.execute("""
                        INSERT INTO profiles (user_id, date_of_birth, height, body_type_id, sex,
                                            orientation_id, job_industry_id, drink_status_id,
                                            smoke_status_id, interested_in_new_language,
                                            education_level_id, drop_out, location_preference, bio)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (user_id) DO NOTHING
                    """, (
                        row['id'],
                        row['date_of_birth'],
                        row['height'],
                        body_type_id,
                        row['sex'],
                        orientation_id,
                        job_industry_id,
                        drink_status_id,
                        smoke_status_id,
                        bool(row['interested_in_new_language']),
                        education_level_id,
                        bool(row['dropped_out_school']),
                        row['location_preference'],
                        row['bio']
                    ))
                    
                    # Chèn location
                    self.cursor.execute("""
                        INSERT INTO locations (user_id, latitudes, longitudes, country, state, city)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT (user_id) DO NOTHING
                    """, (
                        row['id'],
                        row['latitude'],
                        row['longitude'],
                        row['country'],
                        row['state'],
                        row['city']
                    ))
                    
                    # Chèn pets
                    pet_ids = self.insert_pets(row['pets'])
                    for pet_id in pet_ids:
                        self.cursor.execute("""
                            INSERT INTO users_pets (user_id, pet_id) VALUES (%s, %s)
                            ON CONFLICT DO NOTHING
                        """, (row['id'], pet_id))
                    
                    # Chèn interests
                    interest_ids = self.insert_interests(row['interests'])
                    for interest_id in interest_ids:
                        self.cursor.execute("""
                            INSERT INTO users_interests (user_id, interest_id) VALUES (%s, %s)
                            ON CONFLICT DO NOTHING
                        """, (row['id'], interest_id))
                    
                    # Chèn languages
                    language_ids = self.insert_languages(row['languages'])
                    for language_id in language_ids:
                        self.cursor.execute("""
                            INSERT INTO users_languages (user_id, language_id) VALUES (%s, %s)
                            ON CONFLICT DO NOTHING
                        """, (row['id'], language_id))
                    
                    if (index + 1) % 100 == 0:
                        self.conn.commit()
                        logger.info(f"Đã xử lý {index + 1} records")
                
                except Exception as e:
                    logger.error(f"Lỗi xử lý record {index}: {e}")
                    continue
            
            self.conn.commit()
            logger.info(f"Hoàn thành nhập dữ liệu từ {csv_file}")
            
        except Exception as e:
            logger.error(f"Lỗi đọc file {csv_file}: {e}")
            raise
    
    def import_matched_pairs(self, csv_file):
        """Nhập dữ liệu từ matched_pairs.csv"""
        logger.info(f"Bắt đầu nhập dữ liệu từ {csv_file}")
        
        try:
            df = pd.read_csv(csv_file)
            logger.info(f"Đọc được {len(df)} records từ {csv_file}")
            
            for index, row in df.iterrows():
                try:
                    # Chèn match
                    self.cursor.execute("""
                        INSERT INTO matches (user1_id, user2_id, status, matched_at)
                        VALUES (%s, %s, %s, %s)
                        ON CONFLICT DO NOTHING
                    """, (
                        int(row['user_id_1']),
                        int(row['user_id_2']),
                        'active',
                        datetime.now().replace(tzinfo=None)
                    ))
                    
                    if (index + 1) % 1000 == 0:
                        self.conn.commit()
                        logger.info(f"Đã xử lý {index + 1} matches")
                
                except Exception as e:
                    logger.error(f"Lỗi xử lý match {index}: {e}")
                    continue
            
            self.conn.commit()
            logger.info(f"Hoàn thành nhập dữ liệu từ {csv_file}")
            
        except Exception as e:
            logger.error(f"Lỗi đọc file {csv_file}: {e}")
            raise
    
    def run(self):
        """Chạy toàn bộ quá trình import dữ liệu"""
        try:
            logger.info("Bắt đầu quá trình import dữ liệu...")
            
            # Chèn dữ liệu tham chiếu
            self.insert_reference_data()
            
            # Import dữ liệu từ CSV files
            self.import_match_profiles('data/match_profiles.csv')
            self.import_matched_pairs('data/matched_pairs.csv')
            
            # Tạo dữ liệu bổ sung
            self.create_swipes_for_matches()
            self.create_chat_rooms_for_matches()
            self.create_sample_notifications()
            
            logger.info("Hoàn thành toàn bộ quá trình import dữ liệu")
            
        except Exception as e:
            logger.error(f"Lỗi trong quá trình import: {e}")
            self.conn.rollback()
            raise

def main():
    """Hàm main để chạy import dữ liệu"""
    try:
        importer = DataImporter(DB_CONFIG)
        importer.connect()
        importer.run()
        logger.info("Kết thúc quá trình import dữ liệu")
    except Exception as e:
        logger.error(f"Lỗi: {e}")
        sys.exit(1)
    finally:
        if 'importer' in locals():
            importer.disconnect()

if __name__ == "__main__":
    main() 