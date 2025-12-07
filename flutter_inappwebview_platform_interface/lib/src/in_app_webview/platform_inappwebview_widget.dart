import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import '../webview_environment/platform_webview_environment.dart';
import 'in_app_webview_keep_alive.dart';
import 'platform_headless_in_app_webview.dart';
import 'platform_inappwebview_controller.dart';
import 'platform_webview.dart';

part 'platform_inappwebview_widget.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams}
///Object specifying creation parameters for creating a [PlatformInAppWebViewWidget].
///
///Platform specific implementations can add additional fields by extending
///this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
  WebPlatform(requiresSameOrigin: false),
  WindowsPlatform(),
])
class PlatformInAppWebViewWidgetCreationParams
    extends PlatformWebViewCreationParams {
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
  PlatformInAppWebViewWidgetCreationParams(
      {this.key,
      this.layoutDirection,
      this.gestureRecognizers,
      this.headlessWebView,
      this.keepAlive,
      this.preventGestureDelay,
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

  /// Controls how one widget replaces another widget in the tree.
  ///
  /// See also:
  ///
  ///  * The discussions at [Key] and [GlobalKey].
  final Key? key;

  /// The layout direction to use for the embedded WebView.
  final TextDirection? layoutDirection;

  /// The `gestureRecognizers` specifies which gestures should be consumed by the
  /// web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web
  /// view on pointer events, e.g. if the web view is inside a [ListView] the
  /// [ListView] will want to handle vertical drags. The web view will claim
  /// gestures that are recognized by any of the recognizers on this list.
  ///
  /// When `gestureRecognizers` is empty (default), the web view will only handle
  /// pointer events for gestures that were not claimed by any other gesture
  /// recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.headlessWebView}
  ///The [PlatformHeadlessInAppWebView] to use to initialize this widget.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.keepAlive.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(requiresSameOrigin: false),
    WindowsPlatform(),
  ])
  final PlatformHeadlessInAppWebView? headlessWebView;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.keepAlive}
  ///Used to keep alive this WebView.
  ///Remember to dispose the [InAppWebViewKeepAlive] instance
  ///using [InAppWebViewController.disposeKeepAlive].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.keepAlive.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ])
  final InAppWebViewKeepAlive? keepAlive;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.webViewEnvironment}
  ///Used to prevent gesture delay on iOS caused by Flutter's gestures handling
  ///between native/platform views.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.webViewEnvironment.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
  ])
  final bool? preventGestureDelay;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.webViewEnvironment}
  ///Used to create the [PlatformInAppWebViewWidget] using the specified environment.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.webViewEnvironment.supported_platforms}
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  final PlatformWebViewEnvironment? webViewEnvironment;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  @override
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformInAppWebViewWidgetCreationParamsClassSupported.isClassSupported(
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///The property should be one of the [PlatformWebViewCreationParamsProperty] or [PlatformInAppWebViewWidgetCreationParamsProperty] values.
  ///{@endtemplate}
  @override
  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      property is PlatformWebViewCreationParamsProperty
          ? super.isPropertySupported(property, platform: platform)
          : _PlatformInAppWebViewWidgetCreationParamsPropertySupported
              .isPropertySupported(property, platform: platform);
}

///Interface for a platform implementation of a web view widget.
///
///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.supported_platforms}
abstract class PlatformInAppWebViewWidget extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformInAppWebViewWidget]
  factory PlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppWebViewWidget webViewWidgetDelegate =
        InAppWebViewPlatform.instance!.createPlatformInAppWebViewWidget(params);
    PlatformInterface.verify(webViewWidgetDelegate, _token);
    return webViewWidgetDelegate;
  }

  /// Creates a new [PlatformInAppWebViewWidget] to access static methods.
  factory PlatformInAppWebViewWidget.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppWebViewWidget inAppWebViewWidgetStatic =
        InAppWebViewPlatform.instance!.createPlatformInAppWebViewWidgetStatic();
    PlatformInterface.verify(inAppWebViewWidgetStatic, _token);
    return inAppWebViewWidgetStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformInAppWebViewWidget].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInAppWebViewWidget.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformInAppWebViewWidget].
  final PlatformInAppWebViewWidgetCreationParams params;

  /// Builds a new WebView.
  ///
  /// Returns a Widget tree that embeds the created web view.
  Widget build(BuildContext context);

  /// Gets the `InAppWebViewController` instance controller
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.isPropertySupported}
  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      params.isPropertySupported(property, platform: platform);

  @override
  void dispose();
}
