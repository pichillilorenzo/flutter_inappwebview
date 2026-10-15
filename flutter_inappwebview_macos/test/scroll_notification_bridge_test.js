const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');

const packageRoot = path.resolve(__dirname, '..');
const sourceRoot = path.join(
  packageRoot,
  'macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos',
);
const swiftRoot = path.join(sourceRoot, 'PluginScriptsJS');
const bridgePath = path.join(swiftRoot, 'JavaScriptBridgeJS.swift');
const scrollPath = path.join(swiftRoot, 'OnScrollChangedJS.swift');
const nativePath = path.join(sourceRoot, 'InAppWebView/InAppWebView.swift');

const harness = `
import Foundation

public enum WKUserScriptInjectionTime { case atDocumentStart }
public struct PluginScript {
    public let source: String
    public init(groupName: String, source: String, injectionTime: WKUserScriptInjectionTime,
         forMainFrameOnly: Bool, allowedOriginRules: [String]?,
         requiredInAllContentWorlds: Bool = false, messageHandlerNames: [String] = []) {
        self.source = source
    }
}
public enum PluginScriptsUtil { public static let VAR_PLACEHOLDER_VALUE = "__placeholder__" }
public enum WindowIdJS {
    public static func WINDOW_ID_VARIABLE_JS_SOURCE() -> String {
        return "window._\\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_windowId"
    }
}
public enum WebMessageChannelJS {
    public static func WEB_MESSAGE_CHANNELS_VARIABLE_NAME() -> String { "window._webMessageChannels" }
}
public enum WebMessageListenerJS { public static func WEB_MESSAGE_LISTENER_JS_SOURCE() -> String { "" } }

@main struct Harness {
    static func main() {
        let bridge = JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_SOURCE()
            .replacingOccurrences(
                of: JavaScriptBridgeJS.VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET,
                with: "test-bridge-secret")
        let scroll = OnScrollChangedJS.ON_SCROLL_CHANGED_EVENT_JS_SOURCE()
        let value = try! JSONSerialization.data(withJSONObject: [bridge, scroll])
        print(String(data: value, encoding: .utf8)!)
    }
}
`;

