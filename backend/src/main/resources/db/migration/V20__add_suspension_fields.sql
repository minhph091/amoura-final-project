-- Add suspension fields to users table
ALTER TABLE users 
ADD COLUMN suspension_until TIMESTAMP NULL,
ADD COLUMN suspension_reason TEXT NULL;

-- Add index for better performance when checking suspension status
CREATE INDEX idx_users_suspension_until ON users(suspension_until);
CREATE INDEX idx_users_status_suspension ON users(status, suspension_until);