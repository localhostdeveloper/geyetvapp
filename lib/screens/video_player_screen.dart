import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../widgets/player_info_section.dart';
import '../widgets/player_channels_list.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String channelId; // Required for EPG
  final List<Map<String, dynamic>> allChannels;

  const VideoPlayerScreen({
    super.key, 
    required this.streamUrl, 
    required this.title, 
    required this.channelId, 
    required this.allChannels
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Keep screen on
    _initPlayer(widget.streamUrl);
  }

  Future<void> _initPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        isLive: true,
        aspectRatio: 16 / 9,
      );
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _chewieController != null 
                ? Chewie(controller: _chewieController!) 
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(tabs: [Tab(text: "INFO"), Tab(text: "CHANNELS")]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // FIXED: Passing channelId here
                        PlayerInfoSection(title: widget.title, channelId: widget.channelId),
                        PlayerChannelsList(
                          allChannels: widget.allChannels,
                          currentTitle: widget.title,
                          onChannelSelect: (c) {}, // Handle switch logic here
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}