// Runs production native reply builders, then executes their output in V8.
// Usage: node tool/test_javascript_handler_json_replies.js apple|android|windows
// Android needs JAVA_HOME and ANDROID_JSON_JAR (an org.json implementation).
// Windows needs nlohmann/json.hpp on the include path, or NLOHMANN_JSON_INCLUDE.
const assert = require('node:assert/strict');
const {execFileSync} = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');

const root = path.resolve(__dirname, '..');
const fixtures = require('./javascript_handler_json_cases.json');
const cases = [...fixtures.valid, ...fixtures.invalid];
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'handler-json-replies-'));

function verify(platform, scripts) {
  assert.equal(scripts.length, cases.length);
  scripts.forEach((record, index) => {
    const [script, argumentsObject] = typeof record === 'string' ? [record, {}] : record;
    const raw = cases[index];
    let resolved = 0;
    let rejected = 0;
    let value;
    const bridge = {7: {
      resolve(result) { resolved++; value = result; },
      reject() { rejected++; },
    }};
    const window = {flutter_inappwebview: bridge};
    vm.runInNewContext(script, {window, ...argumentsObject});
    assert.equal(window.injected, undefined, `${platform}: never evaluate data as code`);
    assert.equal(bridge[7], undefined, `${platform}: always remove the pending callback`);
    if (index < fixtures.valid.length) {
      assert.equal(resolved, 1, `${platform}: resolve ${raw}`);
      assert.equal(rejected, 0);
      const expected = JSON.parse(raw);
      assert.equal(JSON.stringify(value), JSON.stringify(expected), `${platform}: preserve JSON data`);
      if (typeof expected === 'number') assert.ok(Object.is(value, expected));
      if (expected && Object.hasOwn(expected, '__proto__')) {
        assert.ok(Object.hasOwn(value, '__proto__'), `${platform}: __proto__ is an own data property`);
        assert.equal(value.inherited, undefined);
      }
    } else {
      assert.equal(resolved, 0, `${platform}: do not resolve invalid JSON`);
      assert.equal(rejected, 1, `${platform}: reject invalid JSON`);
    }
    // Replies arriving after disposal must be harmless.
    vm.runInNewContext(script, {window: {flutter_inappwebview: {}}, ...argumentsObject});
  });
  console.log(`${platform}: ${scripts.length} native JSON replies passed`);
}

