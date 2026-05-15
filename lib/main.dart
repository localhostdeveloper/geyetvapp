import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'theme/app_colors.dart';
import 'screens/main_dashboard.dart';
import 'services/audio_handler.dart';

late AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize audio service
  audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'godseye.tv.radio',
      androidNotificationChannelName: 'Godseye Radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFFE50914),
    ),
  );

  runApp(const GodsEyeApp());
}

class GodsEyeApp extends StatelessWidget {
  const GodsEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Godseye TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: AppColors.backgroundBlack,
        fontFamily: 'Roboto',
      ),
      home: const MainDashboard(),
    );
  }
}