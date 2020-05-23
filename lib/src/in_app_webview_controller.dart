import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview/src/webview.dart';

import 'package:html/parser.dart' show parse;

import 'types.dart';
import 'in_app_browser.dart';
import 'webview_options.dart';

///Controls a WebView, such as an [InAppWebView] widget instance, a [HeadlessInAppWebView] instance or [InAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [InAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [InAppBrowser] instance, you can get it through the [InAppBrowser.webViewController] attribute.
class InAppWebViewController {
  WebView _webview;
  MethodChannel _channel;
  static MethodChannel _staticChannel =
  MethodChannel('com.pichillilorenzo/flutter_inappwebview_static');
  Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap =
  HashMap<String, JavaScriptHandlerCallback>();

  // ignore: unused_field
  bool _isOpened = false;

  // ignore: unused_field
  dynamic _id;
  String _inAppBrowserUuid;
  InAppBrowser _inAppBrowser;

  ///Android controller that contains only android-specific methods
  AndroidInAppWebViewController android;

  ///iOS controller that contains only ios-specific methods
  IOSInAppWebViewController ios;

  InAppWebViewController(dynamic id, WebView webview) {
    this._id = id;
    this._channel =
        MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    this._channel.setMethodCallHandler(handleMethod);
    this._webview = webview;
    this.android = AndroidInAppWebViewController(this);
    this.ios = IOSInAppWebViewController(this);
  }

  InAppWebViewController.fromInAppBrowser(
      String uuid, MethodChannel channel, InAppBrowser inAppBrowser) {
    this._inAppBrowserUuid = uuid;
    this._channel = channel;
    this._inAppBrowser = inAppBrowser;
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onHeadlessWebViewCreated":
        if (_webview != null && _webview is HeadlessInAppWebView)
          _webview.onWebViewCreated(this);
        break;
      case "onLoadStart":
        String url = call.arguments["url"];
        if (_webview != null && _webview.onLoadStart != null)
          _webview.onLoadStart(this, url);
        else if (_inAppBrowser != null) _inAppBrowser.onLoadStart(url);
        break;
      case "onLoadStop":
        String url = call.arguments["url"];
        if (_webview != null && _webview.onLoadStop != null)
          _webview.onLoadStop(this, url);
        else if (_inAppBrowser != null) _inAppBrowser.onLoadStop(url);
        break;
      case "onLoadError":
        String url = call.arguments["url"];
        int code = call.arguments["code"];
        String message = call.arguments["message"];
        if (_webview != null && _webview.onLoadError != null)
          _webview.onLoadError(this, url, code, message);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadError(url, code, message);
        break;
      case "onLoadHttpError":
        String url = call.arguments["url"];
        int statusCode = call.arguments["statusCode"];
        String description = call.arguments["description"];
        if (_webview != null && _webview.onLoadHttpError != null)
          _webview.onLoadHttpError(this, url, statusCode, description);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLoadHttpError(url, statusCode, description);
        break;
      case "onProgressChanged":
        int progress = call.arguments["progress"];
        if (_webview != null && _webview.onProgressChanged != null)
          _webview.onProgressChanged(this, progress);
        else if (_inAppBrowser != null)
          _inAppBrowser.onProgressChanged(progress);
        break;
      case "shouldOverrideUrlLoading":
        String url = call.arguments["url"];
        String method = call.arguments["method"];
        Map<String, String> headers =
        call.arguments["headers"]?.cast<String, String>();
        bool isForMainFrame = call.arguments["isForMainFrame"];
        bool androidHasGesture = call.arguments["androidHasGesture"];
        bool androidIsRedirect = call.arguments["androidIsRedirect"];
        int iosWKNavigationType = call.arguments["iosWKNavigationType"];

        ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest =
        ShouldOverrideUrlLoadingRequest(
            url: url,
            method: method,
            headers: headers,
            isForMainFrame: isForMainFrame,
            androidHasGesture: androidHasGesture,
            androidIsRedirect: androidIsRedirect,
            iosWKNavigationType:
            IOSWKNavigationType.fromValue(iosWKNavigationType));

        if (_webview != null && _webview.shouldOverrideUrlLoading != null)
          return (await _webview.shouldOverrideUrlLoading(
              this, shouldOverrideUrlLoadingRequest))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser
              .shouldOverrideUrlLoading(shouldOverrideUrlLoadingRequest))
              ?.toMap();
        break;
      case "onConsoleMessage":
        String message = call.arguments["message"];
        ConsoleMessageLevel messageLevel =
        ConsoleMessageLevel.fromValue(call.arguments["messageLevel"]);
        ConsoleMessage consoleMessage =
        ConsoleMessage(message: message, messageLevel: messageLevel);
        if (_webview != null && _webview.onConsoleMessage != null)
          _webview.onConsoleMessage(this, consoleMessage);
        else if (_inAppBrowser != null)
          _inAppBrowser.onConsoleMessage(consoleMessage);
        break;
      case "onScrollChanged":
        int x = call.arguments["x"];
        int y = call.arguments["y"];
        if (_webview != null && _webview.onScrollChanged != null)
          _webview.onScrollChanged(this, x, y);
        else if (_inAppBrowser != null) _inAppBrowser.onScrollChanged(x, y);
        break;
      case "onDownloadStart":
        String url = call.arguments["url"];
        if (_webview != null && _webview.onDownloadStart != null)
          _webview.onDownloadStart(this, url);
        else if (_inAppBrowser != null) _inAppBrowser.onDownloadStart(url);
        break;
      case "onLoadResourceCustomScheme":
        String scheme = call.arguments["scheme"];
        String url = call.arguments["url"];
        if (_webview != null && _webview.onLoadResourceCustomScheme != null) {
          try {
            var response =
            await _webview.onLoadResourceCustomScheme(this, scheme, url);
            return (response != null) ? response.toJson() : null;
          } catch (error) {
            print(error);
            return null;
          }
        } else if (_inAppBrowser != null) {
          try {
            var response =
            await _inAppBrowser.onLoadResourceCustomScheme(scheme, url);
            return (response != null) ? response.toJson() : null;
          } catch (error) {
            print(error);
            return null;
          }
        }
        break;
      case "onCreateWindow":
        String url = call.arguments["url"];
        bool androidIsDialog = call.arguments["androidIsDialog"];
        bool androidIsUserGesture = call.arguments["androidIsUserGesture"];
        int iosWKNavigationType = call.arguments["iosWKNavigationType"];

