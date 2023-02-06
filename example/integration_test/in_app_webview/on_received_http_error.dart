import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onReceivedHttpError() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('onReceivedHttpError', (WidgetTester tester) async {
    final Completer<String> errorUrlCompleter = Completer<String>();
    final Completer<int> statusCodeCompleter = Completer<int>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_404),
          onReceivedHttpError: (controller, request, errorResponse) async {
            errorUrlCompleter.complete(request.url.toString());
            statusCodeCompleter.complete(errorResponse.statusCode);
          },
        ),
      ),
    );

    final String url = await errorUrlCompleter.future;
    final int code = await statusCodeCompleter.future;

    expect(url, TEST_URL_404.toString());
    expect(code, 404);
  }, skip: shouldSkip);
}
