import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';

void webArchive() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  group('web archive', () {
    final shouldSkipTest1 = kIsWeb
        ? true
        : ![
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform);

    testWidgets('create data', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      expect(await controller.createWebArchiveData(), isNotNull);
    }, skip: shouldSkipTest1);

    testWidgets('save', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      // wait a little bit after page load otherwise Android will not save the web archive
      await Future.delayed(Duration(seconds: 1));

      var supportDir = await getApplicationSupportDirectory();

      var fileName = "flutter-website.";
      if (defaultTargetPlatform == TargetPlatform.android) {
        fileName = fileName + WebArchiveFormat.MHT.toValue();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        fileName = fileName + WebArchiveFormat.WEBARCHIVE.toValue();
      }

      var fullPath = supportDir.path + Platform.pathSeparator + fileName;
      var path = await controller.saveWebArchive(filePath: fullPath);
      expect(path, isNotNull);
      expect(path, endsWith(fileName));

      path = await controller.saveWebArchive(
          filePath: supportDir.path, autoname: true);
      expect(path, isNotNull);
    });
  }, skip: shouldSkip);
}
