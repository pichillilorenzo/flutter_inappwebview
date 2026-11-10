#!/usr/bin/env python3
"""Run production console forwarders with minimal channel/timer doubles.

This compiles the method bodies from the plugin; it is not a WebView SDK build.
Use `apple` on a host with swiftc. Android's production delegate is exercised by
ConsoleMessageBatchTest under Robolectric in android-renderer-lifecycle.yaml.
"""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from swift_source import extract_swift_block

ROOT = Path(__file__).resolve().parents[1]


def method(path, signature):
    source = (ROOT / path).read_text()
    if path.endswith('.swift'):
        return extract_swift_block(source, signature)
    start = source.index(signature)
    opening = source.index('{', start)
    depth = 1
    end = opening + 1
    while depth:
        if source[end] == '{':
            depth += 1
        elif source[end] == '}':
            depth -= 1
        end += 1
    return source[start:end]


COMMON = r'''
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <variant>
#include <vector>
using Message = std::pair<std::string, int64_t>;
struct InAppWebViewSettings { std::optional<std::vector<int64_t>> consoleMessageLevels; };
'''

WINDOWS = r'''
using UINT_PTR = uintptr_t;
namespace flutter {
class EncodableValue;
using EncodableList = std::vector<EncodableValue>;
using EncodableMap = std::map<EncodableValue, EncodableValue>;
using ValueBase = std::variant<std::monostate, std::string, int64_t, EncodableList, EncodableMap>;
class EncodableValue : public ValueBase {
 public:
  using ValueBase::ValueBase;
  EncodableValue(const char* text) : ValueBase(std::string(text)) {}
  bool operator<(const EncodableValue& other) const {
    return static_cast<const ValueBase&>(*this) < static_cast<const ValueBase&>(other);
  }
};
}
flutter::EncodableValue make_fl_value(const std::optional<std::string>& value) {
  return value ? flutter::EncodableValue(*value) : flutter::EncodableValue();
}
void debugLog(const std::string&) {}
struct Timer {
  inline static std::map<UINT_PTR, std::function<void()>> timers;
  inline static UINT_PTR next = 0;
  inline static bool fail = false;
  static UINT_PTR setTimeout(std::function<void()> callback, int delay) {
    assert(delay == 25);
    if (fail) return 0;
    timers[++next] = callback;
    assert(timers.size() == 1);
    return next;
  }
  static void clearTimeout(UINT_PTR id) { timers.erase(id); }
  static void drain() {
    while (!timers.empty()) {
      auto id = timers.begin()->first;
      auto callback = timers.begin()->second;
      callback();
      timers.erase(id);
    }
  }
};
struct Channel {
  std::vector<std::string> methods;
  std::vector<std::vector<Message>> batches;
  void InvokeMethod(const std::string& method, std::unique_ptr<flutter::EncodableValue> args) {
    methods.push_back(method);
    if (method != "onConsoleMessageBatch") return;
    const auto& values = std::get<flutter::EncodableList>(std::get<flutter::EncodableMap>(*args).at("messages"));
    std::vector<Message> batch;
    size_t bytes = 0;
    for (const auto& value : values) {
      const auto& map = std::get<flutter::EncodableMap>(value);
      batch.emplace_back(std::get<std::string>(map.at("message")), std::get<int64_t>(map.at("messageLevel")));
      bytes += batch.back().first.size() + 48;
    }
    assert(!batch.empty() && batch.size() <= 64);
    assert(bytes <= 65536 || batch.size() == 1);
    batches.push_back(batch);
  }
};
struct InAppWebView {
  std::shared_ptr<InAppWebViewSettings> settings = std::make_shared<InAppWebViewSettings>();
  bool hasConsoleMessageListener_ = true;
  bool acceptsConsoleMessage(int64_t level) const;
};
struct WebViewChannelDelegate {
  InAppWebView* webView;
  Channel* channel;
  mutable std::vector<Message> pendingConsoleMessages_;
  mutable size_t pendingConsoleBytes_ = 0;
  mutable UINT_PTR consoleFlushTimer_ = 0;
  WebViewChannelDelegate(InAppWebView* view, Channel* c) : webView(view), channel(c) {}
  ~WebViewChannelDelegate();
  void onConsoleMessage(const std::string&, const int64_t&) const;
  void flushConsoleMessages() const;
  void clearConsoleMessages() const;
  void onLoadStart(const std::optional<std::string>&) const;
};
'''
WINDOWS_TEST = r'''
int main() {
  InAppWebView view; Channel channel;
  auto delegate = std::make_unique<WebViewChannelDelegate>(&view, &channel);
  for (int i = 0; i < 10000; ++i) delegate->onConsoleMessage("log-" + std::to_string(i), 1);
  assert(delegate->pendingConsoleMessages_.size() < 64);
  Timer::drain();
  assert(channel.batches.size() == 157);
  size_t index = 0;
  for (const auto& batch : channel.batches) for (const auto& entry : batch) assert(entry.first == "log-" + std::to_string(index++));
  assert(index == 10000);
  std::cout << "Windows production native->Dart: 10000 records -> " << channel.batches.size() << " InvokeMethod calls\n";
  channel = {};
  view.settings->consoleMessageLevels = std::vector<int64_t>{2, 3};
  for (int i = 0; i < 10000; ++i) for (const auto level : {0, 1, 4}) delegate->onConsoleMessage("filtered", level);
  assert(Timer::timers.empty() && channel.batches.empty());
  delegate->onConsoleMessage("warn", 2);
  delegate->onConsoleMessage("error", 3);
  assert(channel.batches.size() == 2);
  view.settings->consoleMessageLevels = std::nullopt;
  delegate->onConsoleMessage("queued", 1);
  delegate->onConsoleMessage("warning", 2);
  assert(channel.batches.back().size() == 2 && Timer::timers.empty());
  delegate->onConsoleMessage("before navigation", 1);
  delegate->onLoadStart("https://example.com");
  assert(channel.methods[channel.methods.size() - 2] == "onConsoleMessageBatch");
  assert(channel.methods.back() == "onLoadStart" && Timer::timers.empty());
  delegate->onConsoleMessage("stale policy", 1);
  view.settings->consoleMessageLevels = std::vector<int64_t>{2, 3};
  auto before = channel.batches.size(); Timer::drain(); assert(channel.batches.size() == before);
  view.settings->consoleMessageLevels = std::nullopt;
  delegate->onConsoleMessage("detach pending", 1);
  view.hasConsoleMessageListener_ = false; delegate->clearConsoleMessages();
  delegate->onConsoleMessage("detached error", 3);
  Timer::drain(); assert(channel.batches.size() == before);
  view.hasConsoleMessageListener_ = true;
  delegate->onConsoleMessage(std::string(40000, 'a'), 1);
  delegate->onConsoleMessage(std::string(40000, 'b'), 1);
  delegate->onConsoleMessage(std::string(80000, 'c'), 1);
  assert(channel.batches.size() == before + 3);
  delegate->onConsoleMessage("closing", 1);
  delegate.reset(); assert(Timer::timers.empty());
  Timer::drain(); assert(channel.batches.size() == before + 3);
  delegate = std::make_unique<WebViewChannelDelegate>(&view, &channel);
  Timer::fail = true;
  delegate->onConsoleMessage("timer unavailable", 1);
  assert(channel.batches.back()[0].first == "timer unavailable");
  std::cout << "Windows flood/order/filter/policy/navigation/detach/dispose/timer-failure checks passed\n";
}
'''

