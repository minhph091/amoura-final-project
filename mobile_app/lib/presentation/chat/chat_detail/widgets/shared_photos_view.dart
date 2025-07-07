import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class SharedPhotosView extends StatefulWidget {
  final List<SharedMedia> mediaItems;
  final Function(String messageId) onViewOriginalMessage;
  final Function(List<String> mediaIds) onDeleteMedia;

  const SharedPhotosView({
    super.key,
    required this.mediaItems,
    required this.onViewOriginalMessage,
    required this.onDeleteMedia,
  });

  @override
  State<SharedPhotosView> createState() => _SharedPhotosViewState();
}

class _SharedPhotosViewState extends State<SharedPhotosView> {
  final List<String> _selectedItems = [];
  bool _isSelectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll(List<String> ids) {
    setState(() {
      // Check if all ids are already selected
      bool allSelected = ids.every((id) => _selectedItems.contains(id));

      if (allSelected) {
        // Remove all ids from selection
        _selectedItems.removeWhere((id) => ids.contains(id));
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        // Add all ids to selection
        for (final id in ids) {
          if (!_selectedItems.contains(id)) {
            _selectedItems.add(id);
          }
        }
        _isSelectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group media items by date
    final groupedMedia = <String, List<SharedMedia>>{};
    for (final media in widget.mediaItems) {
      final dateKey = _getDateKey(media.timestamp);
      if (!groupedMedia.containsKey(dateKey)) {
        groupedMedia[dateKey] = [];
      }
      groupedMedia[dateKey]!.add(media);
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
          ? Text('Selected: ${_selectedItems.length}')
          : const Text('Shared Photos & Videos'),
        leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelSelection,
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
        actions: _isSelectionMode
          ? [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  widget.onDeleteMedia(_selectedItems);
                  setState(() {
                    _selectedItems.clear();
                    _isSelectionMode = false;
                  });
                },
              ),
            ]
          : null,
      ),
      body: groupedMedia.isEmpty
          ? const Center(child: Text('No shared photos or videos'))
          : ListView(
              children: groupedMedia.entries.map((entry) {
                final dateKey = entry.key;
                final mediaItems = entry.value;
                // Get all media IDs in this section
                final sectionIds = mediaItems.map((m) => m.id).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateKey,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          _buildSectionCheckbox(sectionIds),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: mediaItems.length,
                      itemBuilder: (context, index) {
                        return _buildMediaItem(mediaItems[index]);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
      bottomNavigationBar: _isSelectionMode
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.message),
                    label: const Text('View Original Message'),
                    onPressed: _selectedItems.length == 1
                        ? () {
                            final selectedMediaId = _selectedItems.first;
                            final mediaItem = widget.mediaItems.firstWhere(
                              (item) => item.id == selectedMediaId
                            );
                            widget.onViewOriginalMessage(mediaItem.messageId);
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: _selectedItems.isNotEmpty
                        ? () {
                            widget.onDeleteMedia(_selectedItems);
                            setState(() {
                              _selectedItems.clear();
                              _isSelectionMode = false;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildSectionCheckbox(List<String> sectionIds) {
    final bool allSelected = _selectedItems.toSet().containsAll(sectionIds);
    final bool someSelected = sectionIds.any((id) => _selectedItems.contains(id));

    return GestureDetector(
      onTap: () => _selectAll(sectionIds),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: allSelected || someSelected ? AppColors.primary : Colors.grey,
            width: 2,
          ),
          color: allSelected ? AppColors.primary : Colors.transparent,
        ),
        child: allSelected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : someSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
      ),
    );
  }

  Widget _buildMediaItem(SharedMedia media) {
    final bool isSelected = _selectedItems.contains(media.id);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(media.id);
        } else {
          // View the media in full screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _FullScreenMediaView(
                mediaUrl: media.url,
                messageId: media.messageId,
                timestamp: media.timestamp,
                onViewOriginalMessage: widget.onViewOriginalMessage,
              ),
            ),
          );
        }
      },
      onLongPress: () {
        _toggleSelection(media.id);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: media.type == MediaType.video
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        media.thumbnailUrl ?? media.url,
                        fit: BoxFit.cover,
                      ),
                      const Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 16,
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.network(
                    media.url,
                    fit: BoxFit.cover,
                  ),
          ),

          // Selection overlay
          if (_isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
        ],
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

class _FullScreenMediaView extends StatelessWidget {
  final String mediaUrl;
  final String messageId;
  final DateTime timestamp;
  final Function(String messageId) onViewOriginalMessage;

  const _FullScreenMediaView({
    required this.mediaUrl,
    required this.messageId,
    required this.timestamp,
    required this.onViewOriginalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              onViewOriginalMessage(messageId);
              Navigator.pop(context);
            },
            tooltip: 'View in chat',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            mediaUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black.withValues(alpha: 0.5),
        child: Text(
          _formatTimestamp(timestamp),
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class SharedMedia {
  final String id;
  final String messageId;
  final String url;
  final String? thumbnailUrl; // For videos
  final MediaType type;
  final DateTime timestamp;

  const SharedMedia({
    required this.id,
    required this.messageId,
    required this.url,
    this.thumbnailUrl,
    required this.type,
    required this.timestamp,
  });
}

enum MediaType {
  image,
  video
}
