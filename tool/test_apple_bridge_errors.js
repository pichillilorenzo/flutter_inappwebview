const assert = require('node:assert/strict');
const {execFileSync} = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');

// Compile the actual native interpolation and JSON encoder, then execute the
// resulting reply so syntax errors and altered error messages are observable.
const root = path.resolve(__dirname, '..');
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'apple-bridge-error-'));
try {
  for (const platform of ['ios', 'macos']) {
    const sources = path.join(root, `flutter_inappwebview_${platform}`, platform,
      `flutter_inappwebview_${platform}`, 'Sources', `flutter_inappwebview_${platform}`);
    const native = fs.readFileSync(path.join(sources, 'InAppWebView/InAppWebView.swift'), 'utf8');
    const util = fs.readFileSync(path.join(sources, 'Util.swift'), 'utf8');
    const jsonFunction = util.slice(util.indexOf('    public static func JSONStringify('),
      util.indexOf('    @available', util.indexOf('    public static func JSONStringify(')));
    const errorStart = native.indexOf('            callback.error = { [weak webView] (code: String, message: String?, details: Any?) in', native.indexOf('    func handleScriptMessage('));
    const errorBranch = native.slice(errorStart, native.indexOf('            if let channelDelegate = webView.channelDelegate', errorStart));
    const callback = errorBranch.replace('                print(errorMessage)', '');
    const lifetime = fs.readFileSync(path.join(sources, 'Types/JavaScriptBridgeReply.swift'), 'utf8');
    const harness = `
import Foundation
${lifetime}
struct Util { ${jsonFunction} }
class WebView {
  var script = ""
  func evaluateJavaScript(_ source: String, completionHandler: (() -> Void)?) { script = source }
}
class Callback { var error: ((String, String?, Any?) -> Void)? }
struct JavaScriptBridgeJS {
  static func get_JAVASCRIPT_BRIDGE_NAME() -> String { "flutter_inappwebview" }
}
let cases = ["line\\nbreak\\r\\t", "quotes '\\" and backslash \\\\ and trailing \\\\",
  "\\u{2028}\\u{2029}", "עברית 😃", "'); throw new Error('injected"];
let code = "ERR"
let _callHandlerID = 7
var scripts: [String] = []
for input in cases {
  let message: String? = input
  let reply: JavaScriptBridgeReply? = nil
  let webView = WebView()
  let callback = Callback()
${callback}
  callback.error!(code, message, nil)
  scripts.append(webView.script)
}
let data = try! JSONSerialization.data(withJSONObject: [cases, scripts])
print(String(data: data, encoding: .utf8)!)
`;
    const swift = path.join(temp, `${platform}.swift`);
    const binary = path.join(temp, platform);
    fs.writeFileSync(swift, harness);
    execFileSync('swiftc', [swift, '-o', binary], {stdio: 'inherit'});
    const [cases, scripts] = JSON.parse(execFileSync(binary, {encoding: 'utf8'}));
    cases.forEach((input, index) => {
      let message;
      const bridge = {7: {reject(error) { message = error.message; }}};
      vm.runInNewContext(scripts[index], {window: {flutter_inappwebview: bridge}});
      assert.equal(message, `ERR, ${input}`, `${platform}: preserve the error message`);
      assert.equal(bridge[7], undefined, `${platform}: remove the pending callback`);
      assert.ok(!scripts[index].includes('\u2028') && !scripts[index].includes('\u2029'),
        `${platform}: escape JavaScript line separators for older WebKit`);
      vm.runInNewContext(scripts[index], {window: {flutter_inappwebview: {}}});
    });
    console.log(`${platform}: ${cases.length} native bridge error replies passed`);
  }
} finally {
  fs.rmSync(temp, {recursive: true, force: true});
}
