import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/data/repositories/user_repository.dart';
import '../../../../../config/language/app_localizations.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import 'change_email_viewmodel.dart';
import 'email_password_form.dart';
import 'email_change_form.dart';
import 'email_otp_form.dart';

class ChangeEmailView extends StatelessWidget {
  const ChangeEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => ChangeEmailViewModel(userRepository: userRepository),
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localizations.translate('change_email')),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Consumer<ChangeEmailViewModel>(
              builder: (context, viewModel, child) {
                // Xử lý nút Back để điều hướng giữa các bước
                return IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (viewModel.currentStage != ChangeEmailStage.enterPassword) {
                      viewModel.goBack();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
          body: SafeArea(
            child: Consumer<ChangeEmailViewModel>(
              builder: (context, viewModel, child) {
                switch (viewModel.currentStage) {
                  case ChangeEmailStage.enterPassword:
                    return EmailPasswordForm(viewModel: viewModel);
                  case ChangeEmailStage.enterNewEmail:
                    return EmailChangeForm(viewModel: viewModel);
                  case ChangeEmailStage.enterOtp:
                    return EmailOtpForm(viewModel: viewModel);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
