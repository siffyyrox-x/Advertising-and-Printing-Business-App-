import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/company_info.dart';
import '../widgets/app_image.dart';
import 'main_screen.dart';

/// The first screen. It shows the company logo for two seconds and then moves
/// on to the Home screen automatically.
class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goToHome);
  }

  void _goToHome() {
    // The widget may already have been removed if the user left the app.
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const AppImage(
                  path: 'assets/images/logo.png',
                  width: 160,
                  height: 160,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                CompanyInfo.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                CompanyInfo.tagline,
                textAlign: TextAlign.center,
                style: AppTheme.muted,
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const Spacer(),
              const Text(
                'Loading...',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
