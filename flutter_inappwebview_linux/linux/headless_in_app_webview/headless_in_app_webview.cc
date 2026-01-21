#include "headless_in_app_webview.h"

#include <cstring>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "headless_in_app_webview_manager.h"
#include "headless_webview_channel_delegate.h"

namespace flutter_inappwebview_plugin {

HeadlessInAppWebView::HeadlessInAppWebView(HeadlessInAppWebViewManager* manager,
                                           const HeadlessInAppWebViewCreationParams& params,
                                           const InAppWebViewCreationParams& webviewParams)
    : manager_(manager), id_(params.id), width_(params.initialWidth), height_(params.initialHeight) {
  debugLog("HeadlessInAppWebView::HeadlessInAppWebView id=" + id_);

  // Create the underlying InAppWebView
  // Use 0 as the numeric ID since we use string ID for headless webviews
  webview_ = std::make_shared<InAppWebView>(manager_->registrar(), manager_->messenger(), 0,
                                            webviewParams);

  // CRITICAL: Attach the method channel to the InAppWebView using the string ID.
  // This creates the channel at "com.pichillilorenzo/flutter_inappwebview_<id>"
  // which the Dart LinuxInAppWebViewController expects.
  webview_->AttachChannel(manager_->messenger(), id_, false);

  // Set the initial size
  webview_->setSize(static_cast<int>(width_), static_cast<int>(height_));

  // Create the channel delegate for this headless webview
  // This handles headless-specific methods like setSize, getSize, dispose
  channelDelegate_ = std::make_unique<HeadlessWebViewChannelDelegate>(
      this, manager_->messenger(), id_);
}

HeadlessInAppWebView::~HeadlessInAppWebView() {
  debugLog("HeadlessInAppWebView::~HeadlessInAppWebView id=" + id_);

  channelDelegate_.reset();
  webview_.reset();
}

void HeadlessInAppWebView::setSize(double width, double height) {
  width_ = width;
  height_ = height;
  if (webview_) {
    webview_->setSize(static_cast<int>(width_), static_cast<int>(height_));
  }
}

void HeadlessInAppWebView::getSize(double* width, double* height) const {
  if (width) *width = width_;
  if (height) *height = height_;
}

void HeadlessInAppWebView::dispose() {
  // Remove this headless webview from the manager
  // This will trigger the destructor
  if (manager_) {
    manager_->RemoveHeadlessWebView(id_);
  }
}

}  // namespace flutter_inappwebview_plugin
