import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '_static_channel.dart';

/// Object specifying creation parameters for creating a [LinuxInAppWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppWebViewControllerCreationParams] for
/// more information.
@immutable
class LinuxInAppWebViewControllerCreationParams
    extends PlatformInAppWebViewControllerCreationParams {
  /// Creates a new [LinuxInAppWebViewControllerCreationParams] instance.
  const LinuxInAppWebViewControllerCreationParams(
      {required super.id, super.webviewParams});

  /// Creates a [LinuxInAppWebViewControllerCreationParams] instance based on [PlatformInAppWebViewControllerCreationParams].
  factory LinuxInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
      PlatformInAppWebViewControllerCreationParams params) {
    return LinuxInAppWebViewControllerCreationParams(
        id: params.id, webviewParams: params.webviewParams);
  }
}

/// Controls a WebView, such as an [InAppWebView] widget instance.
///
/// If you are using the [InAppWebView] widget, an [InAppWebViewController] instance
/// can be obtained by setting the [InAppWebView.onWebViewCreated] callback.
class LinuxInAppWebViewController extends PlatformInAppWebViewController
    with ChannelController {
  static final MethodChannel _staticChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

  // List of properties to be saved and restored for keep alive feature
  Map<String, Function> _javaScriptHandlersMap = HashMap<String, Function>();
  Map<UserScriptInjectionTime, List<UserScript>> _userScripts = {
    UserScriptInjectionTime.AT_DOCUMENT_START: <UserScript>[],
    UserScriptInjectionTime.AT_DOCUMENT_END: <UserScript>[]
  };
  Set<String> _webMessageListenerObjNames = Set();
  Map<String, ScriptHtmlTagAttributes> _injectedScriptsFromURL = {};

  // static map that contains the properties to be saved and restored for keep alive feature
  static final Map<InAppWebViewKeepAlive, InAppWebViewControllerKeepAliveProps?>
      _keepAliveMap = {};

  dynamic _controllerFromPlatform;

  LinuxInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams params)
      : super.implementation(
            params is LinuxInAppWebViewControllerCreationParams
                ? params
                : LinuxInAppWebViewControllerCreationParams
                    .fromPlatformInAppWebViewControllerCreationParams(params)) {
    channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    handler = _handleMethod;
    initMethodCallHandler();

    final initialUserScripts = webviewParams?.initialUserScripts;
    if (initialUserScripts != null) {
      for (final userScript in initialUserScripts) {
        if (userScript.injectionTime ==
            UserScriptInjectionTime.AT_DOCUMENT_START) {
          this
              ._userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]
              ?.add(userScript);
        } else {
          this
              ._userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]
              ?.add(userScript);
        }
      }
    }

    this._init(params);
  }

  static final LinuxInAppWebViewController _staticValue =
      LinuxInAppWebViewController(
          LinuxInAppWebViewControllerCreationParams(id: null));

  factory LinuxInAppWebViewController.static() {
    return _staticValue;
  }

  void _init(PlatformInAppWebViewControllerCreationParams params) {
    _controllerFromPlatform =
        params.webviewParams?.controllerFromPlatform?.call(this) ?? this;

    if (params.webviewParams is PlatformInAppWebViewWidgetCreationParams) {
      final keepAlive =
          (params.webviewParams as PlatformInAppWebViewWidgetCreationParams)
              .keepAlive;
      if (keepAlive != null) {
        InAppWebViewControllerKeepAliveProps? props = _keepAliveMap[keepAlive];
        if (props == null) {
          // save controller properties to restore it later
          _keepAliveMap[keepAlive] = InAppWebViewControllerKeepAliveProps(
              injectedScriptsFromURL: _injectedScriptsFromURL,
              javaScriptHandlersMap: _javaScriptHandlersMap,
              userScripts: _userScripts,
              webMessageListenerObjNames: _webMessageListenerObjNames);
        } else {
          // restore controller properties
          _injectedScriptsFromURL = props.injectedScriptsFromURL;
          _javaScriptHandlersMap = props.javaScriptHandlersMap;
          _userScripts = props.userScripts;
          _webMessageListenerObjNames = props.webMessageListenerObjNames;
        }
      }
    }
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        name: "WebView",
        id: id?.toString(),
        debugLoggingSettings:
            PlatformInAppWebViewController.debugLoggingSettings,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (PlatformInAppWebViewController.debugLoggingSettings.enabled &&
        call.method != "onCallJsHandler") {
      _debugLog(call.method, call.arguments);
    }

    switch (call.method) {
      case "onLoadStart":
        _injectedScriptsFromURL.clear();
        if (webviewParams != null && webviewParams!.onLoadStart != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          webviewParams!.onLoadStart!(_controllerFromPlatform, uri);
        }
        break;
      case "onLoadStop":
        if (webviewParams != null && webviewParams!.onLoadStop != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          webviewParams!.onLoadStop!(_controllerFromPlatform, uri);
        }
        break;
      case "shouldOverrideUrlLoading":
        if (webviewParams != null &&
            webviewParams!.shouldOverrideUrlLoading != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();

          // Build NavigationAction from arguments
          Map<String, dynamic>? requestMap =
              arguments["request"]?.cast<String, dynamic>();
          WebUri? url;
          if (requestMap != null && requestMap["url"] != null) {
            url = WebUri(requestMap["url"]);
          }

          NavigationAction navigationAction = NavigationAction(
            request: URLRequest(url: url),
            isForMainFrame: arguments["isForMainFrame"] ?? true,
            navigationType: NavigationType.fromNativeValue(
                arguments["navigationType"] ?? 0),
          );

          NavigationActionPolicy? result =
              await webviewParams!.shouldOverrideUrlLoading!(
                  _controllerFromPlatform, navigationAction);

          // Send the decision back to native
          int decisionId = arguments["decisionId"] ?? 0;
          await channel?.invokeMethod('shouldOverrideUrlLoadingResponse', {
            'decisionId': decisionId,
            'action': result?.toNativeValue() ?? 1, // Default to allow
          });

          return result?.toNativeValue();
        }
        break;
      case "onProgressChanged":
        if (webviewParams != null &&
            webviewParams!.onProgressChanged != null) {
          int progress = call.arguments["progress"];
          webviewParams!.onProgressChanged!(_controllerFromPlatform, progress);
        }
        break;
      case "onConsoleMessage":
        if (webviewParams != null && webviewParams!.onConsoleMessage != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          ConsoleMessage consoleMessage = ConsoleMessage.fromMap(arguments)!;
          webviewParams!.onConsoleMessage!(
              _controllerFromPlatform, consoleMessage);
        }
        break;
      case "onTitleChanged":
        if (webviewParams != null && webviewParams!.onTitleChanged != null) {
          String? title = call.arguments["title"];
          webviewParams!.onTitleChanged!(_controllerFromPlatform, title);
        }
        break;
      case "onUpdateVisitedHistory":
        if (webviewParams != null &&
            webviewParams!.onUpdateVisitedHistory != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          bool? isReload = call.arguments["isReload"];
          webviewParams!.onUpdateVisitedHistory!(
              _controllerFromPlatform, uri, isReload);
        }
        break;
      case "onReceivedError":
        if (webviewParams != null && webviewParams!.onReceivedError != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(
              arguments["request"]?.cast<String, dynamic>())!;
          WebResourceError error = WebResourceError.fromMap(
              arguments["error"]?.cast<String, dynamic>())!;
          webviewParams!.onReceivedError!(
              _controllerFromPlatform, request, error);
        }
        break;
      case "onReceivedHttpError":
        if (webviewParams != null &&
            webviewParams!.onReceivedHttpError != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(
              arguments["request"]?.cast<String, dynamic>())!;
          WebResourceResponse errorResponse = WebResourceResponse.fromMap(
              arguments["errorResponse"]?.cast<String, dynamic>())!;
          webviewParams!.onReceivedHttpError!(
              _controllerFromPlatform, request, errorResponse);
        }
        break;
      case "onPageCommitVisible":
        if (webviewParams != null &&
            webviewParams!.onPageCommitVisible != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          webviewParams!.onPageCommitVisible!(_controllerFromPlatform, uri);
        }
        break;
      case "onZoomScaleChanged":
        if (webviewParams != null &&
            webviewParams!.onZoomScaleChanged != null) {
          double oldScale = call.arguments["oldScale"];
          double newScale = call.arguments["newScale"];
          webviewParams!.onZoomScaleChanged!(
              _controllerFromPlatform, oldScale, newScale);
        }
        break;
      case "onScrollChanged":
        if (webviewParams != null && webviewParams!.onScrollChanged != null) {
          int x = call.arguments["x"];
          int y = call.arguments["y"];
          webviewParams!.onScrollChanged!(_controllerFromPlatform, x, y);
        }
        break;
      case "onCloseWindow":
        if (webviewParams != null && webviewParams!.onCloseWindow != null) {
          webviewParams!.onCloseWindow!(_controllerFromPlatform);
        }
        break;
      case "onCreateWindow":
        if (webviewParams != null && webviewParams!.onCreateWindow != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          CreateWindowAction createWindowAction =
              CreateWindowAction.fromMap(arguments)!;
          return await webviewParams!.onCreateWindow!(
              _controllerFromPlatform, createWindowAction);
        }
        return false;
      case "onJsAlert":
        if (webviewParams != null && webviewParams!.onJsAlert != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsAlertRequest jsAlertRequest = JsAlertRequest.fromMap(arguments)!;
          JsAlertResponse? response = await webviewParams!.onJsAlert!(
              _controllerFromPlatform, jsAlertRequest);
          return response?.toMap();
        }
        return null;
      case "onJsConfirm":
        if (webviewParams != null && webviewParams!.onJsConfirm != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsConfirmRequest jsConfirmRequest =
              JsConfirmRequest.fromMap(arguments)!;
          JsConfirmResponse? response = await webviewParams!.onJsConfirm!(
              _controllerFromPlatform, jsConfirmRequest);
          return response?.toMap();
        }
        return null;
      case "onJsPrompt":
        if (webviewParams != null && webviewParams!.onJsPrompt != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsPromptRequest jsPromptRequest = JsPromptRequest.fromMap(arguments)!;
          JsPromptResponse? response = await webviewParams!.onJsPrompt!(
              _controllerFromPlatform, jsPromptRequest);
          return response?.toMap();
        }
        return null;
      case "onJsBeforeUnload":
        if (webviewParams != null && webviewParams!.onJsBeforeUnload != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsBeforeUnloadRequest jsBeforeUnloadRequest =
              JsBeforeUnloadRequest.fromMap(arguments)!;
          JsBeforeUnloadResponse? response =
              await webviewParams!.onJsBeforeUnload!(
                  _controllerFromPlatform, jsBeforeUnloadRequest);
          return response?.toMap();
        }
        return null;
      case "onPermissionRequest":
        if (webviewParams != null &&
            webviewParams!.onPermissionRequest != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          PermissionRequest permissionRequest =
              PermissionRequest.fromMap(arguments)!;
          PermissionResponse? response =
              await webviewParams!.onPermissionRequest!(
                  _controllerFromPlatform, permissionRequest);
          return response?.toMap();
        }
        return null;
      case "onReceivedHttpAuthRequest":
        if (webviewParams != null &&
            webviewParams!.onReceivedHttpAuthRequest != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          HttpAuthenticationChallenge challenge =
              HttpAuthenticationChallenge.fromMap(arguments)!;
          HttpAuthResponse? response =
              await webviewParams!.onReceivedHttpAuthRequest!(
                  _controllerFromPlatform, challenge);
          return response?.toMap();
        }
        return null;
      case "onEnterFullscreen":
        if (webviewParams != null &&
            webviewParams!.onEnterFullscreen != null) {
          webviewParams!.onEnterFullscreen!(_controllerFromPlatform);
        }
        break;
      case "onExitFullscreen":
        if (webviewParams != null && webviewParams!.onExitFullscreen != null) {
          webviewParams!.onExitFullscreen!(_controllerFromPlatform);
        }
        break;
      case "onReceivedIcon":
        if (webviewParams != null && webviewParams!.onReceivedIcon != null) {
          // For now, we just have the URL, not the actual icon data
          // This could be enhanced to download the favicon
          String? faviconUrl = call.arguments["url"];
          if (faviconUrl != null) {
            // Create a placeholder Uint8List since we don't have the actual icon
            // The favicon URL could be used to download the icon if needed
            webviewParams!.onReceivedIcon!(
                _controllerFromPlatform, Uint8List(0));
          }
        }
        break;
      case "onCallJsHandler":
        if (webviewParams != null) {
          String handlerName = call.arguments["handlerName"];
          // Arguments are passed as a JSON string
          Map<String, dynamic>? data =
              call.arguments["data"]?.cast<String, dynamic>();
          Function? jsHandler = _javaScriptHandlersMap[handlerName];
          if (jsHandler != null) {
            // Decode args from JSON string
            List<dynamic> args = [];
            if (data != null && data["args"] != null) {
              try {
                args = jsonDecode(data["args"]);
              } catch (_) {}
            }
            return await jsHandler(args);
          }
        }
        break;
    }
    return null;
  }

  @override
  Future<WebUri?> getUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await channel?.invokeMethod<String?>('getUrl', args);
    return url != null ? WebUri(url) : null;
  }

  @override
  Future<String?> getTitle() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getTitle', args);
  }

  @override
  Future<void> loadUrl(
      {required URLRequest urlRequest,
      @Deprecated('Use allowingReadAccessTo instead')
      Uri? iosAllowingReadAccessTo,
      WebUri? allowingReadAccessTo}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    args.putIfAbsent('allowingReadAccessTo',
        () => allowingReadAccessTo?.toString() ?? iosAllowingReadAccessTo?.toString());
    await channel?.invokeMethod('loadUrl', args);
  }

  @override
  Future<void> loadData(
      {required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      WebUri? baseUrl,
      @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
      WebUri? historyUrl,
      @Deprecated('Use allowingReadAccessTo instead')
      Uri? iosAllowingReadAccessTo,
      WebUri? allowingReadAccessTo}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? 'about:blank');
    await channel?.invokeMethod('loadData', args);
  }

  @override
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('reload', args);
  }

  @override
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('goBack', args);
  }

  @override
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('goForward', args);
  }

  @override
  Future<bool> canGoBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canGoBack', args) ?? false;
  }

  @override
  Future<bool> canGoForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canGoForward', args) ?? false;
  }

  @override
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('stopLoading', args);
  }

  @override
  Future<bool> isLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isLoading', args) ?? false;
  }

  @override
  Future<int?> getProgress() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getProgress', args);
  }

  @override
  Future<void> loadFile({required String assetFilePath}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('assetFilePath', () => assetFilePath);
    await channel?.invokeMethod('loadFile', args);
  }

  @override
  Future<dynamic> evaluateJavascript(
      {required String source, ContentWorld? contentWorld}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    if (contentWorld != null) {
      args.putIfAbsent('contentWorld', () => contentWorld.toMap());
    }
    var result = await channel?.invokeMethod('evaluateJavascript', args);
    if (result != null && result is String) {
      try {
        result = jsonDecode(result);
      } catch (e) {}
    }
    return result;
  }

  @override
  Future<void> injectJavascriptFileFromUrl(
      {required WebUri urlFile,
      ScriptHtmlTagAttributes? scriptHtmlTagAttributes}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
        'scriptHtmlTagAttributes', () => scriptHtmlTagAttributes?.toMap());
    await channel?.invokeMethod('injectJavascriptFileFromUrl', args);
  }

  @override
  Future<void> injectCSSCode({required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    await channel?.invokeMethod('injectCSSCode', args);
  }

  @override
  Future<void> injectCSSFileFromUrl(
      {required WebUri urlFile,
      CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
        'cssLinkHtmlTagAttributes', () => cssLinkHtmlTagAttributes?.toMap());
    await channel?.invokeMethod('injectCSSFileFromUrl', args);
  }

  @override
  Future<String?> getHtml() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getHtml', args);
  }

  @override
  Future<double?> getZoomScale() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<double?>('getZoomScale', args);
  }

  @override
  Future<void> zoomBy(
      {required double zoomFactor,
      @Deprecated('Use animated instead') bool? iosAnimated,
      bool animated = false}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('zoomFactor', () => zoomFactor);
    await channel?.invokeMethod('setZoomScale', args);
  }

  @override
  Future<void> scrollTo(
      {required int x,
      required int y,
      bool animated = false}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollTo', args);
  }

  @override
  Future<void> scrollBy(
      {required int x,
      required int y,
      bool animated = false}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollBy', args);
  }

  @override
  Future<int?> getScrollX() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getScrollX', args);
  }

  @override
  Future<int?> getScrollY() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getScrollY', args);
  }

  @override
  Future<InAppWebViewSettings?> getSettings() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? settings =
        await channel?.invokeMethod('getSettings', args);
    if (settings != null) {
      settings = settings.cast<String, dynamic>();
      return InAppWebViewSettings.fromMap(settings as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> setSettings({required InAppWebViewSettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('settings', () => settings.toMap());
    await channel?.invokeMethod('setSettings', args);
  }

  @override
  void addJavaScriptHandler(
      {required String handlerName,
      required Function callback}) {
    assert(!kJavaScriptHandlerForbiddenNames.contains(handlerName),
        '"$handlerName" is a reserved name and cannot be used as a JavaScript handler name.');
    _javaScriptHandlersMap[handlerName] = callback;
  }

  @override
  Function? removeJavaScriptHandler(
      {required String handlerName}) {
    return _javaScriptHandlersMap.remove(handlerName);
  }

  @override
  bool hasJavaScriptHandler({required String handlerName}) {
    return _javaScriptHandlersMap.containsKey(handlerName);
  }

  @override
  Future<void> addUserScript({required UserScript userScript}) async {
    // Note: WebKitGTK doesn't support content worlds like WKWebView,
    // so we ignore the contentWorld parameter
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('userScript', () => userScript.toMap());
    await channel?.invokeMethod('addUserScript', args);
    
    _userScripts[userScript.injectionTime]?.add(userScript);
  }

  @override
  Future<void> addUserScripts({required List<UserScript> userScripts}) async {
    for (var userScript in userScripts) {
      await addUserScript(userScript: userScript);
    }
  }

  @override
  Future<bool> removeUserScript({required UserScript userScript}) async {
    var index = _userScripts[userScript.injectionTime]?.indexOf(userScript) ?? -1;
    if (index == -1) {
      return false;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => index);
    args.putIfAbsent('injectionTime', () => userScript.injectionTime.toNativeValue());
    await channel?.invokeMethod('removeUserScript', args);

    _userScripts[userScript.injectionTime]?.remove(userScript);
    return true;
  }

  @override
  Future<void> removeUserScriptsByGroupName({required String groupName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('groupName', () => groupName);
    await channel?.invokeMethod('removeUserScriptsByGroupName', args);

    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]
        ?.removeWhere((element) => element.groupName == groupName);
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]
        ?.removeWhere((element) => element.groupName == groupName);
  }

  @override
  Future<void> removeUserScripts({required List<UserScript> userScripts}) async {
    for (var userScript in userScripts) {
      await removeUserScript(userScript: userScript);
    }
  }

  @override
  Future<void> removeAllUserScripts() async {
    await channel?.invokeMethod('removeAllUserScripts', {});
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.clear();
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.clear();
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
  }
}

extension InternalInAppWebViewController on LinuxInAppWebViewController {
  get handleMethod => _handleMethod;
}
