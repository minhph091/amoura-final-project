import 'package:flutter/material.dart';
import 'chat_list_viewmodel.dart';
import 'widgets/chat_list_item.dart';
import 'widgets/active_users_list.dart';
import 'widgets/search_history_overlay.dart';
import '../../shared/widgets/search_input.dart';
import '../../shared/widgets/app_gradient_background.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatListViewModel _viewModel = ChatListViewModel();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchOverlay = false;

  @override
  void initState() {
    super.initState();
    _viewModel.loadChatList();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    setState(() {
      _showSearchOverlay = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchChanged() {
    // Immediately search as the user types
    _viewModel.searchChats(_searchController.text);

    // Only show the search overlay when focused and no search text
    if (_searchController.text.isEmpty && _searchFocusNode.hasFocus) {
      setState(() {
        _showSearchOverlay = true;
      });
    } else if (_searchController.text.isNotEmpty) {
      setState(() {
        _showSearchOverlay = false;
      });
    }
  }

  void _closeSearchOverlay() {
    // Clear focus and hide overlay
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchOverlay = false;
    });
  }

  void _submitSearch(String query) {
    _viewModel.searchChats(query);
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchOverlay = false;
    });
  }

  void _navigateToUserProfile(String userId) {
    Navigator.pushNamed(
      context,
      '/profile/view',
      arguments: userId,
    );
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Chats'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Full-width search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Show back button when search is focused
                  if (_showSearchOverlay)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeSearchOverlay,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 24,
                    ),

                  // Search input field
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _searchFocusNode.requestFocus();
                      },
                      child: SearchInput(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hintText: 'Search chats or users',
                        onClear: () {
                          _searchController.clear();
                          _viewModel.searchChats('');
                        },
                        onSubmitted: _submitSearch,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Show either search overlay or regular content
            Expanded(
              child: _showSearchOverlay
                ? SearchHistoryOverlay(
                    searchController: _searchController,
                    onSearchSubmit: _submitSearch,
                    onUserTap: _navigateToUserProfile,
                    onClose: _closeSearchOverlay, // Add this to enable closing
                  )
                : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Active users horizontal scrolling list
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ActiveUsersList(
            users: _viewModel.activeUsers,
            onUserTap: (userId) => _navigateToChat(context, userId),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Divider(),
        ),

        // Chat list
        Expanded(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              if (_viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_viewModel.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading chats',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _viewModel.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _viewModel.loadChatList,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (_viewModel.chatList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: _viewModel.chatList.length,
                itemBuilder: (context, index) {
                  final chat = _viewModel.chatList[index];
                  return ChatListItem(
                    chat: chat,
                    onTap: () => _navigateToChat(context, chat.userId),
                    onLongPress: () => _showChatOptions(context, chat),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Match with more people to start\nconversations and find your perfect match!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Discovery
              Navigator.of(context).pushReplacementNamed('/discovery');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore New Profiles'),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, String userId) {
    Navigator.pushNamed(
      context,
      '/chat/conversation',
      arguments: userId,
    );
  }

  void _showChatOptions(BuildContext context, ChatModel chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                chat.isUnread ? Icons.mark_email_read : Icons.mark_email_unread,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                chat.isUnread ? 'Mark as read' : 'Mark as unread',
              ),
              onTap: () {
                Navigator.pop(context);
                _viewModel.toggleReadStatus(chat.userId);
              },
            ),
            ListTile(
              leading: Icon(
                chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                chat.isPinned ? 'Unpin conversation' : 'Pin conversation',
              ),
              onTap: () {
                Navigator.pop(context);
                _viewModel.togglePinned(chat.userId);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications_off_outlined,
                color: Colors.orange,
              ),
              title: const Text('Mute notifications'),
              onTap: () {
                Navigator.pop(context);
                // Implement mute notifications
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.visibility_off_outlined,
                color: Colors.orange,
              ),
              title: const Text('Hide conversation'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.hideChat(chat.userId);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text('Delete conversation'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text(
          'This will delete all messages in this conversation for you. The other person will still see the conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteChat(chat.userId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
