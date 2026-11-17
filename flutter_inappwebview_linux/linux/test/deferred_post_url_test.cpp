// Production methods are included by run_deferred_post_url_test.py.
// These native doubles control callback order/history without Flutter or WPE.
#include <atomic>
#include <cassert>
#include <climits>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <filesystem>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <vector>
#include <unistd.h>
#include "../in_app_webview/deferred_post_url_script.h"

using flutter_inappwebview_plugin::DeferredPostUrlScript;
using gchar = char;
using gpointer = void*;
using gboolean = int;
using guint = unsigned int;
using GSourceFunc = gboolean (*)(gpointer);
using GDestroyNotify = void (*)(gpointer);
constexpr int G_PRIORITY_DEFAULT = 0;
constexpr int G_SOURCE_REMOVE = 0;
constexpr int FALSE = 0;

struct Source {
  GSourceFunc callback;
  gpointer data;
  GDestroyNotify destroy;
};
std::map<guint, Source> sources;
std::deque<std::function<void()>> main_context_tasks;
std::function<void()> load_html_hook;
guint next_source_id = 1;
int destroy_notifications = 0;

guint g_timeout_add_full(int priority, unsigned interval, GSourceFunc callback,
                        gpointer data, GDestroyNotify destroy) {
  assert(priority == G_PRIORITY_DEFAULT && interval == 100);
  assert(callback != nullptr && data != nullptr && destroy != nullptr);
  const guint id = next_source_id++;
  sources.emplace(id, Source{callback, data, destroy});
  return id;
}

gboolean g_source_remove(guint id) {
  const auto found = sources.find(id);
  if (found == sources.end()) return false;
  const Source source = found->second;
  sources.erase(found);
  ++destroy_notifications;
  source.destroy(source.data); // Use the notifier supplied by production.
  return true;
}

void fireSources() {
  while (!sources.empty()) {
    const auto found = sources.begin();
    const Source source = found->second;
    sources.erase(found);
    assert(source.callback(source.data) == G_SOURCE_REMOVE);
    ++destroy_notifications;
    source.destroy(source.data);
  }
}

gboolean g_main_context_iteration(void*, gboolean) {
  if (main_context_tasks.empty()) return false;
  auto task = std::move(main_context_tasks.front());
  main_context_tasks.pop_front();
  task();
  return true;
}
void g_message(const char*) {}
void g_free(void* data) { std::free(data); }
// Keep this lifecycle fixture compatible with the asset URI encoding fix.
// URI escaping itself is covered by file_asset_uri_test, not these doubles.
struct GError { gchar* message = nullptr; };
gchar* g_filename_to_uri(const gchar* filename, const gchar*, GError**) {
  const std::string uri = "file://" + std::string(filename);
  auto* result = static_cast<gchar*>(std::malloc(uri.size() + 1));
  assert(result != nullptr);
  std::memcpy(result, uri.c_str(), uri.size() + 1);
  return result;
}
void g_error_free(GError* error) {
  g_free(error->message);
  delete error;
}
gchar* g_base64_encode(const uint8_t*, size_t) {
  // Request encoding is outside this lifecycle test; supply valid fixed data.
  constexpr char encoded[] = "Zm9vPWJhcg==";
  auto* result = static_cast<gchar*>(std::malloc(sizeof(encoded)));
  assert(result != nullptr);
  std::memcpy(result, encoded, sizeof(encoded));
  return result;
}
void replace_all(std::string& value, const std::string& old_value,
                 const std::string& new_value) {
  size_t offset = 0;
  while ((offset = value.find(old_value, offset)) != std::string::npos) {
    value.replace(offset, old_value.size(), new_value);
    offset += new_value.size();
  }
}

struct WebKitBackForwardListItem {};
struct WebKitBackForwardList {
  bool available = true;
  std::optional<int> valid_step;
  WebKitBackForwardListItem item;
};
struct WebKitWebView {
  bool has_back = false;
  bool has_forward = false;
  bool loading = false;
  int navigation_calls = 0;
  int stop_calls = 0;
  int blank_loads = 0;
  WebKitBackForwardList history;
  std::vector<std::string> evaluations;
};
struct SoupMessageHeaders {};
struct WebKitURIRequest { std::string url; SoupMessageHeaders headers; };
struct GBytes { std::string data; };
struct URLRequest {
  std::optional<std::string> url;
  std::optional<std::string> method;
  std::optional<std::vector<uint8_t>> body;
  std::optional<std::map<std::string, std::string>> headers;
};

