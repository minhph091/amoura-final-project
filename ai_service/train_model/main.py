"""
Pipeline train model cho Amoura AI Service.

Script này thực hiện toàn bộ pipeline từ sinh nhãn đến train model.
"""

import os
import sys

# Import config
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from app.core.config import get_settings

from generate_labels import generate_labels
from feature_engineering import extract_features
from train_models import train_all_models

def main():
    """Chạy toàn bộ pipeline train model"""
    print("NLTK data đã được tải thành công")
    print("=== BẮT ĐẦU PIPELINE TRAIN MODEL ===")
    
    # Get settings
    settings = get_settings()
    
    print(f"📁 Models directory: {settings.models_path}")
    print(f"🎯 Match threshold: {settings.MATCH_PROBABILITY_THRESHOLD}")
    
    # 1. Sinh nhãn cho các cặp user
    print("\n1. Sinh nhãn cho các cặp user...")
    generate_labels()
    
    # 2. Trích xuất đặc trưng cho các cặp
    print("\n2. Trích xuất đặc trưng cho các cặp...")
    extract_features()
    
    # 3. Train các models
    print("\n3. Train các models...")
    models_results = train_all_models()
    
    print("\n=== HOÀN THÀNH PIPELINE TRAIN MODEL ===")
    print("Các file đã được tạo:")
    print("- data/labeled_pairs.csv: Cặp user với nhãn")
    print("- data/pairwise_features.csv: Đặc trưng của các cặp")
    print(f"- {settings.models_path}: Các model và artifacts")
    
    print("\n✅ Pipeline hoàn thành thành công!")

if __name__ == "__main__":
    main() 