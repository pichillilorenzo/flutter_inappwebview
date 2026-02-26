#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <functional>
#include <map>
#include <memory>
#include <string>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

/**
 * Instance channel delegate for individual WebViewEnvironment instances.
 * Handles instance-specific method calls like dispose, isSpellCheckingEnabled, etc.
 */
class WebViewEnvironmentInstanceChannelDelegate : public ChannelDelegate {
 public:
  WebViewEnvironmentInstanceChannelDelegate(FlBinaryMessenger* messenger,
                                            const std::string& id,
                                            std::function<void(const std::string&)> disposeCallback);
  ~WebViewEnvironmentInstanceChannelDelegate() override;

  void HandleMethodCall(FlMethodCall* method_call) override;

  WebKitWebContext* context() const { return context_; }
  void setContext(WebKitWebContext* context) { context_ = context; }

  // Getter methods for WebContext properties
  bool isSpellCheckingEnabled() const;
  std::vector<std::string> getSpellCheckingLanguages() const;
  int getCacheModel() const;
  bool isAutomationAllowed() const;

 private:
  std::string id_;
  WebKitWebContext* context_ = nullptr;
  std::function<void(const std::string&)> disposeCallback_;
};

/**
 * Manages WebView Environment operations for WPE WebKit.
 * Provides access to the WPE WebKit version information and
 * WebKitWebContext instance management.
 */
class WebViewEnvironment : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_webview_environment";

  WebViewEnvironment(PluginInstance* plugin);
  ~WebViewEnvironment() override;

  /// Get the plugin instance
  PluginInstance* plugin() const { return plugin_; }

  void HandleMethodCall(FlMethodCall* method_call) override;

  /**
   * Get the WPE WebKit version string (e.g., "2.42.0").
   */
  static std::string getAvailableVersion();

  /**
   * Get the WebKitWebContext for the given environment ID.
   * Returns nullptr if not found.
   */
  WebKitWebContext* getWebContext(const std::string& id) const;

 private:
  PluginInstance* plugin_ = nullptr;
  FlBinaryMessenger* messenger_;

  // Map of environment ID -> instance channel delegate
  std::map<std::string, std::unique_ptr<WebViewEnvironmentInstanceChannelDelegate>> instances_;

  /**
   * Create a new WebViewEnvironment instance with the given ID and settings.
   */
  void create(const std::string& id, FlValue* settings);

  /**
   * Dispose an environment instance by ID.
   */
  void disposeEnvironment(const std::string& id);

  /**
   * Get a WebViewEnvironment instance by ID.
   * Returns nullptr if not found.
   */
  WebViewEnvironmentInstanceChannelDelegate* getInstance(const std::string& id) const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_
