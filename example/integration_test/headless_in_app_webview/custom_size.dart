import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void customSize() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  test('set and get custom size', () async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      initialSize: Size(600, 800),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
    );

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final Size? size = await headlessWebView.getSize();
    expect(size, isNotNull);
    expect(size, Size(600, 800));

    await headlessWebView.setSize(Size(1080, 1920));
    final Size? newSize = await headlessWebView.getSize();
    expect(newSize, isNotNull);
    expect(newSize, Size(1080, 1920));

    await headlessWebView.dispose();

    expect(headlessWebView.isRunning(), false);
  }, skip: shouldSkip);
}
