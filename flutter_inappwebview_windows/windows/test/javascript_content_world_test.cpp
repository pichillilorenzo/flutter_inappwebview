// Platform doubles surround the actual production methods, extracted by the runner.
#include <cstdint>
#include <functional>
#include <iostream>
#include <limits>
#include <map>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include <nlohmann/json.hpp>
#include "in_app_webview/pending_script_requests.h"
#include "plugin_scripts_js/plugin_scripts_util.h"

using HRESULT = int;
using LPCWSTR = const wchar_t*;
constexpr HRESULT S_OK = 0;
constexpr HRESULT E_FAIL = -1;
struct ICoreWebView2CallDevToolsProtocolMethodCompletedHandler {};
using Handler = std::function<HRESULT(HRESULT, LPCWSTR)>;
struct CallbackHolder {
  std::shared_ptr<Handler> handler;
  std::shared_ptr<Handler> Get() const { return handler; }
};
template <typename T, typename F> CallbackHolder Callback(F callback) {
  return {std::make_shared<Handler>(std::move(callback))};
}

// The scenarios use ASCII CDP payloads; conversion behavior is not under test.
std::string wide_to_utf8(const std::wstring& text) { return {text.begin(), text.end()}; }
std::wstring utf8_to_wide(const std::string& text) { return {text.begin(), text.end()}; }
bool succeededOrLog(HRESULT result) { return result >= 0; }
bool failedAndLog(HRESULT result) { return result < 0; }
void debugLog(const std::string&) {}
template <class M, class K> bool map_contains(const M& map, const K& key) {
  return map.find(key) != map.end();
}
void replace_all(std::string& text, const std::string& from, const std::string& to) {
  size_t at = 0;
  while ((at = text.find(from, at)) != std::string::npos) {
    text.replace(at, from.size(), to);
    at += to.size();
  }
}
std::string replace_all_copy(std::string text, const std::string& from, const std::string& to) {
  replace_all(text, from, to);
  return text;
}
std::string join(const std::vector<std::string>& values, const std::string& separator) {
  std::string result;
  for (const auto& value : values) {
    if (!result.empty()) result += separator;
    result += value;
  }
  return result;
}

void require(bool condition, const std::string& message) {
  if (!condition) throw std::runtime_error(message);
}

struct FakeWebView {
  struct Call {
    std::string method;
    nlohmann::json parameters;
    std::shared_ptr<Handler> handler;
  };
  std::vector<Call> calls;
  HRESULT nextCallResult = S_OK;

  HRESULT CallDevToolsProtocolMethod(LPCWSTR method, LPCWSTR parameters,
                                    std::shared_ptr<Handler> handler) {
    const auto result = std::exchange(nextCallResult, S_OK);
    calls.push_back({wide_to_utf8(method), nlohmann::json::parse(wide_to_utf8(parameters)),
                     result >= 0 ? std::move(handler) : nullptr});
    return result;
  }

  void reply(size_t index, HRESULT error, LPCWSTR json) {
    auto handler = std::move(calls.at(index).handler);
    require(handler != nullptr, "the WebView2 operation must still be pending");
    (*handler)(error, json);
  }

  void clearHandlers() {
    for (auto& call : calls) call.handler.reset();
  }
};

struct FakeChannel {
  void onConsoleMessage(const std::string&, int) {}
};

