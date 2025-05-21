// lib/screens/common/cookie_policy_view.dart
import 'package:flutter/material.dart';

class CookiePolicyView extends StatelessWidget {
  const CookiePolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính Sách Cookie'),
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHÍNH SÁCH COOKIE CỦA AMOURA',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Cập nhật lần cuối: Ngày 1 tháng 8 năm 2023', // Ví dụ
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Cookie là gì?', textTheme, colorScheme),
            _buildParagraph(
                'Cookie là các tệp văn bản nhỏ được đặt trên thiết bị của bạn (máy tính, điện thoại, máy tính bảng) khi bạn truy cập trang web hoặc sử dụng ứng dụng. '
                    'Chúng được sử dụng rộng rãi để làm cho trang web hoạt động hoặc hoạt động hiệu quả hơn, cũng như để cung cấp thông tin cho chủ sở hữu trang web.',
                textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('2. Amoura sử dụng Cookie như thế nào?', textTheme, colorScheme),
            _buildParagraph(
                'Chúng tôi sử dụng cookie và các công nghệ theo dõi tương tự (như web beacons và pixel) cho các mục đích sau:',
                textTheme, colorScheme),
            _buildBulletPoint('Để vận hành Dịch vụ của chúng tôi: Cookie cần thiết cho phép bạn điều hướng trang web và sử dụng các tính năng của chúng tôi.', textTheme, colorScheme),
            _buildBulletPoint('Để cải thiện hiệu suất: Cookie giúp chúng tôi hiểu cách bạn sử dụng Dịch vụ để chúng tôi có thể cải thiện trải nghiệm của bạn.', textTheme, colorScheme),
            _buildBulletPoint('Để cung cấp các tính năng cá nhân hóa: Cookie giúp chúng tôi ghi nhớ các tùy chọn của bạn và cung cấp nội dung phù hợp.', textTheme, colorScheme),
            _buildBulletPoint('Để phân tích và nghiên cứu: Cookie giúp chúng tôi thu thập thông tin về cách bạn tương tác với Dịch vụ, bao gồm các trang bạn truy cập và các liên kết bạn nhấp vào.', textTheme, colorScheme),
            _buildBulletPoint('Để quảng cáo: Chúng tôi có thể sử dụng cookie để hiển thị quảng cáo phù hợp với sở thích của bạn.', textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('3. Các loại Cookie chúng tôi sử dụng', textTheme, colorScheme),
            _buildBulletPoint('Cookie bắt buộc: Những cookie này rất cần thiết để bạn có thể di chuyển xung quanh trang web và sử dụng các tính năng của nó.', textTheme, colorScheme),
            _buildBulletPoint('Cookie hiệu suất: Những cookie này thu thập thông tin về cách bạn sử dụng một trang web, ví dụ: những trang bạn truy cập thường xuyên nhất.', textTheme, colorScheme),
            _buildBulletPoint('Cookie chức năng: Những cookie này cho phép trang web ghi nhớ các lựa chọn bạn thực hiện (như tên người dùng, ngôn ngữ hoặc khu vực của bạn) và cung cấp các tính năng nâng cao, cá nhân hóa hơn.', textTheme, colorScheme),
            _buildBulletPoint('Cookie quảng cáo/định hướng: Những cookie này được sử dụng để cung cấp quảng cáo phù hợp hơn với bạn và sở thích của bạn.', textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('4. Quản lý cài đặt Cookie của bạn', textTheme, colorScheme),
            _buildParagraph(
                'Hầu hết các trình duyệt web đều cho phép bạn quản lý cookie thông qua cài đặt trình duyệt. Tuy nhiên, nếu bạn hạn chế khả năng của các trang web để đặt cookie, bạn có thể làm giảm trải nghiệm người dùng tổng thể của mình. '
                    'Bạn có thể tìm hiểu thêm về cách quản lý cookie trên trình duyệt của mình qua các liên kết sau (ví dụ): Chrome, Firefox, Safari, Edge.',
                textTheme, colorScheme),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Để biết thêm thông tin về Chính sách quyền riêng tư của chúng tôi, vui lòng truy cập mục liên quan.',
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

  Widget _buildBulletPoint(String text, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.75)),
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(height: 1.5, color: colorScheme.onSurface.withOpacity(0.75)),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}