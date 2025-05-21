// lib/presentation/shared/widgets/app_text_field.dart

import 'package:flutter/material.dart';

// Mở rộng Color để thêm thuộc tính alpha
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onEditingComplete;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final String? initialValue;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool autofocus;
  final AutovalidateMode? autovalidateMode;
  final int? maxLength;
  final String? errorText;

  // Các props override màu
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? floatingLabelColor;
  final Color? prefixIconColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? cursorColor;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.onSaved,
    this.onEditingComplete,
    this.onTap,
    this.focusNode,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.initialValue,
    this.decoration,
    this.style,
    this.autofocus = false,
    this.autovalidateMode,
    this.maxLength,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.floatingLabelColor,
    this.prefixIconColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.cursorColor,
    this.contentPadding,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Màu chữ nhập vào
    final TextStyle effectiveTextStyle = style ??
        theme.textTheme.bodyLarge?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
        ) ??
        TextStyle(color: textColor ?? theme.colorScheme.onSurface);

    // Màu nền
    final Color effectiveFillColor = fillColor ?? theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;

    // Border radius mặc định
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(16));

    // Màu viền
    final Color effectiveEnabledBorderColor = enabledBorderColor ?? theme.colorScheme.outline.withValues(alpha: 0.7);
    final Color effectiveFocusedBorderColor = focusedBorderColor ?? theme.colorScheme.primary;
    final Color effectiveErrorBorderColor = errorBorderColor ?? theme.colorScheme.error;

    // Màu icon
    final Color effectivePrefixIconColor = prefixIconColor ?? theme.iconTheme.color ?? theme.colorScheme.primary;

    // Style hint
    final TextStyle effectiveHintStyle = theme.inputDecorationTheme.hintStyle?.copyWith(
      color: hintColor ?? theme.inputDecorationTheme.hintStyle?.color ?? theme.colorScheme.onSurface.withValues(alpha: 0.5),
    ) ??
        TextStyle(color: hintColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.5));

    // Style label
    final TextStyle effectiveLabelStyle = theme.inputDecorationTheme.labelStyle?.copyWith(
      color: labelColor ?? theme.inputDecorationTheme.labelStyle?.color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
    ) ??
        TextStyle(color: labelColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7));

    // Style floating label (focus)
    final TextStyle effectiveFloatingLabelStyle = theme.inputDecorationTheme.floatingLabelStyle?.copyWith(
      color: floatingLabelColor ?? labelColor ?? theme.colorScheme.primary,
    ) ??
        TextStyle(color: floatingLabelColor ?? labelColor ?? theme.colorScheme.primary, fontWeight: FontWeight.w600);

    // Màu con trỏ
    final Color effectiveCursorColor = cursorColor ?? theme.colorScheme.primary;

    // Padding text
    final EdgeInsetsGeometry effectiveContentPadding = contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    final InputDecoration finalDecoration = decoration ??
        InputDecoration(
          labelText: labelText,
          labelStyle: effectiveLabelStyle,
          hintText: hintText,
          hintStyle: effectiveHintStyle,
          prefixIcon: prefixIcon != null
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(prefixIcon, color: effectivePrefixIconColor, size: 22),
          )
              : null,
          suffixIcon: suffixIcon,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: effectiveEnabledBorderColor, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: effectiveEnabledBorderColor, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: effectiveErrorBorderColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: effectiveErrorBorderColor, width: 2.0),
          ),
          floatingLabelStyle: effectiveFloatingLabelStyle,
          filled: true,
          fillColor: effectiveFillColor,
          isDense: true,
          contentPadding: effectiveContentPadding,
        );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSaved: onSaved,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      focusNode: focusNode,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      style: effectiveTextStyle,
      decoration: finalDecoration,
      cursorColor: effectiveCursorColor,
      maxLength: maxLength,
    );
  }
}