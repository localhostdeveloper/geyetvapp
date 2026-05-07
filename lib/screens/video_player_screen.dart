import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;

  const VideoPlayerScreen({super.key, required this.streamUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Keep screen on
    
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
      ),
    );
  }

  @override
  void dispose() {
    // 1. Disable WakeLock
    WakelockPlus.disable();
    
    // 2. FORCE Portrait Mode on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // 3. Show System UI bars again
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Using WillPopScope (or PopScope in newer Flutter) to catch the back button
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          // This ensures that even if they use the hardware back button, 
          // we force portrait mode.
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        },
        child: FlickVideoPlayer(
          flickManager: flickManager,
          preferredDeviceOrientationFullscreen: const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          // This makes the player handle the UI overlay for you
          systemUIOverlay: [], 
          flickVideoWithControls: const FlickVideoWithControls(
            controls: FlickPortraitControls(),
            videoFit: BoxFit.contain,
          ),
          flickVideoWithControlsFullscreen: const FlickVideoWithControls(
            controls: FlickLandscapeControls(),
            videoFit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}