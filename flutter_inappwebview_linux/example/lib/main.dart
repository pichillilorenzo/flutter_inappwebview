import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LinuxInAppWebViewPlatform.registerWith();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LinuxInAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InAppWebView Linux Example'),
        ),
        body: Column(
          children: [
            Expanded(
              child: LinuxInAppWebViewWidget(
                LinuxInAppWebViewWidgetCreationParams(
                  initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    javaScriptEnabled: true,
                    javaScriptBridgeEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true
                  ),
                  onWebViewCreated: (controller) {
                    _controller = controller as LinuxInAppWebViewController;
                  },
                  onLoadStart: (controller, url) {
                    debugPrint('onLoadStart: $url');
                  },
                  onLoadStop: (controller, url) {
                    debugPrint('onLoadStop: $url');
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    debugPrint('shouldOverrideUrlLoading: ${navigationAction.request.url}');
                    return NavigationActionPolicy.ALLOW;
                  },
                  onCreateWindow: (controller, createWindowAction) async {
                    debugPrint('onCreateWindow: ${createWindowAction.request.url}');
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    debugPrint('Console Message: ${consoleMessage.message}');
                  },
                ),
              ).build(context),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _controller?.goBack(),
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () => _controller?.goForward(),
                    child: const Text('Forward'),
                  ),
                  ElevatedButton(
                    onPressed: () => _controller?.reload(),
                    child: const Text('Reload'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Test console.log and JS bridge - check if console is wrapped
                      final result = await _controller?.evaluateJavascript(source: '''
                        (function() {
                          var results = [];
                          results.push("flutter_inappwebview: " + (typeof window.flutter_inappwebview));
                          results.push("callHandler: " + (typeof window.flutter_inappwebview?.callHandler));
                          
                          // Check if console.log has been wrapped (native function vs our wrapper)
                          var consoleLogStr = console.log.toString();
                          results.push("console.log wrapped: " + (consoleLogStr.indexOf('native') === -1));
                          
                          // Test console.log directly (should be intercepted by console_log_js)
                          console.log("Test 1: Direct console.log");
                          console.warn("Test 2: console.warn");
                          console.error("Test 3: console.error");
                          
                          // Test via callHandler (should also work as it goes through the bridge)
                          try {
                            window.flutter_inappwebview.callHandler('onConsoleMessage', {level: 'log', message: 'Test 4: Via callHandler'});
                            results.push("callHandler: sent");
                          } catch(e) {
                            results.push("callHandler error: " + e.message);
                          }
                          
                          return results.join(", ");
                        })();
                      ''');
                      debugPrint('JS Bridge test result: $result');
                    },
                    child: const Text('Test JS'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

