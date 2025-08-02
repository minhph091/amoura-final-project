// Central hub for all translations
import 'en.dart' as english;
import 'vi.dart' as vietnamese;

// Map of supported languages with their translations
final Map<String, Map<String, dynamic>> supportedLanguages = {
  'en': english.en,
  'vi': vietnamese.vi,
};

// Để thêm ngôn ngữ mới (ví dụ tiếng Trung), chỉ cần:
// 1. Tạo file zh.dart với final Map<String, dynamic> zh = {...}
// 2. Import: import 'zh.dart' as chinese;
// 3. Thêm vào map: 'zh': chinese.zh,
