import pandas as pd
import numpy as np
import os
from itertools import combinations
import random

# Đường dẫn dữ liệu
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
PROFILE_PATH = os.path.join(DATA_DIR, 'match_profiles.csv')
MATCHED_PATH = os.path.join(DATA_DIR, 'matched_pairs.csv')

def generate_labels():
    """
    Sinh nhãn cho các cặp user:
    - Label 1: Cặp có trong matched_pairs.csv (positive samples)
    - Label 0: Cặp ngẫu nhiên chưa match (negative samples)
    """
    print("Đang đọc dữ liệu...")
    profiles = pd.read_csv(PROFILE_PATH)
    matched_pairs = pd.read_csv(MATCHED_PATH)
    
    # Tạo set các cặp đã match
    positive_pairs = set()
    for _, row in matched_pairs.iterrows():
        user1, user2 = row['user_id_1'], row['user_id_2']
        # Đảm bảo user1 < user2 để tránh trùng lặp
        if user1 < user2:
            positive_pairs.add((user1, user2))
        else:
            positive_pairs.add((user2, user1))
    
    print(f"Số lượng cặp positive (đã match): {len(positive_pairs)}")
    
    # Lấy danh sách user_id có trong profiles
    valid_user_ids = set(profiles['id'])
    print(f"Số lượng user hợp lệ: {len(valid_user_ids)}")
    
    # Sinh negative samples (cặp chưa match)
    all_possible_pairs = set()
    for user1, user2 in combinations(valid_user_ids, 2):
        all_possible_pairs.add((user1, user2))
    
    # Lấy các cặp chưa match
    negative_pairs = all_possible_pairs - positive_pairs
    print(f"Số lượng cặp negative (chưa match): {len(negative_pairs)}")
    
    # Chọn số lượng negative samples bằng với positive (hoặc ít hơn nếu không đủ)
    n_negative = min(len(negative_pairs), len(positive_pairs))
    negative_samples = random.sample(list(negative_pairs), n_negative)
    
    # Tạo DataFrame kết quả
    data = []
    
    # Thêm positive samples
    for user1, user2 in positive_pairs:
        data.append({
            'user_id_1': user1,
            'user_id_2': user2,
            'label': 1
        })
    
    # Thêm negative samples
    for user1, user2 in negative_samples:
        data.append({
            'user_id_1': user1,
            'user_id_2': user2,
            'label': 0
        })
    
    labeled_pairs = pd.DataFrame(data)
    
    # Shuffle dữ liệu
    labeled_pairs = labeled_pairs.sample(frac=1, random_state=42).reset_index(drop=True)
    
    print(f"\nTổng số cặp được sinh nhãn: {len(labeled_pairs)}")
    print(f"Số positive samples: {len(labeled_pairs[labeled_pairs['label'] == 1])}")
    print(f"Số negative samples: {len(labeled_pairs[labeled_pairs['label'] == 0])}")
    
    # Lưu kết quả
    output_path = os.path.join(DATA_DIR, 'labeled_pairs.csv')
    labeled_pairs.to_csv(output_path, index=False)
    print(f"Đã lưu kết quả vào: {output_path}")
    
    return labeled_pairs

if __name__ == "__main__":
    labeled_pairs = generate_labels() 