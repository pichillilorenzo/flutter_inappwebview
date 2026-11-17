// Runs the production publisher on any Node host. The companion
// scroll_notification_bridge_test.js also compiles the Swift/bridge on macOS.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const sourcePath = path.join(__dirname,
  '../macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/PluginScriptsJS/OnScrollChangedJS.swift');
const swift = fs.readFileSync(sourcePath, 'utf8');
const body = swift.split('public static func ON_SCROLL_CHANGED_EVENT_JS_SOURCE() -> String {')[1];
assert.ok(body, 'test extracts the production source function');
const source = body.split('"""')[1]
  .replaceAll('\\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())', 'flutter_inappwebview');
assert.ok(!source.includes('\\('), 'all Swift interpolations are explicitly handled');

function document({ scrollX = 0, scrollY = 0, hidden = false } = {}) {
  const listeners = new Map();
  const frames = [];
  const messages = [];
  const canceled = [];
  let nextFrame = 1;
  function add(prefix, name, callback) {
    const key = prefix + name;
    if (!listeners.has(key)) listeners.set(key, new Set());
    listeners.get(key).add(callback);
  }
  function remove(prefix, name, callback) {
    listeners.get(prefix + name)?.delete(callback);
  }
  const window = {
    scrollX, scrollY,
    flutter_inappwebview: {
      _callHandlerOneWay(name, args) {
        messages.push({ name, ...args });
      },
    },
    addEventListener: (name, cb) => add('window:', name, cb),
    removeEventListener: (name, cb) => remove('window:', name, cb),
    requestAnimationFrame(callback) {
      const id = nextFrame++;
      frames.push({ id, callback });
      return id;
    },
    cancelAnimationFrame(id) { canceled.push(id); },
    document: {
      hidden,
      addEventListener: (name, cb) => add('document:', name, cb),
      removeEventListener: (name, cb) => remove('document:', name, cb),
    },
  };
  window.window = window;
  const context = vm.createContext(window);
  const inject = () => vm.runInContext(source, context);
  inject();
  function emit(name) {
    for (const listener of listeners.get(name) || []) listener();
  }
  function scroll(x, y) {
    window.scrollX = x;
    window.scrollY = y;
    emit('document:scroll');
  }
  return {
    window, listeners, frames, messages, canceled, inject, emit, scroll,
    enable: value => window.flutter_inappwebview._setScrollChangedListener(value),
    flush: () => frames.splice(0).forEach(frame => frame.callback()),
    count: name => listeners.get(name)?.size || 0,
  };
}

const page = document();
for (let i = 1; i <= 10000; i++) page.scroll(i, i * 2);
assert.equal(page.messages.length, 0, 'no subscription produces zero bridge messages');
assert.equal(page.frames.length, 0, 'no subscription schedules no scroll work');
assert.equal(page.count('document:scroll'), 0, 'the publisher starts detached');
page.enable(false);
page.inject();
assert.equal(page.count('document:scroll'), 0, 'reinjection does not subscribe');

page.enable(true);
page.enable(true);
page.inject();
page.enable(true);
for (const name of ['document:scroll', 'document:visibilitychange', 'window:pagehide']) {
  assert.equal(page.count(name), 1, `one ${name} listener after repeated enable/injection`);
}
for (let i = 1; i <= 10000; i++) page.scroll(i, i * 2);
assert.equal(page.frames.length, 1, 'existing animation-frame coalescing is preserved');
page.flush();
assert.deepEqual(page.messages, [{ name: 'onScrollChanged', x: 10000, y: 20000 }]);
page.scroll(10000, 20000);
page.flush();
assert.equal(page.messages.length, 1, 'unchanged final coordinates are deduplicated');

page.scroll(3.9, -4.9);
const staleFrame = page.frames.shift();
const staleScroll = [...page.listeners.get('document:scroll')][0];
page.enable(false);
assert.ok(page.canceled.includes(staleFrame.id));
for (const name of ['document:scroll', 'document:visibilitychange', 'window:pagehide']) {
  assert.equal(page.count(name), 0, `${name} is removed on disable`);
}
staleFrame.callback();
staleScroll();
page.emit('window:pagehide');
assert.equal(page.messages.length, 1, 'queued callbacks cannot publish after detach');
page.enable(true);
staleFrame.callback();
assert.equal(page.messages.length, 1, 'a stale frame cannot cross a subscription boundary');
page.scroll(3.9, -4.9);
page.flush();
assert.deepEqual(page.messages.at(-1), { name: 'onScrollChanged', x: 3, y: -4 },
  'programmatic and fractional coordinates keep the existing integer contract');

page.scroll(70, 80);
page.scroll(90, 100);
page.window.document.hidden = true;
page.emit('document:visibilitychange');
assert.deepEqual(page.messages.at(-1), { name: 'onScrollChanged', x: 90, y: 100 },
  'hiding a tab flushes the latest position');
const beforeStale = page.messages.length;
page.flush();
assert.equal(page.messages.length, beforeStale);
page.scroll(110, 120);
assert.deepEqual(page.messages.at(-1), { name: 'onScrollChanged', x: 110, y: 120 },
  'hidden programmatic scrolling does not wait for a throttled animation frame');
page.window.document.hidden = false;
page.scroll(130, 140);
page.emit('window:pagehide');
assert.deepEqual(page.messages.at(-1), { name: 'onScrollChanged', x: 130, y: 140 },
  'navigation flushes the final coordinates');
page.flush();

