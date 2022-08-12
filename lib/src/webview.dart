import 'dart:typed_data';

import 'context_menu.dart';

import 'types.dart';
import 'in_app_webview_controller.dart';
import 'webview_options.dart';
import 'headless_in_app_webview.dart';

///Abstract class that represents a WebView. Used by [WebView] and [HeadlessInAppWebView].
abstract class WebView {
  ///The window id of a [CreateWindowRequest.windowId].
  final int windowId;

  ///Event fired when the [WebView] is created.
  final void Function(InAppWebViewController controller) onWebViewCreated;

  ///Event fired when the [WebView] starts to load an [url].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview
  final void Function(InAppWebViewController controller, String url)
      onLoadStart;

  ///Event fired when the [WebView] finishes loading an [url].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview
  final void Function(InAppWebViewController controller, String url) onLoadStop;

  ///Event fired when the [WebView] encounters an error loading an [url].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20int,%20java.lang.String,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview
  final void Function(InAppWebViewController controller, String url,
      int statusCode, String description) onLoadHttpError;

  ///Event fired when the current [progress] of loading a page is changed.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)
  final void Function(InAppWebViewController controller, int progress)
      onProgressChanged;

  ///Event fired when the [WebView] receives a [ConsoleMessage].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll
  final void Function(InAppWebViewController controller, int x, int y)
      onScrollChanged;

  ///Event fired when [WebView] recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[url] represents the url of the file.
  ///
  ///**NOTE**: In order to be able to listen this event, you need to set [InAppWebViewOptions.useOnDownloadStart] option to `true`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview
  final void Function(InAppWebViewController controller, String url)
      onDownloadStart;

  ///Event fired when the [WebView] finds the `custom-scheme` while loading a resource. Here you can handle the url request and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///
  ///[scheme] represents the scheme of the url.
  ///
  ///[url] represents the url of the request.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkurlschemehandler
  final Future<CustomSchemeResponse> Function(
          InAppWebViewController controller, String scheme, String url)
      onLoadResourceCustomScheme;

