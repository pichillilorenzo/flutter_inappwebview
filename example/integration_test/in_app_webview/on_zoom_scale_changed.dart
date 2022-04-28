import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onZoomScaleChanged() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  testWidgets('onZoomScaleChanged', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> onZoomScaleChangedCompleter = Completer<void>();

    var listenForScaleChange = false;

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
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onZoomScaleChanged: (controller, oldScale, newScale) {
            if (listenForScaleChange) {
              onZoomScaleChangedCompleter.complete();
            }
          },
        ),
      ),
    );

    final InAppWebViewController controller =
    await controllerCompleter.future;
    await pageLoaded.future;
    listenForScaleChange = true;

    await controller.zoomBy(zoomFactor: 2);

    await expectLater(onZoomScaleChangedCompleter.future, completes);
  }, skip: shouldSkip);
}
