// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';
import 'chat_list_viewmodel.dart';
import 'widgets/chat_list_item.dart';
import 'widgets/active_users_list.dart';
import '../../shared/widgets/search_input.dart';
import '../../shared/widgets/app_gradient_background.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/url_transformer.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatListViewModel _viewModel = ChatListViewModel();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel.loadChatList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Immediately search as the user types
    _viewModel.searchChats(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizations.translate('chats')),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SearchInput(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: localizations.translate('search_conversations'),
                onClear: () {
                  _searchController.clear();
                  _viewModel.searchChats('');
                },
                onSubmitted: (query) {
                  _viewModel.searchChats(query);
                  _searchFocusNode.unfocus();
                },
              ),
            ),

            // Main content
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Matched users horizontal scrolling list (real API data)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ActiveUsersList(
            users: _viewModel.matches,
            onUserTap: (userId) {
              // Tìm chat tương ứng với matched user này (nếu có)
              try {
                final userChat = _viewModel.chatList.firstWhere(
                  (c) => c.userId == userId,
                );
                _navigateToChat(context, userChat.chatRoomId, userChat);
              } catch (e) {
                debugPrint('No chat found for user $userId');
              }
            },
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
              final localizations = AppLocalizations.of(context);

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
                        localizations.translate('error_loading_chats'),
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
                        label: Text(localizations.translate('retry')),
                      ),
                    ],
                  ),
                );
              }

              if (_viewModel.chatList.isEmpty) {
                return _buildEmptyState(localizations);
              }

              return ListView.builder(
                itemCount: _viewModel.chatList.length,
                itemBuilder: (context, index) {
                  final chat = _viewModel.chatList[index];
                  return ChatListItem(
                    chat: chat,
                    onTap:
                        () => _navigateToChat(context, chat.chatRoomId, chat),
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

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.translate('no_messages_yet'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('start_conversation'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Discovery
              Navigator.of(context).pushReplacementNamed('/discovery');
            },
            icon: const Icon(Icons.explore),
            label: Text(localizations.translate('explore')),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(
    BuildContext context,
    String chatRoomId,
    ChatModel chat,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.chatConversation,
      arguments: {
        'chatId': chatRoomId,
        'recipientName': chat.name, // Đúng tên đối phương
        'recipientAvatar': chat.avatar, // Đúng avatar đối phương
        'isOnline': chat.isOnline,
      },
    );
  }

  void _showChatOptions(BuildContext context, ChatModel chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    chat.isUnread
                        ? Icons.mark_email_read
                        : Icons.mark_email_unread,
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
                  title: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('mute_notifications'),
                  ),
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
                  title: Text(
                    AppLocalizations.of(context).translate('hide_conversation'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _viewModel.hideChat(chat.userId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('delete_conversation'),
                  ),
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
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(
                context,
              ).translate('delete_conversation_question'),
            ),
            content: Text(
              AppLocalizations.of(context).translate('message_deleted_for_you'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _viewModel.deleteChat(chat.userId);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
