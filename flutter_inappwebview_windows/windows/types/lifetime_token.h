#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LIFETIME_TOKEN_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LIFETIME_TOKEN_H_

#include <memory>

namespace flutter_inappwebview_plugin
{
  // Owned by an object whose WebView2 creation callbacks can fire after the
  // Flutter engine tore it down; the callback captures weak() and bails if expired.
  class LifetimeToken
  {
  public:
    std::weak_ptr<void> weak() const
    {
      return token_;
    }

    bool expired() const
    {
      return token_ == nullptr;
    }

    void expire()
    {
      token_.reset();
    }

  private:
    std::shared_ptr<int> token_ = std::make_shared<int>(0);
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_LIFETIME_TOKEN_H_
