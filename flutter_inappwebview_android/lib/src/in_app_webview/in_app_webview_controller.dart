import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../web_message/main.dart';

import '../in_app_browser/in_app_browser.dart';
import '../web_storage/web_storage.dart';

import 'headless_in_app_webview.dart';
import '_static_channel.dart';

import '../print_job/main.dart';
import '../find_interaction/main.dart';

///List of forbidden names for JavaScript handlers.
// ignore: non_constant_identifier_names
final _JAVASCRIPT_HANDLER_FORBIDDEN_NAMES = UnmodifiableListView<String>([
  "onLoadResource",
  "shouldInterceptAjaxRequest",
  "onAjaxReadyStateChange",
  "onAjaxProgress",
  "shouldInterceptFetchRequest",
  "onPrintRequest",
  "onWindowFocus",
  "onWindowBlur",
  "callAsyncJavaScript",
  "evaluateJavaScriptWithContentWorld"
]);

/// Object specifying creation parameters for creating a [AndroidInAppWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppWebViewControllerCreationParams] for
/// more information.
@immutable
class AndroidInAppWebViewControllerCreationParams
    extends PlatformInAppWebViewControllerCreationParams {
  /// Creates a new [AndroidInAppWebViewControllerCreationParams] instance.
  const AndroidInAppWebViewControllerCreationParams(
      {required super.id, super.webviewParams});

  /// Creates a [AndroidInAppWebViewControllerCreationParams] instance based on [PlatformInAppWebViewControllerCreationParams].
  factory AndroidInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformInAppWebViewControllerCreationParams params) {
    return AndroidInAppWebViewControllerCreationParams(
        id: params.id, webviewParams: params.webviewParams);
  }
}

