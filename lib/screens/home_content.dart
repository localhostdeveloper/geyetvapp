import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tv_section_screen.dart'; // Import the TV screen
import 'radio_section_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // Helper method for navigation to keep code clean
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          _buildHeader(),
          const SizedBox(height: 20),
          _buildHeroCard(context), // Added context for the button
          const SizedBox(height: 25),
          _buildSectionHeader("Explore Categories"),
          const SizedBox(height: 15),
          _buildCategoryGrid(context), // Added context for tiles
          const SizedBox(height: 15),
          _buildSocialMediaTile(context), // Added context for tile
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Logic for side menu (Screen 13) goes here later
              },
            ),
            const SizedBox(width: 5),
            Text(
              "GODSEYE TV",
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('assets/images/homecam.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            begin: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("LIVE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const Text(
              "Watch Live TV",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text("24/7 Entertainment", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
              onPressed: () => _navigateTo(context, const TvSectionScreen()),
              child: const Text("Watch Now", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        TextButton(
          onPressed: () {},
          child: const Text("View All", style: TextStyle(color: AppColors.primaryRed)),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _categoryTile(context, "TV", Icons.tv, const TvSectionScreen()),
        _categoryTile(context, "RADIO", Icons.radio, const RadioSectionScreen()),
        _categoryTile(context, "WEBSITE", Icons.web, null),
        _categoryTile(context, "PODCAST", Icons.podcasts, null),
      ],
    );
  }

  Widget _categoryTile(BuildContext context, String title, IconData icon, Widget? destination) {
    return InkWell(
      onTap: () {
        if (destination != null) {
          _navigateTo(context, destination);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title Section coming soon!")),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryRed),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaTile(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A4A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: const [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 15),
            Text("SOCIAL MEDIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}




