import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void loadUrl() {
  final shouldSkip = !kIsWeb || ![
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);

  group('load url', () {
    final shouldSkipTest1 = !kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

    testWidgets('loadUrl', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
      StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
            URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );
      final InAppWebViewController controller =
      await controllerCompleter.future;
      var url = await pageLoads.stream.first;
      expect(url, TEST_CROSS_PLATFORM_URL_1.toString());

      await controller.loadUrl(
          urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_2));
      url = await pageLoads.stream.first;
      expect(url, TEST_CROSS_PLATFORM_URL_2.toString());

      pageLoads.close();
    }, skip: shouldSkipTest1);

    final shouldSkipTest2 = kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

    testWidgets('loadUrl with headers', (WidgetTester tester) async {
      final Completer controllerCompleter = Completer<InAppWebViewController>();
      final StreamController<String> pageStarts =
      StreamController<String>.broadcast();
      final StreamController<String> pageLoads =
      StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest:
            URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true
            ),
            onLoadStart: (controller, url) {
              pageStarts.add(url!.toString());
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );
      final InAppWebViewController controller =
      await controllerCompleter.future;
      final Map<String, String> headers = <String, String>{
        'test_header': 'flutter_test_header'
      };
      await controller.loadUrl(
          urlRequest: URLRequest(
              url: Uri.parse('https://flutter-header-echo.herokuapp.com/'),
              headers: headers));
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, 'https://flutter-header-echo.herokuapp.com/');

      await pageStarts.stream.firstWhere((String url) => url == currentUrl);
      await pageLoads.stream.firstWhere((String url) => url == currentUrl);

      final String? content = await controller.evaluateJavascript(
          source: 'document.documentElement.innerText');
      expect(content!.contains('flutter_test_header'), isTrue);

      pageStarts.close();
      pageLoads.close();
    }, skip: shouldSkipTest2);
  }, skip: shouldSkip);
}