import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/settings/blocked_user.dart';
import '../../../../infrastructure/services/blocking_service.dart';
import 'blocked_user_item.dart';

class BlockedUsersTab extends StatefulWidget {
  const BlockedUsersTab({super.key});

  @override
  State<BlockedUsersTab> createState() => _BlockedUsersTabState();
}

class _BlockedUsersTabState extends State<BlockedUsersTab> {
  final Set<String> _selectedUsers = <String>{};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final blockingService = Provider.of<BlockingService>(context);
    final blockedUsers = blockingService.blockedUsers;

    return Stack(
      children: [
        // Main content
        Column(
          children: [
            // Multi-selection controls
            if (_isSelectionMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).primaryColor.withAlpha(26), // replaced withOpacity(0.1)
                child: Row(
                  children: [
                    Text(
                      '${_selectedUsers.length} selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedUsers.clear();
                          _isSelectionMode = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await blockingService.unblockUsers(
                          _selectedUsers,
                        );
                        setState(() {
                          _selectedUsers.clear();
                          _isSelectionMode = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Unblock'),
                    ),
                  ],
                ),
              ),

            // Blocked users list
            Expanded(
              child: blockingService.isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : blockedUsers.isEmpty
                      ? const Center(child: Text('No blocked users'))
                      : buildBlockedUsersList(blockedUsers),
            ),
          ],
        ),

        // FAB for unblock all
        if (blockedUsers.isNotEmpty && !_isSelectionMode)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: showUnblockAllDialog,
              icon: const Icon(Icons.lock_open),
              label: const Text('Unblock all'),
            ),
          ),
      ],
    );
  }

  Widget buildBlockedUsersList(List<BlockedUser> users) {
    // Group users in rows of 2
    final int rowCount = (users.length / 2).ceil();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final int startIndex = rowIndex * 2;
        final int endIndex = startIndex + 1 < users.length ? startIndex + 1 : startIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First user in row
              Expanded(
                child: BlockedUserItem(
                  user: users[startIndex],
                  isSelected: _selectedUsers.contains(users[startIndex].id),
                  isSelectionMode: _isSelectionMode,
                  onTap: () => _handleUserTap(users[startIndex].id),
                  onLongPress: () => _handleLongPress(users[startIndex].id),
                  onUnblock: () => _handleUnblock(users[startIndex].id),
                  onViewDetails: () => _handleViewDetails(users[startIndex]),
                ),
              ),

              const SizedBox(width: 16),

              // Second user in row (if exists)
              if (endIndex > startIndex)
                Expanded(
                  child: BlockedUserItem(
                    user: users[endIndex],
                    isSelected: _selectedUsers.contains(users[endIndex].id),
                    isSelectionMode: _isSelectionMode,
                    onTap: () => _handleUserTap(users[endIndex].id),
                    onLongPress: () => _handleLongPress(users[endIndex].id),
                    onUnblock: () => _handleUnblock(users[endIndex].id),
                    onViewDetails: () => _handleViewDetails(users[endIndex]),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        );
      },
    );
  }

  void _handleUserTap(String userId) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedUsers.contains(userId)) {
          _selectedUsers.remove(userId);

          // If no more selected users, exit selection mode
          if (_selectedUsers.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedUsers.add(userId);
        }
      });
    }
  }

  void _handleLongPress(String userId) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedUsers.add(userId);
      });
    }
  }

  void _handleUnblock(String userId) async {
    final blockingService = Provider.of<BlockingService>(context, listen: false);
    await blockingService.unblockUser(userId);
  }

  void _handleViewDetails(BlockedUser user) {
    // Navigate to user details (would connect to profile view)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View details: ${user.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void showUnblockAllDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock All'),
        content: const Text('Are you sure you want to unblock all users?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final blockingService = Provider.of<BlockingService>(context, listen: false);
              final userIds = blockingService.blockedUsers.map((user) => user.id).toSet();
              blockingService.unblockUsers(userIds);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}