const popup = document();
popup.enable(false);
page.scroll(150, 160);
page.flush();
assert.equal(popup.messages.length, 0, 'a popup has independent subscription state');
popup.enable(true);
page.enable(false);
popup.scroll(1, 2);
popup.flush();
assert.deepEqual(popup.messages, [{ name: 'onScrollChanged', x: 1, y: 2 }],
  'detaching the parent does not detach the popup');
const navigation = document();
assert.equal(navigation.count('document:scroll'), 0, 'a new document begins detached');
navigation.enable(true);
navigation.scroll(4, 5);
navigation.flush();
assert.deepEqual(navigation.messages, [{ name: 'onScrollChanged', x: 4, y: 5 }]);

// A subscribed native WebView may navigate and restore its position before
// didCommit/didFinish asynchronously enables the new document's publisher.
// No second scroll event is guaranteed after that policy arrives.
const earlyNavigation = document();
earlyNavigation.scroll(42, 280);
earlyNavigation.flush();
assert.equal(earlyNavigation.messages.length, 0);
assert.equal(earlyNavigation.frames.length, 0);
assert.equal(earlyNavigation.count('document:scroll'), 0);
earlyNavigation.enable(true);
assert.equal(earlyNavigation.frames.length, 1,
  'activation reconciles movement that happened before the document got its policy');
earlyNavigation.flush();
assert.deepEqual(earlyNavigation.messages, [{ name: 'onScrollChanged', x: 42, y: 280 }]);
earlyNavigation.enable(true);
earlyNavigation.inject();
earlyNavigation.enable(true);
assert.equal(earlyNavigation.frames.length, 0, 'repeated native enable does not replay a position');
assert.equal(earlyNavigation.messages.length, 1);

for (const coordinates of [{ scrollX: 0, scrollY: 0 }, { scrollX: 13.9, scrollY: -20.9 }]) {
  const unchanged = document(coordinates);
  unchanged.enable(true);
  assert.equal(unchanged.frames.length, 0, 'initial activation schedules no unchanged-position work');
  unchanged.flush();
  assert.equal(unchanged.messages.length, 0, 'attaching at the initial position is silent');
  assert.equal(unchanged.canceled.length, 0);
  unchanged.enable(false);
  unchanged.enable(true);
  assert.equal(unchanged.frames.length, 0,
    'unchanged zero and nonzero positions do not schedule reattachment work');
  unchanged.flush();
  assert.equal(unchanged.messages.length, 0);
}

earlyNavigation.enable(false);
earlyNavigation.enable(true);
assert.equal(earlyNavigation.frames.length, 0, 'reattaching does not repeat the last delivered position');
earlyNavigation.enable(false);
earlyNavigation.scroll(0, 0);
assert.equal(earlyNavigation.frames.length, 0, 'detached movement schedules no work');
assert.equal(earlyNavigation.messages.length, 1);
earlyNavigation.enable(true);
earlyNavigation.flush();
assert.deepEqual(earlyNavigation.messages.at(-1), { name: 'onScrollChanged', x: 0, y: 0 },
  'returning to zero while detached is a real change, not an initial-zero notification');
assert.equal(earlyNavigation.messages.length, 2);

const pendingAttachment = document();
pendingAttachment.enable(true);
pendingAttachment.scroll(9, 8);
const canceledAttachmentFrame = pendingAttachment.frames.shift();
pendingAttachment.enable(false);
pendingAttachment.scroll(11, 12);
pendingAttachment.enable(true);
assert.equal(pendingAttachment.frames.length, 1);
canceledAttachmentFrame.callback();
assert.equal(pendingAttachment.messages.length, 0,
  'an old frame cannot flush the new attachment\'s reconciled position');
pendingAttachment.flush();
assert.deepEqual(pendingAttachment.messages, [{ name: 'onScrollChanged', x: 11, y: 12 }]);

const hiddenNavigation = document({ hidden: true });
hiddenNavigation.scroll(35.8, -77.9);
hiddenNavigation.enable(true);
assert.equal(hiddenNavigation.frames.length, 0, 'hidden activation does not wait for a throttled frame');
assert.deepEqual(hiddenNavigation.messages, [{ name: 'onScrollChanged', x: 35, y: -77 }]);
hiddenNavigation.enable(true);
assert.equal(hiddenNavigation.messages.length, 1);

for (let attempt = 0; attempt < 3; attempt++) {
  const restoredDocument = document();
  restoredDocument.scroll(42, 280);
  restoredDocument.enable(true);
  restoredDocument.flush();
  restoredDocument.enable(true);
  restoredDocument.emit('window:pagehide');
  assert.deepEqual(restoredDocument.messages, [{ name: 'onScrollChanged', x: 42, y: 280 }],
    'each navigation reconciles its own final position exactly once');
}

const waitingParent = document();
const waitingPopup = document();
waitingParent.scroll(20, 30);
waitingPopup.scroll(40, 50);
waitingParent.enable(true);
waitingParent.flush();
assert.equal(waitingPopup.frames.length, 0);
assert.equal(waitingPopup.messages.length, 0, 'a parent policy cannot enable the waiting popup');
waitingPopup.enable(true);
waitingParent.enable(false);
waitingPopup.flush();
assert.deepEqual(waitingParent.messages, [{ name: 'onScrollChanged', x: 20, y: 30 }]);
assert.deepEqual(waitingPopup.messages, [{ name: 'onScrollChanged', x: 40, y: 50 }],
  'popup activation reconciles only that document\'s coordinates');

console.log('Production macOS scroll publisher: gating, lifecycle and final-coordinate tests passed');
