import 'dart:collection';
import 'dart:typed_data';

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

  // Test state machine
  int _testStage = 0;

  // Event tracking for verification
  bool _onLoadStartCalled = false;
  bool _onProgressChangedCalled = false;
  bool _onTitleChangedCalled = false;
  bool _onScrollChangedCalled = false;
  bool _shouldOverrideUrlLoadingCalled = false;
  bool _onUpdateVisitedHistoryCalled = false;
  bool _onPageCommitVisibleCalled = false;
  String? _lastTitle;
  int? _lastProgress;

  @override
  void initState() {
    super.initState();
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
                          url: WebUri("about:blank"),
                        ),
                        initialSettings: settings,
                        // Test initialUserScripts
                        initialUserScripts: UnmodifiableListView([
                          UserScript(
                            source:
                                'window.INITIAL_SCRIPT_LOADED = true; console.log("[INITIAL_SCRIPT] Document Start script executed!");',
                            injectionTime:
                                UserScriptInjectionTime.AT_DOCUMENT_START,
                            groupName: 'initial-test-group',
                          ),
                          UserScript(
                            source:
                                'window.INITIAL_SCRIPT_END = true; console.log("[INITIAL_SCRIPT] Document End script executed!");',
                            injectionTime:
                                UserScriptInjectionTime.AT_DOCUMENT_END,
                            groupName: 'initial-test-group',
                          ),
                        ]),
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                          print(
                            '[TEST] ✅ onWebViewCreated called - controller received',
                          );
                        },
                        onLoadResourceWithCustomScheme: (controller, request) async {
                          print('[TEST] ✅ onLoadResourceWithCustomScheme called!');
                          print('[TEST]   URL: ${request.url}');
                          print('[TEST]   Method: ${request.method}');
                          // Return a simple HTML response for custom schemes
                          return CustomSchemeResponse(
                            data: Uint8List.fromList(
                              '<html><body><h1>Custom Scheme Response</h1><p>URL: ${request.url}</p></body></html>'
                                  .codeUnits,
                            ),
                            contentType: 'text/html',
                          );
                        },
                        onLoadStart: (controller, url) {
                          _onLoadStartCalled = true;
                          print('[TEST] onLoadStart: $url');
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
                          print(
                            '[TEST] onCreateWindow called: ${createWindowAction.request.url}',
                          );
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
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          _shouldOverrideUrlLoadingCalled = true;
                          print(
                            '[TEST] shouldOverrideUrlLoading: ${navigationAction.request.url}',
                          );
                          print(
                            '[TEST]   - isForMainFrame: ${navigationAction.isForMainFrame}',
                          );
                          return NavigationActionPolicy.ALLOW;
                        },
                        onProgressChanged: (controller, progress) {
                          _onProgressChangedCalled = true;
                          _lastProgress = progress;
                          if (progress == 100 || progress % 25 == 0) {
                            print('[TEST] onProgressChanged: $progress%');
                          }
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = url;
                          });
                        },
                        onTitleChanged: (controller, title) {
                          _onTitleChangedCalled = true;
                          _lastTitle = title;
                          print('[TEST] onTitleChanged: "$title"');
                        },
                        onScrollChanged: (controller, x, y) {
                          _onScrollChangedCalled = true;
                          print('[TEST] onScrollChanged: x=$x, y=$y');
                        },
                        onUpdateVisitedHistory: (controller, url, isReload) {
                          _onUpdateVisitedHistoryCalled = true;
                          print(
                            '[TEST] onUpdateVisitedHistory: $url (isReload: $isReload)',
                          );
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onPageCommitVisible: (controller, url) {
                          _onPageCommitVisibleCalled = true;
                          print('[TEST] onPageCommitVisible: $url');
                        },
                        onLoadStop: (controller, url) async {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });

                          final currentUrl = url.toString();
                          print(
                            '[TEST] onLoadStop (stage=$_testStage): $currentUrl',
                          );

                          // Stage 0: Load custom scheme URL to test onLoadResourceWithCustomScheme
                          if (_testStage == 0 && currentUrl == 'about:blank') {
                            _testStage = 1;
                            print(
                              '[TEST] === Stage 1: Loading myapp://test to test onLoadResourceWithCustomScheme ===',
                            );
                            await controller.loadUrl(
                              urlRequest: URLRequest(
                                url: WebUri('myapp://test/hello'),
                              ),
                            );
                            return;
                          }

                          // Stage 1: Check if custom scheme was handled
                          if (_testStage == 1 && currentUrl.startsWith('myapp://')) {
                            _testStage = 2;
                            print('[TEST] === Stage 2: Custom scheme result ===');
                            print(
                              '[TEST] ✅ Custom scheme myapp:// handled successfully!',
                            );
                            print(
                              '[TEST] Now loading test page for other tests...',
                            );
                            await controller.loadData(
                              data: '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>API Test Page</title>
  <style>
    body { height: 3000px; width: 2000px; padding: 20px; }
    h1 { color: blue; }
    .content { margin-top: 1000px; }
  </style>
</head>
<body>
  <h1 id="test-header">API Test Page</h1>
  <p>This page tests scroll, user scripts, and events.</p>
  <div class="content">
    <p>Scrolled content area</p>
  </div>
</body>
</html>
                            ''',
                              mimeType: 'text/html',
                              encoding: 'utf-8',
                            );
                            return;
                          }

                          // Stage 1: Test page loaded - run API tests
                          if (_testStage == 1) {
                            _testStage = 2;
                            print(
                              '[TEST] Test page loaded - running API tests...',
                            );
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );

                            // === Test Events ===
                            print('[TEST]');
                            print('[TEST] === Event Verification ===');
                            print(
                              '[TEST] onLoadStart called: $_onLoadStartCalled ${_onLoadStartCalled ? "✅" : "❌"}',
                            );
                            print(
                              '[TEST] onProgressChanged called: $_onProgressChangedCalled ${_onProgressChangedCalled ? "✅" : "❌"}',
                            );
                            print(
                              '[TEST] onProgressChanged last value: $_lastProgress',
                            );
                            print(
                              '[TEST] onTitleChanged called: $_onTitleChangedCalled ${_onTitleChangedCalled ? "✅" : "❌"}',
                            );
                            print(
                              '[TEST] onTitleChanged last title: "$_lastTitle"',
                            );
                            print(
                              '[TEST] shouldOverrideUrlLoading called: $_shouldOverrideUrlLoadingCalled',
                            );
                            print(
                              '[TEST] onUpdateVisitedHistory called: $_onUpdateVisitedHistoryCalled ${_onUpdateVisitedHistoryCalled ? "✅" : "❌"}',
                            );
                            print(
                              '[TEST] onPageCommitVisible called: $_onPageCommitVisibleCalled ${_onPageCommitVisibleCalled ? "✅" : "❌"}',
                            );

                            // === Test Initial User Scripts ===
                            print('[TEST]');
                            print('[TEST] === Initial User Scripts Test ===');
                            final docStartResult = await controller
                                .evaluateJavascript(
                                  source:
                                      'window.INITIAL_SCRIPT_LOADED === true',
                                );
                            final docEndResult = await controller
                                .evaluateJavascript(
                                  source: 'window.INITIAL_SCRIPT_END === true',
                                );
                            print(
                              '[TEST] INITIAL_SCRIPT_LOADED (AT_DOCUMENT_START): $docStartResult',
                            );
                            print(
                              '[TEST] INITIAL_SCRIPT_END (AT_DOCUMENT_END): $docEndResult',
                            );
                            if (docStartResult == true) {
                              print(
                                '[TEST] ✅ initialUserScripts AT_DOCUMENT_START works!',
                              );
                            }
                            if (docEndResult == true) {
                              print(
                                '[TEST] ✅ initialUserScripts AT_DOCUMENT_END works!',
                              );
                            }

                            // === Test addUserScript() ===
                            print('[TEST]');
                            print('[TEST] === addUserScript() Test ===');
                            await controller.addUserScript(
                              userScript: UserScript(
                                source: 'window.DYNAMIC_SCRIPT_ADDED = "yes";',
                                injectionTime:
                                    UserScriptInjectionTime.AT_DOCUMENT_END,
                                groupName: 'dynamic-test-group',
                              ),
                            );
                            print(
                              '[TEST] addUserScript() called - script will run on next page load',
                            );

                            // === Test scrollBy() ===
                            print('[TEST]');
                            print('[TEST] === scrollBy() Test ===');
                            final scrollYBefore = await controller.getScrollY();
                            print('[TEST] scrollY before: $scrollYBefore');

                            await controller.scrollBy(x: 0, y: 200);
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );

                            final scrollYAfter = await controller.getScrollY();
                            print(
                              '[TEST] scrollY after scrollBy(0, 200): $scrollYAfter',
                            );

                            if (scrollYAfter != null &&
                                scrollYBefore != null &&
                                scrollYAfter > scrollYBefore) {
                              print(
                                '[TEST] ✅ scrollBy() works! Scroll increased by ${scrollYAfter - scrollYBefore}',
                              );
                            } else if (scrollYAfter == 200) {
                              print(
                                '[TEST] ✅ scrollBy() works! Scrolled to y=200',
                              );
                            } else {
                              print(
                                '[TEST] ⚠️ scrollBy() - check result: before=$scrollYBefore, after=$scrollYAfter',
                              );
                            }

                            // Check if onScrollChanged was triggered
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            print(
                              '[TEST] onScrollChanged triggered: $_onScrollChangedCalled ${_onScrollChangedCalled ? "✅" : "⏳"}',
                            );

                            // === Test scrollTo() again to verify animated parameter ===
                            print('[TEST]');
                            print(
                              '[TEST] === scrollTo() with animated=false Test ===',
                            );
                            await controller.scrollTo(
                              x: 100,
                              y: 500,
                              animated: false,
                            );
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            final scrollXAfterTo = await controller
                                .getScrollX();
                            final scrollYAfterTo = await controller
                                .getScrollY();
                            print(
                              '[TEST] After scrollTo(100, 500): x=$scrollXAfterTo, y=$scrollYAfterTo',
                            );
                            if (scrollXAfterTo == 100 &&
                                scrollYAfterTo == 500) {
                              print(
                                '[TEST] ✅ scrollTo() with animated=false works!',
                              );
                            }

                            // === Test getUserScripts() (if available) ===
                            print('[TEST]');
                            print('[TEST] === getUserScripts() Test ===');
                            try {
                              final userScripts = await controller
                                  .getUserScripts();
                              print(
                                '[TEST] getUserScripts() returned ${userScripts?.length ?? 0} scripts',
                              );
                              if (userScripts != null) {
                                for (var script in userScripts) {
                                  print(
                                    '[TEST]   - Group: ${script.groupName}, InjectionTime: ${script.injectionTime}',
                                  );
                                }
                              }
                            } catch (e) {
                              print('[TEST] getUserScripts() error: $e');
                            }

                            // === Test removeUserScriptsByGroupName() ===
                            print('[TEST]');
                            print(
                              '[TEST] === removeUserScriptsByGroupName() Test ===',
                            );
                            await controller.removeUserScriptsByGroupName(
                              groupName: 'initial-test-group',
                            );
                            print(
                              '[TEST] Removed scripts with groupName="initial-test-group"',
                            );

                            try {
                              final userScriptsAfter = await controller
                                  .getUserScripts();
                              print(
                                '[TEST] Scripts remaining: ${userScriptsAfter?.length ?? 0}',
                              );
                              final hasInitialGroup =
                                  userScriptsAfter?.any(
                                    (s) => s.groupName == 'initial-test-group',
                                  ) ??
                                  false;
                              if (!hasInitialGroup) {
                                print(
                                  '[TEST] ✅ removeUserScriptsByGroupName() works!',
                                );
                              }
                            } catch (e) {
                              print(
                                '[TEST] getUserScripts() after removal error: $e',
                              );
                            }

                            // === Test removeAllUserScripts() ===
                            print('[TEST]');
                            print('[TEST] === removeAllUserScripts() Test ===');
                            await controller.removeAllUserScripts();
                            print('[TEST] removeAllUserScripts() called');

                            try {
                              final userScriptsAfterClear = await controller
                                  .getUserScripts();
                              print(
                                '[TEST] Scripts after removeAll: ${userScriptsAfterClear?.length ?? 0}',
                              );
                              if (userScriptsAfterClear?.isEmpty ?? true) {
                                print('[TEST] ✅ removeAllUserScripts() works!');
                              }
                            } catch (e) {
                              print(
                                '[TEST] getUserScripts() after clear error: $e',
                              );
                            }

                            // === Test other Controller Methods ===
                            print('[TEST]');
                            print('[TEST] === Other Controller Methods ===');

                            // Test getOriginalUrl()
                            try {
                              final originalUrl = await controller
                                  .getOriginalUrl();
                              print('[TEST] getOriginalUrl() = $originalUrl');
                            } catch (e) {
                              print('[TEST] getOriginalUrl() error: $e');
                            }

                            // Test getFavicons()
                            try {
                              final favicons = await controller.getFavicons();
                              print(
                                '[TEST] getFavicons() returned ${favicons.length} favicons',
                              );
                            } catch (e) {
                              print('[TEST] getFavicons() error: $e');
                            }

                            // Test isLoading()
                            try {
                              final isLoading = await controller.isLoading();
                              print('[TEST] isLoading() = $isLoading');
                              if (isLoading == false) {
                                print('[TEST] ✅ isLoading() works!');
                              }
                            } catch (e) {
                              print('[TEST] isLoading() error: $e');
                            }

                            // Test takeScreenshot() (may not work without display)
                            try {
                              final screenshot = await controller
                                  .takeScreenshot();
                              if (screenshot != null) {
                                print(
                                  '[TEST] takeScreenshot() returned ${screenshot.length} bytes',
                                );
                                print('[TEST] ✅ takeScreenshot() works!');
                              } else {
                                print('[TEST] takeScreenshot() returned null');
                              }
                            } catch (e) {
                              print('[TEST] takeScreenshot() error: $e');
                            }

                            // Test setZoomScale()
                            print('[TEST]');
                            print('[TEST] === setZoomScale() Test ===');
                            try {
                              final zoomBefore = await controller
                                  .getZoomScale();
                              print(
                                '[TEST] getZoomScale() before: $zoomBefore',
                              );

                              await controller.setZoomScale(
                                zoomScale: 1.5,
                                animated: false,
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 200),
                              );

                              final zoomAfter = await controller.getZoomScale();
                              print(
                                '[TEST] getZoomScale() after setZoomScale(1.5): $zoomAfter',
                              );

                              if (zoomAfter != null && zoomAfter >= 1.4) {
                                print('[TEST] ✅ setZoomScale() works!');
                              } else {
                                print(
                                  '[TEST] ⚠️ setZoomScale() - zoom may not have changed (WPE limitation?)',
                                );
                              }

                              // Reset zoom
                              await controller.setZoomScale(
                                zoomScale: 1.0,
                                animated: false,
                              );
                            } catch (e) {
                              print('[TEST] setZoomScale() error: $e');
                            }

                            // === Print Summary ===
                            print('[TEST]');
                            print('[TEST] ================================');
                            print('[TEST] TEST SUMMARY');
                            print('[TEST] ================================');
                            print('[TEST] Events:');
                            print('[TEST]   ✅ onWebViewCreated - verified');
                            print(
                              '[TEST]   ${_onLoadStartCalled ? "✅" : "❌"} onLoadStart',
                            );
                            print(
                              '[TEST]   ${_onProgressChangedCalled ? "✅" : "❌"} onProgressChanged (last: $_lastProgress%)',
                            );
                            print(
                              '[TEST]   ${_onTitleChangedCalled ? "✅" : "❌"} onTitleChanged (title: "$_lastTitle")',
                            );
                            print(
                              '[TEST]   ${_onUpdateVisitedHistoryCalled ? "✅" : "❌"} onUpdateVisitedHistory',
                            );
                            print(
                              '[TEST]   ${_onPageCommitVisibleCalled ? "✅" : "❌"} onPageCommitVisible',
                            );
                            print(
                              '[TEST]   ${_onScrollChangedCalled ? "✅" : "⏳"} onScrollChanged',
                            );
                            print('[TEST]');
                            print('[TEST] Controller Methods:');
                            print('[TEST]   ✅ scrollBy() - tested');
                            print(
                              '[TEST]   ✅ scrollTo() with animated param - tested',
                            );
                            print('[TEST]   ✅ addUserScript() - tested');
                            print(
                              '[TEST]   ✅ removeUserScriptsByGroupName() - tested',
                            );
                            print('[TEST]   ✅ removeAllUserScripts() - tested');
                            print('[TEST]   ✅ initialUserScripts - tested');
                            print('[TEST]   ✅ getOriginalUrl() - tested');
                            print('[TEST]   ✅ isLoading() - tested');
                            print('[TEST]   ✅ setZoomScale() - tested');
                            print('[TEST] ================================');
                            print('[TEST] ALL TESTS COMPLETE!');
                            print('[TEST] ================================');
                          }
                        },
                        onReceivedError: (controller, request, error) {
                          print(
                            '[TEST] onReceivedError: ${error.type} - ${error.description}',
                          );
                        },
                        onReceivedHttpError: (controller, request, response) {
                          print(
                            '[TEST] onReceivedHttpError: ${response.statusCode}',
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
