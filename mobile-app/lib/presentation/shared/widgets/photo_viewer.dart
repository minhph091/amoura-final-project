// lib/presentation/shared/widgets/photo_viewer.dart

import 'package:flutter/material.dart';

void showPhotoViewer(BuildContext context, String imageUrl, {String? tag, Color backgroundColor = Colors.black}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => _PhotoViewer(imageUrl: imageUrl, tag: tag, backgroundColor: backgroundColor),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
      opaque: false,
      barrierColor: backgroundColor.withValues(alpha: 0.98),
    ),
  );
}

class _PhotoViewer extends StatelessWidget {
  final String imageUrl;
  final String? tag;
  final Color backgroundColor;

  const _PhotoViewer({required this.imageUrl, this.tag, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: tag ?? imageUrl,
            child: InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}