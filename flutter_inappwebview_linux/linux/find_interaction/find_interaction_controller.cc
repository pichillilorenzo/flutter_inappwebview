#include "find_interaction_controller.h"

#include "find_interaction_channel_delegate.h"
#include "../in_app_webview/in_app_webview.h"
#include "../utils/log.h"

namespace flutter_inappwebview_plugin {

FindInteractionController::FindInteractionController(InAppWebView* webView)
    : webView_(webView) {
  // Connect to find controller signals
  if (webView_ && webView_->webview()) {
    WebKitFindController* find_controller =
        webkit_web_view_get_find_controller(webView_->webview());
    if (find_controller) {
      counted_matches_handler_id_ = g_signal_connect(
          find_controller, "counted-matches",
          G_CALLBACK(FindInteractionController::OnCountedMatches), this);
      found_text_handler_id_ =
          g_signal_connect(find_controller, "found-text",
                           G_CALLBACK(FindInteractionController::OnFoundText), this);
      failed_to_find_text_handler_id_ = g_signal_connect(
          find_controller, "failed-to-find-text",
          G_CALLBACK(FindInteractionController::OnFailedToFindText), this);
    }
  }
}

void FindInteractionController::attachChannel(FlBinaryMessenger* messenger,
                                               const std::string& id) {
  std::string channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + id;
  channelDelegate_ = std::make_unique<FindInteractionChannelDelegate>(
      this, messenger, channelName);
}

FindInteractionController::~FindInteractionController() {
  dispose();
}

void FindInteractionController::findAll(const std::string& find) {
  if (!webView_ || !webView_->webview()) return;
  
  searchText_ = find;
  WebKitFindController* find_controller =
      webkit_web_view_get_find_controller(webView_->webview());
  webkit_find_controller_search(find_controller, find.c_str(),
                                WEBKIT_FIND_OPTIONS_CASE_INSENSITIVE, G_MAXUINT);
}

void FindInteractionController::findNext(bool forward) {
  if (!webView_ || !webView_->webview()) return;
  
  WebKitFindController* find_controller =
      webkit_web_view_get_find_controller(webView_->webview());
  if (forward) {
    webkit_find_controller_search_next(find_controller);
  } else {
    webkit_find_controller_search_previous(find_controller);
  }
}

void FindInteractionController::clearMatches() {
  if (!webView_ || !webView_->webview()) return;
  
  WebKitFindController* find_controller =
      webkit_web_view_get_find_controller(webView_->webview());
  webkit_find_controller_search_finish(find_controller);
  activeFindSession_ = std::nullopt;
}

void FindInteractionController::setSearchText(const std::string& searchText) {
  searchText_ = searchText;
  // Note: WebKit doesn't have a separate "set search text" API,
  // the search text is set when calling search()
}

std::optional<std::string> FindInteractionController::getSearchText() const {
  if (!webView_ || !webView_->webview()) return std::nullopt;
  
  WebKitFindController* find_controller =
      webkit_web_view_get_find_controller(webView_->webview());
  const gchar* text = webkit_find_controller_get_search_text(find_controller);
  if (text) {
    return std::string(text);
  }
  return searchText_;
}

std::optional<FindSession> FindInteractionController::getActiveFindSession() const {
  return activeFindSession_;
}

void FindInteractionController::OnCountedMatches(
    WebKitFindController* find_controller, guint match_count,
    gpointer user_data) {
  if (!user_data) return;
  auto* controller = static_cast<FindInteractionController*>(user_data);
  if (controller->channelDelegate_) {
    controller->activeFindSession_ = FindSession(static_cast<int>(match_count), -1);
    controller->channelDelegate_->onFindResultReceived(-1, static_cast<int32_t>(match_count), true);
  }
}

void FindInteractionController::OnFoundText(
    WebKitFindController* find_controller, guint match_count,
    gpointer user_data) {
  if (!user_data) return;
  auto* controller = static_cast<FindInteractionController*>(user_data);
  if (controller->channelDelegate_) {
    controller->channelDelegate_->onFindResultReceived(-1, static_cast<int32_t>(match_count), false);
  }
}

void FindInteractionController::OnFailedToFindText(
    WebKitFindController* find_controller, gpointer user_data) {
  if (!user_data) return;
  auto* controller = static_cast<FindInteractionController*>(user_data);
  if (controller->channelDelegate_) {
    controller->activeFindSession_ = FindSession(0, 0);
    controller->channelDelegate_->onFindResultReceived(0, 0, true);
  }
}

void FindInteractionController::dispose() {
  if (webView_ && webView_->webview()) {
    WebKitFindController* find_controller =
        webkit_web_view_get_find_controller(webView_->webview());
    if (find_controller) {
      if (counted_matches_handler_id_ > 0) {
        g_signal_handler_disconnect(find_controller, counted_matches_handler_id_);
        counted_matches_handler_id_ = 0;
      }
      if (found_text_handler_id_ > 0) {
        g_signal_handler_disconnect(find_controller, found_text_handler_id_);
        found_text_handler_id_ = 0;
      }
      if (failed_to_find_text_handler_id_ > 0) {
        g_signal_handler_disconnect(find_controller, failed_to_find_text_handler_id_);
        failed_to_find_text_handler_id_ = 0;
      }
    }
  }

  if (channelDelegate_) {
    channelDelegate_.reset();
  }
  
  webView_ = nullptr;
  activeFindSession_ = std::nullopt;
  searchText_ = std::nullopt;
}

}  // namespace flutter_inappwebview_plugin
