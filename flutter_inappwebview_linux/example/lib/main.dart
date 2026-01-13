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
                        // initialUrlRequest: URLRequest(url: WebUri("https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/color"),),
                        initialFile: "assets/date_input_test.html",
                        initialSettings: settings,
                        onWebViewCreated: (controller) {
                          webViewController = controller;

                          // Register a test JavaScript handler
                          controller.addJavaScriptHandler(
                            handlerName: 'testHandler',
                            callback: (args) {
                              if (kDebugMode) {
                                print('[TEST] testHandler called with args: $args');
                              }
                              // Return a response that JavaScript will receive
                              return {
                                'success': true,
                                'message': 'Hello from Dart!',
                                'receivedArgs': args
                              };
                            },
                          );

                          // Register another handler that returns a simple string
                          controller.addJavaScriptHandler(
                            handlerName: 'greetHandler',
                            callback: (args) {
                              String name = args.isNotEmpty ? args[0] : 'World';
                              if (kDebugMode) {
                                print('[TEST] greetHandler called with name: $name');
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
                          await controller.evaluateJavascript(source: '''
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
                          ''');

                          // Test 2: Call greetHandler
                          await controller.evaluateJavascript(source: '''
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
                          ''');

                          if (kDebugMode) {
                            print('[TEST] JavaScript handler tests completed');
                          }
                        },
                        onReceivedError: (controller, request, error) {},
                        onReceivedHttpError: (controller, request, response) {},
                        onReceivedClientCertRequest: (controller, challenge) async {
                          // This callback is triggered when a server requests a client certificate
                          print('[TEST] onReceivedClientCertRequest: ${challenge.protectionSpace.host}:${challenge.protectionSpace.port}');
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
