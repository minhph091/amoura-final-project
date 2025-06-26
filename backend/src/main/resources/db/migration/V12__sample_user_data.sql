-- Insert 10 users with Vietnamese names
INSERT INTO users (username, password_hash, email, phone_number, first_name, last_name, role_id, status, created_at)
VALUES
    ('nguyen_van_an', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'nguyen.van.an@example.com', '+84901234501', 'Văn An', 'Nguyễn', 1, 'active', CURRENT_TIMESTAMP),
    ('tran_thi_bich', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'tran.thi.bich@example.com', '+84901234502', 'Thị Bích', 'Trần', 1, 'active', CURRENT_TIMESTAMP),
    ('le_hoang_cuong', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'le.hoang.cuong@example.com', '+84901234503', 'Hoàng Cương', 'Lê', 1, 'active', CURRENT_TIMESTAMP),
    ('pham_minh_duc', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'pham.minh.duc@example.com', '+84901234504', 'Minh Đức', 'Phạm', 1, 'active', CURRENT_TIMESTAMP),
    ('vu_thi_hoa', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'vu.thi.hoa@example.com', '+84901234505', 'Thị Hoa', 'Vũ', 1, 'active', CURRENT_TIMESTAMP),
    ('do_quang_huy', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'do.quang.huy@example.com', '+84901234506', 'Quang Huy', 'Đỗ', 1, 'active', CURRENT_TIMESTAMP),
    ('hoang_thi_lan', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'hoang.thi.lan@example.com', '+84901234507', 'Thị Lan', 'Hoàng', 1, 'active', CURRENT_TIMESTAMP),
    ('bui_van_manh', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'bui.van.manh@example.com', '+84901234508', 'Văn Mạnh', 'Bùi', 1, 'active', CURRENT_TIMESTAMP),
    ('ngo_thi_ngoc', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'ngo.thi.ngoc@example.com', '+84901234509', 'Thị Ngọc', 'Ngô', 1, 'active', CURRENT_TIMESTAMP),
    ('dang_duc_thang', '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO', 'dang.duc.thang@example.com', '+84901234510', 'Đức Thắng', 'Đặng', 1, 'active', CURRENT_TIMESTAMP);

-- Insert profiles for the 10 users
INSERT INTO profiles (user_id, date_of_birth, height, body_type_id, sex, orientation_id, job_industry_id, drink_status_id, smoke_status_id, interested_in_new_language, education_level_id, drop_out, location_preference, bio)
VALUES
    (1, '1990-01-15', 175, 3, 'male', 3, 7, 3, 1, TRUE, 3, FALSE, 50, 'Yêu thích leo núi và lập trình!'),
    (2, '1992-03-22', 165, 2, 'female', 1, 5, 2, 2, FALSE, 4, FALSE, 30, 'Đam mê nghệ thuật và du lịch.'),
    (3, '1995-07-10', 170, 1, 'female', 2, 2, 1, 1, TRUE, 2, FALSE, 20, 'Yêu sách và cà phê.'),
    (4, '1988-11-05', 180, 4, 'male', 3, 3, 4, 3, FALSE, 5, FALSE, 40, 'Kỹ sư ban ngày, game thủ ban đêm.'),
    (5, '1993-04-18', 160, 5, 'female', 1, 1, 2, 1, TRUE, 3, FALSE, 25, 'Luôn sẵn sàng cho một cuộc phiêu lưu!'),
    (6, '1991-09-30', 178, 3, 'male', 2, 10, 3, 4, FALSE, 4, FALSE, 35, 'Âm nhạc là cuộc sống của tôi.'),
    (7, '1994-02-25', 162, 2, 'female', 3, 6, 1, 1, TRUE, 2, FALSE, 15, 'Yêu ẩm thực và thể dục.'),
    (8, '1989-06-12', 182, 4, 'male', 1, 8, 4, 2, FALSE, 3, FALSE, 45, 'Khám phá thế giới từng thành phố một.'),
    (9, '1996-08-08', 167, 6, 'female', 2, 4, 2, 1, TRUE, 1, TRUE, 10, 'Người mơ mộng và hành động.'),
    (10, '1990-12-01', 170, 3, 'non-binary', 1, 11, 3, 3, FALSE, 3, FALSE, 20, 'Yêu game và thú cưng.');

-- Insert locations for the 10 users in Vietnam
INSERT INTO locations (user_id, latitudes, longitudes, country, state, city, version)
VALUES
    (1, 21.0285, 105.8542, 'Vietnam', 'Hà Nội', 'Hà Nội', 0),
    (2, 10.7769, 106.7009, 'Vietnam', 'TP. Hồ Chí Minh', 'TP. Hồ Chí Minh', 0),
    (3, 16.0544, 108.2022, 'Vietnam', 'Đà Nẵng', 'Đà Nẵng', 0),
    (4, 20.8449, 106.6881, 'Vietnam', 'Hải Phòng', 'Hải Phòng', 0),
    (5, 10.0371, 105.7800, 'Vietnam', 'Cần Thơ', 'Cần Thơ', 0),
    (6, 17.4658, 106.5893, 'Vietnam', 'Quảng Bình', 'Đồng Hới', 0),
    (7, 12.2451, 109.1943, 'Vietnam', 'Kiên Giang', 'Phú Quốc', 0),
    (8, 13.7563, 109.2198, 'Vietnam', 'Khánh Hòa', 'Nha Trang', 0),
    (9, 11.9404, 108.4583, 'Vietnam', 'Lâm Đồng', 'Đà Lạt', 0),
    (10, 16.4673, 107.5789, 'Vietnam', 'Thừa Thiên Huế', 'Huế', 0);

