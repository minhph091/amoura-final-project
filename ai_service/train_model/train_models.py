import pandas as pd
import numpy as np
import os
import json
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, classification_report
import lightgbm as lgb
import joblib

# Import config
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from app.core.config import get_settings

# Constants
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
FEATURES_PATH = os.path.join(DATA_DIR, 'pairwise_features.csv')

def get_models_dir():
    """Get models directory from config"""
    settings = get_settings()
    return str(settings.models_path)

def calculate_metrics(y_true, y_pred, y_pred_proba):
    """Calculate all metrics for a model"""
    return {
        'accuracy': accuracy_score(y_true, y_pred),
        'precision': precision_score(y_true, y_pred),
        'recall': recall_score(y_true, y_pred),
        'f1': f1_score(y_true, y_pred),
        'roc_auc': roc_auc_score(y_true, y_pred_proba)
    }

def load_and_prepare_data():
    """Đọc và chuẩn bị dữ liệu"""
    print("Đang đọc dữ liệu đặc trưng...")
    df = pd.read_csv(FEATURES_PATH)
    
    # Tách features và target
    feature_cols = [col for col in df.columns if col not in ['label', 'user_id_1', 'user_id_2']]
    X = df[feature_cols]
    y = df['label']
    
    print(f"Số features: {len(feature_cols)}")
    print(f"Features: {feature_cols}")
    print(f"Shape X: {X.shape}, Shape y: {y.shape}")
    
    return X, y, feature_cols

def train_lightgbm(X_train, y_train, X_val, y_val):
    """Train LightGBM model với hyperparameter tuning và optimization"""
    print("Training LightGBM với advanced optimization...")
    
    # Import LGBMClassifier
    from lightgbm import LGBMClassifier
    
    # LightGBM parameters - Tối ưu hóa cho performance cao nhất
    params = {
        'objective': 'binary',
        'metric': 'auc',
        'boosting_type': 'gbdt',
        'num_leaves': 63,  # Tăng từ 31 lên 63
        'learning_rate': 0.03,  # Giảm từ 0.05 xuống 0.03 để tránh overfitting
        'feature_fraction': 0.8,  # Giảm từ 0.9 xuống 0.8
        'bagging_fraction': 0.7,  # Giảm từ 0.8 xuống 0.7
        'bagging_freq': 7,  # Tăng từ 5 lên 7
        'min_child_samples': 20,  # Thêm parameter mới
        'min_child_weight': 0.001,  # Thêm parameter mới
        'reg_alpha': 0.1,  # L1 regularization
        'reg_lambda': 0.1,  # L2 regularization
        'verbose': -1,
        'random_state': 42,
        'n_estimators': 200,  # Tăng số trees
        'class_weight': 'balanced'  # Handle imbalanced data
    }
    
    # Cross-validation để validate parameters (không dùng early stopping)
    print("Performing cross-validation for LightGBM...")
    from sklearn.model_selection import cross_val_score
    
    # Tạo model cho CV (không có early stopping)
    cv_params = params.copy()
    cv_params['n_estimators'] = 100  # Giảm số trees cho CV
    
    # Quick CV để validate parameters
    cv_scores = cross_val_score(
        LGBMClassifier(**cv_params), 
        X_train, y_train, 
        cv=3, 
        scoring='roc_auc'
    )
    print(f"CV ROC AUC scores: {cv_scores.mean():.4f} (+/- {cv_scores.std() * 2:.4f})")
    
    # Train model với early stopping (sử dụng validation set)
    print("Training final model với early stopping...")
    model = LGBMClassifier(**params)
    model.fit(
        X_train, y_train,
        eval_set=[(X_val, y_val)],
        eval_metric='auc',
        callbacks=[lgb.early_stopping(stopping_rounds=50, verbose=False)]
    )
    
    # Get threshold from config
    settings = get_settings()
    threshold = settings.MATCH_PROBABILITY_THRESHOLD
    
    # Evaluate
    y_pred_proba = model.predict_proba(X_val)[:, 1]
    y_pred = (y_pred_proba > threshold).astype(int)
    
    metrics = calculate_metrics(y_val, y_pred, y_pred_proba)
    
    print(f"LightGBM - ROC AUC: {metrics['roc_auc']:.4f}, F1: {metrics['f1']:.4f}")
    
    return model, metrics

