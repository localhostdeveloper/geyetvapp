import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme/app_colors.dart';
import '../widgets/player_channels_list.dart';
import '../widgets/player_info_section.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String channelId;
  final List<Map<String, dynamic>> allChannels;

  const VideoPlayerScreen({
    super.key,
    required this.streamUrl,
    required this.title,
    required this.channelId,
    required this.allChannels,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  static const _pipChannel = MethodChannel('godseye.tv/pip');
  bool _isInPipMode = false;

  @override
  void initState() {
    super.initState();
    _initPlayer(widget.streamUrl);
    _listenForPipMode();
  }

  // =========================
  // PIP LISTENER (Android only)
  // =========================
  void _listenForPipMode() {
    _pipChannel.setMethodCallHandler((call) async {
      if (call.method == 'pipModeChanged') {
        if (mounted) {
          setState(() {
            _isInPipMode = call.arguments as bool;
          });
        }
      }
    });
  }

  // =========================
  // WAKELOCK
  // =========================
  Future<void> _enableWakelock() async {
    await WakelockPlus.enable();
  }

  Future<void> _disableWakelock() async {
    await WakelockPlus.disable();
  }

  // =========================
  // PLAYER INIT
  // =========================
  Future<void> _initPlayer(String url) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        isLive: true,
        allowFullScreen: true,
        allowMuting: true,
        aspectRatio: 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryRed,
          handleColor: AppColors.primaryRed,
          bufferedColor: Colors.grey,
          backgroundColor: Colors.black26,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          ),
        ),
      );

      if (mounted) {
        await _enableWakelock();
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('PLAYER ERROR: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // =========================
  // SWITCH CHANNEL
  // =========================
  void _switchChannel(Map<String, dynamic> channel) {
    _videoController.dispose();
    _chewieController?.dispose();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoPlayerScreen(
          streamUrl: channel['stream_url'],
          title: channel['title'],
          channelId: channel['id'].toString(),
          allChannels: widget.allChannels,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disableWakelock();
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // VIDEO PLAYER
            // =====================
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryRed))
                    : _hasError
                        ? const Center(
                            child: Text('Failed to load stream',
                                style: TextStyle(color: Colors.white)))
                        : Chewie(controller: _chewieController!),
              ),
            ),

            // =====================
            // TABS SECTION (EPG & CHANNELS)
            // =====================
            if (!_isInPipMode)
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: AppColors.primaryRed,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'EPG'),
                          Tab(text: 'CHANNELS'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            PlayerInfoSection(
                              title: widget.title,
                              channelId: widget.channelId,
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
      ),
    );
  }
}