///Controls a WebView, such as an [InAppWebView] widget instance, a [AndroidHeadlessInAppWebView] instance or [AndroidInAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [InAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [AndroidInAppBrowser] instance, you can get it through the [AndroidInAppBrowser.webViewController] attribute.
class AndroidInAppWebViewController extends PlatformInAppWebViewController
    with ChannelController {
  static final MethodChannel _staticChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

  // List of properties to be saved and restored for keep alive feature
  Map<String, JavaScriptHandlerCallback> _javaScriptHandlersMap =
      HashMap<String, JavaScriptHandlerCallback>();
  Map<UserScriptInjectionTime, List<UserScript>> _userScripts = {
    UserScriptInjectionTime.AT_DOCUMENT_START: <UserScript>[],
    UserScriptInjectionTime.AT_DOCUMENT_END: <UserScript>[]
  };
  Set<String> _webMessageListenerObjNames = Set();
  Map<String, ScriptHtmlTagAttributes> _injectedScriptsFromURL = {};
  Set<AndroidWebMessageChannel> _webMessageChannels = Set();
  Set<AndroidWebMessageListener> _webMessageListeners = Set();

  // static map that contains the properties to be saved and restored for keep alive feature
  static final Map<InAppWebViewKeepAlive, InAppWebViewControllerKeepAliveProps?>
      _keepAliveMap = {};

  AndroidInAppBrowser? _inAppBrowser;

  PlatformInAppBrowserEvents? get _inAppBrowserEventHandler =>
      _inAppBrowser?.eventHandler;

  dynamic _controllerFromPlatform;

  ///Provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
  late AndroidWebStorage webStorage;

  AndroidInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams params)
      : super.implementation(params
                is AndroidInAppWebViewControllerCreationParams
            ? params
            : AndroidInAppWebViewControllerCreationParams
                .fromPlatformInAppWebViewControllerCreationParams(params)) {
    channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
    handler = handleMethod;
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

  static final AndroidInAppWebViewController _staticValue =
      AndroidInAppWebViewController(
          AndroidInAppWebViewControllerCreationParams(id: null));

  factory AndroidInAppWebViewController.static() {
    return _staticValue;
  }

  AndroidInAppWebViewController.fromInAppBrowser(
      PlatformInAppWebViewControllerCreationParams params,
      MethodChannel channel,
      AndroidInAppBrowser inAppBrowser,
      UnmodifiableListView<UserScript>? initialUserScripts)
      : super.implementation(
            params is AndroidInAppWebViewControllerCreationParams
                ? params
                : AndroidInAppWebViewControllerCreationParams
                    .fromPlatformInAppWebViewControllerCreationParams(params)) {
    this.channel = channel;
    this._inAppBrowser = inAppBrowser;

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

  void _init(PlatformInAppWebViewControllerCreationParams params) {
    _controllerFromPlatform =
        params.webviewParams?.controllerFromPlatform?.call(this) ?? this;

    webStorage = AndroidWebStorage(AndroidWebStorageCreationParams(
        localStorage: AndroidLocalStorage.defaultStorage(),
        sessionStorage: AndroidSessionStorage.defaultStorage()));

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
              webMessageChannels: _webMessageChannels,
              webMessageListeners: _webMessageListeners);
        } else {
          // restore controller properties
          _injectedScriptsFromURL = props.injectedScriptsFromURL;
          _javaScriptHandlersMap = props.javaScriptHandlersMap;
          _userScripts = props.userScripts;
          _webMessageListenerObjNames = props.webMessageListenerObjNames;
          _webMessageChannels =
              props.webMessageChannels as Set<AndroidWebMessageChannel>;
          _webMessageListeners =
              props.webMessageListeners as Set<AndroidWebMessageListener>;
        }
      }
    }
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        name: _inAppBrowser == null
            ? "WebView"
            : _inAppBrowser.runtimeType.toString(),
        id: (getViewId() ?? _inAppBrowser?.id).toString(),
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
        if ((webviewParams != null && webviewParams!.onLoadStart != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null && webviewParams!.onLoadStart != null)
            webviewParams!.onLoadStart!(_controllerFromPlatform, uri);
          else
            _inAppBrowserEventHandler!.onLoadStart(uri);
        }
        break;
      case "onLoadStop":
        if ((webviewParams != null && webviewParams!.onLoadStop != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null && webviewParams!.onLoadStop != null)
            webviewParams!.onLoadStop!(_controllerFromPlatform, uri);
          else
            _inAppBrowserEventHandler!.onLoadStop(uri);
        }
        break;
      case "onReceivedError":
        if ((webviewParams != null &&
                (webviewParams!.onReceivedError != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.onLoadError != null)) ||
            _inAppBrowserEventHandler != null) {
          WebResourceRequest request = WebResourceRequest.fromMap(
              call.arguments["request"].cast<String, dynamic>())!;
          WebResourceError error = WebResourceError.fromMap(
              call.arguments["error"].cast<String, dynamic>())!;
          var isForMainFrame = request.isForMainFrame ?? false;

          if (webviewParams != null) {
            if (webviewParams!.onReceivedError != null)
              webviewParams!.onReceivedError!(
                  _controllerFromPlatform, request, error);
            else if (isForMainFrame) {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.onLoadError!(_controllerFromPlatform, request.url,
                  error.type.toNativeValue() ?? -1, error.description);
            }
          } else {
            if (isForMainFrame) {
              _inAppBrowserEventHandler!.onLoadError(request.url,
                  error.type.toNativeValue() ?? -1, error.description);
            }
            _inAppBrowserEventHandler!.onReceivedError(request, error);
          }
        }
        break;
      case "onReceivedHttpError":
        if ((webviewParams != null &&
                (webviewParams!.onReceivedHttpError != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.onLoadHttpError != null)) ||
            _inAppBrowserEventHandler != null) {
          WebResourceRequest request = WebResourceRequest.fromMap(
              call.arguments["request"].cast<String, dynamic>())!;
          WebResourceResponse errorResponse = WebResourceResponse.fromMap(
              call.arguments["errorResponse"].cast<String, dynamic>())!;
          var isForMainFrame = request.isForMainFrame ?? false;

          if (webviewParams != null) {
            if (webviewParams!.onReceivedHttpError != null)
              webviewParams!.onReceivedHttpError!(
                  _controllerFromPlatform, request, errorResponse);
            else if (isForMainFrame) {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.onLoadHttpError!(
                  _controllerFromPlatform,
                  request.url,
                  errorResponse.statusCode ?? -1,
                  errorResponse.reasonPhrase ?? '');
            }
          } else {
            if (isForMainFrame) {
              _inAppBrowserEventHandler!.onLoadHttpError(
                  request.url,
                  errorResponse.statusCode ?? -1,
                  errorResponse.reasonPhrase ?? '');
            }
            _inAppBrowserEventHandler!
                .onReceivedHttpError(request, errorResponse);
          }
        }
        break;
      case "onProgressChanged":
        if ((webviewParams != null &&
                webviewParams!.onProgressChanged != null) ||
            _inAppBrowserEventHandler != null) {
          int progress = call.arguments["progress"];
          if (webviewParams != null && webviewParams!.onProgressChanged != null)
            webviewParams!.onProgressChanged!(
                _controllerFromPlatform, progress);
          else
            _inAppBrowserEventHandler!.onProgressChanged(progress);
        }
        break;
      case "shouldOverrideUrlLoading":
        if ((webviewParams != null &&
                webviewParams!.shouldOverrideUrlLoading != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          NavigationAction navigationAction =
              NavigationAction.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.shouldOverrideUrlLoading != null)
            return (await webviewParams!.shouldOverrideUrlLoading!(
                    _controllerFromPlatform, navigationAction))
                ?.toNativeValue();
          return (await _inAppBrowserEventHandler!
                  .shouldOverrideUrlLoading(navigationAction))
              ?.toNativeValue();
        }
        break;
      case "onConsoleMessage":
        if ((webviewParams != null &&
                webviewParams!.onConsoleMessage != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          ConsoleMessage consoleMessage = ConsoleMessage.fromMap(arguments)!;
          if (webviewParams != null && webviewParams!.onConsoleMessage != null)
            webviewParams!.onConsoleMessage!(
                _controllerFromPlatform, consoleMessage);
          else
            _inAppBrowserEventHandler!.onConsoleMessage(consoleMessage);
        }
        break;
      case "onScrollChanged":
        if ((webviewParams != null && webviewParams!.onScrollChanged != null) ||
            _inAppBrowserEventHandler != null) {
          int x = call.arguments["x"];
          int y = call.arguments["y"];
          if (webviewParams != null && webviewParams!.onScrollChanged != null)
            webviewParams!.onScrollChanged!(_controllerFromPlatform, x, y);
          else
            _inAppBrowserEventHandler!.onScrollChanged(x, y);
        }
        break;
      case "onDownloadStartRequest":
        if ((webviewParams != null &&
                // ignore: deprecated_member_use_from_same_package
                (webviewParams!.onDownloadStart != null ||
                    webviewParams!.onDownloadStartRequest != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          DownloadStartRequest downloadStartRequest =
              DownloadStartRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.onDownloadStartRequest != null)
              webviewParams!.onDownloadStartRequest!(
                  _controllerFromPlatform, downloadStartRequest);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.onDownloadStart!(
                  _controllerFromPlatform, downloadStartRequest.url);
            }
          } else {
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!
                .onDownloadStart(downloadStartRequest.url);
            _inAppBrowserEventHandler!
                .onDownloadStartRequest(downloadStartRequest);
          }
        }
        break;
      case "onLoadResourceWithCustomScheme":
        if ((webviewParams != null &&
                (webviewParams!.onLoadResourceWithCustomScheme != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.onLoadResourceCustomScheme != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> requestMap =
              call.arguments["request"].cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(requestMap)!;

          if (webviewParams != null) {
            if (webviewParams!.onLoadResourceWithCustomScheme != null)
              return (await webviewParams!.onLoadResourceWithCustomScheme!(
                      _controllerFromPlatform, request))
                  ?.toMap();
            else {
              return (await params
                          .webviewParams!
                          // ignore: deprecated_member_use_from_same_package
                          .onLoadResourceCustomScheme!(
                      _controllerFromPlatform, request.url))
                  ?.toMap();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onLoadResourceWithCustomScheme(request)) ??
                    (await _inAppBrowserEventHandler!
                        .onLoadResourceCustomScheme(request.url)))
                ?.toMap();
          }
        }
        break;
      case "onCreateWindow":
        if ((webviewParams != null && webviewParams!.onCreateWindow != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          CreateWindowAction createWindowAction =
              CreateWindowAction.fromMap(arguments)!;

          if (webviewParams != null && webviewParams!.onCreateWindow != null)
            return await webviewParams!.onCreateWindow!(
                _controllerFromPlatform, createWindowAction);
          else
            return await _inAppBrowserEventHandler!
                .onCreateWindow(createWindowAction);
        }
        break;
      case "onCloseWindow":
        if (webviewParams != null && webviewParams!.onCloseWindow != null)
          webviewParams!.onCloseWindow!(_controllerFromPlatform);
        else if (_inAppBrowserEventHandler != null)
          _inAppBrowserEventHandler!.onCloseWindow();
        break;
      case "onTitleChanged":
        if ((webviewParams != null && webviewParams!.onTitleChanged != null) ||
            _inAppBrowserEventHandler != null) {
          String? title = call.arguments["title"];
          if (webviewParams != null && webviewParams!.onTitleChanged != null)
            webviewParams!.onTitleChanged!(_controllerFromPlatform, title);
          else
            _inAppBrowserEventHandler!.onTitleChanged(title);
        }
        break;
      case "onGeolocationPermissionsShowPrompt":
        if ((webviewParams != null &&
                (webviewParams!.onGeolocationPermissionsShowPrompt != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnGeolocationPermissionsShowPrompt !=
                        null)) ||
            _inAppBrowserEventHandler != null) {
          String origin = call.arguments["origin"];

          if (webviewParams != null) {
            if (webviewParams!.onGeolocationPermissionsShowPrompt != null)
              return (await webviewParams!.onGeolocationPermissionsShowPrompt!(
                      _controllerFromPlatform, origin))
                  ?.toMap();
            else {
              return (await params
                          .webviewParams!
                          // ignore: deprecated_member_use_from_same_package
                          .androidOnGeolocationPermissionsShowPrompt!(
                      _controllerFromPlatform, origin))
                  ?.toMap();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onGeolocationPermissionsShowPrompt(origin)) ??
                    (await _inAppBrowserEventHandler!
                        .androidOnGeolocationPermissionsShowPrompt(origin)))
                ?.toMap();
          }
        }
        break;
      case "onGeolocationPermissionsHidePrompt":
        if (webviewParams != null &&
            (webviewParams!.onGeolocationPermissionsHidePrompt != null ||
                // ignore: deprecated_member_use_from_same_package
                webviewParams!.androidOnGeolocationPermissionsHidePrompt !=
                    null)) {
          if (webviewParams!.onGeolocationPermissionsHidePrompt != null)
            webviewParams!
                .onGeolocationPermissionsHidePrompt!(_controllerFromPlatform);
          else {
            // ignore: deprecated_member_use_from_same_package
            webviewParams!.androidOnGeolocationPermissionsHidePrompt!(
                _controllerFromPlatform);
          }
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onGeolocationPermissionsHidePrompt();
          // ignore: deprecated_member_use_from_same_package
          _inAppBrowserEventHandler!
              .androidOnGeolocationPermissionsHidePrompt();
        }
        break;
      case "shouldInterceptRequest":
        if ((webviewParams != null &&
                (webviewParams!.shouldInterceptRequest != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidShouldInterceptRequest != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.shouldInterceptRequest != null)
              return (await webviewParams!.shouldInterceptRequest!(
                      _controllerFromPlatform, request))
                  ?.toMap();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidShouldInterceptRequest!(
                      _controllerFromPlatform, request))
                  ?.toMap();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .shouldInterceptRequest(request)) ??
                    (await _inAppBrowserEventHandler!
                        .androidShouldInterceptRequest(request)))
                ?.toMap();
          }
        }
        break;
      case "onRenderProcessUnresponsive":
        if ((webviewParams != null &&
                (webviewParams!.onRenderProcessUnresponsive != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnRenderProcessUnresponsive !=
                        null)) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            if (webviewParams!.onRenderProcessUnresponsive != null)
              return (await webviewParams!.onRenderProcessUnresponsive!(
                      _controllerFromPlatform, uri))
                  ?.toNativeValue();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidOnRenderProcessUnresponsive!(
                      _controllerFromPlatform, uri))
                  ?.toNativeValue();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onRenderProcessUnresponsive(uri)) ??
                    (await _inAppBrowserEventHandler!
                        .androidOnRenderProcessUnresponsive(uri)))
                ?.toNativeValue();
          }
        }
        break;
      case "onRenderProcessResponsive":
        if ((webviewParams != null &&
                (webviewParams!.onRenderProcessResponsive != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnRenderProcessResponsive != null)) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            if (webviewParams!.onRenderProcessResponsive != null)
              return (await webviewParams!.onRenderProcessResponsive!(
                      _controllerFromPlatform, uri))
                  ?.toNativeValue();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidOnRenderProcessResponsive!(
                      _controllerFromPlatform, uri))
                  ?.toNativeValue();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onRenderProcessResponsive(uri)) ??
                    (await _inAppBrowserEventHandler!
                        .androidOnRenderProcessResponsive(uri)))
                ?.toNativeValue();
          }
        }
        break;
      case "onRenderProcessGone":
        if ((webviewParams != null &&
                (webviewParams!.onRenderProcessGone != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnRenderProcessGone != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          RenderProcessGoneDetail detail =
              RenderProcessGoneDetail.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.onRenderProcessGone != null)
              webviewParams!.onRenderProcessGone!(
                  _controllerFromPlatform, detail);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.androidOnRenderProcessGone!(
                  _controllerFromPlatform, detail);
            }
          } else if (_inAppBrowserEventHandler != null) {
            _inAppBrowserEventHandler!.onRenderProcessGone(detail);
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!.androidOnRenderProcessGone(detail);
          }
        }
        break;
      case "onFormResubmission":
        if ((webviewParams != null &&
                (webviewParams!.onFormResubmission != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnFormResubmission != null)) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            if (webviewParams!.onFormResubmission != null)
              return (await webviewParams!.onFormResubmission!(
                      _controllerFromPlatform, uri))
                  ?.toNativeValue();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidOnFormResubmission!(
                      _controllerFromPlatform, uri))
                  ?.toNativeValue();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onFormResubmission(uri)) ??
                    // ignore: deprecated_member_use_from_same_package
                    (await _inAppBrowserEventHandler!
                        .androidOnFormResubmission(uri)))
                ?.toNativeValue();
          }
        }
        break;
      case "onZoomScaleChanged":
        if ((webviewParams != null &&
                // ignore: deprecated_member_use_from_same_package
                (webviewParams!.androidOnScaleChanged != null ||
                    webviewParams!.onZoomScaleChanged != null)) ||
            _inAppBrowserEventHandler != null) {
          double oldScale = call.arguments["oldScale"];
          double newScale = call.arguments["newScale"];

          if (webviewParams != null) {
            if (webviewParams!.onZoomScaleChanged != null)
              webviewParams!.onZoomScaleChanged!(
                  _controllerFromPlatform, oldScale, newScale);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.androidOnScaleChanged!(
                  _controllerFromPlatform, oldScale, newScale);
            }
          } else {
            _inAppBrowserEventHandler!.onZoomScaleChanged(oldScale, newScale);
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!
                .androidOnScaleChanged(oldScale, newScale);
          }
        }
        break;
      case "onReceivedIcon":
        if ((webviewParams != null &&
                (webviewParams!.onReceivedIcon != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnReceivedIcon != null)) ||
            _inAppBrowserEventHandler != null) {
          Uint8List icon =
              Uint8List.fromList(call.arguments["icon"].cast<int>());

          if (webviewParams != null) {
            if (webviewParams!.onReceivedIcon != null)
              webviewParams!.onReceivedIcon!(_controllerFromPlatform, icon);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.androidOnReceivedIcon!(
                  _controllerFromPlatform, icon);
            }
          } else {
            _inAppBrowserEventHandler!.onReceivedIcon(icon);
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!.androidOnReceivedIcon(icon);
          }
        }
        break;
      case "onReceivedTouchIconUrl":
        if ((webviewParams != null &&
                (webviewParams!.onReceivedTouchIconUrl != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnReceivedTouchIconUrl != null)) ||
            _inAppBrowserEventHandler != null) {
          String url = call.arguments["url"];
          bool precomposed = call.arguments["precomposed"];
          WebUri uri = WebUri(url);

          if (webviewParams != null) {
            if (webviewParams!.onReceivedTouchIconUrl != null)
              webviewParams!.onReceivedTouchIconUrl!(
                  _controllerFromPlatform, uri, precomposed);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.androidOnReceivedTouchIconUrl!(
                  _controllerFromPlatform, uri, precomposed);
            }
          } else {
            _inAppBrowserEventHandler!.onReceivedTouchIconUrl(uri, precomposed);
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!
                .androidOnReceivedTouchIconUrl(uri, precomposed);
          }
        }
        break;
      case "onJsAlert":
        if ((webviewParams != null && webviewParams!.onJsAlert != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsAlertRequest jsAlertRequest = JsAlertRequest.fromMap(arguments)!;

          if (webviewParams != null && webviewParams!.onJsAlert != null)
            return (await webviewParams!.onJsAlert!(
                    _controllerFromPlatform, jsAlertRequest))
                ?.toMap();
          else
            return (await _inAppBrowserEventHandler!.onJsAlert(jsAlertRequest))
                ?.toMap();
        }
        break;
      case "onJsConfirm":
        if ((webviewParams != null && webviewParams!.onJsConfirm != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsConfirmRequest jsConfirmRequest =
              JsConfirmRequest.fromMap(arguments)!;

          if (webviewParams != null && webviewParams!.onJsConfirm != null)
            return (await webviewParams!.onJsConfirm!(
                    _controllerFromPlatform, jsConfirmRequest))
                ?.toMap();
          else
            return (await _inAppBrowserEventHandler!
                    .onJsConfirm(jsConfirmRequest))
                ?.toMap();
        }
        break;
      case "onJsPrompt":
        if ((webviewParams != null && webviewParams!.onJsPrompt != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsPromptRequest jsPromptRequest = JsPromptRequest.fromMap(arguments)!;

          if (webviewParams != null && webviewParams!.onJsPrompt != null)
            return (await webviewParams!.onJsPrompt!(
                    _controllerFromPlatform, jsPromptRequest))
                ?.toMap();
          else
            return (await _inAppBrowserEventHandler!
                    .onJsPrompt(jsPromptRequest))
                ?.toMap();
        }
        break;
      case "onJsBeforeUnload":
        if ((webviewParams != null &&
                (webviewParams!.onJsBeforeUnload != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnJsBeforeUnload != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          JsBeforeUnloadRequest jsBeforeUnloadRequest =
              JsBeforeUnloadRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.onJsBeforeUnload != null)
              return (await webviewParams!.onJsBeforeUnload!(
                      _controllerFromPlatform, jsBeforeUnloadRequest))
                  ?.toMap();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidOnJsBeforeUnload!(
                      _controllerFromPlatform, jsBeforeUnloadRequest))
                  ?.toMap();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onJsBeforeUnload(jsBeforeUnloadRequest)) ??
                    (await _inAppBrowserEventHandler!
                        .androidOnJsBeforeUnload(jsBeforeUnloadRequest)))
                ?.toMap();
          }
        }
        break;
      case "onSafeBrowsingHit":
        if ((webviewParams != null &&
                (webviewParams!.onSafeBrowsingHit != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnSafeBrowsingHit != null)) ||
            _inAppBrowserEventHandler != null) {
          String url = call.arguments["url"];
          SafeBrowsingThreat? threatType =
              SafeBrowsingThreat.fromNativeValue(call.arguments["threatType"]);
          WebUri uri = WebUri(url);

          if (webviewParams != null) {
            if (webviewParams!.onSafeBrowsingHit != null)
              return (await webviewParams!.onSafeBrowsingHit!(
                      _controllerFromPlatform, uri, threatType))
                  ?.toMap();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidOnSafeBrowsingHit!(
                      _controllerFromPlatform, uri, threatType))
                  ?.toMap();
            }
          } else {
            return ((await _inAppBrowserEventHandler!
                        .onSafeBrowsingHit(uri, threatType)) ??
                    (await _inAppBrowserEventHandler!
                        .androidOnSafeBrowsingHit(uri, threatType)))
                ?.toMap();
          }
        }
        break;
      case "onReceivedLoginRequest":
        if ((webviewParams != null &&
                (webviewParams!.onReceivedLoginRequest != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnReceivedLoginRequest != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          LoginRequest loginRequest = LoginRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.onReceivedLoginRequest != null)
              webviewParams!.onReceivedLoginRequest!(
                  _controllerFromPlatform, loginRequest);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.androidOnReceivedLoginRequest!(
                  _controllerFromPlatform, loginRequest);
            }
          } else {
            _inAppBrowserEventHandler!.onReceivedLoginRequest(loginRequest);
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!
                .androidOnReceivedLoginRequest(loginRequest);
          }
        }
        break;
      case "onPermissionRequestCanceled":
        if ((webviewParams != null &&
                webviewParams!.onPermissionRequestCanceled != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          PermissionRequest permissionRequest =
              PermissionRequest.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onPermissionRequestCanceled != null)
            webviewParams!.onPermissionRequestCanceled!(
                _controllerFromPlatform, permissionRequest);
          else
            _inAppBrowserEventHandler!
                .onPermissionRequestCanceled(permissionRequest);
        }
        break;
      case "onRequestFocus":
        if ((webviewParams != null && webviewParams!.onRequestFocus != null) ||
            _inAppBrowserEventHandler != null) {
          if (webviewParams != null && webviewParams!.onRequestFocus != null)
            webviewParams!.onRequestFocus!(_controllerFromPlatform);
          else
            _inAppBrowserEventHandler!.onRequestFocus();
        }
        break;
      case "onReceivedHttpAuthRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedHttpAuthRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          HttpAuthenticationChallenge challenge =
              HttpAuthenticationChallenge.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onReceivedHttpAuthRequest != null)
            return (await webviewParams!.onReceivedHttpAuthRequest!(
                    _controllerFromPlatform, challenge))
                ?.toMap();
          else
            return (await _inAppBrowserEventHandler!
                    .onReceivedHttpAuthRequest(challenge))
                ?.toMap();
        }
        break;
      case "onReceivedServerTrustAuthRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedServerTrustAuthRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          ServerTrustChallenge challenge =
              ServerTrustChallenge.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onReceivedServerTrustAuthRequest != null)
            return (await webviewParams!.onReceivedServerTrustAuthRequest!(
                    _controllerFromPlatform, challenge))
                ?.toMap();
          else
            return (await _inAppBrowserEventHandler!
                    .onReceivedServerTrustAuthRequest(challenge))
                ?.toMap();
        }
        break;
      case "onReceivedClientCertRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedClientCertRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          ClientCertChallenge challenge =
              ClientCertChallenge.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onReceivedClientCertRequest != null)
            return (await webviewParams!.onReceivedClientCertRequest!(
                    _controllerFromPlatform, challenge))
                ?.toMap();
          else
            return (await _inAppBrowserEventHandler!
                    .onReceivedClientCertRequest(challenge))
                ?.toMap();
        }
        break;
      case "onFindResultReceived":
        if ((webviewParams != null &&
                (webviewParams!.onFindResultReceived != null ||
                    (webviewParams!.findInteractionController != null &&
                        webviewParams!.findInteractionController!.params
                                .onFindResultReceived !=
                            null))) ||
            _inAppBrowserEventHandler != null) {
          int activeMatchOrdinal = call.arguments["activeMatchOrdinal"];
          int numberOfMatches = call.arguments["numberOfMatches"];
          bool isDoneCounting = call.arguments["isDoneCounting"];
          if (webviewParams != null) {
            if (webviewParams!.findInteractionController != null &&
                webviewParams!.findInteractionController!.params
                        .onFindResultReceived !=
                    null)
              webviewParams!
                      .findInteractionController!.params.onFindResultReceived!(
                  webviewParams!.findInteractionController!,
                  activeMatchOrdinal,
                  numberOfMatches,
                  isDoneCounting);
            else
              webviewParams!.onFindResultReceived!(_controllerFromPlatform,
                  activeMatchOrdinal, numberOfMatches, isDoneCounting);
          } else {
            if (_inAppBrowser!.findInteractionController != null &&
                _inAppBrowser!
                        .findInteractionController!.onFindResultReceived !=
                    null)
              _inAppBrowser!.findInteractionController!.onFindResultReceived!(
                  webviewParams!.findInteractionController!,
                  activeMatchOrdinal,
                  numberOfMatches,
                  isDoneCounting);
            else
              _inAppBrowserEventHandler!.onFindResultReceived(
                  activeMatchOrdinal, numberOfMatches, isDoneCounting);
          }
        }
        break;
      case "onPermissionRequest":
        if ((webviewParams != null &&
                (webviewParams!.onPermissionRequest != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.androidOnPermissionRequest != null)) ||
            _inAppBrowserEventHandler != null) {
          String origin = call.arguments["origin"];
          List<String> resources = call.arguments["resources"].cast<String>();

          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          PermissionRequest permissionRequest =
              PermissionRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.onPermissionRequest != null)
              return (await webviewParams!.onPermissionRequest!(
                      _controllerFromPlatform, permissionRequest))
                  ?.toMap();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.androidOnPermissionRequest!(
                      _controllerFromPlatform, origin, resources))
                  ?.toMap();
            }
          } else {
            return (await _inAppBrowserEventHandler!
                        .onPermissionRequest(permissionRequest))
                    ?.toMap() ??
                (await _inAppBrowserEventHandler!
                        .androidOnPermissionRequest(origin, resources))
                    ?.toMap();
          }
        }
        break;
      case "onUpdateVisitedHistory":
        if ((webviewParams != null &&
                webviewParams!.onUpdateVisitedHistory != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          bool? isReload = call.arguments["isReload"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null &&
              webviewParams!.onUpdateVisitedHistory != null)
            webviewParams!.onUpdateVisitedHistory!(
                _controllerFromPlatform, uri, isReload);
          else
            _inAppBrowserEventHandler!.onUpdateVisitedHistory(uri, isReload);
        }
        break;
      case "onWebContentProcessDidTerminate":
        if (webviewParams != null &&
            (webviewParams!.onWebContentProcessDidTerminate != null ||
                // ignore: deprecated_member_use_from_same_package
                webviewParams!.iosOnWebContentProcessDidTerminate != null)) {
          if (webviewParams!.onWebContentProcessDidTerminate != null)
            webviewParams!
                .onWebContentProcessDidTerminate!(_controllerFromPlatform);
          else {
            // ignore: deprecated_member_use_from_same_package
            webviewParams!
                .iosOnWebContentProcessDidTerminate!(_controllerFromPlatform);
          }
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onWebContentProcessDidTerminate();
          // ignore: deprecated_member_use_from_same_package
          _inAppBrowserEventHandler!.iosOnWebContentProcessDidTerminate();
        }
        break;
      case "onPageCommitVisible":
        if ((webviewParams != null &&
                webviewParams!.onPageCommitVisible != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null &&
              webviewParams!.onPageCommitVisible != null)
            webviewParams!.onPageCommitVisible!(_controllerFromPlatform, uri);
          else
            _inAppBrowserEventHandler!.onPageCommitVisible(uri);
        }
        break;
      case "onDidReceiveServerRedirectForProvisionalNavigation":
        if (webviewParams != null &&
            (webviewParams!
                        .onDidReceiveServerRedirectForProvisionalNavigation !=
                    null ||
                params
                        .webviewParams!
                        // ignore: deprecated_member_use_from_same_package
                        .iosOnDidReceiveServerRedirectForProvisionalNavigation !=
                    null)) {
          if (webviewParams!
                  .onDidReceiveServerRedirectForProvisionalNavigation !=
              null)
            webviewParams!.onDidReceiveServerRedirectForProvisionalNavigation!(
                _controllerFromPlatform);
          else {
            params
                    .webviewParams!
                    // ignore: deprecated_member_use_from_same_package
                    .iosOnDidReceiveServerRedirectForProvisionalNavigation!(
                _controllerFromPlatform);
          }
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!
              .onDidReceiveServerRedirectForProvisionalNavigation();
          _inAppBrowserEventHandler!
              .iosOnDidReceiveServerRedirectForProvisionalNavigation();
        }
        break;
      case "onNavigationResponse":
        if ((webviewParams != null &&
                (webviewParams!.onNavigationResponse != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.iosOnNavigationResponse != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          // ignore: deprecated_member_use_from_same_package
          IOSWKNavigationResponse iosOnNavigationResponse =
              // ignore: deprecated_member_use_from_same_package
              IOSWKNavigationResponse.fromMap(arguments)!;

          NavigationResponse navigationResponse =
              NavigationResponse.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.onNavigationResponse != null)
              return (await webviewParams!.onNavigationResponse!(
                      _controllerFromPlatform, navigationResponse))
                  ?.toNativeValue();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.iosOnNavigationResponse!(
                      _controllerFromPlatform, iosOnNavigationResponse))
                  ?.toNativeValue();
            }
          } else {
            return (await _inAppBrowserEventHandler!
                        .onNavigationResponse(navigationResponse))
                    ?.toNativeValue() ??
                (await _inAppBrowserEventHandler!
                        .iosOnNavigationResponse(iosOnNavigationResponse))
                    ?.toNativeValue();
          }
        }
        break;
      case "shouldAllowDeprecatedTLS":
        if ((webviewParams != null &&
                (webviewParams!.shouldAllowDeprecatedTLS != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.iosShouldAllowDeprecatedTLS != null)) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          URLAuthenticationChallenge challenge =
              URLAuthenticationChallenge.fromMap(arguments)!;

          if (webviewParams != null) {
            if (webviewParams!.shouldAllowDeprecatedTLS != null)
              return (await webviewParams!.shouldAllowDeprecatedTLS!(
                      _controllerFromPlatform, challenge))
                  ?.toNativeValue();
            else {
              // ignore: deprecated_member_use_from_same_package
              return (await webviewParams!.iosShouldAllowDeprecatedTLS!(
                      _controllerFromPlatform, challenge))
                  ?.toNativeValue();
            }
          } else {
            return (await _inAppBrowserEventHandler!
                        .shouldAllowDeprecatedTLS(challenge))
                    ?.toNativeValue() ??
                // ignore: deprecated_member_use_from_same_package
                (await _inAppBrowserEventHandler!
                        .iosShouldAllowDeprecatedTLS(challenge))
                    ?.toNativeValue();
          }
        }
        break;
      case "onLongPressHitTestResult":
        if ((webviewParams != null &&
                webviewParams!.onLongPressHitTestResult != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          InAppWebViewHitTestResult hitTestResult =
              InAppWebViewHitTestResult.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onLongPressHitTestResult != null)
            webviewParams!.onLongPressHitTestResult!(
                _controllerFromPlatform, hitTestResult);
          else
            _inAppBrowserEventHandler!.onLongPressHitTestResult(hitTestResult);
        }
        break;
      case "onCreateContextMenu":
        ContextMenu? contextMenu;
        if (webviewParams != null && webviewParams!.contextMenu != null) {
          contextMenu = webviewParams!.contextMenu;
        } else if (_inAppBrowserEventHandler != null &&
            _inAppBrowser!.contextMenu != null) {
          contextMenu = _inAppBrowser!.contextMenu;
        }

        if (contextMenu != null && contextMenu.onCreateContextMenu != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          InAppWebViewHitTestResult hitTestResult =
              InAppWebViewHitTestResult.fromMap(arguments)!;

          contextMenu.onCreateContextMenu!(hitTestResult);
        }
        break;
      case "onHideContextMenu":
        ContextMenu? contextMenu;
        if (webviewParams != null && webviewParams!.contextMenu != null) {
          contextMenu = webviewParams!.contextMenu;
        } else if (_inAppBrowserEventHandler != null &&
            _inAppBrowser!.contextMenu != null) {
          contextMenu = _inAppBrowser!.contextMenu;
        }

        if (contextMenu != null && contextMenu.onHideContextMenu != null) {
          contextMenu.onHideContextMenu!();
        }
        break;
      case "onContextMenuActionItemClicked":
        ContextMenu? contextMenu;
        if (webviewParams != null && webviewParams!.contextMenu != null) {
          contextMenu = webviewParams!.contextMenu;
        } else if (_inAppBrowserEventHandler != null &&
            _inAppBrowser!.contextMenu != null) {
          contextMenu = _inAppBrowser!.contextMenu;
        }

        if (contextMenu != null) {
          int? androidId = call.arguments["androidId"];
          String? iosId = call.arguments["iosId"];
          dynamic id = call.arguments["id"];
          String title = call.arguments["title"];

          ContextMenuItem menuItemClicked = ContextMenuItem(
              id: id,
              // ignore: deprecated_member_use_from_same_package
              androidId: androidId,
              // ignore: deprecated_member_use_from_same_package
              iosId: iosId,
              title: title,
              action: null);

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
      case "onEnterFullscreen":
        if (webviewParams != null && webviewParams!.onEnterFullscreen != null)
          webviewParams!.onEnterFullscreen!(_controllerFromPlatform);
        else if (_inAppBrowserEventHandler != null)
          _inAppBrowserEventHandler!.onEnterFullscreen();
        break;
      case "onExitFullscreen":
        if (webviewParams != null && webviewParams!.onExitFullscreen != null)
          webviewParams!.onExitFullscreen!(_controllerFromPlatform);
        else if (_inAppBrowserEventHandler != null)
          _inAppBrowserEventHandler!.onExitFullscreen();
        break;
      case "onOverScrolled":
        if ((webviewParams != null && webviewParams!.onOverScrolled != null) ||
            _inAppBrowserEventHandler != null) {
          int x = call.arguments["x"];
          int y = call.arguments["y"];
          bool clampedX = call.arguments["clampedX"];
          bool clampedY = call.arguments["clampedY"];

          if (webviewParams != null && webviewParams!.onOverScrolled != null)
            webviewParams!.onOverScrolled!(
                _controllerFromPlatform, x, y, clampedX, clampedY);
          else
            _inAppBrowserEventHandler!.onOverScrolled(x, y, clampedX, clampedY);
        }
        break;
      case "onWindowFocus":
        if (webviewParams != null && webviewParams!.onWindowFocus != null)
          webviewParams!.onWindowFocus!(_controllerFromPlatform);
        else if (_inAppBrowserEventHandler != null)
          _inAppBrowserEventHandler!.onWindowFocus();
        break;
      case "onWindowBlur":
        if (webviewParams != null && webviewParams!.onWindowBlur != null)
          webviewParams!.onWindowBlur!(_controllerFromPlatform);
        else if (_inAppBrowserEventHandler != null)
          _inAppBrowserEventHandler!.onWindowBlur();
        break;
      case "onPrintRequest":
        if ((webviewParams != null &&
                (webviewParams!.onPrintRequest != null ||
                    // ignore: deprecated_member_use_from_same_package
                    webviewParams!.onPrint != null)) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          String? printJobId = call.arguments["printJobId"];
          WebUri? uri = url != null ? WebUri(url) : null;
          AndroidPrintJobController? printJob = printJobId != null
              ? AndroidPrintJobController(
                  AndroidPrintJobControllerCreationParams(id: printJobId))
              : null;

          if (webviewParams != null) {
            if (webviewParams!.onPrintRequest != null)
              return await webviewParams!.onPrintRequest!(
                  _controllerFromPlatform, uri, printJob);
            else {
              // ignore: deprecated_member_use_from_same_package
              webviewParams!.onPrint!(_controllerFromPlatform, uri);
              return false;
            }
          } else {
            // ignore: deprecated_member_use_from_same_package
            _inAppBrowserEventHandler!.onPrint(uri);
            return await _inAppBrowserEventHandler!
                .onPrintRequest(uri, printJob);
          }
        }
        break;
      case "onInjectedScriptLoaded":
        String id = call.arguments[0];
        var onLoadCallback = _injectedScriptsFromURL[id]?.onLoad;
        if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
            onLoadCallback != null) {
          onLoadCallback();
        }
        break;
      case "onInjectedScriptError":
        String id = call.arguments[0];
        var onErrorCallback = _injectedScriptsFromURL[id]?.onError;
        if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
            onErrorCallback != null) {
          onErrorCallback();
        }
        break;
      case "onCameraCaptureStateChanged":
        if ((webviewParams != null &&
                webviewParams!.onCameraCaptureStateChanged != null) ||
            _inAppBrowserEventHandler != null) {
          var oldState =
              MediaCaptureState.fromNativeValue(call.arguments["oldState"]);
          var newState =
              MediaCaptureState.fromNativeValue(call.arguments["newState"]);

          if (webviewParams != null &&
              webviewParams!.onCameraCaptureStateChanged != null)
            webviewParams!.onCameraCaptureStateChanged!(
                _controllerFromPlatform, oldState, newState);
          else
            _inAppBrowserEventHandler!
                .onCameraCaptureStateChanged(oldState, newState);
        }
        break;
      case "onMicrophoneCaptureStateChanged":
        if ((webviewParams != null &&
                webviewParams!.onMicrophoneCaptureStateChanged != null) ||
            _inAppBrowserEventHandler != null) {
          var oldState =
              MediaCaptureState.fromNativeValue(call.arguments["oldState"]);
          var newState =
              MediaCaptureState.fromNativeValue(call.arguments["newState"]);

          if (webviewParams != null &&
              webviewParams!.onMicrophoneCaptureStateChanged != null)
            webviewParams!.onMicrophoneCaptureStateChanged!(
                _controllerFromPlatform, oldState, newState);
          else
            _inAppBrowserEventHandler!
                .onMicrophoneCaptureStateChanged(oldState, newState);
        }
        break;
      case "onContentSizeChanged":
        if ((webviewParams != null &&
                webviewParams!.onContentSizeChanged != null) ||
            _inAppBrowserEventHandler != null) {
          var oldContentSize = MapSize.fromMap(
              call.arguments["oldContentSize"]?.cast<String, dynamic>())!;
          var newContentSize = MapSize.fromMap(
              call.arguments["newContentSize"]?.cast<String, dynamic>())!;

          if (webviewParams != null &&
              webviewParams!.onContentSizeChanged != null)
            webviewParams!.onContentSizeChanged!(
                _controllerFromPlatform, oldContentSize, newContentSize);
          else
            _inAppBrowserEventHandler!
                .onContentSizeChanged(oldContentSize, newContentSize);
        }
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        // decode args to json
        List<dynamic> args = jsonDecode(call.arguments["args"]);

        _debugLog(handlerName, args);

        switch (handlerName) {
          case "onLoadResource":
            if ((webviewParams != null &&
                    webviewParams!.onLoadResource != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = args[0].cast<String, dynamic>();
              arguments["startTime"] = arguments["startTime"] is int
                  ? arguments["startTime"].toDouble()
                  : arguments["startTime"];
              arguments["duration"] = arguments["duration"] is int
                  ? arguments["duration"].toDouble()
                  : arguments["duration"];

              var response = LoadedResource.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.onLoadResource != null)
                webviewParams!.onLoadResource!(
                    _controllerFromPlatform, response);
              else
                _inAppBrowserEventHandler!.onLoadResource(response);
            }
            return null;
          case "shouldInterceptAjaxRequest":
            if ((webviewParams != null &&
                    webviewParams!.shouldInterceptAjaxRequest != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = args[0].cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.shouldInterceptAjaxRequest != null)
                return jsonEncode(
                    await params.webviewParams!.shouldInterceptAjaxRequest!(
                        _controllerFromPlatform, request));
              else
                return jsonEncode(await _inAppBrowserEventHandler!
                    .shouldInterceptAjaxRequest(request));
            }
            return null;
          case "onAjaxReadyStateChange":
            if ((webviewParams != null &&
                    webviewParams!.onAjaxReadyStateChange != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = args[0].cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.onAjaxReadyStateChange != null)
                return (await webviewParams!.onAjaxReadyStateChange!(
                        _controllerFromPlatform, request))
                    ?.toNativeValue();
              else
                return (await _inAppBrowserEventHandler!
                        .onAjaxReadyStateChange(request))
                    ?.toNativeValue();
            }
            return null;
          case "onAjaxProgress":
            if ((webviewParams != null &&
                    webviewParams!.onAjaxProgress != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = args[0].cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.onAjaxProgress != null)
                return (await webviewParams!.onAjaxProgress!(
                        _controllerFromPlatform, request))
                    ?.toNativeValue();
              else
                return (await _inAppBrowserEventHandler!
                        .onAjaxProgress(request))
                    ?.toNativeValue();
            }
            return null;
          case "shouldInterceptFetchRequest":
            if ((webviewParams != null &&
                    webviewParams!.shouldInterceptFetchRequest != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = args[0].cast<String, dynamic>();
              FetchRequest request = FetchRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.shouldInterceptFetchRequest != null)
                return jsonEncode(
                    await webviewParams!.shouldInterceptFetchRequest!(
                        _controllerFromPlatform, request));
              else
                return jsonEncode(await _inAppBrowserEventHandler!
                    .shouldInterceptFetchRequest(request));
            }
            return null;
          case "onWindowFocus":
            if (webviewParams != null && webviewParams!.onWindowFocus != null)
              webviewParams!.onWindowFocus!(_controllerFromPlatform);
            else if (_inAppBrowserEventHandler != null)
              _inAppBrowserEventHandler!.onWindowFocus();
            return null;
          case "onWindowBlur":
            if (webviewParams != null && webviewParams!.onWindowBlur != null)
              webviewParams!.onWindowBlur!(_controllerFromPlatform);
            else if (_inAppBrowserEventHandler != null)
              _inAppBrowserEventHandler!.onWindowBlur();
            return null;
          case "onInjectedScriptLoaded":
            String id = args[0];
            var onLoadCallback = _injectedScriptsFromURL[id]?.onLoad;
            if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
                onLoadCallback != null) {
              onLoadCallback();
            }
            return null;
          case "onInjectedScriptError":
            String id = args[0];
            var onErrorCallback = _injectedScriptsFromURL[id]?.onError;
            if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
                onErrorCallback != null) {
              onErrorCallback();
            }
            return null;
        }

        if (_javaScriptHandlersMap.containsKey(handlerName)) {
          // convert result to json
          try {
            return jsonEncode(await _javaScriptHandlersMap[handlerName]!(args));
          } catch (error, stacktrace) {
            developer.log(error.toString() + '\n' + stacktrace.toString(),
                name: 'JavaScript Handler "$handlerName"');
            throw Exception(error.toString().replaceFirst('Exception: ', ''));
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///Gets the URL for the current page.
  ///This is not always the same as the URL passed to [WebView.onLoadStart] because although the load for that URL has begun, the current page may not have changed.
  ///
  ///**NOTE for Web**: If `window.location.href` isn't accessible inside the iframe,
  ///it will return the current value of the `iframe.src` attribute.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getUrl](https://developer.android.com/reference/android/webkit/WebView#getUrl()))
  ///- iOS ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- MacOS ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- Web
  Future<WebUri?> getUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await channel?.invokeMethod<String?>('getUrl', args);
    return url != null ? WebUri(url) : null;
  }

  ///Gets the title for the current page.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getTitle](https://developer.android.com/reference/android/webkit/WebView#getTitle()))
  ///- iOS ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- MacOS ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- Web
  Future<String?> getTitle() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getTitle', args);
  }

  ///Gets the progress for the current page. The progress value is between 0 and 100.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getProgress](https://developer.android.com/reference/android/webkit/WebView#getProgress()))
  ///- iOS ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  ///- MacOS ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  Future<int?> getProgress() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getProgress', args);
  }

  ///Gets the content html of the page. It first tries to get the content through javascript.
  ///If this doesn't work, it tries to get the content reading the file:
  ///- checking if it is an asset (`file:///`) or
  ///- downloading it using an `HttpClient` through the WebView's current url.
  ///
  ///Returns `null` if it was unable to get it.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<String?> getHtml() async {
    String? html;

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      html = await evaluateJavascript(
          source: "window.document.getElementsByTagName('html')[0].outerHTML;");
      if (html != null && html.isNotEmpty) return html;
    }

    var webviewUrl = await getUrl();
    if (webviewUrl == null) {
      return html;
    }

    if (webviewUrl.isScheme("file")) {
      var assetPathSplitted = webviewUrl.toString().split("/flutter_assets/");
      var assetPath = assetPathSplitted[assetPathSplitted.length - 1];
      try {
        var bytes = await rootBundle.load(assetPath);
        html = utf8.decode(bytes.buffer.asUint8List());
      } catch (e) {}
    } else {
      try {
        HttpClient client = HttpClient();
        var htmlRequest = await client.getUrl(webviewUrl);
        html =
            await (await htmlRequest.close()).transform(Utf8Decoder()).join();
      } catch (e) {
        developer.log(e.toString(), name: this.runtimeType.toString());
      }
    }

    return html;
  }

  ///Gets the list of all favicons for the current page.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
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
      var assetPathSplitted = webviewUrl.toString().split("/flutter_assets/");
      assetPathBase = assetPathSplitted[0] + "/flutter_assets/";
    }

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      List<Map<dynamic, dynamic>> links = (await evaluateJavascript(source: """
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
"""))?.cast<Map<dynamic, dynamic>>() ?? [];
      for (var link in links) {
        if (link["rel"] == "manifest") {
          manifestUrl = link["href"];
          if (!_isUrlAbsolute(manifestUrl!)) {
            if (manifestUrl.startsWith("/")) {
              manifestUrl = manifestUrl.substring(1);
            }
            manifestUrl = ((assetPathBase == null)
                    ? webviewUrl.scheme + "://" + webviewUrl.host + "/"
                    : assetPathBase) +
                manifestUrl;
          }
          continue;
        }
        favicons.addAll(_createFavicons(webviewUrl, assetPathBase, link["href"],
            link["rel"], link["sizes"], false));
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
      developer.log("/favicon.ico file not found: " + e.toString(),
          name: this.runtimeType.toString());
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
      manifestFound = manifestResponse.statusCode == 200 &&
          manifestResponse.headers.contentType?.mimeType == "application/json";
    } catch (e) {
      developer.log("Manifest file not found: " + e.toString(),
          name: this.runtimeType.toString());
    }

    if (manifestFound) {
      try {
        Map<String, dynamic> manifest = json
            .decode(await manifestResponse!.transform(Utf8Decoder()).join());
        if (manifest.containsKey("icons")) {
          for (Map<String, dynamic> icon in manifest["icons"]) {
            favicons.addAll(_createFavicons(webviewUrl, assetPathBase,
                icon["src"], icon["rel"], icon["sizes"], true));
          }
        }
      } on FormatException catch (_) {
        /// The [manifestResponse] might not has a valid JSON string, catch and
        /// ignore the error
      }
    }

    return favicons;
  }

  bool _isUrlAbsolute(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<Favicon> _createFavicons(WebUri url, String? assetPathBase,
      String urlIcon, String? rel, String? sizes, bool isManifest) {
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
        favicons.add(Favicon(
            url: WebUri(urlIcon), rel: rel, width: width, height: height));
      }
    } else {
      favicons.add(
          Favicon(url: WebUri(urlIcon), rel: rel, width: null, height: null));
    }

    return favicons;
  }

  ///Loads the given [urlRequest].
  ///
  ///- [allowingReadAccessTo], used in combination with [urlRequest] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the URL parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///**NOTE**: available only on iOS and MacOS.
  ///
  ///**NOTE for Android**: when loading an URL Request using "POST" method, headers are ignored.
  ///
  ///**NOTE for Web**: if method is "GET" and headers are empty, it will change the `src` of the iframe.
  ///For all other cases it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String))). If method is "POST", [Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[]))
  ///- iOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load). If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl))
  ///- MacOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load). If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl))
  ///- Web
  Future<void> loadUrl(
      {required URLRequest urlRequest,
      @Deprecated('Use allowingReadAccessTo instead')
      Uri? iosAllowingReadAccessTo,
      WebUri? allowingReadAccessTo}) async {
    assert(urlRequest.url != null && urlRequest.url.toString().isNotEmpty);
    assert(
        allowingReadAccessTo == null || allowingReadAccessTo.isScheme("file"));
    assert(iosAllowingReadAccessTo == null ||
        iosAllowingReadAccessTo.isScheme("file"));

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    args.putIfAbsent(
        'allowingReadAccessTo',
        () =>
            allowingReadAccessTo?.toString() ??
            iosAllowingReadAccessTo?.toString());
    await channel?.invokeMethod('loadUrl', args);
  }

  ///Loads the given [url] with [postData] (x-www-form-urlencoded) using `POST` method into this WebView.
  ///
  ///Example:
  ///```dart
  ///var postData = Uint8List.fromList(utf8.encode("firstname=Foo&surname=Bar"));
  ///controller.postUrl(url: WebUri("https://www.example.com/"), postData: postData);
  ///```
  ///
  ///**NOTE for Web**: it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])))
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> postUrl(
      {required WebUri url, required Uint8List postData}) async {
    assert(url.toString().isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('postData', () => postData);
    await channel?.invokeMethod('postUrl', args);
  }

  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///
  ///- [mimeType] argument specifies the format of the data. The default value is `"text/html"`.
  ///- [encoding] argument specifies the encoding of the data. The default value is `"utf8"`.
  ///**NOTE**: not used on Web.
  ///- [historyUrl] is an Android-specific argument that represents the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL.
  ///**NOTE**: not used on Web.
  ///- [allowingReadAccessTo], used in combination with [baseUrl] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This [baseUrl] must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [baseUrl] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///**NOTE**: available only on iOS and MacOS.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadDataWithBaseURL](https://developer.android.com/reference/android/webkit/WebView#loadDataWithBaseURL(java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String)))
  ///- iOS ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring) or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load))
  ///- MacOS ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring) or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load))
  ///- Web
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
    assert(
        allowingReadAccessTo == null || allowingReadAccessTo.isScheme("file"));
    assert(iosAllowingReadAccessTo == null ||
        iosAllowingReadAccessTo.isScheme("file"));

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? "about:blank");
    args.putIfAbsent(
        'historyUrl',
        () =>
            historyUrl?.toString() ??
            androidHistoryUrl?.toString() ??
            "about:blank");
    args.putIfAbsent(
        'allowingReadAccessTo',
        () =>
            allowingReadAccessTo?.toString() ??
            iosAllowingReadAccessTo?.toString());
    await channel?.invokeMethod('loadData', args);
  }

  ///Loads the given [assetFilePath].
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
  ///Example:
  ///```dart
  ///...
  ///controller.loadFile(assetFilePath: "assets/index.html");
  ///...
  ///```
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String)))
  ///- iOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- MacOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- Web
  Future<void> loadFile({required String assetFilePath}) async {
    assert(assetFilePath.isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('assetFilePath', () => assetFilePath);
    await channel?.invokeMethod('loadFile', args);
  }

  ///Reloads the WebView.
  ///
  ///**NOTE for Web**: if `window.location.reload()` is not accessible inside the iframe, it will reload using the iframe `src` attribute.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.reload](https://developer.android.com/reference/android/webkit/WebView#reload()))
  ///- iOS ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- MacOS ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- Web ([Official API - Location.reload](https://developer.mozilla.org/en-US/docs/Web/API/Location/reload))
  Future<void> reload() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('reload', args);
  }

  ///Goes back in the history of the WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goBack](https://developer.android.com/reference/android/webkit/WebView#goBack()))
  ///- iOS ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- MacOS ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- Web ([Official API - History.back](https://developer.mozilla.org/en-US/docs/Web/API/History/back))
  Future<void> goBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('goBack', args);
  }

  ///Returns a boolean value indicating whether the WebView can move backward.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoBack](https://developer.android.com/reference/android/webkit/WebView#canGoBack()))
  ///- iOS ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  ///- MacOS ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  Future<bool> canGoBack() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canGoBack', args) ?? false;
  }

  ///Goes forward in the history of the WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goForward](https://developer.android.com/reference/android/webkit/WebView#goForward()))
  ///- iOS ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- MacOS ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- Web ([Official API - History.forward](https://developer.mozilla.org/en-US/docs/Web/API/History/forward))
  Future<void> goForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('goForward', args);
  }

  ///Returns a boolean value indicating whether the WebView can move forward.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoForward](https://developer.android.com/reference/android/webkit/WebView#canGoForward()))
  ///- iOS ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  ///- MacOS ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  Future<bool> canGoForward() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canGoForward', args) ?? false;
  }

  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goBackOrForward](https://developer.android.com/reference/android/webkit/WebView#goBackOrForward(int)))
  ///- iOS ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- MacOS ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- Web ([Official API - History.go](https://developer.mozilla.org/en-US/docs/Web/API/History/go))
  Future<void> goBackOrForward({required int steps}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    await channel?.invokeMethod('goBackOrForward', args);
  }

  ///Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoBackOrForward](https://developer.android.com/reference/android/webkit/WebView#canGoBackOrForward(int)))
  ///- iOS
  ///- MacOS
  Future<bool> canGoBackOrForward({required int steps}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('steps', () => steps);
    return await channel?.invokeMethod<bool>('canGoBackOrForward', args) ??
        false;
  }

  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> goTo({required WebHistoryItem historyItem}) async {
    var steps = historyItem.offset;
    if (steps != null) {
      await goBackOrForward(steps: steps);
    }
  }

  ///Check if the WebView instance is in a loading state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<bool> isLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isLoading', args) ?? false;
  }

  ///Stops the WebView from loading.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.stopLoading](https://developer.android.com/reference/android/webkit/WebView#stopLoading()))
  ///- iOS ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- MacOS ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- Web ([Official API - Window.stop](https://developer.mozilla.org/en-US/docs/Web/API/Window/stop))
  Future<void> stopLoading() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('stopLoading', args);
  }

  ///Evaluates JavaScript [source] code into the WebView and returns the result of the evaluation.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe, using `eval(source);` to get and return the result.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///Available on iOS 14.0+ and MacOS 11.0+.
  ///**NOTE**: not used on Web.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.evaluateJavascript](https://developer.android.com/reference/android/webkit/WebView#evaluateJavascript(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS ([Official API - WKWebView.evaluateJavascript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- MacOS ([Official API - WKWebView.evaluateJavascript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- Web ([Official API - Window.eval](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval?retiredLocale=it))
  Future<dynamic> evaluateJavascript(
      {required String source, ContentWorld? contentWorld}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    args.putIfAbsent('contentWorld', () => contentWorld?.toMap());
    var data = await channel?.invokeMethod('evaluateJavascript', args);
    if (data != null && (Util.isAndroid || Util.isWeb)) {
      try {
        // try to json decode the data coming from JavaScript
        // otherwise return it as it is.
        data = json.decode(data);
      } catch (e) {}
    }
    return data;
  }

  ///Injects an external JavaScript file into the WebView from a defined url.
  ///
  ///[scriptHtmlTagAttributes] represents the possible the `<script>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectJavascriptFileFromUrl(
      {required WebUri urlFile,
      ScriptHtmlTagAttributes? scriptHtmlTagAttributes}) async {
    assert(urlFile.toString().isNotEmpty);
    var id = scriptHtmlTagAttributes?.id;
    if (scriptHtmlTagAttributes != null && id != null) {
      _injectedScriptsFromURL[id] = scriptHtmlTagAttributes;
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
        'scriptHtmlTagAttributes', () => scriptHtmlTagAttributes?.toMap());
    await channel?.invokeMethod('injectJavascriptFileFromUrl', args);
  }

  ///Evaluates the content of a JavaScript file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<dynamic> injectJavascriptFileFromAsset(
      {required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    return await evaluateJavascript(source: source);
  }

  ///Injects CSS into the WebView.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectCSSCode({required String source}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    await channel?.invokeMethod('injectCSSCode', args);
  }

  ///Injects an external CSS file into the WebView from a defined url.
  ///
  ///[cssLinkHtmlTagAttributes] represents the possible CSS stylesheet `<link>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectCSSFileFromUrl(
      {required WebUri urlFile,
      CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes}) async {
    assert(urlFile.toString().isNotEmpty);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile.toString());
    args.putIfAbsent(
        'cssLinkHtmlTagAttributes', () => cssLinkHtmlTagAttributes?.toMap());
    await channel?.invokeMethod('injectCSSFileFromUrl', args);
  }

  ///Injects a CSS file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) async {
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
  ///Forbidden names for JavaScript handlers are defined in [_JAVASCRIPT_HANDLER_FORBIDDEN_NAMES].
  ///
  ///**NOTE**: This method should be called, for example, in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events or, at least,
  ///before you know that your JavaScript code will call the `window.flutter_inappwebview.callHandler` method,
  ///otherwise you won't be able to intercept the JavaScript message.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void addJavaScriptHandler(
      {required String handlerName,
      required JavaScriptHandlerCallback callback}) {
    assert(!_JAVASCRIPT_HANDLER_FORBIDDEN_NAMES.contains(handlerName),
        '"$handlerName" is a forbidden name!');
    this._javaScriptHandlersMap[handlerName] = (callback);
  }

  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  JavaScriptHandlerCallback? removeJavaScriptHandler(
      {required String handlerName}) {
    return this._javaScriptHandlersMap.remove(handlerName);
  }

  ///Returns `true` if a JavaScript handler with [handlerName] already exists, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool hasJavaScriptHandler({required String handlerName}) {
    return this._javaScriptHandlersMap.containsKey(handlerName);
  }

  ///Takes a screenshot of the WebView's visible viewport and returns a [Uint8List]. Returns `null` if it wasn't be able to take it.
  ///
  ///[screenshotConfiguration] represents the configuration data to use when generating an image from a web view’s contents.
  ///
  ///**NOTE for iOS**: available on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 10.13+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  ///- MacOS ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  Future<Uint8List?> takeScreenshot(
      {ScreenshotConfiguration? screenshotConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent(
        'screenshotConfiguration', () => screenshotConfiguration?.toMap());
    return await channel?.invokeMethod<Uint8List?>('takeScreenshot', args);
  }

  ///Use [setSettings] instead.
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppWebViewGroupOptions options}) async {
    InAppWebViewSettings settings =
        InAppWebViewSettings.fromMap(options.toMap()) ?? InAppWebViewSettings();
    await setSettings(settings: settings);
  }

  ///Use [getSettings] instead.
  @Deprecated('Use getSettings instead')
  Future<InAppWebViewGroupOptions?> getOptions() async {
    InAppWebViewSettings? settings = await getSettings();

    Map<dynamic, dynamic>? options = settings?.toMap();
    if (options != null) {
      options = options.cast<String, dynamic>();
      return InAppWebViewGroupOptions.fromMap(options as Map<String, dynamic>);
    }

    return null;
  }

  ///Sets the WebView settings with the new [settings] and evaluates them.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> setSettings({required InAppWebViewSettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};

    args.putIfAbsent('settings', () => settings.toMap());
    await channel?.invokeMethod('setSettings', args);
  }

  ///Gets the current WebView settings. Returns `null` if it wasn't able to get them.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
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

  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.copyBackForwardList](https://developer.android.com/reference/android/webkit/WebView#copyBackForwardList()))
  ///- iOS ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  ///- MacOS ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  Future<WebHistory?> getCopyBackForwardList() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? result =
        (await channel?.invokeMethod('getCopyBackForwardList', args))
            ?.cast<String, dynamic>();
    return WebHistory.fromMap(result);
  }

  ///Clears all the WebView's cache.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> clearCache() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearCache', args);
  }

  ///Use [AndroidFindInteractionController.findAll] instead.
  @Deprecated("Use FindInteractionController.findAll instead")
  Future<void> findAllAsync({required String find}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('find', () => find);
    await channel?.invokeMethod('findAll', args);
  }

  ///Use [AndroidFindInteractionController.findNext] instead.
  @Deprecated("Use FindInteractionController.findNext instead")
  Future<void> findNext({required bool forward}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('forward', () => forward);
    await channel?.invokeMethod('findNext', args);
  }

  ///Use [AndroidFindInteractionController.clearMatches] instead.
  @Deprecated("Use FindInteractionController.clearMatches instead")
  Future<void> clearMatches() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearMatches', args);
  }

  ///Use [tRexRunnerHtml] instead.
  @Deprecated("Use tRexRunnerHtml instead")
  Future<String> getTRexRunnerHtml() async {
    return await tRexRunnerHtml;
  }

  ///Use [tRexRunnerCss] instead.
  @Deprecated("Use tRexRunnerCss instead")
  Future<String> getTRexRunnerCss() async {
    return await tRexRunnerCss;
  }

  ///Scrolls the WebView to the position.
  ///
  ///[x] represents the x position to scroll to.
  ///
  ///[y] represents the y position to scroll to.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.scrollTo](https://developer.android.com/reference/android/view/View#scrollTo(int,%20int)))
  ///- iOS ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollTo](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollTo))
  Future<void> scrollTo(
      {required int x, required int y, bool animated = false}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollTo', args);
  }

  ///Moves the scrolled position of the WebView.
  ///
  ///[x] represents the amount of pixels to scroll by horizontally.
  ///
  ///[y] represents the amount of pixels to scroll by vertically.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.scrollBy](https://developer.android.com/reference/android/view/View#scrollBy(int,%20int)))
  ///- iOS ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollBy](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollBy))
  Future<void> scrollBy(
      {required int x, required int y, bool animated = false}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('x', () => x);
    args.putIfAbsent('y', () => y);
    args.putIfAbsent('animated', () => animated);
    await channel?.invokeMethod('scrollBy', args);
  }

  ///On Android native WebView, it pauses all layout, parsing, and JavaScript timers for all WebViews.
  ///This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused.
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pauseTimers](https://developer.android.com/reference/android/webkit/WebView#pauseTimers()))
  ///- iOS
  ///- MacOS
  Future<void> pauseTimers() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('pauseTimers', args);
  }

  ///On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers.
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.resumeTimers](https://developer.android.com/reference/android/webkit/WebView#resumeTimers()))
  ///- iOS
  ///- MacOS
  Future<void> resumeTimers() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('resumeTimers', args);
  }

  ///Prints the current page.
  ///
  ///To obtain the [AndroidPrintJobController], use [settings] argument with [PrintJobSettings.handledByClient] to `true`.
  ///Otherwise this method will return `null` and the [AndroidPrintJobController] will be handled and disposed automatically by the system.
  ///
  ///**NOTE for Android**: available on Android 19+.
  ///
  ///**NOTE for MacOS**: [AndroidPrintJobController] is available on MacOS 11.0+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin. Also, [AndroidPrintJobController] is always `null`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintManager.print](https://developer.android.com/reference/android/print/PrintManager#print(java.lang.String,%20android.print.PrintDocumentAdapter,%20android.print.PrintAttributes)))
  ///- iOS ([Official API - UIPrintInteractionController.present](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618149-present))
  ///- MacOS (if 11.0+, [Official API - WKWebView.printOperation](https://developer.apple.com/documentation/webkit/wkwebview/3516861-printoperation), else [Official API - NSView.printView](https://developer.apple.com/documentation/appkit/nsview/1483705-printview))
  ///- Web ([Official API - Window.print](https://developer.mozilla.org/en-US/docs/Web/API/Window/print))
  Future<AndroidPrintJobController?> printCurrentPage(
      {PrintJobSettings? settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings?.toMap());
    String? jobId =
        await channel?.invokeMethod<String?>('printCurrentPage', args);
    if (jobId != null) {
      return AndroidPrintJobController(
          PlatformPrintJobControllerCreationParams(id: jobId));
    }
    return null;
  }

  ///Gets the height of the HTML content.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getContentHeight](https://developer.android.com/reference/android/webkit/WebView#getContentHeight()))
  ///- iOS ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- MacOS
  ///- Web ([Official API - Document.documentElement.scrollHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight))
  Future<int?> getContentHeight() async {
    Map<String, dynamic> args = <String, dynamic>{};
    var height = await channel?.invokeMethod('getContentHeight', args);
    if (height == null || height == 0) {
      // try to use javascript
      var scrollHeight = await evaluateJavascript(
          source: "document.documentElement.scrollHeight;");
      if (scrollHeight != null && scrollHeight is num) {
        height = scrollHeight.toInt();
      }
    }
    return height;
  }

  ///Gets the width of the HTML content.
  ///
  ///**NOTE for Android**: it is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- MacOS
  ///- Web ([Official API - Document.documentElement.scrollWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth))
  Future<int?> getContentWidth() async {
    Map<String, dynamic> args = <String, dynamic>{};
    var height = await channel?.invokeMethod('getContentWidth', args);
    if (height == null || height == 0) {
      // try to use javascript
      var scrollHeight = await evaluateJavascript(
          source: "document.documentElement.scrollWidth;");
      if (scrollHeight != null && scrollHeight is num) {
        height = scrollHeight.toInt();
      }
    }
    return height;
  }

  ///Performs a zoom operation in this WebView.
  ///
  ///[zoomFactor] represents the zoom factor to apply. On Android, the zoom factor will be clamped to the Webview's zoom limits and, also, this value must be in the range 0.01 (excluded) to 100.0 (included).
  ///
  ///[animated] `true` to animate the transition to the new scale, `false` to make the transition immediate.
  ///**NOTE**: available only on iOS.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomBy](https://developer.android.com/reference/android/webkit/WebView#zoomBy(float)))
  ///- iOS ([Official API - UIScrollView.setZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619412-setzoomscale))
  Future<void> zoomBy(
      {required double zoomFactor,
      @Deprecated('Use animated instead') bool? iosAnimated,
      bool animated = false}) async {
    assert(!Util.isAndroid ||
        (Util.isAndroid && zoomFactor > 0.01 && zoomFactor <= 100.0));

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('zoomFactor', () => zoomFactor);
    args.putIfAbsent('animated', () => iosAnimated ?? animated);
    return await channel?.invokeMethod('zoomBy', args);
  }

  ///Gets the URL that was originally requested for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStart] because although the load for that URL has begun,
  ///the current page may not have changed. Also, there may have been redirects resulting in a different URL to that originally requested.
  ///
  ///**NOTE for Web**: it will return the current value of the `iframe.src` attribute.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getOriginalUrl](https://developer.android.com/reference/android/webkit/WebView#getOriginalUrl()))
  ///- iOS
  ///- MacOS
  ///- Web
  Future<WebUri?> getOriginalUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await channel?.invokeMethod<String?>('getOriginalUrl', args);
    return url != null ? WebUri(url) : null;
  }

  ///Gets the current zoom scale of the WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIScrollView.zoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619419-zoomscale))
  Future<double?> getZoomScale() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<double?>('getZoomScale', args);
  }

  ///Use [getZoomScale] instead.
  @Deprecated('Use getZoomScale instead')
  Future<double?> getScale() async {
    return await getZoomScale();
  }

  ///Gets the selected text.
  ///
  ///**NOTE**: this method is implemented with using JavaScript.
  ///
  ///**NOTE for Android native WebView**: available only on Android 19+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<String?> getSelectedText() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getSelectedText', args);
  }

  ///Gets the hit result for hitting an HTML elements.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getHitTestResult](https://developer.android.com/reference/android/webkit/WebView#getHitTestResult()))
  ///- iOS
  Future<InAppWebViewHitTestResult?> getHitTestResult() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? hitTestResultMap =
        await channel?.invokeMethod('getHitTestResult', args);

    if (hitTestResultMap == null) {
      return null;
    }

    hitTestResultMap = hitTestResultMap.cast<String, dynamic>();

    InAppWebViewHitTestResultType? type =
        InAppWebViewHitTestResultType.fromNativeValue(
            hitTestResultMap["type"]?.toInt());
    String? extra = hitTestResultMap["extra"];
    return InAppWebViewHitTestResult(type: type, extra: extra);
  }

  ///Clears the current focus. On iOS and Android native WebView, it will clear also, for example, the current text selection.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ViewGroup.clearFocus](https://developer.android.com/reference/android/view/ViewGroup#clearFocus()))
  ///- iOS ([Official API - UIResponder.resignFirstResponder](https://developer.apple.com/documentation/uikit/uiresponder/1621097-resignfirstresponder))
  Future<void> clearFocus() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod('clearFocus', args);
  }

  ///Sets or updates the WebView context menu to be used next time it will appear.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Future<void> setContextMenu(ContextMenu? contextMenu) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("contextMenu", () => contextMenu?.toMap());
    await channel?.invokeMethod('setContextMenu', args);
    _inAppBrowser?.setContextMenu(contextMenu);
  }

  ///Requests the anchor or image element URL at the last tapped point.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestFocusNodeHref](https://developer.android.com/reference/android/webkit/WebView#requestFocusNodeHref(android.os.Message)))
  ///- iOS
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? result =
        await channel?.invokeMethod('requestFocusNodeHref', args);
    return result != null
        ? RequestFocusNodeHrefResult(
            url: result['url'] != null ? WebUri(result['url']) : null,
            title: result['title'],
            src: result['src'],
          )
        : null;
  }

  ///Requests the URL of the image last touched by the user.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestImageRef](https://developer.android.com/reference/android/webkit/WebView#requestImageRef(android.os.Message)))
  ///- iOS
  Future<RequestImageRefResult?> requestImageRef() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<dynamic, dynamic>? result =
        await channel?.invokeMethod('requestImageRef', args);
    return result != null
        ? RequestImageRefResult(
            url: result['url'] != null ? WebUri(result['url']) : null,
          )
        : null;
  }

  ///Returns the list of `<meta>` tags of the current WebView.
  ///
  ///**NOTE**: It is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<List<MetaTag>> getMetaTags() async {
    List<MetaTag> metaTags = [];

    List<Map<dynamic, dynamic>>? metaTagList =
        (await evaluateJavascript(source: """
(function() {
  var metaTags = [];
  var metaTagNodes = document.head.getElementsByTagName('meta');
  for (var i = 0; i < metaTagNodes.length; i++) {
    var metaTagNode = metaTagNodes[i];
    
    var otherAttributes = metaTagNode.getAttributeNames();
    var nameIndex = otherAttributes.indexOf("name");
    if (nameIndex !== -1) otherAttributes.splice(nameIndex, 1);
    var contentIndex = otherAttributes.indexOf("content");
    if (contentIndex !== -1) otherAttributes.splice(contentIndex, 1);
    
    var attrs = [];
    for (var j = 0; j < otherAttributes.length; j++) {
      var otherAttribute = otherAttributes[j];
      attrs.push(
        {
          name: otherAttribute,
          value: metaTagNode.getAttribute(otherAttribute)
        }
      );
    }

    metaTags.push(
      {
        name: metaTagNode.name,
        content: metaTagNode.content,
        attrs: attrs
      }
    );
  }
  return metaTags;
})();
    """))?.cast<Map<dynamic, dynamic>>();

    if (metaTagList == null) {
      return metaTags;
    }

    for (var metaTag in metaTagList) {
      var attrs = <MetaTagAttribute>[];

      for (var metaTagAttr in metaTag["attrs"]) {
        attrs.add(MetaTagAttribute(
            name: metaTagAttr["name"], value: metaTagAttr["value"]));
      }

      metaTags.add(MetaTag(
          name: metaTag["name"], content: metaTag["content"], attrs: attrs));
    }

    return metaTags;
  }

  ///Returns an instance of [Color] representing the `content` value of the
  ///`<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`.
  ///
  ///**NOTE**: on Android, Web, iOS < 15.0 and MacOS < 12.0, it is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor))
  ///- MacOS ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor))
  ///- Web
  Future<Color?> getMetaThemeColor() async {
    Color? themeColor;

    try {
      Map<String, dynamic> args = <String, dynamic>{};
      themeColor = UtilColor.fromStringRepresentation(
          await channel?.invokeMethod('getMetaThemeColor', args));
      return themeColor;
    } catch (e) {
      // not implemented
    }

    // try using javascript
    var metaTags = await getMetaTags();
    MetaTag? metaTagThemeColor;

    for (var metaTag in metaTags) {
      if (metaTag.name == "theme-color") {
        metaTagThemeColor = metaTag;
        break;
      }
    }

    if (metaTagThemeColor == null) {
      return null;
    }

    var colorValue = metaTagThemeColor.content;

    themeColor = colorValue != null
        ? UtilColor.fromStringRepresentation(colorValue)
        : null;

    return themeColor;
  }

  ///Returns the scrolled left position of the current WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.getScrollX](https://developer.android.com/reference/android/view/View#getScrollX()))
  ///- iOS ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollX](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollX))
  Future<int?> getScrollX() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getScrollX', args);
  }

  ///Returns the scrolled top position of the current WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.getScrollY](https://developer.android.com/reference/android/view/View#getScrollY()))
  ///- iOS ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollY](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollY))
  Future<int?> getScrollY() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int?>('getScrollY', args);
  }

  ///Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getCertificate](https://developer.android.com/reference/android/webkit/WebView#getCertificate()))
  ///- iOS
  ///- MacOS
  Future<SslCertificate?> getCertificate() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? sslCertificateMap =
        (await channel?.invokeMethod('getCertificate', args))
            ?.cast<String, dynamic>();
    return SslCertificate.fromMap(sslCertificateMap);
  }

  ///Injects the specified [userScript] into the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript))
  ///- MacOS ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript))
  Future<void> addUserScript({required UserScript userScript}) async {
    assert(webviewParams?.windowId == null || (!Util.isIOS && !Util.isMacOS));

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('userScript', () => userScript.toMap());
    if (!(_userScripts[userScript.injectionTime]?.contains(userScript) ??
        false)) {
      _userScripts[userScript.injectionTime]?.add(userScript);
      await channel?.invokeMethod('addUserScript', args);
    }
  }

  ///Injects the [userScripts] into the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> addUserScripts({required List<UserScript> userScripts}) async {
    assert(webviewParams?.windowId == null || (!Util.isIOS && !Util.isMacOS));

    for (var i = 0; i < userScripts.length; i++) {
      await addUserScript(userScript: userScripts[i]);
    }
  }

  ///Removes the specified [userScript] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///Returns `true` if [userScript] was in the list, `false` otherwise.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<bool> removeUserScript({required UserScript userScript}) async {
    assert(webviewParams?.windowId == null || (!Util.isIOS && !Util.isMacOS));

    var index = _userScripts[userScript.injectionTime]?.indexOf(userScript);
    if (index == null || index == -1) {
      return false;
    }

    _userScripts[userScript.injectionTime]?.remove(userScript);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('userScript', () => userScript.toMap());
    args.putIfAbsent('index', () => index);
    await channel?.invokeMethod('removeUserScript', args);

    return true;
  }

  ///Removes all the [UserScript]s with [groupName] as group name from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> removeUserScriptsByGroupName({required String groupName}) async {
    assert(webviewParams?.windowId == null || (!Util.isIOS && !Util.isMacOS));

    final List<UserScript> userScriptsAtDocumentStart = List.from(
        _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START] ?? []);
    for (final userScript in userScriptsAtDocumentStart) {
      if (userScript.groupName == groupName) {
        _userScripts[userScript.injectionTime]?.remove(userScript);
      }
    }

    final List<UserScript> userScriptsAtDocumentEnd =
        List.from(_userScripts[UserScriptInjectionTime.AT_DOCUMENT_END] ?? []);
    for (final userScript in userScriptsAtDocumentEnd) {
      if (userScript.groupName == groupName) {
        _userScripts[userScript.injectionTime]?.remove(userScript);
      }
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('groupName', () => groupName);
    await channel?.invokeMethod('removeUserScriptsByGroupName', args);
  }

  ///Removes the [userScripts] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> removeUserScripts(
      {required List<UserScript> userScripts}) async {
    assert(webviewParams?.windowId == null || (!Util.isIOS && !Util.isMacOS));

    for (final userScript in userScripts) {
      await removeUserScript(userScript: userScript);
    }
  }

  ///Removes all the user scripts from the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts))
  ///- MacOS ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts))
  Future<void> removeAllUserScripts() async {
    assert(webviewParams?.windowId == null || (!Util.isIOS && !Util.isMacOS));

    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.clear();
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.clear();

    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('removeAllUserScripts', args);
  }

  ///Returns `true` if the [userScript] has been already added, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool hasUserScript({required UserScript userScript}) {
    return _userScripts[userScript.injectionTime]?.contains(userScript) ??
        false;
  }

  ///Executes the specified string as an asynchronous JavaScript function.
  ///
  ///[functionBody] is the JavaScript string to use as the function body.
  ///This method treats the string as an anonymous JavaScript function body and calls it with the named arguments in the arguments parameter.
  ///
  ///[arguments] is a `Map` of the arguments to pass to the function call.
  ///Each key in the `Map` corresponds to the name of an argument in the [functionBody] string,
  ///and the value of that key is the value to use during the evaluation of the code.
  ///Supported value types can be found in the official Flutter docs:
  ///[Platform channel data types support and codecs](https://flutter.dev/docs/development/platform-integration/platform-channels#codec),
  ///except for [Uint8List], [Int32List], [Int64List], and [Float64List] that should be converted into a [List].
  ///All items in a `List` or `Map` must also be one of the supported types.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///Available on iOS 14.3+.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for iOS**: available only on iOS 10.3+.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  ///- MacOS ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript(
      {required String functionBody,
      Map<String, dynamic> arguments = const <String, dynamic>{},
      ContentWorld? contentWorld}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('functionBody', () => functionBody);
    args.putIfAbsent('arguments', () => arguments);
    args.putIfAbsent('contentWorld', () => contentWorld?.toMap());
    var data = await channel?.invokeMethod('callAsyncJavaScript', args);
    if (data == null) {
      return null;
    }
    if (Util.isAndroid) {
      data = json.decode(data);
    }
    return CallAsyncJavaScriptResult(
        value: data["value"], error: data["error"]);
  }

  ///Saves the current WebView as a web archive.
  ///Returns the file path under which the web archive file was saved, or `null` if saving the file failed.
  ///
  ///[filePath] represents the file path where the archive should be placed. This value cannot be `null`.
  ///
  ///[autoname] if `false`, takes [filePath] to be a file.
  ///If `true`, [filePath] is assumed to be a directory in which a filename will be chosen according to the URL of the current page.
  ///
  ///**NOTE for iOS**: Available on iOS 14.0+. If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**NOTE for MacOS**: Available on MacOS 11.0+. If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**NOTE for Android**: if [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.MHT] file extension.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.saveWebArchive](https://developer.android.com/reference/android/webkit/WebView#saveWebArchive(java.lang.String,%20boolean,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS
  ///- MacOS
  Future<String?> saveWebArchive(
      {required String filePath, bool autoname = false}) async {
    if (!autoname) {
      if (Util.isAndroid) {
        assert(filePath.endsWith("." + WebArchiveFormat.MHT.toNativeValue()));
      } else if (Util.isIOS || Util.isMacOS) {
        assert(filePath
            .endsWith("." + WebArchiveFormat.WEBARCHIVE.toNativeValue()));
      }
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("filePath", () => filePath);
    args.putIfAbsent("autoname", () => autoname);
    return await channel?.invokeMethod<String?>('saveWebArchive', args);
  }

  ///Indicates whether the webpage context is capable of using features that require [secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts).
  ///This is implemented using Javascript (see [window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext)).
  ///
  ///**NOTE for Android**: available Android 21.0+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin. Returns `false` otherwise.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web ([Official API - Window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext))
  Future<bool> isSecureContext() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isSecureContext', args) ?? false;
  }

  ///Creates a message channel to communicate with JavaScript and returns the message channel with ports that represent the endpoints of this message channel.
  ///The HTML5 message channel functionality is described [here](https://html.spec.whatwg.org/multipage/comms.html#messagechannel).
  ///
  ///The returned message channels are entangled and already in started state.
  ///
  ///This method should be called when the page is loaded, for example, when the [WebView.onLoadStop] is fired, otherwise the [AndroidWebMessageChannel] won't work.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.createWebMessageChannel](https://developer.android.com/reference/androidx/webkit/WebViewCompat#createWebMessageChannel(android.webkit.WebView)))
  ///- iOS
  ///- MacOS
  Future<AndroidWebMessageChannel?> createWebMessageChannel() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? result =
        (await channel?.invokeMethod('createWebMessageChannel', args))
            ?.cast<String, dynamic>();
    final webMessageChannel = AndroidWebMessageChannel.static().fromMap(result);
    if (webMessageChannel != null) {
      _webMessageChannels.add(webMessageChannel);
    }
    return webMessageChannel;
  }

  ///Post a message to main frame. The embedded application can restrict the messages to a certain target origin.
  ///See [HTML5 spec](https://html.spec.whatwg.org/multipage/comms.html#posting-messages) for how target origin can be used.
  ///
  ///A target origin can be set as a wildcard ("*"). However this is not recommended.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.POST_WEB_MESSAGE].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.postWebMessage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#postWebMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri)))
  ///- iOS
  ///- MacOS
  Future<void> postWebMessage(
      {required WebMessage message, WebUri? targetOrigin}) async {
    if (targetOrigin == null) {
      targetOrigin = WebUri('');
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('message', () => message.toMap());
    args.putIfAbsent('targetOrigin', () => targetOrigin.toString());
    await channel?.invokeMethod('postWebMessage', args);
  }

  ///Adds a [AndroidWebMessageListener] to the WebView and injects a JavaScript object into each frame that the [AndroidWebMessageListener] will listen on.
  ///
  ///The injected JavaScript object will be named [AndroidWebMessageListener.jsObjectName] in the global scope.
  ///This will inject the JavaScript object in any frame whose origin matches [AndroidWebMessageListener.allowedOriginRules]
  ///for every navigation after this call, and the JavaScript object will be available immediately when the page begins to load.
  ///
  ///Each [AndroidWebMessageListener.allowedOriginRules] entry must follow the format `SCHEME "://" [ HOSTNAME_PATTERN [ ":" PORT ] ]`, each part is explained in the below table:
  ///
  ///<table>
  ///   <colgroup>
  ///      <col width="25%">
  ///   </colgroup>
  ///   <tbody>
  ///      <tr>
  ///         <th>Rule</th>
  ///         <th>Description</th>
  ///         <th>Example</th>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with hostname</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a regular hostname; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port
  ///            <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://foobar.com:8080</code> - Matches https:// URL on port 8080, whose normalized
  ///                  host is foobar.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://www.example.com</code> - Matches https:// URL on port 443, whose normalized host
  ///                  is www.example.com.
  ///               </li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with pattern matching</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a sub-domain matching
  ///            pattern with a leading <code translate="no" dir="ltr">*.<wbr></code>; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will
  ///            match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://*.example.com</code> - Matches https://calendar.example.com and
  ///                  https://foo.bar.example.com but not https://example.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://*.example.com:8080</code> - Matches https://calendar.example.com:8080</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with IP literal</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is https or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is IP literal; <code translate="no" dir="ltr">PORT</code> is
  ///            optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code>
  ///            for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://127.0.0.1</code> - Matches https:// URL on port 443, whose IPv4 address is
  ///                  127.0.0.1
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]</code> or <code translate="no" dir="ltr">https://[0:0::1]</code>- Matches any URL to the IPv6 loopback
  ///                  address with port 443.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]:99</code> - Matches any https:// URL to the IPv6 loopback on port 99.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>Custom scheme</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is a custom scheme; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> and <code translate="no" dir="ltr">PORT</code> must not be
  ///            present.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">my-app-scheme://</code> - Matches any my-app-scheme:// URL.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td><code translate="no" dir="ltr">*</code></td>
  ///         <td>Wildcard rule, matches any origin.</td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">*</code></li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///   </tbody>
  ///</table>
  ///
  ///Note that this is a powerful API, as the JavaScript object will be injected when the frame's origin matches any one of the allowed origins.
  ///The HTTPS scheme is strongly recommended for security; allowing HTTP origins exposes the injected object to any potential network-based attackers.
  ///If a wildcard "*" is provided, it will inject the JavaScript object to all frames.
  ///A wildcard should only be used if the app wants **any** third party web page to be able to use the injected object.
  ///When using a wildcard, the app must treat received messages as untrustworthy and validate any data carefully.
  ///
  ///This method can be called multiple times to inject multiple JavaScript objects.
  ///
  ///Let's say the injected JavaScript object is named `myObject`. We will have following methods on that object once it is available to use:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// // message needs to be a JavaScript String, MessagePorts is an optional parameter.
  /// myObject.postMessage(message[, MessagePorts]) // on Android
  /// myObject.postMessage(message) // on iOS
  ///
  /// // To receive messages posted from the app side, assign a function to the "onmessage"
  /// // property. This function should accept a single "event" argument. "event" has a "data"
  /// // property, which is the message string from the app side.
  /// myObject.onmessage = function(event) { ... }
  ///
  /// // To be compatible with DOM EventTarget's addEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject. An event object will be passed to listener with a "data" property,
  /// // which is the message string from the app side.
  /// myObject.addEventListener(type, listener)
  ///
  /// // To be compatible with DOM EventTarget's removeEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject.
  /// myObject.removeEventListener(type, listener)
  ///```
  ///
  ///We start the communication between JavaScript and the app from the JavaScript side.
  ///In order to send message from the app to JavaScript, it needs to post a message from JavaScript first,
  ///so the app will have a [AndroidJavaScriptReplyProxy] object to respond. Example:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// myObject.onmessage = function(event) {
  ///   // prints "Got it!" when we receive the app's response.
  ///   console.log(event.data);
  /// }
  /// myObject.postMessage("I'm ready!");
  ///```
  ///
  ///```dart
  /// // Flutter App
  /// child: InAppWebView(
  ///   onWebViewCreated: (_controllerFromPlatform) async {
  ///     if (defaultTargetPlatform != TargetPlatform.android || await WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
  ///       await controller.addWebMessageListener(WebMessageListener(
  ///         jsObjectName: "myObject",
  ///         onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
  ///           // do something about message, sourceOrigin and isMainFrame.
  ///           replyProxy.postMessage("Got it!");
  ///         },
  ///       ));
  ///     }
  ///     await controller.loadUrl(urlRequest: URLRequest(url: WebUri("https://www.example.com")));
  ///   },
  /// ),
  ///```
  ///
  ///**NOTE for Android**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.WEB_MESSAGE_LISTENER].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.WebMessageListener](https://developer.android.com/reference/androidx/webkit/WebViewCompat#addWebMessageListener(android.webkit.WebView,%20java.lang.String,%20java.util.Set%3Cjava.lang.String%3E,%20androidx.webkit.WebViewCompat.WebMessageListener)))
  ///- iOS
  ///- MacOS
  @override
  Future<void> addWebMessageListener(
      PlatformWebMessageListener webMessageListener) async {
    assert(!_webMessageListeners.contains(webMessageListener),
        "${webMessageListener} was already added.");
    assert(
        !_webMessageListenerObjNames
            .contains(webMessageListener.params.jsObjectName),
        "jsObjectName ${webMessageListener.params.jsObjectName} was already added.");
    _webMessageListeners.add(webMessageListener as AndroidWebMessageListener);
    _webMessageListenerObjNames.add(webMessageListener.params.jsObjectName);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('webMessageListener', () => webMessageListener.toMap());
    await channel?.invokeMethod('addWebMessageListener', args);
  }

  ///Returns `true` if the [webMessageListener] has been already added, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  @override
  bool hasWebMessageListener(PlatformWebMessageListener webMessageListener) {
    return _webMessageListeners.contains(webMessageListener) ||
        _webMessageListenerObjNames
            .contains(webMessageListener.params.jsObjectName);
  }

  ///Returns `true` if the webpage can scroll vertically, otherwise `false`.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  @override
  Future<bool> canScrollVertically() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canScrollVertically', args) ??
        false;
  }

  ///Returns `true` if the webpage can scroll horizontally, otherwise `false`.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  @override
  Future<bool> canScrollHorizontally() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canScrollHorizontally', args) ??
        false;
  }

  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag or [AndroidInAppWebViewOptions.safeBrowsingEnabled].
  ///This prepares resources used for Safe Browsing.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.START_SAFE_BROWSING].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.startSafeBrowsing](https://developer.android.com/reference/android/webkit/WebView#startSafeBrowsing(android.content.Context,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  @override
  Future<bool> startSafeBrowsing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('startSafeBrowsing', args) ??
        false;
  }

  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearSslPreferences](https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()))
  @override
  Future<void> clearSslPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearSslPreferences', args);
  }

  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [InAppWebViewController.pauseTimers]. To resume WebView, call [resume].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onPause](https://developer.android.com/reference/android/webkit/WebView#onPause()))
  @override
  Future<void> pause() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('pause', args);
  }

  ///Resumes a WebView after a previous call to [pause].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onResume](https://developer.android.com/reference/android/webkit/WebView#onResume()))
  @override
  Future<void> resume() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('resume', args);
  }

  ///Scrolls the contents of this WebView down by half the page size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to bottom of page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageDown](https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)))
  @override
  Future<bool> pageDown({required bool bottom}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("bottom", () => bottom);
    return await channel?.invokeMethod<bool>('pageDown', args) ?? false;
  }

  ///Scrolls the contents of this WebView up by half the view size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[top] `true` to jump to the top of the page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageUp](https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)))
  @override
  Future<bool> pageUp({required bool top}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("top", () => top);
    return await channel?.invokeMethod<bool>('pageUp', args) ?? false;
  }

  ///Performs zoom in in this WebView.
  ///Returns `true` if zoom in succeeds, `false` if no zoom changes.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomIn](https://developer.android.com/reference/android/webkit/WebView#zoomIn()))
  @override
  Future<bool> zoomIn() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('zoomIn', args) ?? false;
  }

  ///Performs zoom out in this WebView.
  ///Returns `true` if zoom out succeeds, `false` if no zoom changes.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomOut](https://developer.android.com/reference/android/webkit/WebView#zoomOut()))
  Future<bool> zoomOut() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('zoomOut', args) ?? false;
  }

  ///Clears the internal back/forward list.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearHistory](https://developer.android.com/reference/android/webkit/WebView#clearHistory()))
  Future<void> clearHistory() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod('clearHistory', args);
  }

  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  ///- MacOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('reloadFromOrigin', args);
  }

  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[pdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  ///- MacOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  Future<Uint8List?> createPdf(
      {@Deprecated("Use pdfConfiguration instead")
      // ignore: deprecated_member_use_from_same_package
      IOSWKPDFConfiguration? iosWKPdfConfiguration,
      PDFConfiguration? pdfConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('pdfConfiguration',
        () => pdfConfiguration?.toMap() ?? iosWKPdfConfiguration?.toMap());
    return await channel?.invokeMethod<Uint8List?>('createPdf', args);
  }

  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  ///- MacOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  Future<Uint8List?> createWebArchiveData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod('createWebArchiveData', args);
  }

  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  ///- MacOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  Future<bool> hasOnlySecureContent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('hasOnlySecureContent', args) ??
        false;
  }

  ///Pauses playback of all media in the web view.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback)).
  ///- MacOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback)).
  Future<void> pauseAllMediaPlayback() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod('pauseAllMediaPlayback', args);
  }

  ///Changes whether the webpage is suspending playback of all media in the page.
  ///Pass `true` to pause all media the web view is playing. Neither the user nor the webpage can resume playback until you call this method again with `false`.
  ///
  ///[suspended] represents a [bool] value that indicates whether the webpage should suspend media playback.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended)).
  ///- MacOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended)).
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("suspended", () => suspended);
    return await channel?.invokeMethod('setAllMediaPlaybackSuspended', args);
  }

  ///Closes all media the web view is presenting, including picture-in-picture video and fullscreen video.
  ///
  ///**NOTE for iOS**: available on iOS 14.5+.
  ///
  ///**NOTE for MacOS**: available on MacOS 11.3+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations)).
  ///- MacOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations)).
  Future<void> closeAllMediaPresentations() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod('closeAllMediaPresentations', args);
  }

  ///Requests the playback status of media in the web view.
  ///Returns a [MediaPlaybackState] that indicates whether the media in the web view is playing, paused, or suspended.
  ///If there’s no media in the web view to play, this method provides [MediaPlaybackState.NONE].
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate)).
  ///- MacOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate)).
  Future<MediaPlaybackState?> requestMediaPlaybackState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return MediaPlaybackState.fromNativeValue(
        await channel?.invokeMethod('requestMediaPlaybackState', args));
  }

  ///Returns `true` if the [WebView] is in fullscreen mode, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<bool> isInFullscreen() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isInFullscreen', args) ?? false;
  }

  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the camera to capture images or video.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate)).
  ///- MacOS ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate)).
  Future<MediaCaptureState?> getCameraCaptureState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return MediaCaptureState.fromNativeValue(
        await channel?.invokeMethod('getCameraCaptureState', args));
  }

  ///Changes whether the webpage is using the camera to capture images or video.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate)).
  ///- MacOS ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate)).
  Future<void> setCameraCaptureState({required MediaCaptureState state}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('state', () => state.toNativeValue());
    await channel?.invokeMethod('setCameraCaptureState', args);
  }

  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the microphone to capture audio.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate)).
  ///- MacOS ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate)).
  Future<MediaCaptureState?> getMicrophoneCaptureState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return MediaCaptureState.fromNativeValue(
        await channel?.invokeMethod('getMicrophoneCaptureState', args));
  }

  ///Changes whether the webpage is using the microphone to capture audio.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate)).
  ///- MacOS ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate)).
  Future<void> setMicrophoneCaptureState(
      {required MediaCaptureState state}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('state', () => state.toNativeValue());
    await channel?.invokeMethod('setMicrophoneCaptureState', args);
  }

  ///Loads the web content from the data you provide as if the data were the response to the request.
  ///If [urlResponse] is `null`, it loads the web content from the data as an utf8 encoded HTML string as the response to the request.
  ///
  ///[urlRequest] represents a URL request that specifies the base URL and other loading details the system uses to interpret the data you provide.
  ///
  ///[urlResponse] represents a response the system uses to interpret the data you provide.
  ///
  ///[data] represents the data or the utf8 encoded HTML string to use as the contents of the webpage.
  ///
  ///Example:
  ///```dart
  ///controller.loadSimulateloadSimulatedRequestdRequest(urlRequest: URLRequest(
  ///    url: WebUri("https://flutter.dev"),
  ///  ),
  ///  data: Uint8List.fromList(utf8.encode("<h1>Hello</h1>"))
  ///);
  ///```
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest) and [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)).
  ///- MacOS ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest) and [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)).
  Future<void> loadSimulatedRequest(
      {required URLRequest urlRequest,
      required Uint8List data,
      URLResponse? urlResponse}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('urlResponse', () => urlResponse?.toMap());
    await channel?.invokeMethod('loadSimulatedRequest', args);
  }

  ///Returns the iframe `id` attribute used on the Web platform.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Web
  Future<String?> getIFrameId() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getIFrameId', args);
  }

  ///Gets the default user agent.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebSettings.getDefaultUserAgent](https://developer.android.com/reference/android/webkit/WebSettings#getDefaultUserAgent(android.content.Context)))
  ///- iOS
  ///- MacOS
  Future<String> getDefaultUserAgent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<String>(
            'getDefaultUserAgent', args) ??
        '';
  }

  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///
  ///**NOTE**: On iOS certificate-based credentials are never stored permanently.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearClientCertPreferences](https://developer.android.com/reference/android/webkit/WebView#clearClientCertPreferences(java.lang.Runnable)))
  Future<void> clearClientCertPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _staticChannel.invokeMethod('clearClientCertPreferences', args);
  }

  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getSafeBrowsingPrivacyPolicyUrl](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getSafeBrowsingPrivacyPolicyUrl()))
  Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await _staticChannel.invokeMethod(
        'getSafeBrowsingPrivacyPolicyUrl', args);
    return url != null ? WebUri(url) : null;
  }

  ///Use [setSafeBrowsingAllowlist] instead.
  @Deprecated("Use setSafeBrowsingAllowlist instead")
  Future<bool> setSafeBrowsingWhitelist({required List<String> hosts}) async {
    return await setSafeBrowsingAllowlist(hosts: hosts);
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
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_ALLOWLIST].
  ///
  ///[hosts] represents the list of hosts. This value must never be `null`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.setSafeBrowsingAllowlist](https://developer.android.com/reference/androidx/webkit/WebViewCompat#setSafeBrowsingAllowlist(java.util.Set%3Cjava.lang.String%3E,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('hosts', () => hosts);
    return await _staticChannel.invokeMethod<bool>(
            'setSafeBrowsingAllowlist', args) ??
        false;
  }

  ///If WebView has already been loaded into the current process this method will return the package that was used to load it.
  ///Otherwise, the package that would be used if the WebView was loaded right now will be returned;
  ///this does not cause WebView to be loaded, so this information may become outdated at any time.
  ///The WebView package changes either when the current WebView package is updated, disabled, or uninstalled.
  ///It can also be changed through a Developer Setting. If the WebView package changes, any app process that
  ///has loaded WebView will be killed.
  ///The next time the app starts and loads WebView it will use the new WebView package instead.
  ///
  ///**NOTE**: available only on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getCurrentWebViewPackage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getCurrentWebViewPackage(android.content.Context)))
  Future<WebViewPackageInfo?> getCurrentWebViewPackage() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? packageInfo =
        (await _staticChannel.invokeMethod('getCurrentWebViewPackage', args))
            ?.cast<String, dynamic>();
    return WebViewPackageInfo.fromMap(packageInfo);
  }

  ///Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
  ///This flag can be enabled in order to facilitate debugging of web layouts and JavaScript code running inside WebViews.
  ///Please refer to WebView documentation for the debugging guide. The default is `false`.
  ///
  ///[debuggingEnabled] whether to enable web contents debugging.
  ///
  ///**NOTE**: available only on Android 19+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.setWebContentsDebuggingEnabled](https://developer.android.com/reference/android/webkit/WebView#setWebContentsDebuggingEnabled(boolean)))
  Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('debuggingEnabled', () => debuggingEnabled);
    return await _staticChannel.invokeMethod(
        'setWebContentsDebuggingEnabled', args);
  }

  ///Gets the WebView variations encoded to be used as the X-Client-Data HTTP header.
  ///
  ///The app is responsible for adding the X-Client-Data header to any request
  ///that may use variations metadata, such as requests to Google web properties.
  ///The returned string will be a base64 encoded ClientVariations proto:
  ///https://source.chromium.org/chromium/chromium/src/+/main:components/variations/proto/client_variations.proto
  ///
  ///The string may be empty if the header is not available.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.GET_VARIATIONS_HEADER].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getVariationsHeader](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getVariationsHeader()))
  Future<String?> getVariationsHeader() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<String?>(
        'getVariationsHeader', args);
  }

  ///Returns `true` if WebView is running in multi process mode.
  ///
  ///In Android O and above, WebView may run in "multiprocess" mode.
  ///In multiprocess mode, rendering of web content is performed by a sandboxed
  ///renderer process separate to the application process.
  ///This renderer process may be shared with other WebViews in the application,
  ///but is not shared with other application processes.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.MULTI_PROCESS].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.isMultiProcessEnabled](https://developer.android.com/reference/androidx/webkit/WebViewCompat#isMultiProcessEnabled()))
  Future<bool> isMultiProcessEnabled() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<bool>(
            'isMultiProcessEnabled', args) ??
        false;
  }

  ///Indicate that the current process does not intend to use WebView,
  ///and that an exception should be thrown if a WebView is created or any other
  ///methods in the `android.webkit` package are used.
  ///
  ///Applications with multiple processes may wish to call this in processes that
  ///are not intended to use WebView to avoid accidentally incurring the memory usage
  ///of initializing WebView in long-lived processes that have no need for it,
  ///and to prevent potential data directory conflicts (see [ProcessGlobalConfigSettings.dataDirectorySuffix]).
  ///
  ///**NOTE for Android**: available only on Android 28+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.disableWebView](https://developer.android.com/reference/android/webkit/WebView.html#disableWebView()))
  Future<void> disableWebView() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _staticChannel.invokeMethod('disableWebView', args);
  }

  ///Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
  ///
  ///[urlScheme] represents the URL scheme associated with the resource.
  ///
  ///**NOTE for iOS**: available only on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 10.13+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  ///- MacOS ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  Future<bool> handlesURLScheme(String urlScheme) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlScheme', () => urlScheme);
    return await _staticChannel.invokeMethod('handlesURLScheme', args);
  }

  ///Disposes the WebView that is using the [keepAlive] instance
  ///for the keep alive feature.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('keepAliveId', () => keepAlive.id);
    await _staticChannel.invokeMethod('disposeKeepAlive', args);
    _keepAliveMap[keepAlive] = null;
  }

  ///Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with [tRexRunnerCss].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<String> get tRexRunnerHtml async => await rootBundle.loadString(
      'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html');

  ///Gets the css of the Chromium's t-rex runner game. Used in combination with [tRexRunnerHtml].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<String> get tRexRunnerCss async => await rootBundle.loadString(
      'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css');

  ///View ID used internally.
  dynamic getViewId() {
    return id;
  }

  ///Disposes the controller.
  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
    _inAppBrowser = null;
    webStorage.dispose();
    if (!isKeepAlive) {
      _controllerFromPlatform = null;
      _javaScriptHandlersMap.clear();
      _userScripts.clear();
      _webMessageListenerObjNames.clear();
      _injectedScriptsFromURL.clear();
      for (final webMessageChannel in _webMessageChannels) {
        webMessageChannel.dispose();
      }
      _webMessageChannels.clear();
      for (final webMessageListener in _webMessageListeners) {
        webMessageListener.dispose();
      }
      _webMessageListeners.clear();
    }
  }
}

extension InternalInAppWebViewController on AndroidInAppWebViewController {
  get handleMethod => _handleMethod;
}