-- Insert photos for the 10 users (avatar, profile_cover, highlight1, highlight2)
INSERT INTO photos (user_id, path, type, created_at)
VALUES
    (1, 'users/1/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (1, 'users/1/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (1, 'users/1/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (1, 'users/1/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (2, 'users/2/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (2, 'users/2/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (2, 'users/2/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (2, 'users/2/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (3, 'users/3/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (3, 'users/3/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (3, 'users/3/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (3, 'users/3/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (4, 'users/4/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (4, 'users/4/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (4, 'users/4/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (4, 'users/4/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (5, 'users/5/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (5, 'users/5/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (5, 'users/5/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (5, 'users/5/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (6, 'users/6/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (6, 'users/6/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (6, 'users/6/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (6, 'users/6/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (7, 'users/7/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (7, 'users/7/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (7, 'users/7/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (7, 'users/7/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (8, 'users/8/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (8, 'users/8/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (8, 'users/8/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (8, 'users/8/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (9, 'users/9/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (9, 'users/9/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (9, 'users/9/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (9, 'users/9/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847'),
    (10, 'users/10/avatar.jpg', 'avatar', '2025-06-15T17:45:05.856807'),
    (10, 'users/10/profile_cover.jpg', 'profile_cover', '2025-06-15T17:45:34.406446'),
    (10, 'users/10/highlight1.jpg', 'highlight', '2025-06-15T17:45:22.350297'),
    (10, 'users/10/highlight2.jpg', 'highlight', '2025-06-15T17:46:06.855847');

-- Insert sample pets for users
INSERT INTO users_pets (user_id, pet_id)
VALUES
    (1, 3), -- Nguyễn Văn An has a Dog
    (2, 2), -- Trần Thị Bích has a Cat
    (3, 1), -- Lê Hoàng Cương has a Bird
    (4, 4), -- Phạm Minh Đức has a Fish
    (5, 8), -- Vũ Thị Hoa has a Rabbit
    (6, 3), -- Đỗ Quang Huy has a Dog
    (7, 2), -- Hoàng Thị Lan has a Cat
    (8, 6), -- Bùi Văn Mạnh has a Horse
    (9, 9), -- Ngô Thị Ngọc has a Reptile
    (10, 7); -- Đặng Đức Thắng has an Other pet

-- Insert sample interests for users
INSERT INTO users_interests (user_id, interest_id)
VALUES
    (1, 3), (1, 7), -- Nguyễn Văn An: Fitness & Sports, Nature & Outdoors
    (2, 1), (2, 9), -- Trần Thị Bích: Art & Design, Travel
    (3, 8), (3, 5), -- Lê Hoàng Cương: Reading, Movies & TV
    (4, 4), (4, 3), -- Phạm Minh Đức: Gaming, Fitness & Sports
    (5, 9), (5, 7), -- Vũ Thị Hoa: Travel, Nature & Outdoors
    (6, 6), (6, 4), -- Đỗ Quang Huy: Music, Gaming
    (7, 2), (7, 3), -- Hoàng Thị Lan: Cooking & Food, Fitness & Sports
    (8, 9), (8, 1), -- Bùi Văn Mạnh: Travel, Art & Design
    (9, 10), (9, 8), -- Ngô Thị Ngọc: Volunteering, Reading
    (10, 4), (10, 6); -- Đặng Đức Thắng: Gaming, Music

-- Insert sample languages for users
INSERT INTO users_languages (user_id, language_id)
VALUES
    (1, 20), (1, 3), -- Nguyễn Văn An: Vietnamese, English
    (2, 20), (2, 4), -- Trần Thị Bích: Vietnamese, French
    (3, 20), (3, 3), -- Lê Hoàng Cương: Vietnamese, English
    (4, 20), (4, 8), -- Phạm Minh Đức: Vietnamese, Japanese
    (5, 20), (5, 3), -- Vũ Thị Hoa: Vietnamese, English
    (6, 20), (6, 11), -- Đỗ Quang Huy: Vietnamese, Mandarin
    (7, 20), (7, 3), -- Hoàng Thị Lan: Vietnamese, English
    (8, 20), (8, 4), -- Bùi Văn Mạnh: Vietnamese, French
    (9, 20), (9, 3), -- Ngô Thị Ngọc: Vietnamese, English
    (10, 20), (10, 8); -- Đặng Đức Thắng: Vietnamese, Japanese