function apple() {
  for (const platform of ['ios', 'macos']) {
    const sources = path.join(root, `flutter_inappwebview_${platform}`, platform,
      `flutter_inappwebview_${platform}`, 'Sources', `flutter_inappwebview_${platform}`);
    const native = fs.readFileSync(path.join(sources, 'InAppWebView/InAppWebView.swift'), 'utf8');
    const util = fs.readFileSync(path.join(sources, 'Util.swift'), 'utf8');
    const jsonStart = util.indexOf('    public static func JSONStringify(');
    const jsonFunction = util.slice(jsonStart, util.indexOf('    @available', jsonStart));
    const start = native.indexOf('            callback.defaultBehaviour = { [weak webView] (response: Any?) in',
      native.indexOf('if message.name == "callHandler"'));
    const branch = native.slice(start, native.indexOf('            callback.error = ', start));
    // Compile the entire callback, including the argument path and the legacy
    // path. Replace only OS availability checks to exercise both on this host.
    const callback = branch.replace(/if #available\([^)]*\)/g, 'if modern');
    const lifetime = fs.readFileSync(path.join(sources, 'Types/JavaScriptBridgeReply.swift'), 'utf8');
    const swift = path.join(temp, `${platform}.swift`);
    const binary = path.join(temp, platform);
    fs.writeFileSync(swift, `
import Foundation
${lifetime}
struct Util { ${jsonFunction} }
struct JavaScriptBridgeJS {
  static func get_JAVASCRIPT_BRIDGE_NAME() -> String { "flutter_inappwebview" }
}
enum ContentWorld { case page }
class WebView {
  var windowId: Int? = nil
  var record: [Any] = []
  func evaluateJavaScript(_ source: String, completionHandler: (() -> Void)?) {
    record = [source, [String: String]()]
  }
  func callAsyncJavaScript(_ source: String, arguments: [String: String], frame: Any?, contentWorld: ContentWorld, completionHandler: (() -> Void)?) {
    record = [source, arguments]
  }
}
class Callback { var defaultBehaviour: ((Any?) -> Void)? }
let cases = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [String]
let _callHandlerID = 7
var scripts: [[Any]] = []
for mode in 0..<${platform === 'ios' ? 3 : 2} {
  let modern = mode != 1
  for input in cases {
    let callback = Callback()
    let reply: JavaScriptBridgeReply? = nil
    let webView = WebView()
    webView.windowId = mode == 2 ? 1 : nil
${callback}
    callback.defaultBehaviour!(input)
    scripts.append(webView.record)
  }
}
let data = try! JSONSerialization.data(withJSONObject: scripts)
print(String(data: data, encoding: .utf8)!)
`);
    execFileSync('swiftc', [swift, '-o', binary], {stdio: 'inherit'});
    const scripts = JSON.parse(execFileSync(binary, [path.join(temp, 'cases.json')], {encoding: 'utf8'}));
    const modern = scripts.slice(0, cases.length);
    const legacy = scripts.slice(cases.length, cases.length * 2);
    verify(`${platform} arguments`, modern);
    verify(`${platform} legacy script`, legacy);
    if (platform === 'ios') verify('ios popup fallback', scripts.slice(cases.length * 2));
    modern.forEach(([script, args], i) => {
      assert.equal(args.jsonText, cases[i]);
      assert.ok(!script.includes(cases[i]) || cases[i].length < 5, 'payload stays outside script');
    });
    legacy.forEach(([script]) => assert.ok(!/[\u2028\u2029]/.test(script), 'escape line separators for older WebKit'));
  }
}

function android() {
  const native = fs.readFileSync(path.join(root, 'flutter_inappwebview_android/android/src/main/java/com/pichillilorenzo/flutter_inappwebview_android/webview/JavaScriptBridgeInterface.java'), 'utf8');
  const start = native.indexOf('public void defaultBehaviour(@Nullable Object json)');
  const branch = native.slice(start, native.indexOf('public void error(', start));
  const declarationStart = branch.includes('              String jsonText =')
    ? branch.indexOf('              String jsonText =')
    : branch.indexOf('              String sourceCode =');
  const declaration = branch.slice(declarationStart,
    branch.indexOf('              inAppWebView.evaluateJavascript('));
  const javaHome = process.env.JAVA_HOME || '/Applications/Android Studio.app/Contents/jbr/Contents/Home';
  const jsonJar = process.env.ANDROID_JSON_JAR || '/Applications/Android Studio.app/Contents/plugins/grazie/lib/org.json-json.jar';
  const java = path.join(temp, 'Reply.java');
  fs.writeFileSync(java, `
import org.json.*;
import java.nio.file.*;
class Reply {
  static class JavaScriptBridgeJS {
    static String get_JAVASCRIPT_BRIDGE_NAME() { return "flutter_inappwebview"; }
  }
  public static void main(String[] args) throws Exception {
    JSONArray cases = new JSONArray(Files.readString(Path.of(args[0])));
    JSONArray scripts = new JSONArray();
    int _callHandlerID = 7;
    for (int i=0; i<cases.length(); ++i) {
      Object json = cases.getString(i);
${declaration}
      scripts.put(sourceCode);
    }
    System.out.println(scripts);
  }
}
`);
  execFileSync(path.join(javaHome, 'bin/javac'), ['-cp', jsonJar, java], {stdio: 'inherit'});
  const output = execFileSync(path.join(javaHome, 'bin/java'), ['-cp', `${temp}${path.delimiter}${jsonJar}`, 'Reply', path.join(temp, 'cases.json')], {encoding: 'utf8'});
  verify('android', JSON.parse(output));
}

function windows() {
  const cpp = path.join(temp, 'reply.cpp');
  const binary = path.join(temp, 'reply');
  fs.writeFileSync(cpp, `
#include <fstream>
#include <iostream>
#include "flutter_inappwebview_windows/windows/plugin_scripts_js/javascript_bridge_message.h"
using flutter_inappwebview_plugin::JavaScriptBridgeMessage;
int main(int argc, char** argv) {
  std::ifstream input(argv[1]);
  auto cases = nlohmann::json::parse(input);
  nlohmann::json scripts = nlohmann::json::array();
  nlohmann::json messages = nlohmann::json::array();
  for (const auto& raw : cases) {
    scripts.push_back(JavaScriptBridgeMessage::settleScript("flutter_inappwebview", 7, raw, std::nullopt));
    messages.push_back(JavaScriptBridgeMessage::resolution("flutter_inappwebview", 7, raw));
  }
  std::cout << nlohmann::json::array({scripts, messages}).dump();
}
`);
  const flags = process.env.NLOHMANN_JSON_INCLUDE ? ['-I', process.env.NLOHMANN_JSON_INCLUDE] : [];
  execFileSync(process.env.CXX || 'c++', ['-std=c++17', '-I', root, ...flags, cpp, '-o', binary], {stdio: 'inherit'});
  const [scripts, messages] = JSON.parse(execFileSync(binary, [path.join(temp, 'cases.json')], {encoding: 'utf8'}));
  verify('windows script fallback', scripts);
  fixtures.valid.forEach((raw, index) => {
    // PostWebMessageAsJson parses the JSON envelope rather than evaluating it.
    const value = JSON.parse(messages[index]).flutter_inappwebview.v;
    assert.equal(JSON.stringify(value), JSON.stringify(JSON.parse(raw)));
  });
  console.log(`windows web messages: ${fixtures.valid.length} JSON values passed`);
}

try {
  fs.writeFileSync(path.join(temp, 'cases.json'), JSON.stringify(cases));
  const mode = process.argv[2];
  assert.ok(['apple', 'android', 'windows'].includes(mode), 'choose apple, android or windows');
  ({apple, android, windows})[mode]();
} finally {
  fs.rmSync(temp, {recursive: true, force: true});
}
