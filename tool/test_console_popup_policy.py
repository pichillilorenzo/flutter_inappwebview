#!/usr/bin/env python3
"""Exercise production Linux console policy with a shared popup script manager.

The C++ test compiles the plugin's script installation, console policy and load
event methods with minimal WebKit doubles. Node runs their emitted JavaScript in
separate parent/popup documents. Both Linux backends explicitly share this
manager for related views; this test does not instantiate a live WPE backend.

Use --source-ref <commit> to reproduce the regression against an older revision.
"""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source-ref')
args = parser.parse_args()


def source(path):
    if args.source_ref:
        return subprocess.check_output(
            ['git', 'show', f'{args.source_ref}:{path}'], cwd=ROOT, text=True)
    return (ROOT / path).read_text()


def method(path, signature):
    text = source(path)
    start = text.index(signature)
    end = text.index('{', start) + 1
    depth = 1
    while depth:
        depth += (text[end] == '{') - (text[end] == '}')
        end += 1
    return text[start:end] + '\n'


VIEW = 'flutter_inappwebview_linux/linux/in_app_webview/in_app_webview.cc'
UCC = 'flutter_inappwebview_linux/linux/in_app_webview/user_content_controller.cc'
view_source = source(VIEW)
# The shared-manager double below models the topology used in both branches.
related_manager = '"user-content-manager", webkit_web_view_get_user_content_manager(params.relatedWebView)'
assert view_source.count(related_manager) == 2

code = r'''
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include <vector>
void require(bool condition, const char* reason) {
  if (!condition) { std::cerr << reason << "\n"; std::exit(1); }
}
struct ContentWorld {
  static std::shared_ptr<ContentWorld> page() { return nullptr; }
};
enum class UserScriptInjectionTime { atDocumentStart, atDocumentEnd };
struct UserScript {
  std::optional<std::string> groupName;
  std::string source;
  UserScriptInjectionTime injectionTime;
  bool forMainFrameOnly;
  std::optional<std::vector<std::string>> allowedOriginRules;
  std::shared_ptr<ContentWorld> contentWorld;
  UserScript(const std::optional<std::string>&, const std::string&,
             UserScriptInjectionTime, bool,
             const std::optional<std::vector<std::string>>& = std::nullopt,
             std::shared_ptr<ContentWorld> = nullptr);
};
struct PluginScript : UserScript {
  bool requiredInAllContentWorlds;
  std::vector<std::string> messageHandlerNames;
  PluginScript(const std::string&, const std::string&,
               UserScriptInjectionTime, bool,
               const std::optional<std::vector<std::string>>& = std::nullopt,
               std::shared_ptr<ContentWorld> = nullptr,
               bool = false, const std::vector<std::string>& = {});
};
struct JavaScriptBridgeJS {
  static std::string get_JAVASCRIPT_BRIDGE_NAME() { return "flutter_inappwebview"; }
};
using WebKitUserScriptInjectionTime = int;
using WebKitUserContentInjectedFrames = int;
constexpr int WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START = 0;
constexpr int WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END = 1;
constexpr int WEBKIT_USER_CONTENT_INJECT_TOP_FRAME = 0;
constexpr int WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES = 1;
struct WebKitUserScript { std::string source; };
struct WebKitUserContentManager {
  std::vector<std::string> scripts;
  int rebuilds = 0;
};
WebKitUserScript* webkit_user_script_new(const char* text, int, int, void*, void*) {
  return new WebKitUserScript{text};
}
void webkit_user_content_manager_add_script(WebKitUserContentManager* manager,
                                           WebKitUserScript* script) {
  manager->scripts.push_back(script->source);
}
void webkit_user_script_unref(WebKitUserScript* script) { delete script; }
void webkit_user_content_manager_remove_all_scripts(WebKitUserContentManager* manager) {
  ++manager->rebuilds;
  manager->scripts.clear();
}
struct UserContentController {
  WebKitUserContentManager* content_manager_;
  std::vector<std::unique_ptr<PluginScript>> plugin_scripts_;
  std::vector<std::shared_ptr<UserScript>> document_start_scripts_, document_end_scripts_;
  explicit UserContentController(WebKitUserContentManager* manager) : content_manager_(manager) {}
  void registerScriptMessageHandlerWithReply(const std::string&) {}
  WebKitUserScript* createWebKitUserScript(const std::shared_ptr<UserScript>&) const;
  void rebuildScripts();
  void addPluginScript(std::unique_ptr<PluginScript>);
  void replacePluginScript(std::unique_ptr<PluginScript>);
};
struct Settings {
  bool javaScriptBridgeEnabled = true;
  std::optional<std::vector<std::string>> pluginScriptsOriginAllowList;
  std::optional<std::vector<int64_t>> consoleMessageLevels;
};
struct WebKitWebView { bool valid = true; };
bool WEBKIT_IS_WEB_VIEW(WebKitWebView* view) { return view && view->valid; }
enum WebKitLoadEvent {
  WEBKIT_LOAD_STARTED, WEBKIT_LOAD_REDIRECTED, WEBKIT_LOAD_COMMITTED, WEBKIT_LOAD_FINISHED
};
using gpointer = void*;
struct Channel {
  int commits = 0, finishes = 0;
  void onLoadStart(const std::string&) {}
  void onPageCommitVisible(const std::string&) { ++commits; }
  void onLoadStop(const std::string&) { ++finishes; }
};
struct PendingJavaScriptRequestsDouble {
  int cancellations = 0;
  void cancelAll() { ++cancellations; }
};
struct InAppWebView {
  std::shared_ptr<PendingJavaScriptRequestsDouble> pending_java_script_calls_ =
      std::make_shared<PendingJavaScriptRequestsDouble>();
  UserContentController* user_content_controller_;
  std::shared_ptr<Settings> settings_ = std::make_shared<Settings>();
  bool has_console_message_listener_ = true;
  Channel* channel_delegate_;
  std::vector<std::string> evaluations;
  InAppWebView(UserContentController* content, Channel* channel)
      : user_content_controller_(content), channel_delegate_(channel) {}
  void evaluateJavascript(const std::string& text, std::nullopt_t, std::nullptr_t) {
    evaluations.push_back(text);
  }
  void HideAllPopups() {}
  std::optional<std::string> getUrl() { return "https://example.test/"; }
  bool acceptsConsoleMessage(int64_t) const;
  void setConsoleMessageListener(bool);
  void updateConsoleMessagePolicy();
  static void OnLoadChanged(WebKitWebView*, WebKitLoadEvent, gpointer);
};
'''
code += method('flutter_inappwebview_linux/linux/types/user_script.cc',
               'UserScript::UserScript(const std::optional<std::string>&')
