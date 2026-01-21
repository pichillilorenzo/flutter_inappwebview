import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A mock InAppWebViewPlatform for testing purposes.
/// This allows widget tests to run without requiring a real platform implementation.
class MockInAppWebViewPlatform extends InAppWebViewPlatform
    with MockPlatformInterfaceMixin {
  static final MockInAppWebViewPlatform _instance =
      MockInAppWebViewPlatform._();

  MockInAppWebViewPlatform._();

  /// Initialize the mock platform for testing.
  /// Call this in setUp() or at the start of your tests.
  static void initialize() {
    InAppWebViewPlatform.instance = _instance;
  }

  /// Reset the platform instance.
  /// Call this in tearDown() to clean up after tests.
  static void reset() {
    // Note: We can't actually set instance to null, but we can leave it as the mock
    // for subsequent tests. The mock is stateless so this is fine.
  }

  @override
  PlatformInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return MockPlatformInAppWebViewControllerStatic(
      const PlatformInAppWebViewControllerCreationParams(id: 'mock_controller'),
    );
  }

  @override
  PlatformCookieManager createPlatformCookieManagerStatic() {
    return MockPlatformCookieManagerStatic(
      PlatformCookieManagerCreationParams(),
    );
  }

  @override
  PlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return MockPlatformCookieManager(params);
  }

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return MockPlatformInAppWebViewWidget(params);
  }

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    return MockPlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams(),
    );
  }

  @override
  PlatformInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return MockPlatformInAppWebViewController(params);
  }

  @override
  PlatformServiceWorkerController createPlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) {
    return MockPlatformServiceWorkerController(params);
  }

  @override
  PlatformServiceWorkerController
  createPlatformServiceWorkerControllerStatic() {
    return MockPlatformServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    );
  }

  @override
  PlatformProxyController createPlatformProxyController(
    PlatformProxyControllerCreationParams params,
  ) {
    return MockPlatformProxyController(params);
  }

  @override
  PlatformProxyController createPlatformProxyControllerStatic() {
    return MockPlatformProxyController(
      const PlatformProxyControllerCreationParams(),
    );
  }

  @override
  PlatformTracingController createPlatformTracingController(
    PlatformTracingControllerCreationParams params,
  ) {
    return MockPlatformTracingController(params);
  }

  @override
  PlatformTracingController createPlatformTracingControllerStatic() {
    return MockPlatformTracingController(
      const PlatformTracingControllerCreationParams(),
    );
  }

  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironment(
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    return MockPlatformWebViewEnvironment(params);
  }

  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironmentStatic() {
    return MockPlatformWebViewEnvironment(
      const PlatformWebViewEnvironmentCreationParams(),
    );
  }

  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfig(
    PlatformProcessGlobalConfigCreationParams params,
  ) {
    return MockPlatformProcessGlobalConfig(params);
  }

  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfigStatic() {
    return MockPlatformProcessGlobalConfig(
      const PlatformProcessGlobalConfigCreationParams(),
    );
  }

  @override
  PlatformFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return MockPlatformFindInteractionController(params);
  }

  @override
  PlatformFindInteractionController
  createPlatformFindInteractionControllerStatic() {
    return MockPlatformFindInteractionController(
      const PlatformFindInteractionControllerCreationParams(),
    );
  }

  @override
  PlatformPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    return MockPlatformPullToRefreshController(params);
  }

  @override
  PlatformPullToRefreshController
  createPlatformPullToRefreshControllerStatic() {
    return MockPlatformPullToRefreshController(
      PlatformPullToRefreshControllerCreationParams(),
    );
  }

  @override
  PlatformWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    return MockPlatformWebMessageChannel(params);
  }

  @override
  PlatformWebMessageChannel createPlatformWebMessageChannelStatic() {
    final port1 = MockPlatformWebMessagePort(
      const PlatformWebMessagePortCreationParams(index: 0),
    );
    final port2 = MockPlatformWebMessagePort(
      const PlatformWebMessagePortCreationParams(index: 1),
    );
    return MockPlatformWebMessageChannel(
      PlatformWebMessageChannelCreationParams(
        id: 'mock_channel',
        port1: port1,
        port2: port2,
      ),
    );
  }

  @override
  PlatformHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    return MockPlatformHeadlessInAppWebView(params);
  }

  @override
  PlatformHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    return MockPlatformHeadlessInAppWebView(
      const PlatformHeadlessInAppWebViewCreationParams(),
    );
  }

  @override
  PlatformInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    return MockPlatformInAppBrowser(params);
  }

  @override
  PlatformInAppBrowser createPlatformInAppBrowserStatic() {
    return MockPlatformInAppBrowser(const PlatformInAppBrowserCreationParams());
  }

  @override
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowser(
    PlatformChromeSafariBrowserCreationParams params,
  ) {
    return MockPlatformChromeSafariBrowser(params);
  }

  @override
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return MockPlatformChromeSafariBrowser(
      const PlatformChromeSafariBrowserCreationParams(),
    );
  }

  @override
  PlatformPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    return MockPlatformPrintJobController(params);
  }

  @override
  PlatformPrintJobController createPlatformPrintJobControllerStatic() {
    return MockPlatformPrintJobController(
      const PlatformPrintJobControllerCreationParams(id: 'mock_print_job'),
    );
  }

  @override
  PlatformWebAuthenticationSession createPlatformWebAuthenticationSession(
    PlatformWebAuthenticationSessionCreationParams params,
  ) {
    return MockPlatformWebAuthenticationSession(params);
  }

  @override
  PlatformWebAuthenticationSession
  createPlatformWebAuthenticationSessionStatic() {
    return MockPlatformWebAuthenticationSession(
      const PlatformWebAuthenticationSessionCreationParams(),
    );
  }

  @override
  PlatformHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return MockPlatformHttpAuthCredentialDatabase(params);
  }

  @override
  PlatformHttpAuthCredentialDatabase
  createPlatformHttpAuthCredentialDatabaseStatic() {
    return MockPlatformHttpAuthCredentialDatabase(
      const PlatformHttpAuthCredentialDatabaseCreationParams(),
    );
  }

  @override
  PlatformWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    return MockPlatformWebStorage(params);
  }

  @override
  PlatformWebStorage createPlatformWebStorageStatic() {
    final localStorage = MockPlatformLocalStorage(
      PlatformLocalStorageCreationParams(
        const PlatformStorageCreationParams(
          controller: null,
          webStorageType: WebStorageType.LOCAL_STORAGE,
        ),
      ),
    );
    final sessionStorage = MockPlatformSessionStorage(
      PlatformSessionStorageCreationParams(
        const PlatformStorageCreationParams(
          controller: null,
          webStorageType: WebStorageType.SESSION_STORAGE,
        ),
      ),
    );
    return MockPlatformWebStorage(
      PlatformWebStorageCreationParams(
        localStorage: localStorage,
        sessionStorage: sessionStorage,
      ),
    );
  }

  @override
  PlatformLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    return MockPlatformLocalStorage(params);
  }

  @override
  PlatformLocalStorage createPlatformLocalStorageStatic() {
    return MockPlatformLocalStorage(
      PlatformLocalStorageCreationParams(
        const PlatformStorageCreationParams(
          controller: null,
          webStorageType: WebStorageType.LOCAL_STORAGE,
        ),
      ),
    );
  }

  @override
  PlatformSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    return MockPlatformSessionStorage(params);
  }

  @override
  PlatformSessionStorage createPlatformSessionStorageStatic() {
    return MockPlatformSessionStorage(
      PlatformSessionStorageCreationParams(
        const PlatformStorageCreationParams(
          controller: null,
          webStorageType: WebStorageType.SESSION_STORAGE,
        ),
      ),
    );
  }
}