LINUX = r'''
struct FlValue {
  int refs = 1;
  std::string text;
  int64_t number = 0;
  std::vector<FlValue*> list;
  std::map<std::string, FlValue*> map;
};
FlValue* fl_value_ref(FlValue* v) { ++v->refs; return v; }
void fl_value_unref(FlValue* v) {
  if (!v || --v->refs) return;
  for (auto* entry : v->list) fl_value_unref(entry);
  for (auto& entry : v->map) fl_value_unref(entry.second);
  delete v;
}
void cleanup_value(FlValue** value) { fl_value_unref(*value); }
#define g_autoptr(T) T* __attribute__((cleanup(cleanup_value)))
FlValue* fl_value_new_list() { return new FlValue(); }
size_t fl_value_get_length(FlValue* value) { return value->list.size(); }
void fl_value_append_take(FlValue* list, FlValue* value) { list->list.push_back(value); }
FlValue* make_fl_value(const std::string& text) { auto* v = new FlValue(); v->text = text; return v; }
FlValue* make_fl_value(int64_t number) { auto* v = new FlValue(); v->number = number; return v; }
FlValue* to_fl_map(std::initializer_list<std::pair<const std::string, FlValue*>> entries) {
  auto* v = new FlValue(); v->map = entries; return v;
}
struct InAppWebView {
  std::shared_ptr<InAppWebViewSettings> settings_ = std::make_shared<InAppWebViewSettings>();
  bool has_console_message_listener_ = true;
  bool acceptsConsoleMessage(int64_t level) const;
};
struct WebViewChannelDelegate {
  InAppWebView* webView;
  bool channel_ = true;
  mutable std::vector<std::vector<Message>> batches;
  void onConsoleMessage(const std::string&, int64_t) const;
  void onConsoleMessages(const std::vector<Message>&) const;
  void invokeMethod(const std::string& method, FlValue* args) const {
    assert(method == "onConsoleMessageBatch");
    std::vector<Message> batch;
    size_t bytes = 0;
    for (auto* entry : args->map.at("messages")->list) {
      batch.emplace_back(entry->map.at("message")->text, entry->map.at("messageLevel")->number);
      bytes += batch.back().first.size() + 48;
    }
    assert(!batch.empty() && batch.size() <= 64);
    assert(bytes <= 65536 || batch.size() == 1);
    batches.push_back(batch);
  }
};
'''
LINUX_TEST = r'''
int main() {
  InAppWebView view; WebViewChannelDelegate delegate{&view, true, {}};
  std::vector<Message> input;
  for (int i = 0; i < 10000; ++i) input.emplace_back("log-" + std::to_string(i), 1);
  for (size_t start = 0; start < input.size(); start += 64) {
    delegate.onConsoleMessages({input.begin() + start, input.begin() + std::min(input.size(), start + 64)});
  }
  assert(delegate.batches.size() == 157);
  std::vector<Message> forwarded;
  for (const auto& batch : delegate.batches) forwarded.insert(forwarded.end(), batch.begin(), batch.end());
  assert(forwarded == input);
  std::cout << "Linux production native->Dart: 10000 records -> " << delegate.batches.size() << " invokeMethod calls\n";
  delegate.batches.clear();
  view.settings_->consoleMessageLevels = std::vector<int64_t>{2, 3};
  delegate.onConsoleMessages({{"tip", 0}, {"log", 1}, {"warn", 2}, {"error", 3}, {"debug", 4}});
  assert(delegate.batches.size() == 1 && delegate.batches[0].size() == 2);
  delegate.batches.clear(); delegate.onConsoleMessages(input); assert(delegate.batches.empty());
  view.settings_->consoleMessageLevels = std::vector<int64_t>{};
  delegate.onConsoleMessage("empty policy", 3); assert(delegate.batches.empty());
  view.settings_->consoleMessageLevels = std::nullopt;
  delegate.onConsoleMessages({{std::string(40000, 'a'), 1}, {std::string(40000, 'b'), 1}, {std::string(80000, 'c'), 1}, {"tail", 1}});
  assert(delegate.batches.size() == 4);
  view.has_console_message_listener_ = false; delegate.onConsoleMessages(input); assert(delegate.batches.size() == 4);
  view.has_console_message_listener_ = true; delegate.channel_ = false; delegate.onConsoleMessages(input); assert(delegate.batches.size() == 4);
  delegate.channel_ = true; delegate.webView = nullptr; delegate.onConsoleMessages(input); assert(delegate.batches.size() == 4);
  std::cout << "Linux bounded batching/order/filter/diagnostics/no-listener/dispose checks passed\n";
}
'''


