import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class RadioAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  RadioAudioHandler() {
    // Forward player state to audio_service
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // Transform just_audio state to audio_service state
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // Called when a new station is loaded
  Future<void> playStation(String url, MediaItem item) async {
    mediaItem.add(item);
    await _player.setUrl(url);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    // Handled in the screen via onChannelSelect
  }

  @override
  Future<void> skipToPrevious() async {
    // Handled in the screen via onChannelSelect
  }

  AudioPlayer get player => _player;
}