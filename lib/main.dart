import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await NotificationService.initialize();
  AdService.loadInterstitialAd();

  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('show_onboarding') ?? true;

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mehndi Designs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE28127),
          primary: const Color(0xFFE28127),
          secondary: Colors.red,
        ),
        useMaterial3: true,
      ),
      home: showOnboarding ? const SplashScreen() : const MainScreen(),
    );
  }
}

// MyHomePage class removed as it is replaced by HomeScreen in home_screen.dart
