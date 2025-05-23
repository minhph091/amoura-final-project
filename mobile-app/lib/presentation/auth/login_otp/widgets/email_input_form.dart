//lib/presentation/auth/login_otp/widgets/email_input_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../login_otp_viewmodel.dart';

class EmailInputForm extends StatefulWidget {
  final void Function(String email) onSend;

  const EmailInputForm({super.key, required this.onSend});

  @override
  State<EmailInputForm> createState() => _EmailInputFormState();
}

class _EmailInputFormState extends State<EmailInputForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtl = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _animController.dispose();
    super.dispose();
  }

void _onSubmit() async {
  if (_formKey.currentState?.validate() ?? false) {
    final viewModel = Provider.of<LoginOtpViewModel>(context, listen: false);
    await viewModel.onSendOtp(_emailCtl.text.trim()); // Chỉ truyền email
    widget.onSend(_emailCtl.text.trim());
  }
}

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginOtpViewModel>(context);
    return FadeTransition(
      opacity: _animController,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _emailCtl,
              labelText: "Email",
              hintText: "Enter your email",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              prefixIconColor: Theme.of(context).colorScheme.primary,
              errorText: viewModel.errorMessage,
              validator: (v) => ValidationUtil().validateEmail(v),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "Send OTP",
              icon: Icons.send,
              isLoading: viewModel.isLoading,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}