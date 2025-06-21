# Amoura AI Service

A professional FastAPI-based microservice for AI-powered features in the Amoura dating application. This service provides intelligent matching, message editing, and content moderation capabilities with enterprise-grade architecture.

## 🚀 Features

- **🤖 AI-Powered Matching**: ML-based user compatibility prediction
- **✏️ Smart Message Editing**: AI-assisted message improvement using Google Gemini
- **🛡️ Content Moderation**: Filter inappropriate content and user uploads
- **📊 Conversation Analysis**: Sentiment analysis and conversation insights
- **🔒 Enterprise Security**: Proper authentication, validation, and error handling
- **📈 Monitoring & Logging**: Comprehensive logging and health monitoring

## 🏗️ Architecture

The service follows clean architecture principles with:

- **Layered Architecture**: Clear separation between API, services, and data layers
- **Dependency Injection**: Proper dependency management with FastAPI
- **Error Handling**: Comprehensive exception handling with custom error types
- **Logging**: Structured logging with configurable levels
- **Configuration Management**: Environment-based configuration with validation
- **Type Safety**: Full type hints and Pydantic validation

## 📂 Project Structure

```
ai_service/
├── app/                                # Main application code
│   ├── __init__.py                     # Package initialization
│   ├── main.py                         # FastAPI application entry point
│   ├── dependencies.py                 # Dependency injection
│   │
│   ├── api/                            # API layer
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── api.py                  # API router aggregation
│   │       └── endpoints/              # Endpoint handlers
│   │           ├── __init__.py
│   │           ├── matches.py          # Match-related endpoints
│   │           └── messages.py         # Message-related endpoints
│   │
│   ├── core/                           # Core application components
│   │   ├── __init__.py
│   │   ├── config.py                   # Configuration management
│   │   ├── exceptions.py               # Custom exceptions
│   │   └── logging.py                  # Logging configuration
│   │
│   ├── db/                             # Database layer
│   │   ├── __init__.py
│   │   ├── base.py                     # Database base configuration
│   │   ├── crud.py                     # CRUD operations
│   │   ├── models.py                   # SQLAlchemy models
│   │   └── session.py                  # Database session management
│   │
│   ├── ml/                             # Machine learning components
│   │   ├── __init__.py
│   │   ├── predictor.py                # ML model predictor
│   │   └── preprocessing.py            # Data preprocessing utilities
│   │
│   ├── schemas/                        # Pydantic models
│   │   ├── __init__.py
│   │   ├── match.py                    # Match-related schemas
│   │   └── message.py                  # Message-related schemas
│   │
│   └── services/                       # Business logic layer
│       ├── __init__.py
│       ├── match_service.py            # Match service implementation
│       └── message_service.py          # Message service implementation
│
├── ml_models/                          # Trained ML models
│   ├── best_model_summary.json         # Model performance metrics
│   ├── best_overall_model.joblib       # Main trained model
│   └── [other model files...]          # Preprocessors and scalers
│
├── test/                               # Test suite
│   └── __init__.py
│
├── env.example                         # Environment variables template
├── requirements.txt                    # Python dependencies
└── README.md                           # This file
```

## 🛠️ Technology Stack

- **Framework**: FastAPI 0.115+
- **Database**: PostgreSQL with SQLAlchemy ORM
- **ML**: scikit-learn, LightGBM, NLTK
- **AI**: Google Gemini API
- **Validation**: Pydantic with custom validators
- **Logging**: Python logging with structured output
- **Testing**: pytest (recommended)

## 📋 Prerequisites

- Python 3.12+
- PostgreSQL 12+
- Google Gemini API key
- Git

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ai_service
```

### 2. Create Virtual Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.\.venv\Scripts\activate

# Activate (macOS/Linux)
source .venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment

```bash
# Copy environment template
cp env.example .env

# Edit .env with your configuration
nano .env
```

Required environment variables:
- `POSTGRES_SERVER`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- `GEMINI_API_KEY`
- `MATCH_PROBABILITY_THRESHOLD` (default: 0.5)

### 5. Run the Application

```bash
# Development mode
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 6. Verify Installation

Visit the API documentation:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

## 📚 API Documentation

### Match Endpoints

#### Get Potential Matches
```http
GET /api/v1/users/{user_id}/potential-matches?limit=10
```

Returns potential matches for a user based on ML predictions.

#### Get Match Probability
```http
GET /api/v1/users/{user1_id}/match-probability/{user2_id}
```

Returns match probability between two specific users.

### Message Endpoints

#### Edit Message
```http
POST /api/v1/messages/edit
Content-Type: application/json

{
  "original_message": "Hey, how are you?",
  "edit_prompt": "Make it more engaging",
  "user_id": 1,
  "other_user_id": 2
}
```

Uses AI to improve messages based on conversation context.

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENVIRONMENT` | Environment (development/production) | `development` |
| `DEBUG` | Enable debug mode | `false` |
| `LOG_LEVEL` | Logging level | `INFO` |
| `POSTGRES_SERVER` | PostgreSQL server host | `localhost` |
| `POSTGRES_USER` | PostgreSQL username | `youruser` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `yourpassword` |
| `POSTGRES_DB` | PostgreSQL database name | `amouradb` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |
| `GEMINI_API_KEY` | Google Gemini API key | (required) |
| `MATCH_PROBABILITY_THRESHOLD` | ML match threshold | `0.5` |

### Logging

The service uses structured logging with configurable levels:

```python
# Example log output
2024-01-15 10:30:45,123 - app.services.match_service - INFO - Found 5 potential matches for user 123
2024-01-15 10:30:46,456 - app.ml.predictor - DEBUG - Predicted match probability: 0.85
```

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test file
pytest test/test_matches.py
```

## 📊 Monitoring

### Health Check
```http
GET /health
```

Returns service health status including:
- Service status
- Version information
- Environment details
- Timestamp

### Metrics
The service includes request timing headers (`X-Process-Time`) for performance monitoring.

## 🔒 Security

- Input validation with Pydantic
- SQL injection protection via SQLAlchemy
- Environment-based configuration
- Proper error handling without information leakage
- CORS configuration for production

## 🚀 Deployment

### Docker (Recommended)

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Production Considerations

1. **Environment Variables**: Use proper secrets management
2. **Database**: Use connection pooling and read replicas
3. **Logging**: Configure external log aggregation
4. **Monitoring**: Set up health checks and alerting
5. **Security**: Configure CORS, rate limiting, and authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with proper tests
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the API documentation at `/docs`
- Review the logs for debugging information
