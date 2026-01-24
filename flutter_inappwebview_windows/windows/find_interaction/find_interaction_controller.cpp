#include "find_interaction_controller.h"

#include "find_interaction_channel_delegate.h"

#include <wil/wrl.h>

#include <utility>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/strconv.h"
#include "../utils/string.h"
#include "../utils/util.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  FindInteractionController::FindInteractionController(InAppWebView* webView, flutter::BinaryMessenger* messenger)
    : webView(webView)
  {
    channelDelegate = std::make_unique<FindInteractionChannelDelegate>(
      this, messenger, METHOD_CHANNEL_NAME_PREFIX + variant_to_string(webView->id));
    initializeFind();
  }

  void FindInteractionController::initializeFind()
  {
    if (!webView || !webView->webView) {
      return;
    }

    if (!find_) {
      if (auto webView28 = webView->webView.try_query<ICoreWebView2_28>()) {
        failedLog(webView28->get_Find(find_.put()));
      }
    }

    if (find_) {
      ensureFindOptions();
      registerFindEventHandlers();
    }
  }

  void FindInteractionController::ensureFindOptions()
  {
    if (findOptions_ || !webView || !webView->webViewEnv) {
      return;
    }

    if (auto env15 = webView->webViewEnv.try_query<ICoreWebView2Environment15>()) {
      failedLog(env15->CreateFindOptions(findOptions_.put()));
    }
  }

  void FindInteractionController::startFindSession(const std::string& findText)
  {
    initializeFind();
    if (!find_) {
      return;
    }

    ensureFindOptions();
    if (!findOptions_) {
      return;
    }

    searchText_ = findText;
    failedLog(findOptions_->put_FindTerm(utf8_to_wide(findText).c_str()));
    failedLog(findOptions_->put_ShouldHighlightAllMatches(TRUE));
    failedLog(findOptions_->put_SuppressDefaultFindDialog(suppressDefaultFindDialog_ ? TRUE : FALSE));

    hasFindSession_ = true;
    isDoneCounting_ = false;

    failedLog(find_->Start(findOptions_.get(), Callback<ICoreWebView2FindStartCompletedHandler>(
      [this](HRESULT errorCode) -> HRESULT
      {
        failedLog(errorCode);
        isDoneCounting_ = true;
        updateFindState();
        notifyFindResult();
        return S_OK;
      })
      .Get()));
  }

  void FindInteractionController::updateFindState()
  {
    if (!find_) {
      return;
    }

    int32_t activeMatchIndex = -1;
    int32_t matchCount = 0;
    failedLog(find_->get_ActiveMatchIndex(&activeMatchIndex));
    failedLog(find_->get_MatchCount(&matchCount));

    activeMatchIndex_ = activeMatchIndex;
    matchCount_ = matchCount;
  }

  void FindInteractionController::notifyFindResult() const
  {
    if (!channelDelegate) {
      return;
    }

    channelDelegate->onFindResultReceived(
      activeMatchIndex_, matchCount_, isDoneCounting_);
  }

  std::optional<flutter::EncodableMap> FindInteractionController::getActiveFindSessionMap() const
  {
    if (!hasFindSession_) {
      return std::nullopt;
    }

    return flutter::EncodableMap{
      {"highlightedResultIndex", make_fl_value(activeMatchIndex_)},
      {"resultCount", make_fl_value(matchCount_)},
      {"searchResultDisplayStyle", make_fl_value(2)},
    };
  }

  void FindInteractionController::registerFindEventHandlers()
  {
    if (!find_) {
      return;
    }

    if (!activeMatchIndexChangedRegistered_) {
      EventRegistrationToken token = {};
      auto hr = find_->add_ActiveMatchIndexChanged(Callback<ICoreWebView2FindActiveMatchIndexChangedEventHandler>(
        [this](ICoreWebView2Find* sender, IUnknown* args) -> HRESULT
        {
          updateFindState();
          notifyFindResult();
          return S_OK;
        }).Get(), &token);
      if (succeededOrLog(hr)) {
        activeMatchIndexChangedToken_ = token;
        activeMatchIndexChangedRegistered_ = true;
      }
    }

    if (!matchCountChangedRegistered_) {
      EventRegistrationToken token = {};
      auto hr = find_->add_MatchCountChanged(Callback<ICoreWebView2FindMatchCountChangedEventHandler>(
        [this](ICoreWebView2Find* sender, IUnknown* args) -> HRESULT
        {
          updateFindState();
          notifyFindResult();
          return S_OK;
        }).Get(), &token);
      if (succeededOrLog(hr)) {
        matchCountChangedToken_ = token;
        matchCountChangedRegistered_ = true;
      }
    }
  }

  void FindInteractionController::unregisterFindEventHandlers()
  {
    if (!find_) {
      return;
    }

    if (activeMatchIndexChangedRegistered_) {
      failedLog(find_->remove_ActiveMatchIndexChanged(activeMatchIndexChangedToken_));
      activeMatchIndexChangedRegistered_ = false;
    }

    if (matchCountChangedRegistered_) {
      failedLog(find_->remove_MatchCountChanged(matchCountChangedToken_));
      matchCountChangedRegistered_ = false;
    }
  }

  void FindInteractionController::findAll(const std::optional<std::string>& findText)
  {
    if (findText.has_value()) {
      startFindSession(findText.value());
    }
    else if (searchText_.has_value()) {
      startFindSession(searchText_.value());
    }
    else {
      startFindSession("");
    }
  }

  void FindInteractionController::findNext(const bool forward)
  {
    if (find_ && hasFindSession_) {
      if (forward) {
        failedLog(find_->FindNext());
      }
      else {
        failedLog(find_->FindPrevious());
      }
    }
  }

  void FindInteractionController::clearMatches()
  {
    if (find_ && hasFindSession_) {
      failedLog(find_->Stop());
    }
    hasFindSession_ = false;
    activeMatchIndex_ = -1;
    matchCount_ = 0;
    isDoneCounting_ = true;
    notifyFindResult();
  }

  void FindInteractionController::setSearchText(const std::optional<std::string>& searchText)
  {
    searchText_ = searchText;
    if (findOptions_ && searchText.has_value()) {
      failedLog(findOptions_->put_FindTerm(utf8_to_wide(searchText.value()).c_str()));
    }
  }

  std::optional<std::string> FindInteractionController::getSearchText() const
  {
    return searchText_;
  }

  void FindInteractionController::dispose()
  {
    unregisterFindEventHandlers();
    if (channelDelegate) {
      channelDelegate->dispose();
      channelDelegate.reset();
    }
    findOptions_ = nullptr;
    find_ = nullptr;
  }

  FindInteractionController::~FindInteractionController()
  {
    debugLog("dealloc FindInteractionController");
    dispose();
    webView = nullptr;
  }
}
