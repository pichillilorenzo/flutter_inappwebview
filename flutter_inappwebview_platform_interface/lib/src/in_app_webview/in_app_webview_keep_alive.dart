/// @docImport 'in_app_webview_settings.dart';
/// @docImport 'platform_headless_in_app_webview.dart';
/// @docImport 'platform_webview.dart';
library;

import '../types/main.dart';
import '../util.dart';
import '../web_message/platform_web_message_channel.dart';
import '../web_message/platform_web_message_listener.dart';
import 'platform_inappwebview_widget.dart';
import 'platform_inappwebview_controller.dart';

///Class used to keep alive a [PlatformInAppWebViewWidget].
class InAppWebViewKeepAlive {
  InAppWebViewKeepAlive({
    this.onRenderProcessGone,
    this.onWebContentProcessDidTerminate,
  });

  ///Event fired when the kept-alive WebView's render process is gone, for the
  ///whole native lifetime of the WebView: whether a widget is currently
  ///attached to it or not. While one is, its own
  ///[PlatformWebViewCreationParams.onRenderProcessGone] fires for the same
  ///death as well: handle it in one of the two.
  ///
  ///Passing it also enables [InAppWebViewSettings.useOnRenderProcessGone]
  ///when the WebView is created, as the widget's own callback does. A keep
  ///alive handed a running [PlatformHeadlessInAppWebView] through
  ///[PlatformInAppWebViewWidgetCreationParams.headlessWebView] takes that
  ///WebView over as it was created, so the setting comes from the headless
  ///creation and not from this callback.
  ///
  ///The WebView is unusable once this fires: dispose the keep alive, and do
  ///not attach another widget to it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.onRenderProcessGone](https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)))
  ///- Windows WebView2: fired for a browser process exit; a render process
  ///exit is reported through [onWebContentProcessDidTerminate] instead.
  final void Function(RenderProcessGoneDetail detail)? onRenderProcessGone;

  ///Event fired when the kept-alive WebView's content process is terminated,
  ///for the whole native lifetime of the WebView: whether a widget is
  ///currently attached to it or not. While one is, its own
  ///[PlatformWebViewCreationParams.onWebContentProcessDidTerminate] fires for
  ///the same termination as well: handle it in one of the two.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- MacOS ([Official API - WKNavigationDelegate.webViewWebContentProcessDidTerminate](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi))
  ///- Windows WebView2: fired for a render process exit.
  final void Function()? onWebContentProcessDidTerminate;

  String _id = IdGenerator.generate();
}

///Used internally
extension InternalInAppWebViewKeepAlive on InAppWebViewKeepAlive {
  String get id => _id;

  set id(String id) {
    _id = id;
  }
}

///Used internally to save and restore [PlatformInAppWebViewController] properties
///for the keep alive feature.
class InAppWebViewControllerKeepAliveProps {
  Map<String, Function> javaScriptHandlersMap;
  Map<UserScriptInjectionTime, List<UserScript>> userScripts;
  Set<String> webMessageListenerObjNames;
  Map<String, ScriptHtmlTagAttributes> injectedScriptsFromURL;
  Set<PlatformWebMessageChannel> webMessageChannels = Set();
  Set<PlatformWebMessageListener> webMessageListeners = Set();
  Map<String, Function(dynamic data)> devToolsProtocolEventListenerMap;

  InAppWebViewControllerKeepAliveProps({
    this.javaScriptHandlersMap = const {},
    this.userScripts = const {},
    this.webMessageListenerObjNames = const {},
    this.injectedScriptsFromURL = const {},
    this.webMessageChannels = const {},
    this.webMessageListeners = const {},
    this.devToolsProtocolEventListenerMap = const {},
  });
}
