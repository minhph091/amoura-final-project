# 🌟 Amoura - AI-Powered Dating Platform

Amoura is a modern, full-stack dating application that leverages artificial intelligence to enhance user connections and communication. The platform provides intelligent matchmaking and AI-assisted messaging features to create meaningful relationships.

## ✨ Key Features

- 🤖 **AI-Powered Matching**: Intelligent algorithm to find compatible matches based on user preferences and behavior
- 💬 **AI Message Enhancement**: Smart message editing and optimization to improve communication
- 📱 **Mobile Application**: Cross-platform mobile app for seamless user experience
- 🎯 **Admin Dashboard**: Comprehensive admin panel for platform management
- 🌐 **Landing Page**: Attractive web presence to showcase the platform
- 🔒 **Secure Backend**: Robust Spring Boot backend with comprehensive error handling

## 🏗️ Architecture

This project follows a microservices architecture with the following components:

- **Backend** (`/backend`): Spring Boot REST API with Java
- **AI Service** (`/ai_service`): Dedicated AI/ML service for matching and message processing
- **Mobile App** (`/mobile_app`): Cross-platform mobile application
- **Admin Dashboard** (`/admin_dashboard`): Web-based administrative interface
- **Landing Page** (`/landing_page`): Marketing and information website
- **Data Management** (`/insert_data`): Database seeding and data management tools

## 🛠️ Technology Stack

- **Backend**: Java, Spring Boot, Maven
- **AI/ML**: Custom AI service for intelligent matching and message enhancement
- **Database**: PostgresSQL
- **Mobile**: Flutter
- **Frontend**: React, TypeScript
- **DevOps**: GitHub Actions CI/CD

## 🛠️ Development Requirements

- **Java**: Version 17 or higher
- **Database**: PostgreSQL 17.5
  - **Username**: postgres
  - **Password**: 123456789  

## 🚀 Core Functionality

### AI Matching System
- Intelligent user compatibility analysis
- Personalized match recommendations
- Adaptive learning from user interactions

### Smart Messaging
- AI-powered message editing and enhancement
- Communication optimization suggestions
- Fallback mechanisms for service reliability

## 📋 Getting Started

To set up the project locally, follow these steps:

```bash
# Clone the repository
git clone https://github.com/minhph091/amoura-final-project.git
cd amoura-final-project

# Start the backend service
cd backend
./mvnw spring-boot:run

