import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme/app_colors.dart';
import '../widgets/player_info_section.dart';
import '../widgets/player_channels_list.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;
  final List<Map<String, dynamic>> allChannels;

  const VideoPlayerScreen({
    super.key,
    required this.streamUrl,
    required this.title,
    required this.allChannels,
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

    _enableWakelock();
    _initPlayer(widget.streamUrl);
  }

  Future<void> _enableWakelock() async {
    await WakelockPlus.enable();
  }

  Future<void> _disableWakelock() async {
    await WakelockPlus.disable();
  }

  Future<void> _initPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    try {
      await _videoController.initialize();

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          isLive: true,
          aspectRatio: 16 / 9,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
          ],
          placeholder: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint("Player Init Error: $e");
    }
  }

  void _switchChannel(Map<String, dynamic> channel) {
    _videoController.dispose();
    _chewieController?.dispose();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => VideoPlayerScreen(
          streamUrl: channel['stream_url'],
          title: channel['title'],
          allChannels: widget.allChannels,
        ),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _disableWakelock();

    _videoController.dispose();
    _chewieController?.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: isPortrait
          ? AppBar(
              backgroundColor: Colors.black,
              title: Text(widget.title),
            )
          : null,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  ),
          ),
          if (isPortrait)
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      indicatorColor: AppColors.primaryRed,
                      tabs: [
                        Tab(text: "EPG"),
                        Tab(text: "CHANNELS"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          PlayerInfoSection(
                            title: widget.title,
                          ),
                          PlayerChannelsList(
                            allChannels: widget.allChannels,
                            currentTitle: widget.title,
                            onChannelSelect: _switchChannel,
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