  ///Event fired when the [WebView] requests the host application to create a new window,
  ///for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
  ///If the host application chooses to honor this request, it should return `true` from this method, create a new WebView to host the window.
  ///If the host application chooses not to honor the request, it should return `false` from this method.
  ///The default implementation of this method does nothing and hence returns `false`.
  ///
  ///[createWindowRequest] represents the request.
  ///
  ///**NOTE**: to allow JavaScript to open windows, you need to set [InAppWebViewOptions.javaScriptCanOpenWindowsAutomatically] option to `true`.
  ///
  ///**NOTE**: on Android you need to set [AndroidInAppWebViewOptions.supportMultipleWindows] option to `true`.
  ///
  ///**NOTE**: on iOS, setting these initial options: [InAppWebViewOptions.supportZoom], [InAppWebViewOptions.useOnLoadResource], [InAppWebViewOptions.useShouldInterceptAjaxRequest],
  ///[InAppWebViewOptions.useShouldInterceptFetchRequest], [InAppWebViewOptions.applicationNameForUserAgent], [InAppWebViewOptions.javaScriptCanOpenWindowsAutomatically],
  ///[InAppWebViewOptions.javaScriptEnabled], [InAppWebViewOptions.minimumFontSize], [InAppWebViewOptions.preferredContentMode], [InAppWebViewOptions.incognito],
  ///[InAppWebViewOptions.cacheEnabled], [InAppWebViewOptions.mediaPlaybackRequiresUserGesture],
  ///[InAppWebViewOptions.resourceCustomSchemes], [IOSInAppWebViewOptions.sharedCookiesEnabled],
  ///[IOSInAppWebViewOptions.enableViewportScale], [IOSInAppWebViewOptions.allowsAirPlayForMediaPlayback],
  ///[IOSInAppWebViewOptions.allowsPictureInPictureMediaPlayback], [IOSInAppWebViewOptions.isFraudulentWebsiteWarningEnabled],
  ///[IOSInAppWebViewOptions.allowsInlineMediaPlayback], [IOSInAppWebViewOptions.suppressesIncrementalRendering], [IOSInAppWebViewOptions.selectionGranularity],
  ///[IOSInAppWebViewOptions.ignoresViewportScaleLimits],
  ///will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
  ///with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
  ///So, these options will be inherited from the caller WebView.
  ///Also, note that calling [InAppWebViewController.setOptions] method using the controller of the new created WebView,
  ///it will update also the WebView options of the caller WebView.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview
  final Future<bool> Function(InAppWebViewController controller,
      CreateWindowRequest createWindowRequest) onCreateWindow;

  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose
  final void Function(InAppWebViewController controller) onCloseWindow;

  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` JavaScript event applied to the `window` object.
  final void Function(InAppWebViewController controller) onWindowFocus;

  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` JavaScript event applied to the `window` object.
  final void Function(InAppWebViewController controller) onWindowBlur;

  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview
  final Future<JsAlertResponse> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)
      onJsAlert;

  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview
  final Future<JsConfirmResponse> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)
      onJsConfirm;

  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview
  final Future<JsPromptResponse> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)
      onJsPrompt;

  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [HttpAuthChallenge].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview
  final Future<HttpAuthResponse> Function(
          InAppWebViewController controller, HttpAuthChallenge challenge)
      onReceivedHttpAuthRequest;

  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview
  final Future<ServerTrustAuthResponse> Function(
          InAppWebViewController controller, ServerTrustChallenge challenge)
      onReceivedServerTrustAuthRequest;

  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#setFindListener(android.webkit.WebView.FindListener)
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult) onLongPressHitTestResult;

  ///Event fired when the current page has entered full screen mode.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification
  final void Function(InAppWebViewController controller) onEnterFullscreen;

  ///Event fired when the current page has exited full screen mode.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification
  final void Function(InAppWebViewController controller) onExitFullscreen;

  ///Called when the web view begins to receive web content.
  ///
  ///This event occurs early in the document loading process, and as such
  ///you should expect that linked resources (for example, CSS and images) may not be available.
  ///
  ///[url] represents the URL corresponding to the page navigation that triggered this callback.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview
  final void Function(InAppWebViewController controller, String url)
      onPageCommitVisible;

  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)
  final void Function(InAppWebViewController controller, String title)
      onTitleChanged;

  ///Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///
  ///**NOTE**: available only on Android 27+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)
  final Future<SafeBrowsingResponse> Function(InAppWebViewController controller,
      String url, SafeBrowsingThreat threatType) androidOnSafeBrowsingHit;

  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[origin] represents the origin of the web page which is trying to access the restricted resources.
  ///
  ///[resources] represents the array of resources the web content wants to access.
  ///
  ///**NOTE**: available only on Android 23+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)
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
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)
  final Future<GeolocationPermissionShowPromptResponse> Function(
          InAppWebViewController controller, String origin)
      androidOnGeolocationPermissionsShowPrompt;

  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [androidOnGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()
  final void Function(InAppWebViewController controller)
      androidOnGeolocationPermissionsHidePrompt;

  ///Notify the host application of a resource request and allow the application to return the data.
  ///If the return value is `null`, the WebView will continue to load the resource as usual.
  ///Otherwise, the return response and data will be used.
  ///
  ///This callback is invoked for a variety of URL schemes (e.g., `http(s):`, `data:`, `file:`, etc.),
  ///not only those schemes which send requests over the network.
  ///This is not called for `javascript:` URLs, `blob:` URLs, or for assets accessed via `file:///android_asset/` or `file:///android_res/` URLs.
  ///
  ///In the case of redirects, this is only called for the initial resource URL, not any subsequent redirect URLs.
  ///
  ///[request] Object containing the details of the request.
  ///
  ///**NOTE**: available only on Android. In order to be able to listen this event, you need to set [AndroidInAppWebViewOptions.useShouldInterceptRequest] option to `true`.
  ///
  ///**Official Android API**:
  ///- https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)
  ///- https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20java.lang.String)
  final Future<WebResourceResponse> Function(
          InAppWebViewController controller, WebResourceRequest request)
      androidShouldInterceptRequest;

  ///Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript.
  ///
  ///If a WebView fails to process an input event, or successfully navigate to a new URL within a reasonable time frame, the renderer is considered to be unresponsive, and this callback will be called.
  ///
  ///This callback will continue to be called at regular intervals as long as the renderer remains unresponsive.
  ///If the renderer becomes responsive again, [androidOnRenderProcessResponsive] will be called once,
  ///and this method will not subsequently be called unless another period of unresponsiveness is detected.
  ///
  ///The minimum interval between successive calls to `androidOnRenderProcessUnresponsive` is 5 seconds.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///Applications may choose to terminate the associated renderer via the object that is passed to this callback,
  ///if in multiprocess mode, however this must be accompanied by correctly handling [androidOnRenderProcessGone] for this WebView,
  ///and all other WebViews associated with the same renderer. Failure to do so will result in application termination.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)
  final Future<WebViewRenderProcessAction> Function(
          InAppWebViewController controller, String url)
      androidOnRenderProcessUnresponsive;

  ///Event called once when an unresponsive renderer currently associated with the WebView becomes responsive.
  ///
  ///After a WebView renderer becomes unresponsive, which is notified to the application by [androidOnRenderProcessUnresponsive],
  ///it is possible for the blocking renderer task to complete, returning the renderer to a responsive state.
  ///In that case, this method is called once to indicate responsiveness.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///
  ///**NOTE**: available only on Android 29+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)
  final Future<WebViewRenderProcessAction> Function(
          InAppWebViewController controller, String url)
      androidOnRenderProcessResponsive;

  ///Event fired when the given WebView's render process has exited.
  ///The application's implementation of this callback should only attempt to clean up the WebView.
  ///The WebView should be removed from the view hierarchy, all references to it should be cleaned up.
  ///
  ///[detail] the reason why it exited.
  ///
  ///**NOTE**: available only on Android 26+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)
      androidOnRenderProcessGone;

  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)
  final Future<FormResubmissionAction> Function(
      InAppWebViewController controller, String url) androidOnFormResubmission;

  ///Event fired when the scale applied to the WebView has changed.
  ///
  ///[oldScale] The old scale factor.
  ///
  ///[newScale] The new scale factor.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)
  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)
      androidOnScaleChanged;

  ///Event fired when there is a request to display and focus for this WebView.
  ///This may happen due to another WebView opening a link in this WebView and requesting that this WebView be displayed.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)
  final void Function(InAppWebViewController controller) androidOnRequestFocus;

  ///Event fired when there is new favicon for the current page.
  ///
  ///[icon] represents the favicon for the current page.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedIcon(android.webkit.WebView,%20android.graphics.Bitmap)
  final void Function(InAppWebViewController controller, Uint8List icon)
      androidOnReceivedIcon;

  ///Event fired when there is an url for an apple-touch-icon.
  ///
  ///[url] represents the icon url.
  ///
  ///[precomposed] is `true` if the url is for a precomposed touch icon.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)
  final void Function(
          InAppWebViewController controller, String url, bool precomposed)
      androidOnReceivedTouchIconUrl;

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
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)
  final Future<JsBeforeUnloadResponse> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest) androidOnJsBeforeUnload;

  ///Event fired when a request to automatically log in the user has been processed.
  ///
  ///[loginRequest] contains the realm, account and args of the login request.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)
      androidOnReceivedLoginRequest;

  ///Invoked when the web view's web content process is terminated.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi
  final void Function(InAppWebViewController controller)
      iosOnWebContentProcessDidTerminate;

  ///Called when a web view receives a server redirect.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview
  final void Function(InAppWebViewController controller)
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

  WebView(
      {this.windowId,
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
      this.onCloseWindow,
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
      this.onPageCommitVisible,
      this.onTitleChanged,
      this.onWindowFocus,
      this.onWindowBlur,
      this.androidOnSafeBrowsingHit,
      this.androidOnPermissionRequest,
      this.androidOnGeolocationPermissionsShowPrompt,
      this.androidOnGeolocationPermissionsHidePrompt,
      this.androidShouldInterceptRequest,
      this.androidOnRenderProcessGone,
      this.androidOnRenderProcessResponsive,
      this.androidOnRenderProcessUnresponsive,
      this.androidOnFormResubmission,
      this.androidOnScaleChanged,
      this.androidOnRequestFocus,
      this.androidOnReceivedIcon,
      this.androidOnReceivedTouchIconUrl,
      this.androidOnJsBeforeUnload,
      this.androidOnReceivedLoginRequest,
      this.iosOnWebContentProcessDidTerminate,
      this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      this.initialUrl,
      this.initialFile,
      this.initialData,
      this.initialHeaders,
      this.initialOptions,
      this.contextMenu});
}
