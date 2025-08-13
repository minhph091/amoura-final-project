import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'call_viewmodel.dart';
import 'widgets/call_controls.dart';

class CallView extends StatefulWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final bool isVideoCall;

  const CallView({
    super.key,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
    this.isVideoCall = true,
  });

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> with WidgetsBindingObserver {
  late CallViewModel viewModel;
  bool isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock the screen in portrait mode for the call
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Enter full screen mode for the call
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<CallViewModel>(context);
    // Initialize the call when the dependencies are ready
    viewModel.initializeCall(
      matchId: widget.matchId,
      isVideoCall: widget.isVideoCall,
    );
  }

  @override
  void dispose() {
    // Restore normal screen orientation and UI when the call ends
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // The app is in the background, handle accordingly
      viewModel.pauseCall();
    } else if (state == AppLifecycleState.resumed) {
      // The app is in the foreground again
      viewModel.resumeCall();
    }
  }

  void _toggleControlsVisibility() {
    setState(() {
      isControlsVisible = !isControlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControlsVisibility,
        child: Stack(
          children: [
            // Remote user's video
            if (widget.isVideoCall)
              _buildRemoteVideoView()
            else
              _buildAudioCallBackground(),

            // Local user's video (small preview)
            if (widget.isVideoCall && viewModel.isLocalVideoEnabled)
              _buildLocalVideoPreview(),

            // Call status and information
            _buildCallInfo(),

            // Call controls at the bottom
            _buildCallControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideoView() {
    return Consumer<CallViewModel>(
      builder: (context, model, child) {
        if (model.isCallConnected && model.isRemoteVideoEnabled) {
          return Container(
            color: Colors.black,
            child: Center(
              child:
                  model.remoteVideoWidget ??
                  const Center(
                    child: Text(
                      "Connecting video...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            ),
          );
        } else {
          return _buildAudioCallBackground();
        }
      },
    );
  }

  Widget _buildAudioCallBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple,
            Colors.purple.withValues(alpha: 0.7),
            Colors.blue,
          ],
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 80,
          backgroundImage:
              widget.matchAvatar.isNotEmpty
                  ? NetworkImage(widget.matchAvatar) as ImageProvider
                  : const AssetImage(
                    'assets/images/avatars/default_avatar.png',
                  ),
        ),
      ),
    );
  }

  Widget _buildLocalVideoPreview() {
    return Consumer<CallViewModel>(
      builder: (context, model, child) {
        return Positioned(
          right: 16,
          top: 60,
          child: GestureDetector(
            onPanUpdate: (details) {
              // TODO: Implement dragging the local preview
            },
            child: Container(
              height: 160,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child:
                    model.localVideoWidget ??
                    const Center(
                      child: Text(
                        "Loading camera...",
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallInfo() {
    return Consumer<CallViewModel>(
      builder: (context, model, child) {
        return AnimatedOpacity(
          opacity: isControlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Text(
                    widget.matchName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.callStatusText,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  if (model.callDuration != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      model.callDurationFormatted,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallControls() {
    return Consumer<CallViewModel>(
      builder: (context, model, child) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          bottom: isControlsVisible ? 40 : -100,
          child: Center(
            child: CallControls(
              isMuted: model.isAudioMuted,
              isCameraOff: !model.isLocalVideoEnabled,
              isSpeakerOn: model.isSpeakerOn,
              onToggleMute: model.toggleAudio,
              onToggleCamera: model.toggleVideo,
              onToggleSpeaker: model.toggleSpeaker,
              onEndCall: () {
                model.endCall();
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
