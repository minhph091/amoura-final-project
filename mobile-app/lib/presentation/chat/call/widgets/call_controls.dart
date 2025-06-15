import 'package:flutter/material.dart';

// Widget that displays call control buttons (mute, end call, switch camera)
class CallControls extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final Function() onToggleMute;
  final Function() onToggleCamera;
  final Function() onToggleSpeaker;
  final Function() onEndCall;

  const CallControls({
    Key? key,
    required this.isMuted,
    required this.isCameraOff,
    required this.isSpeakerOn,
    required this.onToggleMute,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: isMuted ? 'Unmute' : 'Mute',
            onPressed: onToggleMute,
            backgroundColor: isMuted ? Colors.red : Colors.white54,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            onPressed: onEndCall,
            backgroundColor: Colors.red,
            iconColor: Colors.white,
          ),
          _buildControlButton(
            icon: isCameraOff ? Icons.videocam_off : Icons.videocam,
            label: isCameraOff ? 'Camera On' : 'Camera Off',
            onPressed: onToggleCamera,
            backgroundColor: isCameraOff ? Colors.red : Colors.white54,
          ),
          _buildControlButton(
            icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: isSpeakerOn ? 'Speaker' : 'Speaker',
            onPressed: onToggleSpeaker,
            backgroundColor: isSpeakerOn ? Colors.blue : Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Function() onPressed,
    Color backgroundColor = Colors.white54,
    Color iconColor = Colors.white,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

// A simplified version of call controls for a more compact UI
class CompactCallControls extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOff;
  final Function() onToggleMute;
  final Function() onToggleCamera;
  final Function() onEndCall;

  const CompactCallControls({
    Key? key,
    required this.isMuted,
    required this.isCameraOff,
    required this.onToggleMute,
    required this.onToggleCamera,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            onPressed: onToggleMute,
            color: isMuted ? Colors.red : Colors.white,
          ),
          const SizedBox(width: 16),
          _buildIconButton(
            icon: Icons.call_end,
            onPressed: onEndCall,
            color: Colors.red,
          ),
          const SizedBox(width: 16),
          _buildIconButton(
            icon: isCameraOff ? Icons.videocam_off : Icons.videocam,
            onPressed: onToggleCamera,
            color: isCameraOff ? Colors.red : Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Function() onPressed,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      iconSize: 24,
    );
  }
}
