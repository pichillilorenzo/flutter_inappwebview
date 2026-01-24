import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

/// Status of the test runner
enum TestStatus { idle, running, paused, completed, error }

/// Extended test result with additional metadata
class ExtendedTestResult {
  final String testId;
  final String testTitle;
  final TestCategory category;
  final bool success;
  final String message;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool skipped;
  final String? skipReason;

  const ExtendedTestResult({
    required this.testId,
    required this.testTitle,
    required this.category,
    required this.success,
    required this.message,
    required this.duration,
    required this.timestamp,
    this.data,
    this.skipped = false,
    this.skipReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testTitle': testTitle,
      'category': category.name,
      'success': success,
      'message': message,
      'durationMs': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'skipped': skipped,
      'skipReason': skipReason,
    };
  }

  factory ExtendedTestResult.fromJson(Map<String, dynamic> json) {
    return ExtendedTestResult(
      testId: json['testId'] as String,
      testTitle: json['testTitle'] as String,
      category: TestCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      success: json['success'] as bool,
      message: json['message'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
      skipped: json['skipped'] as bool? ?? false,
      skipReason: json['skipReason'] as String?,
    );
  }
}

/// A single test case that can be executed
class ExecutableTestCase {
  final String id;
  final String title;
  final String description;
  final TestCategory category;
  final Future<TestResult> Function(InAppWebViewController? controller) execute;
  final List<String> supportedPlatforms;
  final dynamic supportedMethod;
  final bool Function(dynamic method, {TargetPlatform? platform})?
  isMethodSupported;

  const ExecutableTestCase({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.execute,
    this.supportedPlatforms = const [
      'android',
      'ios',
      'macos',
      'windows',
      'linux',
      'web',
    ],
    this.supportedMethod,
    this.isMethodSupported,
  });

  bool isSupportedOnCurrentPlatform() {
    if (isMethodSupported != null && supportedMethod != null) {
      return isMethodSupported!(
        supportedMethod,
        platform: _getCurrentTargetPlatform(),
      );
    }

    final currentPlatform = _getCurrentPlatform();
    return supportedPlatforms.contains(currentPlatform);
  }

  static String _getCurrentPlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }

  static TargetPlatform? _getCurrentTargetPlatform() {
    if (kIsWeb) return null;
    return defaultTargetPlatform;
  }
}

/// Category with its test cases
class TestCategoryGroup {
  final TestCategory category;
  final List<ExecutableTestCase> tests;

  const TestCategoryGroup({required this.category, required this.tests});

  /// The display name derived from category.displayName
  String get name => category.displayName;

  /// The description derived from category.description
  String get description => category.description;
}
