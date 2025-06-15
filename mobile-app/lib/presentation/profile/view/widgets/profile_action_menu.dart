import 'package:flutter/material.dart';

class ProfileActionMenu extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback? onUnblock;
  final bool isBlocked;

  const ProfileActionMenu({
    Key? key,
    required this.onReport,
    required this.onBlock,
    this.onUnblock,
    this.isBlocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Report option
          ListTile(
            leading: Icon(
              Icons.flag_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Report Profile',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: onReport,
          ),

          // Block/Unblock option
          if (isBlocked && onUnblock != null)
            ListTile(
              leading: const Icon(
                Icons.block_outlined,
                color: Colors.blue,
              ),
              title: const Text(
                'Unblock Profile',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: onUnblock,
            )
          else
            ListTile(
              leading: const Icon(
                Icons.block_outlined,
                color: Colors.red,
              ),
              title: const Text(
                'Block Profile',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: onBlock,
            ),

          // Cancel option
          ListTile(
            leading: Icon(
              Icons.close,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            title: const Text('Cancel'),
            onTap: () => Navigator.of(context).pop(),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
