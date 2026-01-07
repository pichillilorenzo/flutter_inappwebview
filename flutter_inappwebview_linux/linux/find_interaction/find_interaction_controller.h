#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CONTROLLER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <memory>
#include <optional>
#include <string>

#include "../types/find_session.h"

namespace flutter_inappwebview_plugin {

class InAppWebView;
class FindInteractionChannelDelegate;

class FindInteractionController {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappwebview_find_interaction_";

  FindInteractionController(InAppWebView* webView);
  ~FindInteractionController();

  // Attach the method channel with the given ID (called after texture_id is known)
  void attachChannel(FlBinaryMessenger* messenger, const std::string& id);

  void findAll(const std::string& find);
  void findNext(bool forward);
  void clearMatches();
  void setSearchText(const std::string& searchText);
  std::optional<std::string> getSearchText() const;
  std::optional<FindSession> getActiveFindSession() const;

  void dispose();

  // Signal handlers
  static void OnCountedMatches(WebKitFindController* find_controller,
                               guint match_count, gpointer user_data);
  static void OnFoundText(WebKitFindController* find_controller,
                          guint match_count, gpointer user_data);
  static void OnFailedToFindText(WebKitFindController* find_controller,
                                 gpointer user_data);

  InAppWebView* webView_;
  std::unique_ptr<FindInteractionChannelDelegate> channelDelegate_;
  std::optional<std::string> searchText_;
  std::optional<FindSession> activeFindSession_;

 private:
  gulong counted_matches_handler_id_ = 0;
  gulong found_text_handler_id_ = 0;
  gulong failed_to_find_text_handler_id_ = 0;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CONTROLLER_H_
