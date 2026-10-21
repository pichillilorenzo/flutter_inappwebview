#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_BLOCKER_HANDLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_BLOCKER_HANDLER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

class InAppWebView;

/**
 * ContentBlockerHandler manages WebKit content filters for content blocking.
 *
 * Uses WebKitUserContentFilterStore to compile Safari-compatible content blocker
 * JSON rules into native WebKit filters. This is the same mechanism used by
 * iOS/macOS (WKContentRuleListStore).
 *
 * WPE WebKit uses the Safari content blocker JSON format:
 * [
 *   {
 *     "trigger": { "url-filter": ".*ads.*" },
 *     "action": { "type": "block" }
 *   }
 * ]
 *
 * Supported action types:
 * - block: Block the resource from loading
 * - css-display-none: Hide matching elements with CSS
 * - make-https: Upgrade HTTP URLs to HTTPS
 */
class ContentBlockerHandler {
 public:
  explicit ContentBlockerHandler(WebKitUserContentManager* content_manager);
  ~ContentBlockerHandler();

  /**
   * Compile and apply content blockers from FlValue list.
   *
   * The FlValue should be a list of content blocker maps, each with:
   * - "trigger": map with "url-filter" and optional other trigger properties
   * - "action": map with "type" and optional "selector" (for css-display-none)
   *
   * @param contentBlockers FlValue list of content blocker maps
   * @param callback Called when compilation is complete (success or failure)
   */
  void setContentBlockers(FlValue* contentBlockers,
                          std::function<void(bool success)> callback);

  /**
   * Remove all content filters from the content manager.
   */
  void removeAllFilters();

  /**
   * Get the current filter identifier.
   */
  std::string getFilterIdentifier() const { return filter_identifier_; }

  /**
   * Whether rules were requested but none are in force.
   */
  bool rulesMissing() const {
    return requested_identifier_ != std::string() && applied_identifier_.empty();
  }

  /**
   * Whether the latest request is still being loaded or compiled.
   */
  bool isPending() const { return pending_; }

  /**
   * Call [waiter] with the outcome of the latest request.
   */
  void whenSettled(std::function<void(bool applied)> waiter) {
    waiters_.push_back(std::move(waiter));
  }

 private:
  /**
   * Convert FlValue content blockers to Safari-format JSON string.
   *
   * @param contentBlockers FlValue list of content blocker maps
   * @return JSON string in Safari content blocker format, or empty string on error
   */
  std::string convertToJsonString(FlValue* contentBlockers);

  /**
   * Load the filter from the store, compiling it only when it is not there (async).
   */
  void loadOrCompile(const std::string& identifier, const std::string& jsonSource);

  static void onFilterLoaded(GObject* source, GAsyncResult* result, gpointer user_data);
  static void onFilterCompiled(GObject* source, GAsyncResult* result, gpointer user_data);

  /**
   * Enforce a ready filter, unless a newer request was made since: enforcing it would undo
   * that request.
   */
  void filterReady(WebKitUserContentFilter* filter, const std::string& identifier);

  /**
   * Report the outcome of the latest request to everyone waiting for it.
   */
  void finishRequest(bool applied);

  WebKitUserContentManager* content_manager_;  // Not owned (from webview)
  WebKitUserContentFilterStore* filter_store_;  // Owned
  std::string filter_identifier_;
  // Identifier of the filter currently enforced; empty when none is.
  std::string applied_identifier_;
  // Latest request: "" for no rules, nullopt when it could not be applied.
  std::optional<std::string> requested_identifier_ = std::string();
  bool pending_ = false;
  // Callers waiting for the latest request to take effect.
  std::vector<std::function<void(bool)>> waiters_;
  // Expires with the handler; a load or compile can complete after the WebView is closed.
  std::shared_ptr<bool> alive_ = std::make_shared<bool>(true);
  std::string store_path_;

  /**
   * Context for async filter compilation callback.
   */
  struct CompileContext {
    ContentBlockerHandler* handler;
    std::weak_ptr<bool> alive;
    std::string identifier;
    std::string jsonSource;
  };
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_BLOCKER_HANDLER_H_
