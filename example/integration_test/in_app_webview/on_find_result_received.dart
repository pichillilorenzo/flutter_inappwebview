import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

void onFindResultReceived() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('onFindResultReceived', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<int> numberOfMatchesCompleter = Completer<int>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_initial_file_test.html",
          initialSettings: InAppWebViewSettings(
            clearCache: true,
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onFindResultReceived: (controller, int activeMatchOrdinal,
              int numberOfMatches, bool isDoneCounting) async {
            if (isDoneCounting && !numberOfMatchesCompleter.isCompleted) {
              numberOfMatchesCompleter.complete(numberOfMatches);
            }
          },
        ),
      ),
    );

    var controller = await controllerCompleter.future;
    await pageLoaded.future;

    await tester.pump();

    await controller.findAllAsync(find: "InAppWebViewInitialFileTest");
    final int numberOfMatches = await numberOfMatchesCompleter.future;
    expect(numberOfMatches, 2);
  }, skip: shouldSkip);
}
