#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <string>

#include "../in_app_webview/in_app_webview.h"
#include "headless_webview_channel_delegate.h"

namespace flutter_inappwebview_plugin {

class HeadlessInAppWebViewManager;

struct HeadlessInAppWebViewCreationParams {
  std::string id;
  double initialWidth = -1;
  double initialHeight = -1;
};

/// HeadlessInAppWebView - A WebView without visual output
///
/// This class wraps InAppWebView for headless operation.
/// Since WPE WebKit is inherently headless (it renders to offscreen buffers),
/// this is essentially InAppWebView without texture registration.
class HeadlessInAppWebView {
 public:

  HeadlessInAppWebView(HeadlessInAppWebViewManager* manager,
                       const HeadlessInAppWebViewCreationParams& params,
                       const InAppWebViewCreationParams& webviewParams);
  ~HeadlessInAppWebView();

  const std::string& id() const { return id_; }
  InAppWebView* webview() const { return webview_.get(); }
  HeadlessInAppWebViewManager* manager() const { return manager_; }

  // Size management
  void setSize(double width, double height);
  void getSize(double* width, double* height) const;

  // Get the channel delegate
  HeadlessWebViewChannelDelegate* channelDelegate() const { return channelDelegate_.get(); }

  // Dispose this headless webview (called by channel delegate)
  void dispose();

 private:
  HeadlessInAppWebViewManager* manager_ = nullptr;
  std::string id_;
  double width_ = -1;
  double height_ = -1;

  // The underlying InAppWebView
  std::shared_ptr<InAppWebView> webview_;

  // Channel delegate for this headless webview
  std::unique_ptr<HeadlessWebViewChannelDelegate> channelDelegate_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_H_
