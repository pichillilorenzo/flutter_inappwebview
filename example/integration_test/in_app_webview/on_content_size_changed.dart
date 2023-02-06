import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onContentSizeChanged() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('onContentSizeChanged', (WidgetTester tester) async {
    final Completer<void> onContentSizeChangedCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onContentSizeChanged: (controller, oldContentSize, newContentSize) {
            if (!onContentSizeChangedCompleter.isCompleted) {
              onContentSizeChangedCompleter.complete();
            }
          },
        ),
      ),
    );

    await expectLater(onContentSizeChangedCompleter.future, completes);
  }, skip: shouldSkip);
}