        OnCreateWindowRequest onCreateWindowRequest = OnCreateWindowRequest(
            url: url,
            androidIsDialog: androidIsDialog,
            androidIsUserGesture: androidIsUserGesture,
            iosWKNavigationType:
            IOSWKNavigationType.fromValue(iosWKNavigationType));

        if (_webview != null && _webview.onCreateWindow != null)
          _webview.onCreateWindow(this, onCreateWindowRequest);
        else if (_inAppBrowser != null)
          _inAppBrowser.onCreateWindow(onCreateWindowRequest);
        break;
      case "onGeolocationPermissionsShowPrompt":
        String origin = call.arguments["origin"];
        if (_webview != null &&
            _webview.androidOnGeolocationPermissionsShowPrompt != null)
          return (await _webview.androidOnGeolocationPermissionsShowPrompt(
              this, origin))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser
              .androidOnGeolocationPermissionsShowPrompt(origin))
              ?.toMap();
        break;
      case "onGeolocationPermissionsHidePrompt":
        if (_webview != null &&
            _webview.androidOnGeolocationPermissionsHidePrompt != null)
          await _webview.androidOnGeolocationPermissionsHidePrompt(this);
        else if (_inAppBrowser != null)
          await _inAppBrowser.androidOnGeolocationPermissionsHidePrompt();
        break;
      case "onJsAlert":
        String message = call.arguments["message"];
        if (_webview != null && _webview.onJsAlert != null)
          return (await _webview.onJsAlert(this, message))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onJsAlert(message))?.toMap();
        break;
      case "onJsConfirm":
        String message = call.arguments["message"];
        if (_webview != null && _webview.onJsConfirm != null)
          return (await _webview.onJsConfirm(this, message))?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onJsConfirm(message))?.toMap();
        break;
      case "onJsPrompt":
        String message = call.arguments["message"];
        String defaultValue = call.arguments["defaultValue"];
        if (_webview != null && _webview.onJsPrompt != null)
          return (await _webview.onJsPrompt(this, message, defaultValue))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onJsPrompt(message, defaultValue))
              ?.toMap();
        break;
      case "onSafeBrowsingHit":
        String url = call.arguments["url"];
        SafeBrowsingThreat threatType =
        SafeBrowsingThreat.fromValue(call.arguments["threatType"]);
        if (_webview != null && _webview.androidOnSafeBrowsingHit != null)
          return (await _webview.androidOnSafeBrowsingHit(this, url, threatType))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.androidOnSafeBrowsingHit(url, threatType))
              ?.toMap();
        break;
      case "onReceivedHttpAuthRequest":
        String host = call.arguments["host"];
        String protocol = call.arguments["protocol"];
        String realm = call.arguments["realm"];
        int port = call.arguments["port"];
        int previousFailureCount = call.arguments["previousFailureCount"];
        var protectionSpace = ProtectionSpace(
            host: host, protocol: protocol, realm: realm, port: port);
        var challenge = HttpAuthChallenge(
            previousFailureCount: previousFailureCount,
            protectionSpace: protectionSpace);
        if (_webview != null && _webview.onReceivedHttpAuthRequest != null)
          return (await _webview.onReceivedHttpAuthRequest(this, challenge))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onReceivedHttpAuthRequest(challenge))
              ?.toMap();
        break;
      case "onReceivedServerTrustAuthRequest":
        String host = call.arguments["host"];
        String protocol = call.arguments["protocol"];
        String realm = call.arguments["realm"];
        int port = call.arguments["port"];
        int error = call.arguments["error"];
        String message = call.arguments["message"];
        Uint8List serverCertificate = call.arguments["serverCertificate"];
        var protectionSpace = ProtectionSpace(
            host: host, protocol: protocol, realm: realm, port: port);
        var challenge = ServerTrustChallenge(
            protectionSpace: protectionSpace,
            error: error,
            message: message,
            serverCertificate: serverCertificate);
        if (_webview != null && _webview.onReceivedServerTrustAuthRequest != null)
          return (await _webview.onReceivedServerTrustAuthRequest(
              this, challenge))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser
              .onReceivedServerTrustAuthRequest(challenge))
              ?.toMap();
        break;
      case "onReceivedClientCertRequest":
        String host = call.arguments["host"];
        String protocol = call.arguments["protocol"];
        String realm = call.arguments["realm"];
        int port = call.arguments["port"];
        var protectionSpace = ProtectionSpace(
            host: host, protocol: protocol, realm: realm, port: port);
        var challenge = ClientCertChallenge(protectionSpace: protectionSpace);
        if (_webview != null && _webview.onReceivedClientCertRequest != null)
          return (await _webview.onReceivedClientCertRequest(this, challenge))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.onReceivedClientCertRequest(challenge))
              ?.toMap();
        break;
      case "onFindResultReceived":
        int activeMatchOrdinal = call.arguments["activeMatchOrdinal"];
        int numberOfMatches = call.arguments["numberOfMatches"];
        bool isDoneCounting = call.arguments["isDoneCounting"];
        if (_webview != null && _webview.onFindResultReceived != null)
          _webview.onFindResultReceived(
              this, activeMatchOrdinal, numberOfMatches, isDoneCounting);
        else if (_inAppBrowser != null)
          _inAppBrowser.onFindResultReceived(
              activeMatchOrdinal, numberOfMatches, isDoneCounting);
        break;
      case "onPermissionRequest":
        String origin = call.arguments["origin"];
        List<String> resources = call.arguments["resources"].cast<String>();
        if (_webview != null && _webview.androidOnPermissionRequest != null)
          return (await _webview.androidOnPermissionRequest(
              this, origin, resources))
              ?.toMap();
        else if (_inAppBrowser != null)
          return (await _inAppBrowser.androidOnPermissionRequest(
              origin, resources))
              ?.toMap();
        break;
      case "onUpdateVisitedHistory":
        String url = call.arguments["url"];
        bool androidIsReload = call.arguments["androidIsReload"];
        if (_webview != null && _webview.onUpdateVisitedHistory != null)
          _webview.onUpdateVisitedHistory(this, url, androidIsReload);
        else if (_inAppBrowser != null)
          _inAppBrowser.onUpdateVisitedHistory(url, androidIsReload);
        return null;
      case "onWebContentProcessDidTerminate":
        if (_webview != null &&
            _webview.iosOnWebContentProcessDidTerminate != null)
          _webview.iosOnWebContentProcessDidTerminate(this);
        else if (_inAppBrowser != null)
          _inAppBrowser.iosOnWebContentProcessDidTerminate();
        break;
      case "onDidCommit":
        if (_webview != null && _webview.iosOnDidCommit != null)
          _webview.iosOnDidCommit(this);
        else if (_inAppBrowser != null) _inAppBrowser.iosOnDidCommit();
        break;
      case "onDidReceiveServerRedirectForProvisionalNavigation":
        if (_webview != null &&
            _webview.iosOnDidReceiveServerRedirectForProvisionalNavigation !=
                null)
          _webview.iosOnDidReceiveServerRedirectForProvisionalNavigation(this);
        else if (_inAppBrowser != null)
          _inAppBrowser.iosOnDidReceiveServerRedirectForProvisionalNavigation();
        break;
      case "onLongPressHitTestResult":
        Map<dynamic, dynamic> hitTestResultMap =
        call.arguments["hitTestResult"];
        InAppWebViewHitTestResultType type = InAppWebViewHitTestResultType.fromValue(
            hitTestResultMap["type"].toInt());
        String extra = hitTestResultMap["extra"];
        InAppWebViewHitTestResult hitTestResult = InAppWebViewHitTestResult(type: type, extra: extra);

        if (_webview != null && _webview.onLongPressHitTestResult != null)
          _webview.onLongPressHitTestResult(this, hitTestResult);
        else if (_inAppBrowser != null)
          _inAppBrowser.onLongPressHitTestResult(hitTestResult);
        break;
      case "onCreateContextMenu":
        ContextMenu contextMenu;
        if (_webview != null && _webview.contextMenu != null) {
          contextMenu = _webview.contextMenu;
        } else if (_inAppBrowser != null && _inAppBrowser.contextMenu != null) {
          contextMenu = _inAppBrowser.contextMenu;
        }

        if (contextMenu != null && contextMenu.onCreateContextMenu != null) {
          Map<dynamic, dynamic> hitTestResultMap =
          call.arguments["hitTestResult"];
          InAppWebViewHitTestResultType type = InAppWebViewHitTestResultType.fromValue(
              hitTestResultMap["type"].toInt());
          String extra = hitTestResultMap["extra"];
          InAppWebViewHitTestResult hitTestResult = InAppWebViewHitTestResult(type: type, extra: extra);

          contextMenu.onCreateContextMenu(hitTestResult);
        }
        break;
      case "onHideContextMenu":
        ContextMenu contextMenu;
        if (_webview != null && _webview.contextMenu != null) {
          contextMenu = _webview.contextMenu;
        } else if (_inAppBrowser != null && _inAppBrowser.contextMenu != null) {
          contextMenu = _inAppBrowser.contextMenu;
        }

        if (contextMenu != null && contextMenu.onHideContextMenu != null) {
          contextMenu.onHideContextMenu();
        }
        break;
      case "onContextMenuActionItemClicked":
        ContextMenu contextMenu;
        if (_webview != null && _webview.contextMenu != null) {
          contextMenu = _webview.contextMenu;
        } else if (_inAppBrowser != null && _inAppBrowser.contextMenu != null) {
          contextMenu = _inAppBrowser.contextMenu;
        }

        if (contextMenu != null) {
          int androidId = call.arguments["androidId"];
          String iosId = call.arguments["iosId"];
          String title = call.arguments["title"];

          ContextMenuItem menuItemClicked = ContextMenuItem(androidId: androidId, iosId: iosId, title: title, action: null);

          for (var menuItem in contextMenu.menuItems) {
            if ((Platform.isAndroid && menuItem.androidId == androidId) ||
                (Platform.isIOS && menuItem.iosId == iosId)) {
              menuItemClicked = menuItem;
              menuItem?.action();
              break;
            }
          }

          if (contextMenu.onContextMenuActionItemClicked != null) {
            contextMenu.onContextMenuActionItemClicked(menuItemClicked);
          }
        }
        break;
      case "onEnterFullscreen":
        if (_webview != null &&
            _webview.onEnterFullscreen != null)
          _webview.onEnterFullscreen(this);
        else if (_inAppBrowser != null)
          _inAppBrowser.onEnterFullscreen();
        break;
      case "onExitFullscreen":
        if (_webview != null &&
            _webview.onExitFullscreen != null)
          _webview.onExitFullscreen(this);
        else if (_inAppBrowser != null)
          _inAppBrowser.onExitFullscreen();
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        // decode args to json
        List<dynamic> args = jsonDecode(call.arguments["args"]);

        switch (handlerName) {
          case "androidKeyboardWorkaroundFocusoutEvent":
            // android Workaround to hide the Keyboard when the user click outside
            // on something not focusable such as input or a textarea.
            SystemChannels.textInput.invokeMethod("TextInput.hide");
            break;
          case "onLoadResource":
            Map<dynamic, dynamic> argMap = args[0];
            String initiatorType = argMap["initiatorType"];
            String url = argMap["name"];
            double startTime = argMap["startTime"] is int
                ? argMap["startTime"].toDouble()
                : argMap["startTime"];
            double duration = argMap["duration"] is int
                ? argMap["duration"].toDouble()
                : argMap["duration"];

            var response = new LoadedResource(
                initiatorType: initiatorType,
                url: url,
                startTime: startTime,
                duration: duration);

            if (_webview != null && _webview.onLoadResource != null)
              _webview.onLoadResource(this, response);
            else if (_inAppBrowser != null)
              _inAppBrowser.onLoadResource(response);
            return null;
          case "shouldInterceptAjaxRequest":
            Map<dynamic, dynamic> argMap = args[0];
            dynamic data = argMap["data"];
            String method = argMap["method"];
            String url = argMap["url"];
            bool isAsync = argMap["isAsync"];
            String user = argMap["user"];
            String password = argMap["password"];
            bool withCredentials = argMap["withCredentials"];
            AjaxRequestHeaders headers = AjaxRequestHeaders(argMap["headers"]);
            String responseType = argMap["responseType"];

            var request = new AjaxRequest(
                data: data,
                method: method,
                url: url,
                isAsync: isAsync,
                user: user,
                password: password,
                withCredentials: withCredentials,
                headers: headers,
                responseType: responseType);

            if (_webview != null && _webview.shouldInterceptAjaxRequest != null)
              return jsonEncode(
                  await _webview.shouldInterceptAjaxRequest(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(
                  await _inAppBrowser.shouldInterceptAjaxRequest(request));
            return null;
          case "onAjaxReadyStateChange":
            Map<dynamic, dynamic> argMap = args[0];
            dynamic data = argMap["data"];
            String method = argMap["method"];
            String url = argMap["url"];
            bool isAsync = argMap["isAsync"];
            String user = argMap["user"];
            String password = argMap["password"];
            bool withCredentials = argMap["withCredentials"];
            AjaxRequestHeaders headers = AjaxRequestHeaders(argMap["headers"]);
            int readyState = argMap["readyState"];
            int status = argMap["status"];
            String responseURL = argMap["responseURL"];
            String responseType = argMap["responseType"];
            dynamic response = argMap["response"];
            String responseText = argMap["responseText"];
            String responseXML = argMap["responseXML"];
            String statusText = argMap["statusText"];
            Map<dynamic, dynamic> responseHeaders = argMap["responseHeaders"];

            var request = new AjaxRequest(
                data: data,
                method: method,
                url: url,
                isAsync: isAsync,
                user: user,
                password: password,
                withCredentials: withCredentials,
                headers: headers,
                readyState: AjaxRequestReadyState.fromValue(readyState),
                status: status,
                responseURL: responseURL,
                responseType: responseType,
                response: response,
                responseText: responseText,
                responseXML: responseXML,
                statusText: statusText,
                responseHeaders: responseHeaders);

            if (_webview != null && _webview.onAjaxReadyStateChange != null)
              return jsonEncode(
                  await _webview.onAjaxReadyStateChange(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(
                  await _inAppBrowser.onAjaxReadyStateChange(request));
            return null;
          case "onAjaxProgress":
            Map<dynamic, dynamic> argMap = args[0];
            dynamic data = argMap["data"];
            String method = argMap["method"];
            String url = argMap["url"];
            bool isAsync = argMap["isAsync"];
            String user = argMap["user"];
            String password = argMap["password"];
            bool withCredentials = argMap["withCredentials"];
            AjaxRequestHeaders headers = AjaxRequestHeaders(argMap["headers"]);
            int readyState = argMap["readyState"];
            int status = argMap["status"];
            String responseURL = argMap["responseURL"];
            String responseType = argMap["responseType"];
            dynamic response = argMap["response"];
            String responseText = argMap["responseText"];
            String responseXML = argMap["responseXML"];
            String statusText = argMap["statusText"];
            Map<dynamic, dynamic> responseHeaders = argMap["responseHeaders"];
            Map<dynamic, dynamic> eventMap = argMap["event"];

            AjaxRequestEvent event = AjaxRequestEvent(
                lengthComputable: eventMap["lengthComputable"],
                loaded: eventMap["loaded"],
                total: eventMap["total"],
                type: AjaxRequestEventType.fromValue(eventMap["type"]));

            var request = new AjaxRequest(
                data: data,
                method: method,
                url: url,
                isAsync: isAsync,
                user: user,
                password: password,
                withCredentials: withCredentials,
                headers: headers,
                readyState: AjaxRequestReadyState.fromValue(readyState),
                status: status,
                responseURL: responseURL,
                responseType: responseType,
                response: response,
                responseText: responseText,
                responseXML: responseXML,
                statusText: statusText,
                responseHeaders: responseHeaders,
                event: event);

            if (_webview != null && _webview.onAjaxProgress != null)
              return jsonEncode(await _webview.onAjaxProgress(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(await _inAppBrowser.onAjaxProgress(request));
            return null;
          case "shouldInterceptFetchRequest":
            Map<dynamic, dynamic> argMap = args[0];
            String url = argMap["url"];
            String method = argMap["method"];
            Map<dynamic, dynamic> headers = argMap["headers"];
            Uint8List body = Uint8List.fromList(argMap["body"].cast<int>());
            String mode = argMap["mode"];
            FetchRequestCredential credentials =
            FetchRequest.createFetchRequestCredentialFromMap(
                argMap["credentials"]);
            String cache = argMap["cache"];
            String redirect = argMap["redirect"];
            String referrer = argMap["referrer"];
            String referrerPolicy = argMap["referrerPolicy"];
            String integrity = argMap["integrity"];
            bool keepalive = argMap["keepalive"];

            var request = new FetchRequest(
                url: url,
                method: method,
                headers: headers,
                body: body,
                mode: mode,
                credentials: credentials,
                cache: cache,
                redirect: redirect,
                referrer: referrer,
                referrerPolicy: referrerPolicy,
                integrity: integrity,
                keepalive: keepalive);

            if (_webview != null && _webview.shouldInterceptFetchRequest != null)
              return jsonEncode(
                  await _webview.shouldInterceptFetchRequest(this, request));
            else if (_inAppBrowser != null)
              return jsonEncode(
                  await _inAppBrowser.shouldInterceptFetchRequest(request));
            return null;
          case "onPrint":
            String url = args[0];
            if (_webview != null && _webview.onPrint != null)
              _webview.onPrint(this, url);
            else if (_inAppBrowser != null) _inAppBrowser.onPrint(url);
            return null;
        }

        if (javaScriptHandlersMap.containsKey(handlerName)) {
          // convert result to json
          try {
            return jsonEncode(await javaScriptHandlersMap[handlerName](args));
          } catch (error) {
            print(error);
            return null;
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Gets the URL for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStarted] because although the load for that URL has begun, the current page may not have changed.
  Future<String> getUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getUrl', args);
  }

  ///Gets the title for the current page.
  Future<String> getTitle() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getTitle', args);
  }

  ///Gets the progress for the current page. The progress value is between 0 and 100.
  Future<int> getProgress() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getProgress', args);
  }

  ///Gets the content html of the page. It first tries to get the content through javascript.
  ///If this doesn't work, it tries to get the content reading the file:
  ///- checking if it is an asset (`file:///`) or
  ///- downloading it using an `HttpClient` through the WebView's current url.
  Future<String> getHtml() async {
    var html = "";
    InAppWebViewGroupOptions options = await getOptions();
    if (options != null && options.crossPlatform.javaScriptEnabled == true) {
      html = await evaluateJavascript(
          source: "window.document.getElementsByTagName('html')[0].outerHTML;");
      if (html != null && html.isNotEmpty) return html;
    }

    var webviewUrl = await getUrl();
    if (webviewUrl.startsWith("file:///")) {
      var assetPathSplitted = webviewUrl.split("/flutter_assets/");
      var assetPath = assetPathSplitted[assetPathSplitted.length - 1];
      var bytes = await rootBundle.load(assetPath);
      html = utf8.decode(bytes.buffer.asUint8List());
    } else {
      HttpClient client = new HttpClient();
      var url = Uri.parse(webviewUrl);
      try {
        var htmlRequest = await client.getUrl(url);
        html =
        await (await htmlRequest.close()).transform(Utf8Decoder()).join();
      } catch (e) {
        print(e);
      }
    }
    return html;
  }

  ///Gets the list of all favicons for the current page.
  Future<List<Favicon>> getFavicons() async {
    List<Favicon> favicons = [];

    HttpClient client = new HttpClient();
    var webviewUrl = await getUrl();
    var url = (webviewUrl.startsWith("file:///"))
        ? Uri.file(webviewUrl)
        : Uri.parse(webviewUrl);
    String manifestUrl;

    var html = await getHtml();
    if (html.isEmpty) {
      return favicons;
    }

    var assetPathBase;

    if (webviewUrl.startsWith("file:///")) {
      var assetPathSplitted = webviewUrl.split("/flutter_assets/");
      assetPathBase = assetPathSplitted[0] + "/flutter_assets/";
    }

    // get all link html elements
    var document = parse(html);
    var links = document.getElementsByTagName('link');
    for (var link in links) {
      var attributes = link.attributes;
      if (attributes["rel"] == "manifest") {
        manifestUrl = attributes["href"];
        if (!_isUrlAbsolute(manifestUrl)) {
          if (manifestUrl.startsWith("/")) {
            manifestUrl = manifestUrl.substring(1);
          }
          manifestUrl = ((assetPathBase == null)
              ? url.scheme + "://" + url.host + "/"
              : assetPathBase) +
              manifestUrl;
        }
        continue;
      }
      if (!attributes["rel"].contains("icon")) {
        continue;
      }
      favicons.addAll(_createFavicons(url, assetPathBase, attributes["href"],
          attributes["rel"], attributes["sizes"], false));
    }

    // try to get /favicon.ico
    try {
      var faviconUrl = url.scheme + "://" + url.host + "/favicon.ico";
      await client.headUrl(Uri.parse(faviconUrl));
      favicons.add(Favicon(url: faviconUrl, rel: "shortcut icon"));
    } catch (e) {
      print("/favicon.ico file not found: " + e.toString());
    }

    // try to get the manifest file
    HttpClientRequest manifestRequest;
    HttpClientResponse manifestResponse;
    bool manifestFound = false;
    if (manifestUrl == null) {
      manifestUrl = url.scheme + "://" + url.host + "/manifest.json";
    }
    try {
      manifestRequest = await client.getUrl(Uri.parse(manifestUrl));
      manifestResponse = await manifestRequest.close();
      manifestFound = manifestResponse.statusCode == 200 &&
          manifestResponse.headers.contentType?.mimeType == "application/json";
    } catch (e) {
      print("Manifest file not found: " + e.toString());
    }

    if (manifestFound) {
      Map<String, dynamic> manifest =
      json.decode(await manifestResponse.transform(Utf8Decoder()).join());
      if (manifest.containsKey("icons")) {
        for (Map<String, dynamic> icon in manifest["icons"]) {
          favicons.addAll(_createFavicons(url, assetPathBase, icon["src"],
              icon["rel"], icon["sizes"], true));
        }
      }
    }

    return favicons;
  }

  bool _isUrlAbsolute(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<Favicon> _createFavicons(Uri url, String assetPathBase, String urlIcon,
      String rel, String sizes, bool isManifest) {
    List<Favicon> favicons = [];

    List<String> urlSplitted = urlIcon.split("/");
    if (!_isUrlAbsolute(urlIcon)) {
      if (urlIcon.startsWith("/")) {
        urlIcon = urlIcon.substring(1);
      }
      urlIcon = ((assetPathBase == null)
          ? url.scheme + "://" + url.host + "/"
          : assetPathBase) +
          urlIcon;
    }
    if (isManifest) {
      rel = (sizes != null)
          ? urlSplitted[urlSplitted.length - 1]
          .replaceFirst("-" + sizes, "")
          .split(" ")[0]
          .split(".")[0]
          : null;
    }
    if (sizes != null && sizes.isNotEmpty && sizes != "any") {
      List<String> sizesSplitted = sizes.split(" ");
      for (String size in sizesSplitted) {
        int width = int.parse(size.split("x")[0]);
        int height = int.parse(size.split("x")[1]);
        favicons
            .add(Favicon(url: urlIcon, rel: rel, width: width, height: height));
      }
    } else {
      favicons.add(Favicon(url: urlIcon, rel: rel, width: null, height: null));
    }

    return favicons;
  }

  ///Loads the given [url] with optional [headers] specified as a map from name to value.
  Future<void> loadUrl(
      {@required String url, Map<String, String> headers = const {}}) async {
    assert(url != null && url.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    await _channel.invokeMethod('loadUrl', args);
  }

  ///Loads the given [url] with [postData] using `POST` method into this WebView.
  Future<void> postUrl(
      {@required String url, @required Uint8List postData}) async {
    assert(url != null && url.isNotEmpty);
    assert(postData != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('postData', () => postData);
    await _channel.invokeMethod('postUrl', args);
  }

  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///
  ///The [mimeType] parameter specifies the format of the data. The default value is `"text/html"`.
  ///
  ///The [encoding] parameter specifies the encoding of the data. The default value is `"utf8"`.
  ///
  ///The [androidHistoryUrl] parameter is the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL. This parameter is used only on Android.
  Future<void> loadData(
      {@required String data,
        String mimeType = "text/html",
        String encoding = "utf8",
        String baseUrl = "about:blank",
        String androidHistoryUrl = "about:blank"}) async {
    assert(data != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl);
    args.putIfAbsent('historyUrl', () => androidHistoryUrl);
    await _channel.invokeMethod('loadData', args);
  }

  ///Loads the given [assetFilePath] with optional [headers] specified as a map from name to value.
  ///
  ///To be able to load your local files (assets, js, css, etc.), you need to add them in the `assets` section of the `pubspec.yaml` file, otherwise they cannot be found!
  ///
  ///Example of a `pubspec.yaml` file:
  ///```yaml
  ///...
  ///
  ///# The following section is specific to Flutter.
  ///flutter:
  ///
  ///  # The following line ensures that the Material Icons font is
  ///  # included with your application, so that you can use the icons in
  ///  # the material Icons class.
  ///  uses-material-design: true
  ///
  ///  assets:
  ///    - assets/index.html
  ///    - assets/css/
  ///    - assets/images/
  ///
  ///...
  ///```
  ///Example of a `main.dart` file:
  ///```dart
  ///...
  ///inAppBrowser.loadFile("assets/index.html");
  ///...
  ///```
  Future<void> loadFile(
      {@required String assetFilePath,
        Map<String, String> headers = const {}}) async {
    assert(assetFilePath != null && assetFilePath.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => assetFilePath);
    args.putIfAbsent('headers', () => headers);
    await _channel.invokeMethod('loadFile', args);
  }

  ///Reloads the WebView.
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('reload', args);
  }

  ///Goes back in the history of the WebView.
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('goBack', args);
  }

  ///Returns a boolean value indicating whether the WebView can move backward.
  Future<bool> canGoBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('canGoBack', args);
  }

  ///Goes forward in the history of the WebView.
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('goForward', args);
  }

  ///Returns a boolean value indicating whether the WebView can move forward.
  Future<bool> canGoForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('canGoForward', args);
  }

  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  Future<void> goBackOrForward({@required int steps}) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    await _channel.invokeMethod('goBackOrForward', args);
  }

  ///Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
  Future<bool> canGoBackOrForward({@required int steps}) async {
    assert(steps != null);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    return await _channel.invokeMethod('canGoBackOrForward', args);
  }

  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  Future<void> goTo({@required WebHistoryItem historyItem}) async {
    await goBackOrForward(steps: historyItem.offset);
  }

  ///Check if the WebView instance is in a loading state.
  Future<bool> isLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('isLoading', args);
  }

  ///Stops the WebView from loading.
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('stopLoading', args);
  }

  ///Evaluates JavaScript code into the WebView and returns the result of the evaluation.
  Future<dynamic> evaluateJavascript({@required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    var data = await _channel.invokeMethod('evaluateJavascript', args);
    if (data != null && Platform.isAndroid) data = json.decode(data);
    return data;
  }

  ///Injects an external JavaScript file into the WebView from a defined url.
  Future<void> injectJavascriptFileFromUrl({@required String urlFile}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectJavascriptFileFromUrl', args);
  }

  ///Injects a JavaScript file into the WebView from the flutter assets directory.
  Future<void> injectJavascriptFileFromAsset(
      {@required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    await evaluateJavascript(source: source);
  }

  ///Injects CSS into the WebView.
  Future<void> injectCSSCode({@required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    await _channel.invokeMethod('injectCSSCode', args);
  }

  ///Injects an external CSS file into the WebView from a defined url.
  Future<void> injectCSSFileFromUrl({@required String urlFile}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile);
    await _channel.invokeMethod('injectStyleFile', args);
  }

  ///Injects a CSS file into the WebView from the flutter assets directory.
  Future<void> injectCSSFileFromAsset({@required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    await injectCSSCode(source: source);
  }

  ///Adds a JavaScript message handler [callback] ([JavaScriptHandlerCallback]) that listen to post messages sent from JavaScript by the handler with name [handlerName].
  ///
  ///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
  ///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
  ///
  ///The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
  ///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
  ///
  ///In order to call `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppWebViewPlatformReady`.
  ///This event will be dispatched as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
  ///```javascript
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     console.log("ready");
  ///   });
  ///```
  ///
  ///`window.flutter_inappwebview.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
  ///that can be used to get the json result returned by [JavaScriptHandlerCallback].
  ///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
  ///
  ///So, on the JavaScript side, to get data coming from the Dart side, you will use:
  ///```html
  ///<script>
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     window.flutter_inappwebview.callHandler('handlerFoo').then(function(result) {
  ///       console.log(result);
  ///     });
  ///
  ///     window.flutter_inappwebview.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
  ///       console.log(result);
  ///     });
  ///   });
  ///</script>
  ///```
  ///
  ///Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
  ///```dart
  ///  // Inject JavaScript that will receive data back from Flutter
  ///  inAppWebViewController.evaluateJavascript(source: """
  ///    window.flutter_inappwebview.callHandler('test', 'Text from Javascript').then(function(result) {
  ///      console.log(result);
  ///    });
  ///  """);
  ///```
  ///
  ///Forbidden names for JavaScript handlers are defined in [javaScriptHandlerForbiddenNames].
  void addJavaScriptHandler(
      {@required String handlerName,
        @required JavaScriptHandlerCallback callback}) {
    assert(!javaScriptHandlerForbiddenNames.contains(handlerName));
    this.javaScriptHandlersMap[handlerName] = (callback);
  }

  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler()] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  JavaScriptHandlerCallback removeJavaScriptHandler(
      {@required String handlerName}) {
    return this.javaScriptHandlersMap.remove(handlerName);
  }

  ///Takes a screenshot (in PNG format) of the WebView's visible viewport and returns a `Uint8List`. Returns `null` if it wasn't be able to take it.
  ///
  ///**NOTE for iOS**: available from iOS 11.0+.
  Future<Uint8List> takeScreenshot() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('takeScreenshot', args);
  }

  ///Sets the WebView options with the new [options] and evaluates them.
  Future<void> setOptions({@required InAppWebViewGroupOptions options}) async {
    Map<String, dynamic> args = <String, dynamic>{};

    args.putIfAbsent('options', () => options?.toMap());
    await _channel.invokeMethod('setOptions', args);
  }

  ///Gets the current WebView options. Returns the options with `null` value if they are not set yet.
  Future<InAppWebViewGroupOptions> getOptions() async {
    Map<String, dynamic> args = <String, dynamic>{};

    InAppWebViewGroupOptions inAppWebViewGroupOptions =
    InAppWebViewGroupOptions();
    Map<dynamic, dynamic> options =
    await _channel.invokeMethod('getOptions', args);
    if (options != null) {
      options = options.cast<String, dynamic>();
      inAppWebViewGroupOptions.crossPlatform =
          InAppWebViewOptions.fromMap(options);
      if (Platform.isAndroid)
        inAppWebViewGroupOptions.android =
            AndroidInAppWebViewOptions.fromMap(options);
      else if (Platform.isIOS)
        inAppWebViewGroupOptions.ios = IOSInAppWebViewOptions.fromMap(options);
    }

    return inAppWebViewGroupOptions;
  }

  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  Future<WebHistory> getCopyBackForwardList() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic> result =
    await _channel.invokeMethod('getCopyBackForwardList', args);
    result = result.cast<String, dynamic>();

    List<dynamic> historyListMap = result["history"];
    historyListMap = historyListMap.cast<LinkedHashMap<dynamic, dynamic>>();

    int currentIndex = result["currentIndex"];

    List<WebHistoryItem> historyList = List();
    for (var i = 0; i < historyListMap.length; i++) {
      LinkedHashMap<dynamic, dynamic> historyItem = historyListMap[i];
      historyList.add(WebHistoryItem(
          originalUrl: historyItem["originalUrl"],
          title: historyItem["title"],
          url: historyItem["url"],
          index: i,
          offset: i - currentIndex));
    }
    return WebHistory(list: historyList, currentIndex: currentIndex);
  }

  ///Clears all the webview's cache.
  Future<void> clearCache() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearCache', args);
  }

  ///Finds all instances of find on the page and highlights them. Notifies [onFindResultReceived] listener.
  ///
  ///[find] represents the string to find.
  ///
  ///**NOTE**: on Android, it finds all instances asynchronously. Successive calls to this will cancel any pending searches.
  ///
  ///**NOTE**: on iOS, this is implemented using CSS and Javascript.
  Future<void> findAllAsync({@required String find}) async {
    assert(find != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('find', () => find);
    await _channel.invokeMethod('findAllAsync', args);
  }

  ///Highlights and scrolls to the next match found by [findAllAsync()]. Notifies [onFindResultReceived] listener.
  ///
  ///[forward] represents the direction to search.
  ///
  ///**NOTE**: on iOS, this is implemented using CSS and Javascript.
  Future<void> findNext({@required bool forward}) async {
    assert(forward != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('forward', () => forward);
    await _channel.invokeMethod('findNext', args);
  }

  ///Clears the highlighting surrounding text matches created by [findAllAsync()].
  ///
  ///**NOTE**: on iOS, this is implemented using CSS and Javascript.
  Future<void> clearMatches() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearMatches', args);
  }

  ///Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with [getTRexRunnerCss()].
  Future<String> getTRexRunnerHtml() async {
    return await rootBundle
        .loadString("packages/flutter_inappwebview/t_rex_runner/t-rex.html");
  }

  ///Gets the css of the Chromium's t-rex runner game. Used in combination with [getTRexRunnerHtml()].
  Future<String> getTRexRunnerCss() async {
    return await rootBundle
        .loadString("packages/flutter_inappwebview/t_rex_runner/t-rex.css");
  }

  ///Scrolls the WebView to the position.
  ///
  ///[x] represents the x position to scroll to.
  ///
  ///[y] represents the y position to scroll to.
  Future<void> scrollTo({@required int x, @required int y}) async {
    assert(x != null && y != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    await _channel.invokeMethod('scrollTo', args);
  }

  ///Moves the scrolled position of the WebView.
  ///
  ///[x] represents the amount of pixels to scroll by horizontally.
  ///
  ///[y] represents the amount of pixels to scroll by vertically.
  Future<void> scrollBy({@required int x, @required int y}) async {
    assert(x != null && y != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    await _channel.invokeMethod('scrollBy', args);
  }

  ///On Android, it pauses all layout, parsing, and JavaScript timers for all WebViews.
  ///This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused.
  ///
  ///On iOS, it is restricted to just this WebView.
  Future<void> pauseTimers() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('pauseTimers', args);
  }

  ///On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers.
  ///
  ///On iOS, it resumes all layout, parsing, and JavaScript timers to just this WebView.
  Future<void> resumeTimers() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('resumeTimers', args);
  }

  ///Prints the current page.
  ///
  ///**NOTE**: available on Android 21+.
  Future<void> printCurrentPage() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('printCurrentPage', args);
  }

  ///Gets the height of the HTML content.
  Future<int> getContentHeight() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getContentHeight', args);
  }

  ///Performs a zoom operation in this WebView.
  ///
  ///[zoomFactor] represents the zoom factor to apply. On Android, the zoom factor will be clamped to the Webview's zoom limits and, also, this value must be in the range 0.01 to 100.0 inclusive.
  ///
  ///**NOTE**: available on Android 21+.
  Future<void> zoomBy(double zoomFactor) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('zoomFactor', () => zoomFactor);
    return await _channel.invokeMethod('zoomBy', args);
  }

  ///Gets the current scale of this WebView.
  Future<double> getScale() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getScale', args);
  }

  ///Gets the selected text.
  ///
  ///**NOTE**: This method is implemented with using JavaScript.
  ///Available only on Android 19+.
  Future<String> getSelectedText() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getSelectedText', args);
  }

  ///Gets the hit result for hitting an HTML elements.
  ///
  ///**NOTE**: On iOS it is implemented using JavaScript.
  Future<InAppWebViewHitTestResult> getHitTestResult() async {
    Map<String, dynamic> args = <String, dynamic>{};
    var hitTestResultMap = await _channel.invokeMethod('getHitTestResult', args);
    InAppWebViewHitTestResultType type = InAppWebViewHitTestResultType.fromValue(
        hitTestResultMap["type"].toInt());
    String extra = hitTestResultMap["extra"];
    return InAppWebViewHitTestResult(type: type, extra: extra);
  }

  ///Gets the default user agent.
  static Future<String> getDefaultUserAgent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod('getDefaultUserAgent', args);
  }
}

