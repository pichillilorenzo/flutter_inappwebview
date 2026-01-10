import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../web_message/web_message_channel.dart';
import '../web_message/web_message_listener.dart';
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
  const LinuxInAppWebViewControllerCreationParams({
    required super.id,
    super.webviewParams,
  });

  /// Creates a [LinuxInAppWebViewControllerCreationParams] instance based on [PlatformInAppWebViewControllerCreationParams].
  factory LinuxInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return LinuxInAppWebViewControllerCreationParams(
      id: params.id,
      webviewParams: params.webviewParams,
    );
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
    UserScriptInjectionTime.AT_DOCUMENT_END: <UserScript>[],
  };
  Set<LinuxWebMessageListener> _webMessageListeners = Set();
  Set<String> _webMessageListenerObjNames = Set();
  Set<LinuxWebMessageChannel> _webMessageChannels = Set();
  Map<String, ScriptHtmlTagAttributes> _injectedScriptsFromURL = {};

  // static map that contains the properties to be saved and restored for keep alive feature
  static final Map<InAppWebViewKeepAlive, InAppWebViewControllerKeepAliveProps?>
  _keepAliveMap = {};

  dynamic _controllerFromPlatform;

  LinuxInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) : super.implementation(
        params is LinuxInAppWebViewControllerCreationParams
            ? params
            : LinuxInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    handler = _handleMethod;
    initMethodCallHandler();

    final initialUserScripts = webviewParams?.initialUserScripts;
    if (initialUserScripts != null) {
      for (final userScript in initialUserScripts) {
        if (userScript.injectionTime ==
            UserScriptInjectionTime.AT_DOCUMENT_START) {
          this._userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.add(
            userScript,
          );
        } else {
          this._userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.add(
            userScript,
          );
        }
      }
    }

    this._init(params);
  }

  static final LinuxInAppWebViewController _staticValue =
      LinuxInAppWebViewController(
        LinuxInAppWebViewControllerCreationParams(id: null),
      );

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
            webMessageListenerObjNames: _webMessageListenerObjNames,
          );
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
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: method,
      args: args,
    );
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
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          NavigationAction navigationAction = NavigationAction.fromMap(
            arguments,
          )!;

          NavigationActionPolicy? result =
              await webviewParams!.shouldOverrideUrlLoading!(
                _controllerFromPlatform,
                navigationAction,
              );

          // Return the decision directly to native (supports invokeMethodWithResult pattern)
          return result?.toNativeValue();
        }
        break;
      case "onProgressChanged":
        if (webviewParams != null && webviewParams!.onProgressChanged != null) {
          int progress = call.arguments["progress"];
          webviewParams!.onProgressChanged!(_controllerFromPlatform, progress);
        }
        break;
      case "onConsoleMessage":
        if (webviewParams != null && webviewParams!.onConsoleMessage != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ConsoleMessage consoleMessage = ConsoleMessage.fromMap(arguments)!;
          webviewParams!.onConsoleMessage!(
            _controllerFromPlatform,
            consoleMessage,
          );
        }
        break;
      case "onLoadResource":
        if (webviewParams != null && webviewParams!.onLoadResource != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          LoadedResource resource = LoadedResource.fromMap(arguments)!;
          webviewParams!.onLoadResource!(_controllerFromPlatform, resource);
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
            _controllerFromPlatform,
            uri,
            isReload,
          );
        }
        break;
      case "onReceivedError":
        if (webviewParams != null && webviewParams!.onReceivedError != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(
            arguments["request"]?.cast<String, dynamic>(),
          )!;
          WebResourceError error = WebResourceError.fromMap(
            arguments["error"]?.cast<String, dynamic>(),
          )!;
          webviewParams!.onReceivedError!(
            _controllerFromPlatform,
            request,
            error,
          );
        }
        break;
      case "onReceivedHttpError":
        if (webviewParams != null &&
            webviewParams!.onReceivedHttpError != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(
            arguments["request"]?.cast<String, dynamic>(),
          )!;
          WebResourceResponse errorResponse = WebResourceResponse.fromMap(
            arguments["errorResponse"]?.cast<String, dynamic>(),
          )!;
          webviewParams!.onReceivedHttpError!(
            _controllerFromPlatform,
            request,
            errorResponse,
          );
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
            _controllerFromPlatform,
            oldScale,
            newScale,
          );
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
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          CreateWindowAction createWindowAction = CreateWindowAction.fromMap(
            arguments,
          )!;
          return await webviewParams!.onCreateWindow!(
            _controllerFromPlatform,
            createWindowAction,
          );
        }
        return false;
      case "onJsAlert":
        if (webviewParams != null && webviewParams!.onJsAlert != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsAlertRequest jsAlertRequest = JsAlertRequest.fromMap(arguments)!;
          JsAlertResponse? response = await webviewParams!.onJsAlert!(
            _controllerFromPlatform,
            jsAlertRequest,
          );
          return response?.toMap();
        }
        return null;
      case "onJsConfirm":
        if (webviewParams != null && webviewParams!.onJsConfirm != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsConfirmRequest jsConfirmRequest = JsConfirmRequest.fromMap(
            arguments,
          )!;
          JsConfirmResponse? response = await webviewParams!.onJsConfirm!(
            _controllerFromPlatform,
            jsConfirmRequest,
          );
          return response?.toMap();
        }
        return null;
      case "onJsPrompt":
        if (webviewParams != null && webviewParams!.onJsPrompt != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsPromptRequest jsPromptRequest = JsPromptRequest.fromMap(arguments)!;
          JsPromptResponse? response = await webviewParams!.onJsPrompt!(
            _controllerFromPlatform,
            jsPromptRequest,
          );
          return response?.toMap();
        }
        return null;
      case "onJsBeforeUnload":
        if (webviewParams != null && webviewParams!.onJsBeforeUnload != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsBeforeUnloadRequest jsBeforeUnloadRequest =
              JsBeforeUnloadRequest.fromMap(arguments)!;
          JsBeforeUnloadResponse? response =
              await webviewParams!.onJsBeforeUnload!(
                _controllerFromPlatform,
                jsBeforeUnloadRequest,
              );
          return response?.toMap();
        }
        return null;
      case "onPermissionRequest":
        if (webviewParams != null &&
            webviewParams!.onPermissionRequest != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          PermissionRequest permissionRequest = PermissionRequest.fromMap(
            arguments,
          )!;
          PermissionResponse? response = await webviewParams!
              .onPermissionRequest!(_controllerFromPlatform, permissionRequest);
          return response?.toMap();
        }
        return null;
      case "onReceivedHttpAuthRequest":
        if (webviewParams != null &&
            webviewParams!.onReceivedHttpAuthRequest != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          HttpAuthenticationChallenge challenge =
              HttpAuthenticationChallenge.fromMap(arguments)!;
          HttpAuthResponse? response = await webviewParams!
              .onReceivedHttpAuthRequest!(_controllerFromPlatform, challenge);
          return response?.toMap();
        }
        return null;
      case "onReceivedServerTrustAuthRequest":
        if (webviewParams != null &&
            webviewParams!.onReceivedServerTrustAuthRequest != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ServerTrustChallenge challenge = ServerTrustChallenge.fromMap(
            arguments,
          )!;
          ServerTrustAuthResponse? response =
              await webviewParams!.onReceivedServerTrustAuthRequest!(
                _controllerFromPlatform,
                challenge,
              );
          return response?.toMap();
        }
        return null;
      case "onReceivedClientCertRequest":
        if (webviewParams != null &&
            webviewParams!.onReceivedClientCertRequest != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ClientCertChallenge challenge = ClientCertChallenge.fromMap(
            arguments,
          )!;
          ClientCertResponse? response =
              await webviewParams!.onReceivedClientCertRequest!(
                _controllerFromPlatform,
                challenge,
              );
          return response?.toMap();
        }
        return null;
      case "onDownloadStarting":
        if (webviewParams != null &&
            (webviewParams!.onDownloadStart != null ||
                webviewParams!.onDownloadStartRequest != null ||
                webviewParams!.onDownloadStarting != null)) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          DownloadStartRequest downloadStartRequest =
              DownloadStartRequest.fromMap(arguments)!;

          if (webviewParams!.onDownloadStarting != null) {
            return (await webviewParams!.onDownloadStarting!(
              _controllerFromPlatform,
              downloadStartRequest,
            ))?.toMap();
          } else if (webviewParams!.onDownloadStartRequest != null) {
            webviewParams!.onDownloadStartRequest!(
              _controllerFromPlatform,
              downloadStartRequest,
            );
          } else {
            webviewParams!.onDownloadStart!(
              _controllerFromPlatform,
              downloadStartRequest.url,
            );
          }
        }
        return null;
      case "onEnterFullscreen":
        if (webviewParams != null && webviewParams!.onEnterFullscreen != null) {
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
              _controllerFromPlatform,
              Uint8List(0),
            );
          }
        }
        break;
      case "onCreateContextMenu":
        ContextMenu? contextMenu = webviewParams?.contextMenu;
        if (contextMenu != null && contextMenu.onCreateContextMenu != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          InAppWebViewHitTestResult hitTestResult =
              InAppWebViewHitTestResult.fromMap(arguments)!;
          contextMenu.onCreateContextMenu!(hitTestResult);
        }
        break;
      case "onHideContextMenu":
        ContextMenu? contextMenu = webviewParams?.contextMenu;
        if (contextMenu != null && contextMenu.onHideContextMenu != null) {
          contextMenu.onHideContextMenu!();
        }
        break;
      case "onContextMenuActionItemClicked":
        ContextMenu? contextMenu = webviewParams?.contextMenu;
        if (contextMenu != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          String id = arguments["id"] ?? "";
          String title = arguments["title"] ?? "";

          ContextMenuItem menuItemClicked = ContextMenuItem(
            id: id,
            title: title,
            action: null,
          );

          // Check if this matches any custom menu items
          for (var menuItem in contextMenu.menuItems) {
            if (menuItem.id == id) {
              menuItemClicked = menuItem;
              if (menuItem.action != null) {
                menuItem.action!();
              }
              break;
            }
          }

          if (contextMenu.onContextMenuActionItemClicked != null) {
            contextMenu.onContextMenuActionItemClicked!(menuItemClicked);
          }
        }
        break;

      case "onRenderProcessGone":
        if (webviewParams != null &&
            webviewParams!.onRenderProcessGone != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          RenderProcessGoneDetail detail = RenderProcessGoneDetail.fromMap(
            arguments,
          )!;
          webviewParams!.onRenderProcessGone!(_controllerFromPlatform, detail);
        }
        break;
      case "onShowFileChooser":
        if (webviewParams != null && webviewParams!.onShowFileChooser != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ShowFileChooserRequest request = ShowFileChooserRequest.fromMap(
            arguments,
          )!;
          ShowFileChooserResponse? response = await webviewParams!
              .onShowFileChooser!(_controllerFromPlatform, request);
          // Return file paths list or null
          return response?.filePaths;
        }
        return null;
      // onFindResultReceived is now handled by FindInteractionController
      case "onLoadResourceWithCustomScheme":
        if (webviewParams != null &&
            (webviewParams!.onLoadResourceWithCustomScheme != null ||
                // ignore: deprecated_member_use_from_same_package
                webviewParams!.onLoadResourceCustomScheme != null)) {
          Map<String, dynamic> requestMap = call.arguments
              .cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(requestMap)!;

          if (webviewParams!.onLoadResourceWithCustomScheme != null) {
            return (await webviewParams!.onLoadResourceWithCustomScheme!(
              _controllerFromPlatform,
              request,
            ))?.toMap();
          } else {
            return (await webviewParams!
                    // ignore: deprecated_member_use_from_same_package
                    .onLoadResourceCustomScheme!(
                  _controllerFromPlatform,
                  request.url,
                ))
                ?.toMap();
          }
        }
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        Map<String, dynamic> handlerDataMap = call.arguments["data"]
            .cast<String, dynamic>();
        // decode args to json
        handlerDataMap["args"] = jsonDecode(handlerDataMap["args"]);
        final handlerData = JavaScriptHandlerFunctionData.fromMap(
          handlerDataMap,
        )!;

        _debugLog(handlerName, handlerData);

        switch (handlerName) {
          case "onLoadResource":
            if (webviewParams != null &&
                webviewParams!.onLoadResource != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              arguments["startTime"] = arguments["startTime"] is int
                  ? arguments["startTime"].toDouble()
                  : arguments["startTime"];
              arguments["duration"] = arguments["duration"] is int
                  ? arguments["duration"].toDouble()
                  : arguments["duration"];

              var response = LoadedResource.fromMap(arguments)!;
              webviewParams!.onLoadResource!(_controllerFromPlatform, response);
            }
            return null;
          case "shouldInterceptAjaxRequest":
            if (webviewParams != null &&
                webviewParams!.shouldInterceptAjaxRequest != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;
              return jsonEncode(
                await webviewParams!.shouldInterceptAjaxRequest!(
                  _controllerFromPlatform,
                  request,
                ),
              );
            }
            return null;
          case "onAjaxReadyStateChange":
            if (webviewParams != null &&
                webviewParams!.onAjaxReadyStateChange != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;
              return jsonEncode(
                (await webviewParams!.onAjaxReadyStateChange!(
                  _controllerFromPlatform,
                  request,
                ))?.toNativeValue(),
              );
            }
            return null;
          case "onAjaxProgress":
            if (webviewParams != null &&
                webviewParams!.onAjaxProgress != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;
              return jsonEncode(
                (await webviewParams!.onAjaxProgress!(
                  _controllerFromPlatform,
                  request,
                ))?.toNativeValue(),
              );
            }
            return null;
          case "shouldInterceptFetchRequest":
            if (webviewParams != null &&
                webviewParams!.shouldInterceptFetchRequest != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              FetchRequest request = FetchRequest.fromMap(arguments)!;
              return jsonEncode(
                await webviewParams!.shouldInterceptFetchRequest!(
                  _controllerFromPlatform,
                  request,
                ),
              );
            }
            return null;
          case "onWindowFocus":
            if (webviewParams != null && webviewParams!.onWindowFocus != null)
              webviewParams!.onWindowFocus!(_controllerFromPlatform);
            return null;
          case "onWindowBlur":
            if (webviewParams != null && webviewParams!.onWindowBlur != null)
              webviewParams!.onWindowBlur!(_controllerFromPlatform);
            return null;
          case "onInjectedScriptLoaded":
            String id = handlerData.args[0];
            var onLoadCallback = _injectedScriptsFromURL[id]?.onLoad;
            if (webviewParams != null && onLoadCallback != null) {
              onLoadCallback();
            }
            return null;
          case "onInjectedScriptError":
            String id = handlerData.args[0];
            var onErrorCallback = _injectedScriptsFromURL[id]?.onError;
            if (webviewParams != null && onErrorCallback != null) {
              onErrorCallback();
            }
            return null;
          case "onWebMessageListenerPostMessageReceived":
            Map<String, dynamic> arguments = handlerData.args[0]
                .cast<String, dynamic>();
            String jsObjectName = arguments["jsObjectName"];
            // Find the corresponding web message listener
            for (var listener in _webMessageListeners) {
              if (listener.params.jsObjectName == jsObjectName) {
                // Forward to the listener's channel
                Map<String, dynamic>? messageMap = arguments["message"]
                    ?.cast<String, dynamic>();
                WebMessage? message = messageMap != null
                    ? WebMessage.fromMap(messageMap)
                    : null;
                String? sourceOrigin = arguments["sourceOrigin"];
                bool isMainFrame = arguments["isMainFrame"] ?? true;
                // Call the listener's onPostMessage callback via channel
                listener.channel?.invokeMethod("onPostMessage", {
                  "message": message?.toMap(),
                  "sourceOrigin": sourceOrigin,
                  "isMainFrame": isMainFrame,
                });
                break;
              }
            }
            return null;
          case "onWebMessagePortMessageReceived":
            Map<String, dynamic> arguments = handlerData.args[0]
                .cast<String, dynamic>();
            String webMessageChannelId = arguments["webMessageChannelId"];
            int index = arguments["index"];
            // Find the channel and forward the message
            for (var webMessageChannel in _webMessageChannels) {
              if (webMessageChannel.id == webMessageChannelId) {
                Map<String, dynamic>? messageMap = arguments["message"]
                    ?.cast<String, dynamic>();
                WebMessage? message = messageMap != null
                    ? WebMessage.fromMap(messageMap)
                    : null;
                webMessageChannel.internalChannel?.invokeMethod("onMessage", {
                  "index": index,
                  "message": message?.toMap(),
                });
                break;
              }
            }
            return null;
        }

        if (_javaScriptHandlersMap.containsKey(handlerName)) {
          // convert result to json
          try {
            var jsHandlerResult = null;
            if (_javaScriptHandlersMap[handlerName]
                is JavaScriptHandlerCallback) {
              jsHandlerResult =
                  await (_javaScriptHandlersMap[handlerName]
                      as JavaScriptHandlerCallback)(handlerData.args);
            } else if (_javaScriptHandlersMap[handlerName]
                is JavaScriptHandlerFunction) {
              jsHandlerResult =
                  await (_javaScriptHandlersMap[handlerName]
                      as JavaScriptHandlerFunction)(handlerData);
            } else {
              jsHandlerResult = await _javaScriptHandlersMap[handlerName]!();
            }
            return jsonEncode(jsHandlerResult);
          } catch (error, stacktrace) {
            developer.log(
              error.toString() + '\n' + stacktrace.toString(),
              name: 'JavaScript Handler "$handlerName"',
            );
            throw Exception(error.toString().replaceFirst('Exception: ', ''));
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
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
  Future<void> loadUrl({
    required URLRequest urlRequest,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    args.putIfAbsent(
      'allowingReadAccessTo',
      () =>
          allowingReadAccessTo?.toString() ??
          iosAllowingReadAccessTo?.toString(),
    );
    await channel?.invokeMethod('loadUrl', args);
  }

  @override
  Future<void> loadData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
    WebUri? historyUrl,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? 'about:blank');
    await channel?.invokeMethod('loadData', args);
  }

  @override
  Future<void> postUrl({
    required WebUri url,
    required Uint8List postData,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('postData', () => postData);
    await channel?.invokeMethod('postUrl', args);
  }

  @override
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('reload', args);
  }

  @override
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('reloadFromOrigin', args);
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
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
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
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic> arguments = const <String, dynamic>{},
    ContentWorld? contentWorld,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('functionBody', () => functionBody);
    // JSON encode arguments to handle complex types (arrays, nested objects)
    // that WPE WebKit's GVariant a{sv} format doesn't support directly
    args.putIfAbsent('arguments', () => jsonEncode(arguments));
    args.putIfAbsent('argumentKeys', () => arguments.keys.toList());
    if (contentWorld != null) {
      args.putIfAbsent('contentWorld', () => contentWorld.toMap());
    }

    // Native returns a JSON string: {"value": ..., "error": ...}
    String? jsonResult = await channel?.invokeMethod<String?>(
      'callAsyncJavaScript',
      args,
    );

    if (jsonResult != null) {
      try {
        Map<String, dynamic> result = jsonDecode(jsonResult);
        return CallAsyncJavaScriptResult(
          value: result['value'],
          error: result['error'],
        );
      } catch (e) {
        return CallAsyncJavaScriptResult(
          value: null,
          error: 'Failed to decode result: $e',
        );
      }
    }
    return null;
  }

  @override
  Future<void> injectJavascriptFileFromUrl({
    required WebUri urlFile,
    ScriptHtmlTagAttributes? scriptHtmlTagAttributes,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
      'scriptHtmlTagAttributes',
      () => scriptHtmlTagAttributes?.toMap(),
    );
    await channel?.invokeMethod('injectJavascriptFileFromUrl', args);
  }

  @override
  Future<void> injectCSSCode({required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    await channel?.invokeMethod('injectCSSCode', args);
  }

  @override
  Future<void> injectCSSFileFromUrl({
    required WebUri urlFile,
    CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
      'cssLinkHtmlTagAttributes',
      () => cssLinkHtmlTagAttributes?.toMap(),
    );
    await channel?.invokeMethod('injectCSSFileFromUrl', args);
  }

  @override
  Future<String?> getHtml() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getHtml', args);
  }

  @override
  Future<String?> getSelectedText() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getSelectedText', args);
  }

  @override
  Future<bool> isSecureContext() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool?>('isSecureContext', args) ?? false;
  }

  @override
  Future<SslCertificate?> getCertificate() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? result = await channel?.invokeMethod(
      'getCertificate',
      args,
    );
    if (result != null) {
      return SslCertificate.fromMap(result.cast<String, dynamic>());
    }
    return null;
  }

  @override
  Future<InAppWebViewHitTestResult?> getHitTestResult() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? result = await channel?.invokeMethod(
      'getHitTestResult',
      args,
    );
    if (result != null) {
      return InAppWebViewHitTestResult.fromMap(result.cast<String, dynamic>());
    }
    return null;
  }

  @override
  Future<void> clearAllCache({bool includeDiskFiles = true}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('includeDiskFiles', () => includeDiskFiles);
    await _staticChannel.invokeMethod('clearAllCache', args);
  }

  @override
  Future<void> setJavaScriptBridgeName(String bridgeName) async {
    assert(
      RegExp(r'^[a-zA-Z_]\w*$').hasMatch(bridgeName),
      'bridgeName must be a non-empty string with only alphanumeric and underscore characters. It can\'t start with a number.',
    );
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('bridgeName', () => bridgeName);
    await _staticChannel.invokeMethod('setJavaScriptBridgeName', args);
  }

  @override
  Future<String> getJavaScriptBridgeName() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<String>(
          'getJavaScriptBridgeName',
          args,
        ) ??
        'flutter_inappwebview';
  }

  @override
  Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('keepAliveId', () => keepAlive.id);
    await _staticChannel.invokeMethod('disposeKeepAlive', args);
    _keepAliveMap[keepAlive] = null;
  }

  @override
  Future<String> get tRexRunnerHtml async => await rootBundle.loadString(
    'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html',
  );

  @override
  Future<String> get tRexRunnerCss async => await rootBundle.loadString(
    'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css',
  );

  @override
  Future<bool> handlesURLScheme(String urlScheme) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlScheme', () => urlScheme);
    return await _staticChannel.invokeMethod<bool>('handlesURLScheme', args) ??
        false;
  }

  @override
  Future<bool> canScrollVertically() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool?>('canScrollVertically', args) ??
        false;
  }

  @override
  Future<bool> canScrollHorizontally() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool?>('canScrollHorizontally', args) ??
        false;
  }

  @override
  Future<double?> getZoomScale() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<double?>('getZoomScale', args);
  }

  @override
  Future<void> zoomBy({
    required double zoomFactor,
    @Deprecated('Use animated instead') bool? iosAnimated,
    bool animated = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('zoomFactor', () => zoomFactor);
    await channel?.invokeMethod('setZoomScale', args);
  }

  @override
  Future<void> scrollTo({
    required int x,
    required int y,
    bool animated = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollTo', args);
  }

  @override
  Future<void> scrollBy({
    required int x,
    required int y,
    bool animated = false,
  }) async {
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
    Map<dynamic, dynamic>? settings = await channel?.invokeMethod(
      'getSettings',
      args,
    );
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
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) {
    assert(
      !kJavaScriptHandlerForbiddenNames.contains(handlerName),
      '"$handlerName" is a reserved name and cannot be used as a JavaScript handler name.',
    );
    _javaScriptHandlersMap[handlerName] = callback;
  }

  @override
  Function? removeJavaScriptHandler({required String handlerName}) {
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
    var index =
        _userScripts[userScript.injectionTime]?.indexOf(userScript) ?? -1;
    if (index == -1) {
      return false;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => index);
    args.putIfAbsent(
      'injectionTime',
      () => userScript.injectionTime.toNativeValue(),
    );
    await channel?.invokeMethod('removeUserScript', args);

    _userScripts[userScript.injectionTime]?.remove(userScript);
    return true;
  }

  @override
  Future<void> removeUserScriptsByGroupName({required String groupName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('groupName', () => groupName);
    await channel?.invokeMethod('removeUserScriptsByGroupName', args);

    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.removeWhere(
      (element) => element.groupName == groupName,
    );
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.removeWhere(
      (element) => element.groupName == groupName,
    );
  }

  @override
  Future<void> removeUserScripts({
    required List<UserScript> userScripts,
  }) async {
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

  /// Returns all user scripts that have been added.
  /// This is a Linux-specific method for accessing the user scripts cache.
  Future<List<UserScript>> getUserScripts() async {
    List<UserScript> result = [];
    result.addAll(
      _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START] ?? [],
    );
    result.addAll(_userScripts[UserScriptInjectionTime.AT_DOCUMENT_END] ?? []);
    return result;
  }

  @override
  Future<void> addWebMessageListener(
    PlatformWebMessageListener webMessageListener,
  ) async {
    assert(
      !_webMessageListeners.contains(webMessageListener),
      "${webMessageListener} was already added.",
    );
    assert(
      !_webMessageListenerObjNames.contains(
        webMessageListener.params.jsObjectName,
      ),
      "jsObjectName ${webMessageListener.params.jsObjectName} was already added.",
    );
    _webMessageListeners.add(webMessageListener as LinuxWebMessageListener);
    _webMessageListenerObjNames.add(webMessageListener.params.jsObjectName);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('webMessageListener', () => webMessageListener.toMap());
    await channel?.invokeMethod('addWebMessageListener', args);
  }

  @override
  bool hasWebMessageListener(PlatformWebMessageListener webMessageListener) {
    return _webMessageListeners.contains(webMessageListener) ||
        _webMessageListenerObjNames.contains(
          webMessageListener.params.jsObjectName,
        );
  }

  @override
  Future<LinuxWebMessageChannel?> createWebMessageChannel() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? result = (await channel?.invokeMethod(
      'createWebMessageChannel',
      args,
    ))?.cast<String, dynamic>();
    final webMessageChannel = LinuxWebMessageChannel.static().fromMap(result);
    if (webMessageChannel != null) {
      _webMessageChannels.add(webMessageChannel);
    }
    return webMessageChannel;
  }

  @override
  Future<void> postWebMessage({
    required WebMessage message,
    WebUri? targetOrigin,
  }) async {
    if (targetOrigin == null) {
      targetOrigin = WebUri('');
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('message', () => message.toMap());
    args.putIfAbsent('targetOrigin', () => targetOrigin.toString());
    await channel?.invokeMethod('postWebMessage', args);
  }

  @override
  Future<WebUri?> getOriginalUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await channel?.invokeMethod<String?>('getOriginalUrl', args);
    return url != null ? WebUri(url) : null;
  }

  /// Sets the zoom level of the WebView.
  /// This is a Linux-specific method that directly sets the zoom level.
  /// For cross-platform code, use [zoomBy] instead.
  Future<void> setZoomScale({
    required double zoomScale,
    @Deprecated('Use animated instead') bool? iosAnimated,
    bool animated = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('zoomScale', () => zoomScale);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('setZoomScale', args);
  }

  @override
  Future<bool> isInFullscreen() async {
    return await channel?.invokeMethod<bool>('isInFullscreen', {}) ?? false;
  }

  @override
  Future<void> requestEnterFullscreen() async {
    await channel?.invokeMethod('requestEnterFullscreen', {});
  }

  @override
  Future<void> requestExitFullscreen() async {
    await channel?.invokeMethod('requestExitFullscreen', {});
  }

  @override
  Future<void> setVisible({required bool visible}) async {
    await channel?.invokeMethod('setVisible', visible);
  }

  @override
  Future<void> setTargetRefreshRate({required int rate}) async {
    await channel?.invokeMethod('setTargetRefreshRate', rate);
  }

  @override
  Future<int> getTargetRefreshRate() async {
    return await channel?.invokeMethod<int>('getTargetRefreshRate', {}) ?? 0;
  }

  @override
  Future<bool> requestPointerLock() async {
    return await channel?.invokeMethod<bool>('requestPointerLock', {}) ?? false;
  }

  @override
  Future<bool> requestPointerUnlock() async {
    return await channel?.invokeMethod<bool>('requestPointerUnlock', {}) ??
        false;
  }

  @override
  Future<Uint8List?> takeScreenshot({
    ScreenshotConfiguration? screenshotConfiguration,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent(
      'screenshotConfiguration',
      () => screenshotConfiguration?.toMap(),
    );
    return await channel?.invokeMethod<Uint8List?>('takeScreenshot', args);
  }

  @override
  Future<Uint8List?> saveState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<Uint8List?>('saveState', args);
  }

  @override
  Future<bool> restoreState(Uint8List state) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('state', () => state);
    return await channel?.invokeMethod<bool>('restoreState', args) ?? false;
  }

  @override
  Future<String?> saveWebArchive({
    required String filePath,
    bool autoname = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('filePath', () => filePath);
    args.putIfAbsent('autoname', () => autoname);
    return await channel?.invokeMethod<String?>('saveWebArchive', args);
  }

  @override
  Future<int?> getContentHeight() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getContentHeight', args);
  }

  @override
  Future<int?> getContentWidth() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getContentWidth', args);
  }

  @override
  Future<WebHistory?> getCopyBackForwardList() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? result = await channel?.invokeMethod(
      'getCopyBackForwardList',
      args,
    );
    if (result != null) {
      return WebHistory.fromMap(result.cast<String, dynamic>());
    }
    return null;
  }

  @override
  Future<void> goBackOrForward({required int steps}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    await channel?.invokeMethod('goBackOrForward', args);
  }

  @override
  Future<bool> canGoBackOrForward({required int steps}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    return await channel?.invokeMethod<bool>('canGoBackOrForward', args) ??
        false;
  }

  @override
  Future<List<Favicon>> getFavicons() async {
    List<Favicon> favicons = [];

    var webviewUrl = await getUrl();

    if (webviewUrl == null) {
      return favicons;
    }

    String? manifestUrl;

    var html = await getHtml();
    if (html == null || html.isEmpty) {
      return favicons;
    }
    var assetPathBase;

    if (webviewUrl.isScheme("file")) {
      var assetPathSplit = webviewUrl.toString().split("/flutter_assets/");
      assetPathBase = assetPathSplit[0] + "/flutter_assets/";
    }

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      var jsResult = await evaluateJavascript(
        source: """
(function() {
  var linkNodes = document.head.getElementsByTagName("link");
  var links = [];
  for (var i = 0; i < linkNodes.length; i++) {
    var linkNode = linkNodes[i];
    if (linkNode.rel === 'manifest') {
      links.push(
        {
          rel: linkNode.rel,
          href: linkNode.href,
          sizes: null
        }
      );
    } else if (linkNode.rel != null && linkNode.rel.indexOf('icon') >= 0) {
      links.push(
        {
          rel: linkNode.rel,
          href: linkNode.href,
          sizes: linkNode.sizes != null && linkNode.sizes.value != "" ? linkNode.sizes.value : null
        }
      );
    }
  }
  return links;
})();
""",
      );
      List<Map<dynamic, dynamic>> links = [];
      if (jsResult is List) {
        links = jsResult.cast<Map<dynamic, dynamic>>();
      }
      for (var link in links) {
        if (link["rel"] == "manifest") {
          manifestUrl = link["href"];
          if (!_isUrlAbsolute(manifestUrl!)) {
            if (manifestUrl.startsWith("/")) {
              manifestUrl = manifestUrl.substring(1);
            }
            manifestUrl =
                ((assetPathBase == null)
                    ? webviewUrl.scheme + "://" + webviewUrl.host + "/"
                    : assetPathBase) +
                manifestUrl;
          }
          continue;
        }
        favicons.addAll(
          _createFavicons(
            webviewUrl,
            assetPathBase,
            link["href"],
            link["rel"],
            link["sizes"],
            false,
          ),
        );
      }
    }

    // try to get /favicon.ico
    try {
      HttpClient client = HttpClient();
      var faviconUrl =
          webviewUrl.scheme + "://" + webviewUrl.host + "/favicon.ico";
      var faviconUri = WebUri(faviconUrl);
      var headRequest = await client.headUrl(faviconUri);
      var headResponse = await headRequest.close();
      if (headResponse.statusCode == 200) {
        favicons.add(Favicon(url: faviconUri, rel: "shortcut icon"));
      }
    } catch (e) {
      developer.log(
        "/favicon.ico file not found: " + e.toString(),
        name: runtimeType.toString(),
      );
    }

    // try to get the manifest file
    HttpClientRequest? manifestRequest;
    HttpClientResponse? manifestResponse;
    bool manifestFound = false;
    if (manifestUrl == null) {
      manifestUrl =
          webviewUrl.scheme + "://" + webviewUrl.host + "/manifest.json";
    }
    try {
      HttpClient client = HttpClient();
      manifestRequest = await client.getUrl(Uri.parse(manifestUrl));
      manifestResponse = await manifestRequest.close();
      manifestFound =
          manifestResponse.statusCode == 200 &&
          manifestResponse.headers.contentType?.mimeType == "application/json";
    } catch (e) {
      developer.log(
        "Manifest file not found: " + e.toString(),
        name: this.runtimeType.toString(),
      );
    }

    if (manifestFound) {
      try {
        Map<String, dynamic> manifest = json.decode(
          await manifestResponse!.transform(Utf8Decoder()).join(),
        );
        if (manifest.containsKey("icons")) {
          for (Map<String, dynamic> icon in manifest["icons"]) {
            favicons.addAll(
              _createFavicons(
                webviewUrl,
                assetPathBase,
                icon["src"],
                icon["rel"],
                icon["sizes"],
                true,
              ),
            );
          }
        }
      } catch (e) {
        developer.log(
          "Cannot get favicons from Manifest file. It might not have a valid format: " +
              e.toString(),
          error: e,
          name: runtimeType.toString(),
        );
      }
    }

    return favicons;
  }

  bool _isUrlAbsolute(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<Favicon> _createFavicons(
    WebUri url,
    String? assetPathBase,
    String urlIcon,
    String? rel,
    String? sizes,
    bool isManifest,
  ) {
    List<Favicon> favicons = [];

    List<String> urlSplit = urlIcon.split("/");
    if (!_isUrlAbsolute(urlIcon)) {
      if (urlIcon.startsWith("/")) {
        urlIcon = urlIcon.substring(1);
      }
      urlIcon =
          ((assetPathBase == null)
              ? url.scheme + "://" + url.host + "/"
              : assetPathBase) +
          urlIcon;
    }
    if (isManifest) {
      rel = (sizes != null)
          ? urlSplit[urlSplit.length - 1]
                .replaceFirst("-" + sizes, "")
                .split(" ")[0]
                .split(".")[0]
          : null;
    }
    if (sizes != null && sizes.isNotEmpty && sizes != "any") {
      List<String> sizesSplit = sizes.split(" ");
      for (String size in sizesSplit) {
        int width = int.parse(size.split("x")[0]);
        int height = int.parse(size.split("x")[1]);
        favicons.add(
          Favicon(url: WebUri(urlIcon), rel: rel, width: width, height: height),
        );
      }
    } else {
      favicons.add(
        Favicon(url: WebUri(urlIcon), rel: rel, width: null, height: null),
      );
    }

    return favicons;
  }

  @override
  Future<void> pauseAllMediaPlayback() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('pauseAllMediaPlayback', args);
  }

  @override
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('suspended', () => suspended);
    await channel?.invokeMethod('setAllMediaPlaybackSuspended', args);
  }

  @override
  Future<void> closeAllMediaPresentations() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('closeAllMediaPresentations', args);
  }

  @override
  Future<MediaPlaybackState?> requestMediaPlaybackState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    int? result = await channel?.invokeMethod<int?>(
      'requestMediaPlaybackState',
      args,
    );
    if (result != null) {
      return MediaPlaybackState.fromNativeValue(result);
    }
    return null;
  }

  @override
  Future<MediaCaptureState?> getCameraCaptureState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    int? result = await channel?.invokeMethod<int?>(
      'getCameraCaptureState',
      args,
    );
    if (result != null) {
      return MediaCaptureState.fromNativeValue(result);
    }
    return null;
  }

  @override
  Future<void> setCameraCaptureState({required MediaCaptureState state}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('state', () => state.toNativeValue());
    await channel?.invokeMethod('setCameraCaptureState', args);
  }

  @override
  Future<MediaCaptureState?> getMicrophoneCaptureState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    int? result = await channel?.invokeMethod<int?>(
      'getMicrophoneCaptureState',
      args,
    );
    if (result != null) {
      return MediaCaptureState.fromNativeValue(result);
    }
    return null;
  }

  @override
  Future<void> setMicrophoneCaptureState({
    required MediaCaptureState state,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('state', () => state.toNativeValue());
    await channel?.invokeMethod('setMicrophoneCaptureState', args);
  }

  @override
  Future<Color?> getMetaThemeColor() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? hexColor = await channel?.invokeMethod<String?>(
      'getMetaThemeColor',
      args,
    );
    if (hexColor == null || hexColor.isEmpty) {
      return null;
    }
    // Parse hex color string like #RRGGBB or #RRGGBBAA
    return UtilColor.fromHex(hexColor);
  }

  @override
  Future<bool> isPlayingAudio() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isPlayingAudio', args) ?? false;
  }

  @override
  Future<bool> isMuted() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isMuted', args) ?? false;
  }

  @override
  Future<void> setMuted({required bool muted}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('muted', () => muted);
    await channel?.invokeMethod('setMuted', args);
  }

  @override
  Future<void> terminateWebProcess() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('terminateWebProcess', args);
  }

  @override
  Future<void> clearFocus() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearFocus', args);
  }

  @override
  Future<bool?> requestFocus({
    FocusDirection? direction,
    InAppWebViewRect? previouslyFocusedRect,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool?>('requestFocus', args);
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    if (!isKeepAlive) {
      for (final webMessageListener in _webMessageListeners) {
        webMessageListener.dispose();
      }
      _webMessageListeners.clear();
      _webMessageListenerObjNames.clear();
      for (final webMessageChannel in _webMessageChannels) {
        webMessageChannel.dispose();
      }
      _webMessageChannels.clear();
    }
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
  }
}

extension InternalInAppWebViewController on LinuxInAppWebViewController {
  get handleMethod => _handleMethod;
}
