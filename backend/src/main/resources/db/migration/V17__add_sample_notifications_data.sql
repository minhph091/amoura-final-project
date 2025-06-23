-- Sample notifications for user with id = 1, type = SYSTEM
INSERT INTO notifications (user_id, type, content, related_entity_id, is_read, read_at, created_at, updated_at)
VALUES
(1, 'SYSTEM', 'Chào mừng bạn đến với Amoura! Hãy cập nhật hồ sơ để tăng cơ hội kết nối.', NULL, FALSE, NULL, NOW(), NOW()),
(1, 'SYSTEM', 'Hệ thống sẽ bảo trì vào lúc 23:00 ngày 10/06/2024. Vui lòng lưu lại công việc.', NULL, FALSE, NULL, NOW(), NOW()),
(1, 'SYSTEM', 'Bạn đã nhận được 1 tháng dùng thử miễn phí gói Premium!', NULL, FALSE, NULL, NOW(), NOW()); 