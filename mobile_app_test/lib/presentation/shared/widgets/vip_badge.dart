import 'package:flutter/material.dart';

class VipBadge extends StatelessWidget {
  final double size;
  final bool compact;

  const VipBadge({
    super.key,
    this.size = 1.0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.0 : 8.0,
        vertical: compact ? 2.0 : 4.0,
      ) * size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 4.0 : 8.0) * size,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.3),
            blurRadius: 4.0 * size,
            spreadRadius: 0,
            offset: Offset(0, 2.0 * size),
          ),
        ],
      ),
      child: Text(
        'VIP',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: (compact ? 10.0 : 12.0) * size,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
