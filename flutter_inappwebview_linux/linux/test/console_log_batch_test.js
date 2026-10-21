const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const repoRoot = path.resolve(__dirname, '../../..');
const linuxSourcePath = path.join(repoRoot, 'flutter_inappwebview_linux/linux/plugin_scripts_js/console_log_js.h');
const iosRoot = path.join(repoRoot, 'flutter_inappwebview_ios/ios/flutter_inappwebview_ios/Sources/flutter_inappwebview_ios');
const macosRoot = path.join(repoRoot, 'flutter_inappwebview_macos/macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos');

function linuxScript() {
  const source = fs.readFileSync(linuxSourcePath, 'utf8');
  const match = source.match(/return R"JS\(([\s\S]*?)\)JS"\s*\+\s*JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME\(\)\s*\+\s*R"JS\(([\s\S]*?)\)JS";/);
  assert.ok(match, 'Linux console source contains its complete raw JavaScript literal');
  return match[1] + 'flutter_inappwebview' + match[2];
}

function swiftScript(root, relativePath) {
  const source = fs.readFileSync(path.join(root, relativePath), 'utf8');
  const match = source.match(/source: CONSOLE_LOG_JS_SOURCE\(\)[\s\S]*?func CONSOLE_LOG_JS_SOURCE\(\) -> String \{\s*return """([\s\S]*?)"""/);
  assert.ok(match, `${relativePath} exposes a multiline console source`);
  return match[1].replaceAll('\\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())', 'flutter_inappwebview');
}

function runScript(source, oneWay, alwaysThrows = false) {
  const sent = [];
  const originalCalls = [];
  const listeners = {};
  const timers = new Map();
  let nextTimer = 1;
  let attemptCount = 0;
  let timerCreateCount = 0;
  let bridgeUnavailable = alwaysThrows;
  let onSend = null;
  const send = (message) => {
    attemptCount++;
    if (bridgeUnavailable) {
      throw new Error('bridge unavailable');
    }
    sent.push(message);
    if (onSend) {
      const callback = onSend;
      onSend = null;
      callback();
    }
  };
  const bridge = {
    callHandler: (handlerName, payload) => {
      send({ handlerName, args: JSON.stringify([payload]), oneWay: false });
      return Promise.resolve(null);
    },
    _callHandlerOneWay: (handlerName, payload) => {
      send({ handlerName, args: JSON.stringify([payload]), oneWay: true });
    },
  };
  const console = {};
  for (const level of ['log', 'debug', 'error', 'info', 'warn']) {
    console[level] = (...args) => originalCalls.push({ level, args });
  }
  const window = {
    console,
    flutter_inappwebview: bridge,
    document: {
      hidden: false,
      addEventListener: (name, callback) => { listeners[`document:${name}`] = callback; },
    },
    addEventListener: (name, callback) => { listeners[name] = callback; },
    setTimeout: (callback) => {
      timerCreateCount++;
      const id = nextTimer++;
      timers.set(id, callback);
      return id;
    },
    clearTimeout: (id) => timers.delete(id),
  };
  window.window = window;
  vm.runInNewContext(source, window);
  return {
    window, sent, originalCalls, listeners, timers,
    get attemptCount() { return attemptCount; },
    get timerCreateCount() { return timerCreateCount; },
    setBridgeUnavailable(value) { bridgeUnavailable = value; },
    setOnSend(callback) { onSend = callback; },
    flushTimers() {
      while (timers.size) {
        const [id, callback] = timers.entries().next().value;
        timers.delete(id);
        callback();
      }
    },
  };
}

function runSuite(platform, source, oneWay) {
  const harness = runScript(source, oneWay);
  const { window, sent, originalCalls, listeners } = harness;
  for (let i = 0; i < 1000; i++) window.console.log(`message-${i}`);
  window.console.debug('debug entry');
  window.console.warn('warning');
  window.console.error('error');
  window.console.info();
  assert.equal(originalCalls.length, 1004, `${platform}: every original console method runs immediately`);
  assert.ok(sent.length < 20, `${platform}: 1000 logs use far fewer bridge sends`);
  harness.flushTimers();
  assert.ok(sent.length < 20, `${platform}: 1000 logs use far fewer bridge sends`);
  assert.equal(sent[0].handlerName, 'onConsoleMessageBatch');
  assert.ok(sent.every((message) => message.oneWay === oneWay), `${platform}: uses its intended bridge reply mode`);
  const records = sent.flatMap((message) => JSON.parse(message.args)[0].messages);
  assert.ok(sent.every((message) => JSON.parse(message.args)[0].messages.length <= 64),
    `${platform}: native message batches stay bounded`);
  assert.equal(records.length, 1004, `${platform}: all console entries are forwarded`);
  for (let i = 0; i < 1000; i++) {
    assert.equal(records[i].message, `message-${i}`, `${platform}: record ${i} stays ordered`);
  }
  assert.deepEqual(records.slice(-4).map((entry) => entry.level), ['debug', 'warn', 'error', 'info']);
  assert.equal(records.at(-1).message, '', `${platform}: empty argument lists remain an empty message`);

  window.console.log('lifecycle pending');
  const sendsBeforeHidden = sent.length;
  window.document.hidden = true;
  listeners['document:visibilitychange']();
  assert.equal(sent.length, sendsBeforeHidden + 1, `${platform}: hidden visibility flushes trailing entries`);
  assert.equal(JSON.parse(sent.at(-1).args)[0].messages[0].message, 'lifecycle pending');
  window.console.log('pagehide pending');
  listeners.pagehide();
  assert.equal(JSON.parse(sent.at(-1).args)[0].messages[0].message, 'pagehide pending');

  const failingBridge = runScript(source, oneWay, true);
  for (let i = 0; i < 1000; i++) failingBridge.window.console.log(`offline-${i}`);
  failingBridge.flushTimers();
  assert.ok(failingBridge.attemptCount < 20, `${platform}: a permanently failed bridge does not cause retry traffic`);
  assert.ok(failingBridge.timerCreateCount <= Math.ceil(1000 / 64) + 1,
    `${platform}: failed batches do not create extra retry timers`);
  assert.equal(failingBridge.timers.size, 0, `${platform}: failed sends leave no scheduled retry`);
  failingBridge.setBridgeUnavailable(false);
  failingBridge.window.console.warn('recovered');
  const recovered = failingBridge.sent.flatMap((message) => JSON.parse(message.args)[0].messages);
  assert.equal(recovered.at(-1).message, 'recovered', `${platform}: a later healthy log still reaches native`);
  assert.equal(failingBridge.originalCalls.length, 1001, `${platform}: original console always runs during bridge failure`);
}

function runLargePayloadSuite(platform, source, oneWay) {
  const harness = runScript(source, oneWay);
  const longSmallMessages = Array.from({ length: 20 }, (_, index) => `${index}:` + 's'.repeat(4000));
  const oversizedMessage = 'L'.repeat(70000);
  for (const message of longSmallMessages) harness.window.console.log(message);
  const sendsBeforeOversized = harness.sent.length;
  harness.window.console.log(oversizedMessage);
  assert.equal(harness.sent.length, sendsBeforeOversized + 2,
    `${platform}: queued normal text flushes before an oversized message, which sends immediately`);
  assert.equal(JSON.parse(harness.sent.at(-1).args)[0].messages[0].message, oversizedMessage,
    `${platform}: one oversized message is sent intact`);
  harness.window.console.log('after oversized');
  harness.flushTimers();

  const batches = harness.sent.map((message) => JSON.parse(message.args)[0].messages);
  const records = batches.flat();
  assert.deepEqual(records.map((record) => record.message), [...longSmallMessages, oversizedMessage, 'after oversized'],
    `${platform}: size-triggered flush keeps every message in order`);
  assert.ok(batches.every((batch) => batch.length <= 64), `${platform}: large strings do not bypass the record cap`);
  for (const batch of batches) {
    const size = batch.reduce((total, record) => total + record.message.length + 48, 0);
    assert.ok(size <= 65536 || (batch.length === 1 && batch[0].message.length > 65536),
      `${platform}: queued text stays within budget, with an oversized single message intact`);
  }
  assert.equal(harness.originalCalls.length, 22, `${platform}: originals run immediately for large messages too`);
}

function runReentrantSuite(platform, source, oneWay) {
  const harness = runScript(source, oneWay);
  harness.setOnSend(() => {
    for (let i = 0; i < 100; i++) harness.window.console.log(`reentrant-${i}`);
  });
  harness.window.console.warn('outer warning');
  harness.flushTimers();
  const batches = harness.sent.map((message) => JSON.parse(message.args)[0].messages);
  const records = batches.flat();
  assert.deepEqual(records.map((record) => record.message), [
    'outer warning', ...Array.from({ length: 100 }, (_, index) => `reentrant-${index}`),
  ], `${platform}: reentrant logs flush in order after the in-flight batch`);
  assert.ok(batches.every((batch) => batch.length <= 64), `${platform}: reentrant flushes remain batch-bounded`);
  assert.ok(harness.timerCreateCount <= 3, `${platform}: reentrant flush schedules a finite number of timers`);
  assert.equal(harness.timers.size, 0, `${platform}: reentrant queue drains without timer spin`);
}

runSuite('Linux', linuxScript(), false);
runSuite('iOS', swiftScript(iosRoot, 'PluginScriptsJS/ConsoleLogJS.swift'), true);
runSuite('macOS', swiftScript(macosRoot, 'PluginScriptsJS/ConsoleLogJS.swift'), true);
runLargePayloadSuite('Linux', linuxScript(), false);
runLargePayloadSuite('iOS', swiftScript(iosRoot, 'PluginScriptsJS/ConsoleLogJS.swift'), true);
runLargePayloadSuite('macOS', swiftScript(macosRoot, 'PluginScriptsJS/ConsoleLogJS.swift'), true);
runReentrantSuite('Linux', linuxScript(), false);
runReentrantSuite('iOS', swiftScript(iosRoot, 'PluginScriptsJS/ConsoleLogJS.swift'), true);
runReentrantSuite('macOS', swiftScript(macosRoot, 'PluginScriptsJS/ConsoleLogJS.swift'), true);

const iosBridge = fs.readFileSync(path.join(iosRoot, 'PluginScriptsJS/JavaScriptBridgeJS.swift'), 'utf8');
assert.match(iosBridge, /_callHandlerOneWay = function\(\)/, 'iOS helper is one-way');
assert.match(iosBridge, /'_bridgeSecret': bridgeSecret/, 'iOS one-way helper retains bridge-secret protection');
const macBridge = fs.readFileSync(path.join(macosRoot, 'PluginScriptsJS/JavaScriptBridgeJS.swift'), 'utf8');
assert.match(macBridge, /_callHandlerOneWay = function\(\)/, 'macOS helper is one-way');
assert.match(macBridge, /'_bridgeSecret': bridgeSecret/, 'macOS one-way helper retains bridge-secret protection');
for (const [platform, root] of [['iOS', iosRoot], ['macOS', macosRoot]]) {
  const native = fs.readFileSync(path.join(root, 'InAppWebView/InAppWebView.swift'), 'utf8');
  assert.match(native, /case "onConsoleMessage", "onConsoleMessageBatch"/, `${platform}: batch stays on the internal console dispatcher`);
  assert.match(native, /for jsonData in consoleMessages/, `${platform}: native dispatch preserves every callback`);
  assert.match(native, /if body\["_callHandlerOneWay"\] as\? Bool == true \{\s*return\s*\}\s*evaluateJavaScript/, `${platform}: internal one-way calls skip promise reply evaluation`);
}
const linuxNative = fs.readFileSync(path.join(repoRoot, 'flutter_inappwebview_linux/linux/in_app_webview/in_app_webview.cc'), 'utf8');
assert.match(linuxNative, /handlerName == "onConsoleMessageBatch"/, 'Linux recognizes the internal batch handler');
assert.match(linuxNative, /for \(const auto& consoleMessage : consoleMessages\)/, 'Linux dispatches every original callback in order');

console.log('console_log_batch_test passed');
