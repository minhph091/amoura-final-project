// lib/presentation/settings/widgets/settings_logout_button.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_viewmodel.dart';
import '../../shared/dialogs/confirm_dialog.dart';
import '../../../app/routes/app_routes.dart';
import '../../../config/language/app_localizations.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final viewModel = Provider.of<SettingsViewModel>(context);
    final localizations = AppLocalizations.of(context);

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
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          localizations.translate('log_out'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed:
            viewModel.isLoading
                ? null
                : () => _handleLogout(context, viewModel),
      ),
    );
  }

  void _handleLogout(BuildContext context, SettingsViewModel viewModel) async {
    final localizations = AppLocalizations.of(context);
    final result = await showConfirmDialog(
      context: context,
      title: localizations.translate('logout_title'),
      content: localizations.translate('logout_confirmation'),
      confirmText: localizations.translate('yes_logout'),
      cancelText: localizations.translate('no_cancel'),
      icon: Icons.logout_rounded,
      iconColor: Theme.of(context).colorScheme.error,
      onConfirm: () async {
        // Hàm rỗng để đảm bảo nút "Yes, Log Out" không bị disable
        // Logic logout sẽ được xử lý sau khi dialog trả về true
      },
    );

    debugPrint(
      'Logout confirmation result: $result',
    ); // Log để kiểm tra giá trị trả về

    if (result == true) {
      debugPrint(
        'User confirmed logout, proceeding with logout process',
      ); // Log thêm
      try {
        await viewModel.logout(context);
        debugPrint(
          'Logout successful, navigating to WelcomeView',
        ); // Log xác nhận logout thành công
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.welcome,
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Caught error in _handleLogout: $e'); // Log lỗi nếu có
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
        }
      }
    } else {
      debugPrint(
        'Logout cancelled or dialog dismissed with result: $result',
      ); // Log nếu hủy hoặc đóng dialog
    }
  }
}
