import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PlayerInfoSection extends StatelessWidget {
  final String title;

  const PlayerInfoSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RELAXED NOW SHOWING BANNER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: Colors.black.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NOW SHOWING",
                style: TextStyle(
                  color: AppColors.primaryRed, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        
        // RELAXED EPG LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            itemCount: 6,
            itemBuilder: (context, index) {
              bool isCurrent = index == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 32), // More space between items
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time with better spacing
                    SizedBox(
                      width: 50,
                      child: Text(
                        "${18 + index}:00", 
                        style: TextStyle(
                          color: isCurrent ? Colors.white : AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        )
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Program Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrent ? "Live: Global News Hour" : "Upcoming: Documentary Series",
                            style: TextStyle(
                              color: isCurrent ? AppColors.primaryRed : Colors.white,
                              fontSize: 16,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "A detailed look into the most important stories of the day, updated every hour.",
                            style: TextStyle(
                              color: AppColors.textGrey, 
                              fontSize: 13,
                              height: 1.5, // Better line height for readability
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}