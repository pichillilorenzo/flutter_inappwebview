#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Base class for channel delegates that handle Flutter method channels.
 * This mirrors the Windows ChannelDelegate pattern.
 */
class ChannelDelegate {
 public:
  ChannelDelegate(FlBinaryMessenger* messenger, const std::string& name);
  virtual ~ChannelDelegate();

  /**
   * Handle a method call from Flutter.
   * Subclasses should override this to handle their specific methods.
   */
  virtual void HandleMethodCall(FlMethodCall* method_call);

  /**
   * Invoke a method on the Dart side without expecting a result.
   */
  void invokeMethod(const std::string& method, FlValue* arguments) const;

  /**
   * Invoke a method on the Dart side with a result callback.
   */
  void invokeMethodWithResult(const std::string& method, FlValue* arguments,
                              GAsyncReadyCallback callback, gpointer user_data) const;

  /**
   * Unregister the method call handler.
   */
  void unregisterMethodCallHandler();

  FlMethodChannel* channel() const { return channel_; }
  FlBinaryMessenger* messenger() const { return messenger_; }

 protected:
  FlBinaryMessenger* messenger_ = nullptr;
  FlMethodChannel* channel_ = nullptr;

 private:
  static void HandleMethodCallStatic(FlMethodChannel* channel, FlMethodCall* method_call,
                                     gpointer user_data);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CHANNEL_DELEGATE_H_
