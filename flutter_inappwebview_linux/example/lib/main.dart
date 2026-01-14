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
    print('[TEST] InAppBrowser: onBrowserCreated fired');
    browserCreated = true;
    if (!browserCreatedCompleter.isCompleted) {
      browserCreatedCompleter.complete();
    }
  }

  @override
  void onExit() {
    print('[TEST] InAppBrowser: onExit fired');
    browserExited = true;
    if (!browserExitedCompleter.isCompleted) {
      browserExitedCompleter.complete();
    }
  }

  @override
  void onLoadStart(WebUri? url) {
    print('[TEST] InAppBrowser: onLoadStart - $url');
  }

  @override
  void onLoadStop(WebUri? url) {
    print('[TEST] InAppBrowser: onLoadStop - $url');
  }

  @override
  FutureOr<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) {
    print("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }
}

/// Test InAppBrowser implementation
Future<void> testInAppBrowser() async {
  print('[TEST] InAppBrowser: Starting test...');

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
    print('[TEST] InAppBrowser: openUrlRequest completed');
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: openUrlRequest failed - $e');
    return;
  }

  // Wait for browser to be created (with timeout)
  try {
    await eventHandler.browserCreatedCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('[TEST] ❌ InAppBrowser: Timeout waiting for onBrowserCreated');
      },
    );
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: Error waiting for browser - $e');
  }

  if (!eventHandler.browserCreated) {
    print('[TEST] ❌ InAppBrowser: onBrowserCreated not fired');
    return;
  }

  print('[TEST] ✅ InAppBrowser: Browser created successfully');

  // Test isHidden
  try {
    final isHidden = await browser.isHidden();
    print('[TEST] InAppBrowser: isHidden = $isHidden');
    if (isHidden == false) {
      print('[TEST] ✅ InAppBrowser: isHidden returned correct value (false)');
    }
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: isHidden failed - $e');
  }

  // Test hide
  try {
    await browser.hide();
    print('[TEST] ✅ InAppBrowser: hide() called successfully');
    await Future.delayed(const Duration(milliseconds: 500));

    final isHiddenAfterHide = await browser.isHidden();
    print('[TEST] InAppBrowser: isHidden after hide = $isHiddenAfterHide');
    if (isHiddenAfterHide == true) {
      print('[TEST] ✅ InAppBrowser: hide() worked correctly');
    }
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: hide failed - $e');
  }

  // Test show
  try {
    await browser.show();
    print('[TEST] ✅ InAppBrowser: show() called successfully');
    await Future.delayed(const Duration(milliseconds: 500));

    final isHiddenAfterShow = await browser.isHidden();
    print('[TEST] InAppBrowser: isHidden after show = $isHiddenAfterShow');
    if (isHiddenAfterShow == false) {
      print('[TEST] ✅ InAppBrowser: show() worked correctly');
    }
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: show failed - $e');
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
    print('[TEST] ✅ InAppBrowser: setSettings() called successfully');
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: setSettings failed - $e');
  }

  // Test getSettings
  try {
    final settings = await browser.getSettings();
    print('[TEST] InAppBrowser: getSettings() = $settings');
    print('[TEST] ✅ InAppBrowser: getSettings() called successfully');
  } catch (e) {
    print('[TEST] ❌ InAppBrowser: getSettings failed - $e');
  }

  // Wait for browser exit (with timeout)
  try {
    await eventHandler.browserExitedCompleter.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        print('[TEST] ⚠️ InAppBrowser: Timeout waiting for onExit');
      },
    );
  } catch (e) {
    print('[TEST] ⚠️ InAppBrowser: Error waiting for exit - $e');
  }

  if (eventHandler.browserExited) {
    print('[TEST] ✅ InAppBrowser: All tests passed!');
  } else {
    print('[TEST] ⚠️ InAppBrowser: Tests completed but onExit not fired');
  }
}

/// Test openWithSystemBrowser
Future<void> testOpenWithSystemBrowser() async {
  print('[TEST] openWithSystemBrowser: Starting test...');
  try {
    final browser = LinuxInAppBrowser(LinuxInAppBrowserCreationParams());
    await browser.openWithSystemBrowser(url: WebUri('https://flutter.dev'));
    print('[TEST] ✅ openWithSystemBrowser: Command executed successfully');
  } catch (e) {
    print('[TEST] ❌ openWithSystemBrowser: $e');
  }
}

