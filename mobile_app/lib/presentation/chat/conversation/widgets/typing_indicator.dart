 import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;
  final String? userName;
  final bool isDarkMode;

  const TypingIndicator({
    super.key,
    required this.isTyping,
    this.userName,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTyping) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = isDarkMode || theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Typing dots animation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.grey[800]!.withValues(alpha: 0.8)
                  : Colors.grey[200]!.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                    delay: 0.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: 600.ms,
                  ),
                
                const SizedBox(width: 4),
                
                // Second dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                    delay: 200.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: 600.ms,
                  ),
                
                const SizedBox(width: 4),
                
                // Third dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                    delay: 400.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: 600.ms,
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Typing text
          Text(
            userName != null && userName!.isNotEmpty
                ? '$userName đang nhập tin nhắn...'
                : 'Đang nhập tin nhắn...',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().slideX(
      begin: -0.3,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    ).fadeIn(
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    );
  }
} 