# Pipeline Train Model - AI Service

Pipeline để train các model dự đoán matching cho ứng dụng dating.

## Cấu trúc thư mục

```
train_model/
├── data/                          # Dữ liệu đầu vào
│   ├── match_profiles.csv         # Thông tin người dùng
│   ├── matched_pairs.csv          # Cặp đã match
│   ├── labeled_pairs.csv          # Cặp với nhãn (được tạo)
│   └── pairwise_features.csv      # Đặc trưng cặp (được tạo)
├── models/                        # Models và artifacts (được tạo)
│   ├── best_overall_model.joblib # Model tốt nhất
│   ├── best_model_summary.json   # Thông tin model tốt nhất
│   ├── training_summary.json     # Tóm tắt training
│   └── ...                       # Các model và scaler khác
├── inspect_data.py                # Kiểm tra dữ liệu
├── generate_labels.py             # Sinh nhãn cho cặp user
├── feature_engineering.py         # Trích xuất đặc trưng
├── train_models.py               # Train 3 models
├── main.py                       # Pipeline chính
└── README.md                     # Hướng dẫn này
```

## Sử dụng

### 1. Kiểm tra dữ liệu
```bash
python inspect_data.py
```

### 2. Chạy từng bước riêng lẻ

**Sinh nhãn:**
```bash
python generate_labels.py
```

**Trích xuất đặc trưng:**
```bash
python feature_engineering.py
```

**Train models:**
```bash
python train_models.py
```

### 3. Chạy toàn bộ pipeline
```bash
python main.py
```

## Output

Sau khi chạy pipeline, các file sau sẽ được tạo:

### Trong thư mục `data/`:
- `labeled_pairs.csv`: Cặp user với nhãn (1: match, 0: không match)
- `pairwise_features.csv`: Đặc trưng của các cặp

### Trong thư mục `models/`:
- `best_overall_model.joblib`: Model tốt nhất
- `best_overall_model_scaler.joblib`: Scaler cho model tốt nhất (nếu có)
- `best_model_summary.json`: Thông tin model tốt nhất
- `training_summary.json`: Tóm tắt kết quả training
- `pairwise_model_input_columns.joblib`: Danh sách tên cột features
- `lightgbm.joblib`: Model LightGBM
- `logistic_regression.joblib`: Model Logistic Regression  
- `logistic_regression_scaler.joblib`: Scaler cho Logistic Regression
- `random_forest.joblib`: Model Random Forest
- `*_metrics.json`: Metrics của từng model

## Models được train

1. **LightGBM**: Gradient boosting, không cần scale features
2. **Logistic Regression**: Linear model, cần scale features
3. **Random Forest**: Ensemble model, không cần scale features

## Metrics đánh giá

- Accuracy: Độ chính xác tổng thể
- Precision: Độ chính xác dự đoán positive
- Recall: Độ bao phủ positive samples
- F1-Score: Trung bình điều hòa precision và recall
- ROC AUC: Diện tích dưới đường ROC

## Đặc trưng được sử dụng

- **Basic differences**: age_diff, height_diff
- **Geographical**: geo_distance_km
- **Compatibility**: orientation_compatible, drink_match, smoke_match, education_match
- **Similarity**: interests_jaccard, languages_jaccard, pets_jaccard
- **Preferences**: language_interest_match

## Lưu ý

- Dữ liệu được chia train/test với tỷ lệ 80/20
- Negative samples được sinh ngẫu nhiên với số lượng bằng positive samples
- Random state được set để đảm bảo kết quả reproducible 