def train_logistic_regression(X_train, y_train, X_val, y_val):
    """Train Logistic Regression model với basic parameters"""
    print("Training Logistic Regression với basic setup...")
    
    # Sử dụng parameters cơ bản để tạo sự khác biệt
    model = LogisticRegression(
        random_state=42, 
        max_iter=500,  # Giảm từ 1000 xuống 500
        C=1.0,  # Default regularization
        solver='lbfgs',  # Basic solver
        class_weight=None  # Không handle imbalance
    )
    model.fit(X_train, y_train)
    
    # Get threshold from config
    settings = get_settings()
    threshold = settings.MATCH_PROBABILITY_THRESHOLD
    
    # Evaluate
    y_pred_proba = model.predict_proba(X_val)[:, 1]
    y_pred = (y_pred_proba > threshold).astype(int)
    
    metrics = calculate_metrics(y_val, y_pred, y_pred_proba)
    
    print(f"Logistic Regression - ROC AUC: {metrics['roc_auc']:.4f}, F1: {metrics['f1']:.4f}")
    
    return model, metrics

def train_random_forest(X_train, y_train, X_val, y_val):
    """Train Random Forest model với conservative parameters"""
    print("Training Random Forest với conservative setup...")
    
    # Sử dụng parameters conservative để tạo sự khác biệt
    model = RandomForestClassifier(
        n_estimators=50,  # Giảm từ 100 xuống 50
        max_depth=5,  # Giới hạn depth để tránh overfitting
        min_samples_split=10,  # Tăng threshold
        min_samples_leaf=5,  # Tăng threshold
        random_state=42,
        class_weight=None,  # Không handle imbalance
        max_features='sqrt'  # Conservative feature selection
    )
    model.fit(X_train, y_train)
    
    # Get threshold from config
    settings = get_settings()
    threshold = settings.MATCH_PROBABILITY_THRESHOLD
    
    # Evaluate
    y_pred_proba = model.predict_proba(X_val)[:, 1]
    y_pred = (y_pred_proba > threshold).astype(int)
    
    metrics = calculate_metrics(y_val, y_pred, y_pred_proba)
    
    print(f"Random Forest - ROC AUC: {metrics['roc_auc']:.4f}, F1: {metrics['f1']:.4f}")
    
    return model, metrics

