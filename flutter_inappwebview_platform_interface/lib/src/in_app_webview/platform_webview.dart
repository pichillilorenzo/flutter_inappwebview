import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

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
import '../in_app_browser/platform_in_app_browser.dart';

part 'platform_webview.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams}
///Class that represents a WebView. Used by [PlatformInAppWebViewWidget],
///[PlatformHeadlessInAppWebView] and the WebView of [PlatformInAppBrowser].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
@SupportedPlatforms(
  ignoreParameterNames: ['controller'],
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(requiresSameOrigin: false),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
class PlatformWebViewCreationParams<T> {
  final T Function(PlatformInAppWebViewController controller)?
  controllerFromPlatform;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId}
  ///The window id of a [CreateWindowAction.windowId].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
    ],
  )
  final int? windowId;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebViewCreated}
  ///Event fired when the `WebView` is created.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebViewCreated.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final void Function(T controller)? onWebViewCreated;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStart}
  ///Event fired when the `WebView` starts to load an [url].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStart.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onPageStarted',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview',
      ),
      WebPlatform(
        note:
            "It will be dispatched at the same time of [onLoadStop] event because there isn't any way to capture the real load start event from an iframe. If `window.location.href` isn't accessible inside the iframe, the [url] parameter will have the current value of the `iframe.src` attribute.",
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_NavigationStarting',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationstarting',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::load-changed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.load-changed.html',
        note: 'Fired when WebKitLoadEvent is WEBKIT_LOAD_STARTED.',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onLoadStart;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStop}
  ///Event fired when the `WebView` finishes loading an [url].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStop.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onPageFinished',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview',
      ),
      WebPlatform(
        apiName: 'Window.onload',
        apiUrl:
            'https://developer.mozilla.org/en-US/docs/Web/API/Window/load_event',
        note:
            "If `window.location.href` isn't accessible inside the iframe, the [url] parameter will have the current value of the `iframe.src` attribute.",
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_NavigationCompleted',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::load-changed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.load-changed.html',
        note: 'Fired when WebKitLoadEvent is WEBKIT_LOAD_FINISHED.',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onLoadStop;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentLoading}
  ///Called when the `WebView` is about to load content for the current
  ///navigation.
  ///
  ///This fires before any content is loaded (including scripts added with
  ///`addScriptToExecuteOnDocumentCreated`), after [onLoadStart] and before
  ///[onDOMContentLoaded].
  ///
  ///This event does not fire for same-page navigations such as fragment
  ///changes or `history.pushState`.
  ///
  ///[url] represents the URL corresponding to the page navigation that
  ///triggered this callback.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentLoading.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ContentLoading',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_contentloading',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onContentLoading;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDOMContentLoaded}
  ///Called when the HTML document has been parsed and the DOM is ready.
  ///
  ///[url] represents the URL corresponding to the page navigation that
  ///triggered this callback.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDOMContentLoaded.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_2.add_DOMContentLoaded',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_2?view=webview2-1.0.2210.55#add_domcontentloaded',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onDOMContentLoaded;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadError}
  ///Use [onReceivedError] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadError.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated("Use onReceivedError instead")
  final void Function(T controller, Uri? url, int code, String message)?
  onLoadError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedError}
  ///Event fired when the `WebView` encounters an [error] loading a [request].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedError.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceError)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_NavigationCompleted',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::load-failed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.load-failed.html',
      ),
    ],
  )
  final void Function(
    T controller,
    WebResourceRequest request,
    WebResourceError error,
  )?
  onReceivedError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadHttpError}
  ///Use [onReceivedHttpError] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadHttpError.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated("Use onReceivedHttpError instead")
  final void Function(
    T controller,
    Uri? url,
    int statusCode,
    String description,
  )?
  onLoadHttpError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpError}
  ///Event fired when the `WebView` receives an HTTP error.
  ///
  ///[request] represents the originating request.
  ///
  ///[errorResponse] represents the information about the error occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpError.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedHttpError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)',
        available: '23',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_NavigationCompleted',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/iwebview2webview?view=webview2-0.8.355#add_navigationcompleted',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::load-failed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.load-failed.html',
        note:
            'HTTP errors are detected during the load-failed signal handling.',
      ),
    ],
  )
  final void Function(
    T controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  )?
  onReceivedHttpError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProgressChanged}
  ///Event fired when the current [progress] of loading a page is changed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProgressChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onProgressChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(
        apiName: 'WebKitWebView::notify::estimated-load-progress',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.WebView.estimated-load-progress.html',
      ),
    ],
  )
  final void Function(T controller, int progress)? onProgressChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onConsoleMessage}
  ///Event fired when the `WebView` receives a [ConsoleMessage].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onConsoleMessage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onConsoleMessage',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)',
      ),
      IOSPlatform(note: 'This event is implemented using JavaScript.'),
      MacOSPlatform(note: 'This event is implemented using JavaScript.'),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  final void Function(T controller, ConsoleMessage consoleMessage)?
  onConsoleMessage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldOverrideUrlLoading}
  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///[navigationAction] represents an object that contains information about an action that causes navigation to occur.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useShouldOverrideUrlLoading] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldOverrideUrlLoading.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.shouldOverrideUrlLoading',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)',
        note:
            """There isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
However, if you want to cancel requests for subframes, you can use the [InAppWebViewSettings.regexToCancelSubFramesLoading] setting
to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
Instead, the [InAppWebViewSettings.regexToAllowSyncUrlLoading] setting could
be used to allow navigation requests synchronously, as this event is synchronous on native side
and the current plugin implementation will always cancel the current request and load a new request if
this event returns [NavigationActionPolicy.ALLOW] because Flutter method channels work only asynchronously.
Also, this event is not called for POST requests and is not called on the first page load.""",
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview',
      ),
      WindowsPlatform(),
      LinuxPlatform(
        apiName: 'WebKitWebView::decide-policy',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.decide-policy.html',
      ),
    ],
  )
  final FutureOr<NavigationActionPolicy?> Function(
    T controller,
    NavigationAction navigationAction,
  )?
  shouldOverrideUrlLoading;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLaunchingExternalUriScheme}
  ///Event fired when an external URI scheme is about to be launched.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLaunchingExternalUriScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_18.add_LaunchingExternalUriScheme',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_18?view=webview2-1.0.2849.39#add_launchingexternalurischeme',
      ),
    ],
  )
  final FutureOr<LaunchingExternalUriSchemeResponse?> Function(
    T controller,
    LaunchingExternalUriSchemeRequest request,
  )?
  onLaunchingExternalUriScheme;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResource}
  ///Event fired when the `WebView` loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useOnLoadResource] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResource.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This event is implemented using JavaScript.'),
      IOSPlatform(note: 'This event is implemented using JavaScript.'),
      MacOSPlatform(note: 'This event is implemented using JavaScript.'),
      LinuxPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  final void Function(T controller, LoadedResource resource)? onLoadResource;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScrollChanged}
  ///Event fired when the `WebView` scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScrollChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onScrollChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)',
      ),
      IOSPlatform(
        apiName: 'UIScrollViewDelegate.scrollViewDidScroll',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll',
      ),
      MacOSPlatform(note: 'This event is implemented using JavaScript.'),
      WebPlatform(
        apiName: 'Window.onscroll',
        apiUrl:
            'https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onscroll',
      ),
      LinuxPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  final void Function(T controller, int x, int y)? onScrollChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStart}
  ///Use [onDownloadStarting] instead
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStart.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated('Use onDownloadStarting instead')
  final void Function(T controller, Uri url)? onDownloadStart;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStartRequest}
  ///Use [onDownloadStarting] instead
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStartRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated('Use onDownloadStarting instead')
  final void Function(T controller, DownloadStartRequest downloadStartRequest)?
  onDownloadStartRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStarting}
  ///Event fired when `WebView` recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[downloadStartRequest] represents the request of the file to download.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useOnDownloadStart] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.setDownloadListener',
        apiUrl:
            '(https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2_4.add_DownloadStarting',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_4?view=webview2-1.0.2849.39#add_downloadstarting',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::decide-policy',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.decide-policy.html',
        note:
            'Downloads are detected via WEBKIT_POLICY_DECISION_TYPE_RESPONSE.',
      ),
    ],
  )
  final FutureOr<DownloadStartResponse?> Function(
    T controller,
    DownloadStartRequest downloadStartRequest,
  )?
  onDownloadStarting;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceCustomScheme}
  ///Use [onLoadResourceWithCustomScheme] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceCustomScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  final FutureOr<CustomSchemeResponse?> Function(T controller, Uri url)?
  onLoadResourceCustomScheme;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme}
  ///Event fired when the `WebView` finds the `custom-scheme` while loading a resource.
  ///Here you can handle the url [request] and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'WKURLSchemeHandler',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkurlschemehandler',
      ),
      MacOSPlatform(
        apiName: 'WKURLSchemeHandler',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkurlschemehandler',
      ),
      WindowsPlatform(),
      LinuxPlatform(
        apiName: 'WebKitURISchemeRequest',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.URISchemeRequest.html',
      ),
    ],
  )
  final FutureOr<CustomSchemeResponse?> Function(
    T controller,
    WebResourceRequest request,
  )?
  onLoadResourceWithCustomScheme;

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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCreateWindow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onCreateWindow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)',
        note:
            'You need to set [InAppWebViewSettings.supportMultipleWindows] setting to `true`. Also, if the request has been created using JavaScript (`window.open()`), then there are some limitation: check the [NavigationAction] class.',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview',
        note:
            """Setting these initial settings [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
So, these options will be inherited from the caller WebView.
Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
it will update also the WebView options of the caller WebView.""",
      ),
      MacOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview',
        note:
            """Setting these initial settings [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
So, these options will be inherited from the caller WebView.
Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
it will update also the WebView options of the caller WebView.""",
      ),
      WebPlatform(
        note:
            'It works only for `window.open()` javascript calls. Also, there is no way to block the opening the window in a synchronous way, so returning `true` will just close it quickly.',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_NewWindowRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_newwindowrequested',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::create',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.create.html',
        note:
            'Creates a new InAppWebView with related-view for multi-window support.',
      ),
    ],
  )
  final FutureOr<bool?> Function(
    T controller,
    CreateWindowAction createWindowAction,
  )?
  onCreateWindow;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCloseWindow}
  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCloseWindow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onCloseWindow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webViewDidClose',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose',
      ),
      MacOSPlatform(
        apiName: 'WKUIDelegate.webViewDidClose',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose',
      ),
      WebPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_WindowCloseRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_windowcloserequested',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::close',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.close.html',
      ),
    ],
  )
  final void Function(T controller)? onCloseWindow;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowFocus}
  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` JavaScript event applied to the `window` object.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        apiName: 'Window.onfocus',
        apiUrl:
            'https://developer.mozilla.org/en-US/docs/Web/API/Window/focus_event',
      ),
    ],
  )
  final void Function(T controller)? onWindowFocus;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowBlur}
  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` JavaScript event applied to the `window` object.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowBlur.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        apiName: 'Window.onblur',
        apiUrl:
            'https://developer.mozilla.org/en-US/docs/Web/API/Window/blur_event',
      ),
    ],
  )
  final void Function(T controller)? onWindowBlur;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsAlert}
  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsAlert.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsAlert',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview',
      ),
      MacOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::script-dialog',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.script-dialog.html',
        note: 'Handles WEBKIT_SCRIPT_DIALOG_ALERT dialog type.',
      ),
    ],
  )
  final FutureOr<JsAlertResponse?> Function(
    T controller,
    JsAlertRequest jsAlertRequest,
  )?
  onJsAlert;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsConfirm}
  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsConfirm.onJsConfirm}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsConfirm',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview',
      ),
      MacOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::script-dialog',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.script-dialog.html',
        note: 'Handles WEBKIT_SCRIPT_DIALOG_CONFIRM dialog type.',
      ),
    ],
  )
  final FutureOr<JsConfirmResponse?> Function(
    T controller,
    JsConfirmRequest jsConfirmRequest,
  )?
  onJsConfirm;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsPrompt}
  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsPrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsPrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview',
      ),
      MacOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::script-dialog',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.script-dialog.html',
        note: 'Handles WEBKIT_SCRIPT_DIALOG_PROMPT dialog type.',
      ),
    ],
  )
  final FutureOr<JsPromptResponse?> Function(
    T controller,
    JsPromptRequest jsPromptRequest,
  )?
  onJsPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpAuthRequest}
  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [URLAuthenticationChallenge].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpAuthRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedHttpAuthRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2_10.add_BasicAuthenticationRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_10?view=webview2-1.0.2849.39#add_basicauthenticationrequested',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::authenticate',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.authenticate.html',
      ),
    ],
  )
  final FutureOr<HttpAuthResponse?> Function(
    T controller,
    HttpAuthenticationChallenge challenge,
  )?
  onReceivedHttpAuthRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest}
  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedSslError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
        note:
            """To override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details.""",
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
        note:
            """To override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details.""",
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2_14.add_ServerCertificateErrorDetected',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#add_servercertificateerrordetected',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::load-failed-with-tls-errors',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.load-failed-with-tls-errors.html',
        note:
            'Uses webkit_web_context_allow_tls_certificate_for_host() to allow proceeding with an invalid certificate.',
      ),
    ],
  )
  final FutureOr<ServerTrustAuthResponse?> Function(
    T controller,
    ServerTrustChallenge challenge,
  )?
  onReceivedServerTrustAuthRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedClientCertRequest}
  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedClientCertRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedClientCertRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2_5.add_ClientCertificateRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_5?view=webview2-1.0.2849.39#add_clientcertificaterequested',
      ),
      LinuxPlatform(
        apiName:
            'WebKitAuthenticationRequest with WEBKIT_AUTHENTICATION_SCHEME_CLIENT_CERTIFICATE_REQUESTED',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.authenticate.html',
        note:
            'WPE WebKit supports client certificate requests via the authenticate signal. '
            'Providing a certificate programmatically requires WebKit 2.34+ and the certificate must be loaded from a PEM file. '
            'PKCS12 format may not be fully supported. If the certificate cannot be loaded, PROCEED will behave like CANCEL.',
      ),
    ],
  )
  final FutureOr<ClientCertResponse?> Function(
    T controller,
    ClientCertChallenge challenge,
  )?
  onReceivedClientCertRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFindResultReceived}
  ///Use [FindInteractionController.onFindResultReceived] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFindResultReceived.supported_platforms}
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  final void Function(
    T controller,
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  )?
  onFindResultReceived;

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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptAjaxRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(
        note:
            'This event is implemented using JavaScript. In order to be able to listen to this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting documentation.',
      ),
    ],
  )
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxReadyStateChange.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(
        note:
            'This event is implemented using JavaScript. In order to be able to listen to this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings documentation.',
      ),
    ],
  )
  final FutureOr<AjaxRequestAction?> Function(
    T controller,
    AjaxRequest ajaxRequest,
  )?
  onAjaxReadyStateChange;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxProgress}
  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxProgress.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(
        note:
            'This event is implemented using JavaScript. In order to be able to listen to this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings documentation.',
      ),
    ],
  )
  final FutureOr<AjaxRequestAction?> Function(
    T controller,
    AjaxRequest ajaxRequest,
  )?
  onAjaxProgress;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptFetchRequest}
  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[fetchRequest] represents a resource request.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptFetchRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptFetchRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(
        note:
            'This event is implemented using JavaScript. In order to be able to listen to this event, check the [InAppWebViewSettings.useShouldInterceptFetchRequest] setting documentation.',
      ),
    ],
  )
  final FutureOr<FetchRequest?> Function(
    T controller,
    FetchRequest fetchRequest,
  )?
  shouldInterceptFetchRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onUpdateVisitedHistory}
  ///Event fired when the host application updates its visited links database.
  ///This event is also fired when the navigation state of the `WebView` changes through the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event
  ///or, also, when the javascript `window.location` changes without reloading the webview (for example appending or modifying a hash to the url).
  ///
  ///[url] represents the url being visited.
  ///
  ///[isReload] indicates if this url is being reloaded.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onUpdateVisitedHistory.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.doUpdateVisitedHistory',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_HistoryChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_historychanged',
      ),
      LinuxPlatform(
        note:
            'Tracked via load-changed signal and History API JavaScript events.',
      ),
    ],
    parameterPlatforms: {
      'isReload': [AndroidPlatform()],
    },
  )
  final void Function(T controller, WebUri? url, bool? isReload)?
  onUpdateVisitedHistory;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrint}
  ///Use [onPrintRequest] instead
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrint.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrintRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      LinuxPlatform(
        note: 'Intercepted via JavaScript window.print() override.',
      ),
    ],
    parameterPlatforms: {
      'printJobController': [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
    },
  )
  final FutureOr<bool?> Function(
    T controller,
    WebUri? url,
    PlatformPrintJobController? printJobController,
  )?
  onPrintRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLongPressHitTestResult}
  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLongPressHitTestResult.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.setOnLongClickListener',
        apiUrl:
            'https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)',
      ),
      IOSPlatform(
        apiName: 'UILongPressGestureRecognizer',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer',
      ),
    ],
  )
  final void Function(T controller, InAppWebViewHitTestResult hitTestResult)?
  onLongPressHitTestResult;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onEnterFullscreen}
  ///Event fired when the current page has entered full screen mode.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onEnterFullscreen.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onShowCustomView',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)',
      ),
      IOSPlatform(
        apiName: 'UIWindow.didBecomeVisibleNotification',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification',
      ),
      MacOSPlatform(
        apiName: 'NSWindow.didEnterFullScreenNotification',
        apiUrl:
            'https://developer.apple.com/documentation/appkit/nswindow/1419651-didenterfullscreennotification',
      ),
      WebPlatform(
        apiName: 'Document.onfullscreenchange',
        apiUrl:
            'https://developer.mozilla.org/en-US/docs/Web/API/Document/fullscreenchange_event',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ContainsFullScreenElementChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_containsfullscreenelementchanged',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::enter-fullscreen',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.enter-fullscreen.html',
      ),
    ],
  )
  final void Function(T controller)? onEnterFullscreen;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onExitFullscreen}
  ///Event fired when the current page has exited full screen mode.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onExitFullscreen.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onHideCustomView',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()',
      ),
      IOSPlatform(
        apiName: 'UIWindow.didBecomeHiddenNotification',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification',
      ),
      MacOSPlatform(
        apiName: 'NSWindow.didExitFullScreenNotification',
        apiUrl:
            'https://developer.apple.com/documentation/appkit/nswindow/1419177-didexitfullscreennotification',
      ),
      WebPlatform(
        apiName: 'Document.onfullscreenchange',
        apiUrl:
            'https://developer.mozilla.org/en-US/docs/Web/API/Document/fullscreenchange_event',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ContainsFullScreenElementChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_containsfullscreenelementchanged',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::leave-fullscreen',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.leave-fullscreen.html',
      ),
    ],
  )
  final void Function(T controller)? onExitFullscreen;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPageCommitVisible}
  ///Called when the web view begins to receive web content.
  ///
  ///This event occurs early in the document loading process, and as such
  ///you should expect that linked resources (for example, CSS and images) may not be available.
  ///
  ///[url] represents the URL corresponding to the page navigation that triggered this callback.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPageCommitVisible.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onPageCommitVisible',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::load-changed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.load-changed.html',
        note: 'Fired when WebKitLoadEvent is WEBKIT_LOAD_COMMITTED.',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onPageCommitVisible;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onTitleChanged}
  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onTitleChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedTitle',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_DocumentTitleChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_documenttitlechanged',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::notify::title',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.WebView.title.html',
      ),
    ],
  )
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onOverScrolled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onOverScrolled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)',
      ),
      IOSPlatform(),
    ],
  )
  final void Function(T controller, int x, int y, bool clampedX, bool clampedY)?
  onOverScrolled;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onZoomScaleChanged}
  ///Event fired when the zoom scale of the WebView has changed.
  ///
  ///[oldScale] The old zoom scale factor.
  ///
  ///[newScale] The new zoom scale factor.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onZoomScaleChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onScaleChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)',
      ),
      IOSPlatform(
        apiName: 'UIScrollViewDelegate.scrollViewDidZoom',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom',
      ),
      WebPlatform(),
      WindowsPlatform(
        apiName: 'ICoreWebView2Controller.add_ZoomFactorChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_zoomfactorchanged',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::notify::zoom-level',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/property.WebView.zoom-level.html',
      ),
    ],
  )
  final void Function(T controller, double oldScale, double newScale)?
  onZoomScaleChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnSafeBrowsingHit}
  ///Use [onSafeBrowsingHit] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onSafeBrowsingHit instead")
  final FutureOr<SafeBrowsingResponse?> Function(
    T controller,
    Uri url,
    SafeBrowsingThreat? threatType,
  )?
  androidOnSafeBrowsingHit;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSafeBrowsingHit}
  ///Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onSafeBrowsingHit',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)',
        available: '27',
      ),
    ],
  )
  final FutureOr<SafeBrowsingResponse?> Function(
    T controller,
    WebUri url,
    SafeBrowsingThreat? threatType,
  )?
  onSafeBrowsingHit;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnPermissionRequest}
  ///Use [onPermissionRequest] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnPermissionRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onPermissionRequest instead")
  final FutureOr<PermissionRequestResponse?> Function(
    T controller,
    String origin,
    List<String> resources,
  )?
  androidOnPermissionRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequest}
  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[permissionRequest] represents the permission request with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)',
        available: '21',
      ),
      IOSPlatform(
        available: '15.0',
        note:
            'The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].',
      ),
      MacOSPlatform(
        available: '12.0',
        note:
            'The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_PermissionRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#add_permissionrequested',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::permission-request',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.permission-request.html',
      ),
    ],
  )
  final FutureOr<PermissionResponse?> Function(
    T controller,
    PermissionRequest permissionRequest,
  )?
  onPermissionRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnGeolocationPermissionsShowPrompt}
  ///Use [onGeolocationPermissionsShowPrompt] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  final FutureOr<GeolocationPermissionShowPromptResponse?> Function(
    T controller,
    String origin,
  )?
  androidOnGeolocationPermissionsShowPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt}
  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onGeolocationPermissionsShowPrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)',
      ),
    ],
  )
  final FutureOr<GeolocationPermissionShowPromptResponse?> Function(
    T controller,
    String origin,
  )?
  onGeolocationPermissionsShowPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnGeolocationPermissionsHidePrompt}
  ///Use [onGeolocationPermissionsHidePrompt] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  final void Function(T controller)? androidOnGeolocationPermissionsHidePrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt}
  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [onGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onGeolocationPermissionsHidePrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()',
      ),
    ],
  )
  final void Function(T controller)? onGeolocationPermissionsHidePrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidShouldInterceptRequest}
  ///Use [shouldInterceptRequest] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidShouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated("Use shouldInterceptRequest instead")
  final FutureOr<WebResourceResponse?> Function(
    T controller,
    WebResourceRequest request,
  )?
  androidShouldInterceptRequest;

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
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptRequest] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.shouldInterceptRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_WebResourceRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2478.35#add_webresourcerequested',
      ),
      LinuxPlatform(
        apiName: 'webkit_web_context_register_uri_scheme',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.register_uri_scheme.html',
        note:
            'Request interception is implemented via custom URI scheme handlers.',
      ),
    ],
  )
  final FutureOr<WebResourceResponse?> Function(
    T controller,
    WebResourceRequest request,
  )?
  shouldInterceptRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessUnresponsive}
  ///Use [onRenderProcessUnresponsive] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessUnresponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
    ],
  )
  final FutureOr<WebViewRenderProcessAction?> Function(
    T controller,
    WebUri? url,
  )?
  onRenderProcessUnresponsive;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessResponsive}
  ///Use [onRenderProcessResponsive] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessResponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29',
      ),
    ],
  )
  final FutureOr<WebViewRenderProcessAction?> Function(
    T controller,
    WebUri? url,
  )?
  onRenderProcessResponsive;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessGone}
  ///Use [onRenderProcessGone] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnRenderProcessGone.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessGone.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onRenderProcessGone',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)',
        available: '26',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
      LinuxPlatform(
        apiName: 'WebView.web-process-terminated',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/WebKitWebView.html#WebKitWebView-web-process-terminated',
      ),
    ],
  )
  final void Function(T controller, RenderProcessGoneDetail detail)?
  onRenderProcessGone;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnFormResubmission}
  ///Use [onFormResubmission] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnFormResubmission.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onFormResubmission instead')
  final FutureOr<FormResubmissionAction?> Function(T controller, Uri? url)?
  androidOnFormResubmission;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFormResubmission}
  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFormResubmission.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onFormResubmission',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)',
      ),
    ],
  )
  final FutureOr<FormResubmissionAction?> Function(T controller, WebUri? url)?
  onFormResubmission;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnScaleChanged}
  ///Use [onZoomScaleChanged] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnScaleChanged.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onZoomScaleChanged instead')
  final void Function(T controller, double oldScale, double newScale)?
  androidOnScaleChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedIcon}
  ///Use [onReceivedIcon] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedIcon.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onReceivedIcon instead')
  final void Function(T controller, Uint8List icon)? androidOnReceivedIcon;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedIcon}
  ///Event fired when there is new favicon for the current page.
  ///
  ///[icon] represents the favicon for the current page.
  ///
  ///Deprecated: use [onFaviconChanged] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedIcon.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedIcon',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)',
      ),
    ],
  )
  @Deprecated('Use onFaviconChanged instead')
  final void Function(T controller, Uint8List icon)? onReceivedIcon;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFaviconChanged}
  ///Event fired when the favicon for the current page changes.
  ///
  ///[faviconChangedRequest] contains the favicon URL and/or icon bytes, if available.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFaviconChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedIcon',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2_15.add_FaviconChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_15?view=webview2-1.0.2849.39#add_faviconchanged',
      ),
    ],
  )
  final void Function(
    T controller,
    FaviconChangedRequest faviconChangedRequest,
  )?
  onFaviconChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedTouchIconUrl}
  ///Use [onReceivedTouchIconUrl] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onReceivedTouchIconUrl instead')
  final void Function(T controller, Uri url, bool precomposed)?
  androidOnReceivedTouchIconUrl;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedTouchIconUrl}
  ///Event fired when there is an url for an apple-touch-icon.
  ///
  ///[url] represents the icon url.
  ///
  ///[precomposed] is `true` if the url is for a precomposed touch icon.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedTouchIconUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)',
      ),
    ],
  )
  final void Function(T controller, WebUri url, bool precomposed)?
  onReceivedTouchIconUrl;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnJsBeforeUnload}
  ///Use [onJsBeforeUnload] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnJsBeforeUnload.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onJsBeforeUnload instead')
  final FutureOr<JsBeforeUnloadResponse?> Function(
    T controller,
    JsBeforeUnloadRequest jsBeforeUnloadRequest,
  )?
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsBeforeUnload.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsBeforeUnload',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::script-dialog',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.WebView.script-dialog.html',
        note: 'Handles WEBKIT_SCRIPT_DIALOG_BEFORE_UNLOAD_CONFIRM dialog type.',
      ),
    ],
  )
  final FutureOr<JsBeforeUnloadResponse?> Function(
    T controller,
    JsBeforeUnloadRequest jsBeforeUnloadRequest,
  )?
  onJsBeforeUnload;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedLoginRequest}
  ///Use [onReceivedLoginRequest] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.androidOnReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  @Deprecated('Use onReceivedLoginRequest instead')
  final void Function(T controller, LoginRequest loginRequest)?
  androidOnReceivedLoginRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedLoginRequest}
  ///Event fired when a request to automatically log in the user has been processed.
  ///
  ///[loginRequest] contains the realm, account and args of the login request.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedLoginRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)',
      ),
    ],
  )
  final void Function(T controller, LoginRequest loginRequest)?
  onReceivedLoginRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequestCanceled}
  ///Notify the host application that the given permission request has been canceled. Any related UI should therefore be hidden.
  ///
  ///[permissionRequest] represents the permission request that needs be canceled
  ///with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequestCanceled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequestCanceled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)',
        available: '21',
      ),
    ],
  )
  final void Function(T controller, PermissionRequest permissionRequest)?
  onPermissionRequestCanceled;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRequestFocus}
  ///Request display and focus for this WebView.
  ///This may happen due to another WebView opening a link in this WebView and requesting that this WebView be displayed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onRequestFocus](https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)))
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRequestFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onRequestFocus',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)',
      ),
    ],
  )
  final void Function(T controller)? onRequestFocus;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnWebContentProcessDidTerminate}
  ///Use [onWebContentProcessDidTerminate] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  final void Function(T controller)? iosOnWebContentProcessDidTerminate;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebContentProcessDidTerminate}
  ///Invoked when the web view's web content process is terminated.
  ///Reloading the page will start a new render process if needed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webViewWebContentProcessDidTerminate',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webViewWebContentProcessDidTerminate',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
    ],
  )
  final void Function(T controller)? onWebContentProcessDidTerminate;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnDidReceiveServerRedirectForProvisionalNavigation}
  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  final void Function(T controller)?
  iosOnDidReceiveServerRedirectForProvisionalNavigation;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation}
  ///Called when a web view receives a server redirect.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview',
      ),
    ],
  )
  final void Function(T controller)?
  onDidReceiveServerRedirectForProvisionalNavigation;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnNavigationResponse}
  ///Use [onNavigationResponse] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosOnNavigationResponse.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use onNavigationResponse instead')
  final FutureOr<IOSNavigationResponseAction?> Function(
    T controller,
    IOSWKNavigationResponse navigationResponse,
  )?
  iosOnNavigationResponse;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNavigationResponse}
  ///Called when a web view asks for permission to navigate to new content after the response to the navigation request is known.
  ///
  ///[navigationResponse] represents the navigation response.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useOnNavigationResponse] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNavigationResponse.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::decide-policy',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/signal.WebView.decide-policy.html',
      ),
    ],
  )
  final FutureOr<NavigationResponseAction?> Function(
    T controller,
    NavigationResponse navigationResponse,
  )?
  onNavigationResponse;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosShouldAllowDeprecatedTLS}
  ///Use [shouldAllowDeprecatedTLS] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.iosShouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  final FutureOr<IOSShouldAllowDeprecatedTLSAction?> Function(
    T controller,
    URLAuthenticationChallenge challenge,
  )?
  iosShouldAllowDeprecatedTLS;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS}
  ///Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1).
  ///
  ///[challenge] represents the authentication challenge.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '14.0',
      ),
      MacOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '11.0',
      ),
    ],
  )
  final FutureOr<ShouldAllowDeprecatedTLSAction?> Function(
    T controller,
    URLAuthenticationChallenge challenge,
  )?
  shouldAllowDeprecatedTLS;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCameraCaptureStateChanged}
  ///Event fired when a change in the camera capture state occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCameraCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '15.0'),
      MacOSPlatform(available: '12.0'),
      LinuxPlatform(
        apiName: 'WebKitWebView::notify::camera-capture-state',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/property.WebView.camera-capture-state.html',
        note: 'Requires WPE WebKit 2.34 or later.',
      ),
    ],
  )
  final FutureOr<void> Function(
    T controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )?
  onCameraCaptureStateChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged}
  ///Event fired when a change in the microphone capture state occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '15.0'),
      MacOSPlatform(available: '12.0'),
      LinuxPlatform(
        apiName: 'WebKitWebView::notify::microphone-capture-state',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/property.WebView.microphone-capture-state.html',
        note: 'Requires WPE WebKit 2.34 or later.',
      ),
    ],
  )
  final FutureOr<void> Function(
    T controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )?
  onMicrophoneCaptureStateChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentSizeChanged}
  ///Event fired when the content size of the `WebView` changes.
  ///
  ///[oldContentSize] represents the old content size value.
  ///
  ///[newContentSize] represents the new content size value.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentSizeChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(),
      LinuxPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  final void Function(T controller, Size oldContentSize, Size newContentSize)?
  onContentSizeChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProcessFailed}
  ///Invoked when any of the processes in the WebView Process Group encounters one of the following conditions:
  ///- Unexpected exit: The process indicated by the event args has exited unexpectedly (usually due to a crash).
  ///The failure might or might not be recoverable and some failures are auto-recoverable.
  ///- Unresponsiveness: The process indicated by the event args has become unresponsive to user input.
  ///This is only reported for renderer processes, and will run every few seconds until the process becomes responsive again.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProcessFailed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2.add_ProcessFailed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2849.39#add_processfailed',
      ),
    ],
  )
  final void Function(T controller, ProcessFailedDetail detail)?
  onProcessFailed;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNotificationReceived}
  ///Event fired when a web notification is received.
  ///
  ///The [request] contains the [NotificationReceivedRequest.senderOrigin] (the origin of the web content
  ///that sends the notification) and the [NotificationReceivedRequest.notificationController] which provides
  ///methods to report the notification status (shown, clicked, closed) back to the web content,
  ///as well as listen for the close event when the notification is closed by web code.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNotificationReceived.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_24.add_NotificationReceived',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_24?view=webview2-1.0.2849.39#add_notificationreceived',
      ),
    ],
  )
  final FutureOr<NotificationReceivedResponse?> Function(
    T controller,
    NotificationReceivedRequest request,
  )?
  onNotificationReceived;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSaveAsUIShowing}
  ///Event fired when Save As UI is showing.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSaveAsUIShowing.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_25.add_SaveAsUIShowing',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_25?view=webview2-1.0.2849.39#add_saveasuishowing',
      ),
    ],
  )
  final FutureOr<SaveAsUIShowingResponse?> Function(
    T controller,
    SaveAsUIShowingRequest request,
  )?
  onSaveAsUIShowing;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting}
  ///Event fired when a save file security check is starting.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_26.add_SaveFileSecurityCheckStarting',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_26?view=webview2-1.0.2849.39#add_savefilesecuritycheckstarting',
      ),
    ],
  )
  final FutureOr<SaveFileSecurityCheckStartingResponse?> Function(
    T controller,
    SaveFileSecurityCheckStartingRequest request,
  )?
  onSaveFileSecurityCheckStarting;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScreenCaptureStarting}
  ///Event fired when screen capture is starting.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScreenCaptureStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2_27.add_ScreenCaptureStarting',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_27?view=webview2-1.0.2849.39#add_screencapturestarting',
      ),
    ],
  )
  final FutureOr<ScreenCaptureStartingResponse?> Function(
    T controller,
    ScreenCaptureStartingRequest request,
  )?
  onScreenCaptureStarting;

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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAcceleratorKeyPressed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Controller.add_AcceleratorKeyPressed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#add_acceleratorkeypressed',
      ),
    ],
  )
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onShowFileChooser.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onShowFileChooser',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowFileChooser(android.webkit.WebView,%20android.webkit.ValueCallback%3Candroid.net.Uri[]%3E,%20android.webkit.WebChromeClient.FileChooserParams)',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebView::run-file-chooser',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/signal.WebView.run-file-chooser.html',
      ),
    ],
  )
  final FutureOr<ShowFileChooserResponse?> Function(
    T controller,
    ShowFileChooserRequest request,
  )?
  onShowFileChooser;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUrlRequest}
  ///Initial url request that will be loaded.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUrlRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            'When loading an URL Request using "POST" method, headers are ignored.',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(requiresSameOrigin: false),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final URLRequest? initialUrlRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialFile}
  ///Initial asset file that will be loaded. See [InAppWebViewController.loadFile] for explanation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialFile.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(requiresSameOrigin: false),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final String? initialFile;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialData}
  ///Initial [InAppWebViewInitialData] that will be loaded.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(requiresSameOrigin: false),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final InAppWebViewInitialData? initialData;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialOptions}
  ///Use [initialSettings] instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialOptions.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated('Use initialSettings instead')
  final InAppWebViewGroupOptions? initialOptions;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialSettings}
  ///Initial settings that will be used.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialSettings.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(requiresSameOrigin: false),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final InAppWebViewSettings? initialSettings;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu}
  ///Context menu which contains custom menu items to be shown when [ContextMenu] is presented.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final ContextMenu? contextMenu;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts}
  ///Initial list of user scripts to be loaded at start or end of a page loading.
  ///To add or remove user scripts, you have to use the [InAppWebViewController]'s methods such as [InAppWebViewController.addUserScript],
  ///[InAppWebViewController.removeUserScript], [InAppWebViewController.removeAllUserScripts], etc.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs.""",
      ),
      MacOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs.""",
      ),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(
        apiName: 'WebKitUserContentManager',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.UserContentManager.html',
      ),
    ],
  )
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController}
  ///Represents the pull-to-refresh feature controller.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            'To be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.',
      ),
      IOSPlatform(),
    ],
  )
  final PlatformPullToRefreshController? pullToRefreshController;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController}
  ///Represents the find interaction feature controller.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(
        apiName: 'WebKitFindController',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.FindController.html',
      ),
    ],
  )
  final PlatformFindInteractionController? findInteractionController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
  const PlatformWebViewCreationParams({
    this.controllerFromPlatform,
    this.windowId,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onContentLoading,
    this.onDOMContentLoaded,
    @Deprecated('Use onReceivedError instead') this.onLoadError,
    this.onReceivedError,
    @Deprecated("Use onReceivedHttpError instead") this.onLoadHttpError,
    this.onReceivedHttpError,
    this.onProgressChanged,
    this.onConsoleMessage,
    this.shouldOverrideUrlLoading,
    this.onLaunchingExternalUriScheme,
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
    @Deprecated('Use onSafeBrowsingHit instead') this.androidOnSafeBrowsingHit,
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
    @Deprecated('Use onFaviconChanged instead') this.onReceivedIcon,
    this.onFaviconChanged,
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
      'Use onDidReceiveServerRedirectForProvisionalNavigation instead',
    )
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
    this.onNotificationReceived,
    this.onSaveAsUIShowing,
    this.onSaveFileSecurityCheckStarting,
    this.onScreenCaptureStarting,
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
    this.findInteractionController,
  });

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebViewCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebViewCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => _PlatformWebViewCreationParamsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
