#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_BLOCKER_HANDLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_BLOCKER_HANDLER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <functional>
#include <memory>
#include <string>

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

 private:
  /**
   * Convert FlValue content blockers to Safari-format JSON string.
   *
   * @param contentBlockers FlValue list of content blocker maps
   * @return JSON string in Safari content blocker format, or empty string on error
   */
  std::string convertToJsonString(FlValue* contentBlockers);

  /**
   * Compile JSON to WebKit filter (async).
   *
   * @param jsonSource JSON string in Safari format
   * @param callback Called when compilation is complete
   */
  void compileContentBlockers(const std::string& jsonSource,
                              std::function<void(bool success)> callback);

  /**
   * Callback when filter store save completes.
   */
  static void onFilterCompiled(GObject* source, GAsyncResult* result, gpointer user_data);

  WebKitUserContentManager* content_manager_;  // Not owned (from webview)
  WebKitUserContentFilterStore* filter_store_;  // Owned
  std::string filter_identifier_;
  std::string store_path_;

  /**
   * Context for async filter compilation callback.
   */
  struct CompileContext {
    ContentBlockerHandler* handler;
    std::function<void(bool)> callback;
  };
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_BLOCKER_HANDLER_H_
