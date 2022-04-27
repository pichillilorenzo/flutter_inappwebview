import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onLoadError() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  group('onLoadError', () {
    testWidgets('invalid url', (WidgetTester tester) async {
      final Completer<String> errorUrlCompleter = Completer<String>();
      final Completer<int> errorCodeCompleter = Completer<int>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_NOT_A_WEBSITE_URL),
            onLoadError: (controller, url, code, message) {
              errorUrlCompleter.complete(url.toString());
              errorCodeCompleter.complete(code);
            },
          ),
        ),
      );

      final String url = await errorUrlCompleter.future;
      final int code = await errorCodeCompleter.future;

      if (defaultTargetPlatform == TargetPlatform.android) {
        expect(code, -2);
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        expect(code, -1003);
      }
      expect(url, TEST_NOT_A_WEBSITE_URL.toString());
    });

    testWidgets('event is not called with valid url',
        (WidgetTester tester) async {
      final Completer<String> errorUrlCompleter = Completer<String>();
      final Completer<int> errorCodeCompleter = Completer<int>();
      final Completer<String> errorMessageCompleter = Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+')),
            onLoadError: (controller, url, code, message) {
              errorUrlCompleter.complete(url.toString());
              errorCodeCompleter.complete(code);
              errorMessageCompleter.complete(message);
            },
          ),
        ),
      );

      expect(errorUrlCompleter.future, doesNotComplete);
      expect(errorCodeCompleter.future, doesNotComplete);
      expect(errorMessageCompleter.future, doesNotComplete);
    });
  }, skip: shouldSkip);
}
