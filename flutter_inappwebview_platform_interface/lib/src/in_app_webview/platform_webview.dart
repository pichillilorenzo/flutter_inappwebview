import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import '../find_interaction/platform_find_interaction_controller.dart';
import '../pull_to_refresh/platform_pull_to_refresh_controller.dart';
import '../context_menu/context_menu.dart';
import '../types/main.dart';
import '../web_uri.dart';
import 'in_app_webview_settings.dart';
import 'platform_inappwebview_controller.dart';
import '../print_job/main.dart';
import 'platform_inappwebview_widget.dart';
import 'platform_headless_in_app_webview.dart';
import '../platform_webview_feature.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams}
///Class that represents a WebView. Used by [PlatformInAppWebViewWidget],
///[PlatformHeadlessInAppWebView] and the WebView of [PlatformInAppBrowser].
///{@endtemplate}
class PlatformWebViewCreationParams<T> {
  final T Function(PlatformInAppWebViewController controller)?
      controllerFromPlatform;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId}
  ///The window id of a [CreateWindowAction.windowId].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final int? windowId;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebViewCreated}
  ///Event fired when the `WebView` is created.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  final void Function(T controller)? onWebViewCreated;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStart}
  ///Event fired when the `WebView` starts to load an [url].
  ///
  ///**NOTE for Web**: it will be dispatched at the same time of [onLoadStop] event
  ///because there isn't any way to capture the real load start event from an iframe.
  ///If `window.location.href` isn't accessible inside the iframe,
  ///the [url] parameter will have the current value of the `iframe.src` attribute.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageStarted](https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.add_NavigationStarting](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationstarting))
  ///{@endtemplate}
  final void Function(T controller, WebUri? url)? onLoadStart;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStop}
  ///Event fired when the `WebView` finishes loading an [url].
  ///
  ///**NOTE for Web**: If `window.location.href` isn't accessible inside the iframe,
  ///the [url] parameter will have the current value of the `iframe.src` attribute.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageFinished](https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview))
  ///- Web ([Official API - Window.onload](https://developer.mozilla.org/en-US/docs/Web/API/Window/load_event))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationCompleted](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted))
  ///{@endtemplate}
  final void Function(T controller, WebUri? url)? onLoadStop;

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  final void Function(T controller, Uri? url, int code, String message)?
      onLoadError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedError}
  ///Event fired when the `WebView` encounters an [error] loading a [request].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceError)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationCompleted](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted))
  ///{@endtemplate}
  final void Function(
          T controller, WebResourceRequest request, WebResourceError error)?
      onReceivedError;

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  final void Function(
          T controller, Uri? url, int statusCode, String description)?
      onLoadHttpError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpError}
  ///Event fired when the `WebView` receives an HTTP error.
  ///
  ///[request] represents the originating request.
  ///
  ///[errorResponse] represents the information about the error occurred.
  ///
  ///**NOTE**: available on Android 23+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedHttpError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- Windows ([Official API - ICoreWebView2.add_NavigationCompleted](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted))
  ///{@endtemplate}
  final void Function(T controller, WebResourceRequest request,
      WebResourceResponse errorResponse)? onReceivedHttpError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProgressChanged}
  ///Event fired when the current [progress] of loading a page is changed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onProgressChanged](https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)))
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  final void Function(T controller, int progress)? onProgressChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onConsoleMessage}
  ///Event fired when the `WebView` receives a [ConsoleMessage].
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onConsoleMessage](https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)))
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  final void Function(T controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldOverrideUrlLoading}
  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///Note that on Android there isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
  ///However, if you want to cancel requests for subframes, you can use the [InAppWebViewSettings.regexToCancelSubFramesLoading] setting
  ///to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
  ///
  ///Also, on Android, this event is not called for POST requests.
  ///
  ///[navigationAction] represents an object that contains information about an action that causes navigation to occur.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldOverrideUrlLoading] setting to `true`.
  ///Also, on Android this event is not called on the first page load.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.shouldOverrideUrlLoading](https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview))
  ///{@endtemplate}
  final FutureOr<NavigationActionPolicy?> Function(
          T controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResource}
  ///Event fired when the `WebView` loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnLoadResource] and [InAppWebViewSettings.javaScriptEnabled] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final void Function(T controller, LoadedResource resource)? onLoadResource;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScrollChanged}
  ///Event fired when the `WebView` scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented with using JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onScrollChanged](https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)))
  ///- iOS ([Official API - UIScrollViewDelegate.scrollViewDidScroll](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll))
  ///- Web ([Official API - Window.onscroll](https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onscroll))
  ///- MacOS
  ///{@endtemplate}
  final void Function(T controller, int x, int y)? onScrollChanged;

  ///Use [onDownloadStarting] instead
  @Deprecated('Use onDownloadStarting instead')
  final void Function(T controller, Uri url)? onDownloadStart;

  ///Use [onDownloadStarting] instead
  @Deprecated('Use onDownloadStarting instead')
  final void Function(T controller, DownloadStartRequest downloadStartRequest)?
      onDownloadStartRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStarting}
  ///Event fired when `WebView` recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[downloadStartRequest] represents the request of the file to download.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnDownloadStart] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.setDownloadListener](https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)))
  ///- iOS
  ///- MacOS
  ///- Windows ([Official API - ICoreWebView2_4.add_DownloadStarting](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_4?view=webview2-1.0.2849.39#add_downloadstarting))
  ///{@endtemplate}
  final FutureOr<DownloadStartResponse?> Function(
          T controller, DownloadStartRequest downloadStartRequest)?
      onDownloadStarting;

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  final FutureOr<CustomSchemeResponse?> Function(T controller, Uri url)?
      onLoadResourceCustomScheme;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme}
  ///Event fired when the `WebView` finds the `custom-scheme` while loading a resource.
  ///Here you can handle the url [request] and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKURLSchemeHandler](https://developer.apple.com/documentation/webkit/wkurlschemehandler))
  ///- MacOS ([Official API - WKURLSchemeHandler](https://developer.apple.com/documentation/webkit/wkurlschemehandler))
  ///- Windows
  ///{@endtemplate}
  final FutureOr<CustomSchemeResponse?> Function(
      T controller, WebResourceRequest request)? onLoadResourceWithCustomScheme;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCreateWindow}
  ///Event fired when the `WebView` requests the host application to create a new window,
  ///for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
  ///If the host application chooses to honor this request, it should return `true` from this method, create a new WebView to host the window.
  ///If the host application chooses not to honor the request, it should return `false` from this method.
  ///The default implementation of this method does nothing and hence returns `false`.
  ///
  ///- [createWindowAction] represents the request.
  ///
  ///**NOTE**: to allow JavaScript to open windows, you need to set [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically] setting to `true`.
  ///
  ///**NOTE for Android**: you need to set [InAppWebViewSettings.supportMultipleWindows] setting to `true`.
  ///Also, if the request has been created using JavaScript (`window.open()`), then there are some limitation: check the [NavigationAction] class.
  ///
  ///**NOTE for iOS and MacOS**: setting these initial options: [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
  ///[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
  ///[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
  ///[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
  ///[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
  ///[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
  ///[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
  ///[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
  ///[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
  ///[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
  ///will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
  ///with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
  ///So, these options will be inherited from the caller WebView.
  ///Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
  ///it will update also the WebView options of the caller WebView.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin. It works only for `window.open()` javascript calls.
  ///Also, there is no way to block the opening the window in a synchronous way, so returning `true` will just close it quickly.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onCreateWindow](https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.add_NewWindowRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_newwindowrequested))
  ///{@endtemplate}
  final FutureOr<bool?> Function(
      T controller, CreateWindowAction createWindowAction)? onCreateWindow;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCloseWindow}
  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onCloseWindow](https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)))
  ///- iOS ([Official API - WKUIDelegate.webViewDidClose](https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose))
  ///- MacOS ([Official API - WKUIDelegate.webViewDidClose](https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose))
  ///- Windows ([Official API - ICoreWebView2.add_WindowCloseRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_windowcloserequested))
  ///{@endtemplate}
  final void Function(T controller)? onCloseWindow;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowFocus}
  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` JavaScript event applied to the `window` object.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web ([Official API - Window.onfocus](https://developer.mozilla.org/en-US/docs/Web/API/Window/focus_event))
  ///{@endtemplate}
  final void Function(T controller)? onWindowFocus;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowBlur}
  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` JavaScript event applied to the `window` object.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web ([Official API - Window.onblur](https://developer.mozilla.org/en-US/docs/Web/API/Window/blur_event))
  ///{@endtemplate}
  final void Function(T controller)? onWindowBlur;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsAlert}
  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsAlert](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview))
  ///{@endtemplate}
  final FutureOr<JsAlertResponse?> Function(
      T controller, JsAlertRequest jsAlertRequest)? onJsAlert;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsConfirm}
  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsConfirm](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview))
  ///{@endtemplate}
  final FutureOr<JsConfirmResponse?> Function(
      T controller, JsConfirmRequest jsConfirmRequest)? onJsConfirm;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsPrompt}
  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsPrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)))
  ///- iOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview))
  ///- MacOS ([Official API - WKUIDelegate.webView](https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview))
  ///{@endtemplate}
  final FutureOr<JsPromptResponse?> Function(
      T controller, JsPromptRequest jsPromptRequest)? onJsPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpAuthRequest}
  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [URLAuthenticationChallenge].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedHttpAuthRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- Windows ([Official API - ICoreWebView2_10.add_BasicAuthenticationRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_10?view=webview2-1.0.2849.39#add_basicauthenticationrequested))
  ///{@endtemplate}
  final FutureOr<HttpAuthResponse?> Function(
          T controller, HttpAuthenticationChallenge challenge)?
      onReceivedHttpAuthRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest}
  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///
  ///**NOTE for iOS and macOS**: to override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
  ///See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1)
  ///for details.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedSslError](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- Windows ([Official API - ICoreWebView2_14.add_ServerCertificateErrorDetected](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#add_servercertificateerrordetected))
  ///{@endtemplate}
  final FutureOr<ServerTrustAuthResponse?> Function(
          T controller, ServerTrustChallenge challenge)?
      onReceivedServerTrustAuthRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedClientCertRequest}
  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedClientCertRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview))
  ///- Windows ([Official API - ICoreWebView2_5.add_ClientCertificateRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_5?view=webview2-1.0.2849.39#add_clientcertificaterequested))
  ///{@endtemplate}
  final FutureOr<ClientCertResponse?> Function(
      T controller, ClientCertChallenge challenge)? onReceivedClientCertRequest;

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  final void Function(T controller, int activeMatchOrdinal, int numberOfMatches,
      bool isDoneCounting)? onFindResultReceived;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptAjaxRequest}
  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///Due to the async nature of this event implementation, it will intercept only async `XMLHttpRequest`s ([AjaxRequest.isAsync] with `true`).
  ///To be able to intercept sync `XMLHttpRequest`s, use [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] to `false`.
  ///If necessary, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final FutureOr<AjaxRequest?> Function(T controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxReadyStateChange}
  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///Due to the async nature of this event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final FutureOr<AjaxRequestAction?> Function(
      T controller, AjaxRequest ajaxRequest)? onAjaxReadyStateChange;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxProgress}
  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final FutureOr<AjaxRequestAction?> Function(
      T controller, AjaxRequest ajaxRequest)? onAjaxProgress;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptFetchRequest}
  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptFetchRequest] setting to `true`.
  ///Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept fetch requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the fetch requests will be intercept for sure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final FutureOr<FetchRequest?> Function(
      T controller, FetchRequest fetchRequest)? shouldInterceptFetchRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onUpdateVisitedHistory}
  ///Event fired when the host application updates its visited links database.
  ///This event is also fired when the navigation state of the `WebView` changes through the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event
  ///or, also, when the javascript `window.location` changes without reloading the webview (for example appending or modifying a hash to the url).
  ///
  ///[url] represents the url being visited.
  ///
  ///[isReload] indicates if this url is being reloaded. Available only on Android.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.doUpdateVisitedHistory](https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)))
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.add_HistoryChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_historychanged))
  ///{@endtemplate}
  final void Function(T controller, WebUri? url, bool? isReload)?
      onUpdateVisitedHistory;

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  final void Function(T controller, Uri? url)? onPrint;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrintRequest}
  ///Event fired when `window.print()` is called from JavaScript side.
  ///Return `true` if you want to handle the print job.
  ///Otherwise return `false`, so the [PlatformPrintJobController] will be handled and disposed automatically by the system.
  ///
  ///[url] represents the url on which is called.
  ///
  ///[printJobController] represents the controller of the print job created.
  ///**NOTE**: on Web, it is always `null`
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  final FutureOr<bool?> Function(T controller, WebUri? url,
      PlatformPrintJobController? printJobController)? onPrintRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLongPressHitTestResult}
  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.setOnLongClickListener](https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)))
  ///- iOS ([Official API - UILongPressGestureRecognizer](https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer))
  ///{@endtemplate}
  final void Function(T controller, InAppWebViewHitTestResult hitTestResult)?
      onLongPressHitTestResult;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onEnterFullscreen}
  ///Event fired when the current page has entered full screen mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onShowCustomView](https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)))
  ///- iOS ([Official API - UIWindow.didBecomeVisibleNotification](https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification))
  ///- MacOS ([Official API - NSWindow.didEnterFullScreenNotification](https://developer.apple.com/documentation/appkit/nswindow/1419651-didenterfullscreennotification))
  ///- Web ([Official API - Document.onfullscreenchange](https://developer.mozilla.org/en-US/docs/Web/API/Document/fullscreenchange_event))
  ///{@endtemplate}
  final void Function(T controller)? onEnterFullscreen;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onExitFullscreen}
  ///Event fired when the current page has exited full screen mode.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onHideCustomView](https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()))
  ///- iOS ([Official API - UIWindow.didBecomeHiddenNotification](https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification))
  ///- MacOS ([Official API - NSWindow.didExitFullScreenNotification](https://developer.apple.com/documentation/appkit/nswindow/1419177-didexitfullscreennotification))
  ///- Web ([Official API - Document.onfullscreenchange](https://developer.mozilla.org/en-US/docs/Web/API/Document/fullscreenchange_event))
  ///{@endtemplate}
  final void Function(T controller)? onExitFullscreen;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPageCommitVisible}
  ///Called when the web view begins to receive web content.
  ///
  ///This event occurs early in the document loading process, and as such
  ///you should expect that linked resources (for example, CSS and images) may not be available.
  ///
  ///[url] represents the URL corresponding to the page navigation that triggered this callback.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onPageCommitVisible](https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)))
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview))
  ///{@endtemplate}
  final void Function(T controller, WebUri? url)? onPageCommitVisible;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onTitleChanged}
  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedTitle](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)))
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows ([Official API - ICoreWebView2.add_DocumentTitleChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_documenttitlechanged))
  ///{@endtemplate}
  final void Function(T controller, String? title)? onTitleChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onOverScrolled}
  ///Event fired to respond to the results of an over-scroll operation.
  ///
  ///[x] represents the new X scroll value in pixels.
  ///
  ///[y] represents the new Y scroll value in pixels.
  ///
  ///[clampedX] is `true` if [x] was clamped to an over-scroll boundary.
  ///
  ///[clampedY] is `true` if [y] was clamped to an over-scroll boundary.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onOverScrolled](https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)))
  ///- iOS
  ///{@endtemplate}
  final void Function(T controller, int x, int y, bool clampedX, bool clampedY)?
      onOverScrolled;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onZoomScaleChanged}
  ///Event fired when the zoom scale of the WebView has changed.
  ///
  ///[oldScale] The old zoom scale factor.
  ///
  ///[newScale] The new zoom scale factor.
  ///
  ///**NOTE for Web**: this event will be called only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onScaleChanged](https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)))
  ///- iOS ([Official API - UIScrollViewDelegate.scrollViewDidZoom](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom))
  ///- Web
  ///- Windows ([Official API - ICoreWebView2Controller.add_ZoomFactorChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_zoomfactorchanged))
  ///{@endtemplate}
  final void Function(T controller, double oldScale, double newScale)?
      onZoomScaleChanged;

  ///Use [onSafeBrowsingHit] instead.
  @Deprecated("Use onSafeBrowsingHit instead")
  final FutureOr<SafeBrowsingResponse?> Function(
          T controller, Uri url, SafeBrowsingThreat? threatType)?
      androidOnSafeBrowsingHit;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSafeBrowsingHit}
  ///Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android 27+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onSafeBrowsingHit](https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)))
  ///{@endtemplate}
  final FutureOr<SafeBrowsingResponse?> Function(
          T controller, WebUri url, SafeBrowsingThreat? threatType)?
      onSafeBrowsingHit;

  ///Use [onPermissionRequest] instead.
  @Deprecated("Use onPermissionRequest instead")
  final FutureOr<PermissionRequestResponse?> Function(
          T controller, String origin, List<String> resources)?
      androidOnPermissionRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequest}
  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[permissionRequest] represents the permission request with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+. The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].
  ///
  ///**NOTE for MacOS**: available only on iOS 12.0+. The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onPermissionRequest](https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)))
  ///- iOS
  ///- MacOS
  ///- Windows ([Official API - ICoreWebView2.add_PermissionRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_permissionrequested))
  ///{@endtemplate}
  final FutureOr<PermissionResponse?> Function(
      T controller, PermissionRequest permissionRequest)? onPermissionRequest;

  ///Use [onGeolocationPermissionsShowPrompt] instead.
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  final FutureOr<GeolocationPermissionShowPromptResponse?> Function(
      T controller, String origin)? androidOnGeolocationPermissionsShowPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt}
  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onGeolocationPermissionsShowPrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)))
  ///{@endtemplate}
  final FutureOr<GeolocationPermissionShowPromptResponse?> Function(
      T controller, String origin)? onGeolocationPermissionsShowPrompt;

  ///Use [onGeolocationPermissionsHidePrompt] instead.
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  final void Function(T controller)? androidOnGeolocationPermissionsHidePrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt}
  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [onGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onGeolocationPermissionsHidePrompt](https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()))
  ///{@endtemplate}
  final void Function(T controller)? onGeolocationPermissionsHidePrompt;

  ///Use [shouldInterceptRequest] instead.
  @Deprecated("Use shouldInterceptRequest instead")
  final FutureOr<WebResourceResponse?> Function(
      T controller, WebResourceRequest request)? androidShouldInterceptRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptRequest}
  ///Notify the host application of a resource request and allow the application to return the data.
  ///If the return value is `null`, the WebView will continue to load the resource as usual.
  ///Otherwise, the return response and data will be used.
  ///
  ///This event is invoked for a variety of URL schemes (e.g., `http(s):`, `data:`, `file:`, etc.),
  ///not only those schemes which send requests over the network.
  ///This is not called for `javascript:` URLs, `blob:` URLs, or for assets accessed via `file:///android_asset/` or `file:///android_res/` URLs.
  ///
  ///In the case of redirects, this is only called for the initial resource URL, not any subsequent redirect URLs.
  ///
  ///[request] Object containing the details of the request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useShouldInterceptRequest] option to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.shouldInterceptRequest](https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)))
  ///- Windows ([ICoreWebView2.add_WebResourceRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2478.35#add_webresourcerequested))
  ///{@endtemplate}
  final FutureOr<WebResourceResponse?> Function(
      T controller, WebResourceRequest request)? shouldInterceptRequest;

  ///Use [onRenderProcessUnresponsive] instead.
  @Deprecated("Use onRenderProcessUnresponsive instead")
  final FutureOr<WebViewRenderProcessAction?> Function(T controller, Uri? url)?
      androidOnRenderProcessUnresponsive;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessUnresponsive}
  ///Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript.
  ///
  ///If a WebView fails to process an input event, or successfully navigate to a new URL within a reasonable time frame, the renderer is considered to be unresponsive, and this callback will be called.
  ///
  ///This callback will continue to be called at regular intervals as long as the renderer remains unresponsive.
  ///If the renderer becomes responsive again, [onRenderProcessResponsive] will be called once,
  ///and this method will not subsequently be called unless another period of unresponsiveness is detected.
  ///
  ///The minimum interval between successive calls to [onRenderProcessUnresponsive] is 5 seconds.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///Applications may choose to terminate the associated renderer via the object that is passed to this callback,
  ///if in multiprocess mode, however this must be accompanied by correctly handling [onRenderProcessGone] for this WebView,
  ///and all other WebViews associated with the same renderer. Failure to do so will result in application termination.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewRenderProcessClient.onRenderProcessUnresponsive](https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)))
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  ///{@endtemplate}
  final FutureOr<WebViewRenderProcessAction?> Function(
      T controller, WebUri? url)? onRenderProcessUnresponsive;

  ///Use [onRenderProcessResponsive] instead.
  @Deprecated("Use onRenderProcessResponsive instead")
  final FutureOr<WebViewRenderProcessAction?> Function(T controller, Uri? url)?
      androidOnRenderProcessResponsive;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessResponsive}
  ///Event called once when an unresponsive renderer currently associated with the WebView becomes responsive.
  ///
  ///After a WebView renderer becomes unresponsive, which is notified to the application by [onRenderProcessUnresponsive],
  ///it is possible for the blocking renderer task to complete, returning the renderer to a responsive state.
  ///In that case, this method is called once to indicate responsiveness.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewRenderProcessClient.onRenderProcessResponsive](https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)))
  ///{@endtemplate}
  final FutureOr<WebViewRenderProcessAction?> Function(
      T controller, WebUri? url)? onRenderProcessResponsive;

  ///Use [onRenderProcessGone] instead.
  @Deprecated("Use onRenderProcessGone instead")
  final void Function(T controller, RenderProcessGoneDetail detail)?
      androidOnRenderProcessGone;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessGone}
  ///Event fired when the given WebView's render process has exited.
  ///The application's implementation of this callback should only attempt to clean up the WebView.
  ///The WebView should be removed from the view hierarchy, all references to it should be cleaned up.
  ///
  ///To cause an render process crash for test purpose, the application can call load url `"chrome://crash"` on the WebView.
  ///Note that multiple WebView instances may be affected if they share a render process, not just the specific WebView which loaded `"chrome://crash"`.
  ///
  ///[detail] the reason why it exited.
  ///
  ///**NOTE**: available only on Android 26+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onRenderProcessGone](https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)))
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  ///{@endtemplate}
  final void Function(T controller, RenderProcessGoneDetail detail)?
      onRenderProcessGone;

  ///Use [onFormResubmission] instead.
  @Deprecated('Use onFormResubmission instead')
  final FutureOr<FormResubmissionAction?> Function(T controller, Uri? url)?
      androidOnFormResubmission;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFormResubmission}
  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onFormResubmission](https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)))
  ///{@endtemplate}
  final FutureOr<FormResubmissionAction?> Function(T controller, WebUri? url)?
      onFormResubmission;

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use onZoomScaleChanged instead')
  final void Function(T controller, double oldScale, double newScale)?
      androidOnScaleChanged;

  ///Use [onReceivedIcon] instead.
  @Deprecated('Use onReceivedIcon instead')
  final void Function(T controller, Uint8List icon)? androidOnReceivedIcon;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedIcon}
  ///Event fired when there is new favicon for the current page.
  ///
  ///[icon] represents the favicon for the current page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedIcon](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)))
  ///{@endtemplate}
  final void Function(T controller, Uint8List icon)? onReceivedIcon;

  ///Use [onReceivedTouchIconUrl] instead.
  @Deprecated('Use onReceivedTouchIconUrl instead')
  final void Function(T controller, Uri url, bool precomposed)?
      androidOnReceivedTouchIconUrl;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedTouchIconUrl}
  ///Event fired when there is an url for an apple-touch-icon.
  ///
  ///[url] represents the icon url.
  ///
  ///[precomposed] is `true` if the url is for a precomposed touch icon.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onReceivedTouchIconUrl](https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)))
  ///{@endtemplate}
  final void Function(T controller, WebUri url, bool precomposed)?
      onReceivedTouchIconUrl;

  ///Use [onJsBeforeUnload] instead.
  @Deprecated('Use onJsBeforeUnload instead')
  final FutureOr<JsBeforeUnloadResponse?> Function(
          T controller, JsBeforeUnloadRequest jsBeforeUnloadRequest)?
      androidOnJsBeforeUnload;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsBeforeUnload}
  ///Event fired when the client should display a dialog to confirm navigation away from the current page.
  ///This is the result of the `onbeforeunload` javascript event.
  ///If [JsBeforeUnloadResponse.handledByClient] is `true`, WebView will assume that the client will handle the confirm dialog.
  ///If [JsBeforeUnloadResponse.handledByClient] is `false`, a default value of `true` will be returned to javascript to accept navigation away from the current page.
  ///The default behavior is to return `false`.
  ///Setting the [JsBeforeUnloadResponse.action] to [JsBeforeUnloadResponseAction.CONFIRM] will navigate away from the current page,
  ///[JsBeforeUnloadResponseAction.CANCEL] will cancel the navigation.
  ///
  ///[jsBeforeUnloadRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onJsBeforeUnload](https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)))
  ///{@endtemplate}
  final FutureOr<JsBeforeUnloadResponse?> Function(
          T controller, JsBeforeUnloadRequest jsBeforeUnloadRequest)?
      onJsBeforeUnload;

  ///Use [onReceivedLoginRequest] instead.
  @Deprecated('Use onReceivedLoginRequest instead')
  final void Function(T controller, LoginRequest loginRequest)?
      androidOnReceivedLoginRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedLoginRequest}
  ///Event fired when a request to automatically log in the user has been processed.
  ///
  ///[loginRequest] contains the realm, account and args of the login request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onReceivedLoginRequest](https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)))
  ///{@endtemplate}
  final void Function(T controller, LoginRequest loginRequest)?
      onReceivedLoginRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequestCanceled}
  ///Notify the host application that the given permission request has been canceled. Any related UI should therefore be hidden.
  ///
  ///[permissionRequest] represents the permission request that needs be canceled
  ///with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onPermissionRequestCanceled](https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)))
  ///{@endtemplate}
  final void Function(T controller, PermissionRequest permissionRequest)?
      onPermissionRequestCanceled;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRequestFocus}
  ///Request display and focus for this WebView.
  ///This may happen due to another WebView opening a link in this WebView and requesting that this WebView be displayed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onRequestFocus](https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)))
  ///{@endtemplate}
  final void Function(T controller)? onRequestFocus;

  ///Use [onWebContentProcessDidTerminate] instead.
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  final void Function(T controller)? iosOnWebContentProcessDidTerminate;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebContentProcessDidTerminate}
  ///Invoked when the web view's web content process is terminated.
  ///Reloading the page will start a new render process if needed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- MacOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  ///{@endtemplate}
  final void Function(T controller)? onWebContentProcessDidTerminate;

  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  final void Function(T controller)?
      iosOnDidReceiveServerRedirectForProvisionalNavigation;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation}
  ///Called when a web view receives a server redirect.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview))
  ///{@endtemplate}
  final void Function(T controller)?
      onDidReceiveServerRedirectForProvisionalNavigation;

  ///Use [onNavigationResponse] instead.
  @Deprecated('Use onNavigationResponse instead')
  final FutureOr<IOSNavigationResponseAction?> Function(
          T controller, IOSWKNavigationResponse navigationResponse)?
      iosOnNavigationResponse;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNavigationResponse}
  ///Called when a web view asks for permission to navigate to new content after the response to the navigation request is known.
  ///
  ///[navigationResponse] represents the navigation response.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewSettings.useOnNavigationResponse] setting to `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview))
  ///{@endtemplate}
  final FutureOr<NavigationResponseAction?> Function(
          T controller, NavigationResponse navigationResponse)?
      onNavigationResponse;

  ///Use [shouldAllowDeprecatedTLS] instead.
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  final FutureOr<IOSShouldAllowDeprecatedTLSAction?> Function(
          T controller, URLAuthenticationChallenge challenge)?
      iosShouldAllowDeprecatedTLS;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS}
  ///Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1).
  ///
  ///[challenge] represents the authentication challenge.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview))
  ///- MacOS ([Official API - WKNavigationDelegate.webView](https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview))
  ///{@endtemplate}
  final FutureOr<ShouldAllowDeprecatedTLSAction?> Function(
          T controller, URLAuthenticationChallenge challenge)?
      shouldAllowDeprecatedTLS;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCameraCaptureStateChanged}
  ///Event fired when a change in the camera capture state occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final FutureOr<void> Function(
    T controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onCameraCaptureStateChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged}
  ///Event fired when a change in the microphone capture state occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 12.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final FutureOr<void> Function(
    T controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onMicrophoneCaptureStateChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentSizeChanged}
  ///Event fired when the content size of the `WebView` changes.
  ///
  ///[oldContentSize] represents the old content size value.
  ///
  ///[newContentSize] represents the new content size value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///{@endtemplate}
  final void Function(T controller, Size oldContentSize, Size newContentSize)?
      onContentSizeChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProcessFailed}
  ///Invoked when any of the processes in the WebView Process Group encounters one of the following conditions:
  ///- Unexpected exit: The process indicated by the event args has exited unexpectedly (usually due to a crash).
  ///The failure might or might not be recoverable and some failures are auto-recoverable.
  ///- Unresponsiveness: The process indicated by the event args has become unresponsive to user input.
  ///This is only reported for renderer processes, and will run every few seconds until the process becomes responsive again.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2.add_ProcessFailed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed))
  ///{@endtemplate}
  final void Function(T controller, ProcessFailedDetail detail)?
      onProcessFailed;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAcceleratorKeyPressed}
  ///This event runs when an accelerator key or key combo is pressed or
  ///released while the WebView is focused.
  ///To listen this event, [InAppWebViewSettings.handleAcceleratorKeyPressed] must be `true`.
  ///
  ///A key is considered an accelerator if either of the following conditions are `true`:
  ///- `Ctrl` or `Alt` is currently being held.
  ///- The pressed key does not map to a character.
  ///
  ///A few specific keys are never considered accelerators, such as `Shift`.
  ///The `Escape` key is always considered an accelerator.
  ///
  ///Auto-repeated key events caused by holding the key down also triggers this event.
  ///Filter out the auto-repeated key events by verifying the [AcceleratorKeyPressedDetail.physicalKeyStatus] property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2Controller.add_AcceleratorKeyPressed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_acceleratorkeypressed))
  ///{@endtemplate}
  final void Function(T controller, AcceleratorKeyPressedDetail detail)?
      onAcceleratorKeyPressed;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onShowFileChooser}
  ///Tell the client to show a file chooser.
  ///This is called to handle HTML forms with 'file' input type,
  ///in response to the user pressing the "Select File" button.
  ///To cancel the request, return a [ShowFileChooserResponse] with [ShowFileChooserResponse.filePaths] to `null`.
  ///
  ///Note that the WebView does not enforce any restrictions on the chosen file(s).
  ///WebView can access all files that your app can access.
  ///In case the file(s) are chosen through an untrusted source such as a third-party app,
  ///it is your own app's responsibility to check what the returned Uris refer
  ///to.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onShowFileChooser](https://developer.android.com/reference/android/webkit/WebChromeClient#onShowFileChooser(android.webkit.WebView,%20android.webkit.ValueCallback%3Candroid.net.Uri[]%3E,%20android.webkit.WebChromeClient.FileChooserParams)))
  ///{@endtemplate}
  final FutureOr<ShowFileChooserResponse?> Function(T controller, ShowFileChooserRequest request)? onShowFileChooser;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUrlRequest}
  ///Initial url request that will be loaded.
  ///
  ///**NOTE for Android**: when loading an URL Request using "POST" method, headers are ignored.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  final URLRequest? initialUrlRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialFile}
  ///Initial asset file that will be loaded. See [InAppWebViewController.loadFile] for explanation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  final String? initialFile;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialData}
  ///Initial [InAppWebViewInitialData] that will be loaded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  final InAppWebViewInitialData? initialData;

  ///Use [initialSettings] instead.
  @Deprecated('Use initialSettings instead')
  final InAppWebViewGroupOptions? initialOptions;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialSettings}
  ///Initial settings that will be used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  final InAppWebViewSettings? initialSettings;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu}
  ///Context menu which contains custom menu items to be shown when [ContextMenu] is presented.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///{@endtemplate}
  final ContextMenu? contextMenu;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts}
  ///Initial list of user scripts to be loaded at start or end of a page loading.
  ///To add or remove user scripts, you have to use the [InAppWebViewController]'s methods such as [InAppWebViewController.addUserScript],
  ///[InAppWebViewController.removeUserScript], [InAppWebViewController.removeAllUserScripts], etc.
  ///
  ///**NOTE for iOS**: this property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to iOS window WebViews.
  ///This is a limitation of the native iOS WebKit APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  ///{@endtemplate}
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController}
  ///Represents the pull-to-refresh feature controller.
  ///
  ///**NOTE for Android**: to be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///{@endtemplate}
  final PlatformPullToRefreshController? pullToRefreshController;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController}
  ///Represents the find interaction feature controller.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  final PlatformFindInteractionController? findInteractionController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams}
  const PlatformWebViewCreationParams(
      {this.controllerFromPlatform,
      this.windowId,
      this.onWebViewCreated,
      this.onLoadStart,
      this.onLoadStop,
      @Deprecated('Use onReceivedError instead') this.onLoadError,
      this.onReceivedError,
      @Deprecated("Use onReceivedHttpError instead") this.onLoadHttpError,
      this.onReceivedHttpError,
      this.onProgressChanged,
      this.onConsoleMessage,
      this.shouldOverrideUrlLoading,
      this.onLoadResource,
      this.onScrollChanged,
      @Deprecated('Use onDownloadStarting instead') this.onDownloadStart,
      @Deprecated('Use onDownloadStarting instead') this.onDownloadStartRequest,
      this.onDownloadStarting,
      @Deprecated('Use onLoadResourceWithCustomScheme instead')
      this.onLoadResourceCustomScheme,
      this.onLoadResourceWithCustomScheme,
      this.onCreateWindow,
      this.onCloseWindow,
      this.onJsAlert,
      this.onJsConfirm,
      this.onJsPrompt,
      this.onReceivedHttpAuthRequest,
      this.onReceivedServerTrustAuthRequest,
      this.onReceivedClientCertRequest,
      @Deprecated('Use FindInteractionController.onFindResultReceived instead')
      this.onFindResultReceived,
      this.shouldInterceptAjaxRequest,
      this.onAjaxReadyStateChange,
      this.onAjaxProgress,
      this.shouldInterceptFetchRequest,
      this.onUpdateVisitedHistory,
      @Deprecated("Use onPrintRequest instead") this.onPrint,
      this.onPrintRequest,
      this.onLongPressHitTestResult,
      this.onEnterFullscreen,
      this.onExitFullscreen,
      this.onPageCommitVisible,
      this.onTitleChanged,
      this.onWindowFocus,
      this.onWindowBlur,
      this.onOverScrolled,
      this.onZoomScaleChanged,
      @Deprecated('Use onSafeBrowsingHit instead')
      this.androidOnSafeBrowsingHit,
      this.onSafeBrowsingHit,
      @Deprecated('Use onPermissionRequest instead')
      this.androidOnPermissionRequest,
      this.onPermissionRequest,
      @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
      this.androidOnGeolocationPermissionsShowPrompt,
      this.onGeolocationPermissionsShowPrompt,
      @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
      this.androidOnGeolocationPermissionsHidePrompt,
      this.onGeolocationPermissionsHidePrompt,
      @Deprecated('Use shouldInterceptRequest instead')
      this.androidShouldInterceptRequest,
      this.shouldInterceptRequest,
      @Deprecated('Use onRenderProcessGone instead')
      this.androidOnRenderProcessGone,
      this.onRenderProcessGone,
      @Deprecated('Use onRenderProcessResponsive instead')
      this.androidOnRenderProcessResponsive,
      this.onRenderProcessResponsive,
      @Deprecated('Use onRenderProcessUnresponsive instead')
      this.androidOnRenderProcessUnresponsive,
      this.onRenderProcessUnresponsive,
      @Deprecated('Use onFormResubmission instead')
      this.androidOnFormResubmission,
      this.onFormResubmission,
      @Deprecated('Use onZoomScaleChanged instead') this.androidOnScaleChanged,
      @Deprecated('Use onReceivedIcon instead') this.androidOnReceivedIcon,
      this.onReceivedIcon,
      @Deprecated('Use onReceivedTouchIconUrl instead')
      this.androidOnReceivedTouchIconUrl,
      this.onReceivedTouchIconUrl,
      @Deprecated('Use onJsBeforeUnload instead') this.androidOnJsBeforeUnload,
      this.onJsBeforeUnload,
      @Deprecated('Use onReceivedLoginRequest instead')
      this.androidOnReceivedLoginRequest,
      this.onReceivedLoginRequest,
      this.onPermissionRequestCanceled,
      this.onRequestFocus,
      @Deprecated('Use onWebContentProcessDidTerminate instead')
      this.iosOnWebContentProcessDidTerminate,
      this.onWebContentProcessDidTerminate,
      @Deprecated(
          'Use onDidReceiveServerRedirectForProvisionalNavigation instead')
      this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      this.onDidReceiveServerRedirectForProvisionalNavigation,
      @Deprecated('Use onNavigationResponse instead')
      this.iosOnNavigationResponse,
      this.onNavigationResponse,
      @Deprecated('Use shouldAllowDeprecatedTLS instead')
      this.iosShouldAllowDeprecatedTLS,
      this.shouldAllowDeprecatedTLS,
      this.onCameraCaptureStateChanged,
      this.onMicrophoneCaptureStateChanged,
      this.onContentSizeChanged,
      this.onProcessFailed,
      this.onAcceleratorKeyPressed,
      this.onShowFileChooser,
      this.initialUrlRequest,
      this.initialFile,
      this.initialData,
      @Deprecated('Use initialSettings instead') this.initialOptions,
      this.initialSettings,
      this.contextMenu,
      this.initialUserScripts,
      this.pullToRefreshController,
      this.findInteractionController});
}
