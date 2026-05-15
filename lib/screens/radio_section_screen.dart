import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import 'radio_player_screen.dart';

class RadioSectionScreen extends StatefulWidget {
  const RadioSectionScreen({super.key});

  @override
  State<RadioSectionScreen> createState() => _RadioSectionScreenState();
}

class _RadioSectionScreenState extends State<RadioSectionScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: const Text("Radio", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getContentByCategory('29f2c0bf-2b5b-40c2-853e-996222b98fde'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No stations found.", style: TextStyle(color: Colors.white54)),
            );
          }

          final stations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              return _buildStationTile(stations[index], stations);
            },
          );
        },
      ),
    );
  }

  Widget _buildStationTile(
      Map<String, dynamic> station, List<Map<String, dynamic>> allStations) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RadioPlayerScreen(
              streamUrl: station['stream_url'] ?? '',
              title: station['title'] ?? 'Unknown',
              stationId: station['id'].toString(),
              logoUrl: station['logo_url'] ?? '',
              description: station['description'] ?? '',
              allStations: allStations,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // STATION LOGO
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: station['logo_url'] != null
                  ? Image.network(
                      station['logo_url'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.white10,
                        child: const Icon(Icons.radio, color: AppColors.primaryRed),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.white10,
                      child: const Icon(Icons.radio, color: AppColors.primaryRed),
                    ),
            ),
            const SizedBox(width: 15),

            // STATION INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station['title'] ?? 'Unknown Station',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station['description'] ?? 'Live Radio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // PLAY ICON
            const Icon(Icons.play_circle_outline, color: AppColors.primaryRed, size: 32),
          ],
        ),
      ),
    );
  }
}