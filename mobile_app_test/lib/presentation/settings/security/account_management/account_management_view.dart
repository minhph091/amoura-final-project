// lib/presentation/settings/security/account_management/account_management_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/language/app_localizations.dart';
import '../../widgets/settings_section_title.dart';
import '../../widgets/settings_tile.dart';
import 'account_management_viewmodel.dart';
import 'widgets/deactivate_account_dialog.dart';
import 'widgets/delete_account_dialog.dart';

class AccountManagementView extends StatefulWidget {
  const AccountManagementView({super.key});

  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView>
    with TickerProviderStateMixin {
  late AnimationController _staggeredListController;

  @override
  void initState() {
    super.initState();
    _staggeredListController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150 + 2 * 80), // 2 items
    )..forward();
  }

  @override
  void dispose() {
    _staggeredListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final viewModel = AccountManagementViewModel();

    final List<Map<String, dynamic>> accountItems = [
      {
        'icon': Icons.lock_person_outlined,
        'title': localizations.translate('deactivate_account'),
        'subtitle': localizations.translate('deactivate_account_info'),
        'action': (BuildContext context, AccountManagementViewModel viewModel) {
          return showDeactivateAccountDialog(context, viewModel);
        },
        'isDestructive': false,
      },
      {
        'icon': Icons.delete_forever,
        'title': localizations.translate('delete_account'),
        'subtitle': localizations.translate('delete_account_info'),
        'action': (BuildContext context, AccountManagementViewModel viewModel) {
          return showDeleteAccountDialog(context, viewModel);
        },
        'isDestructive': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(
          title: localizations.translate('account_management'),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: accountItems.length,
          itemBuilder: (context, index) {
            final item = accountItems[index];
            final Duration itemDelay = (100 + index * 70).ms;
            return SettingsTile(
                  icon: item['icon'] as IconData,
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  iconColor: item['isDestructive'] == true ? Colors.red : null,
                  titleColor: item['isDestructive'] == true ? Colors.red : null,
                  onTap: () => (item['action'] as Function)(context, viewModel),
                )
                .animate(controller: _staggeredListController, autoPlay: false)
                .fadeIn(delay: itemDelay, duration: 350.ms)
                .slideY(
                  begin: 0.15,
                  delay: itemDelay,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                );
          },
          separatorBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                height: 0.8,
                thickness: 0.8,
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.25),
              ),
            ).animate().fadeIn(delay: (150 + index * 70).ms);
          },
        ),
      ],
    );
  }
}
