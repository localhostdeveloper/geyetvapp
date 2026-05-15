import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:godseye_tv/services/epg_service.dart'; // Using the service file we discussed

class PlayerEpgList extends StatelessWidget {
  final String channelId;

  const PlayerEpgList({super.key, required this.channelId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: EpgService().fetchRemoteEpg(channelId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No program information available", 
              style: TextStyle(color: Colors.white70)),
          );
        }

        final schedule = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Parent handles scrolling
          itemCount: schedule.length,
          itemBuilder: (context, index) {
            final program = schedule[index];
            final bool isFirst = index == 0; // Usually the current/next show

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isFirst ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(program['start']),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (isFirst)
                      const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                title: Text(
                  program['title'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: Text(
                  program['desc'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}