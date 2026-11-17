import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Apple reply transport is opt-in and survives settings round trips', () {
    expect(InAppWebViewSettings().useScriptMessageHandlerWithReply, isFalse);
    expect(
      InAppWebViewSettings().toMap()['useScriptMessageHandlerWithReply'],
      isFalse,
    );
    for (final enabled in [false, true]) {
      final initial = InAppWebViewSettings(
        useScriptMessageHandlerWithReply: enabled,
        javaScriptHandlersForMainFrameOnly: true,
        javaScriptHandlersOriginAllowList: {'^https://allowed.example\$'},
      );
      final restored = InAppWebViewSettings.fromMap(initial.toMap())!;
      expect(restored.useScriptMessageHandlerWithReply, enabled);
      expect(restored.javaScriptHandlersForMainFrameOnly, isTrue);
      expect(
        restored.javaScriptHandlersOriginAllowList,
        initial.javaScriptHandlersOriginAllowList,
      );
    }
    // Older clients omit the optional key; native implementations default OFF.
    expect(
      InAppWebViewSettings.fromMap({})!.useScriptMessageHandlerWithReply,
      isNull,
    );
  });
}
