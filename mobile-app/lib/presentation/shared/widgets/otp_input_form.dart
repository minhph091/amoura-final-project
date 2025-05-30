// lib/presentation/shared/widgets/otp_input_form.dart
import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class OtpInputForm extends StatefulWidget {
  final int otpLength;
  final Function(String) onSubmit;
  final bool resendAvailable;
  final VoidCallback? onResend;
  final int? remainingSeconds;
  final String? errorMessage;

  const OtpInputForm({
    Key? key,
    this.otpLength = 6,
    required this.onSubmit,
    this.resendAvailable = false,
    this.onResend,
    this.remainingSeconds,
    this.errorMessage,
  }) : super(key: key);

  @override
  _OtpInputFormState createState() => _OtpInputFormState();
}

class _OtpInputFormState extends State<OtpInputForm> {
  late List<String> _otpDigits;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _otpDigits = List.filled(widget.otpLength, '');
    _focusNodes = List.generate(widget.otpLength, (_) => FocusNode());
    _controllers = List.generate(widget.otpLength, (_) => TextEditingController());
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) value = value.substring(value.length - 1);
    setState(() {
      _otpDigits[index] = value.trim();
      _controllers[index].text = value.trim();
    });
    print('Digit $index changed to: $value');

    if (value.isNotEmpty && index < widget.otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    final otp = _otpDigits.join();
    if (otp.length == widget.otpLength && otp.trim().isNotEmpty) {
      print('Submitting OTP: $otp');
      widget.onSubmit(otp);
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
        // Hiển thị bộ đếm ngược hoặc nút Resend OTP
        if (widget.remainingSeconds != null && !widget.resendAvailable)
          Text(
            'Resend OTP in ${widget.remainingSeconds}s',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          )
        else if (widget.resendAvailable)
          TextButton(
            onPressed: widget.onResend,
            child: Text(
              'Resend OTP',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // Hiển thị thông báo lỗi hoặc thành công
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.errorMessage!,
            style: TextStyle(
              color: widget.errorMessage!.contains('A new OTP has been sent')
                  ? colorScheme.primary
                  : colorScheme.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}