def run_cpp(platform, prefix, test):
    base = f'flutter_inappwebview_{platform}/{platform}/in_app_webview/'
    extension = 'cpp' if platform == 'windows' else 'cc'
    view = base + 'in_app_webview.' + extension
    delegate = base + 'webview_channel_delegate.' + extension
    code = COMMON + prefix + '\n' + method(view, 'bool InAppWebView::acceptsConsoleMessage(')
    names = ['void WebViewChannelDelegate::onConsoleMessage(']
    if platform == 'windows':
        names += ['void WebViewChannelDelegate::flushConsoleMessages(', 'void WebViewChannelDelegate::clearConsoleMessages(',
                  'void WebViewChannelDelegate::onLoadStart(', 'WebViewChannelDelegate::~WebViewChannelDelegate(']
    else:
        names += ['void WebViewChannelDelegate::onConsoleMessages(']
    for name in names:
        code += '\n' + method(delegate, name)
    code += '\n' + test
    with tempfile.TemporaryDirectory(prefix='console-native-') as directory:
        source = Path(directory) / 'test.cpp'
        binary = Path(directory) / 'test'
        source.write_text(code)
        subprocess.run([os.environ.get('CXX', 'c++'), '-std=c++17', '-Wall', '-Wextra', '-Werror', '-g',
                        str(source), '-o', str(binary)], check=True)
        subprocess.run([str(binary)], check=True)


