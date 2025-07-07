import 'dart:async';
import 'package:flutter/material.dart';

// ViewModel for handling video/audio call functionality
class CallViewModel extends ChangeNotifier {

  // Call state
  bool _isCallConnected = false;
  bool _isCallInitialized = false;
  bool _isIncomingCall = false;
  DateTime? _callStartTime;
  Duration? _callDuration;
  Timer? _callDurationTimer;
  String _callStatusText = "Connecting...";

  // Media state
  bool _isAudioMuted = false;
  bool _isLocalVideoEnabled = true;
  bool _isRemoteVideoEnabled = false;
  bool _isSpeakerOn = true;

  // Video widgets
  Widget? _localVideoWidget;
  Widget? _remoteVideoWidget;

  // Getters for UI
  bool get isCallConnected => _isCallConnected;
  bool get isCallInitialized => _isCallInitialized;
  bool get isIncomingCall => _isIncomingCall;
  bool get isAudioMuted => _isAudioMuted;
  bool get isLocalVideoEnabled => _isLocalVideoEnabled;
  bool get isRemoteVideoEnabled => _isRemoteVideoEnabled;
  bool get isSpeakerOn => _isSpeakerOn;
  Duration? get callDuration => _callDuration;
  String get callStatusText => _callStatusText;
  Widget? get localVideoWidget => _localVideoWidget;
  Widget? get remoteVideoWidget => _remoteVideoWidget;

  // Formatted duration for display
  String get callDurationFormatted {
    if (_callDuration == null) return "";

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_callDuration!.inHours);
    final minutes = twoDigits(_callDuration!.inMinutes.remainder(60));
    final seconds = twoDigits(_callDuration!.inSeconds.remainder(60));

    return _callDuration!.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  // Initialize a new call
  void initializeCall({required String matchId, bool isVideoCall = true}) {
    _isLocalVideoEnabled = isVideoCall;

    _callStatusText = "Connecting...";
    notifyListeners();

    // TODO: Initialize actual video call service here
    // This is a mock implementation for demonstration

    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      _callStatusText = "Connecting to call service...";
      notifyListeners();

      // Simulate connection established
      Future.delayed(const Duration(seconds: 2), () {
        _isCallInitialized = true;
        _callStatusText = "Calling...";
        notifyListeners();

        // Simulate call pickup
        Future.delayed(const Duration(seconds: 3), () {
          _connectCall();
        });
      });
    });
  }

  // Simulate call connection established
  void _connectCall() {
    _isCallConnected = true;
    _callStartTime = DateTime.now();
    _callStatusText = "Connected";

    // Start timer for call duration
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        _callDuration = DateTime.now().difference(_callStartTime!);
        notifyListeners();
      }
    });

    // Simulate remote video if enabled
    if (_isLocalVideoEnabled) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isRemoteVideoEnabled = true;

        // Create mock video widgets for demo purposes
        // In a real app, these would be actual video feeds
        _setupMockVideoWidgets();

        notifyListeners();
      });
    }

    notifyListeners();
  }

  // Create mock video widgets for UI demonstration
  void _setupMockVideoWidgets() {
    // Local video mock
    _localVideoWidget = Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );

    // Remote video mock
    _remoteVideoWidget = Container(
      color: Colors.grey[900],
      child: Center(
        child: Icon(
          Icons.person,
          size: 120,
          color: Colors.grey[500],
        ),
      ),
    );

    notifyListeners();
  }

  // Toggle audio mute state
  void toggleAudio() {
    _isAudioMuted = !_isAudioMuted;
    // TODO: Implement actual mute functionality
    notifyListeners();
  }

  // Toggle video enabled state
  void toggleVideo() {
    _isLocalVideoEnabled = !_isLocalVideoEnabled;
    // TODO: Implement actual video toggle functionality
    notifyListeners();
  }

  // Toggle speaker mode
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    // TODO: Implement actual speaker mode functionality
    notifyListeners();
  }

  // Pause the call (when app goes to background)
  void pauseCall() {
    // TODO: Implement actual call pausing
    _callStatusText = "Paused";
    notifyListeners();
  }

  // Resume the call (when app comes to foreground)
  void resumeCall() {
    if (_isCallConnected) {
      _callStatusText = "Connected";
    } else {
      _callStatusText = "Connecting...";
    }
    // TODO: Implement actual call resuming
    notifyListeners();
  }

  // End the current call
  void endCall() {
    // Clean up resources
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
    _isCallConnected = false;
    _isCallInitialized = false;

    // TODO: Implement actual call ending with backend

    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources
    _callDurationTimer?.cancel();
    super.dispose();
  }
}
