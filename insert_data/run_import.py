#!/usr/bin/env python3
"""
Script chính để chạy toàn bộ quá trình setup database và import dữ liệu
"""

import logging
import sys
from setup_database import DatabaseSetup, DB_CONFIG
from data_import import DataImporter

# Cấu hình logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    """Hàm main chính"""
    try:
        logger.info("=== BẮT ĐẦU QUÁ TRÌNH SETUP VÀ IMPORT DỮ LIỆU ===")
        
        # Bước 1: Setup database
        logger.info("Bước 1: Setup database...")
        setup = DatabaseSetup(DB_CONFIG)
        setup.setup_database('amoura')
        logger.info("✅ Setup database hoàn thành")
        
        # Bước 2: Import dữ liệu
        logger.info("Bước 2: Import dữ liệu...")
        importer = DataImporter(DB_CONFIG)
        importer.run_import()
        logger.info("✅ Import dữ liệu hoàn thành")
        
        logger.info("=== HOÀN THÀNH TOÀN BỘ QUÁ TRÌNH ===")
        logger.info("Database 'amoura' đã được setup và import dữ liệu thành công!")
        
    except Exception as e:
        logger.error(f"❌ Lỗi trong quá trình thực hiện: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 