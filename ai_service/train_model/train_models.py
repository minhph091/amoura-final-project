import pandas as pd
import numpy as np
import os
import json
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, classification_report
import lightgbm as lgb
import joblib

# Đường dẫn
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
FEATURES_PATH = os.path.join(DATA_DIR, 'pairwise_features.csv')
MODELS_DIR = os.path.join(os.path.dirname(__file__), 'models')

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
    """Train LightGBM model"""
    print("Training LightGBM...")
    
    # LightGBM parameters
    params = {
        'objective': 'binary',
        'metric': 'auc',
        'boosting_type': 'gbdt',
        'num_leaves': 31,
        'learning_rate': 0.05,
        'feature_fraction': 0.9,
        'bagging_fraction': 0.8,
        'bagging_freq': 5,
        'verbose': -1,
        'random_state': 42
    }
    
    # Train model
    train_data = lgb.Dataset(X_train, label=y_train)
    val_data = lgb.Dataset(X_val, label=y_val, reference=train_data)
    
    model = lgb.train(
        params,
        train_data,
        valid_sets=[train_data, val_data],
        num_boost_round=1000,
        callbacks=[lgb.early_stopping(stopping_rounds=50), lgb.log_evaluation(0)]
    )
    
    # Create wrapper for predict_proba compatibility
    class LightGBMWrapper:
        def __init__(self, model):
            self.model = model
            
        def predict_proba(self, X):
            # LightGBM predict returns raw scores, convert to probabilities
            raw_scores = self.model.predict(X)
            # Convert to probabilities using sigmoid
            import numpy as np
            probs = 1 / (1 + np.exp(-raw_scores))
            # Return 2D array with [not_match_prob, match_prob]
            return np.column_stack([1 - probs, probs])
    
    wrapped_model = LightGBMWrapper(model)
    
    # Evaluate
    y_pred_proba = wrapped_model.predict_proba(X_val)[:, 1]
    y_pred = (y_pred_proba > 0.5).astype(int)
    
    metrics = calculate_metrics(y_val, y_pred, y_pred_proba)
    
    return wrapped_model, metrics

def train_logistic_regression(X_train, y_train, X_val, y_val):
    """Train Logistic Regression model"""
    print("Training Logistic Regression...")
    
    model = LogisticRegression(random_state=42, max_iter=1000)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred_proba = model.predict_proba(X_val)[:, 1]
    y_pred = (y_pred_proba > 0.5).astype(int)
    
    metrics = calculate_metrics(y_val, y_pred, y_pred_proba)
    
    return model, metrics

def train_random_forest(X_train, y_train, X_val, y_val):
    """Train Random Forest model"""
    print("Training Random Forest...")
    
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred_proba = model.predict_proba(X_val)[:, 1]
    y_pred = (y_pred_proba > 0.5).astype(int)
    
    metrics = calculate_metrics(y_val, y_pred, y_pred_proba)
    
    return model, metrics

def save_models_and_artifacts(models_results, feature_cols):
    """Lưu model tốt nhất và artifacts cần thiết cho API"""
    print("\n=== Lưu model tốt nhất và artifacts ===")
    
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
    
    # Tạo và lưu pairwise features scaler
    from sklearn.preprocessing import MinMaxScaler
    pairwise_scaler = MinMaxScaler()
    
    # Load features data để fit scaler
    features_df = pd.read_csv(os.path.join(os.path.dirname(__file__), 'data', 'pairwise_features.csv'))
    feature_data = features_df[feature_cols].fillna(0)
    pairwise_scaler.fit(feature_data)
    
    joblib.dump(pairwise_scaler, os.path.join(MODELS_DIR, 'pairwise_features_scaler.joblib'))
    print(f"Đã lưu pairwise features scaler")
    
    # Tạo và lưu numerical columns to scale
    numerical_cols_to_scale = [
        'age_diff', 'height_diff', 'geo_distance_km',
        'interests_jaccard', 'languages_jaccard', 'pets_jaccard'
    ]
    # Chỉ lấy các cột có trong feature_cols
    numerical_cols_to_scale = [col for col in numerical_cols_to_scale if col in feature_cols]
    
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
    print(f"📁 Files để copy sang ai_service/ml_models:")
    for file in summary['files_created']:
        print(f"   - {file}")
    print(f"\n💡 Lưu ý: Copy tất cả files từ train_model/models/ sang ai_service/ml_models/")

def train_all_models():
    """Train tất cả models"""
    # Load data
    X, y, feature_cols = load_and_prepare_data()
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Train set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")
    
    # Train models
    models_results = {}
    
    # LightGBM
    lgb_model, lgb_metrics = train_lightgbm(X_train, y_train, X_test, y_test)
    models_results['LightGBM'] = (lgb_model, None, lgb_metrics)
    
    # Logistic Regression
    lr_model, lr_metrics = train_logistic_regression(X_train, y_train, X_test, y_test)
    models_results['Logistic Regression'] = (lr_model, None, lr_metrics)
    
    # Random Forest
    rf_model, rf_metrics = train_random_forest(X_train, y_train, X_test, y_test)
    models_results['Random Forest'] = (rf_model, None, rf_metrics)
    
    # Save models and artifacts
    save_models_and_artifacts(models_results, feature_cols)
    
    return models_results

if __name__ == "__main__":
    models_results = train_all_models() 