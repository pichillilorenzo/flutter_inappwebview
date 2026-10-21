#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_VISIBILITY_STATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_VISIBILITY_STATE_H_

#include <optional>

namespace flutter_inappwebview_plugin
{
  // Separates the visibility requested by the WebView API from temporary
  // host-window visibility. A resumed WebView must remain hidden while its
  // host is minimized, and a paused WebView must stay hidden after restore.
  class WebViewVisibilityState
  {
  public:
    explicit WebViewVisibilityState(const bool hostWindowMinimized = false)
      : hostWindowMinimized_(hostWindowMinimized)
    {}

    bool shouldBeVisible() const
    {
      return !paused_ && !hostWindowMinimized_;
    }

    bool isPaused() const { return paused_; }
    bool isHostWindowMinimized() const { return hostWindowMinimized_; }

    void setPaused(const bool paused) { paused_ = paused; }
    void setHostWindowMinimized(const bool minimized)
    {
      hostWindowMinimized_ = minimized;
    }

    // Delivery of put_IsVisible can be deferred while the browser process is
    // unresponsive; these track what the controller last actually received.
    bool needsApply() const
    {
      return !applied_.has_value() || applied_.value() != shouldBeVisible();
    }
    void markApplied() { applied_ = shouldBeVisible(); }

  private:
    bool paused_ = false;
    bool hostWindowMinimized_ = false;
    std::optional<bool> applied_;
  };
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_VISIBILITY_STATE_H_
