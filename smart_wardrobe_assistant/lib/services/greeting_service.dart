// ============================================
// GREETING_SERVICE.DART
// ============================================
// Service class for generating time-based greetings
// Determines greeting based on current time
// ============================================

class GreetingService {
  // Prevent instantiation
  GreetingService._();

  /// Get greeting based on current time
  /// 
  /// Time ranges:
  /// - 05:00-11:59 → Good Morning
  /// - 12:00-16:59 → Good Afternoon
  /// - 17:00-20:59 → Good Evening
  /// - 21:00-04:59 → Good Night
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Get greeting with user's first name
  /// 
  /// Example: "Good Morning, Rodney"
  static String getGreetingWithName(String? firstName) {
    final greeting = getGreeting();
    
    if (firstName == null || firstName.isEmpty || firstName == 'Guest') {
      return 'Welcome';
    }
    
    return '$greeting, $firstName';
  }

  /// Get greeting emoji based on time
  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return '👋'; // Morning wave
    } else if (hour >= 12 && hour < 17) {
      return '☀️'; // Afternoon sun
    } else if (hour >= 17 && hour < 21) {
      return '🌆'; // Evening sunset
    } else {
      return '🌙'; // Night moon
    }
  }

  /// Get greeting icon based on time (for UI)
  static String getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return '☀️'; // Morning sun
    } else if (hour >= 12 && hour < 17) {
      return '🌤️'; // Afternoon
    } else if (hour >= 17 && hour < 21) {
      return '🌇'; // Evening
    } else {
      return '🌃'; // Night
    }
  }

  /// Get greeting message for different scenarios
  static String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Ready to pick out your outfit for the day?';
    } else if (hour >= 12 && hour < 17) {
      return 'How\'s your day going?';
    } else if (hour >= 17 && hour < 21) {
      return 'Ready to unwind after a long day?';
    } else {
      return 'Time to relax and plan for tomorrow!';
    }
  }
}