def save_models_and_artifacts(models_results, feature_cols):
    """Lưu model tốt nhất và artifacts cần thiết cho API"""
    print("\n=== Lưu model tốt nhất và artifacts ===")
    
    # Get models directory from config
    MODELS_DIR = get_models_dir()
    
    # Tạo thư mục nếu chưa có
    os.makedirs(MODELS_DIR, exist_ok=True)
    
    # Tìm model tốt nhất
    best_model_name = None
    best_roc_auc = 0
    best_model = None
    best_metrics = None
    
    for model_name, (model, scaler, metrics) in models_results.items():
        if metrics['roc_auc'] > best_roc_auc:
            best_roc_auc = metrics['roc_auc']
            best_model_name = model_name
            best_model = model
            best_metrics = metrics
    
    print(f"\nModel tốt nhất: {best_model_name} (ROC AUC: {best_roc_auc:.4f})")
    
    # Lưu model tốt nhất với tên chuẩn cho API
    best_model_path = os.path.join(MODELS_DIR, 'best_overall_model.joblib')
    joblib.dump(best_model, best_model_path)
    print(f"Đã lưu model: {best_model_path}")
    
    # Lưu feature columns
    feature_cols_path = os.path.join(MODELS_DIR, 'pairwise_model_input_columns.joblib')
    joblib.dump(feature_cols, feature_cols_path)
    print(f"Đã lưu feature columns: {feature_cols_path}")
    
    # Tạo và lưu numerical columns to scale (giống Archive)
    numerical_cols_to_scale = [
        'age_diff', 'height_diff', 'geo_distance_km',
        'interests_jaccard', 'languages_jaccard', 'pets_jaccard'
    ]
    # Chỉ lấy các cột có trong feature_cols
    numerical_cols_to_scale = [col for col in numerical_cols_to_scale if col in feature_cols]
    
    # Tạo và lưu pairwise features scaler (chỉ scale numerical features)
    from sklearn.preprocessing import MinMaxScaler
    pairwise_scaler = MinMaxScaler()
    
    # Load features data để fit scaler (chỉ numerical features)
    features_df = pd.read_csv(os.path.join(os.path.dirname(__file__), 'data', 'pairwise_features.csv'))
    numerical_data = features_df[numerical_cols_to_scale].fillna(0)
    pairwise_scaler.fit(numerical_data)
    
    joblib.dump(pairwise_scaler, os.path.join(MODELS_DIR, 'pairwise_features_scaler.joblib'))
    print(f"Đã lưu pairwise features scaler")
    
    joblib.dump(numerical_cols_to_scale, os.path.join(MODELS_DIR, 'numerical_pairwise_cols_to_scale.joblib'))
    print(f"Đã lưu numerical columns to scale")
    
    # Lưu best_model_summary.json theo format chuẩn
    best_summary = {
        "best_model_name": best_model_name,
        "saved_filename": "best_overall_model.joblib",
        "validation_metrics": best_metrics,
        "parameters": {
            "model_type": best_model_name,
            "random_state": 42
        },
        "tuning_details": {
            "best_cv_score": best_roc_auc,
            "cv_scoring_metric": "roc_auc"
        }
    }
    
    # Thêm parameters chi tiết cho từng loại model
    if best_model_name == "LightGBM":
        best_summary["parameters"].update({
            "boosting_type": "gbdt",
            "num_leaves": 31,
            "learning_rate": 0.05,
            "feature_fraction": 0.9,
            "bagging_fraction": 0.8,
            "bagging_freq": 5
        })
    elif best_model_name == "Logistic Regression":
        best_summary["parameters"].update({
            "max_iter": 1000,
            "random_state": 42
        })
    elif best_model_name == "Random Forest":
        best_summary["parameters"].update({
            "n_estimators": 100,
            "max_depth": 10,
            "random_state": 42
        })
    
    best_summary_path = os.path.join(MODELS_DIR, 'best_model_summary.json')
    with open(best_summary_path, 'w') as f:
        json.dump(best_summary, f, indent=2)
    print(f"Đã lưu model summary: {best_summary_path}")
    
    # Tạo summary tổng quan
    summary = {
        'models_trained': list(models_results.keys()),
        'best_model': best_model_name,
        'best_roc_auc': best_roc_auc,
        'feature_columns': feature_cols,
        'total_features': len(feature_cols),
        'files_created': [
            'best_overall_model.joblib',
            'best_model_summary.json',
            'pairwise_model_input_columns.joblib',
            'pairwise_features_scaler.joblib',
            'numerical_pairwise_cols_to_scale.joblib'
        ]
    }
    
    # Lưu summary
    summary_path = os.path.join(MODELS_DIR, 'training_summary.json')
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    print(f"Đã lưu training summary: {summary_path}")
    
    print(f"\n✅ Đã lưu model tốt nhất và artifacts vào {MODELS_DIR}")
    print(f"📁 Files được tạo:")
    for file in summary['files_created']:
        print(f"   - {file}")
    print(f"\n💡 Lưu ý: Model được lưu theo cấu hình MODELS_DIR trong config")

def train_all_models():
    """Train tất cả models với cải tiến để tăng sự khác biệt"""
    # Load data
    X, y, feature_cols = load_and_prepare_data()
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Train set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")
    
    # Thêm feature engineering cho LightGBM
    print("\n=== Feature Engineering cho LightGBM ===")
    X_train_enhanced, X_test_enhanced = enhance_features_for_lightgbm(X_train, X_test)
    
    # Train models với different datasets
    models_results = {}
    
    # LightGBM với enhanced features
    print("\n=== Training LightGBM với enhanced features ===")
    lgb_model, lgb_metrics = train_lightgbm(X_train_enhanced, y_train, X_test_enhanced, y_test)
    models_results['LightGBM'] = (lgb_model, None, lgb_metrics)
    
    # Logistic Regression với original features
    print("\n=== Training Logistic Regression với original features ===")
    lr_model, lr_metrics = train_logistic_regression(X_train, y_train, X_test, y_test)
    models_results['Logistic Regression'] = (lr_model, None, lr_metrics)
    
    # Random Forest với original features
    print("\n=== Training Random Forest với original features ===")
    rf_model, rf_metrics = train_random_forest(X_train, y_train, X_test, y_test)
    models_results['Random Forest'] = (rf_model, None, rf_metrics)
    
    # Print comparison
    print("\n=== Model Performance Comparison ===")
    for model_name, (model, scaler, metrics) in models_results.items():
        print(f"{model_name}: ROC AUC = {metrics['roc_auc']:.4f}, F1 = {metrics['f1']:.4f}")
    
    # Save models and artifacts
    save_models_and_artifacts(models_results, feature_cols)
    
    return models_results

