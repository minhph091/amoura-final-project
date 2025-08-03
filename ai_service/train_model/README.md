# Quy Trình Training Model Matching - Amoura AI Service

## Tổng Quan

Pipeline training model cho hệ thống matching của Amoura được thiết kế để dự đoán khả năng match giữa hai người dùng dựa trên thông tin profile của họ. Quy trình bao gồm 3 bước chính:

1. **Sinh nhãn dữ liệu** (`generate_labels.py`)
2. **Trích xuất đặc trưng** (`feature_engineering.py`) 
3. **Training models** (`train_models.py`)

## Cấu Trúc Dữ Liệu

### Input Data
- `data/match_profiles.csv`: Thông tin profile của tất cả users
- `data/matched_pairs.csv`: Danh sách các cặp đã match (positive samples)

### Output Data
- `data/labeled_pairs.csv`: Cặp users với nhãn (1: match, 0: không match)
- `data/pairwise_features.csv`: Đặc trưng được trích xuất cho từng cặp
- `models/`: Thư mục chứa các model và artifacts

## Quy Trình Chi Tiết

### 1. Sinh Nhãn Dữ Liệu (`generate_labels.py`)

**Mục đích**: Tạo dataset có nhãn để training model

**Quy trình**:
- Đọc dữ liệu profiles và matched pairs
- Tạo positive samples từ các cặp đã match
- Sinh negative samples từ các cặp chưa match (random sampling)
- Cân bằng dataset (số lượng positive = negative)
- Shuffle và lưu kết quả

**Output**: `data/labeled_pairs.csv`

### 2. Trích Xuất Đặc Trưng (`feature_engineering.py`)

**Mục đích**: Chuyển đổi thông tin profile thành các đặc trưng số học

**Các loại đặc trưng được trích xuất**:

#### Đặc trưng cá nhân:
- **Demographics**: Tuổi, chiều cao, giới tính, orientation
- **Location**: Khoảng cách địa lý, tọa độ
- **Education**: Trình độ học vấn
- **Career**: Ngành nghề, industry

#### Đặc trưng pairwise (19 features):
- **Demographics**: Chênh lệch tuổi, chiều cao
- **Location**: Khoảng cách địa lý, location preference matching
- **Compatibility**: Orientation compatibility (3 features)
- **Lifestyle**: Drink/smoke matching, education matching
- **Interests**: Jaccard similarity cho interests, languages, pets
- **Language Learning**: Language interest matching (3 features)
- **User Features**: Cosine similarity, MAE difference của user feature vectors

**Preprocessing**:
- Text normalization và lemmatization cho bio text
- Scaling numerical features (age, height, location coordinates)
- Handling missing values và outliers
- Feature engineering cho pairwise comparisons (19 features)
- User feature vector creation cho similarity calculation

**Output**: `data/pairwise_features.csv` + các scalers/encoders trong `models/`

### 3. Training Models (`train_models.py`)

**Mục đích**: Train và so sánh hiệu suất các model khác nhau

**Các model được training**:

#### LightGBM
- **Hyperparameters**: Optimized cho performance cao nhất
- **Features**: 19 pairwise features từ feature engineering
- **Optimization**: Cross-validation, early stopping
- **Handling imbalance**: Class weights

#### Logistic Regression
- **Baseline model** với interpretability cao
- **Coefficients**: Feature importance analysis
- **Best performance**: Được chọn làm model chính

#### Random Forest
- **Ensemble method** với 100 trees
- **Feature importance**: Built-in importance scores
- **Max depth**: 10 để tránh overfitting

**Evaluation Metrics**:
- Accuracy, Precision, Recall, F1-score
- ROC AUC (metric chính)
- Cross-validation scores

**Model Selection**:
- Chọn model có ROC AUC cao nhất (Logistic Regression)
- Lưu best model và artifacts
- Tạo training summary

## Cách Chạy Pipeline

### Chạy toàn bộ pipeline:
```bash
cd ai_service/train_model
python main.py
```

### Chạy từng bước riêng lẻ:
```bash
# 1. Sinh nhãn
python generate_labels.py

# 2. Trích xuất đặc trưng  
python feature_engineering.py

# 3. Training models
python train_models.py
```

## Output Files

### Data Files:
- `labeled_pairs.csv`: 33,174 cặp với nhãn
- `pairwise_features.csv`: 19 pairwise features cho mỗi cặp

### Model Files:
- `best_overall_model.joblib`: Model tốt nhất (LightGBM)
- `best_model_summary.json`: Thông tin model được chọn
- `training_summary.json`: Kết quả training chi tiết

### Artifacts:
- Các scalers cho numerical features (age, height, latitude, longitude)
- TF-IDF vectorizer cho bio text preprocessing
- One-hot encoders cho categorical features (education, job industry, etc.)
- Top categories/items cho multi-value features (interests, languages, pets)
- Pairwise feature scaler và input columns cho model inference
- User features final columns cho feature vector creation

## Performance Metrics

### Kết Quả Training Thực Tế:

| Model | ROC AUC | Accuracy | Precision | Recall | F1-Score |
|-------|---------|----------|-----------|--------|----------|
| **Logistic Regression** | 0.8790 | 86.15% | 78.33% | 99.94% | 87.83% |
| **LightGBM** | 0.8779 | 86.13% | 78.34% | 99.88% | 87.81% |
| **Random Forest** | 0.8708 | 86.15% | 78.33% | 99.94% | 87.83% |

### Nhận Xét:
- **Logistic Regression** đạt performance tốt nhất với ROC AUC cao nhất (0.8790)
- Tất cả models đều có recall rất cao (>99%) do class imbalance
- Precision ~78% cho thấy model có khả năng dự đoán chính xác khá tốt
- F1-score ~88% cho thấy cân bằng giữa precision và recall
- Performance của 3 models rất gần nhau, chênh lệch ROC AUC < 0.01

## Lưu Ý Kỹ Thuật

1. **Data Imbalance**: Sử dụng class weights và balanced sampling
2. **Feature Engineering**: Extensive preprocessing cho text và categorical data
3. **Hyperparameter Tuning**: Optimized parameters cho LightGBM
4. **Cross-validation**: 3-fold CV để validate model performance
5. **Model Persistence**: Lưu tất cả artifacts cần thiết cho inference

## Deployment

Model được training sẽ được sử dụng trong `ai_service/app/ml/predictor.py` để dự đoán matching probability cho các cặp users mới. 