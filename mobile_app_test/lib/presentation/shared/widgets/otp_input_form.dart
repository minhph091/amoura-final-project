// lib/presentation/shared/widgets/otp_input_form.dart
import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';

class OtpInputForm extends StatefulWidget {
  final int otpLength;
  final Future<void> Function(String)? onSubmit;
  final bool resendAvailable;
  final VoidCallback? onResend;
  final int? remainingSeconds;
  final String? errorMessage;
  final bool isLoading;

  const OtpInputForm({
    super.key,
    this.otpLength = 6,
    this.onSubmit,
    this.resendAvailable = false,
    this.onResend,
    this.remainingSeconds,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  State<OtpInputForm> createState() => _OtpInputFormState();
}

class _OtpInputFormState extends State<OtpInputForm> {
  late List<String> _otpDigits;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _otpDigits = List.filled(widget.otpLength, '');
    _focusNodes = List.generate(widget.otpLength, (_) => FocusNode());
    _controllers = List.generate(
      widget.otpLength,
      (_) => TextEditingController(),
    );
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) value = value.substring(value.length - 1);
    setState(() {
      _otpDigits[index] = value.trim();
      _controllers[index].text = value.trim();
    });
    debugPrint('Digit $index changed to: $value');

    if (value.isNotEmpty && index < widget.otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    final otp = _otpDigits.join();
    if (otp.length == widget.otpLength &&
        otp.trim().isNotEmpty &&
        !_isSubmitting) {
      debugPrint('Submitting OTP: $otp');
      _submitOtp(otp);
    }
  }

  Future<void> _submitOtp(String otp) async {
    if (widget.onSubmit == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit!(otp);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.otpLength, (index) {
            return SizedBox(
              width: 50,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                enabled: !_isSubmitting,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                onChanged: (value) => _onDigitChanged(index, value),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // Hiển thị loading indicator khi đang submit
        if (_isSubmitting) ...[
          const SizedBox(height: 12),
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
        ],
        // Hiển thị bộ đếm ngược hoặc nút Resend OTP
        if (widget.remainingSeconds != null && !widget.resendAvailable)
          Text(
            '${localizations.translate('resend_otp_in')} ${widget.remainingSeconds}s',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          )
        else if (widget.resendAvailable && !_isSubmitting)
          TextButton(
            onPressed: widget.isLoading ? null : widget.onResend,
            child: Text(
              localizations.translate('resend_otp'),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
