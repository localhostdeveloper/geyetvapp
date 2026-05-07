import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import 'video_player_screen.dart'; // Ensure this import exists

class TvSectionScreen extends StatefulWidget {
  const TvSectionScreen({super.key});

  @override
  State<TvSectionScreen> createState() => _TvSectionScreenState();
}

class _TvSectionScreenState extends State<TvSectionScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: const Text("Live TV", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _supabaseService.getContentByCategory('1d401013-085c-4a29-aa37-b433e7c96879'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No channels found.", 
                      style: TextStyle(color: Colors.white54)
                    )
                  );
                }

                final channels = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    return _buildChannelTile(channels[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    List<String> filters = ["All", "News", "Sports", "Entertainment"];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              backgroundColor: index == 0 ? AppColors.primaryRed : AppColors.surfaceDark,
              side: BorderSide.none,
              label: Text(filters[index], style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelTile(Map<String, dynamic> channel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              streamUrl: channel['stream_url'],
              title: channel['title'],
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: channel['logo_url'] != null 
                ? Image.network(
                    channel['logo_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.tv, color: Colors.white24),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.white10,
                    child: const Icon(Icons.tv, color: AppColors.primaryRed),
                  ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel['title'] ?? 'Unknown Channel',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel['description'] ?? 'Live Stream',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (channel['is_live'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "LIVE", 
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ),
          ],
        ),
      ),
    );
  }
}