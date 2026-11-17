@TestOn('browser')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_web/src/in_app_webview/in_app_webview.dart';
import 'package:flutter_inappwebview_web/web/in_app_web_view_web_element.dart';
import 'package:flutter_inappwebview_web/web/in_app_webview_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    for (final element in InAppWebViewManager.webViews.values.toList()) {
      element.dispose();
    }
    InAppWebViewManager.webViews.clear();
  });

  InAppWebViewWebElement createElement(WidgetTester tester, int id) {
    final element = InAppWebViewWebElement(
      viewId: id,
      messenger: tester.binding.defaultBinaryMessenger,
    );
    InAppWebViewManager.webViews[id] = element;
    web.document.body!.append(element.iframeContainer);
    return element;
  }

  Future<void> attachController(
    WidgetTester tester,
    WebPlatformInAppWebViewWidget widget,
    int id,
  ) async {
    late HtmlElementView platformView;
    // Exercise the real creation callback without registering another platform
    // view: the browser host element above already owns this view ID.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            platformView = widget.build(context) as HtmlElementView;
            return const SizedBox();
          },
        ),
      ),
    );
    platformView.onPlatformViewCreated!(id);
  }

  testWidgets('widget disposal releases its host and preserves a peer', (
    tester,
  ) async {
    final closing = createElement(tester, 63);
    final peer = createElement(tester, 64)..windowId = null;
    final widget = WebPlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams(),
    );
    await attachController(tester, widget, 63);

    widget.dispose();
    widget.dispose();

    expect(InAppWebViewManager.webViews.containsKey(63), isFalse);
    expect(closing.iframeContainer.isConnected, isFalse);
    expect(closing.jsWebView, isNull);
    expect(InAppWebViewManager.webViews[64], same(peer));
    expect(peer.iframeContainer.isConnected, isTrue);
  });

  testWidgets('keep-alive widget disposal preserves its host', (tester) async {
    final element = createElement(tester, 65);
    final widget = WebPlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams(
        keepAlive: InAppWebViewKeepAlive(),
      ),
    );
    await attachController(tester, widget, 65);

    widget.dispose();

    expect(InAppWebViewManager.webViews[65], same(element));
    expect(element.iframeContainer.isConnected, isTrue);
  });

  test('disposal before platform view creation is harmless', () {
    final widget = WebPlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams(),
    );
    widget.dispose();
    widget.dispose();
    expect(InAppWebViewManager.webViews, isEmpty);
  });
}
