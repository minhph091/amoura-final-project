CREATE TABLE email_otp_codes (
                                 id BIGSERIAL PRIMARY KEY,
                                 user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
                                 email VARCHAR(255) NOT NULL,
                                 code VARCHAR(255) NOT NULL,
                                 used BOOLEAN NOT NULL DEFAULT FALSE,
                                 attempts INTEGER NOT NULL DEFAULT 0,
                                 created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
                                 expires_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
);