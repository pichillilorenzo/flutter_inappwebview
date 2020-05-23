import 'package:flutter_inappwebview/src/context_menu.dart';

import 'types.dart';
import 'in_app_webview_controller.dart';

///Abstract class that represents a WebView. Used by [WebView] and [HeadlessInAppWebView].
abstract class WebView {
  ///Event fired when the [WebView] is created.
  final void Function(InAppWebViewController controller) onWebViewCreated;

  ///Event fired when the [WebView] starts to load an [url].
  final void Function(InAppWebViewController controller, String url)
  onLoadStart;

  ///Event fired when the [WebView] finishes loading an [url].
  final void Function(InAppWebViewController controller, String url) onLoadStop;

  ///Event fired when the [WebView] encounters an error loading an [url].
  final void Function(InAppWebViewController controller, String url, int code,
      String message) onLoadError;

  ///Event fired when the [WebView] main page receives an HTTP error.
  ///
  ///[url] represents the url of the main page that received the HTTP error.
  ///
  ///[statusCode] represents the status code of the response. HTTP errors have status codes >= 400.
  ///
  ///[description] represents the description of the HTTP error. On iOS, it is always an empty string.
  ///
  ///**NOTE**: available on Android 23+.
  final void Function(InAppWebViewController controller, String url,
      int statusCode, String description) onLoadHttpError;

  ///Event fired when the current [progress] of loading a page is changed.
  final void Function(InAppWebViewController controller, int progress)
  onProgressChanged;

  ///Event fired when the [WebView] receives a [ConsoleMessage].
  final void Function(
      InAppWebViewController controller, ConsoleMessage consoleMessage)
  onConsoleMessage;

  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView. This event is not called on the initial load of the WebView.
  ///
  ///Note that on Android there isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
  ///However, if you want to cancel requests for subframes, you can use the [AndroidInAppWebViewOptions.regexToCancelSubFramesLoading] option
  ///to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
  ///
  ///Also, on Android, this method is not called for POST requests.
  ///
  ///[shouldOverrideUrlLoadingRequest] represents the navigation request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldOverrideUrlLoading] option to `true`.
  final Future<ShouldOverrideUrlLoadingAction> Function(
      InAppWebViewController controller,
      ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest)
  shouldOverrideUrlLoading;

  ///Event fired when the [WebView] loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnLoadResource] and [InAppWebViewOptions.javaScriptEnabled] options to `true`.
  final void Function(
      InAppWebViewController controller, LoadedResource resource)
  onLoadResource;

  ///Event fired when the [WebView] scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  final void Function(InAppWebViewController controller, int x, int y)
  onScrollChanged;

  ///Event fired when [WebView] recognizes and starts a downloadable file.
  ///
  ///[url] represents the url of the file.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnDownloadStart] option to `true`.
  final void Function(InAppWebViewController controller, String url)
  onDownloadStart;

  ///Event fired when the [WebView] finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///[scheme] represents the scheme of the url.
  ///
  ///[url] represents the url of the request.
  final Future<CustomSchemeResponse> Function(
      InAppWebViewController controller, String scheme, String url)
  onLoadResourceCustomScheme;

