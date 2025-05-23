// lib/presentation/shared/widgets/otp_input_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputForm extends StatefulWidget {
  final int otpLength;
  final void Function(String otp) onSubmit;
  final bool resendAvailable;
  final VoidCallback? onResend;
  final int remainingSeconds; // Thêm tham số để hiển thị thời gian đếm ngược

  const OtpInputForm({
    super.key,
    this.otpLength = 6,
    required this.onSubmit,
    this.resendAvailable = false,
    this.onResend,
    required this.remainingSeconds, // Bắt buộc truyền giá trị
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

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
      _controllers[index].clear();
      return;
    }

    setState(() => _otpDigits[index] = value);

    if (value.isNotEmpty && index < widget.otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    if (_otpDigits.join().length == widget.otpLength) {
      _submit();
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
                  border: OutlineInputBorder(),
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
        if (widget.onResend != null) ...[
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.remainingSeconds > 0 || !widget.resendAvailable ? null : widget.onResend,
            child: Text(
              widget.remainingSeconds > 0
                  ? "Resend in ${widget.remainingSeconds}s"
                  : "Didn't receive code? Resend",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.remainingSeconds > 0 || !widget.resendAvailable
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary,
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