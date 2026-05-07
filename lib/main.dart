import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_colors.dart';
import 'screens/main_dashboard.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// Load environment variables
await dotenv.load(fileName: ".env");

// Initialize Supabase
await Supabase.initialize(
url: dotenv.env['SUPABASE_URL'] ?? '',
anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
// Using a standard font for now until you add Google Fonts
fontFamily: 'Roboto',
),
home: MainDashboard(),
);
}
}