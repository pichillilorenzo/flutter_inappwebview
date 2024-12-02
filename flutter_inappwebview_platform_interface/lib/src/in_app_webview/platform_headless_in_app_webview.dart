import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import '../webview_environment/platform_webview_environment.dart';
import 'platform_inappwebview_controller.dart';
import 'platform_webview.dart';

/// Object specifying creation parameters for creating a [PlatformInAppWebViewWidget].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class PlatformHeadlessInAppWebViewCreationParams
    extends PlatformWebViewCreationParams {
  /// Used by the platform implementation to create a new [PlatformHeadlessInAppWebView].
  const PlatformHeadlessInAppWebViewCreationParams(
      {this.initialSize = const Size(-1, -1),
      this.webViewEnvironment,
      super.controllerFromPlatform,
      super.windowId,
      super.onWebViewCreated,
      super.onLoadStart,
      super.onLoadStop,
      @Deprecated('Use onReceivedError instead') super.onLoadError,
      super.onReceivedError,
      @Deprecated("Use onReceivedHttpError instead") super.onLoadHttpError,
      super.onReceivedHttpError,
      super.onProgressChanged,
      super.onConsoleMessage,
      super.shouldOverrideUrlLoading,
      super.onLoadResource,
      super.onScrollChanged,
      @Deprecated('Use onDownloadStarting instead') super.onDownloadStart,
      @Deprecated('Use onDownloadStarting instead')
      super.onDownloadStartRequest,
      super.onDownloadStarting,
      @Deprecated('Use onLoadResourceWithCustomScheme instead')
      super.onLoadResourceCustomScheme,
      super.onLoadResourceWithCustomScheme,
      super.onCreateWindow,
      super.onCloseWindow,
      super.onJsAlert,
      super.onJsConfirm,
      super.onJsPrompt,
      super.onReceivedHttpAuthRequest,
      super.onReceivedServerTrustAuthRequest,
      super.onReceivedClientCertRequest,
      @Deprecated('Use FindInteractionController.onFindResultReceived instead')
      super.onFindResultReceived,
      super.shouldInterceptAjaxRequest,
      super.onAjaxReadyStateChange,
      super.onAjaxProgress,
      super.shouldInterceptFetchRequest,
      super.onUpdateVisitedHistory,
      @Deprecated("Use onPrintRequest instead") super.onPrint,
      super.onPrintRequest,
      super.onLongPressHitTestResult,
      super.onEnterFullscreen,
      super.onExitFullscreen,
      super.onPageCommitVisible,
      super.onTitleChanged,
      super.onWindowFocus,
      super.onWindowBlur,
      super.onOverScrolled,
      super.onZoomScaleChanged,
      @Deprecated('Use onSafeBrowsingHit instead')
      super.androidOnSafeBrowsingHit,
      super.onSafeBrowsingHit,
      @Deprecated('Use onPermissionRequest instead')
      super.androidOnPermissionRequest,
      super.onPermissionRequest,
      @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
      super.androidOnGeolocationPermissionsShowPrompt,
      super.onGeolocationPermissionsShowPrompt,
      @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
      super.androidOnGeolocationPermissionsHidePrompt,
      super.onGeolocationPermissionsHidePrompt,
      @Deprecated('Use shouldInterceptRequest instead')
      super.androidShouldInterceptRequest,
      super.shouldInterceptRequest,
      @Deprecated('Use onRenderProcessGone instead')
      super.androidOnRenderProcessGone,
      super.onRenderProcessGone,
      @Deprecated('Use onRenderProcessResponsive instead')
      super.androidOnRenderProcessResponsive,
      super.onRenderProcessResponsive,
      @Deprecated('Use onRenderProcessUnresponsive instead')
      super.androidOnRenderProcessUnresponsive,
      super.onRenderProcessUnresponsive,
      @Deprecated('Use onFormResubmission instead')
      super.androidOnFormResubmission,
      super.onFormResubmission,
      @Deprecated('Use onZoomScaleChanged instead') super.androidOnScaleChanged,
      @Deprecated('Use onReceivedIcon instead') super.androidOnReceivedIcon,
      super.onReceivedIcon,
      @Deprecated('Use onReceivedTouchIconUrl instead')
      super.androidOnReceivedTouchIconUrl,
      super.onReceivedTouchIconUrl,
      @Deprecated('Use onJsBeforeUnload instead') super.androidOnJsBeforeUnload,
      super.onJsBeforeUnload,
      @Deprecated('Use onReceivedLoginRequest instead')
      super.androidOnReceivedLoginRequest,
      super.onReceivedLoginRequest,
      super.onPermissionRequestCanceled,
      super.onRequestFocus,
      @Deprecated('Use onWebContentProcessDidTerminate instead')
      super.iosOnWebContentProcessDidTerminate,
      super.onWebContentProcessDidTerminate,
      @Deprecated(
          'Use onDidReceiveServerRedirectForProvisionalNavigation instead')
      super.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      super.onDidReceiveServerRedirectForProvisionalNavigation,
      @Deprecated('Use onNavigationResponse instead')
      super.iosOnNavigationResponse,
      super.onNavigationResponse,
      @Deprecated('Use shouldAllowDeprecatedTLS instead')
      super.iosShouldAllowDeprecatedTLS,
      super.shouldAllowDeprecatedTLS,
      super.onCameraCaptureStateChanged,
      super.onMicrophoneCaptureStateChanged,
      super.onContentSizeChanged,
      super.onProcessFailed,
      super.onAcceleratorKeyPressed,
      super.onShowFileChooser,
      super.initialUrlRequest,
      super.initialFile,
      super.initialData,
      @Deprecated('Use initialSettings instead') super.initialOptions,
      super.initialSettings,
      super.contextMenu,
      super.initialUserScripts,
      super.pullToRefreshController,
      super.findInteractionController});

  ///The WebView initial size in pixels.
  ///
  ///Set `-1` to match the corresponding width or height of the current device screen size.
  ///`Size(-1, -1)` will match both width and height of the current device screen size.
  ///
  ///**NOTE for Android**: `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  final Size initialSize;

  ///Used to create the [PlatformHeadlessInAppWebView] using the specified environment.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  final PlatformWebViewEnvironment? webViewEnvironment;
}