namespace flutter_inappwebview_plugin {
struct ContentWorld {
  std::string name;
  explicit ContentWorld(std::string name) : name(std::move(name)) {}
  static std::shared_ptr<ContentWorld> page() { return std::make_shared<ContentWorld>("page"); }
  static bool isPage(const std::shared_ptr<ContentWorld>& world) {
    return world && world->name == "page";
  }
};

struct InAppWebView;
struct UserContentController {
  InAppWebView* webView_;
  std::map<std::string, int> contentWorlds_;
  int pluginScriptsAdded = 0;
  explicit UserContentController(InAppWebView* webView) : webView_(webView) {}
  // PRODUCTION_CONTENT_WORLD_DECLARATION
  void addPluginScriptsIfRequired(const std::shared_ptr<ContentWorld>) { ++pluginScriptsAdded; }
};

struct InAppWebView {
  std::shared_ptr<FakeWebView> webView = std::make_shared<FakeWebView>();
  std::unique_ptr<UserContentController> userContentController = std::make_unique<UserContentController>(this);
  std::shared_ptr<PendingScriptRequests> pendingScripts_ = std::make_shared<PendingScriptRequests>();
  std::shared_ptr<int> aliveToken_ = std::make_shared<int>(0);
  FakeChannel* channelDelegate = nullptr;
  std::weak_ptr<void> aliveToken() const { return aliveToken_; }
  void ensureRuntimeDomain() {}
  std::string pageFrameId() const { return "main-frame"; }
  void evaluateJavascript(const std::string&, const std::shared_ptr<ContentWorld>,
                          const std::function<void(std::string)>) const;
  void callAsyncJavaScript(const std::string&, const std::string&,
                           const std::shared_ptr<ContentWorld>,
                           const std::function<void(std::string)>) const;
  ~InAppWebView() {
    aliveToken_.reset();
    pendingScripts_->cancelAll();
  }
};

// PRODUCTION_METHODS
}  // namespace flutter_inappwebview_plugin

using namespace flutter_inappwebview_plugin;
using Results = std::vector<std::string>;

void runRequest(InAppWebView& view, bool async, const std::shared_ptr<ContentWorld>& world,
                Results& results) {
  auto complete = [&results](std::string value) { results.push_back(std::move(value)); };
  if (async) view.callAsyncJavaScript("return token;", R"({"token":42})", world, complete);
  else view.evaluateJavascript("42", world, complete);
}

void requireSuccess(const Results& results, bool async) {
  require(results.size() == 1, "success must complete exactly once");
  const auto result = nlohmann::json::parse(results.front());
  require(async ? result["value"] == 42 && result["error"].is_null() : result == 42,
          "success must preserve the public result shape");
}

void requireFailure(const Results& results, bool async) {
  require(results.size() == 1, "failure or cancellation must complete exactly once");
  const auto result = nlohmann::json::parse(results.front());
  require(async ? result["value"].is_null() && result["error"].is_string() : result.is_null(),
          "failure must return null for eval and an error for async");
}

void pageSuccess() {
  for (bool async : {false, true}) {
    Results results;
    InAppWebView view;
    runRequest(view, async, ContentWorld::page(), results);
    require(view.webView->calls.size() == 1, "page requests do not create an isolated world");
    const auto& call = view.webView->calls.front();
    require(call.method == "Runtime.evaluate" && !call.parameters.contains("contextId"),
            "only the explicitly selected page world may omit contextId");
    view.webView->reply(0, S_OK, LR"({"result":{"value":42}})");
    requireSuccess(results, async);
    require(view.pendingScripts_->count() == 0, "completed request must leave the registry");
  }
}

void isolatedSuccess() {
  for (bool async : {false, true}) {
    Results results;
    InAppWebView view;
    auto world = std::make_shared<ContentWorld>("isolated");
    runRequest(view, async, world, results);
    require(view.webView->calls.at(0).method == "Page.createIsolatedWorld", "create the requested world first");
    view.webView->reply(0, S_OK, LR"({"executionContextId":7})");
    require(view.webView->calls.at(1).parameters.at("contextId") == 7, "execute in the created context");
    require(view.userContentController->pluginScriptsAdded == 1, "live isolated creation retains plugin scripts");
    view.webView->reply(1, S_OK, LR"({"result":{"value":42}})");
    requireSuccess(results, async);

    results.clear();
    view.userContentController->contentWorlds_[world->name] = 9;
    runRequest(view, async, world, results);
    require(view.webView->calls.size() == 3 && view.webView->calls.at(2).parameters.at("contextId") == 9,
            "an existing isolated context is reused directly");
    view.webView->reply(2, S_OK, LR"({"result":{"value":42}})");
    requireSuccess(results, async);
  }
}

