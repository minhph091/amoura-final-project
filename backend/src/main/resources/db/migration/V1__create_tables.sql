-- --- Bảng lõi và tham chiếu cơ bản ---
CREATE TABLE roles (
                       id BIGSERIAL PRIMARY KEY,
                       name VARCHAR(255),
                       description VARCHAR(255),
                       created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE users (
                       id BIGSERIAL PRIMARY KEY,
                       username VARCHAR(255) UNIQUE,
                       password_hash VARCHAR(255),
                       email VARCHAR(255) UNIQUE,
                       phone_number VARCHAR(50) UNIQUE,
                       first_name VARCHAR(255),
                       last_name VARCHAR(255),
                       role_id BIGINT REFERENCES roles(id),
                       status VARCHAR(20),
                       last_login TIMESTAMP WITHOUT TIME ZONE,
                       created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP WITHOUT TIME ZONE,
                       refresh_token VARCHAR(255),
                       refresh_token_expiry_date TIMESTAMP
);

CREATE TABLE message_types (
                               id BIGSERIAL PRIMARY KEY,
                               name VARCHAR(255),
                               description VARCHAR(255),
                               created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE body_types (
                            id BIGSERIAL PRIMARY KEY,
                            name VARCHAR(255),
                            created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE orientations (
                              id BIGSERIAL PRIMARY KEY,
                              name VARCHAR(255),
                              description VARCHAR(255),
                              created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE job_industries (
                                id BIGSERIAL PRIMARY KEY,
                                name VARCHAR(255),
                                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE drink_statuses (
                                id BIGSERIAL PRIMARY KEY,
                                name VARCHAR(255),
                                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE smoke_statuses (
                                id BIGSERIAL PRIMARY KEY,
                                name VARCHAR(255),
                                created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE education_levels (
                                  id BIGSERIAL PRIMARY KEY,
                                  name VARCHAR(255),
                                  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                  updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE pets (
                      id BIGSERIAL PRIMARY KEY,
                      name VARCHAR(255)
);

CREATE TABLE interests (
                           id BIGSERIAL PRIMARY KEY,
                           name VARCHAR(255)
);

CREATE TABLE languages (
                           id BIGSERIAL PRIMARY KEY,
                           name VARCHAR(255)
);

CREATE TABLE premium_plans (
                               id BIGSERIAL PRIMARY KEY,
                               name VARCHAR(255),
                               price_monthly DECIMAL(10, 2),
                               price_yearly DECIMAL(10, 2),
                               description TEXT,
                               features TEXT,
                               is_active BOOLEAN,
                               created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITHOUT TIME ZONE
);

-- --- Bảng thông tin người dùng và hồ sơ ---
CREATE TABLE profiles (
                          user_id BIGINT PRIMARY KEY REFERENCES users(id),
                          date_of_birth DATE,
                          height INTEGER,
                          body_type_id BIGINT REFERENCES body_types(id),
                          sex VARCHAR(10),
                          orientation_id BIGINT REFERENCES orientations(id),
                          job_industry_id BIGINT REFERENCES job_industries(id),
                          drink_status_id BIGINT REFERENCES drink_statuses(id),
                          smoke_status_id BIGINT REFERENCES smoke_statuses(id),
                          interested_in_new_language BOOLEAN,
                          education_level_id BIGINT REFERENCES education_levels(id),
                          drop_out BOOLEAN,
                          location_preference INTEGER,
                          bio TEXT
);

CREATE TABLE locations (
                           user_id BIGINT PRIMARY KEY REFERENCES users(id),
                           latitudes DECIMAL(9, 6),
                           longitudes DECIMAL(9, 6),
                           country VARCHAR(255),
                           state VARCHAR(255),
                           city VARCHAR(255),
                           created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                           updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE photos (
                        id BIGSERIAL PRIMARY KEY,
                        user_id BIGINT REFERENCES users(id),
                        path VARCHAR(255),
                        type VARCHAR(50),
                        created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_pets (
                            user_id BIGINT REFERENCES users(id),
                            pet_id BIGINT REFERENCES pets(id),
                            PRIMARY KEY (user_id, pet_id)
);

CREATE TABLE users_interests (
                                 user_id BIGINT REFERENCES users(id),
                                 interest_id BIGINT REFERENCES interests(id),
                                 PRIMARY KEY (user_id, interest_id)
);

CREATE TABLE users_languages (
                                 user_id BIGINT REFERENCES users(id),
                                 language_id BIGINT REFERENCES languages(id),
                                 PRIMARY KEY (user_id, language_id)
);

-- --- Bảng chức năng chính (Nhắn tin, Tương tác, Gọi điện) ---
CREATE TABLE messages (
                          id BIGSERIAL PRIMARY KEY,
                          sender_id BIGINT REFERENCES users(id),
                          receiver_id BIGINT REFERENCES users(id),
                          content TEXT,
                          message_type_id BIGINT REFERENCES message_types(id),
                          is_read BOOLEAN DEFAULT FALSE,
                          read_at TIMESTAMP WITHOUT TIME ZONE,
                          is_edited BOOLEAN DEFAULT FALSE,
                          edited_at TIMESTAMP WITHOUT TIME ZONE,
                          is_recalled BOOLEAN DEFAULT FALSE,
                          recalled_at TIMESTAMP WITHOUT TIME ZONE,
                          created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE user_message_visibilities (
                                           user_id BIGINT REFERENCES users(id),
                                           message_id BIGINT REFERENCES messages(id),
                                           deleted_for_user_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                           PRIMARY KEY (user_id, message_id)
);

CREATE TABLE swipes (
                        id BIGSERIAL PRIMARY KEY,
                        initiator BIGINT REFERENCES users(id),
                        target_user BIGINT REFERENCES users(id),
                        is_like BOOLEAN,
                        created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE matches (
                         id BIGSERIAL PRIMARY KEY,
                         user1_id BIGINT REFERENCES users(id),
                         user2_id BIGINT REFERENCES users(id),
                         status VARCHAR(20),
                         matched_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                         updated_at TIMESTAMP WITHOUT TIME ZONE,
                         CONSTRAINT uq_match_pair UNIQUE (user1_id, user2_id)
);

CREATE TABLE calls (
                       id BIGSERIAL PRIMARY KEY,
                       caller_id BIGINT REFERENCES users(id),
                       receiver_id BIGINT REFERENCES users(id),
                       type VARCHAR(10),
                       start_time TIMESTAMP WITHOUT TIME ZONE,
                       end_time TIMESTAMP WITHOUT TIME ZONE,
                       status VARCHAR(50),
                       created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- --- Bảng Quản lý, Báo cáo và Thông báo ---
CREATE TABLE report_requests (
                                 id BIGSERIAL PRIMARY KEY,
                                 reporter_id BIGINT REFERENCES users(id),
                                 reported_user_id BIGINT REFERENCES users(id),
                                 type VARCHAR(50),
                                 description TEXT,
                                 status VARCHAR(20) DEFAULT 'pending',
                                 resolved_at TIMESTAMP WITHOUT TIME ZONE,
                                 resolved_by BIGINT REFERENCES users(id),
                                 created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                 updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE suspended_users (
                                 id BIGSERIAL PRIMARY KEY,
                                 user_id BIGINT UNIQUE REFERENCES users(id),
                                 report_id BIGINT REFERENCES report_requests(id),
                                 suspension_period INTEGER,
                                 suspended_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
                               id BIGSERIAL PRIMARY KEY,
                               user_id BIGINT REFERENCES users(id),
                               type VARCHAR(20),
                               content TEXT,
                               related_entity_id BIGINT,
                               is_read BOOLEAN DEFAULT FALSE,
                               read_at TIMESTAMP WITHOUT TIME ZONE,
                               created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITHOUT TIME ZONE
);

-- --- Bảng Thanh toán và Gói dịch vụ ---
CREATE TABLE payment_cards (
                               id BIGSERIAL PRIMARY KEY,
                               user_id BIGINT REFERENCES users(id),
                               card_numbers VARCHAR(255),
                               name_in_card VARCHAR(255),
                               expiration_date DATE,
                               is_default BOOLEAN DEFAULT FALSE,
                               created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE transactions (
                              id BIGSERIAL PRIMARY KEY,
                              user_id BIGINT REFERENCES users(id),
                              card_id BIGINT REFERENCES payment_cards(id),
                              plan_id BIGINT REFERENCES premium_plans(id),
                              purchase_period VARCHAR(50),
                              status VARCHAR(20),
                              created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE users_plans (
                             user_id BIGINT PRIMARY KEY REFERENCES users(id),
                             plan_id BIGINT REFERENCES premium_plans(id),
                             transaction_id BIGINT UNIQUE REFERENCES transactions(id),
                             start_at DATE,
                             end_at DATE,
                             created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE login_history (
                               id BIGSERIAL PRIMARY KEY,
                               user_id BIGINT NOT NULL REFERENCES users(id),
                               login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               ip_address VARCHAR(50),
                               user_agent TEXT,
                               device_info VARCHAR(255),
                               successful BOOLEAN NOT NULL,
                               created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE password_reset_sessions (
                                         id BIGSERIAL PRIMARY KEY,
                                         session_token VARCHAR(255) NOT NULL UNIQUE,
                                         user_id BIGINT REFERENCES users(id),
                                         email VARCHAR(255) NOT NULL,
                                         status VARCHAR(20) NOT NULL, -- INITIATED, VERIFIED, COMPLETED
                                         created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                         updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                         expires_at TIMESTAMP NOT NULL,
                                         last_otp_sent_at TIMESTAMP,
                                         CONSTRAINT chk_password_reset_status CHECK (status IN ('INITIATED', 'VERIFIED', 'COMPLETED'))
);

-- --- Thêm các ràng buộc CHECK ---
ALTER TABLE users
    ADD CONSTRAINT chk_user_status CHECK (status IN ('active', 'inactive', 'suspend'));

ALTER TABLE profiles
    ADD CONSTRAINT chk_sex CHECK (sex IN ('male', 'female','non-binary','prefer not to say'));

ALTER TABLE matches
    ADD CONSTRAINT chk_match_status CHECK (status IN ('active', 'unmatched'));

ALTER TABLE calls
    ADD CONSTRAINT chk_call_type CHECK (type IN ('voice', 'video'));

ALTER TABLE report_requests
    ADD CONSTRAINT chk_report_type CHECK (type IN ('fake', 'inappropriate content'));

ALTER TABLE report_requests
    ADD CONSTRAINT chk_report_status CHECK (status IN ('pending', 'resolving', 'resolved'));

ALTER TABLE notifications
    ADD CONSTRAINT chk_notification_type CHECK (type IN ('message', 'match', 'marketing'));

ALTER TABLE transactions
    ADD CONSTRAINT chk_transaction_status CHECK (status IN ('success', 'failed'));

ALTER TABLE photos
    ADD CONSTRAINT chk_photo_type
        CHECK (type IN (
                        'avatar',
                        'profile_cover',
                        'highlight'
            ));
