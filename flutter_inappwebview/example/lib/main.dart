import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/providers/test_runner.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/models/test_configuration.dart';
import 'package:flutter_inappwebview_example/screens/platform_info_screen.dart';
import 'package:flutter_inappwebview_example/screens/webview_tester_screen.dart';
import 'package:flutter_inappwebview_example/screens/settings_editor_screen.dart';
import 'package:flutter_inappwebview_example/screens/webview_environment_settings_editor_screen.dart';
import 'package:flutter_inappwebview_example/screens/storage/cookie_manager_screen.dart';
import 'package:flutter_inappwebview_example/screens/storage/web_storage_screen.dart';
import 'package:flutter_inappwebview_example/screens/storage/http_auth_screen.dart';
import 'package:flutter_inappwebview_example/screens/browsers/inapp_browser_screen.dart';
import 'package:flutter_inappwebview_example/screens/browsers/chrome_safari_browser_screen.dart';
import 'package:flutter_inappwebview_example/screens/browsers/headless_webview_screen.dart';
import 'package:flutter_inappwebview_example/screens/advanced/controllers_screen.dart';
import 'package:flutter_inappwebview_example/screens/advanced/service_controllers_screen.dart';
import 'package:flutter_inappwebview_example/screens/advanced/static_methods_screen.dart';
import 'package:flutter_inappwebview_example/screens/support_matrix/support_matrix_screen.dart';
import 'package:flutter_inappwebview_example/screens/support_matrix/platform_comparison_screen.dart';
import 'package:flutter_inappwebview_example/screens/test_automation/test_runner_screen.dart';
import 'package:flutter_inappwebview_example/screens/test_automation/test_configuration_screen.dart';
import 'package:flutter_inappwebview_example/utils/test_registry.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

final localhostServer = InAppLocalhostServer(documentRoot: 'assets');

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize test registry
  TestRegistry.init();

  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  final settingsManager = SettingsManager();
  await settingsManager.init();

  final testConfigManager = TestConfigurationManager();
  await testConfigManager.init();

  runApp(
    MyApp(
      settingsManager: settingsManager,
      testConfigManager: testConfigManager,
    ),
  );
}

Drawer buildDrawer({required BuildContext context}) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$InAppWebView',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Test Suite',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text('WebView Tester'),
          leading: Icon(Icons.web),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        ListTile(
          title: Text('Settings Editor'),
          leading: Icon(Icons.settings),
          onTap: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
        ListTile(
          title: Text('Environment Settings'),
          leading: Icon(Icons.memory),
          onTap: () {
            Navigator.pushNamed(context, '/environment-settings');
          },
        ),
        ListTile(
          title: Text('Platform Info'),
          leading: Icon(Icons.info_outline),
          onTap: () {
            Navigator.pushNamed(context, '/platform-info');
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Storage & Cookies',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('Cookie Manager'),
          leading: Icon(Icons.cookie_outlined),
          onTap: () {
            Navigator.pushNamed(context, '/storage/cookies');
          },
        ),
        ListTile(
          title: Text('Web Storage'),
          leading: Icon(Icons.storage_outlined),
          onTap: () {
            Navigator.pushNamed(context, '/storage/webstorage');
          },
        ),
        ListTile(
          title: Text('HTTP Auth Credentials'),
          leading: Icon(Icons.lock_outline),
          onTap: () {
            Navigator.pushNamed(context, '/storage/http-auth');
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Browsers',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('$InAppBrowser'),
          leading: Icon(Icons.open_in_browser),
          onTap: () {
            Navigator.pushNamed(context, '/browsers/inapp-browser');
          },
        ),
        ListTile(
          title: Text('Chrome/Safari Browser'),
          leading: Icon(Icons.public),
          onTap: () {
            Navigator.pushNamed(context, '/browsers/chrome-safari-browser');
          },
        ),
        ListTile(
          title: Text('Headless WebView'),
          leading: Icon(Icons.visibility_off_outlined),
          onTap: () {
            Navigator.pushNamed(context, '/browsers/headless');
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Advanced',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('Controllers'),
          leading: Icon(Icons.tune),
          onTap: () {
            Navigator.pushNamed(context, '/advanced/controllers');
          },
        ),
        ListTile(
          title: Text('Service Controllers'),
          leading: Icon(Icons.settings_applications),
          onTap: () {
            Navigator.pushNamed(context, '/advanced/service-controllers');
          },
        ),
        ListTile(
          title: Text('Static Methods'),
          leading: Icon(Icons.functions),
          onTap: () {
            Navigator.pushNamed(context, '/advanced/static-methods');
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Testing',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('Automated Test Runner'),
          leading: Icon(Icons.science),
          onTap: () {
            Navigator.pushNamed(context, '/test-automation');
          },
        ),
        ListTile(
          title: Text('Test Configuration'),
          leading: Icon(Icons.tune),
          onTap: () {
            Navigator.pushNamed(context, '/test-configuration');
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Documentation',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('API Support Matrix'),
          leading: Icon(Icons.grid_on),
          onTap: () {
            Navigator.pushNamed(context, '/support-matrix');
          },
        ),
        ListTile(
          title: Text('Platform Comparison'),
          leading: Icon(Icons.compare_arrows),
          onTap: () {
            Navigator.pushNamed(context, '/platform-comparison');
          },
        ),
      ],
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsManager,
    required this.testConfigManager,
  });

  final SettingsManager settingsManager;
  final TestConfigurationManager testConfigManager;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the app with providers for Phase 1
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventLogProvider()),
        ChangeNotifierProvider.value(value: widget.settingsManager),
        ChangeNotifierProvider(create: (_) => TestRunner()),
        ChangeNotifierProvider(create: (_) => NetworkMonitor()),
        ChangeNotifierProvider.value(value: widget.testConfigManager),
      ],
      child: _buildMaterialApp(),
    );
  }

  Widget _buildMaterialApp() {
    return MaterialApp(
      title: '${InAppWebView} Test Suite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          elevation: 2,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        useMaterial3: false,
      ),
      routes: {
        '/': (context) => WebViewTesterScreen(),
        '/platform-info': (context) => PlatformInfoScreen(),
        '/webview-tester': (context) => WebViewTesterScreen(),
        '/settings': (context) => SettingsEditorScreen(),
        '/environment-settings': (context) =>
            WebViewEnvironmentSettingsEditorScreen(),
        '/storage/cookies': (context) => CookieManagerScreen(),
        '/storage/webstorage': (context) => WebStorageScreen(),
        '/storage/http-auth': (context) => HttpAuthScreen(),
        '/browsers/inapp-browser': (context) => InAppBrowserScreen(),
        '/browsers/chrome-safari-browser': (context) =>
            ChromeSafariBrowserScreen(),
        '/browsers/headless': (context) => HeadlessWebViewScreen(),
        '/advanced/controllers': (context) => ControllersScreen(),
        '/advanced/service-controllers': (context) =>
            ServiceControllersScreen(),
        '/advanced/static-methods': (context) => StaticMethodsScreen(),
        '/support-matrix': (context) => SupportMatrixScreen(),
        '/platform-comparison': (context) => PlatformComparisonScreen(),
        '/test-automation': (context) => TestRunnerScreen(),
        '/test-configuration': (context) => TestConfigurationScreen(),
      },
    );
  }
}
