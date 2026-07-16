import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/app_initialization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize app and determine navigation route
    _initializeApp();
  }

  /// Initialize the app and navigate to the appropriate screen
  /// This method:
  /// 1. Waits for 3 seconds (splash screen display time)
  /// 2. Checks if user is logged in
  /// 3. Checks if user has completed onboarding
  /// 4. Navigates to the correct screen based on these conditions
  Future<void> _initializeApp() async {
    // Show splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Determine which screen to navigate to
    final appInitService = AppInitializationService.instance;
    
    // Get initialization status (for debugging)
    final status = await appInitService.getInitializationStatus();
    print('App Initialization Status:');
    print('  - Is Logged In: ${status['isLoggedIn']}');
    print('  - Has Completed Onboarding: ${status['hasCompletedOnboarding']}');
    print('  - Initial Route: ${status['initialRoute']}');
    print('  - Route Name: ${status['routeName']}');

    // Get the route name to navigate to
    final routeName = await appInitService.getInitialRouteName();

    // Navigate to the determined route
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wardrobe Logo Image
              Image.asset(
                'assets/images/wardrobe.png',
                width: 140,
                height: 140,
              ),
              
              const SizedBox(height: 60),
              
              // App Name
              const Text(
                'Smart Wardrobe',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Assistant',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              
              const SizedBox(height: 100),
              
              // Slogan
              const Text(
                'AI-Powered Outfit &',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              
              const SizedBox(height: 4),
              
              const Text(
                'Shopping Recommendations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Loading Indicator
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
