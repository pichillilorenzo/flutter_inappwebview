import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_linux/src/in_app_webview/custom_platform_view.dart';

const IN_APP_WEBVIEW_STATIC_CHANNEL = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);

const int _kTextureId = 1;
const MethodChannel _viewChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_$_kTextureId',
);
const EventChannel _viewEventChannel = EventChannel(
  'com.pichillilorenzo/custom_platform_view_${_kTextureId}_events',
);

/// Mounts its child but lays it out only once [layoutChild] is true, like a
/// kept-alive page that was built before it was ever shown.
class _DeferLayout extends SingleChildRenderObjectWidget {
  const _DeferLayout({required this.layoutChild, super.child});

  final bool layoutChild;

  @override
  _RenderDeferLayout createRenderObject(BuildContext context) =>
      _RenderDeferLayout(layoutChild);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderDeferLayout renderObject,
  ) => renderObject.layoutChild = layoutChild;
}

class _RenderDeferLayout extends RenderProxyBox {
  _RenderDeferLayout(this._layoutChild);

  bool _layoutChild;
  set layoutChild(bool value) {
    if (value == _layoutChild) return;
    _layoutChild = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (_layoutChild && child != null) {
      child!.layout(constraints, parentUsesSize: true);
    }
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_layoutChild) super.paint(context, offset);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_layoutChild) super.visitChildrenForSemantics(visitor);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      _layoutChild && super.hitTestChildren(result, position: position);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> viewChannelCalls;

  setUp(() {
    viewChannelCalls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
      call,
    ) async {
      if (call.method == 'createInAppWebView') {
        return _kTextureId;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewChannelCalls.add(call);
      return null;
    });
    messenger.setMockStreamHandler(
      _viewEventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, null);
    messenger.setMockMethodCallHandler(_viewChannel, null);
    messenger.setMockStreamHandler(_viewEventChannel, null);
  });

  List<List<double>> sizeCalls() => viewChannelCalls
      .where((call) => call.method == 'setSize')
      .map(
        (call) => (call.arguments as List)
            .take(2)
            .map((e) => (e as num).toDouble())
            .toList(),
      )
      .toList();

  Widget app({required bool shown}) => MaterialApp(
    home: Center(
      child: SizedBox(
        width: 320,
        height: 240,
        child: _DeferLayout(
          layoutChild: shown,
          child: const CustomPlatformView(),
        ),
      ),
    ),
  );

  testWidgets('a view first laid out after creation reports its size', (
    tester,
  ) async {
    await tester.pumpWidget(app(shown: false));
    await tester.pumpAndSettle();
    expect(sizeCalls(), isEmpty);

    await tester.pumpWidget(app(shown: true));
    await tester.pumpAndSettle();

    expect(sizeCalls(), [
      [320.0, 240.0],
    ]);
  });

  testWidgets('an unchanged layout is not reported twice', (tester) async {
    await tester.pumpWidget(app(shown: true));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(shown: true));
    await tester.pumpAndSettle();

    expect(sizeCalls(), [
      [320.0, 240.0],
    ]);
  });
}
