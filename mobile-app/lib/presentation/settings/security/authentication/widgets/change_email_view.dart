import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import 'change_email_viewmodel.dart';
import 'email_password_form.dart';
import 'email_change_form.dart';
import 'email_otp_form.dart';

class ChangeEmailView extends StatelessWidget {
  const ChangeEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangeEmailViewModel(),
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Change Email'),
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
