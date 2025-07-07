// lib/presentation/settings/widgets/settings_logout_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_viewmodel.dart';
import '../../shared/dialogs/confirm_dialog.dart';
import '../../../app/routes/app_routes.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final viewModel = Provider.of<SettingsViewModel>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      width: size.width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
          minimumSize: Size(size.width, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
        ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: viewModel.isLoading
            ? null
            : () => _handleLogout(context, viewModel),
      ),
    );
  }

  void _handleLogout(BuildContext context, SettingsViewModel viewModel) async {
    final result = await showConfirmDialog(
      context: context,
      title: 'Log Out',
      content: 'Are you sure you want to log out of your account?',
      confirmText: 'Yes, Log Out',
      cancelText: 'No, Cancel',
      icon: Icons.logout_rounded,
      iconColor: Theme.of(context).colorScheme.error,
      onConfirm: () async {
        // Hàm rỗng để đảm bảo nút "Yes, Log Out" không bị disable
        // Logic logout sẽ được xử lý sau khi dialog trả về true
      },
    );

    print('Logout confirmation result: $result'); // Log để kiểm tra giá trị trả về

    if (result == true) {
      print('User confirmed logout, proceeding with logout process'); // Log thêm
      try {
        await viewModel.logout(context);
        print('Logout successful, navigating to WelcomeView'); // Log xác nhận logout thành công
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.welcome,
          (route) => false,
        );
      } catch (e) {
        print('Caught error in _handleLogout: $e'); // Log lỗi nếu có
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    } else {
      print('Logout cancelled or dialog dismissed with result: $result'); // Log nếu hủy hoặc đóng dialog
    }
  }
}