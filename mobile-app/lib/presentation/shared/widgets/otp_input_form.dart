// lib/presentation/shared/widgets/otp_input_form.dart

import 'package:flutter/material.dart';

class OtpInputForm extends StatefulWidget {
  final int otpLength;
  final void Function(String otp) onSubmit;
  final bool resendAvailable;
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
    for (var ctl in _controllers) {
      ctl.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) value = value.substring(value.length - 1);
    setState(() => _otpDigits[index] = value);
    if (value.isNotEmpty && index < widget.otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

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
        // Các ô nhập OTP
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
                onChanged: (v) => _onDigitChanged(i, v),
                onSubmitted: (v) {
                  if (i == widget.otpLength - 1) _submit();
                },
              ),
            );
          }),
        ),
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