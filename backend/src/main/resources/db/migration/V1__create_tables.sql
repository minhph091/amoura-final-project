CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone_number VARCHAR(50) UNIQUE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role_id INTEGER REFERENCES roles(id),
  status VARCHAR(50) NOT NULL DEFAULT 'pending_verification', -- e.g., active, inactive, suspended, pending_verification
  last_login TIMESTAMP WITHOUT TIME ZONE,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE message_content_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE body_profiles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orientations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE job_industries (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE drink_statuses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE smoke_statuses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE education_levels (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pets (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE interests (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE languages (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE premium_plans (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price_monthly DECIMAL(10, 2),
  price_yearly DECIMAL(10, 2),
  description TEXT,
  features TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- --- Bảng thông tin người dùng và hồ sơ ---
CREATE TABLE profiles (
  user_id INTEGER PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  date_of_birth DATE,
  height INTEGER, -- in cm
  body_profile_id INTEGER REFERENCES body_profiles(id),
  sex VARCHAR(50), -- e.g., male, female
  orientation_id INTEGER REFERENCES orientations(id),
  job_industry_id INTEGER REFERENCES job_industries(id),
  drink_status_id INTEGER REFERENCES drink_statuses(id),
  smoke_status_id INTEGER REFERENCES smoke_statuses(id),
  new_language VARCHAR(255), 
  education_level_id INTEGER REFERENCES education_levels(id),
  drop_out BOOLEAN,
  location_preference INTEGER,
  bio TEXT
);

CREATE TABLE location (
  user_id INTEGER PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  latitudes DECIMAL(10, 7), -- Precision for GPS coordinates
  longitudes DECIMAL(10, 7),-- Precision for GPS coordinates
  country VARCHAR(100),
  state VARCHAR(100),
  city VARCHAR(100),
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE photos (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  path VARCHAR(512) NOT NULL, -- Path to image file (e.g., S3 URL)
  type VARCHAR(50), -- e.g., profile_picture, gallery_image
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_pets (
  user_id INTEGER REFERENCES accounts(id) ON DELETE CASCADE,
  pet_id INTEGER REFERENCES pets(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, pet_id)
);

CREATE TABLE users_interests (
  user_id INTEGER REFERENCES accounts(id) ON DELETE CASCADE,
  interest_id INTEGER REFERENCES interests(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, interest_id)
);

CREATE TABLE users_languages (
  user_id INTEGER REFERENCES accounts(id) ON DELETE CASCADE,
  language_id INTEGER REFERENCES languages(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, language_id)
);

-- --- Bảng chức năng chính (Nhắn tin, Tương tác, Gọi điện) ---
CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY, -- Use BIGSERIAL for very high volume tables
  sender_id INTEGER NOT NULL REFERENCES accounts(id), -- Consider ON DELETE SET NULL or a "deleted_user" account
  receiver_id INTEGER NOT NULL REFERENCES accounts(id), -- Consider ON DELETE SET NULL or a "deleted_user" account
  content TEXT,
  content_type_id INTEGER REFERENCES message_content_types(id),
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITHOUT TIME ZONE,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP WITHOUT TIME ZONE,
  is_recalled BOOLEAN DEFAULT FALSE,
  recalled_at TIMESTAMP WITHOUT TIME ZONE,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- Index for faster querying of user's messages
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);


CREATE TABLE user_message_visibilities (
  user_id INTEGER REFERENCES accounts(id) ON DELETE CASCADE,
  message_id BIGINT REFERENCES messages(id) ON DELETE CASCADE,
  deleted_for_user_at TIMESTAMP WITHOUT TIME ZONE, -- Timestamp when user 'deleted' the message for themselves
  PRIMARY KEY (user_id, message_id)
);


CREATE TABLE interacts (
  id SERIAL PRIMARY KEY,
  initiator_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE, -- Renamed for clarity
  target_user_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE, -- Renamed for clarity
  is_like BOOLEAN NOT NULL, -- TRUE for like, FALSE for dislike/pass
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (initiator_id, target_user_id) -- A user can only interact (like/dislike) with another user once
);
CREATE INDEX idx_interacts_target_user_id_is_like ON interacts(target_user_id, is_like);


CREATE TABLE matches (
  id SERIAL PRIMARY KEY,
  user1_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  user2_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL DEFAULT 'active', -- e.g., active, unmatched_by_user1, unmatched_by_user2, unmatched_by_system
  matched_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (user1_id, user2_id),
  CONSTRAINT check_users_order CHECK (user1_id < user2_id) -- Ensures (1,2) is stored, not (2,1), preventing duplicates
);
CREATE INDEX idx_matches_user2_id ON matches(user2_id); -- For querying matches involving a user


CREATE TABLE calls (
  id BIGSERIAL PRIMARY KEY,
  caller_id INTEGER NOT NULL REFERENCES accounts(id),
  receiver_id INTEGER NOT NULL REFERENCES accounts(id),
  type VARCHAR(50) NOT NULL, -- e.g., audio, video
  start_time TIMESTAMP WITHOUT TIME ZONE,
  end_time TIMESTAMP WITHOUT TIME ZONE,
  status VARCHAR(50) NOT NULL, -- e.g., initiated, ringing, answered, ended, missed, declined
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_calls_caller_id ON calls(caller_id);
CREATE INDEX idx_calls_receiver_id ON calls(receiver_id);


-- --- Bảng Quản lý, Báo cáo và Thông báo ---
CREATE TABLE report_requests (
  id SERIAL PRIMARY KEY,
  reporter_id INTEGER NOT NULL REFERENCES accounts(id),
  reported_user_id INTEGER NOT NULL REFERENCES accounts(id),
  type VARCHAR(100) NOT NULL, -- e.g., inappropriate_profile, spam, harassment
  description TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'pending', -- e.g., pending, investigating, resolved_action_taken, resolved_no_action
  resolved_at TIMESTAMP WITHOUT TIME ZONE,
  resolved_by INTEGER REFERENCES accounts(id), -- Admin/Moderator who resolved it
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE suspended_users (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE REFERENCES accounts(id) ON DELETE CASCADE, -- A user is either suspended or not
  report_id INTEGER REFERENCES report_requests(id), -- Optional: link to the report that caused suspension
  suspension_period INTEGER, -- in days, NULL for permanent
  suspended_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  type VARCHAR(100) NOT NULL, -- e.g., new_message, new_match, profile_view, system_update
  content TEXT NOT NULL,
  related_entity_id INTEGER, -- ID of the message, match, user etc.
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITHOUT TIME ZONE,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
  -- Consider adding a `link` or `action_url` field
);
CREATE INDEX idx_notifications_user_id_is_read_created_at ON notifications(user_id, is_read, created_at DESC);


-- --- Bảng Thanh toán và Gói dịch vụ ---

-- !!! WARNING: Storing raw card_numbers is a SEVERE security risk.
-- Use a payment gateway and store tokens instead.
CREATE TABLE payment_cards (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  card_numbers VARCHAR(255), -- HIGHLY INSECURE. Should be payment_token or similar from gateway.
  name_on_card VARCHAR(255), -- Changed from name_in_card
  expiration_date DATE, -- Format 'YYYY-MM' or full date depending on gateway
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
  id BIGSERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES accounts(id), -- No ON DELETE CASCADE, keep transaction history
  payment_card_id INTEGER REFERENCES payment_cards(id), -- Can be NULL if other payment methods or for audit of free plans
  premium_plan_id INTEGER REFERENCES premium_plans(id), -- Can be NULL if transaction is not for a plan (e.g. buying features)
  amount DECIMAL(10,2) NOT NULL,
  purchase_period VARCHAR(50),
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_plans (
  user_id INTEGER PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  plan_id INTEGER NOT NULL REFERENCES premium_plans(id),
  transaction_id INTEGER UNIQUE REFERENCES transactions(id),
  start_at DATE NOT NULL,
  end_at DATE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);