code += method('flutter_inappwebview_linux/linux/types/plugin_script.cc',
               'PluginScript::PluginScript(const std::string&')
console = source('flutter_inappwebview_linux/linux/plugin_scripts_js/console_log_js.h')
code += console[console.index('class ConsoleLogJS'):
                console.index('}  // namespace flutter_inappwebview_plugin')]
for signature in ['WebKitUserScript* UserContentController::createWebKitUserScript(',
                  'void UserContentController::rebuildScripts()',
                  'void UserContentController::addPluginScript(']:
    code += method(UCC, signature)
if 'void UserContentController::replacePluginScript(' in source(UCC):
    code += method(UCC, 'void UserContentController::replacePluginScript(')
for signature in ['bool InAppWebView::acceptsConsoleMessage(',
                  'void InAppWebView::setConsoleMessageListener(',
                  'void InAppWebView::updateConsoleMessagePolicy()',
                  'void InAppWebView::OnLoadChanged(']:
    code += method(VIEW, signature)

code += r'''
int main(int argc, char** argv) {
  require(argc == 2, "An output directory is required");
  const std::filesystem::path directory(argv[1]);
  WebKitUserContentManager shared;
  UserContentController parentContent(&shared), popupContent(&shared);
  parentContent.addPluginScript(ConsoleLogJS::CONSOLE_LOG_JS_PLUGIN_SCRIPT(std::nullopt));
  parentContent.addPluginScript(std::make_unique<PluginScript>(
      "other-plugin", "window.otherPluginSurvived = true;",
      UserScriptInjectionTime::atDocumentStart, true));
  popupContent.addPluginScript(ConsoleLogJS::CONSOLE_LOG_JS_PLUGIN_SCRIPT(std::nullopt));
  const auto initialScripts = shared.scripts;
  Channel parentChannel, popupChannel;
  InAppWebView parent(&parentContent, &parentChannel), popup(&popupContent, &popupChannel);
  WebKitWebView nativeView;
  auto unchanged = [&]() {
    require(shared.rebuilds == 0 && shared.scripts == initialScripts,
            "A console policy update changed the shared parent/popup scripts");
  };
  auto write = [&](const std::string& file, const std::string& text) {
    std::ofstream(directory / file) << text;
  };
  auto snapshot = [&](const std::string& label, InAppWebView& view) {
    unchanged();
    std::string bootstrap;
    for (const auto& script : shared.scripts) bootstrap += script + "\n";
    write(label + ".bootstrap.js", bootstrap);
    auto before = view.evaluations.size();
    InAppWebView::OnLoadChanged(&nativeView, WEBKIT_LOAD_COMMITTED, &view);
    require(view.evaluations.size() == before + 1,
            "A committed document did not receive its own console policy");
    write(label + ".commit.js", view.evaluations.back());
    InAppWebView::OnLoadChanged(&nativeView, WEBKIT_LOAD_FINISHED, &view);
    require(view.evaluations.size() == before + 2,
            "A finished document did not retry its own console policy");
    write(label + ".finished.js", view.evaluations.back());
    std::string nativeLevels = "[";
    for (int64_t level = 0; level <= 4; ++level) {
      if (!view.acceptsConsoleMessage(level)) continue;
      if (nativeLevels.size() > 1) nativeLevels += ",";
      nativeLevels += std::to_string(level);
    }
    write(label + ".native.json", nativeLevels + "]");
    unchanged();
  };

  popup.settings_->consoleMessageLevels = std::vector<int64_t>{3};
  popup.updateConsoleMessagePolicy();
  unchanged();
  snapshot("parent_full", parent);
  snapshot("popup_error", popup);

  popup.setConsoleMessageListener(false);
  unchanged();
  snapshot("popup_off", popup);
  snapshot("parent_after_popup_off", parent);

  popup.setConsoleMessageListener(true);
  parent.settings_->consoleMessageLevels = std::vector<int64_t>{2};
  parent.updateConsoleMessagePolicy();
  unchanged();
  snapshot("parent_warning", parent);
  snapshot("popup_after_parent_warning", popup);

  parent.setConsoleMessageListener(false);
  popup.settings_->consoleMessageLevels = std::nullopt;
  popup.updateConsoleMessagePolicy();
  snapshot("parent_off", parent);
  snapshot("popup_after_parent_off", popup);

  parent.settings_->consoleMessageLevels = std::vector<int64_t>{};
  parent.setConsoleMessageListener(true);
  snapshot("parent_empty", parent);
  parent.settings_->consoleMessageLevels = std::nullopt;
  parent.updateConsoleMessagePolicy();
  snapshot("parent_default", parent);

  auto before = parent.evaluations.size();
  parent.settings_->javaScriptBridgeEnabled = false;
  parent.updateConsoleMessagePolicy();
  InAppWebView::OnLoadChanged(&nativeView, WEBKIT_LOAD_COMMITTED, &parent);
  require(parent.evaluations.size() == before, "A disabled bridge received console injection");
  require(parentChannel.commits > 0 && parentChannel.finishes > 0 &&
          popupChannel.commits > 0 && popupChannel.finishes > 0,
          "Existing navigation notifications were lost");
  unchanged();
  std::cout << "Production Linux policies and load events preserve the shared manager\n";
}
'''