///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView}
///Class that represents a WebView in headless mode.
///It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
///
///**NOTE**: Remember to dispose it when you don't need it anymore.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- Web
///- MacOS
///- Windows
///{@endtemplate}
abstract class PlatformHeadlessInAppWebView extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformHeadlessInAppWebView]
  factory PlatformHeadlessInAppWebView(
      PlatformHeadlessInAppWebViewCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformHeadlessInAppWebView webViewControllerDelegate =
        InAppWebViewPlatform.instance!
            .createPlatformHeadlessInAppWebView(params);
    PlatformInterface.verify(webViewControllerDelegate, _token);
    return webViewControllerDelegate;
  }

  /// Used by the platform implementation to create a new [PlatformHeadlessInAppWebView].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformHeadlessInAppWebView.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformHeadlessInAppWebView].
  final PlatformHeadlessInAppWebViewCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.id}
  ///View ID.
  ///{@endtemplate}
  String get id =>
      throw UnimplementedError('id is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.webViewController}
  ///WebView Controller that can be used to access the [InAppWebViewController] API.
  ///{@endtemplate}
  PlatformInAppWebViewController? get webViewController =>
      throw UnimplementedError(
          'webViewController is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.run}
  ///Runs the headless WebView.
  ///
  ///**NOTE for Web**: it will append a new `iframe` to the body.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  ///{@endtemplate}
  Future<void> run() {
    throw UnimplementedError('run is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.isRunning}
  ///Indicates if the headless WebView is running or not.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  ///{@endtemplate}
  bool isRunning() {
    throw UnimplementedError(
        'isRunning is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.setSize}
  ///Set the size of the WebView in pixels.
  ///
  ///Set `-1` to match the corresponding width or height of the current device screen size.
  ///`Size(-1, -1)` will match both width and height of the current device screen size.
  ///
  ///Note that if the [PlatformHeadlessInAppWebView] is not running, this method won't have effect.
  ///
  ///**NOTE for Android**: `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  ///{@endtemplate}
  Future<void> setSize(Size size) {
    throw UnimplementedError(
        'setSize is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.getSize}
  ///Gets the current size in pixels of the WebView.
  ///
  ///Note that if the [PlatformHeadlessInAppWebView] is not running, this method will return `null`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  ///{@endtemplate}
  Future<Size?> getSize() {
    throw UnimplementedError(
        'getSize is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.dispose}
  ///Disposes the headless WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  ///{@endtemplate}
  Future<void> dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}