void webkit_web_view_stop_loading(WebKitWebView* view) {
  ++view->stop_calls;
  view->loading = false;
}
void webkit_web_view_load_html(WebKitWebView* view, const char*, const char*) {
  ++view->blank_loads;
  // Consume before invoking so a nested postUrl can load another document.
  auto hook = std::exchange(load_html_hook, {});
  if (hook) hook();
}
void webkit_web_view_evaluate_javascript(WebKitWebView* view, const char* script,
                                       int, void*, void*, void*, void*, void*) {
  view->evaluations.emplace_back(script);
}
void webkit_web_view_load_uri(WebKitWebView* view, const char*) {
  ++view->navigation_calls;
}
WebKitURIRequest* webkit_uri_request_new(const char* url) {
  return new WebKitURIRequest{url, {}};
}
SoupMessageHeaders* webkit_uri_request_get_http_headers(WebKitURIRequest* request) {
  return &request->headers;
}
void soup_message_headers_append(SoupMessageHeaders*, const char*, const char*) {}
void webkit_web_view_load_request(WebKitWebView* view, WebKitURIRequest*) {
  ++view->navigation_calls;
}
void g_object_unref(WebKitURIRequest* request) { delete request; }
GBytes* g_bytes_new(const char* data, size_t size) { return new GBytes{{data, size}}; }
void g_bytes_unref(GBytes* bytes) { delete bytes; }
void webkit_web_view_load_bytes(WebKitWebView* view, GBytes*, const char*,
                               const char*, const char*) {
  ++view->navigation_calls;
}
void webkit_web_view_reload(WebKitWebView* view) { ++view->navigation_calls; }
void webkit_web_view_reload_bypass_cache(WebKitWebView* view) {
  ++view->navigation_calls;
}
gboolean webkit_web_view_can_go_back(WebKitWebView* view) { return view->has_back; }
gboolean webkit_web_view_can_go_forward(WebKitWebView* view) { return view->has_forward; }
void webkit_web_view_go_back(WebKitWebView* view) {
  if (view->has_back) ++view->navigation_calls;
}
void webkit_web_view_go_forward(WebKitWebView* view) {
  if (view->has_forward) ++view->navigation_calls;
}
WebKitBackForwardList* webkit_web_view_get_back_forward_list(WebKitWebView* view) {
  return view->history.available ? &view->history : nullptr;
}
WebKitBackForwardListItem* webkit_back_forward_list_get_nth_item(
    WebKitBackForwardList* list, int steps) {
  return list->valid_step == steps ? &list->item : nullptr;
}
void webkit_web_view_go_to_back_forward_list_item(WebKitWebView* view,
                                                 WebKitBackForwardListItem*) {
  ++view->navigation_calls;
}
gboolean webkit_web_view_is_loading(WebKitWebView* view) { return view->loading; }

struct PendingJavaScriptCalls { void cancelAll() {} };
class InAppWebView {
 public:
  explicit InAppWebView(WebKitWebView* view) : webview_(view) {}
  ~InAppWebView();
  WebKitWebView* webview() { return webview_; }
  void debugLog(const std::string&) {}
  void CancelHiddenPixelBufferTrim() {}
  void CancelHostBoundPopups() {}
  void loadUrl(const std::string& url);
  void loadUrl(const std::shared_ptr<URLRequest>& request);
  void loadData(const std::string& data, const std::string& mime_type,
                const std::string& encoding, const std::string& base_url);
  void loadFile(const std::string& asset_file_path);
  void postUrl(const std::string& url, const std::vector<uint8_t>& data);
  void reload();
  void reloadFromOrigin();
  void goBack();
  void goForward();
  bool canGoBack() const;
  bool canGoForward() const;
  void stopLoading();
  bool isLoading() const;
  void goBackOrForward(int steps);
  bool canGoBackOrForward(int steps) const;

  WebKitWebView* webview_;
  std::shared_ptr<int> lifetime_token_ = std::make_shared<int>(0);
  uint64_t post_url_generation_ = 0;
  bool has_console_message_listener_ = false;
  std::atomic<bool> is_disposing_{false};
  std::unique_ptr<PendingJavaScriptCalls> pending_java_script_calls_ =
      std::make_unique<PendingJavaScriptCalls>();
};

#include "post_url_methods_under_test.inc"

const std::vector<uint8_t> post_data{'f', 'o', 'o', '=', 'b', 'a', 'r'};

void post(InAppWebView& view, const std::string& suffix = "first") {
  view.postUrl("https://example.test/" + suffix, post_data);
}
void expectPost(const WebKitWebView& engine, const std::string& suffix = "first") {
  assert(engine.evaluations.size() == 1);
  assert(engine.evaluations.front().find("https://example.test/" + suffix) !=
         std::string::npos);
}

void testNoOpCommands() {
  const std::vector<std::function<void(InAppWebView&, WebKitWebView&)>> commands{
      [](auto& view, auto&) { view.goBack(); },
      [](auto& view, auto&) { view.goForward(); },
      [](auto& view, auto&) { view.goBackOrForward(-1); },
      [](auto& view, auto&) { view.goBackOrForward(1); },
      [](auto& view, auto& engine) {
        engine.history.available = false;
        view.goBackOrForward(-1);
      },
      [](auto& view, auto&) { view.loadUrl(std::shared_ptr<URLRequest>{}); },
      [](auto& view, auto&) { view.loadUrl(std::make_shared<URLRequest>()); },
  };
  for (const auto& command : commands) {
    WebKitWebView engine;
    InAppWebView view(&engine);
    post(view);
    command(view, engine);
    assert(engine.navigation_calls == 0);
    fireSources();
    expectPost(engine);
  }
}

