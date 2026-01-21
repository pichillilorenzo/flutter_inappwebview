import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';

import 'mock_inappwebview_platform.dart';

/// Creates a mock SettingsManager for testing.
/// This bypasses the SharedPreferences and WebViewEnvironment dependencies.
class MockSettingsManager extends SettingsManager {
  MockSettingsManager()
    : super(
        environmentFactory: (_) async => null,
        environmentSupportChecker: () => false,
      );

  @override
  WebViewEnvironmentSettings buildEnvironmentSettings() =>
      WebViewEnvironmentSettings(
        releaseChannels: EnvironmentReleaseChannels.STABLE,
      );

  @override
  InAppWebViewSettings buildSettings() => InAppWebViewSettings();
}

/// A wrapper widget that provides all common providers needed for testing.
class TestProviderWrapper extends StatelessWidget {
  final Widget child;
  final SettingsManager? settingsManager;
  final EventLogProvider? eventLogProvider;
  final NetworkMonitor? networkMonitor;

  const TestProviderWrapper({
    super.key,
    required this.child,
    this.settingsManager,
    this.eventLogProvider,
    this.networkMonitor,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsManager>.value(
          value: settingsManager ?? MockSettingsManager(),
        ),
        ChangeNotifierProvider<EventLogProvider>.value(
          value: eventLogProvider ?? EventLogProvider(),
        ),
        ChangeNotifierProvider<NetworkMonitor>.value(
          value: networkMonitor ?? NetworkMonitor(),
        ),
      ],
      child: child,
    );
  }
}

/// Helper to set up tests that require the InAppWebViewPlatform mock.
void setUpMockPlatform() {
  MockInAppWebViewPlatform.initialize();
}