def run_apple(platform):
    base = f'flutter_inappwebview_{platform}/{platform}/flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}/InAppWebView/'
    accepts = method(base + 'InAppWebView.swift', 'public func acceptsConsoleMessage(')
    single = method(base + 'WebViewChannelDelegate.swift', 'public func onConsoleMessage(')
    batch = method(base + 'WebViewChannelDelegate.swift', 'public func onConsoleMessages(')
    code = '''import Foundation
class InAppWebViewSettings { var consoleMessageLevels: [Int]? = nil }
class InAppWebView {
  var hasConsoleMessageListener = true
  var settings: InAppWebViewSettings? = InAppWebViewSettings()
''' + accepts + '''
}
class Channel {
  var batches: [[[String: Any]]] = []
  func invokeMethod(_ method: String, arguments: [String: Any]) {
    precondition(method == "onConsoleMessageBatch")
    let batch = arguments["messages"] as! [[String: Any]]
    precondition(!batch.isEmpty && batch.count <= 64)
    let size = batch.reduce(0) { $0 + ($1["message"] as! String).utf16.count + 48 }
    precondition(size <= 65536 || batch.count == 1)
    batches.append(batch)
  }
}
class WebViewChannelDelegate {
  var webView: InAppWebView? = InAppWebView()
  var channel: Channel? = Channel()
''' + single + '\n' + batch + '''
}
let delegate = WebViewChannelDelegate()
for start in stride(from: 0, to: 10000, by: 64) {
  delegate.onConsoleMessages((start..<min(start + 64, 10000)).map { ("log-\\($0)", 1) })
}
precondition(delegate.channel!.batches.count == 157)
let messages = delegate.channel!.batches.flatMap { $0 }.map { $0["message"] as! String }
precondition(messages == (0..<10000).map { "log-\\($0)" })
print("PLATFORM production native->Dart: 10000 records -> 157 invokeMethod calls")
delegate.channel!.batches = []
delegate.webView!.settings!.consoleMessageLevels = [2, 3]
delegate.onConsoleMessages([("tip", 0), ("log", 1), ("warn", 2), ("error", 3), ("debug", 4)])
precondition(delegate.channel!.batches.count == 1 && delegate.channel!.batches[0].count == 2)
delegate.channel!.batches = []
delegate.webView!.settings!.consoleMessageLevels = []
delegate.onConsoleMessage(message: "empty policy", messageLevel: 3)
precondition(delegate.channel!.batches.isEmpty)
delegate.webView!.settings!.consoleMessageLevels = nil
delegate.onConsoleMessages([(String(repeating: "א", count: 40000), 1), (String(repeating: "b", count: 40000), 1), (String(repeating: "c", count: 80000), 1), ("tail", 1)])
precondition(delegate.channel!.batches.count == 4)
delegate.webView!.hasConsoleMessageListener = false
delegate.onConsoleMessage(message: "detached", messageLevel: 3)
precondition(delegate.channel!.batches.count == 4)
delegate.webView = nil
delegate.onConsoleMessage(message: "disposed", messageLevel: 3)
precondition(delegate.channel!.batches.count == 4)
print("PLATFORM bounded batching/order/filter/diagnostics/no-listener/dispose checks passed")
'''.replace('PLATFORM', platform)
    with tempfile.TemporaryDirectory(prefix='console-native-') as directory:
        source = Path(directory) / 'test.swift'
        binary = Path(directory) / 'test'
        source.write_text(code)
        subprocess.run(['swiftc', str(source), '-o', str(binary)], check=True)
        subprocess.run([str(binary)], check=True)


if __name__ == '__main__':
    if sys.argv[1:] == ['apple']:
        for platform in ('ios', 'macos'):
            run_apple(platform)
    else:
        run_cpp('windows', WINDOWS, WINDOWS_TEST)
        run_cpp('linux', LINUX, LINUX_TEST)
