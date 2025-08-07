-- Tạo tài khoản admin mới với hash đã xác thực (mật khẩu: Amoura123@)
INSERT INTO users (
  username, password_hash, email, phone_number, first_name, last_name, role_id, status, created_at
) VALUES (
  'admin',
  '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO',
  'admin@amoura.space',
  '0123456789',
  'Admin',
  'Super',
  (SELECT id FROM roles WHERE name = 'ADMIN'),
  'active',
  NOW()
);

-- Tạo tài khoản moderator mới với hash đã xác thực (mật khẩu: Amoura123@)
INSERT INTO users (
  username, password_hash, email, phone_number, first_name, last_name, role_id, status, created_at
) VALUES (
  'moderator',
  '$2a$10$cbFwxATqL9vPnocjhrr/Ge9cP1sjHmob4eInthJaKUf2Byoa1R8YO',
  'moderator@amoura.space',
  '0987654321',
  'Moderator',
  'Super',
  (SELECT id FROM roles WHERE name = 'MODERATOR'),
  'active',
  NOW()
);