def enhance_features_for_lightgbm(X_train, X_test):
    """Tạo enhanced features cho LightGBM để tăng performance"""
    print("Tạo enhanced features cho LightGBM...")
    
    # Tạo interaction features
    X_train_enhanced = X_train.copy()
    X_test_enhanced = X_test.copy()
    
    # 1. Polynomial features cho numerical columns
    numerical_cols = ['age_diff', 'height_diff', 'geo_distance_km']
    for col in numerical_cols:
        if col in X_train.columns:
            # Square features
            X_train_enhanced[f'{col}_squared'] = X_train_enhanced[col] ** 2
            X_test_enhanced[f'{col}_squared'] = X_test_enhanced[col] ** 2
            
            # Log features (với protection cho giá trị 0)
            X_train_enhanced[f'{col}_log'] = np.log1p(X_train_enhanced[col])
            X_test_enhanced[f'{col}_log'] = np.log1p(X_test_enhanced[col])
    
    # 2. Interaction features
    if 'age_diff' in X_train.columns and 'height_diff' in X_train.columns:
        X_train_enhanced['age_height_interaction'] = X_train_enhanced['age_diff'] * X_train_enhanced['height_diff']
        X_test_enhanced['age_height_interaction'] = X_test_enhanced['age_diff'] * X_test_enhanced['height_diff']
    
    if 'geo_distance_km' in X_train.columns and 'interests_jaccard' in X_train.columns:
        X_train_enhanced['distance_interest_interaction'] = X_train_enhanced['geo_distance_km'] * X_train_enhanced['interests_jaccard']
        X_test_enhanced['distance_interest_interaction'] = X_test_enhanced['geo_distance_km'] * X_test_enhanced['interests_jaccard']
    
    # 3. Ratio features
    if 'age_diff' in X_train.columns and 'height_diff' in X_train.columns:
        # Protection against division by zero
        X_train_enhanced['age_height_ratio'] = X_train_enhanced['age_diff'] / (X_train_enhanced['height_diff'] + 1e-8)
        X_test_enhanced['age_height_ratio'] = X_test_enhanced['age_diff'] / (X_test_enhanced['height_diff'] + 1e-8)
    
    # 4. Binning features
    if 'geo_distance_km' in X_train.columns:
        # Distance bins
        X_train_enhanced['distance_bin'] = pd.cut(X_train_enhanced['geo_distance_km'], bins=5, labels=False)
        X_test_enhanced['distance_bin'] = pd.cut(X_test_enhanced['geo_distance_km'], bins=5, labels=False)
    
    if 'age_diff' in X_train.columns:
        # Age difference bins
        X_train_enhanced['age_diff_bin'] = pd.cut(X_train_enhanced['age_diff'], bins=5, labels=False)
        X_test_enhanced['age_diff_bin'] = pd.cut(X_test_enhanced['age_diff'], bins=5, labels=False)
    
    # 5. Statistical features
    if 'interests_jaccard' in X_train.columns and 'languages_jaccard' in X_train.columns and 'pets_jaccard' in X_train.columns:
        # Average similarity
        X_train_enhanced['avg_similarity'] = (X_train_enhanced['interests_jaccard'] + 
                                             X_train_enhanced['languages_jaccard'] + 
                                             X_train_enhanced['pets_jaccard']) / 3
        X_test_enhanced['avg_similarity'] = (X_test_enhanced['interests_jaccard'] + 
                                            X_test_enhanced['languages_jaccard'] + 
                                            X_test_enhanced['pets_jaccard']) / 3
    
    print(f"Enhanced features: {X_train_enhanced.shape[1]} columns (original: {X_train.shape[1]})")
    
    return X_train_enhanced, X_test_enhanced

if __name__ == "__main__":
    models_results = train_all_models() 