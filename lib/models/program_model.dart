import 'package:intl/intl.dart';

class Program {
  final String channelId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  Program({
    required this.channelId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  // Helper to format time (e.g., "14:30 - 15:00")
  String get timeRange {
    final formatter = DateFormat('HH:mm');
    return "${formatter.format(startTime)} - ${formatter.format(endTime)}";
  }

  // Calculate progress for the 'Live' indicator bar
  double get progress {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return 1.0;
    if (now.isBefore(startTime)) return 0.0;
    
    final totalDuration = endTime.difference(startTime).inSeconds;
    final elapsed = now.difference(startTime).inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  // Check if program is currently airing
  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}