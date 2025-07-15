import 'package:flutter/material.dart';
import '../../../../config/language/app_localizations.dart';
import '../../../shared/widgets/user_avatar.dart';

class SearchHistoryOverlay extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchSubmit;
  final Function(String) onUserTap;
  final VoidCallback onClose; // Add close callback

  const SearchHistoryOverlay({
    super.key,
    required this.searchController,
    required this.onSearchSubmit,
    required this.onUserTap,
    required this.onClose, // Make the close callback required
  });

  @override
  State<SearchHistoryOverlay> createState() => _SearchHistoryOverlayState();
}

class _SearchHistoryOverlayState extends State<SearchHistoryOverlay> {
  // Mock data for recent searches
  final List<String> _recentSearches = [
    'Emma Watson',
    'dating',
    'New York',
    'coffee lover',
    'traveler',
    'yoga',
    'photography',
  ];

  // Mock data for recently viewed users
  final List<RecentUser> _recentUsers = [
    RecentUser(
      id: '1',
      name: 'Emma',
      avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    RecentUser(
      id: '2',
      name: 'Chris',
      avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentUser(
      id: '3',
      name: 'Sofia',
      avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
      isOnline: true,
      lastSeen: DateTime.now(),
    ),
    RecentUser(
      id: '4',
      name: 'James',
      avatar: 'https://randomuser.me/api/portraits/men/2.jpg',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentUser(
      id: '5',
      name: 'Olivia',
      avatar: 'https://randomuser.me/api/portraits/women/3.jpg',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  void _removeSearchTerm(String term) {
    setState(() {
      _recentSearches.remove(term);
    });
  }

  void _removeRecentUser(String userId) {
    setState(() {
      _recentUsers.removeWhere((user) => user.id == userId);
    });
  }

  void _clearAllSearchHistory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear search history?'),
            content: const Text(
              'This will delete all your search history. Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Delete all'),
              ),
            ],
          ),
    );
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes minutes ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours hours ago';
    } else {
      final days = difference.inDays;
      return '$days days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent search terms section
              _buildSectionHeader(
                'Recent Searches',
                _recentSearches.isNotEmpty ? 'View more' : null,
                () {
                  // Handle view more action
                },
              ),
              _recentSearches.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No search history',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  )
                  : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        _recentSearches
                            .take(6)
                            .map((term) => _buildSearchTermChip(term))
                            .toList(),
                  ),
              const SizedBox(height: 24),

              // Recently viewed users section
              _buildSectionHeader(
                'Recently Viewed Users',
                _recentUsers.isNotEmpty ? 'View more' : null,
                () {
                  // Handle view more action
                },
              ),
              const SizedBox(height: 8),
              _recentUsers.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No recently viewed users',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  )
                  : SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentUsers.length,
                      itemBuilder: (context, index) {
                        final user = _recentUsers[index];
                        return _buildRecentUserItem(user);
                      },
                    ),
                  ),
              const SizedBox(height: 24),

              // Nearby users section
              _buildSectionHeader('Nearby Users', 'View more', () {
                // Handle view more action
              }),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    // Using the same data as recent users for this example
                    final user = _recentUsers[index % _recentUsers.length];
                    return _buildNearbyUserItem(user);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Clear all button
              if (_recentSearches.isNotEmpty)
                Center(
                  child: TextButton.icon(
                    onPressed: _clearAllSearchHistory,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear all search history'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String? actionText,
    VoidCallback? onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (actionText != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionText)),
      ],
    );
  }

  Widget _buildSearchTermChip(String term) {
    return InputChip(
      label: Text(term),
      onDeleted: () => _removeSearchTerm(term),
      onPressed: () {
        widget.searchController.text = term;
        widget.onSearchSubmit(term);
      },
      deleteIconColor: Colors.grey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildRecentUserItem(RecentUser user) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => widget.onUserTap(user.id),
                child: UserAvatar(
                  imageUrl: user.avatar,
                  radius: 30,
                  showFrame: user.isOnline,
                  frameColor: user.isOnline ? Colors.green : null,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeRecentUser(user.id),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user.isOnline ? 'Active now' : _getLastSeenText(user.lastSeen),
            style: TextStyle(
              fontSize: 10,
              color: user.isOnline ? Colors.green : Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyUserItem(RecentUser user) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => widget.onUserTap(user.id),
            child: UserAvatar(
              imageUrl: user.avatar,
              radius: 30,
              showFrame: user.isOnline,
              frameColor: user.isOnline ? Colors.green : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user.isOnline ? 'Active now' : '${(1 + user.id.length) * 0.3} km',
            style: TextStyle(
              fontSize: 10,
              color: user.isOnline ? Colors.green : Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RecentUser {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final DateTime lastSeen;

  RecentUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isOnline,
    required this.lastSeen,
  });
}
