import os
import sys
from generate_labels import generate_labels
from feature_engineering import extract_features
from train_models import train_all_models

def main():
    """Chạy toàn bộ pipeline train model"""
    print("=== BẮT ĐẦU PIPELINE TRAIN MODEL ===")
    
    # Bước 1: Sinh nhãn
    print("\n1. Sinh nhãn cho các cặp user...")
    labeled_pairs = generate_labels()
    
    # Bước 2: Trích xuất đặc trưng
    print("\n2. Trích xuất đặc trưng cho các cặp...")
    features_df = extract_features()
    
    # Bước 3: Train models
    print("\n3. Train các models...")
    models_results = train_all_models()
    
    print("\n=== HOÀN THÀNH PIPELINE TRAIN MODEL ===")
    print("Các file đã được tạo:")
    print("- data/labeled_pairs.csv: Cặp user với nhãn")
    print("- data/pairwise_features.csv: Đặc trưng của các cặp")
    print("- ml_models/: Các model và artifacts")
    
    return models_results

if __name__ == "__main__":
    try:
        models_results = main()
        print("\n✅ Pipeline hoàn thành thành công!")
    except Exception as e:
        print(f"\n❌ Lỗi: {e}")
        sys.exit(1) 