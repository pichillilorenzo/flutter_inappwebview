import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LinuxInAppWebViewPlatform.registerWith();

  runApp(const MaterialApp(home: MyApp()));
}

/// Event handler for InAppBrowser tests
class TestInAppBrowserEventHandler extends PlatformInAppBrowserEvents {
  bool browserCreated = false;
  bool browserExited = false;
  Completer<void> browserCreatedCompleter = Completer<void>();
  Completer<void> browserExitedCompleter = Completer<void>();

  @override
  void onBrowserCreated() {
    debugPrint('[TEST] InAppBrowser: onBrowserCreated fired');
    browserCreated = true;
    if (!browserCreatedCompleter.isCompleted) {
      browserCreatedCompleter.complete();
    }
  }

  @override
  void onExit() {
    debugPrint('[TEST] InAppBrowser: onExit fired');
    browserExited = true;
    if (!browserExitedCompleter.isCompleted) {
      browserExitedCompleter.complete();
    }
  }

  @override
  void onLoadStart(WebUri? url) {
    debugPrint('[TEST] InAppBrowser: onLoadStart - $url');
  }

  @override
  void onLoadStop(WebUri? url) {
    debugPrint('[TEST] InAppBrowser: onLoadStop - $url');
  }

  @override
  FutureOr<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) {
    debugPrint("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }
}

/// Test InAppBrowser implementation
Future<void> testInAppBrowser() async {
  debugPrint('[TEST] InAppBrowser: Starting test...');

  final browser = LinuxInAppBrowser(LinuxInAppBrowserCreationParams());
  final eventHandler = TestInAppBrowserEventHandler();
  browser.eventHandler = eventHandler;

  // Open URL
  try {
    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri('https://flutter.dev')),
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(
          toolbarTopBackgroundColor: Colors.blue,
          presentationStyle: ModalPresentationStyle.POPOVER,
        ),
        webViewSettings: InAppWebViewSettings(
          isInspectable: kDebugMode,
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
        ),
      ),
    );
    debugPrint('[TEST] InAppBrowser: openUrlRequest completed');
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: openUrlRequest failed - $e');
    return;
  }

  // Wait for browser to be created (with timeout)
  try {
    await eventHandler.browserCreatedCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint(
          '[TEST] ❌ InAppBrowser: Timeout waiting for onBrowserCreated',
        );
      },
    );
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: Error waiting for browser - $e');
  }

  if (!eventHandler.browserCreated) {
    debugPrint('[TEST] ❌ InAppBrowser: onBrowserCreated not fired');
    return;
  }

  debugPrint('[TEST] ✅ InAppBrowser: Browser created successfully');

  // Test isHidden
  try {
    final isHidden = await browser.isHidden();
    debugPrint('[TEST] InAppBrowser: isHidden = $isHidden');
    if (isHidden == false) {
      debugPrint(
        '[TEST] ✅ InAppBrowser: isHidden returned correct value (false)',
      );
    }
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: isHidden failed - $e');
  }

  // Test hide
  try {
    await browser.hide();
    debugPrint('[TEST] ✅ InAppBrowser: hide() called successfully');
    await Future.delayed(const Duration(milliseconds: 500));

    final isHiddenAfterHide = await browser.isHidden();
    debugPrint('[TEST] InAppBrowser: isHidden after hide = $isHiddenAfterHide');
    if (isHiddenAfterHide == true) {
      debugPrint('[TEST] ✅ InAppBrowser: hide() worked correctly');
    }
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: hide failed - $e');
  }

  // Test show
  try {
    await browser.show();
    debugPrint('[TEST] ✅ InAppBrowser: show() called successfully');
    await Future.delayed(const Duration(milliseconds: 500));

    final isHiddenAfterShow = await browser.isHidden();
    debugPrint('[TEST] InAppBrowser: isHidden after show = $isHiddenAfterShow');
    if (isHiddenAfterShow == false) {
      debugPrint('[TEST] ✅ InAppBrowser: show() worked correctly');
    }
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: show failed - $e');
  }

  // Test setSettings
  try {
    await browser.setSettings(
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(
          toolbarTopBackgroundColor: const Color.fromARGB(255, 100, 100, 100),
        ),
      ),
    );
    debugPrint('[TEST] ✅ InAppBrowser: setSettings() called successfully');
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: setSettings failed - $e');
  }

  // Test getSettings
  try {
    final settings = await browser.getSettings();
    debugPrint('[TEST] InAppBrowser: getSettings() = $settings');
    debugPrint('[TEST] ✅ InAppBrowser: getSettings() called successfully');
  } catch (e) {
    debugPrint('[TEST] ❌ InAppBrowser: getSettings failed - $e');
  }

  // Wait for browser exit (with timeout)
  try {
    await eventHandler.browserExitedCompleter.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('[TEST] ⚠️ InAppBrowser: Timeout waiting for onExit');
      },
    );
  } catch (e) {
    debugPrint('[TEST] ⚠️ InAppBrowser: Error waiting for exit - $e');
  }

  if (eventHandler.browserExited) {
    debugPrint('[TEST] ✅ InAppBrowser: All tests passed!');
  } else {
    debugPrint('[TEST] ⚠️ InAppBrowser: Tests completed but onExit not fired');
  }
}

