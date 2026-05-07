import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PlayerChannelsList extends StatelessWidget {
  final List<Map<String, dynamic>> allChannels;
  final String currentTitle;
  final Function(Map<String, dynamic>) onChannelSelect;

  const PlayerChannelsList({
    super.key,
    required this.allChannels,
    required this.currentTitle,
    required this.onChannelSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: allChannels.length,
      itemBuilder: (context, index) {
        final channel = allChannels[index];
        bool isPlaying = channel['title'] == currentTitle;

        return TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: ColorTween(
            begin: Colors.transparent,
            end: isPlaying ? AppColors.primaryRed.withOpacity(0.15) : Colors.transparent,
          ),
          builder: (context, Color? bgColor, child) {
            return Container(
              color: bgColor,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                onTap: () => onChannelSelect(channel),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    channel['logo_url'] ?? '',
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 50, height: 50, color: Colors.white10,
                      child: const Icon(Icons.tv, color: Colors.white24),
                    ),
                  ),
                ),
                title: Text(
                  channel['title'] ?? 'Channel',
                  style: TextStyle(
                    color: isPlaying ? Colors.white : Colors.white70,
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  isPlaying ? "NOW PLAYING" : "Live Stream",
                  style: TextStyle(
                    color: isPlaying ? AppColors.primaryRed : AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1
                  ),
                ),
                trailing: isPlaying 
                  ? const Icon(Icons.graphic_eq, color: AppColors.primaryRed) // Visual indicator
                  : const Icon(Icons.chevron_right, color: Colors.white12),
              ),
            );
          },
        );
      },
    );
  }
}