import 'package:flutter_inappwebview_example/utils/constants.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';

/// Represents a single test case with metadata and execution logic
class TestCase {
  final String id;
  final String title;
  final String description;
  final List<String> supportedPlatforms;
  final TestCategory category;
  final TestComplexity complexity;
  final Future<TestResult?> Function() execute;

  const TestCase({
    required this.id,
    required this.title,
    required this.description,
    required this.supportedPlatforms,
    required this.category,
    required this.complexity,
    required this.execute,
  });

  /// Check if this test is supported on the given platform
  bool isSupportedOnPlatform(String platform) {
    return supportedPlatforms.contains(platform);
  }

  /// Serialize to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'supportedPlatforms': supportedPlatforms,
      'category': category.name,
      'complexity': complexity.name,
    };
  }

  /// Deserialize from map
  factory TestCase.fromMap(Map<String, dynamic> map) {
    return TestCase(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      supportedPlatforms: List<String>.from(map['supportedPlatforms'] as List),
      category: TestCategory.values.firstWhere(
        (e) => e.name == map['category'],
      ),
      complexity: TestComplexity.values.firstWhere(
        (e) => e.name == map['complexity'],
      ),
      execute: () async => null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TestCase &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.complexity == complexity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        complexity.hashCode;
  }
}
