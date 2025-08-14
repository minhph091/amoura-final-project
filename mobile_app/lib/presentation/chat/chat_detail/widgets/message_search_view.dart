import 'package:flutter/material.dart';
import '../../../../domain/models/message.dart';
import 'package:intl/intl.dart';

class MessageSearchView extends StatefulWidget {
  final List<Message> messages;
  final Function(String messageId) onMessageSelected;

  const MessageSearchView({
    super.key,
    required this.messages,
    required this.onMessageSelected,
  });

  @override
  State<MessageSearchView> createState() => _MessageSearchViewState();
}

class _MessageSearchViewState extends State<MessageSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Message> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = widget.messages
            .where((msg) => msg.content.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 16),
          autofocus: true,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isSearching) {
      return const Center(
        child: Text('Enter text to search messages'),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No messages found for "${_searchController.text}"',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Group search results by date
    final groupedResults = <String, List<Message>>{};
    for (final message in _searchResults) {
      final dateKey = _getDateKey(message.timestamp);
      if (!groupedResults.containsKey(dateKey)) {
        groupedResults[dateKey] = [];
      }
      groupedResults[dateKey]!.add(message);
    }

    return ListView(
      children: groupedResults.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            ...entry.value.map((message) => _buildSearchResultItem(message)),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSearchResultItem(Message message) {
    final query = _searchController.text.trim();
    final content = message.content;

    // Highlight the search query in the message
    final List<TextSpan> textSpans = [];

    if (content.isNotEmpty) {
      int startIndex = 0;
      int searchIndex;

      // Function to add regions of text with and without highlighting
      void addSpans(String text, int start, int end, bool highlight) {
        final span = TextSpan(
          text: text.substring(start, end),
          style: highlight
              ? const TextStyle(
                  backgroundColor: Colors.yellow,
                  fontWeight: FontWeight.bold,
                )
              : null,
        );
        textSpans.add(span);
      }

      // Find all occurrences of the query and create appropriate TextSpans
      String lowerContent = content.toLowerCase();
      String lowerQuery = query.toLowerCase();

      while ((searchIndex = lowerContent.indexOf(lowerQuery, startIndex)) >= 0) {
        // Add non-highlighted text before match
        addSpans(content, startIndex, searchIndex, false);

        // Add highlighted text for match
        addSpans(content, searchIndex, searchIndex + query.length, true);

        // Update start index for next search
        startIndex = searchIndex + query.length;
      }

      // Add any remaining text after the last match
      if (startIndex < content.length) {
        addSpans(content, startIndex, content.length, false);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onMessageSelected(message.id);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender avatar
              CircleAvatar(
                radius: 18,
                backgroundImage: message.senderAvatar != null && message.senderAvatar!.isNotEmpty
                    ? NetworkImage(message.senderAvatar!) as ImageProvider
                    : const AssetImage('assets/images/avatars/default_avatar.png'),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name and timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          message.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat.jm().format(message.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message content with highlighted search term
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                        children: textSpans,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateKey(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
