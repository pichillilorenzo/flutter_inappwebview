import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

void handlesURLScheme() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  test('handlesURLScheme', () async {
    expect(await InAppWebViewController.handlesURLScheme("http"), true);
    expect(await InAppWebViewController.handlesURLScheme("https"), true);
  }, skip: shouldSkip);
}
