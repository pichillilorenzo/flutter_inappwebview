import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
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
        onFindResultReceived: (
          controller,
          activeMatchOrdinal,
          numberOfMatches,
          isDoneCounting,
        ) {
        },
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
                          url: WebUri("about:blank"),
                        ),
                        initialSettings: settings,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
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
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
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
                        onPageCommitVisible: (controller, url) {
                        },
                        onLoadStop: (controller, url) async {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onReceivedError: (controller, request, error) {
                        },
                        onReceivedHttpError: (controller, request, response) {
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
