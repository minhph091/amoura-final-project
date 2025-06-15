# Amoura AI Service

This is the backend AI Service module for the Amoura online dating application. This module is built with FastAPI and is responsible for providing APIs for the application's Artificial Intelligence (AI) based features, including:

*   **AI Matching Support:** Suggest suitable matches, display common interests.
*   **AI Communication Behavior Analysis:** Analyze message sentiment, suggest conversation topics.
*   **AI Content Moderation & User Safety (E4):** Filter inappropriate user names, uploads photos.

This module is designed to operate independently or as a microservice, interacting with the main backend of the Amoura application.

## 📂 Directory Structure

```text
amoura_ai_service/
├── app/                                # Main source code of the FastAPI application
│   ├── __init__.py
│   ├── main.py                         # Entry point for FastAPI app
│   ├── dependencies.py                 # Shared dependencies and utilities
│   ├── api/                            # API routers and endpoints
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── api.py                  # Aggregation of v1 routers
│   │       └── endpoints/              # Endpoint route handlers
│   │           ├── __init__.py
│   │           └── matches.py          # Match-related endpoints
│   │
│   ├── core/                           # Configuration and settings
│   │   ├── __init__.py
│   │   └── config.py
│   │
│   ├── db/                             # Database utilities and session setup
│   │   ├── __init__.py
│   │   ├── base.py                     # Base database configuration
│   │   ├── crud.py                     # CRUD operations
│   │   ├── models.py                   # SQLAlchemy models
│   │   └── session.py                  # Database session management
│   │
│   ├── ml/                             # Machine learning models and utilities
│   │   ├── __init__.py
│   │   ├── predictor.py               # ML model prediction logic
│   │   └── preprocessing.py           # Data preprocessing utilities
│   │
│   ├── schemas/                        # Pydantic models for request/response
│   │   ├── __init__.py
│   │   ├── match.py                   # Match-related schemas
│   │   └── user.py                    # User-related schemas
│   │
│   └── services/                       # Core logic and orchestration layer
│       ├── __init__.py
│       └── match_service.py           # Match service implementation
│
├── ml_models/                          # Trained ML models storage
│   ├── best_model_summary.json        # Summary of model performance metrics and configuration
│   └── best_overall_model.joblib      # The main trained matching model
│
├── test/                               # Unit and integration tests
│   └── __init__.py
│
├── .env                                # Environment variables (local use)
├── .env.example                        # Template environment config
├── .gitignore                          # Git ignore rules
├── README.md                           # Project description and instructions
└── requirements.txt                    # List of Python dependencies

```
## 📋 Prerequisites

*   Python 3.12+
*   Pip (Python package installer)
*   Git

## 🚀 Getting Started

### 1. Clone Repository

```bash
git clone https://github.com/vvtruong27/amoura_ai_service
cd ai_service
```
### 2. Create and Activate Virtual Environment

It's recommended to use a virtual environment to manage project dependencies.

**For Windows:**

```bash
python -m venv .venv
.\.venv\Scripts\activate
```

**For macOS/Linux:**

```bash
python3 -m venv .venv
source .venv/bin/activate
```

After activation, you'll see (.venv) at the beginning of the command line.

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

The requirements.txt file contains a list of all Python libraries needed for the project.

### 4. Configure Environment Variables

```bash
cp .env.example .env
```

Open the .env file and update the necessary values (e.g., API keys for third-party AI services if any, paths to models, etc.).

### 5. Run the Application (Development)

```bash
uvicorn app.main:app --reload
```

*   **app.main:app:** Points to the FastAPI app instance in the app/main.py file.
*   **--reload:** Automatically reloads the server when code changes (only for development).

After the server starts, you can access the application at: http://localhost:8000

## 📖 API Documentation (Swagger UI & ReDoc)

FastAPI automatically generates interactive API documentation. Once the application is running, you can access:

* **Swagger UI**: http://localhost:8000/docs
* **ReDoc:** http://localhost:8000/redoc

Here, you can view all endpoints, request/response schemas, and test the API directly.

## 🧪 Running Tests

The project uses pytest for testing. To run all tests:

```bash
pytest
```
