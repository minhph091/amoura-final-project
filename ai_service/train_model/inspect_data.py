import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Đường dẫn dữ liệu
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
PROFILE_PATH = os.path.join(DATA_DIR, 'match_profiles.csv')
MATCHED_PATH = os.path.join(DATA_DIR, 'matched_pairs.csv')

# Đọc dữ liệu
profiles = pd.read_csv(PROFILE_PATH)
matched_pairs = pd.read_csv(MATCHED_PATH)

# Thông tin tổng quan
print('--- Thông tin dữ liệu người dùng ---')
print(profiles.info())
print(profiles.head())
print('\n--- Thống kê mô tả ---')
print(profiles.describe(include='all'))

print('\n--- Thông tin dữ liệu cặp match ---')
print(matched_pairs.info())
print(matched_pairs.head())
print(f"Số lượng cặp match: {len(matched_pairs)}")

# Kiểm tra phân bố tuổi
profiles['age'] = pd.to_datetime('today').year - pd.to_datetime(profiles['date_of_birth'], errors='coerce').dt.year
plt.figure(figsize=(8,4))
sns.histplot(profiles['age'].dropna(), bins=20, kde=True)
plt.title('Phân bố tuổi người dùng')
plt.xlabel('Tuổi')
plt.ylabel('Số lượng')
plt.tight_layout()
plt.show()

# Phân bố giới tính
plt.figure(figsize=(6,3))
sns.countplot(y=profiles['sex'])
plt.title('Phân bố giới tính')
plt.tight_layout()
plt.show()

# Phân bố orientation
plt.figure(figsize=(6,3))
sns.countplot(y=profiles['orientation'])
plt.title('Phân bố orientation')
plt.tight_layout()
plt.show()

# Số lượng match mỗi user
user_match_counts = pd.concat([matched_pairs['user_id_1'], matched_pairs['user_id_2']]).value_counts()
plt.figure(figsize=(8,4))
sns.histplot(user_match_counts, bins=30, kde=True)
plt.title('Số lượng match mỗi user')
plt.xlabel('Số match')
plt.ylabel('Số user')
plt.tight_layout()
plt.show()

# Kiểm tra user_id có trong profile không
all_user_ids = set(profiles['id'])
matched_user_ids = set(matched_pairs['user_id_1']).union(set(matched_pairs['user_id_2']))
missing_users = matched_user_ids - all_user_ids
print(f"Số user_id trong matched_pairs nhưng không có trong profile: {len(missing_users)}")
if missing_users:
    print(f"Các user_id thiếu: {list(missing_users)[:10]} ...")

# --- Liệt kê các giá trị unique của các trường categorical ---
def print_unique_values(col):
    print(f"\nCác giá trị unique của '{col}':")
    print(sorted(profiles[col].dropna().unique()))

for col in [
    'body_type', 'sex', 'orientation', 'job', 'drink', 'smoke', 'education_level']:
    print_unique_values(col)

# --- Đặc biệt với pets, interests, languages: tách value ---
def split_and_flatten(series, sep='-'):
    values = set()
    for item in series.dropna():
        for v in str(item).split(sep):
            v = v.strip().lower()
            if v:
                values.add(v)
    return sorted(values)

for col in ['pets', 'interests', 'languages']:
    unique_values = split_and_flatten(profiles[col])
    print(f"\nCác giá trị riêng biệt của '{col}':")
    print(unique_values)