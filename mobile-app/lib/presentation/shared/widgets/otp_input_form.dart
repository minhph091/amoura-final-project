// lib/presentation/shared/widgets/otp_input_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Form for entering OTP verification code
class OtpInputForm extends StatefulWidget {
  // Number of digits in OTP code
  final int otpLength;

  // Callback function when OTP is submitted
  final void Function(String otp) onSubmit;

  // Whether resend option should be available
  final bool resendAvailable;

  // Callback function for resending OTP
  final VoidCallback? onResend;

  const OtpInputForm({
    super.key,
    this.otpLength = 6,
    required this.onSubmit,
    this.resendAvailable = false,
    this.onResend,
  });

  @override
  State<OtpInputForm> createState() => _OtpInputFormState();
}

class _OtpInputFormState extends State<OtpInputForm> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otpDigits;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(widget.otpLength, (_) => FocusNode());
    _otpDigits = List.generate(widget.otpLength, (_) => '');
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Handle changes to individual OTP digits and manage focus
  void _onDigitChanged(int index, String value) {
    // Only allow digits
    if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
      _controllers[index].clear();
      return;
    }

    setState(() => _otpDigits[index] = value);

    // Auto-advance focus
    if (value.isNotEmpty && index < widget.otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    // Move focus back on delete
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  // Submit complete OTP code
  void _submit() {
    final otp = _otpDigits.join();
    if (otp.length == widget.otpLength) {
      widget.onSubmit(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.otpLength, (i) {
            return Container(
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: const InputDecoration(
                  counterText: '',
                  filled: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (v) => _onDigitChanged(i, v),
                onSubmitted: (v) {
                  if (i == widget.otpLength - 1) _submit();
                },
              ),
            );
          }),
        ),

        // Resend option
        if (widget.resendAvailable && widget.onResend != null) ...[
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.onResend,
            child: Text(
              "Didn't receive code? Resend",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Verify button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _otpDigits.join().length == widget.otpLength ? _submit : null,
            icon: const Icon(Icons.lock_open),
            label: const Text("Verify"),
          ),
        ),
      ],
    );
  }
}