void testValidCommands() {
  const std::vector<std::function<void(InAppWebView&)>> commands{
      [](auto& view) { view.goBack(); },
      [](auto& view) { view.goForward(); },
      [](auto& view) { view.goBackOrForward(-1); },
      [](auto& view) { view.loadUrl(std::string("https://example.test/next")); },
      [](auto& view) {
        auto request = std::make_shared<URLRequest>();
        request->url = "https://example.test/next";
        view.loadUrl(request);
      },
      [](auto& view) {
        auto request = std::make_shared<URLRequest>();
        request->url = "https://example.test/next";
        request->headers = std::map<std::string, std::string>{{"Accept", "text/html"}};
        view.loadUrl(request);
      },
      [](auto& view) { view.loadData("next", "text/html", "utf-8", ""); },
      [](auto& view) { view.loadFile("post-url-test.html"); },
      [](auto& view) { view.reload(); },
      [](auto& view) { view.reloadFromOrigin(); },
  };
  for (const auto& command : commands) {
    WebKitWebView engine;
    engine.has_back = engine.has_forward = true;
    engine.history.valid_step = -1;
    InAppWebView view(&engine);
    post(view);
    command(view);
    assert(engine.navigation_calls == 1);
    fireSources();
    assert(engine.evaluations.empty());
  }
  // The POST can remain pending after WebKit has finished its blank load.
  WebKitWebView engine;
  InAppWebView view(&engine);
  post(view);
  assert(!view.isLoading());
  view.stopLoading();
  fireSources();
  assert(engine.evaluations.empty());
}

void testLifetimeAndCleanup() {
  WebKitWebView destroyed_engine;
  auto* destroyed = new InAppWebView(&destroyed_engine);
  post(*destroyed);
  delete destroyed;

  WebKitWebView live_engine;
  InAppWebView live(&live_engine);
  post(live, "live");
  const int destroys_before = destroy_notifications;
  fireSources();
  assert(destroy_notifications == destroys_before + 2);
  assert(destroyed_engine.evaluations.empty());
  expectPost(live_engine, "live");

  WebKitWebView removed_engine;
  InAppWebView removed(&removed_engine);
  post(removed);
  const guint id = sources.begin()->first;
  const int removals_before = destroy_notifications;
  assert(g_source_remove(id));
  assert(!g_source_remove(id));
  assert(destroy_notifications == removals_before + 1);
  assert(removed_engine.evaluations.empty());
  assert(sources.empty());

  WebKitWebView unavailable_engine;
  InAppWebView unavailable(&unavailable_engine);
  post(unavailable);
  unavailable.webview_ = nullptr;
  fireSources();
  assert(unavailable_engine.evaluations.empty());
}

void testReentrantCalls() {
  {
    WebKitWebView engine;
    InAppWebView view(&engine);
    main_context_tasks.emplace_back([&] { view.stopLoading(); });
    post(view);
    fireSources();
    assert(engine.blank_loads == 0 && engine.evaluations.empty());
  }
  {
    WebKitWebView engine;
    InAppWebView view(&engine);
    main_context_tasks.emplace_back([&] { post(view, "newer"); });
    post(view, "older");
    fireSources();
    assert(engine.blank_loads == 1);
    expectPost(engine, "newer");
  }
  {
    WebKitWebView engine;
    auto* view = new InAppWebView(&engine);
    main_context_tasks.emplace_back([view] { delete view; });
    post(*view);
    fireSources();
    assert(engine.blank_loads == 0 && engine.evaluations.empty());
  }
  {
    WebKitWebView engine;
    InAppWebView view(&engine);
    load_html_hook = [&] { view.loadUrl(std::string("https://example.test/next")); };
    post(view);
    fireSources();
    assert(engine.navigation_calls == 1 && engine.evaluations.empty());
  }
  {
    WebKitWebView engine;
    InAppWebView view(&engine);
    load_html_hook = [&] { post(view, "newer"); };
    post(view, "older");
    fireSources();
    expectPost(engine, "newer");
  }
  {
    WebKitWebView engine;
    auto* view = new InAppWebView(&engine);
    load_html_hook = [view] { delete view; };
    post(*view);
    fireSources();
    assert(engine.evaluations.empty());
  }
}

int main() {
  {
    WebKitWebView engine;
    InAppWebView view(&engine);
    post(view);
    fireSources();
    expectPost(engine);
  }
  testNoOpCommands();
  testValidCommands();
  {
    WebKitWebView engine;
    InAppWebView view(&engine);
    post(view, "older");
    post(view, "newer");
    fireSources();
    expectPost(engine, "newer");
  }
  testLifetimeAndCleanup();
  testReentrantCalls();
  assert(sources.empty() && main_context_tasks.empty() && !load_html_hook);
  std::cout << "Production deferred POST navigation, lifetime and cleanup tests passed\n";
}
