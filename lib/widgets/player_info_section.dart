import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/epg_service.dart'; // Import your new service

class PlayerInfoSection extends StatefulWidget {
  final String title;
  final String channelId; // Add this to identify which channel's EPG to fetch

  const PlayerInfoSection({
    super.key, 
    required this.title, 
    required this.channelId
  });

  @override
  State<PlayerInfoSection> createState() => _PlayerInfoSectionState();
}

class _PlayerInfoSectionState extends State<PlayerInfoSection> {
  final EpgService _epgService = EpgService();
  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEpg();
  }

  Future<void> _loadEpg() async {
    final data = await _epgService.fetchRemoteEpg(widget.channelId);
    setState(() {
      _schedule = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
    }

    return Column(
      children: [
        _buildRealTimeBanner(_schedule),
        Expanded(child: _buildEpgList(_schedule)),
      ],
    );
  }

  Widget _buildRealTimeBanner(List<Map<String, dynamic>> schedule) {
    final now = DateTime.now();
    // Find the current program
    final currentProgram = schedule.firstWhere(
      (prog) => now.isAfter(prog['start']) && now.isBefore(prog['end']),
      orElse: () => {'title': widget.title}, // Fallback to channel name
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.black.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NOW SHOWING",
            style: TextStyle(color: AppColors.primaryRed, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            currentProgram['title'],
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEpgList(List<Map<String, dynamic>> schedule) {
    if (schedule.isEmpty) {
      return const Center(child: Text("No schedule available", style: TextStyle(color: AppColors.textGrey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final item = schedule[index];
        final now = DateTime.now();
        bool isCurrent = now.isAfter(item['start']) && now.isBefore(item['end']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${item['start'].hour.toString().padLeft(2, '0')}:${item['start'].minute.toString().padLeft(2, '0')}", 
                style: TextStyle(color: isCurrent ? Colors.white : AppColors.textGrey, fontSize: 14)
              ),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: TextStyle(
                        color: isCurrent ? AppColors.primaryRed : Colors.white,
                        fontSize: 16,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['desc'] ?? '',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}