/// Run all InAppBrowser tests
Future<void> runAllInAppBrowserTests() async {
  print('');
  print('========================================');
  print('[TEST] Starting InAppBrowser Test Suite');
  print('========================================');
  print('');

  // Test 1: InAppBrowser
  await testInAppBrowser();

  print('');
  print('----------------------------------------');
  print('');

  print('');
  print('========================================');
  print('[TEST] InAppBrowser Test Suite Complete');
  print('========================================');
  print('');
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
                        initialUrlRequest: URLRequest(url: WebUri("https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/color"),),
                        //initialFile: "assets/date_input_test.html",
                        initialSettings: settings,
                        onWebViewCreated: (controller) {
                          webViewController = controller;

                          // Register a test JavaScript handler
                          controller.addJavaScriptHandler(
                            handlerName: 'testHandler',
                            callback: (args) {
                              if (kDebugMode) {
                                print(
                                  '[TEST] testHandler called with args: $args',
                                );
                              }
                              // Return a response that JavaScript will receive
                              return {
                                'success': true,
                                'message': 'Hello from Dart!',
                                'receivedArgs': args,
                              };
                            },
                          );

                          // Register another handler that returns a simple string
                          controller.addJavaScriptHandler(
                            handlerName: 'greetHandler',
                            callback: (args) {
                              String name = args.isNotEmpty ? args[0] : 'World';
                              if (kDebugMode) {
                                print(
                                  '[TEST] greetHandler called with name: $name',
                                );
                              }
                              return 'Hello, $name!';
                            },
                          );
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT,
                          );
                        },
                        onCreateWindow: (controller, createWindowAction) async {
                          if (createWindowAction.request.url != null) {
                            controller.loadUrl(
                              urlRequest: createWindowAction.request,
                            );
                          }
                          return true;
                        },
                        onCloseWindow: (controller) {
                          print('[TEST] onCloseWindow called');
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                              return NavigationActionPolicy.ALLOW;
                            },
                        onProgressChanged: (controller, progress) {
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = url;
                          });
                        },
                        onUpdateVisitedHistory: (controller, url, isReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onPageCommitVisible: (controller, url) {},
                        onLoadStop: (controller, url) async {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                          await Future.delayed(Duration(seconds: 1));

                          // Test JavaScript handlers after page loads
                          if (kDebugMode) {
                            print('[TEST] Testing JavaScript handlers...');
                          }

                          // Test 1: Call testHandler with arguments
                          await controller.evaluateJavascript(
                            source: '''
                            (async function() {
                              try {
                                console.log('[JS TEST] Calling testHandler...');
                                var result = await window.flutter_inappwebview.callHandler('testHandler', 'arg1', 123, {key: 'value'});
                                console.log('[JS TEST] testHandler result:', JSON.stringify(result));
                                return JSON.stringify(result);
                              } catch (e) {
                                console.error('[JS TEST] testHandler error:', e);
                                return 'error: ' + e.message;
                              }
                            })();
                          ''',
                          );

                          // Test 2: Call greetHandler
                          await controller.evaluateJavascript(
                            source: '''
                            (async function() {
                              try {
                                console.log('[JS TEST] Calling greetHandler...');
                                var result = await window.flutter_inappwebview.callHandler('greetHandler', 'Flutter');
                                console.log('[JS TEST] greetHandler result:', result);
                                return result;
                              } catch (e) {
                                console.error('[JS TEST] greetHandler error:', e);
                                return 'error: ' + e.message;
                              }
                            })();
                          ''',
                          );

                          if (kDebugMode) {
                            print('[TEST] JavaScript handler tests completed');
                          }
                        },
                        onReceivedError: (controller, request, error) {},
                        onReceivedHttpError: (controller, request, response) {},
                        onReceivedClientCertRequest: (controller, challenge) async {
                          // This callback is triggered when a server requests a client certificate
                          print(
                            '[TEST] onReceivedClientCertRequest: ${challenge.protectionSpace.host}:${challenge.protectionSpace.port}',
                          );
                          // For testing, we just cancel the request
                          // In a real app, you might load a certificate from a file:
                          // return ClientCertResponse(
                          //   certificatePath: '/path/to/client.pem',
                          //   action: ClientCertResponseAction.PROCEED,
                          // );
                          return ClientCertResponse(
                            action: ClientCertResponseAction.CANCEL,
                          );
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          if (kDebugMode) {
                            print('[CONSOLE] ${consoleMessage.message}');
                          }
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
