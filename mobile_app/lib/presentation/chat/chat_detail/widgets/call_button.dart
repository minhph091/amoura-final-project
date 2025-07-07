import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../call/call_viewmodel.dart';
import '../../call/call_view.dart';

// A button widget that initiates a call (video or audio) to a match
class CallButton extends StatelessWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final bool isVideoCall;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const CallButton({
    Key? key,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
    this.isVideoCall = true,
    this.size = 50.0,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _initiateCall(context),
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? (isVideoCall
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.secondary),
        ),
        child: Center(
          child: Icon(
            isVideoCall ? Icons.videocam : Icons.call,
            color: iconColor ?? Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  // Initiate a call to the match
  void _initiateCall(BuildContext context) {
    // Check if the user has an active subscription for calls
    // You might want to add this check in a real app

    // Show confirmation dialog before starting the call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Call ${isVideoCall ? 'Video' : 'Audio'} with $matchName?"),
        content: Text(
          "You are about to start a ${isVideoCall ? 'video' : 'voice'} call with $matchName.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _startCall(context);
            },
            child: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  // Start the actual call
  void _startCall(BuildContext context) {
    // Create a new instance of CallViewModel for this specific call
    final callViewModel = CallViewModel();

    // Navigate to call screen with provider
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: callViewModel,
          child: CallView(
            matchId: matchId,
            matchName: matchName,
            matchAvatar: matchAvatar,
            isVideoCall: isVideoCall,
          ),
        ),
      ),
    );
  }
}

// A compact version with both video and audio call options
class CallOptions extends StatelessWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final double buttonSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const CallOptions({
    Key? key,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
    this.buttonSize = 40.0,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Video call button
        CallButton(
          matchId: matchId,
          matchName: matchName,
          matchAvatar: matchAvatar,
          isVideoCall: true,
          size: buttonSize,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
        const SizedBox(width: 12),
        // Audio call button
        CallButton(
          matchId: matchId,
          matchName: matchName,
          matchAvatar: matchAvatar,
          isVideoCall: false,
          size: buttonSize,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      ],
    );
  }
}
