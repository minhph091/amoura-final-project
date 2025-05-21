// lib/screens/common/help_center_view.dart
import 'package:flutter/material.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung Tâm Trợ Giúp & FAQ'),
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHÀO MỪNG ĐẾN VỚI TRUNG TÂM TRỢ GIÚP AMOURA',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Tìm câu trả lời cho các câu hỏi thường gặp của bạn và nhận hỗ trợ từ đội ngũ của chúng tôi.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('CÂU HỎI THƯỜNG GẶP (FAQ)', textTheme, colorScheme),
            _buildFAQItem(
              question: 'Làm thế nào để tạo tài khoản Amoura?',
              answer: 'Bạn có thể tạo tài khoản Amoura bằng cách tải ứng dụng từ App Store hoặc Google Play, sau đó làm theo hướng dẫn đăng ký trên màn hình.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'Tôi quên mật khẩu, phải làm sao?',
              answer: 'Trên màn hình đăng nhập, chọn "Quên mật khẩu?" và làm theo hướng dẫn để đặt lại mật khẩu của bạn qua email hoặc số điện thoại đã đăng ký.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'Làm thế nào để cập nhật thông tin cá nhân?',
              answer: 'Truy cập "Hồ sơ của bạn" từ phần cài đặt ứng dụng. Tại đây bạn có thể chỉnh sửa ảnh, giới thiệu bản thân, sở thích và các thông tin khác.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'Làm thế nào để báo cáo một người dùng?',
              answer: 'Nếu bạn gặp phải hành vi không phù hợp, bạn có thể báo cáo người dùng đó bằng cách truy cập hồ sơ của họ và chọn tùy chọn "Báo cáo người dùng". Chúng tôi sẽ xem xét báo cáo của bạn một cách nghiêm túc.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'Làm thế nào để xóa tài khoản Amoura?',
              answer: 'Bạn có thể xóa tài khoản của mình vĩnh viễn trong phần "Cài đặt & Tài khoản" -> "Quản lý dữ liệu". Vui lòng lưu ý rằng hành động này không thể hoàn tác.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('LIÊN HỆ CHÚNG TÔI', textTheme, colorScheme),
            _buildParagraph(
                'Nếu bạn không tìm thấy câu trả lời cho câu hỏi của mình ở đây hoặc cần hỗ trợ thêm, vui lòng liên hệ với đội ngũ hỗ trợ của chúng tôi.',
                textTheme, colorScheme),
            const SizedBox(height: 10),
            Text(
              'Email: support@amoura.com', // Thay thế bằng email hỗ trợ thực tế
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.75)),
            ),
            Text(
              'Giờ làm việc: Thứ Hai - Thứ Sáu, 9:00 AM - 5:00 PM (GMT+7)',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.75)),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Amoura Team luôn sẵn sàng hỗ trợ bạn!',
                style: textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, color: colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onBackground.withOpacity(0.85)),
      ),
    );
  }

  Widget _buildParagraph(String text, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: textTheme.bodyLarge?.copyWith(height: 1.5, color: colorScheme.onSurface.withOpacity(0.75)),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onBackground),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
          child: Text(
            answer,
            style: textTheme.bodyLarge?.copyWith(height: 1.5, color: colorScheme.onSurface.withOpacity(0.75)),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}