#!/usr/bin/env python3
"""
Script để setup database và chạy migrations
"""

import psycopg2
import os
import logging
from pathlib import Path

# Cấu hình logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Cấu hình database
DB_CONFIG = {
    'host': 'localhost',
    'user': 'postgres',
    'password': '123456789',
    'port': 5432
}

class DatabaseSetup:
    def __init__(self, db_config):
        self.db_config = db_config
        self.conn = None
        self.cursor = None
    
    def connect_to_postgres(self):
        """Kết nối đến PostgreSQL server (không phải database cụ thể)"""
        try:
            self.conn = psycopg2.connect(**self.db_config)
            self.conn.autocommit = True
            self.cursor = self.conn.cursor()
            logger.info("Kết nối PostgreSQL server thành công")
        except Exception as e:
            logger.error(f"Lỗi kết nối PostgreSQL server: {e}")
            raise
    
    def disconnect(self):
        """Đóng kết nối"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        logger.info("Đã đóng kết nối database")
    
    
    def setup_database(self, db_name):
        """Setup toàn bộ database"""
        try:
            logger.info("Bắt đầu setup database...")
            
            # Kết nối PostgreSQL server
            self.connect_to_postgres()
            
            logger.info("Setup database hoàn thành")
            
        except Exception as e:
            logger.error(f"Lỗi setup database: {e}")
            raise
        finally:
            self.disconnect()

def main():
    """Hàm main"""
    logger.info("Bắt đầu setup database")
    
    setup = DatabaseSetup(DB_CONFIG)
    setup.setup_database('amoura')
    
    logger.info("Kết thúc setup database")

if __name__ == "__main__":
    main() 