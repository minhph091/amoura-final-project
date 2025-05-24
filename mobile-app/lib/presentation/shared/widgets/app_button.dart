import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutline;
  final IconData? icon;
  final Color? color;
  final OutlinedBorder? shape;
  final Color? textColor;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final bool useThemeGradient;
  final bool isDisabled;
  final BorderSide? borderSide;
  final bool isLoading;  // Thêm tham số
  final Widget? loading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutline = false,
    this.icon,
    this.color,
    this.shape,
    this.textColor,
    this.height,
    this.width,
    this.textStyle,
    this.elevation,
    this.padding,
    this.gradient,
    this.useThemeGradient = false,
    this.isDisabled = false,
    this.borderSide,
    this.isLoading = false,  // Giá trị mặc định
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Gradient? effectiveGradient = isDisabled
        ? LinearGradient(
            colors: [
              colorScheme.onSurface.withAlpha(20),
              colorScheme.onSurface.withAlpha(13)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight)
        : gradient ??
            (useThemeGradient
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)
                : null);

    final Color effectiveTextColor = isDisabled
        ? colorScheme.onSurface.withAlpha(97)
        : textColor ??
            (effectiveGradient != null
                ? Colors.white
                : (isOutline
                    ? (color ?? colorScheme.primary)
                    : Colors.white));

    final TextStyle buttonTextStyle = textStyle ??
        theme.textTheme.labelLarge?.copyWith(
            fontSize: 16, fontWeight: FontWeight.bold) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final TextStyle effectiveTextStyleWithColor = buttonTextStyle.copyWith(
        color: effectiveTextColor);

    final OutlinedBorder effectiveShape =
        shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(
            height != null ? (height! / 2) : 26));

    final double effectiveElevation = elevation ??
        (effectiveGradient != null
            ? 4.0
            : (isOutline
                ? 0
                : 2.0));

    final EdgeInsetsGeometry effectivePadding = padding ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12.0);

    Widget buttonContent = isLoading
        ? loading ?? const CircularProgressIndicator(color: Colors.white)
        : Text(
            text,
            style: effectiveTextStyleWithColor,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );

    if (icon != null && !isLoading) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: (buttonTextStyle.fontSize ?? 16) * 1.25,
              color: effectiveTextColor),
          const SizedBox(width: 8),
          Flexible(child: buttonContent),
        ],
      );
    }

    if (effectiveGradient != null && !isOutline && borderSide == null) {
      return Container(
        width: width,
        height: height ?? 52,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: (effectiveShape is RoundedRectangleBorder)
              ? (effectiveShape.borderRadius as BorderRadius?)?.resolve(
                  Directionality.of(context))
              : BorderRadius.circular(height ?? 52 / 2),
          boxShadow: [
            if (effectiveElevation > 0 && !isDisabled)
              BoxShadow(
                color: colorScheme.primary.withAlpha(25),
                spreadRadius: 0.4,
                blurRadius: effectiveElevation * 1.3,
                offset: Offset(0, effectiveElevation / 2.8),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: effectivePadding,
            shape: effectiveShape,
            minimumSize: Size(width ?? 0, height ?? 52),
            textStyle: effectiveTextStyleWithColor,
            foregroundColor: effectiveTextColor,
            disabledForegroundColor: colorScheme.onSurface.withAlpha(97),
            disabledBackgroundColor: Colors.transparent,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) =>
                  states.contains(WidgetState.pressed)
                      ? Colors.white.withAlpha(25)
                      : null,
            ),
          ),
          child: buttonContent,
        ),
      );
    }

    if (isOutline || borderSide != null) {
      return SizedBox(
        width: width,
        height: height ?? 52,
        child: OutlinedButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: color ?? Colors.transparent,
            shape: effectiveShape,
            padding: effectivePadding,
            elevation: effectiveElevation,
            minimumSize: Size(width ?? 0, height ?? 52),
            side: borderSide ??
                BorderSide(color: color ?? colorScheme.primary, width: 2),
            foregroundColor: effectiveTextColor,
            textStyle: effectiveTextStyleWithColor,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) =>
                  states.contains(WidgetState.pressed)
                      ? (color ?? colorScheme.primary).withAlpha(20)
                      : null,
            ),
          ),
          child: buttonContent,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? colorScheme.primary,
          shape: effectiveShape,
          padding: effectivePadding,
          elevation: effectiveElevation,
          minimumSize: Size(width ?? 0, height ?? 52),
          textStyle: effectiveTextStyleWithColor,
          foregroundColor: effectiveTextColor,
          shadowColor: colorScheme.shadow.withAlpha(43),
          disabledForegroundColor: colorScheme.onSurface.withAlpha(97),
          disabledBackgroundColor: colorScheme.onSurface.withAlpha(25),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) =>
                states.contains(WidgetState.pressed)
                    ? effectiveTextColor.withAlpha(20)
                    : null,
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}