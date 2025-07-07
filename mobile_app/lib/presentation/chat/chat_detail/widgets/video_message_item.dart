import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoMessageItem extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final Duration? duration;
  final String? fileSize;
  final bool isMe;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const VideoMessageItem({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.fileSize,
    required this.isMe,
    this.onLongPress,
    this.onDoubleTap,
  }) : super(key: key);

  @override
  State<VideoMessageItem> createState() => _VideoMessageItemState();
}

class _VideoMessageItemState extends State<VideoMessageItem>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onVideoTap() async {
    HapticFeedback.lightImpact();
    _pressController.forward().then((_) => _pressController.reverse());
    
    setState(() {
      _isLoading = true;
    });

    // Simulate video loading/opening
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    // TODO: Implement actual video player navigation
    _showVideoPlayer();
  }

  void _showVideoPlayer() {
    // For now, just show a dialog indicating video would play
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text('Video URL: ${widget.videoUrl}'),
            if (widget.duration != null)
              Text('Duration: ${_formatDuration(widget.duration!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onVideoTap,
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_pressController.value * 0.05),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              width: 250,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video thumbnail
                    _buildThumbnail(),
                    
                    // Dark overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(102),
                          ],
                        ),
                      ),
                    ),
                    
                    // Play button overlay
                    Center(
                      child: _buildPlayButton(),
                    ),
                    
                    // Duration and file size overlay
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: _buildVideoInfo(),
                    ),
                    
                    // Download/status indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusIndicator(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail() {
    if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
      return Image.network(
        widget.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderThumbnail();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderThumbnail();
        },
      );
    }
    return _buildPlaceholderThumbnail();
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      color: widget.isMe
          ? Theme.of(context).colorScheme.primary.withAlpha(51)
          : Theme.of(context).colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.videocam,
          size: 48,
          color: widget.isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withAlpha(153),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(153),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
    );
  }

  Widget _buildVideoInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Duration
        if (widget.duration != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDuration(widget.duration!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        // File size
        if (widget.fileSize != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.fileSize!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(153),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.download_done,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
} 