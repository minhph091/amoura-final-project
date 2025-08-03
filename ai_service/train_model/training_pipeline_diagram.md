# Sơ Đồ Quy Trình Training Model Matching

```mermaid
flowchart TD
    %% Input Data
    A[Input Data] --> B[Data Preparation]
    
    %% Data Preparation
    B --> C[Profiles Data<br/>match_profiles.csv]
    B --> D[Matched Pairs Data<br/>matched_pairs.csv]
    
    %% Step 1: Label Generation
    C --> E[Step 1: Generate Labels]
    D --> E
    E --> F[Create Positive Samples<br/>from matched_pairs.csv]
    E --> G[Generate Negative Samples<br/>random sampling]
    E --> H[Balance Dataset<br/>positive = negative]
    F --> I[labeled_pairs.csv]
    G --> I
    H --> I
    
    %% Step 2: Feature Engineering
    I --> J[Step 2: Feature Engineering]
    C --> J

    J --> L[Create User Feature Vectors]
    L --> M[Pairwise Feature Extraction]
    
    M --> N[Demographics Features<br/>age_diff, height_diff]
    M --> O[Location Features<br/>geo_distance, location_pref]
    M --> P[Compatibility Features<br/>orientation_compatibility]
    M --> Q[Lifestyle Features<br/>drink_match, smoke_match, education_match]
    M --> R[Interest Features<br/>interests_jaccard, languages_jaccard, pets_jaccard]
    M --> S[Language Learning Features<br/>language_interest_match]
    M --> T[User Feature Similarity<br/>cosine_sim, mae_diff]
    
    N --> U[Save Scalers & Encoders]
    O --> U
    P --> U
    Q --> U
    R --> U
    S --> U
    T --> U
    
    U --> V[pairwise_features.csv<br/>19 features total]
    
    %% Step 3: Model Training
    V --> W[Step 3: Model Training]
    
    W --> X[Split Data<br/>Train/Validation]
    X --> Y[Train Multiple Models]
    
    Y --> Z[Logistic Regression]
    Y --> AA[LightGBM]
    Y --> BB[Random Forest]
    
    Z --> CC[Evaluate Models]
    AA --> CC
    BB --> CC
    
    CC --> DD[Compare Performance<br/>ROC AUC, Accuracy, Precision, Recall, F1]
    DD --> EE[Select Best Model<br/>Logistic Regression<br/>ROC AUC: 0.8790]
    
    %% Save Results
    EE --> FF[Save Best Model<br/>best_overall_model.joblib]
    EE --> GG[Save Training Summary<br/>training_summary.json]
    EE --> HH[Save Model Artifacts<br/>scalers, encoders, etc.]
    
    %% Styling
    classDef inputData fill:#e1f5fe
    classDef process fill:#f3e5f5
    classDef output fill:#e8f5e8
    classDef model fill:#fff3e0
    
    class A,C,D inputData
    class B,E,J,K,L,M,N,O,P,Q,R,S,T,U,W,X,Y,Z,AA,BB,CC,DD process
    class I,V,EE,FF,GG,HH output
    class Z,AA,BB model
```

## Chi Tiết Các Bước

### 1. Data Preparation
- **Input**: `match_profiles.csv` (thông tin users) + `matched_pairs.csv` (cặp đã match)
- **Output**: Dữ liệu sạch và chuẩn bị cho training

### 2. Label Generation
- **Positive samples**: Từ `matched_pairs.csv` (label = 1)
- **Negative samples**: Random sampling từ các cặp chưa match (label = 0)
- **Balance**: Cân bằng số lượng positive/negative
- **Output**: `labeled_pairs.csv` với 33,174 cặp

### 3. Feature Engineering
- **User Features**: Tạo feature vectors cho từng user
- **Pairwise Features**: 19 features so sánh giữa 2 users
- **Artifacts**: Lưu scalers, encoders cho inference
- **Output**: `pairwise_features.csv` + artifacts trong `models/`

### 4. Model Training
- **Split**: Chia data thành train/validation sets
- **Train**: 3 models (Logistic Regression, LightGBM, Random Forest)
- **Evaluate**: So sánh performance metrics
- **Select**: Chọn Logistic Regression (best ROC AUC: 0.8790)

### 5. Model Persistence
- **Best Model**: Lưu `best_overall_model.joblib`
- **Summary**: Lưu `training_summary.json`
- **Artifacts**: Lưu tất cả scalers, encoders cần thiết

## Performance Comparison

| Model | ROC AUC | Accuracy | Precision | Recall | F1-Score |
|-------|---------|----------|-----------|--------|----------|
| **Logistic Regression** | **0.8790** | 86.15% | 78.33% | 99.94% | 87.83% |
| **LightGBM** | 0.8779 | 86.13% | 78.34% | 99.88% | 87.81% |
| **Random Forest** | 0.8708 | 86.15% | 78.33% | 99.94% | 87.83% |

## Key Features (19 total)

1. **Demographics**: age_diff, height_diff
2. **Location**: geo_distance_km, user1_within_user2_loc_pref, user2_within_user1_loc_pref
3. **Compatibility**: orientation_compatible_user1_to_user2, orientation_compatible_user2_to_user1, orientation_compatible_final
4. **Lifestyle**: drink_match, smoke_match, education_match
5. **Interests**: interests_jaccard, languages_jaccard, pets_jaccard
6. **Language Learning**: user1_wants_learn_lang, user2_wants_learn_lang, language_interest_match
7. **User Features**: user_features_cosine_sim, user_features_mae_diff 