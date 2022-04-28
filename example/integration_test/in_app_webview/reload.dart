import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void reload() {
  final shouldSkip = !kIsWeb ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('reload', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final StreamController<String> pageLoads =
    StreamController<String>.broadcast();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: url),
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
    String? reloadUrl = await pageLoads.stream.first;
    expect(reloadUrl, url.toString());

    await controller.reload();
    reloadUrl = await pageLoads.stream.first;
    expect(reloadUrl, url.toString());

    pageLoads.close();
  }, skip: shouldSkip);
}