void creationFailure() {
  const std::vector<std::pair<HRESULT, LPCWSTR>> failures = {
    {E_FAIL, nullptr}, {S_OK, nullptr}, {S_OK, L"invalid-json"}, {S_OK, L"null"}, {S_OK, L"{}"},
    {S_OK, LR"({"executionContextId":"7"})"}, {S_OK, LR"({"executionContextId":7.5})"},
    {S_OK, LR"({"executionContextId":-1})"}, {S_OK, LR"({"executionContextId":2147483648})"},
    {S_OK, LR"({"executionContextId":18446744073709551615})"}
  };
  for (bool async : {false, true}) {
    for (const auto& failure : failures) {
      Results results;
      InAppWebView view;
      runRequest(view, async, std::make_shared<ContentWorld>("isolated"), results);
      view.webView->reply(0, failure.first, failure.second);
      // Remove pending fake COM handlers before reporting a failed assertion, so
      // an expected negative regression does not leave a test-double reference cycle.
      view.webView->clearHandlers();
      require(view.webView->calls.size() == 1, "isolated-world failure must not call Runtime.evaluate");
      require(view.userContentController->pluginScriptsAdded == 0, "failed creation must not install plugin scripts");
      requireFailure(results, async);
      require(view.pendingScripts_->count() == 0, "failed creation must release the request");
    }
    Results results;
    InAppWebView view;
    view.webView->nextCallResult = E_FAIL;
    runRequest(view, async, std::make_shared<ContentWorld>("isolated"), results);
    require(view.webView->calls.size() == 1, "synchronous world failure must not evaluate in the page");
    requireFailure(results, async);
  }
}

void cancellation() {
  for (bool async : {false, true}) {
    Results oldResults, replacementResults;
    InAppWebView view;
    auto world = std::make_shared<ContentWorld>("isolated");
    runRequest(view, async, world, oldResults);
    view.pendingScripts_->cancelAll();  // committed document replacement or process loss
    requireFailure(oldResults, async);
    runRequest(view, async, world, replacementResults);
    view.webView->reply(0, S_OK, LR"({"executionContextId":7})");
    require(view.userContentController->pluginScriptsAdded == 0,
            "a cancelled world's late reply must not install scripts in the replacement document");
    require(view.webView->calls.size() == 2, "a cancelled request must not evaluate");
    require(replacementResults.empty(), "a late reply must not complete the replacement request");
    view.webView->reply(1, S_OK, LR"({"executionContextId":9})");
    require(view.webView->calls.at(2).parameters.at("contextId") == 9, "new work after cancellation still runs");
    view.webView->reply(2, S_OK, LR"({"result":{"value":42}})");
    requireSuccess(replacementResults, async);
    requireFailure(oldResults, async);

    Results lateEval;
    runRequest(view, async, ContentWorld::page(), lateEval);
    view.pendingScripts_->cancelAll();
    view.webView->reply(3, S_OK, LR"({"result":{"value":42}})");
    view.pendingScripts_->cancelAll();
    requireFailure(lateEval, async);
  }
}

void disposal() {
  for (bool async : {false, true}) {
    Results results;
    std::shared_ptr<FakeWebView> webView;
    {
      InAppWebView view;
      webView = view.webView;
      runRequest(view, async, std::make_shared<ContentWorld>("isolated"), results);
    }
    requireFailure(results, async);
    webView->reply(0, S_OK, LR"({"executionContextId":7})");
    require(webView->calls.size() == 1, "a reply after destruction must not touch the freed controller");
    requireFailure(results, async);
  }
}

void peerIsolation() {
  for (bool async : {false, true}) {
    Results closedResults, peerResults;
    InAppWebView closing, peer;
    auto world = std::make_shared<ContentWorld>("isolated");
    runRequest(closing, async, world, closedResults);
    runRequest(peer, async, world, peerResults);
    closing.pendingScripts_->cancelAll();
    closing.webView->reply(0, E_FAIL, nullptr);
    peer.webView->reply(0, S_OK, LR"({"executionContextId":7})");
    peer.webView->reply(1, S_OK, LR"({"result":{"value":42}})");
    requireFailure(closedResults, async);
    requireSuccess(peerResults, async);
  }
}

int main(int argc, char** argv) {
  const std::map<std::string, std::function<void()>> cases = {
    {"page-success", pageSuccess}, {"isolated-success", isolatedSuccess},
    {"creation-failure", creationFailure}, {"cancellation", cancellation},
    {"disposal", disposal}, {"peer-isolation", peerIsolation}
  };
  try {
    for (const auto& test : cases) {
      if (argc > 1 && test.first != argv[1]) continue;
      test.second();
      std::cout << "PASS: " << test.first << '\n';
    }
  } catch (const std::exception& error) {
    std::cerr << "FAIL: " << error.what() << '\n';
    return 1;
  }
}
