import 'package:flutter/material.dart';

/// Test categories for organizing tests
enum TestCategory {
  navigation,
  javascript,
  content,
  storage,
  advanced,
  browsers,
}

/// Test complexity levels
enum TestComplexity {
  quick, // < 1 second
  medium, // 1-5 seconds
  long, // 5-30 seconds
  interactive, // Requires user interaction
}

/// Color constants for support badges
class SupportBadgeColors {
  static const Color supported = Color(0xFF4CAF50); // Green
  static const Color unsupported = Color(0xFFF44336); // Red
}

/// Color constants for performance indicators
class PerformanceColors {
  static const Color fast = Color(0xFF4CAF50); // Green < 100ms
  static const Color medium = Color(0xFFFFC107); // Yellow 100-500ms
  static const Color slow = Color(0xFFF44336); // Red >= 500ms
}

/// Platform display names
const Map<String, String> platformNames = {
  'android': 'Android',
  'ios': 'iOS',
  'macos': 'macOS',
  'web': 'Web',
  'windows': 'Windows',
  'linux': 'Linux',
};

/// All supported platforms
const List<String> allPlatforms = [
  'android',
  'ios',
  'macos',
  'web',
  'windows',
  'linux',
];

/// Performance thresholds in milliseconds
class PerformanceThresholds {
  static const int fast = 100;
  static const int medium = 500;
}
