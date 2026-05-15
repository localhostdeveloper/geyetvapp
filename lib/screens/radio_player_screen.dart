import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../services/audio_handler.dart';

class RadioPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String stationId;
  final String logoUrl;
  final String description;
  final List<Map<String, dynamic>> allStations;

  const RadioPlayerScreen({
    super.key,
    required this.streamUrl,
    required this.title,
    required this.stationId,
    required this.logoUrl,
    required this.description,
    required this.allStations,
  });

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  late int _currentIndex;
  late RadioAudioHandler _handler;

  @override
  void initState() {
    super.initState();
    _handler = audioHandler as RadioAudioHandler;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _currentIndex = widget.allStations
        .indexWhere((s) => s['id'].toString() == widget.stationId);
    if (_currentIndex == -1) _currentIndex = 0;

    _initPlayer(widget.streamUrl);

    // Listen to playback state
    _handler.playbackState.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
        if (state.playing) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      }
    });
  }

  Future<void> _initPlayer(String url) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final mediaItem = MediaItem(
        id: url,
        title: widget.title,
        artist: widget.description.isNotEmpty ? widget.description : 'Live Radio',
        artUri: widget.logoUrl.isNotEmpty ? Uri.parse(widget.logoUrl) : null,
      );

      await _handler.playStation(url, mediaItem);
      await WakelockPlus.enable();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('RADIO ERROR: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _handler.pause();
    } else {
      _handler.play();
    }
  }

  void _switchStation(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.allStations.length) return;
    final station = widget.allStations[newIndex];

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            RadioPlayerScreen(
          streamUrl: station['stream_url'] ?? '',
          title: station['title'] ?? 'Unknown',
          stationId: station['id'].toString(),
          logoUrl: station['logo_url'] ?? '',
          description: station['description'] ?? '',
          allStations: widget.allStations,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDescription = widget.description.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title,
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),

          // =====================
          // STATION LOGO
          // =====================
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _isPlaying
                      ? [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(
                                0.3 + 0.2 * _animationController.value),
                            blurRadius:
                                30 + 20 * _animationController.value,
                            spreadRadius: 5,
                          )
                        ]
                      : [],
                ),
                child: ClipOval(
                  child: widget.logoUrl.isNotEmpty
                      ? Image.network(
                          widget.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: AppColors.surfaceDark,
                            child: const Icon(Icons.radio,
                                color: AppColors.primaryRed, size: 80),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceDark,
                          child: const Icon(Icons.radio,
                              color: AppColors.primaryRed, size: 80),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // =====================
          // STATION NAME
          // =====================
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

  // =====================
// WAVEFORM VISUALIZER
// =====================
if (_isPlaying)
  AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          // Alternate bars go in opposite directions
          final double phase = index % 2 == 0
              ? _animationController.value
              : 1 - _animationController.value;
          // Each bar has a different height range based on its index
          final double height = 8 + 30 * (0.3 + 0.7 * 
              ((phase + index * 0.15) % 1.0));
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      );
    },
  )
else
  const SizedBox(height: 40),

          const Spacer(),

          // =====================
          // CONTROLS
          // =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () => _switchStation(_currentIndex - 1),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _isLoading ? null : _togglePlayPause,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : _hasError
                          ? const Icon(Icons.refresh,
                              color: Colors.white, size: 35)
                          : Icon(
                              _isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () => _switchStation(_currentIndex + 1),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =====================
          // NOW PLAYING + DESCRIPTION
          // =====================
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // NOW PLAYING
                Row(
                  children: const [
                    Icon(Icons.graphic_eq,
                        color: AppColors.primaryRed, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Now Playing",
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // DESCRIPTION
                if (hasDescription) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 4),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.description,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}