node = r'''
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const directory = process.argv[2];
const text = name => fs.readFileSync(path.join(directory, name), 'utf8');
const levels = {debug: 0, log: 1, info: 1, warn: 2, error: 3};
function document(label, installBootstrap = true) {
  const d = {sent: [], delivered: [], originals: [], conversions: 0};
  d.nativeLevels = new Set(JSON.parse(text(label + '.native.json')));
  const timers = new Map();
  let nextTimer = 0;
  const console = Object.fromEntries(Object.keys(levels).map(level => [level, () => d.originals.push(level)]));
  const bridge = {callHandler(name, payload) {
    assert.equal(name, 'onConsoleMessageBatch');
    d.sent.push(...payload.messages.map(message => message.level));
    d.delivered.push(...payload.messages.filter(message => d.nativeLevels.has(levels[message.level])).map(message => message.level));
    return Promise.resolve(null);
  }};
  const window = {
    console, flutter_inappwebview: bridge,
    document: {hidden: false, addEventListener() {}}, addEventListener() {},
    setTimeout(fn) { timers.set(++nextTimer, fn); return nextTimer; },
    clearTimeout(id) { timers.delete(id); },
  };
  window.window = window;
  d.evaluate = script => vm.runInNewContext(script, window);
  d.flush = () => {
    while (timers.size) {
      const [id, fn] = timers.entries().next().value;
      timers.delete(id); fn();
    }
  };
  d.emit = () => {
    d.sent = []; d.delivered = []; d.originals = []; d.conversions = 0;
    for (const level of ['log', 'warn', 'error']) {
      window.console[level]({toString() { d.conversions++; return level; }});
    }
    d.flush();
    assert.deepEqual(d.originals, ['log', 'warn', 'error']);
    return d.delivered;
  };
  d.policy = state => {
    d.nativeLevels = new Set(JSON.parse(text(state + '.native.json')));
    d.evaluate(text(state + '.commit.js'));
  };
  if (installBootstrap) {
    d.evaluate(text(label + '.bootstrap.js'));
    assert.equal(window.otherPluginSurvived, true);
  }
  d.window = window;
  return d;
}

const expected = {
  parent_full: ['log', 'warn', 'error'],
  popup_error: ['error'],
  popup_off: [],
  parent_after_popup_off: ['log', 'warn', 'error'],
  parent_warning: ['warn'],
  popup_after_parent_warning: ['error'],
  parent_off: [],
  popup_after_parent_off: ['log', 'warn', 'error'],
  parent_empty: [],
  parent_default: ['log', 'warn', 'error'],
};
for (const [label, received] of Object.entries(expected)) {
  const d = document(label);
  assert.deepEqual(d.emit(), received, label + ': native filtering remains authoritative before the document policy arrives');
  assert.deepEqual(d.sent, ['log', 'warn', 'error'], label + ': the shared bootstrap is neutral');
  d.policy(label);
  assert.deepEqual(d.emit(), received, label + ': its own policy applies after commit');
  assert.deepEqual(d.sent, received, label + ': JS filters before crossing the bridge');
  assert.equal(d.conversions, received.length, label + ': filtered objects are not stringified');
  d.evaluate(text(label + '.finished.js'));
  d.evaluate(text(label + '.bootstrap.js'));
  assert.deepEqual(d.emit(), received, label + ': finish and reinjection preserve this document policy');
  assert.deepEqual(d.sent, received);
}

const parent = document('parent_full');
const popup = document('popup_error');
parent.policy('parent_full'); popup.policy('popup_error');
popup.policy('popup_off');
assert.deepEqual(parent.emit(), ['log', 'warn', 'error'], 'Detaching the popup cannot affect the live parent');
assert.deepEqual(popup.emit(), []);
parent.policy('parent_warning'); popup.policy('popup_after_parent_warning');
assert.deepEqual(parent.emit(), ['warn']);
assert.deepEqual(popup.emit(), ['error'], 'Parent restriction cannot affect the live popup');
parent.policy('parent_off'); popup.policy('popup_after_parent_off');
assert.deepEqual(parent.emit(), []);
assert.deepEqual(popup.emit(), ['log', 'warn', 'error'], 'Detached parent cannot affect the live popup');

// A policy evaluation only updates an existing publisher. It must not install
// one into a document where the bootstrap/bridge was intentionally absent.
const absent = document('parent_default', false);
absent.policy('parent_default');
assert.equal(absent.window.flutter_inappwebview._setConsoleMessagePolicy, undefined);
assert.deepEqual(absent.emit(), []);
assert.equal(absent.conversions, 0);
console.log('Production Linux JS: independent parent/popup navigation, detach, allowlists, defaults, early native filtering and no-hook documents passed');
'''

with tempfile.TemporaryDirectory(prefix='console-popup-policy-') as temporary:
    directory = Path(temporary)
    cpp = directory / 'test.cpp'
    binary = directory / 'test'
    js = directory / 'test.js'
    cpp.write_text(code)
    js.write_text(node)
    subprocess.run([os.environ.get('CXX', 'c++'), '-std=c++17', '-Wall', '-Wextra',
                    '-Werror', str(cpp), '-o', str(binary)], check=True)
    subprocess.run([str(binary), str(directory)], check=True)
    subprocess.run(['node', str(js), str(directory)], check=True)