///InAppWebViewControllerAndroid class represents the Android controller that contains only android-specific methods for the WebView.
class AndroidInAppWebViewController {
  InAppWebViewController _controller;

  AndroidInAppWebViewController(InAppWebViewController controller) {
    this._controller = controller;
  }

  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag
  ///or [AndroidInAppWebViewOptions.safeBrowsingEnabled]. This prepares resources used for Safe Browsing.
  ///
  ///**NOTE**: available only on Android 27+.
  Future<bool> startSafeBrowsing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _controller._channel.invokeMethod('startSafeBrowsing', args);
  }

  ///Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
  ///
  /// Each rule should take one of these:
  ///| Rule | Example | Matches Subdomain |
  ///| -- | -- | -- |
  ///| HOSTNAME | example.com | Yes |
  ///| .HOSTNAME | .example.com | No |
  ///| IPV4_LITERAL | 192.168.1.1 | No |
  ///| IPV6_LITERAL_WITH_BRACKETS | [10:20:30:40:50:60:70:80] | No |
  ///
  ///All other rules, including wildcards, are invalid. The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  ///
  ///[hosts] represents the list of hosts. This value must never be null.
  ///
  ///**NOTE**: available only on Android 27+.
  Future<bool> setSafeBrowsingWhitelist({@required List<String> hosts}) async {
    assert(hosts != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('hosts', () => hosts);
    return await _controller._channel
        .invokeMethod('setSafeBrowsingWhitelist', args);
  }

  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting. This value will never be `null`.
  ///
  ///**NOTE**: available only on Android 27+.
  Future<String> getSafeBrowsingPrivacyPolicyUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _controller._channel
        .invokeMethod('getSafeBrowsingPrivacyPolicyUrl', args);
  }

  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  Future<void> clearSslPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _controller._channel.invokeMethod('clearSslPreferences', args);
  }

  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///
  ///**NOTE**: On iOS certificate-based credentials are never stored permanently.
  ///
  ///**NOTE**: available on Android 21+.
  Future<void> clearClientCertPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _controller._channel.invokeMethod('clearClientCertPreferences', args);
  }

  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [pauseTimers()]. To resume WebView, call [resume()].
  Future<void> pause() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _controller._channel.invokeMethod('pause', args);
  }

  ///Resumes a WebView after a previous call to [pause()].
  Future<void> resume() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _controller._channel.invokeMethod('resume', args);
  }

  ///Gets the URL that was originally requested for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStarted] because although the load for that URL has begun,
  ///the current page may not have changed. Also, there may have been redirects resulting in a different URL to that originally requested.
  Future<String> getOriginalUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _controller._channel.invokeMethod('getOriginalUrl', args);
  }
}

///InAppWebViewControllerIOS class represents the iOS controller that contains only ios-specific methods for the WebView.
class IOSInAppWebViewController {
  InAppWebViewController _controller;

  IOSInAppWebViewController(InAppWebViewController controller) {
    this._controller = controller;
  }

  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _controller._channel.invokeMethod('reloadFromOrigin', args);
  }

  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  Future<bool> hasOnlySecureContent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _controller._channel
        .invokeMethod('hasOnlySecureContent', args);
  }
}
