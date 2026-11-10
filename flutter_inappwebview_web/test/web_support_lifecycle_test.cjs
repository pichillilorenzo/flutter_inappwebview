// Standalone Node regression for the bundled JavaScript, no Flutter SDK required.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

class EventTargetStub {
  constructor() { this.listeners = new Map(); }
  addEventListener(event, fn, options = {}) {
    if (!this.listeners.has(event)) this.listeners.set(event, new Set());
    this.listeners.get(event).add(fn);
    if (options.signal) {
      options.signal.addEventListener('abort', () => this.removeEventListener(event, fn),
        { once: true });
    }
  }
  removeEventListener(event, fn) { this.listeners.get(event)?.delete(fn); }
  dispatch(event) {
    for (const fn of [...(this.listeners.get(event) || [])]) fn({type:event});
  }
  count(event) { return this.listeners.get(event)?.size || 0; }
}

function harness() {
  const document = new EventTargetStub();
  document.fullscreenElement = null;
  const window = { Array, Function, JSON };
  const context = { window, document, AbortController, console };
  const js = fs.readFileSync(path.resolve(__dirname, '../lib/assets/web/web_support.js'), 'utf8');
  vm.runInNewContext(js, context, { filename: 'web_support.js' });
  const bridge = window.flutter_inappwebview_plugin;
  const events = [];
  bridge.nativeSyncCommunication = (method, id) => {
    events.push([method, id]);
    return 'null';
  };
  return { bridge, document, events };
}

test('reprepare adds one global listener and dispose removes it and iframe load', () => {
  const {bridge, document, events} = harness();
  const iframe = new EventTargetStub();
  iframe.id = 'web-view-1';
  const webView = bridge.createFlutterInAppWebView(1, iframe, {}, 'secret');
  webView.prepare({});
  webView.prepare({});
  assert.equal(document.count('fullscreenchange'), 1);
  assert.equal(iframe.count('load'), 1);

  document.fullscreenElement = {id:'web-view-1'};
  document.dispatch('fullscreenchange');
  assert.deepEqual(events, [['onEnterFullscreen', 1]]);

  webView.dispose();
  webView.dispose();
  assert.equal(document.count('fullscreenchange'), 0);
  assert.equal(iframe.count('load'), 0);
  assert.equal(webView.iframe, null);
  assert.equal(webView.iframeContainer, null);
  document.fullscreenElement = null;
  document.dispatch('fullscreenchange');
  assert.deepEqual(events, [['onEnterFullscreen', 1]]);
});

test('closing one WebView preserves the other WebView listener', () => {
  const {bridge, document, events} = harness();
  const a = new EventTargetStub(); a.id = 'old';
  const b = new EventTargetStub(); b.id = 'new';
  const oldView = bridge.createFlutterInAppWebView('old', a, {}, 'secret');
  const newView = bridge.createFlutterInAppWebView('new', b, {}, 'secret');
  oldView.prepare({});
  newView.prepare({});
  assert.equal(document.count('fullscreenchange'), 2);
  oldView.dispose();
  assert.equal(document.count('fullscreenchange'), 1);
  document.fullscreenElement = {id:'new'};
  document.dispatch('fullscreenchange');
  assert.deepEqual(events, [['onEnterFullscreen', 'new']]);
  newView.dispose();
  assert.equal(document.count('fullscreenchange'), 0);
});

test('rehosting an iframe delivers events only to its new owner', () => {
  const {bridge, document, events} = harness();
  const iframe = new EventTargetStub(); iframe.id = 'headless';
  const headless = bridge.createFlutterInAppWebView('headless', iframe, {}, 'secret');
  headless.prepare({});
  headless.dispose();

  iframe.id = 'visible';
  const visible = bridge.createFlutterInAppWebView('visible', iframe, {}, 'new-secret');
  visible.prepare({});
  headless.dispose();
  assert.equal(document.count('fullscreenchange'), 1);
  assert.equal(iframe.count('load'), 1);

  document.fullscreenElement = {id: 'visible'};
  document.dispatch('fullscreenchange');
  assert.deepEqual(events, [['onEnterFullscreen', 'visible']]);
  visible.dispose();
  assert.equal(document.count('fullscreenchange'), 0);
  assert.equal(iframe.count('load'), 0);
});
