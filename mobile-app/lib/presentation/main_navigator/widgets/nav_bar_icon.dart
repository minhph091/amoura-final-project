import 'package:flutter/material.dart';

class NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final double size;

  const NavBarIcon({
    super.key,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: isActive ? activeColor : Colors.grey.shade500,
    );
  }
}