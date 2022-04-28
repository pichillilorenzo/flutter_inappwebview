import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onProgressChanged() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  testWidgets('onProgressChanged', (WidgetTester tester) async {
    final Completer<void> onProgressChangedCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
              URLRequest(url: TEST_URL_1),
          initialSettings: InAppWebViewSettings(
            clearCache: true,
          ),
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              onProgressChangedCompleter.complete();
            }
          },
        ),
      ),
    );
    await expectLater(onProgressChangedCompleter.future, completes);
  }, skip: shouldSkip);
}
