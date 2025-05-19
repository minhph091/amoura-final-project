CREATE TABLE registration_sessions (
                                       id BIGSERIAL PRIMARY KEY,
                                       session_token VARCHAR(255) NOT NULL UNIQUE,
                                       email VARCHAR(255) NOT NULL,
                                       phone_number VARCHAR(255),
                                       password VARCHAR(255) NOT NULL,
                                       first_name VARCHAR(255),
                                       last_name VARCHAR(255),
                                       status VARCHAR(255) NOT NULL,
                                       created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       expires_at TIMESTAMP NOT NULL
);
