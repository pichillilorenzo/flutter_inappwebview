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
                    javaScriptBridgeEnabled: true
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