const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'macos-scroll-bridge-'));
try {
  const harnessPath = path.join(tempDir, 'Harness.swift');
  const binaryPath = path.join(tempDir, 'generate-sources');
  fs.writeFileSync(harnessPath, harness);
  execFileSync('swiftc', [bridgePath, scrollPath, harnessPath, '-o', binaryPath], {
    stdio: 'inherit',
  });
  const [bridgeSource, scrollSource] = JSON.parse(execFileSync(binaryPath, { encoding: 'utf8' }));

  let timerCount = 0;
  let promiseCount = 0;
  let nextTimerId = 40;
  let nextFrameId = 1;
  const messages = [];
  const animationFrames = [];
  const canceledFrames = [];
  const listeners = {};
  const window = {
    JSON,
    Array,
    Function,
    Promise: class CountedPromise extends Promise {
      constructor(executor) {
        promiseCount += 1;
        super(executor);
      }
    },
    setTimeout() {
      timerCount += 1;
      return nextTimerId++;
    },
    requestAnimationFrame(callback) {
      const id = nextFrameId++;
      animationFrames.push({ id, callback });
      return id;
    },
    cancelAnimationFrame(id) {
      canceledFrames.push(id);
    },
    webkit: {
      messageHandlers: {
        callHandler: {
          postMessage(message) {
            messages.push(message);
          },
        },
      },
    },
    scrollX: 0,
    scrollY: 0,
    _flutter_inappwebview_windowId: 72,
    hidden: false,
    URLSearchParams,
    Symbol,
    Blob,
    FileReader: function FileReader() {},
    FormData,
    ArrayBuffer,
    DataView,
    Headers,
    Response,
  };
  window.window = window;
  window.top = window;
  window.addEventListener = (name, callback) => { listeners[name] = callback; };
  window.dispatchEvent = () => {};
  window.document = {
    hidden: false,
    addEventListener(name, callback) { listeners[`document:${name}`] = callback; },
  };

  vm.runInNewContext(`${bridgeSource}\n${scrollSource}`, window);
  assert.equal(typeof listeners['document:scroll'], 'function', 'scroll listener installed');

  for (const [x, y] of [[2, 3], [4, 5], [8, 13]]) {
    window.scrollX = x;
    window.scrollY = y;
    listeners['document:scroll']({});
  }
  assert.equal(animationFrames.length, 1, 'scroll burst schedules one animation frame');
  animationFrames.shift().callback();
  assert.equal(messages.length, 1, 'scroll burst sends one native message');
  assert.deepEqual(JSON.parse(messages[0].args), [{ x: 8, y: 13 }], 'frame sends latest coordinates');
  assert.equal(messages[0].handlerName, 'onScrollChanged');
  assert.equal(messages[0]._callHandlerOneWay, true);
  assert.equal(messages[0]._bridgeSecret, 'test-bridge-secret');
  assert.equal(messages[0]._windowId, 72, 'popup window ID is forwarded');
  assert.equal(timerCount, 0, 'internal scroll notification allocates no timeout');
  assert.equal(promiseCount, 0, 'internal scroll notification allocates no promise');

  listeners['document:scroll']({});
  animationFrames.shift().callback();
  assert.equal(messages.length, 1, 'unchanged coordinates are deduplicated');

  window.scrollX = 1.5;
  window.scrollY = -2.5;
  listeners['document:scroll']({});
  animationFrames.shift().callback();
  assert.deepEqual(JSON.parse(messages[1].args), [{ x: 1, y: -2 }],
    'fractional scroll offsets are deliberately truncated to public integer coordinates');

  window.scrollX = 21;
  window.scrollY = 22;
  listeners['document:scroll']({});
  const hiddenFrame = animationFrames[0];
  window.scrollX = 31;
  window.scrollY = 32;
  listeners['document:scroll']({});
  window.document.hidden = true;
  listeners['document:visibilitychange']();
  assert.deepEqual(JSON.parse(messages[2].args), [{ x: 31, y: 32 }],
    'visibility hidden flushes the latest pending coordinates');
  assert.ok(canceledFrames.includes(hiddenFrame.id), 'visibility hidden cancels the queued frame');
  assert.equal(animationFrames.shift(), hiddenFrame);
  hiddenFrame.callback();
  assert.equal(messages.length, 3, 'stale frame callback cannot send a duplicate');

  window.scrollX = 41.9;
  window.scrollY = 50.9;
  const queuedFrameCount = animationFrames.length;
  listeners['document:scroll']({});
  assert.equal(messages.length, 4, 'scroll while hidden sends immediately');
  assert.deepEqual(JSON.parse(messages[3].args), [{ x: 41, y: 50 }]);
  assert.equal(animationFrames.length, queuedFrameCount, 'hidden scroll does not await an animation frame');

  window.document.hidden = false;
  window.scrollX = 60;
  window.scrollY = 70;
  listeners['document:scroll']({});
  const pagehideFrame = animationFrames[0];
  listeners.pagehide();
  assert.deepEqual(JSON.parse(messages[4].args), [{ x: 60, y: 70 }],
    'pagehide flushes the latest pending coordinates');
  assert.ok(canceledFrames.includes(pagehideFrame.id), 'pagehide cancels the queued frame');
  assert.equal(animationFrames.shift(), pagehideFrame);
  pagehideFrame.callback();
  assert.equal(messages.length, 5, 'stale pagehide frame callback cannot send a duplicate');

  assert.equal(timerCount, 0, 'all internal scroll notifications avoid timeouts');
  assert.equal(promiseCount, 0, 'all internal scroll notifications avoid Promises');
  const normalCall = window.flutter_inappwebview.callHandler('userHandler', { ok: true });
  assert.ok(normalCall instanceof window.Promise, 'public callHandler still returns a Promise');
  assert.equal(timerCount, 1, 'public callHandler still allocates a callback ID');
  assert.equal(promiseCount, 1, 'public callHandler still allocates its Promise');
  assert.equal(messages.length, 6);
  assert.equal(messages[5].handlerName, 'userHandler');
  assert.equal(messages[5]._callHandlerID, 40);
  assert.equal(messages[5]._callHandlerOneWay, undefined, 'public envelope remains unchanged');

  const nativeSource = fs.readFileSync(nativePath, 'utf8');
  const secretCheck = nativeSource.indexOf('guard let bridgeSecret = body["_bridgeSecret"]');
  const originCheck = nativeSource.indexOf('if !isOriginAllowed {', secretCheck);
  const dispatch = nativeSource.indexOf('if message.name == "callHandler" {', originCheck);
  assert.ok(secretCheck >= 0 && secretCheck < originCheck && originCheck < dispatch,
    'native source keeps secret and origin gates before callHandler dispatch');
  const oneWayBranch = nativeSource.indexOf('if body["_callHandlerOneWay"] as? Bool == true {', dispatch);
  const resolveReply = nativeSource.indexOf('evaluateJavaScript("""', oneWayBranch);
  assert.ok(oneWayBranch > dispatch && oneWayBranch < resolveReply,
    'native source checks the one-way marker before internal Promise resolution');
  assert.match(nativeSource.slice(oneWayBranch, resolveReply), /return/,
    'marked internal notifications return without evaluating a Promise reply');
  assert.match(nativeSource, /windowWebViews\[wId\]/,
    'native source retains popup routing through _windowId');

  console.log('macOS scroll notification JavaScript regression and native source invariant checks passed');
} finally {
  fs.rmSync(tempDir, { recursive: true, force: true });
}
