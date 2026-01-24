#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CONTROLLER_H_

#include <flutter/binary_messenger.h>
#include <flutter/standard_message_codec.h>
#include <WebView2.h>
#include <wil/com.h>

#include <memory>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin
{
  class InAppWebView;

  class FindInteractionChannelDelegate;

  class FindInteractionController
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_find_interaction_";

    InAppWebView* webView;
    std::unique_ptr<FindInteractionChannelDelegate> channelDelegate;

    FindInteractionController(InAppWebView* webView, flutter::BinaryMessenger* messenger);
    ~FindInteractionController();

    void dispose();

    void findAll(const std::optional<std::string>& findText);
    void findNext(const bool forward);
    void clearMatches();
    void setSearchText(const std::optional<std::string>& searchText);
    std::optional<std::string> getSearchText() const;
    std::optional<flutter::EncodableMap> getActiveFindSessionMap() const;

  private:
    wil::com_ptr<ICoreWebView2Find> find_;
    wil::com_ptr<ICoreWebView2FindOptions> findOptions_;
    std::optional<std::string> searchText_;
    bool hasFindSession_ = false;
    int32_t activeMatchIndex_ = -1;
    int32_t matchCount_ = 0;
    bool isDoneCounting_ = true;
    EventRegistrationToken activeMatchIndexChangedToken_{};
    EventRegistrationToken matchCountChangedToken_{};
    bool activeMatchIndexChangedRegistered_ = false;
    bool matchCountChangedRegistered_ = false;
    bool suppressDefaultFindDialog_ = true;

    void initializeFind();
    void ensureFindOptions();
    void startFindSession(const std::string& findText);
    void updateFindState();
    void notifyFindResult() const;
    void registerFindEventHandlers();
    void unregisterFindEventHandlers();
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CONTROLLER_H_
