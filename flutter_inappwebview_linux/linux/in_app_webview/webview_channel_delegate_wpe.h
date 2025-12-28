#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_WPE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_WPE_H_

// WPE WebKit WebView Channel Delegate
// 
// This handles the method channel communication between Dart and the WPE 
// WebKit-based InAppWebView implementation. The API is identical to the 
// WebKitGTK version since the method channel protocol is the same.
//
// For now, we use the same implementation as WebKitGTK.

#ifdef USE_WPE_WEBKIT

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class InAppWebViewWpe;

class WebViewChannelDelegateWpe : public ChannelDelegate {
 public:
  WebViewChannelDelegateWpe(InAppWebViewWpe* webView,
                            FlBinaryMessenger* messenger,
                            const std::string& channelName);
  ~WebViewChannelDelegateWpe() override;

  // Navigation events
  void onLoadStart(const std::string& url);
  void onLoadStop(const std::string& url);
  void onLoadError(const std::string& url, int errorCode, 
                   const std::string& description);
  void onProgressChanged(int progress);
  void onTitleChanged(const std::string& title);

  // JavaScript handler callback
  void onCallJsHandler(const std::string& handlerName, const std::string& args);

  // URL loading decision
  void shouldOverrideUrlLoading(int64_t decisionId, const std::string& url);

  // Window events
  void onCloseWindow();
  void onEnterFullscreen();
  void onExitFullscreen();

 protected:
  void HandleMethodCall(FlMethodCall* method_call) override;

 private:
  InAppWebViewWpe* webview_ = nullptr;

  // Method call handlers
  void HandleLoadUrl(FlMethodCall* method_call);
  void HandleLoadData(FlMethodCall* method_call);
  void HandleLoadFile(FlMethodCall* method_call);
  void HandleReload(FlMethodCall* method_call);
  void HandleGoBack(FlMethodCall* method_call);
  void HandleGoForward(FlMethodCall* method_call);
  void HandleCanGoBack(FlMethodCall* method_call);
  void HandleCanGoForward(FlMethodCall* method_call);
  void HandleStopLoading(FlMethodCall* method_call);
  void HandleIsLoading(FlMethodCall* method_call);
  void HandleGetUrl(FlMethodCall* method_call);
  void HandleGetTitle(FlMethodCall* method_call);
  void HandleGetProgress(FlMethodCall* method_call);
  void HandleEvaluateJavascript(FlMethodCall* method_call);
  void HandleInjectJavascriptFileFromUrl(FlMethodCall* method_call);
  void HandleInjectCSSCode(FlMethodCall* method_call);
  void HandleInjectCSSFileFromUrl(FlMethodCall* method_call);
  void HandleAddUserScript(FlMethodCall* method_call);
  void HandleRemoveUserScript(FlMethodCall* method_call);
  void HandleRemoveUserScriptsByGroupName(FlMethodCall* method_call);
  void HandleRemoveAllUserScripts(FlMethodCall* method_call);
  void HandleGetHtml(FlMethodCall* method_call);
  void HandleGetZoomScale(FlMethodCall* method_call);
  void HandleSetZoomScale(FlMethodCall* method_call);
  void HandleScrollTo(FlMethodCall* method_call);
  void HandleScrollBy(FlMethodCall* method_call);
  void HandleGetScrollX(FlMethodCall* method_call);
  void HandleGetScrollY(FlMethodCall* method_call);
  void HandleGetSettings(FlMethodCall* method_call);
  void HandleSetSettings(FlMethodCall* method_call);
  void HandleShouldOverrideUrlLoadingDecision(FlMethodCall* method_call);
};

}  // namespace flutter_inappwebview_plugin

#endif  // USE_WPE_WEBKIT

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_WPE_H_
