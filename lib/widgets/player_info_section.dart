import 'package:flutter/material.dart';
import '../services/epg_service.dart';

class PlayerInfoSection extends StatefulWidget {
  final String title;
  final String channelId;
  const PlayerInfoSection({super.key, required this.title, required this.channelId});

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
    if (mounted) {
      setState(() {
        _schedule = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.red));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.05),
          child: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _schedule.length,
            itemBuilder: (context, i) {
              final item = _schedule[i];
              return ListTile(
                leading: Text(
                  "${item['start'].hour}:${item['start'].minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.grey),
                ),
                title: Text(item['title'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(item['desc'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              );
            },
          ),
        ),
      ],
    );
  }
}