/// Mock static controller for testing
class MockPlatformInAppWebViewControllerStatic
    extends PlatformInAppWebViewController
    with MockPlatformInterfaceMixin {
  MockPlatformInAppWebViewControllerStatic(super.params)
    : super.implementation();

  @override
  bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) {
    // Return true for all methods in tests
    return true;
  }
}

class MockPlatformInAppWebViewController extends PlatformInAppWebViewController
    with MockPlatformInterfaceMixin {
  MockPlatformInAppWebViewController(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<void> loadUrl({
    required URLRequest urlRequest,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> stopLoading() async {}

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<bool> canGoForward() async => false;

  @override
  Future<void> goBack() async {}

  @override
  Future<void> goForward() async {}

  @override
  Future<String?> getTitle() async => 'Mock Title';

  @override
  int? getViewId() => 1;

  @override
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async => null;

  @override
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic>? arguments,
    ContentWorld? contentWorld,
  }) async => null;

  @override
  Future<void> addUserScript({required UserScript userScript}) async {}

  @override
  Future<bool> removeUserScript({required UserScript userScript}) async => true;

  @override
  Future<PlatformWebMessageChannel?> createWebMessageChannel() async {
    final port1 = MockPlatformWebMessagePort(
      const PlatformWebMessagePortCreationParams(index: 0),
    );
    final port2 = MockPlatformWebMessagePort(
      const PlatformWebMessagePortCreationParams(index: 1),
    );
    return MockPlatformWebMessageChannel(
      PlatformWebMessageChannelCreationParams(
        id: 'controller_channel',
        port1: port1,
        port2: port2,
      ),
    );
  }
}

class MockPlatformInAppWebViewWidget extends PlatformInAppWebViewWidget
    with MockPlatformInterfaceMixin {
  MockPlatformInAppWebViewWidget(super.params) : super.implementation();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    return controller as T;
  }

  @override
  void dispose() {}

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Mock static cookie manager for testing
class MockPlatformCookieManagerStatic extends PlatformCookieManager
    with MockPlatformInterfaceMixin {
  MockPlatformCookieManagerStatic(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) {
    return true;
  }
}

class MockPlatformCookieManager extends PlatformCookieManager
    with MockPlatformInterfaceMixin {
  MockPlatformCookieManager(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) => true;
}

class MockPlatformServiceWorkerController
    extends PlatformServiceWorkerController
    with MockPlatformInterfaceMixin {
  MockPlatformServiceWorkerController(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformServiceWorkerControllerMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<bool> getAllowContentAccess() async => true;

  @override
  Future<bool> getAllowFileAccess() async => true;

  @override
  Future<bool> getBlockNetworkLoads() async => false;

  @override
  Future<CacheMode?> getCacheMode() async => CacheMode.LOAD_DEFAULT;

  @override
  Future<void> setAllowContentAccess(bool value) async {}

  @override
  Future<void> setAllowFileAccess(bool value) async {}

  @override
  Future<void> setBlockNetworkLoads(bool value) async {}

  @override
  Future<void> setCacheMode(CacheMode? mode) async {}

  @override
  ServiceWorkerClient? get serviceWorkerClient => null;
}

class MockPlatformProxyController extends PlatformProxyController
    with MockPlatformInterfaceMixin {
  MockPlatformProxyController(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformProxyControllerMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<void> setProxyOverride({required ProxySettings settings}) async {}

  @override
  Future<void> clearProxyOverride() async {}
}

class MockPlatformTracingController extends PlatformTracingController
    with MockPlatformInterfaceMixin {
  MockPlatformTracingController(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformTracingControllerMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<void> start({required TracingSettings settings}) async {}

  @override
  Future<bool> stop({String? filePath}) async => true;
}

class MockPlatformWebViewEnvironment extends PlatformWebViewEnvironment
    with MockPlatformInterfaceMixin {
  MockPlatformWebViewEnvironment(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformWebViewEnvironmentMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<String?> getAvailableVersion({
    String? browserExecutableFolder,
  }) async => null;

  @override
  Future<List<BrowserProcessInfo>> getBrowserProcessInfo() async => [];
}

class MockPlatformProcessGlobalConfig extends PlatformProcessGlobalConfig
    with MockPlatformInterfaceMixin {
  MockPlatformProcessGlobalConfig(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformProcessGlobalConfigMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<void> setDataDirectorySuffix({required String suffix}) async {}
}

class MockPlatformFindInteractionController
    extends PlatformFindInteractionController
    with MockPlatformInterfaceMixin {
  MockPlatformFindInteractionController(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformFindInteractionControllerMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<void> findAll({String? find}) async {}

  @override
  Future<void> findNext({bool forward = true}) async {}

  @override
  Future<void> clearMatches() async {}

  @override
  Future<void> setSearchText(String? searchText) async {}

  @override
  Future<String?> getSearchText() async => '';

  @override
  Future<void> presentFindNavigator() async {}

  @override
  Future<void> dismissFindNavigator() async {}

  @override
  Future<bool?> isFindNavigatorVisible() async => false;

  @override
  Future<FindSession?> getActiveFindSession() async => null;

  @override
  void dispose({bool isKeepAlive = false}) {}
}

class MockPlatformPullToRefreshController
    extends PlatformPullToRefreshController
    with MockPlatformInterfaceMixin {
  bool _enabled = true;

  MockPlatformPullToRefreshController(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformPullToRefreshControllerMethod method, {
    TargetPlatform? platform,
  }) => true;

  @override
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
  }

  @override
  Future<bool> isEnabled() async => _enabled;

  @override
  Future<void> beginRefreshing() async {}

  @override
  Future<void> endRefreshing() async {}

  @override
  Future<bool> isRefreshing() async => false;

  @override
  Future<void> setColor(Color color) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<int> getDefaultSlingshotDistance() async => 0;

  @override
  void dispose({bool isKeepAlive = false}) {}
}

class MockPlatformWebMessageChannel extends PlatformWebMessageChannel
    with MockPlatformInterfaceMixin {
  MockPlatformWebMessageChannel(super.params) : super.implementation();

  @override
  PlatformWebMessagePort get port1 => params.port1;

  @override
  PlatformWebMessagePort get port2 => params.port2;

  @override
  Future<void> dispose() async {}
}

class MockPlatformWebMessagePort extends PlatformWebMessagePort
    with MockPlatformInterfaceMixin {
  MockPlatformWebMessagePort(super.params) : super.implementation();

  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {}

  @override
  Future<void> postMessage(WebMessage message) async {}

  @override
  Future<void> close() async {}

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {};

  @override
  Map<String, dynamic> toJson() => toMap();
}

class MockPlatformHeadlessInAppWebView extends PlatformHeadlessInAppWebView
    with MockPlatformInterfaceMixin {
  MockPlatformHeadlessInAppWebView(super.params) : super.implementation();

  @override
  String get id => 'mock_headless';

  @override
  PlatformInAppWebViewController? get webViewController =>
      MockPlatformInAppWebViewController(
        const PlatformInAppWebViewControllerCreationParams(
          id: 'mock_headless_controller',
        ),
      );

  @override
  Future<void> run() async {}

  @override
  bool isRunning() => false;

  @override
  Future<void> setSize(Size size) async {}

  @override
  Future<Size?> getSize() async => null;

  @override
  Future<void> dispose() async {}
}

class MockPlatformInAppBrowser extends PlatformInAppBrowser
    with MockPlatformInterfaceMixin {
  MockPlatformInAppBrowser(super.params) : super.implementation();

  @override
  String get id => 'mock_inapp_browser';

  @override
  PlatformInAppWebViewController? get webViewController =>
      MockPlatformInAppWebViewController(
        const PlatformInAppWebViewControllerCreationParams(
          id: 'mock_inapp_browser_controller',
        ),
      );

  @override
  Future<void> openUrlRequest({
    required URLRequest urlRequest,
    @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
    InAppBrowserClassSettings? settings,
  }) async {}

  @override
  Future<void> openFile({
    required String assetFilePath,
    @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
    InAppBrowserClassSettings? settings,
  }) async {}

  @override
  Future<void> openData({
    required String data,
    String mimeType = 'text/html',
    String encoding = 'utf8',
    WebUri? baseUrl,
    @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
    WebUri? historyUrl,
    @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
    InAppBrowserClassSettings? settings,
  }) async {}

  @override
  Future<void> show() async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> close() async {}

  @override
  Future<bool> isHidden() async => false;

  @override
  Future<void> setSettings({
    required InAppBrowserClassSettings settings,
  }) async {}

  @override
  Future<InAppBrowserClassSettings?> getSettings() async =>
      InAppBrowserClassSettings();

  @override
  bool isOpened() => true;

  @override
  void dispose() {
    super.dispose();
  }
}

class MockPlatformChromeSafariBrowser extends PlatformChromeSafariBrowser
    with MockPlatformInterfaceMixin {
  MockPlatformChromeSafariBrowser(super.params) : super.implementation();

  @override
  String get id => 'mock_chrome_safari_browser';

  @override
  Future<void> open({
    WebUri? url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
    @Deprecated('Use settings instead')
    ChromeSafariBrowserClassOptions? options,
    ChromeSafariBrowserSettings? settings,
  }) async {}

  @override
  Future<void> launchUrl({
    required WebUri url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
  }) async {}

  @override
  Future<bool> mayLaunchUrl({
    WebUri? url,
    List<WebUri>? otherLikelyURLs,
  }) async => true;

  @override
  Future<bool> validateRelationship({
    required CustomTabsRelationType relation,
    required WebUri origin,
  }) async => true;

  @override
  Future<void> close() async {}

  @override
  void dispose() {
    eventHandler = null;
  }
}

class MockPlatformPrintJobController extends PlatformPrintJobController
    with MockPlatformInterfaceMixin {
  MockPlatformPrintJobController(super.params) : super.implementation();

  @override
  Future<void> cancel() async {}

  @override
  Future<void> restart() async {}

  @override
  Future<void> dismiss({bool animated = true}) async {}

  @override
  Future<PrintJobInfo?> getInfo() async => null;

  @override
  void dispose() {}
}

class MockPlatformWebAuthenticationSession
    extends PlatformWebAuthenticationSession
    with MockPlatformInterfaceMixin {
  MockPlatformWebAuthenticationSession(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformWebAuthenticationSessionMethod method, {
    TargetPlatform? platform,
  }) => true;
}

class MockPlatformHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase
    with MockPlatformInterfaceMixin {
  MockPlatformHttpAuthCredentialDatabase(super.params) : super.implementation();

  @override
  bool isMethodSupported(
    PlatformHttpAuthCredentialDatabaseMethod method, {
    TargetPlatform? platform,
  }) => true;
}

class MockPlatformWebStorage extends PlatformWebStorage
    with MockPlatformInterfaceMixin {
  MockPlatformWebStorage(super.params) : super.implementation();

  @override
  PlatformLocalStorage get localStorage => params.localStorage;

  @override
  PlatformSessionStorage get sessionStorage => params.sessionStorage;
}

class MockPlatformLocalStorage extends PlatformLocalStorage
    with MockPlatformInterfaceMixin {
  MockPlatformLocalStorage(super.params) : super.implementation();

  @override
  PlatformInAppWebViewController? get controller => params.controller;

  @override
  bool isMethodSupported(
    PlatformLocalStorageMethod method, {
    TargetPlatform? platform,
  }) => true;
}

class MockPlatformSessionStorage extends PlatformSessionStorage
    with MockPlatformInterfaceMixin {
  MockPlatformSessionStorage(super.params) : super.implementation();

  @override
  PlatformInAppWebViewController? get controller => params.controller;

  @override
  bool isMethodSupported(
    PlatformSessionStorageMethod method, {
    TargetPlatform? platform,
  }) => true;
}
