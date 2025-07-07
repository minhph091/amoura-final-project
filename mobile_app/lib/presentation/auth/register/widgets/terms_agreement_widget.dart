import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../common/terms_of_service_view.dart';
import '../../../common/privacy_policy_view.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/language/app_localizations.dart';

class TermsAgreementWidget extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool> onChanged;
  final AppLocalizations? localizations;

  const TermsAgreementWidget({
    super.key,
    required this.isAgreed,
    required this.onChanged,
    this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -2),
            child: Checkbox(
              value: isAgreed,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: loc.translate('terms_agreement').split(loc.translate('terms_service'))[0],
                  ),
                  TextSpan(
                    text: loc.translate('terms_service'),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsOfServiceView()),
                        );
                      },
                  ),
                  TextSpan(
                    text: loc.translate('terms_agreement').split(loc.translate('terms_service'))[1].split(loc.translate('privacy_policy'))[0],
                  ),
                  TextSpan(
                    text: loc.translate('privacy_policy'),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacyPolicyView()),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}