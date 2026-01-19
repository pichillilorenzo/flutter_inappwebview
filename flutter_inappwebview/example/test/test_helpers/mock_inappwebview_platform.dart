import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A mock InAppWebViewPlatform for testing purposes.
/// This allows widget tests to run without requiring a real platform implementation.
class MockInAppWebViewPlatform extends InAppWebViewPlatform
    with MockPlatformInterfaceMixin {
  static final MockInAppWebViewPlatform _instance =
      MockInAppWebViewPlatform._();

  MockInAppWebViewPlatform._();

  /// Initialize the mock platform for testing.
  /// Call this in setUp() or at the start of your tests.
  static void initialize() {
    InAppWebViewPlatform.instance = _instance;
  }

  /// Reset the platform instance.
  /// Call this in tearDown() to clean up after tests.
  static void reset() {
    // Note: We can't actually set instance to null, but we can leave it as the mock
    // for subsequent tests. The mock is stateless so this is fine.
  }

  @override
  PlatformInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return MockPlatformInAppWebViewControllerStatic(
      const PlatformInAppWebViewControllerCreationParams(id: 'mock_controller'),
    );
  }

  @override
  PlatformCookieManager createPlatformCookieManagerStatic() {
    return MockPlatformCookieManagerStatic(
      PlatformCookieManagerCreationParams(),
    );
  }
}

/// Mock static controller for testing
class MockPlatformInAppWebViewControllerStatic
    extends PlatformInAppWebViewController
    with MockPlatformInterfaceMixin {
  MockPlatformInAppWebViewControllerStatic(super.params)
    : super.implementation();

  @override
  bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) {
    // Return true for all methods in tests
    return true;
  }
}

/// Mock static cookie manager for testing
class MockPlatformCookieManagerStatic extends PlatformCookieManager
    with MockPlatformInterfaceMixin {
  MockPlatformCookieManagerStatic(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) {
    return true;
  }
}
