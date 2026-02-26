import 'package:flutter/material.dart';

/// Test categories for organizing tests
enum TestCategory {
  navigation('Navigation', 'Tests for navigation-related methods'),
  javascript('JavaScript', 'Tests for JavaScript execution and handlers'),
  content('Content', 'Tests for content manipulation and retrieval'),
  storage('Storage', 'Tests for storage and cookie management'),
  advanced('Advanced', 'Advanced and misc test cases'),
  browsers('Browsers', 'Tests for browser-related functionality');

  final String displayName;
  final String description;

  const TestCategory(this.displayName, this.description);
}

/// Test complexity levels
enum TestComplexity {
  quick, // < 1 second
  medium, // 1-5 seconds
  long, // 5-30 seconds
  interactive, // Requires user interaction
}

/// Color constants for performance indicators
class PerformanceColors {
  static const Color fast = Color(0xFF4CAF50); // Green < 100ms
  static const Color medium = Color(0xFFFFC107); // Yellow 100-500ms
  static const Color slow = Color(0xFFF44336); // Red >= 500ms
}

/// Performance thresholds in milliseconds
class PerformanceThresholds {
  static const int fast = 100;
  static const int medium = 500;
}