  ///Event fired when the [WebView] requests the host application to create a new window,
  ///for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
  ///
  ///[onCreateWindowRequest] represents the request.
  ///
  ///**NOTE**: on Android you need to set [AndroidInAppWebViewOptions.supportMultipleWindows] option to `true`.
  final void Function(InAppWebViewController controller,
      OnCreateWindowRequest onCreateWindowRequest) onCreateWindow;

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  final Future<JsAlertResponse> Function(
      InAppWebViewController controller, String message) onJsAlert;

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  final Future<JsConfirmResponse> Function(
      InAppWebViewController controller, String message) onJsConfirm;

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[message] represents the message to be displayed in the alert dialog.
  ///
  ///[defaultValue] represents the default value displayed in the prompt dialog.
  final Future<JsPromptResponse> Function(InAppWebViewController controller,
      String message, String defaultValue) onJsPrompt;

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [HttpAuthChallenge].
  final Future<HttpAuthResponse> Function(
      InAppWebViewController controller, HttpAuthChallenge challenge)
  onReceivedHttpAuthRequest;

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  final Future<ServerTrustAuthResponse> Function(
      InAppWebViewController controller, ServerTrustChallenge challenge)
  onReceivedServerTrustAuthRequest;

  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  final Future<ClientCertResponse> Function(
      InAppWebViewController controller, ClientCertChallenge challenge)
  onReceivedClientCertRequest;

  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the numberOfMatches value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  final void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting) onFindResultReceived;

  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  final Future<AjaxRequest> Function(
      InAppWebViewController controller, AjaxRequest ajaxRequest)
  shouldInterceptAjaxRequest;

  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  final Future<AjaxRequestAction> Function(
      InAppWebViewController controller, AjaxRequest ajaxRequest)
  onAjaxReadyStateChange;

  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptAjaxRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the ajax requests will be intercept for sure.
  final Future<AjaxRequestAction> Function(
      InAppWebViewController controller, AjaxRequest ajaxRequest)
  onAjaxProgress;

  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///
  ///[fetchRequest] represents a resource request.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useShouldInterceptFetchRequest] option to `true`.
  ///Also, unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
  ///can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
  ///used to intercept fetch requests is loaded as soon as possible so it won't be instantaneous as iOS but just after some milliseconds (< ~100ms).
  ///Inside the `window.addEventListener("flutterInAppWebViewPlatformReady")` event, the fetch requests will be intercept for sure.
  final Future<FetchRequest> Function(
      InAppWebViewController controller, FetchRequest fetchRequest)
  shouldInterceptFetchRequest;

  ///Event fired when the host application updates its visited links database.
  ///This event is also fired when the navigation state of the [WebView] changes through the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event
  ///or, also, when the javascript `window.location` changes without reloading the webview (for example appending or modifying an hash to the url).
  ///
  ///[url] represents the url being visited.
  ///
  ///[androidIsReload] indicates if this url is being reloaded. Available only on Android.
  final void Function(
      InAppWebViewController controller, String url, bool androidIsReload)
  onUpdateVisitedHistory;

  ///Event fired when `window.print()` is called from JavaScript side.
  ///
  ///[url] represents the url on which is called.
  ///
  ///**NOTE**: available on Android 21+.
  final void Function(InAppWebViewController controller, String url) onPrint;

  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult) onLongPressHitTestResult;

  ///Event fired when the current page has entered full screen mode.
  final void Function(InAppWebViewController controller) onEnterFullscreen;

  ///Event fired when the current page has exited full screen mode.
  final void Function(InAppWebViewController controller) onExitFullscreen;

  ///Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android 27+.
  final Future<SafeBrowsingResponse> Function(InAppWebViewController controller,
      String url, SafeBrowsingThreat threatType) androidOnSafeBrowsingHit;

  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[origin] represents the origin of the web page which is trying to access the restricted resources.
  ///
  ///[resources] represents the array of resources the web content wants to access.
  ///
  ///**NOTE**: available only on Android 23+.
  final Future<PermissionRequestResponse> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources) androidOnPermissionRequest;

  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///
  ///**NOTE**: available only on Android.
  final Future<GeolocationPermissionShowPromptResponse> Function(
      InAppWebViewController controller, String origin)
  androidOnGeolocationPermissionsShowPrompt;

  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [androidOnGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///
  ///**NOTE**: available only on Android.
  final Future<void> Function(InAppWebViewController controller)
  androidOnGeolocationPermissionsHidePrompt;

  ///Invoked when the web view's web content process is terminated.
  ///
  ///**NOTE**: available only on iOS.
  final Future<void> Function(InAppWebViewController controller)
  iosOnWebContentProcessDidTerminate;

  ///Called when the web view begins to receive web content.
  ///
  ///**NOTE**: available only on iOS.
  final Future<void> Function(InAppWebViewController controller) iosOnDidCommit;

  ///Called when a web view receives a server redirect.
  ///
  ///**NOTE**: available only on iOS.
  final Future<void> Function(InAppWebViewController controller)
  iosOnDidReceiveServerRedirectForProvisionalNavigation;

  ///Initial url that will be loaded.
  final String initialUrl;

  ///Initial asset file that will be loaded. See [InAppWebViewController.loadFile] for explanation.
  final String initialFile;

  ///Initial [InAppWebViewInitialData] that will be loaded.
  final InAppWebViewInitialData initialData;

  ///Initial headers that will be used.
  final Map<String, String> initialHeaders;

  ///Initial options that will be used.
  final InAppWebViewGroupOptions initialOptions;

  ///Context menu which contains custom menu items to be shown when [ContextMenu] is presented.
  final ContextMenu contextMenu;

  WebView({
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onLoadError,
    this.onLoadHttpError,
    this.onProgressChanged,
    this.onConsoleMessage,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    this.onDownloadStart,
    this.onLoadResourceCustomScheme,
    this.onCreateWindow,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onReceivedHttpAuthRequest,
    this.onReceivedServerTrustAuthRequest,
    this.onReceivedClientCertRequest,
    this.onFindResultReceived,
    this.shouldInterceptAjaxRequest,
    this.onAjaxReadyStateChange,
    this.onAjaxProgress,
    this.shouldInterceptFetchRequest,
    this.onUpdateVisitedHistory,
    this.onPrint,
    this.onLongPressHitTestResult,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.androidOnSafeBrowsingHit,
    this.androidOnPermissionRequest,
    this.androidOnGeolocationPermissionsShowPrompt,
    this.androidOnGeolocationPermissionsHidePrompt,
    this.iosOnWebContentProcessDidTerminate,
    this.iosOnDidCommit,
    this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
    this.initialUrl,
    this.initialFile,
    this.initialData,
    this.initialHeaders,
    this.initialOptions,
    this.contextMenu
  });
}