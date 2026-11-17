#include "process_infos_generated.h"

#include <iostream>
#include <type_traits>

using namespace flutter_inappwebview_plugin;

namespace {
void require(bool condition, const std::string& message) {
  if (!condition) throw std::runtime_error(message);
}

struct Fixture {
  wil::com_ptr<ICoreWebView2Environment> environment = makeCom<ICoreWebView2Environment>();
  std::unique_ptr<WebViewEnvironment> owner = std::make_unique<WebViewEnvironment>(environment);
  int completions = 0;
  std::optional<ProcessInfosResult> result;

  void basic() {
    environment->basic = makeCom<ICoreWebView2Environment8>();
    environment->basic->collection = makeCom<ICoreWebView2ProcessInfoCollection>();
  }
  void extended() { environment->extended = makeCom<ICoreWebView2Environment13>(); }
  void start(std::function<void()> onComplete = nullptr) {
    owner->getProcessInfos([this, onComplete](auto value) {
      ++completions;
      if constexpr (std::is_same_v<decltype(value), ProcessInfosResult>) {
        result = std::move(value);
      }
      else {
        // Observe legacy successful-vector replies without changing the code
        // under test. Error assertions must fail on those replies.
        result = ProcessInfosResult{std::move(value), S_OK, {}, {}};
      }
      if (onComplete) onComplete();
    });
  }
  void error(HRESULT hr, const std::string& stage,
    const std::string& code = "process_info_collection_failed") const {
    require(completions == 1 && result.has_value(), "expected exactly one completion");
    require(result->error == hr, "lost HRESULT at " + stage);
    require(result->stage == stage, "wrong failure stage: " + result->stage);
    require(result->code == code, "wrong availability classification: " + result->code);
    require(result->infos.empty(), "a failed snapshot returned partial process data");
  }
  void success(size_t count) const {
    require(completions == 1 && result.has_value(), "expected exactly one completion");
    require(SUCCEEDED(result->error), "expected a successful snapshot");
    require(result->infos.size() == count, "wrong process count");
  }
};

auto extendedCollection(size_t count = 1) {
  auto collection = makeCom<ICoreWebView2ProcessExtendedInfoCollection>();
  for (size_t i = 0; i < count; ++i) {
    collection->items.push_back(makeCom<ICoreWebView2ProcessExtendedInfo>());
  }
  return collection;
}
auto basicCollection(size_t count = 1) {
  auto collection = makeCom<ICoreWebView2ProcessInfoCollection>();
  for (size_t i = 0; i < count; ++i) {
    collection->items.push_back(makeCom<ICoreWebView2ProcessInfo>());
  }
  return collection;
}

using Test = std::pair<std::string, std::function<void()>>;
std::vector<Test> tests() {
  std::vector<Test> result{
    {"unavailable_environment", [] {
      Fixture f;
      f.owner = std::make_unique<WebViewEnvironment>(nullptr);
      f.start();
      f.error(E_UNEXPECTED, "environment", "webview_environment_unavailable");
    }},
    {"unsupported_runtime", [] {
      Fixture f; f.start();
      f.error(E_NOINTERFACE, "QueryInterface.Environment8", "process_info_unsupported");
    }},
    {"interface_failure_is_not_unsupported", [] {
      Fixture f;
      f.environment->query13Error = E_ACCESSDENIED;
      f.start();
      f.error(E_ACCESSDENIED, "QueryInterface.Environment13");
    }},
    {"basic_interface_failure", [] {
      Fixture f;
      f.environment->query8Error = E_ACCESSDENIED;
      f.start();
      f.error(E_ACCESSDENIED, "QueryInterface.Environment8");
    }},
    {"null_basic_interface", [] {
      Fixture f;
      f.environment->query8Error = S_OK;
      f.start();
      f.error(E_POINTER, "QueryInterface.Environment8");
    }},
    {"basic_request_failure", [] {
      Fixture f; f.basic();
      f.environment->basic->error = E_ACCESSDENIED;
      f.start();
      f.error(E_ACCESSDENIED, "GetProcessInfos");
    }},
    {"extended_start_failure_retains_cause", [] {
      Fixture f; f.extended();
      f.environment->extended->startError = E_ACCESSDENIED;
      f.start();
      f.error(E_ACCESSDENIED, "GetProcessExtendedInfos");
    }},
    {"extended_start_failure_uses_basic_fallback_once", [] {
      Fixture f; f.basic(); f.extended();
      f.environment->basic->collection = basicCollection();
      f.environment->extended->startError = E_FAIL;
      f.start();
      f.success(1);
      require(f.environment->basic->requests == 1, "missing legacy fallback");
      f.environment->extended->complete(E_ACCESSDENIED, nullptr);
      f.success(1);
    }},
    {"basic_fallback_failure", [] {
      Fixture f; f.basic(); f.extended();
      f.environment->extended->startError = E_FAIL;
      f.environment->basic->error = E_ACCESSDENIED;
      f.start();
      f.error(E_ACCESSDENIED, "GetProcessInfos");
    }},
    {"null_extended_interface_uses_basic_fallback", [] {
      Fixture f; f.basic();
      f.environment->query13Error = S_OK;
      f.start();
      f.success(0);
    }},
    {"extended_callback_failure_is_explicit", [] {
      Fixture f; f.basic(); f.extended();
      f.start();
      require(f.completions == 0, "completed before the native callback");
      f.environment->extended->complete(E_ACCESSDENIED, nullptr);
      f.error(E_ACCESSDENIED, "GetProcessExtendedInfos.callback");
      require(f.environment->basic->requests == 0, "async errors silently retried");
    }},
    {"duplicate_callback_completes_once", [] {
      Fixture f; f.extended(); f.start();
      f.environment->extended->complete(S_OK, extendedCollection());
      f.environment->extended->complete(E_FAIL, nullptr);
      f.success(1);
    }},
    {"late_callback_after_environment_disposal", [] {
      Fixture f; f.extended(); f.start();
      f.owner.reset();
      f.environment->extended->complete(S_OK, extendedCollection());
      f.error(E_UNEXPECTED, "environment", "webview_environment_unavailable");
      f.environment->extended->complete(E_FAIL, nullptr);
      require(f.completions == 1, "disposed request completed twice");
    }},
    {"inline_completion_can_dispose_environment", [] {
      Fixture f; f.extended(); f.basic();
      f.environment->extended->completeInline = true;
      f.environment->extended->inlineCollection = extendedCollection();
      f.environment->extended->startError = E_FAIL;
      f.start([&] { f.owner.reset(); });
      f.success(1);
      require(f.environment->basic->requests == 0, "fallback after a completed request");
    }},
    {"native_callback_releases_reply_owner", [] {
      Fixture f; f.extended();
      auto reply = std::make_shared<int>(1);
      std::weak_ptr<int> weak = reply;
      f.owner->getProcessInfos([reply](auto) {});
      reply.reset();
      require(!weak.expired(), "reply owner lost while request was pending");
      f.environment->extended->complete(S_OK, extendedCollection(0));
      f.environment->extended->pending = nullptr;
      require(weak.expired(), "reply owner leaked after native callback release");
    }},
    {"extended_required_process_info_failure", [] {
      Fixture f; f.extended(); f.start();
      auto collection = extendedCollection();
      collection->items[0]->infoError = E_ACCESSDENIED;
      f.environment->extended->complete(S_OK, collection);
      f.error(E_ACCESSDENIED, "GetProcessExtendedInfos[0].get_ProcessInfo");
    }},
    {"extended_required_process_info_null", [] {
      Fixture f; f.extended(); f.start();
      auto collection = extendedCollection();
      collection->items[0]->info = nullptr;
      f.environment->extended->complete(S_OK, collection);
      f.error(E_POINTER, "GetProcessExtendedInfos[0].get_ProcessInfo");
    }},
    {"extended_optional_frames_fail_or_return_null", [] {
      for (HRESULT hr : { E_FAIL, S_OK }) {
        Fixture f; f.extended(); f.start();
        auto collection = extendedCollection();
        collection->items[0]->framesError = hr;
        f.environment->extended->complete(S_OK, collection);
        f.success(1);
        require(!f.result->infos[0]->frameInfos.has_value(), "unavailable frames reported as collected");
      }
    }},
    {"extended_optional_frame_iterator_null", [] {
      Fixture f; f.extended(); f.start();
      auto collection = extendedCollection();
      collection->items[0]->frames = makeCom<ICoreWebView2FrameInfoCollection>();
      f.environment->extended->complete(S_OK, collection);
      f.success(1);
      require(!f.result->infos[0]->frameInfos.has_value(), "missing iterator reported as collected");
    }},
    {"extended_preserves_available_frame_details", [] {
      Fixture f; f.extended(); f.start();
      auto collection = extendedCollection();
      auto frames = makeCom<ICoreWebView2FrameInfoCollection>();
      frames->iterator = makeCom<ICoreWebView2FrameInfoCollectionIterator>();
      frames->iterator->current = makeCom<ICoreWebView2FrameInfo>();
      collection->items[0]->frames = frames;
      f.environment->extended->complete(S_OK, collection);
      f.success(1);
      require(f.result->infos[0]->frameInfos->size() == 1, "lost frame metadata");
    }},
    {"event_decoder_keeps_best_effort_behavior", [] {
      auto collection = basicCollection(2);
      collection->failingIndex = 0;
      auto detail = BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessInfoCollection(collection);
      require(detail->infos.size() == 1, "event no longer keeps readable entries");
      collection->countError = E_FAIL;
      detail = BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessInfoCollection(collection);
      require(detail->infos.empty(), "event count failure changed behavior");
      auto info = makeCom<ICoreWebView2ProcessInfo>();
      info->kindError = E_FAIL;
      auto converted = BrowserProcessInfo::fromICoreWebView2ProcessInfo(info);
      require(!converted->kind.has_value(), "best-effort converter became strict");
    }},
  };

  // The same collection contract applies to both WebView2 APIs.
  for (bool extended : {false, true}) {
    for (std::string scenario : {"empty", "populated", "null", "count_failure",
      "item_failure", "null_item", "kind_failure", "optional_pid"}) {
      result.emplace_back((extended ? "extended_" : "basic_") + scenario,
        [extended, scenario] {
          Fixture f;
          auto basic = basicCollection(scenario == "empty" ? 0 : 2);
          auto extra = extendedCollection(scenario == "empty" ? 0 : 2);
          const std::string api = extended ? "GetProcessExtendedInfos" : "GetProcessInfos";
          if (scenario == "count_failure") {
            basic->countError = extra->countError = E_ACCESSDENIED;
          }
          if (scenario == "item_failure") {
            basic->failingIndex = extra->failingIndex = 1;
          }
          if (scenario == "null_item") {
            basic->items[1] = nullptr;
            extra->items[1] = nullptr;
          }
          if (scenario == "kind_failure") {
            basic->items[1]->kindError = extra->items[1]->info->kindError = E_ACCESSDENIED;
          }
          if (scenario == "optional_pid") {
            basic->items[1]->pidError = extra->items[1]->info->pidError = E_ACCESSDENIED;
          }
          if (extended) {
            f.extended(); f.start();
            f.environment->extended->complete(S_OK, scenario == "null" ? nullptr : extra);
          }
          else {
            f.basic();
            f.environment->basic->collection = scenario == "null" ? nullptr : basic;
            f.start();
          }
          if (scenario == "null") f.error(E_POINTER, api + ".collection");
          else if (scenario == "count_failure") f.error(E_ACCESSDENIED, api + ".get_Count");
          else if (scenario == "item_failure") f.error(E_ACCESSDENIED, api + ".GetValueAtIndex[1]");
          else if (scenario == "null_item") f.error(E_POINTER, api + ".GetValueAtIndex[1]");
          else if (scenario == "kind_failure") f.error(E_ACCESSDENIED, api + "[1].get_Kind");
          else {
            f.success(scenario == "empty" ? 0 : 2);
            if (scenario == "optional_pid") {
              require(!f.result->infos[1]->processId.has_value(), "unreadable PID became a fake value");
            }
            if (scenario == "populated") {
              require(f.result->infos[1]->kind == RENDERER && f.result->infos[1]->processId == 42,
                "process fields did not survive conversion");
            }
          }
        });
    }
  }
  return result;
}
}

int main(int argc, char** argv) {
  const std::string filter = argc > 1 ? argv[1] : "";
  int ran = 0, failed = 0;
  for (const auto& [name, test] : tests()) {
    if (!filter.empty() && name.find(filter) == std::string::npos) continue;
    ++ran;
    try {
      test();
      require(TestComObject::live == 0, "COM references leaked");
      std::cout << "PASS " << name << '\n';
    }
    catch (const std::exception& error) {
      ++failed;
      std::cerr << "FAIL " << name << ": " << error.what() << '\n';
    }
  }
  std::cout << ran << " production-source cases, " << failed << " failures\n";
  return ran == 0 || failed != 0 ? 1 : 0;
}
