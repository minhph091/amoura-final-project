-- Cập nhật bảng notifications để hỗ trợ module notification mới
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS title VARCHAR(255) NOT NULL DEFAULT 'Notification',
ADD COLUMN IF NOT EXISTS related_entity_type VARCHAR(50);

-- Cập nhật constraint để hỗ trợ các loại notification mới
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS chk_notification_type;

ALTER TABLE notifications 
ADD CONSTRAINT chk_notification_type CHECK (type IN (
    'MATCH', 'MESSAGE', 'SYSTEM', 'MARKETING', 'PROFILE_UPDATE', 'SECURITY_ALERT'
));

-- Tạo index để tối ưu performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read); 