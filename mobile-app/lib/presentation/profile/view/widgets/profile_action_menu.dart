import 'package:flutter/material.dart';
import '../../setup/theme/setup_profile_theme.dart';
import 'report_form_dialog.dart';

Future<void> showProfileActionMenu(BuildContext context, dynamic profile) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Báo cáo hồ sơ
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.red),
              title: const Text('Báo cáo hồ sơ'),
              onTap: () {
                Navigator.pop(ctx);
                _showReportDialog(context, profile);
              },
            ),

            // Chặn hồ sơ
            ListTile(
              leading: const Icon(Icons.block, color: Colors.grey),
              title: const Text('Chặn hồ sơ'),
              onTap: () {
                Navigator.pop(ctx);
                _showBlockConfirmationDialog(context, profile);
              },
            ),

            // Hủy
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Hủy'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showBlockConfirmationDialog(BuildContext context, dynamic profile) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chặn người dùng'),
      content: const Text('Bạn có muốn chặn người này không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            // Xử lý logic chặn người dùng ở đây
            // Trong th���c tế, bạn sẽ gọi API hoặc cập nhật Provider
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã chặn người dùng thành công')),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Chặn'),
        ),
      ],
    ),
  );
}

Future<void> _showReportDialog(BuildContext context, dynamic profile) async {
  showDialog(
    context: context,
    builder: (context) => const ReportFormDialog(),
    barrierDismissible: false,
  );
}