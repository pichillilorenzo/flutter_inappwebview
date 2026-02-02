// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_inappwebview_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformInAppWebViewControllerClassSupported
    on PlatformInAppWebViewController {
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformInAppWebViewController]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformInAppWebViewControllerProperty {
  ///Can be used to check if the [PlatformInAppWebViewController.tRexRunnerCss] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  tRexRunnerCss,

  ///Can be used to check if the [PlatformInAppWebViewController.tRexRunnerHtml] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  tRexRunnerHtml,

  ///Can be used to check if the [PlatformInAppWebViewController.webStorage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webStorage,
}

extension _PlatformInAppWebViewControllerPropertySupported
    on PlatformInAppWebViewController {
  static bool isPropertySupported(
    PlatformInAppWebViewControllerProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformInAppWebViewControllerProperty.tRexRunnerCss:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerProperty.tRexRunnerHtml:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerProperty.webStorage:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformInAppWebViewController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformInAppWebViewControllerMethod {
  ///Can be used to check if the [PlatformInAppWebViewController.addDevToolsProtocolEventListener] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addDevToolsProtocolEventListener.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2DevToolsProtocolEventReceiver.add_DevToolsProtocolEventReceived](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2devtoolsprotocoleventreceiver?view=webview2-1.0.2210.55#add_devtoolsprotocoleventreceived))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [eventName]: all platforms
  ///- [callback]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addDevToolsProtocolEventListener,

  ///Can be used to check if the [PlatformInAppWebViewController.addJavaScriptHandler] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [handlerName]: all platforms
  ///- [callback]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addJavaScriptHandler,

  ///Can be used to check if the [PlatformInAppWebViewController.addUserScript] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript)):
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Linux WPE WebKit ([Official API - webkit_user_content_manager_add_script](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.UserContentManager.add_script.html))
  ///- macOS WKWebView ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript)):
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [userScript]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addUserScript,

  ///Can be used to check if the [PlatformInAppWebViewController.addUserScripts] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Linux WPE WebKit
  ///- macOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [userScripts]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addUserScripts,

  ///Can be used to check if the [PlatformInAppWebViewController.addWebMessageListener] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.WebMessageListener](https://developer.android.com/reference/androidx/webkit/WebViewCompat#addWebMessageListener(android.webkit.WebView,%20java.lang.String,%20java.util.Set%3Cjava.lang.String%3E,%20androidx.webkit.WebViewCompat.WebMessageListener))):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.WEB_MESSAGE_LISTENER].
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit ([Official API - webkit_user_content_manager_add_script](https://webkitgtk.org/reference/webkit2gtk/stable/method.UserContentManager.add_script.html)):
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [webMessageListener]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addWebMessageListener,

  ///Can be used to check if the [PlatformInAppWebViewController.callAsyncJavaScript] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+
  ///- iOS WKWebView 14.3+ ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  ///- Windows WebView2
  ///- Linux WPE WebKit 2.40+ ([Official API - webkit_web_view_call_async_javascript_function](https://webkitgtk.org/reference/webkit2gtk/stable/method.WebView.call_async_javascript_function.html)):
  ///    - Uses WPE WebKit call_async_javascript_function API which handles JavaScript Promises automatically.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [functionBody]: all platforms
  ///- [arguments]: all platforms
  ///- [contentWorld]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  callAsyncJavaScript,

  ///Can be used to check if the [PlatformInAppWebViewController.callDevToolsProtocolMethod] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callDevToolsProtocolMethod.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2.CallDevToolsProtocolMethod](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#calldevtoolsprotocolmethod))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [methodName]: all platforms
  ///- [parameters]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  callDevToolsProtocolMethod,

  ///Can be used to check if the [PlatformInAppWebViewController.canGoBack] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.canGoBack](https://developer.android.com/reference/android/webkit/WebView#canGoBack()))
  ///- iOS WKWebView ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  ///- macOS WKWebView ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  ///- Windows WebView2 ([Official API - ICoreWebView2.get_CanGoBack](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_cangoback))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_can_go_back](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.can_go_back.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  canGoBack,

  ///Can be used to check if the [PlatformInAppWebViewController.canGoBackOrForward] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.canGoBackOrForward](https://developer.android.com/reference/android/webkit/WebView#canGoBackOrForward(int)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [steps]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  canGoBackOrForward,

  ///Can be used to check if the [PlatformInAppWebViewController.canGoForward] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.canGoForward](https://developer.android.com/reference/android/webkit/WebView#canGoForward()))
  ///- iOS WKWebView ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  ///- macOS WKWebView ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  ///- Windows WebView2 ([Official API - ICoreWebView2.get_CanGoForward](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_cangoforward))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_can_go_forward](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.can_go_forward.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  canGoForward,

  ///Can be used to check if the [PlatformInAppWebViewController.canScrollHorizontally] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  canScrollHorizontally,

  ///Can be used to check if the [PlatformInAppWebViewController.canScrollVertically] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  canScrollVertically,

  ///Can be used to check if the [PlatformInAppWebViewController.clearAllCache] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [includeDiskFiles]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearAllCache,

  ///Can be used to check if the [PlatformInAppWebViewController.clearCache] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearCache.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use InAppWebViewController.clearAllCache instead')
  clearCache,

  ///Can be used to check if the [PlatformInAppWebViewController.clearClientCertPreferences] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebView.clearClientCertPreferences](https://developer.android.com/reference/android/webkit/WebView#clearClientCertPreferences(java.lang.Runnable)))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearClientCertPreferences,

  ///Can be used to check if the [PlatformInAppWebViewController.clearFocus] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ViewGroup.clearFocus](https://developer.android.com/reference/android/view/ViewGroup#clearFocus()))
  ///- iOS WKWebView ([Official API - UIResponder.resignFirstResponder](https://developer.apple.com/documentation/uikit/uiresponder/1621097-resignfirstresponder))
  ///- macOS WKWebView ([Official API - NSWindow.makeFirstResponder](https://developer.apple.com/documentation/appkit/nswindow/1419366-makefirstresponder))
  ///- Linux WPE WebKit ([Official API - wpe_view_backend_remove_activity_state](https://wpewebkit.org/reference/stable/wpe-platform-2.0/func.view_backend_remove_activity_state.html)):
  ///    - Removes focused state from WPE backend and blurs active element via JavaScript
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearFocus,

  ///Can be used to check if the [PlatformInAppWebViewController.clearFormData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.clearFormData](https://developer.android.com/reference/android/webkit/WebView#clearFormData()))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearFormData,

  ///Can be used to check if the [PlatformInAppWebViewController.clearHistory] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.clearHistory](https://developer.android.com/reference/android/webkit/WebView#clearHistory()))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearHistory,

  ///Can be used to check if the [PlatformInAppWebViewController.clearMatches] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearMatches.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use FindInteractionController.clearMatches instead')
  clearMatches,

  ///Can be used to check if the [PlatformInAppWebViewController.clearSslPreferences] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.clearSslPreferences](https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()))
  ///- Windows WebView2 ([Official API - ICoreWebView2_3.ClearServerCertificateErrorActions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_14?view=webview2-1.0.2792.45#clearservercertificateerroractions))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearSslPreferences,

  ///Can be used to check if the [PlatformInAppWebViewController.closeAllMediaPresentations] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+ ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations))
  ///- macOS WKWebView 11.3+ ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations))
  ///- Linux WPE WebKit ([Official API - JavaScript Document.exitFullscreen()/exitPictureInPicture()](https://developer.mozilla.org/en-US/docs/Web/API/Document/exitFullscreen)):
  ///    - Uses JavaScript to exit fullscreen and picture-in-picture modes
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  closeAllMediaPresentations,

  ///Can be used to check if the [PlatformInAppWebViewController.createPdf] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  ///- Windows WebView2 ([Official API - ICoreWebView2_16.PrintToPdfStream](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_16#printtopdfstream))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [pdfConfiguration]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  createPdf,

  ///Can be used to check if the [PlatformInAppWebViewController.createWebArchiveData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  createWebArchiveData,

  ///Can be used to check if the [PlatformInAppWebViewController.createWebMessageChannel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.createWebMessageChannel](https://developer.android.com/reference/androidx/webkit/WebViewCompat#createWebMessageChannel(android.webkit.WebView))):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL].
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  createWebMessageChannel,

  ///Can be used to check if the [PlatformInAppWebViewController.disableWebView] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 28+ ([Official API - WebView.disableWebView](https://developer.android.com/reference/android/webkit/WebView#disableWebView()))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  disableWebView,

  ///Can be used to check if the [PlatformInAppWebViewController.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [isKeepAlive]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformInAppWebViewController.disposeKeepAlive] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [keepAlive]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  disposeKeepAlive,

  ///Can be used to check if the [PlatformInAppWebViewController.enableSlowWholeDocumentDraw] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebView.enableSlowWholeDocumentDraw](https://developer.android.com/reference/android/webkit/WebView#enableSlowWholeDocumentDraw())):
  ///    - This method should be called before any WebViews are created.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  enableSlowWholeDocumentDraw,

  ///Can be used to check if the [PlatformInAppWebViewController.evaluateJavascript] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.evaluateJavascript](https://developer.android.com/reference/android/webkit/WebView#evaluateJavascript(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS WKWebView ([Official API - WKWebView.evaluateJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- macOS WKWebView ([Official API - WKWebView.evaluateJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- Web \<iframe\> but requires same origin ([Official API - Window.eval](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval))
  ///- Windows WebView2
  ///- Linux WPE WebKit ([Official API - webkit_web_view_evaluate_javascript](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.evaluate_javascript.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [source]: all platforms
  ///- [contentWorld]:
  ///    - Android WebView
  ///    - iOS WKWebView 14.0+
  ///    - macOS WKWebView 11.0+
  ///    - Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  evaluateJavascript,

  ///Can be used to check if the [PlatformInAppWebViewController.findAllAsync] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.findAllAsync.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [find]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use FindInteractionController.findAll instead')
  findAllAsync,

  ///Can be used to check if the [PlatformInAppWebViewController.findNext] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.findNext.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [forward]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use FindInteractionController.findNext instead')
  findNext,

  ///Can be used to check if the [PlatformInAppWebViewController.getCameraCaptureState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate))
  ///- Linux WPE WebKit 2.34+ ([Official API - webkit_web_view_get_camera_capture_state](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_camera_capture_state.html))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCameraCaptureState,

  ///Can be used to check if the [PlatformInAppWebViewController.getCertificate] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getCertificate](https://developer.android.com/reference/android/webkit/WebView#getCertificate()))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_tls_info](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_tls_info.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCertificate,

  ///Can be used to check if the [PlatformInAppWebViewController.getContentHeight] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getContentHeight](https://developer.android.com/reference/android/webkit/WebView#getContentHeight()))
  ///- iOS WKWebView ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin ([Official API - Document.documentElement.scrollHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight))
  ///- Linux WPE WebKit
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getContentHeight,

  ///Can be used to check if the [PlatformInAppWebViewController.getContentWidth] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - This method is implemented using JavaScript.
  ///- iOS WKWebView ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin ([Official API - Document.documentElement.scrollWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth))
  ///- Linux WPE WebKit
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getContentWidth,

  ///Can be used to check if the [PlatformInAppWebViewController.getCopyBackForwardList] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.copyBackForwardList](https://developer.android.com/reference/android/webkit/WebView#copyBackForwardList()))
  ///- iOS WKWebView ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  ///- macOS WKWebView ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCopyBackForwardList,

  ///Can be used to check if the [PlatformInAppWebViewController.getCurrentWebViewPackage] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebViewCompat.getCurrentWebViewPackage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getCurrentWebViewPackage(android.content.Context)))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCurrentWebViewPackage,

  ///Can be used to check if the [PlatformInAppWebViewController.getDefaultUserAgent] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.getDefaultUserAgent](https://developer.android.com/reference/android/webkit/WebSettings#getDefaultUserAgent(android.content.Context)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin ([Official API - Navigator.userAgent](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/userAgent))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getDefaultUserAgent,

  ///Can be used to check if the [PlatformInAppWebViewController.getFavicon] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicon.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2_15.GetFavicon](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_15?view=webview2-1.0.2849.39#getfavicon))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [faviconImageFormat]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getFavicon,

  ///Can be used to check if the [PlatformInAppWebViewController.getFavicons] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getFavicons,

  ///Can be used to check if the [PlatformInAppWebViewController.getFrameId] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFrameId.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2_20.get_FrameId](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_20?view=webview2-1.0.2849.39#get_frameid))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getFrameId,

  ///Can be used to check if the [PlatformInAppWebViewController.getHitTestResult] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getHitTestResult](https://developer.android.com/reference/android/webkit/WebView#getHitTestResult()))
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit ([Official API - WebKitHitTestResult](https://webkitgtk.org/reference/webkit2gtk/stable/WebKitHitTestResult.html)):
  ///    - This method uses native WebKitHitTestResult from the mouse-target-changed signal.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getHitTestResult,

  ///Can be used to check if the [PlatformInAppWebViewController.getHtml] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getHtml,

  ///Can be used to check if the [PlatformInAppWebViewController.getIFrameId] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getIFrameId.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getIFrameId,

  ///Can be used to check if the [PlatformInAppWebViewController.getJavaScriptBridgeName] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getJavaScriptBridgeName,

  ///Can be used to check if the [PlatformInAppWebViewController.getMemoryUsageTargetLevel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMemoryUsageTargetLevel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2_19.get_MemoryUsageTargetLevel](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_19?view=webview2-1.0.2849.39#get_memoryusagetargetlevel))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getMemoryUsageTargetLevel,

  ///Can be used to check if the [PlatformInAppWebViewController.getMetaTags] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - This method is implemented using JavaScript.
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin:
  ///    - This method is implemented using JavaScript.
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getMetaTags,

  ///Can be used to check if the [PlatformInAppWebViewController.getMetaThemeColor] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - This method is implemented using JavaScript.
  ///- iOS WKWebView ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor)):
  ///    - On iOS < 15.0, this method is implemented using JavaScript.
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_theme_color](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_theme_color.html))
  ///- macOS WKWebView ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor)):
  ///    - On iOS < 12.0, this method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin:
  ///    - This method is implemented using JavaScript.
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getMetaThemeColor,

  ///Can be used to check if the [PlatformInAppWebViewController.getMicrophoneCaptureState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate))
  ///- Linux WPE WebKit 2.34+ ([Official API - webkit_web_view_get_microphone_capture_state](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_microphone_capture_state.html))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getMicrophoneCaptureState,

  ///Can be used to check if the [PlatformInAppWebViewController.getOptions] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOptions.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use getSettings instead')
  getOptions,

  ///Can be used to check if the [PlatformInAppWebViewController.getOriginalUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getOriginalUrl](https://developer.android.com/reference/android/webkit/WebView#getOriginalUrl()))
  ///- iOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_uri](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_uri.html)):
  ///    - Returns the current URL. WPE WebKit does not distinguish between original and current URL.
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin:
  ///    - It will return the current value of the `iframe.src` attribute.
  ///- Windows WebView2:
  ///    - Returns the current URL. WebView2 does not distinguish between original and current URL.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getOriginalUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.getProgress] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getProgress](https://developer.android.com/reference/android/webkit/WebView#getProgress()))
  ///- iOS WKWebView ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  ///- macOS WKWebView ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_estimated_load_progress](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_estimated_load_progress.html))
  ///- Windows WebView2:
  ///    - Progress is tracked through navigation events: NavigationStarting (0), ContentLoading (33), DOMContentLoaded (66), NavigationCompleted (100).
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getProgress,

  ///Can be used to check if the [PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.getSafeBrowsingPrivacyPolicyUrl](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getSafeBrowsingPrivacyPolicyUrl())):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL].
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getSafeBrowsingPrivacyPolicyUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.getScale] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use getZoomScale instead')
  getScale,

  ///Can be used to check if the [PlatformInAppWebViewController.getScreenScale] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScreenScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - wpe_screen_get_scale](https://wpewebkit.org/reference/stable/wpe-platform-1.0/method.Screen.get_scale.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getScreenScale,

  ///Can be used to check if the [PlatformInAppWebViewController.getScrollX] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.getScrollX](https://developer.android.com/reference/android/view/View#getScrollX()))
  ///- iOS WKWebView ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit
  ///- Web \<iframe\> but requires same origin ([Official API - Window.scrollX](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollX))
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getScrollX,

  ///Can be used to check if the [PlatformInAppWebViewController.getScrollY] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.getScrollY](https://developer.android.com/reference/android/view/View#getScrollY()))
  ///- iOS WKWebView ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit
  ///- Web \<iframe\> but requires same origin ([Official API - Window.scrollY](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollY))
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getScrollY,

  ///Can be used to check if the [PlatformInAppWebViewController.getSelectedText] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - This method is implemented using JavaScript.
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getSelectedText,

  ///Can be used to check if the [PlatformInAppWebViewController.getSettings] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getSettings,

  ///Can be used to check if the [PlatformInAppWebViewController.getTRexRunnerCss] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTRexRunnerCss.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use tRexRunnerCss instead')
  getTRexRunnerCss,

  ///Can be used to check if the [PlatformInAppWebViewController.getTRexRunnerHtml] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTRexRunnerHtml.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use tRexRunnerHtml instead')
  getTRexRunnerHtml,

  ///Can be used to check if the [PlatformInAppWebViewController.getTargetRefreshRate] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTargetRefreshRate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getTargetRefreshRate,

  ///Can be used to check if the [PlatformInAppWebViewController.getTitle] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getTitle](https://developer.android.com/reference/android/webkit/WebView#getTitle()))
  ///- iOS WKWebView ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- macOS WKWebView ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2 ([Official API - ICoreWebView2.get_DocumentTitle](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_documenttitle))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_title](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_title.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getTitle,

  ///Can be used to check if the [PlatformInAppWebViewController.getUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.getUrl](https://developer.android.com/reference/android/webkit/WebView#getUrl()))
  ///- iOS WKWebView ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- macOS WKWebView ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- Web \<iframe\> but requires same origin:
  ///    - If `window.location.href` isn't accessible inside the iframe, it will return the current value of the `iframe.src` attribute.
  ///- Windows WebView2 ([Official API - ICoreWebView2.get_Source](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#get_source))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_uri](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_uri.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.getVariationsHeader] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.getVariationsHeader](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getVariationsHeader())):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.GET_VARIATIONS_HEADER].
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getVariationsHeader,

  ///Can be used to check if the [PlatformInAppWebViewController.getViewId] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getViewId,

  ///Can be used to check if the [PlatformInAppWebViewController.getZoomScale] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIScrollView.zoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619419-zoomscale))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_get_zoom_level](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_zoom_level.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2Controller.get_ZoomFactor](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller?view=webview2-1.0.2849.39#get_zoomfactor))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getZoomScale,

  ///Can be used to check if the [PlatformInAppWebViewController.goBack] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBack.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.goBack](https://developer.android.com/reference/android/webkit/WebView#goBack()))
  ///- iOS WKWebView ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- macOS WKWebView ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- Web \<iframe\> but requires same origin ([Official API - History.back](https://developer.mozilla.org/en-US/docs/Web/API/History/back))
  ///- Windows WebView2 ([Official API - ICoreWebView2.GoBack](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#goback))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_go_back](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.go_back.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  goBack,

  ///Can be used to check if the [PlatformInAppWebViewController.goBackOrForward] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.goBackOrForward](https://developer.android.com/reference/android/webkit/WebView#goBackOrForward(int)))
  ///- iOS WKWebView ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- macOS WKWebView ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- Web \<iframe\> but requires same origin ([Official API - History.go](https://developer.mozilla.org/en-US/docs/Web/API/History/go))
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [steps]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  goBackOrForward,

  ///Can be used to check if the [PlatformInAppWebViewController.goForward] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goForward.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.goForward](https://developer.android.com/reference/android/webkit/WebView#goForward()))
  ///- iOS WKWebView ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- macOS WKWebView ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- Web \<iframe\> but requires same origin ([Official API - History.forward](https://developer.mozilla.org/en-US/docs/Web/API/History/forward))
  ///- Windows WebView2 ([Official API - ICoreWebView2.GoForward](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#goforward))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_go_forward](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.go_forward.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  goForward,

  ///Can be used to check if the [PlatformInAppWebViewController.goTo] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goTo.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [historyItem]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  goTo,

  ///Can be used to check if the [PlatformInAppWebViewController.handlesURLScheme] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  ///- macOS WKWebView 10.13+ ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  ///- Linux WPE WebKit:
  ///    - Returns true for built-in schemes (http, https, file, ftp, data, blob, about, javascript).
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [urlScheme]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  handlesURLScheme,

  ///Can be used to check if the [PlatformInAppWebViewController.hasJavaScriptHandler] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [handlerName]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasJavaScriptHandler,

  ///Can be used to check if the [PlatformInAppWebViewController.hasOnlySecureContent] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  ///- macOS WKWebView ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasOnlySecureContent,

  ///Can be used to check if the [PlatformInAppWebViewController.hasUserScript] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [userScript]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasUserScript,

  ///Can be used to check if the [PlatformInAppWebViewController.hasWebMessageListener] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [webMessageListener]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasWebMessageListener,

  ///Can be used to check if the [PlatformInAppWebViewController.hideInputMethod] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - InputMethodManager.hideSoftInputFromWindow](https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#hideSoftInputFromWindow(android.os.IBinder,%20int)))
  ///- iOS WKWebView ([Official API - UIView.endEditing](https://developer.apple.com/documentation/uikit/uiview/1619630-endediting))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hideInputMethod,

  ///Can be used to check if the [PlatformInAppWebViewController.injectCSSCode] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [source]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  injectCSSCode,

  ///Can be used to check if the [PlatformInAppWebViewController.injectCSSFileFromAsset] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [assetFilePath]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  injectCSSFileFromAsset,

  ///Can be used to check if the [PlatformInAppWebViewController.injectCSSFileFromUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [urlFile]: all platforms
  ///- [cssLinkHtmlTagAttributes]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  injectCSSFileFromUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.injectJavascriptFileFromAsset] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [assetFilePath]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  injectJavascriptFileFromAsset,

  ///Can be used to check if the [PlatformInAppWebViewController.injectJavascriptFileFromUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [urlFile]: all platforms
  ///- [scriptHtmlTagAttributes]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  injectJavascriptFileFromUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.isInFullscreen] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isInFullscreen,

  ///Can be used to check if the [PlatformInAppWebViewController.isInterfaceSupported] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInterfaceSupported.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [interface]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isInterfaceSupported,

  ///Can be used to check if the [PlatformInAppWebViewController.isLoading] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_web_view_is_loading](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.is_loading.html))
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isLoading,

  ///Can be used to check if the [PlatformInAppWebViewController.isMultiProcessEnabled] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.isMultiProcessEnabled](https://developer.android.com/reference/androidx/webkit/WebViewCompat#isMultiProcessEnabled())):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.MULTI_PROCESS].
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isMultiProcessEnabled,

  ///Can be used to check if the [PlatformInAppWebViewController.isMuted] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMuted.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit 2.30+ ([Official API - webkit_web_view_get_is_muted](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.get_is_muted.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isMuted,

  ///Can be used to check if the [PlatformInAppWebViewController.isPlayingAudio] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isPlayingAudio.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit 2.8+ ([Official API - webkit_web_view_is_playing_audio](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.is_playing_audio.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isPlayingAudio,

  ///Can be used to check if the [PlatformInAppWebViewController.isSecureContext] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+:
  ///    - This method is implemented using JavaScript.
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Web \<iframe\> but requires same origin ([Official API - Window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext))
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isSecureContext,

  ///Can be used to check if the [PlatformInAppWebViewController.isVisible] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isVisible.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - wpe_view_get_visible](https://wpewebkit.org/reference/stable/wpe-platform-1.0/method.View.get_visible.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isVisible,

  ///Can be used to check if the [PlatformInAppWebViewController.loadData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.loadDataWithBaseURL](https://developer.android.com/reference/android/webkit/WebView#loadDataWithBaseURL(java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String)))
  ///- iOS WKWebView ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring)):
  ///    - or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load)
  ///- macOS WKWebView ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring)):
  ///    - or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load)
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2 ([Official API - ICoreWebView2.NavigateToString](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#navigatetostring))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_load_html](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.load_html.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [data]: all platforms
  ///- [mimeType]:
  ///    - Android WebView
  ///    - iOS WKWebView
  ///    - macOS WKWebView
  ///    - Web \<iframe\> but requires same origin
  ///- [encoding]:
  ///    - Android WebView
  ///    - iOS WKWebView
  ///    - macOS WKWebView
  ///- [baseUrl]:
  ///    - Android WebView
  ///    - iOS WKWebView
  ///    - macOS WKWebView
  ///- [historyUrl]:
  ///    - Android WebView
  ///- [allowingReadAccessTo]:
  ///    - iOS WKWebView
  ///    - macOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  loadData,

  ///Can be used to check if the [PlatformInAppWebViewController.loadFile] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- macOS WKWebView ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2 ([Official API - ICoreWebView2.Navigate](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#navigate))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_load_uri](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.load_uri.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [assetFilePath]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  loadFile,

  ///Can be used to check if the [PlatformInAppWebViewController.loadSimulatedRequest] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest)):
  ///    - or [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest)):
  ///    - or [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [urlRequest]: all platforms
  ///- [data]: all platforms
  ///- [urlResponse]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  loadSimulatedRequest,

  ///Can be used to check if the [PlatformInAppWebViewController.loadUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String))):
  ///    - If method is "POST", [Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])). Also, when loading an URL Request using "POST" method, headers are ignored.
  ///- iOS WKWebView ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load)):
  ///    - If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)
  ///- macOS WKWebView ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load)):
  ///    - If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)
  ///- Web \<iframe\> but requires same origin:
  ///    - If method is "GET" and headers are empty, it will change the `src` of the iframe. For all other cases it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///- Windows WebView2 ([Official API - ICoreWebView2_2.NavigateWithWebResourceRequest](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_2?view=webview2-1.0.2210.55#navigatewithwebresourcerequest))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_load_uri](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.load_uri.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [urlRequest]: all platforms
  ///- [allowingReadAccessTo]:
  ///    - iOS WKWebView
  ///    - macOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  loadUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.openDevTools] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.openDevTools.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2.OpenDevToolsWindow](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#opendevtoolswindow))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  openDevTools,

  ///Can be used to check if the [PlatformInAppWebViewController.pageDown] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.pageDown](https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [bottom]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  pageDown,

  ///Can be used to check if the [PlatformInAppWebViewController.pageUp] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.pageUp](https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [top]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  pageUp,

  ///Can be used to check if the [PlatformInAppWebViewController.pause] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pause.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.onPause](https://developer.android.com/reference/android/webkit/WebView#onPause()))
  ///- Windows WebView2 ([Official API - ICoreWebView2_3.TrySuspend](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_3?view=webview2-1.0.2792.45#trysuspend))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  pause,

  ///Can be used to check if the [PlatformInAppWebViewController.pauseAllMediaPlayback] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback))
  ///- Linux WPE WebKit ([Official API - JavaScript HTMLMediaElement.pause()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/pause)):
  ///    - Uses JavaScript to pause all audio and video elements
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  pauseAllMediaPlayback,

  ///Can be used to check if the [PlatformInAppWebViewController.pauseTimers] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.pauseTimers](https://developer.android.com/reference/android/webkit/WebView#pauseTimers()))
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript and it is restricted to just this WebView.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  pauseTimers,

  ///Can be used to check if the [PlatformInAppWebViewController.postUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin:
  ///    - It will try to create an XMLHttpRequest and load the result inside the iframe.
  ///- Windows WebView2
  ///- Linux WPE WebKit:
  ///    - Uses JavaScript to create an XMLHttpRequest and load the result.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [postData]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  postUrl,

  ///Can be used to check if the [PlatformInAppWebViewController.postWebMessage] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.postWebMessage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#postWebMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri))):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.POST_WEB_MESSAGE].
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [message]: all platforms
  ///- [targetOrigin]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  postWebMessage,

  ///Can be used to check if the [PlatformInAppWebViewController.printCurrentPage] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PrintManager.print](https://developer.android.com/reference/android/print/PrintManager#print(java.lang.String,%20android.print.PrintDocumentAdapter,%20android.print.PrintAttributes)))
  ///- iOS WKWebView ([Official API - UIPrintInteractionController.present](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618149-present))
  ///- macOS WKWebView ([Official API - WKWebView.printOperation](https://developer.apple.com/documentation/webkit/wkwebview/3516861-printoperation)):
  ///    - If macOS version is less than 11.0, it will use [Official API - NSView.printView](https://developer.apple.com/documentation/appkit/nsview/1483705-printview).
  ///- Web \<iframe\> but requires same origin ([Official API - Window.print](https://developer.mozilla.org/en-US/docs/Web/API/Window/print)):
  ///    - [PlatformPrintJobController] is always `null`.
  ///- Windows WebView2 ([Official API - ICoreWebView2_16.Print](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_16?view=webview2-1.0.2849.39#print))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  printCurrentPage,

  ///Can be used to check if the [PlatformInAppWebViewController.reload] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reload.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.reload](https://developer.android.com/reference/android/webkit/WebView#reload()))
  ///- iOS WKWebView ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- macOS WKWebView ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- Web \<iframe\> but requires same origin ([Official API - Location.reload](https://developer.mozilla.org/en-US/docs/Web/API/Location/reload)):
  ///    - if `window.location.reload()` is not accessible inside the iframe, it will reload using the iframe `src` attribute.
  ///- Windows WebView2 ([Official API - ICoreWebView2.Reload](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#reload))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_reload](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.reload.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  reload,

  ///Can be used to check if the [PlatformInAppWebViewController.reloadFromOrigin] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  ///- macOS WKWebView ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_reload_bypass_cache](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.reload_bypass_cache.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  reloadFromOrigin,

  ///Can be used to check if the [PlatformInAppWebViewController.removeAllUserScripts] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts)):
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Linux WPE WebKit ([Official API - webkit_user_content_manager_remove_all_scripts](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.UserContentManager.remove_all_scripts.html))
  ///- macOS WKWebView ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts)):
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeAllUserScripts,

  ///Can be used to check if the [PlatformInAppWebViewController.removeDevToolsProtocolEventListener] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeDevToolsProtocolEventListener.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2DevToolsProtocolEventReceiver.remove_DevToolsProtocolEventReceived](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2devtoolsprotocoleventreceiver?view=webview2-1.0.2210.55#remove_devtoolsprotocoleventreceived))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [eventName]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeDevToolsProtocolEventListener,

  ///Can be used to check if the [PlatformInAppWebViewController.removeJavaScriptHandler] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [handlerName]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeJavaScriptHandler,

  ///Can be used to check if the [PlatformInAppWebViewController.removeUserScript] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Linux WPE WebKit
  ///- macOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [userScript]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeUserScript,

  ///Can be used to check if the [PlatformInAppWebViewController.removeUserScripts] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Linux WPE WebKit
  ///- macOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [userScripts]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeUserScripts,

  ///Can be used to check if the [PlatformInAppWebViewController.removeUserScriptsByGroupName] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Linux WPE WebKit
  ///- macOS WKWebView:
  ///    - This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [groupName]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeUserScriptsByGroupName,

  ///Can be used to check if the [PlatformInAppWebViewController.requestEnterFullscreen] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestEnterFullscreen.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestEnterFullscreen,

  ///Can be used to check if the [PlatformInAppWebViewController.requestExitFullscreen] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestExitFullscreen.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestExitFullscreen,

  ///Can be used to check if the [PlatformInAppWebViewController.requestFocus] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.requestFocus](https://developer.android.com/reference/android/webkit/WebView#requestFocus(int,%20android.graphics.Rect)))
  ///- iOS WKWebView ([Official API - UIResponder.becomeFirstResponder](https://developer.apple.com/documentation/uikit/uiresponder/1621113-becomefirstresponder))
  ///- macOS WKWebView ([Official API - NSWindow.makeFirstResponder](https://developer.apple.com/documentation/appkit/nswindow/1419366-makefirstresponder))
  ///- Linux WPE WebKit ([Official API - wpe_view_backend_add_activity_state](https://wpewebkit.org/reference/stable/wpe-platform-2.0/func.view_backend_add_activity_state.html)):
  ///    - Adds focused state to WPE backend
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [direction]:
  ///    - Android WebView
  ///- [previouslyFocusedRect]:
  ///    - Android WebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestFocus,

  ///Can be used to check if the [PlatformInAppWebViewController.requestFocusNodeHref] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.requestFocusNodeHref](https://developer.android.com/reference/android/webkit/WebView#requestFocusNodeHref(android.os.Message)))
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestFocusNodeHref,

  ///Can be used to check if the [PlatformInAppWebViewController.requestImageRef] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.requestImageRef](https://developer.android.com/reference/android/webkit/WebView#requestImageRef(android.os.Message)))
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestImageRef,

  ///Can be used to check if the [PlatformInAppWebViewController.requestMediaPlaybackState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate))
  ///- Linux WPE WebKit ([Official API - JavaScript HTMLMediaElement.paused](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/paused)):
  ///    - Uses JavaScript to query media playback state
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestMediaPlaybackState,

  ///Can be used to check if the [PlatformInAppWebViewController.requestPointerLock] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestPointerLock.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestPointerLock,

  ///Can be used to check if the [PlatformInAppWebViewController.requestPointerUnlock] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestPointerUnlock.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestPointerUnlock,

  ///Can be used to check if the [PlatformInAppWebViewController.restoreState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.restoreState](https://developer.android.com/reference/android/webkit/WebView#restoreState(android.os.Bundle))):
  ///    - This method doesn't restore the display data for this WebView.
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [state]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  restoreState,

  ///Can be used to check if the [PlatformInAppWebViewController.resume] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resume.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.onResume](https://developer.android.com/reference/android/webkit/WebView#onResume()))
  ///- Windows WebView2 ([Official API - ICoreWebView2_3.Resume](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_3?view=webview2-1.0.2792.45#resume))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  resume,

  ///Can be used to check if the [PlatformInAppWebViewController.resumeTimers] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.resumeTimers](https://developer.android.com/reference/android/webkit/WebView#resumeTimers()))
  ///- iOS WKWebView:
  ///    - This method is implemented using JavaScript and it is restricted to just this WebView.
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  resumeTimers,

  ///Can be used to check if the [PlatformInAppWebViewController.saveState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.saveState](https://developer.android.com/reference/android/webkit/WebView#saveState(android.os.Bundle))):
  ///    - This method doesn't store the display data for this WebView.
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.interactionState](https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate))
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  saveState,

  ///Can be used to check if the [PlatformInAppWebViewController.saveWebArchive] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.saveWebArchive](https://developer.android.com/reference/android/webkit/WebView#saveWebArchive(java.lang.String,%20boolean,%20android.webkit.ValueCallback%3Cjava.lang.String%3E))):
  ///    - If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.MHT] file extension.
  ///- iOS WKWebView 14.0+:
  ///    - If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///- Linux WPE WebKit ([Official API - webkit_web_view_save_to_file](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.save_to_file.html)):
  ///    - If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.MHT] file extension.
  ///- macOS WKWebView 11.0+:
  ///    - If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [filePath]: all platforms
  ///- [autoname]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  saveWebArchive,

  ///Can be used to check if the [PlatformInAppWebViewController.scrollBy] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.scrollBy](https://developer.android.com/reference/android/view/View#scrollBy(int,%20int)))
  ///- iOS WKWebView ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit
  ///- Web \<iframe\> but requires same origin ([Official API - Window.scrollBy](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollBy))
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [x]: all platforms
  ///- [y]: all platforms
  ///- [animated]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  scrollBy,

  ///Can be used to check if the [PlatformInAppWebViewController.scrollTo] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.scrollTo](https://developer.android.com/reference/android/webkit/WebView#scrollTo(int,%20int)))
  ///- iOS WKWebView ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- macOS WKWebView:
  ///    - This method is implemented using JavaScript.
  ///- Linux WPE WebKit
  ///- Web \<iframe\> but requires same origin ([Official API - Window.scrollTo](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollTo))
  ///- Windows WebView2:
  ///    - This method is implemented using JavaScript.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [x]: all platforms
  ///- [y]: all platforms
  ///- [animated]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  scrollTo,

  ///Can be used to check if the [PlatformInAppWebViewController.setAllMediaPlaybackSuspended] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended))
  ///- Linux WPE WebKit ([Official API - JavaScript HTMLMediaElement.pause()/play()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement)):
  ///    - Uses JavaScript to suspend/resume all media elements
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [suspended]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setAllMediaPlaybackSuspended,

  ///Can be used to check if the [PlatformInAppWebViewController.setCameraCaptureState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate))
  ///- Linux WPE WebKit 2.34+ ([Official API - webkit_web_view_set_camera_capture_state](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.set_camera_capture_state.html)):
  ///    - Once state is set to NONE, it cannot be changed back. The page can request capture again using the mediaDevices API.
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [state]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setCameraCaptureState,

  ///Can be used to check if the [PlatformInAppWebViewController.setContextMenu] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [contextMenu]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setContextMenu,

  ///Can be used to check if the [PlatformInAppWebViewController.setInputMethodEnabled] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIResponder.inputView](https://developer.apple.com/documentation/uikit/uiresponder/1621092-inputview))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [enabled]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setInputMethodEnabled,

  ///Can be used to check if the [PlatformInAppWebViewController.setJavaScriptBridgeName] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [bridgeName]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setJavaScriptBridgeName,

  ///Can be used to check if the [PlatformInAppWebViewController.setMemoryUsageTargetLevel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMemoryUsageTargetLevel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2_19.put_MemoryUsageTargetLevel](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_19?view=webview2-1.0.2849.39#put_memoryusagetargetlevel))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [level]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setMemoryUsageTargetLevel,

  ///Can be used to check if the [PlatformInAppWebViewController.setMicrophoneCaptureState] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate))
  ///- Linux WPE WebKit 2.34+ ([Official API - webkit_web_view_set_microphone_capture_state](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.set_microphone_capture_state.html)):
  ///    - Once state is set to NONE, it cannot be changed back. The page can request capture again using the mediaDevices API.
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [state]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setMicrophoneCaptureState,

  ///Can be used to check if the [PlatformInAppWebViewController.setMuted] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMuted.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit 2.30+ ([Official API - webkit_web_view_set_is_muted](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.set_is_muted.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [muted]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setMuted,

  ///Can be used to check if the [PlatformInAppWebViewController.setOptions] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setOptions.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [options]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use setSettings instead')
  setOptions,

  ///Can be used to check if the [PlatformInAppWebViewController.setSafeBrowsingAllowlist] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.setSafeBrowsingAllowlist](https://developer.android.com/reference/androidx/webkit/WebViewCompat#setSafeBrowsingAllowlist(java.util.Set%3Cjava.lang.String%3E,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E))):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_ALLOWLIST].
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [hosts]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setSafeBrowsingAllowlist,

  ///Can be used to check if the [PlatformInAppWebViewController.setSafeBrowsingWhitelist] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingWhitelist.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [hosts]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use setSafeBrowsingAllowlist instead')
  setSafeBrowsingWhitelist,

  ///Can be used to check if the [PlatformInAppWebViewController.setScreenScale] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setScreenScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - wpe_screen_set_scale](https://wpewebkit.org/reference/stable/wpe-platform-1.0/method.Screen.set_scale.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [scale]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setScreenScale,

  ///Can be used to check if the [PlatformInAppWebViewController.setSettings] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setSettings,

  ///Can be used to check if the [PlatformInAppWebViewController.setTargetRefreshRate] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setTargetRefreshRate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [rate]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setTargetRefreshRate,

  ///Can be used to check if the [PlatformInAppWebViewController.setVisible] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setVisible.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [visible]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setVisible,

  ///Can be used to check if the [PlatformInAppWebViewController.setWebContentsDebuggingEnabled] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setWebContentsDebuggingEnabled](https://developer.android.com/reference/android/webkit/WebView#setWebContentsDebuggingEnabled(boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [debuggingEnabled]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setWebContentsDebuggingEnabled,

  ///Can be used to check if the [PlatformInAppWebViewController.showInputMethod] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - InputMethodManager.showSoftInput](https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#showSoftInput(android.view.View,%20int)))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  showInputMethod,

  ///Can be used to check if the [PlatformInAppWebViewController.showSaveAsUI] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.showSaveAsUI.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2_25.ShowSaveAsUI](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2_25?view=webview2-1.0.2849.39#showsaveasui))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  showSaveAsUI,

  ///Can be used to check if the [PlatformInAppWebViewController.startSafeBrowsing] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.startSafeBrowsing.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.startSafeBrowsing](https://developer.android.com/reference/android/webkit/WebView#startSafeBrowsing(android.content.Context,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E))):
  ///    - This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.START_SAFE_BROWSING].
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  startSafeBrowsing,

  ///Can be used to check if the [PlatformInAppWebViewController.stopLoading] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.stopLoading](https://developer.android.com/reference/android/webkit/WebView#stopLoading()))
  ///- iOS WKWebView ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- macOS WKWebView ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- Web \<iframe\> but requires same origin ([Official API - Window.stop](https://developer.mozilla.org/en-US/docs/Web/API/Window/stop))
  ///- Windows WebView2 ([Official API - ICoreWebView2.Stop](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2210.55#stop))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_stop_loading](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.stop_loading.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  stopLoading,

  ///Can be used to check if the [PlatformInAppWebViewController.takeScreenshot] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - To be able to take screenshots outside the visible viewport, you must call [PlatformInAppWebViewController.enableSlowWholeDocumentDraw] before any WebViews are created.
  ///- iOS WKWebView 11.0+ ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  ///- macOS WKWebView 10.13+ ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [screenshotConfiguration]: all platforms
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  takeScreenshot,

  ///Can be used to check if the [PlatformInAppWebViewController.terminateWebProcess] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.terminateWebProcess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit 2.34+ ([Official API - webkit_web_view_terminate_web_process](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.terminate_web_process.html))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  terminateWebProcess,

  ///Can be used to check if the [PlatformInAppWebViewController.zoomBy] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebView.zoomBy](https://developer.android.com/reference/android/webkit/WebView#zoomBy(float)))
  ///- iOS WKWebView ([Official API - UIScrollView.setZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619412-setzoomscale))
  ///- Linux WPE WebKit ([Official API - webkit_web_view_set_zoom_level](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebView.set_zoom_level.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [zoomFactor]: all platforms
  ///- [animated]:
  ///    - iOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  zoomBy,

  ///Can be used to check if the [PlatformInAppWebViewController.zoomIn] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.zoomIn](https://developer.android.com/reference/android/webkit/WebView#zoomIn()))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  zoomIn,

  ///Can be used to check if the [PlatformInAppWebViewController.zoomOut] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.zoomOut](https://developer.android.com/reference/android/webkit/WebView#zoomOut()))
  ///
  ///Use the [PlatformInAppWebViewController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  zoomOut,
}

extension _PlatformInAppWebViewControllerMethodSupported
    on PlatformInAppWebViewController {
  static bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformInAppWebViewControllerMethod
          .addDevToolsProtocolEventListener:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.addJavaScriptHandler:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.addUserScript:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.addUserScripts:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.addWebMessageListener:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.callAsyncJavaScript:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.callDevToolsProtocolMethod:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.canGoBack:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.canGoBackOrForward:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.canGoForward:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.canScrollHorizontally:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.canScrollVertically:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearAllCache:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearCache:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearClientCertPreferences:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearFocus:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearFormData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearHistory:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearMatches:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.clearSslPreferences:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.closeAllMediaPresentations:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.createPdf:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.createWebArchiveData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.createWebMessageChannel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.disableWebView:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.dispose:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.disposeKeepAlive:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.enableSlowWholeDocumentDraw:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.evaluateJavascript:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.findAllAsync:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.findNext:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getCameraCaptureState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getCertificate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getContentHeight:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getContentWidth:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getCopyBackForwardList:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getCurrentWebViewPackage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getDefaultUserAgent:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getFavicon:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getFavicons:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getFrameId:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getHitTestResult:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getHtml:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getIFrameId:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getJavaScriptBridgeName:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getMemoryUsageTargetLevel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getMetaTags:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getMetaThemeColor:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getMicrophoneCaptureState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getOptions:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getOriginalUrl:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getProgress:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getSafeBrowsingPrivacyPolicyUrl:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getScreenScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getScrollX:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getScrollY:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getSelectedText:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getSettings:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getTRexRunnerCss:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getTRexRunnerHtml:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getTargetRefreshRate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getTitle:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getUrl:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getVariationsHeader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getViewId:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.getZoomScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.goBack:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.goBackOrForward:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.goForward:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.goTo:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.handlesURLScheme:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.hasJavaScriptHandler:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.hasOnlySecureContent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.hasUserScript:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.hasWebMessageListener:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.hideInputMethod:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.injectCSSCode:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.injectCSSFileFromAsset:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.injectCSSFileFromUrl:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.injectJavascriptFileFromAsset:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.injectJavascriptFileFromUrl:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isInFullscreen:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isInterfaceSupported:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isLoading:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isMultiProcessEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isMuted:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isPlayingAudio:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isSecureContext:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.isVisible:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.loadData:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.loadFile:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.loadSimulatedRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.loadUrl:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.openDevTools:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.pageDown:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.pageUp:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.pause:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.pauseTimers:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.postUrl:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.postWebMessage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.printCurrentPage:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.reload:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.reloadFromOrigin:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.removeAllUserScripts:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod
          .removeDevToolsProtocolEventListener:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.removeJavaScriptHandler:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.removeUserScript:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.removeUserScripts:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.removeUserScriptsByGroupName:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestEnterFullscreen:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestExitFullscreen:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestFocus:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestFocusNodeHref:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestImageRef:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestMediaPlaybackState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestPointerLock:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.requestPointerUnlock:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.restoreState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.resume:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.resumeTimers:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.saveState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.saveWebArchive:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.scrollBy:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.scrollTo:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setAllMediaPlaybackSuspended:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setCameraCaptureState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setContextMenu:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setInputMethodEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setJavaScriptBridgeName:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setMemoryUsageTargetLevel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setMicrophoneCaptureState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setMuted:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setOptions:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setSafeBrowsingAllowlist:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setSafeBrowsingWhitelist:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setScreenScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setSettings:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.linux,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setTargetRefreshRate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setVisible:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.setWebContentsDebuggingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.showInputMethod:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.showSaveAsUI:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.startSafeBrowsing:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.stopLoading:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.takeScreenshot:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.terminateWebProcess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.zoomBy:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.zoomIn:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewControllerMethod.zoomOut:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
