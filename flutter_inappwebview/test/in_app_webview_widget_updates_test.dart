import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// Simulates a platform view whose asynchronous creation and controller belong
// to the delegate that first built it, just like a native platform view.
class _Delegate extends PlatformInAppWebViewWidget {
  _Delegate(super.params, {this.created}) : super.implementation();

  final Completer<void>? created;
  PlatformInAppWebViewWidgetCreationParams get current => widgetParams;
  final Object controller = Object();
  int creations = 0;
  int disposals = 0;
  bool ready = false;

  void scroll(int x, int y) {
    if (ready) current.onScrollChanged?.call(controller, x, y);
  }

  @override
  Widget build(BuildContext context) => _NativeView(delegate: this);

  @override
  void dispose() => disposals++;

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();
}

class _NativeView extends StatefulWidget {
  const _NativeView({required this.delegate});
  final _Delegate delegate;

  @override
  State<_NativeView> createState() => _NativeViewState();
}

class _NativeViewState extends State<_NativeView> {
  @override
  void initState() {
    super.initState();
    final owner = widget.delegate;
    owner.creations++;
    if (owner.created != null) {
      owner.created!.future.then((_) => owner.ready = true);
    } else {
      owner.ready = true;
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: widget.delegate.current.layoutDirection ?? TextDirection.ltr,
    child: const SizedBox(),
  );
}

void main() {
  testWidgets('updates null → A → B → null on the same controller and owner', (
    tester,
  ) async {
    final events = <String>[];
    final delegates = <_Delegate>[];
    Future<void> pump(void Function(dynamic, int, int)? callback) async {
      final delegate = _Delegate(
        PlatformInAppWebViewWidgetCreationParams(onScrollChanged: callback),
      );
      delegates.add(delegate);
      await tester.pumpWidget(InAppWebView.fromPlatform(platform: delegate));
    }

    await pump(null);
    final owner = delegates.first;
    owner.scroll(1, 2);
    await pump((controller, x, y) {
      expect(controller, same(owner.controller));
      events.add('A:$x,$y');
    });
    owner.scroll(3, 4);
    await pump((controller, x, y) {
      expect(controller, same(owner.controller));
      events.add('B:$x,$y');
    });
    owner.scroll(5, 6);
    await pump(null);
    owner.scroll(7, 8);
    expect(events, ['A:3,4', 'B:5,6']);
    expect(owner.creations, 1);
    expect(
      delegates.skip(1).map((delegate) => delegate.creations),
      everyElement(0),
    );

    await tester.pumpWidget(const SizedBox());
    expect(owner.disposals, 1);
    expect(
      delegates.skip(1).map((delegate) => delegate.disposals),
      everyElement(0),
    );
  });

  testWidgets('a rebuild before native creation retains the latest listener', (
    tester,
  ) async {
    final created = Completer<void>();
    final events = <String>[];
    final owner = _Delegate(
      PlatformInAppWebViewWidgetCreationParams(
        onScrollChanged: (_, x, y) => events.add('old'),
      ),
      created: created,
    );
    await tester.pumpWidget(InAppWebView.fromPlatform(platform: owner));
    await tester.pumpWidget(
      InAppWebView.fromPlatform(
        platform: _Delegate(
          PlatformInAppWebViewWidgetCreationParams(
            onScrollChanged: (_, x, y) => events.add('new:$x,$y'),
          ),
        ),
      ),
    );
    created.complete();
    await tester.pump();
    owner.scroll(9, 10);
    expect(events, ['new:9,10']);
    expect(owner.creations, 1);
  });

  testWidgets('rebuild parameters change without replacing creation settings', (
    tester,
  ) async {
    final settings = InAppWebViewSettings(javaScriptEnabled: false);
    final keepAlive = InAppWebViewKeepAlive();
    final owner = _Delegate(
      PlatformInAppWebViewWidgetCreationParams(
        initialSettings: settings,
        keepAlive: keepAlive,
        layoutDirection: TextDirection.ltr,
      ),
    );
    await tester.pumpWidget(InAppWebView.fromPlatform(platform: owner));
    final gestures = <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
    };
    await tester.pumpWidget(
      InAppWebView.fromPlatform(
        platform: _Delegate(
          PlatformInAppWebViewWidgetCreationParams(
            initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
            layoutDirection: TextDirection.rtl,
            gestureRecognizers: gestures,
          ),
        ),
      ),
    );
    expect(owner.current.layoutDirection, TextDirection.rtl);
    expect(owner.current.gestureRecognizers, same(gestures));
    expect(owner.params.initialSettings, same(settings));
    expect(owner.params.keepAlive, same(keepAlive));
    expect(owner.creations, 1);
    expect(
      tester.widget<Directionality>(find.byType(Directionality)).textDirection,
      TextDirection.rtl,
    );
    await tester.pumpWidget(const SizedBox());
    expect(owner.disposals, 1);
  });
}
