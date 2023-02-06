import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void runAndDispose() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  test('run and dispose', () async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
    );
    headlessWebView.onLoadStop = (controller, url) async {
      pageLoaded.complete();
    };

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String? url = (await controller.getUrl())?.toString();
    expect(url, TEST_CROSS_PLATFORM_URL_1.toString());

    await headlessWebView.dispose();

    expect(headlessWebView.isRunning(), false);
  }, skip: shouldSkip);
}