/// Test openWithSystemBrowser
Future<void> testOpenWithSystemBrowser() async {
  debugPrint('[TEST] openWithSystemBrowser: Starting test...');
  try {
    final browser = LinuxInAppBrowser(LinuxInAppBrowserCreationParams());
    await browser.openWithSystemBrowser(url: WebUri('https://flutter.dev'));
    debugPrint('[TEST] ✅ openWithSystemBrowser: Command executed successfully');
  } catch (e) {
    debugPrint('[TEST] ❌ openWithSystemBrowser: $e');
  }
}

/// Run all InAppBrowser tests
Future<void> runAllInAppBrowserTests() async {
  debugPrint('');
  debugPrint('========================================');
  debugPrint('[TEST] Starting InAppBrowser Test Suite');
  debugPrint('========================================');
  debugPrint('');

  // Test 1: InAppBrowser
  await testInAppBrowser();

  debugPrint('');
  debugPrint('----------------------------------------');
  debugPrint('');

  debugPrint('');
  debugPrint('========================================');
  debugPrint('[TEST] InAppBrowser Test Suite Complete');
  debugPrint('========================================');
  debugPrint('');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  LinuxInAppWebViewController? webViewController;
  late LinuxFindInteractionController findInteractionController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    javaScriptCanOpenWindowsAutomatically: true,
    // Register custom scheme for onLoadResourceWithCustomScheme testing
    // Note: http/https cannot be overridden - WPE WebKit explicitly prohibits it
    resourceCustomSchemes: ['myapp'],
    // Enable Intelligent Tracking Prevention (ITP)
    itpEnabled: true,
  );

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    findInteractionController = LinuxFindInteractionController(
      LinuxFindInteractionControllerCreationParams(
        onFindResultReceived:
            (
              controller,
              activeMatchOrdinal,
              numberOfMatches,
              isDoneCounting,
            ) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Linux InAppWebView Tests")),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: urlController,
              keyboardType: TextInputType.url,
              onSubmitted: (value) {
                var url = WebUri(value);
                if (url.scheme.isEmpty) {
                  url = WebUri("https://www.google.com/search?q=$value");
                }
                webViewController?.loadUrl(urlRequest: URLRequest(url: url));
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: LinuxInAppWebViewWidget(
                      LinuxInAppWebViewWidgetCreationParams(
                        key: webViewKey,
                        initialUrlRequest: URLRequest(
                          url: WebUri(
                            "https://www.youtube.com/watch?v=d7j6vZHskNY&themeRefresh=1",
                          ),
                        ),
                        // initialFile: "assets/date_input_test.html",
                        initialSettings: settings,
                        onWebViewCreated: (controller) async {
                          webViewController = controller;

                          await Future.delayed(Duration(seconds: 2));
                          controller.loadUrl(
                            urlRequest: URLRequest(
                              url: WebUri('https://flutter.dev'),
                            ),
                          );
                          debugPrint('[TEST] Loaded flutter.dev');

                          await Future.delayed(Duration(seconds: 2));
                          controller.reload();
                          debugPrint('[TEST] Reloaded flutter.dev');

                          await Future.delayed(Duration(seconds: 2));
                          controller.loadUrl(
                            urlRequest: URLRequest(
                              url: WebUri('https://google.com'),
                            ),
                          );
                          debugPrint('[TEST] Loaded google.com');

                          await Future.delayed(Duration(seconds: 2));
                          controller.reload();
                          debugPrint('[TEST] Reloaded google.com');

                          await Future.delayed(Duration(seconds: 2));
                          controller.goBack();
                          debugPrint('[TEST] Should go back to flutter.dev');

                          await Future.delayed(Duration(seconds: 2));
                          controller.goBack();
                          debugPrint('[TEST] Should go back to YouTube');
                        },
                      ),
                    ).build(context),
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Icon(Icons.arrow_back),
                  onPressed: () {
                    webViewController?.goBack();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    webViewController?.goForward();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () {
                    webViewController?.reload();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Test InAppBrowser'),
                  onPressed: () {
                    runAllInAppBrowserTests();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
