import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records which platform widget created the native view and which ones were
/// disposed.
class _FakePlatform extends InAppWebViewPlatform {
  _FakePlatform({this.createsViewLater = false});

  /// Whether the view is created the way iOS, macOS, Windows and Linux create
  /// it: asynchronously, by whichever platform widget is current when
  /// [completeViewCreation] is called, instead of the way Android does it:
  /// synchronously, by the first platform widget built.
  final bool createsViewLater;

  final disposed = <_FakeWidget>[];
  VoidCallback? _pendingCreation;
  _FakeWidget? viewCreator;

  void completeViewCreation() => _pendingCreation?.call();

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) => _FakeWidget(params, platform: this);

  @override
  PlatformPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) => _FakePullToRefreshController(params);
}

/// Readies its params' controllers when the native view is created for it, and
/// disposes them along with itself, like the platform implementations do.
class _FakeWidget extends PlatformInAppWebViewWidget {
  _FakeWidget(super.params, {required this.platform}) : super.implementation();

  final _FakePlatform platform;

  @override
  Widget build(BuildContext context) =>
      _ViewLink(onCreate: _onViewCreated, platform: platform);

  void _onViewCreated() {
    platform.viewCreator = this;
    notifyNativeViewCreated();
    (params.pullToRefreshController as _FakePullToRefreshController?)?.init();
  }

  @override
  void dispose() {
    platform.disposed.add(this);
    params.pullToRefreshController?.dispose();
  }

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      controller as T;
}

class _FakePullToRefreshController extends PlatformPullToRefreshController
    with ChannelController {
  _FakePullToRefreshController(super.params) : super.implementation();

  void init() {
    channel = const MethodChannel('pull_to_refresh_test');
    handler = (call) async {};
    initMethodCallHandler();
  }

  @override
  void dispose({bool isKeepAlive = false}) =>
      disposeChannel(removeMethodCallHandler: !isKeepAlive);
}

/// Creates the view once and keeps it across every rebuild after that, like
/// Android's `PlatformViewLink` or, when the view is created later, like
/// `UiKitView`, which reads its creation callback from its current widget
/// once creation completes.
class _ViewLink extends StatefulWidget {
  const _ViewLink({required this.onCreate, required this.platform});

  final VoidCallback onCreate;
  final _FakePlatform platform;

  @override
  State<_ViewLink> createState() => _ViewLinkState();
}

class _ViewLinkState extends State<_ViewLink> {
  @override
  void initState() {
    super.initState();
    if (widget.platform.createsViewLater) {
      widget.platform._pendingCreation = () => widget.onCreate();
    } else {
      widget.onCreate();
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets(
    'a webview rebuilt after its view exists releases that view and its latest build only when it goes',
    (tester) async {
      final platform = _FakePlatform();
      InAppWebViewPlatform.instance = platform;

      await tester.pumpWidget(InAppWebView());
      final creator = platform.viewCreator;
      await tester.pumpWidget(InAppWebView());
      await tester.pumpWidget(InAppWebView());
      final latest = tester.widget<InAppWebView>(find.byType(InAppWebView));
      await tester.pumpWidget(const SizedBox.shrink());

      expect(creator, isNotNull);
      expect(platform.disposed, [creator, latest.platform]);
    },
  );

  testWidgets(
    'a webview rebuilt while its view is being created releases that view and its latest build only when it goes',
    (tester) async {
      final platform = _FakePlatform(createsViewLater: true);
      InAppWebViewPlatform.instance = platform;

      await tester.pumpWidget(InAppWebView());
      await tester.pumpWidget(InAppWebView());
      platform.completeViewCreation();
      final creator = platform.viewCreator;
      await tester.pumpWidget(InAppWebView());
      await tester.pumpWidget(InAppWebView());
      final latest = tester.widget<InAppWebView>(find.byType(InAppWebView));
      await tester.pumpWidget(const SizedBox.shrink());

      expect(creator, isNotNull);
      expect(platform.disposed, [creator, latest.platform]);
    },
  );

  testWidgets(
    'a webview never rebuilt releases the view it created when it goes',
    (tester) async {
      final platform = _FakePlatform();
      InAppWebViewPlatform.instance = platform;

      await tester.pumpWidget(InAppWebView());
      await tester.pumpWidget(const SizedBox.shrink());

      expect(platform.disposed, [platform.viewCreator]);
    },
  );

  testWidgets(
    'a webview rebuilt with the same pull-to-refresh controller releases it when it goes',
    (tester) async {
      InAppWebViewPlatform.instance = _FakePlatform();
      final pullToRefresh = PullToRefreshController();

      await tester.pumpWidget(
        InAppWebView(pullToRefreshController: pullToRefresh),
      );
      await tester.pumpWidget(
        InAppWebView(pullToRefreshController: pullToRefresh),
      );
      await tester.pumpWidget(const SizedBox.shrink());

      expect(
        (pullToRefresh.platform as _FakePullToRefreshController).disposed,
        isTrue,
      );
    },
  );
}
