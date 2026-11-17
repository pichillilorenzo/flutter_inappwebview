// Execute the production Apple bootstrap in V8. Native authorization/lifetime
// and live WKWebView/Flutter acceptance have separate harnesses and CI jobs.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {performance} = require('node:perf_hooks');
const fixtures = require('./javascript_handler_json_cases.json');
const root = path.resolve(__dirname, '..');

function bootstrap(platform) {
  const file = path.join(root, `flutter_inappwebview_${platform}/${platform}/flutter_inappwebview_${platform}/Sources/flutter_inappwebview_${platform}/PluginScriptsJS/JavaScriptBridgeJS.swift`);
  const swift = fs.readFileSync(file, 'utf8');
  const start = swift.indexOf('            window.\\(get_JAVASCRIPT_BRIDGE_NAME()) = ');
  const end = swift.indexOf('            \\(WebMessageListenerJS.WEB_MESSAGE_LISTENER_JS_SOURCE())', start);
  const js = swift.slice(start, end)
    .replaceAll('\\(get_JAVASCRIPT_BRIDGE_NAME())', 'flutter_inappwebview')
    .replaceAll('\\(VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET)', 'test-secret')
    .replaceAll('\\(WebMessageChannelJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME())', 'window.flutter_inappwebview._webMessageChannels')
    .replaceAll('\\(WindowIdJS.WINDOW_ID_VARIABLE_JS_SOURCE())', 'window._windowId');
  assert.ok(start >= 0 && end > start && !js.includes('\\('), 'extract the actual bootstrap');
  return js;
}

let nextDocumentID = 0;
function document(js, options = {}) {
  const documentID = ++nextDocumentID;
  const nativePolicy = value => value === 'true' ? `enabled:document-${documentID}` : value;
  let nextID = 0;
  const stats = {probes: 0, replyRPCs: 0, legacyRPCs: 0, oneWay: 0, cancels: 0, legacyEvaluations: 0, probeTimersStarted: 0, probeTimersCleared: 0};
  const listeners = {};
  const pending = [];
  const pendingProbes = [];
  const probeTimers = new Map();
  const received = [];
  const window = {JSON, Array, Function, Promise, _windowId: options.windowId,
    setTimeout(callback, delay) {
      const id = ++nextID;
      if (delay) { stats.probeTimersStarted++; probeTimers.set(id, callback); }
      return id;
    },
    clearTimeout(id) { if (probeTimers.delete(id)) stats.probeTimersCleared++; },
    addEventListener(name, fn) { (listeners[name] ||= []).push(fn); },
    webkit: {messageHandlers: {}}};
  window.top = options.top || window;
  const rawResult = body => options.rawResult ? options.rawResult(body) : JSON.parse(body.args)[0];
  window.webkit.messageHandlers.callHandler = {postMessage(body) {
    if (body._bridgeReplyCancelDocument) { stats.cancels++; received.push(body); return; }
    if (body._callHandlerOneWay) { stats.oneWay++; received.push(body); return; }
    stats.legacyRPCs++;
    received.push(body);
    queueMicrotask(() => {
      stats.legacyEvaluations++;
      const entry = window.top.flutter_inappwebview[body._callHandlerID];
      if (!entry) return;
      try { entry.resolve(JSON.parse(rawResult(body))); } catch (error) { entry.reject(error); }
      delete window.top.flutter_inappwebview[body._callHandlerID];
    });
  }};
  function installReply() {
    window.webkit.messageHandlers.callHandlerWithReply = {postMessage(body) {
      if (body._bridgeReplyProbe) {
        stats.probes++;
        if (options.holdPolicy) return new Promise((resolve, reject) => pendingProbes.push({resolve: value => resolve(nativePolicy(value)), reject}));
        if (options.policyError) return Promise.reject(new Error(options.policyError));
        return Promise.resolve(nativePolicy(typeof options.policy === 'function' ? options.policy() : options.policy || 'true'));
      }
      stats.replyRPCs++;
      received.push(body);
      if (options.throwAfterAccept) throw new Error('accepted then threw');
      if (options.nonPromise) return undefined;
      if (options.replyError) return Promise.reject(new Error(options.replyError));
      if (options.hold) return new Promise((resolve, reject) => pending.push({resolve, reject, body}));
      return Promise.resolve(rawResult(body));
    }};
  }
  if (options.replyAvailable !== false) installReply();
  const context = vm.createContext({window, Date, Math, Error});
  const inject = () => vm.runInContext(js, context);
  inject();
  return {window, stats, received, pending, pendingProbes, probeTimers, inject, installReply,
    expireProbe() { for (const callback of [...probeTimers.values()]) callback(); },
    call: (...args) => window.flutter_inappwebview.callHandler(...args),
    event: name => (listeners[name] || []).forEach(fn => fn()),
    removeReply() { delete window.webkit.messageHandlers.callHandlerWithReply; }};
}
const flush = async () => { await Promise.resolve(); await Promise.resolve(); };

async function parity(platform) {
  const js = bootstrap(platform);
  const disabled = document(js, {replyAvailable: false});
  await disabled.call('echo', '{"default":true}');
  disabled.inject();
  await disabled.call('echo', 'null');
  assert.deepEqual(disabled.stats, {probes: 0, replyRPCs: 0, legacyRPCs: 2, oneWay: 0, cancels: 0, legacyEvaluations: 2, probeTimersStarted: 0, probeTimersCleared: 0}, 'default OFF / old OS adds no bridge traffic');

  const optedOut = document(js, {policy: 'false'});
  await flush();
  await optedOut.call('echo', 'true');
  optedOut.inject();
  await optedOut.call('echo', 'false');
  assert.equal(optedOut.stats.probes, 1);
  assert.equal(optedOut.stats.replyRPCs, 0, 'disabled popup never inherits enabled parent policy');

  const modern = document(js);
  const early = modern.call('echo', '{"early":1}');
  assert.equal(modern.stats.legacyRPCs + modern.stats.replyRPCs, 0, 'capability is chosen before any application dispatch');
  await early;
  await flush();
  for (const raw of [...fixtures.valid, JSON.stringify({text: 'עברית 😀\u2028\u2029'.repeat(50000)})]) {
    const result = await modern.call('echo', raw);
    assert.equal(JSON.stringify(result), JSON.stringify(JSON.parse(raw)));
    if (result && typeof result === 'object' && Object.hasOwn(JSON.parse(raw), '__proto__')) {
      assert.ok(Object.hasOwn(result, '__proto__'));
      assert.equal(result.inherited, undefined);
    }
  }
  for (const raw of fixtures.invalid) await assert.rejects(modern.call('echo', raw));
  assert.equal(modern.window.injected, undefined, 'JSON is data, including dangerous-looking strings');
  assert.equal(modern.stats.legacyRPCs, 0, 'first call and invalid replies never redispatch');
  assert.equal(modern.stats.legacyEvaluations, 0);
  const before = {...modern.stats};
  modern.window.flutter_inappwebview._callHandlerOneWay('onConsoleMessage', {message: 'one way'});
  assert.equal(modern.stats.oneWay, before.oneWay + 1);
  assert.equal(modern.stats.replyRPCs, before.replyRPCs);
  modern.inject();
  await modern.call('echo', '42');
  assert.equal(modern.stats.probes, 1, 'reinjection preserves policy and callbacks');

  for (const options of [{throwAfterAccept: true}, {replyError: 'ERR, quotes \'" \\ and עברית\u2028'}, {nonPromise: true}, {rawResult: () => ({bad: 'native type'})}]) {
    const doc = document(js, options);
    await flush();
    await assert.rejects(doc.call('echo', 'null'));
    assert.equal(doc.stats.replyRPCs, 1);
    assert.equal(doc.stats.legacyRPCs, 0, 'accepted request is never repeated on the legacy route');
  }
  const internal = document(js, {rawResult: () => undefined});
  await flush();
  assert.equal(await internal.call('internal'), undefined, 'internal handlers preserve undefined');

  // Frames/worlds have separate closures and WebKit reply Promises, including
  // a cross-origin frame whose top cannot be accessed by the legacy bridge.
  const concurrent = Array.from({length: 4}, (_, index) => document(js, {hold: true, windowId: index || undefined, top: new Proxy({}, {get() { throw new Error('cross-origin'); }})}));
  await flush();
  const all = concurrent.flatMap((doc, index) => Array.from({length: 64}, (_, n) => doc.call('echo', JSON.stringify({index, n}))));
  for (const doc of [...concurrent].reverse()) for (const request of [...doc.pending].reverse()) request.resolve(JSON.parse(request.body.args)[0]);
  const values = await Promise.all(all);
  assert.deepEqual(JSON.parse(JSON.stringify(values)), Array.from({length: 4}, (_, index) => Array.from({length: 64}, (_, n) => ({index, n}))).flat());
  for (const doc of concurrent) assert.equal(doc.stats.legacyRPCs, 0);

  let attached = false;
  const popup = document(js, {policy: () => attached ? 'true' : 'pending', windowId: 9});
  await flush();
  attached = true;
  assert.equal(await popup.call('echo', '7'), 7); // retry only the policy before dispatching the RPC
  await flush();
  assert.equal(await popup.call('echo', '8'), 8);
  assert.equal(popup.stats.probes, 2);
  assert.equal(popup.stats.legacyRPCs, 0);
  assert.equal(popup.stats.replyRPCs, 2);

  const lateOwner = document(js, {replyAvailable: false, windowId: 10});
  lateOwner.installReply();
  await lateOwner.call('echo', '1');
  await flush();
  await lateOwner.call('echo', '2');
  assert.equal(lateOwner.stats.replyRPCs, 2, 'enabled popup discovers handler installed after bootstrap');
  lateOwner.removeReply();
  await lateOwner.call('echo', '3');
  assert.equal(lateOwner.stats.legacyRPCs, 1, 'last owner removal is detected before dispatch');

  const navigating = document(js, {hold: true});
  await flush();
  const pending = navigating.call('echo', '1');
  navigating.inject();
  navigating.event('pagehide');
  assert.equal(navigating.stats.cancels, 1);
  assert.ok(navigating.received.at(-1)._bridgeReplyCancelDocument);
  navigating.pending[0].reject(new Error('JavaScript bridge frame navigated'));
  await assert.rejects(pending, /frame navigated/);
  await assert.rejects(navigating.call('echo', '2'), /unloading/);
  assert.equal(navigating.stats.replyRPCs, 1);
  assert.equal(navigating.stats.legacyRPCs, 0);
  navigating.event('pageshow');
  const restored = navigating.call('echo', '3');
  navigating.pending.at(-1).resolve('3');
  assert.equal(await restored, 3);

  const timedOut = document(js, {holdPolicy: true});
  const first = timedOut.call('echo', '17');
  assert.equal(timedOut.stats.legacyRPCs + timedOut.stats.replyRPCs, 0);
  timedOut.expireProbe();
  assert.equal(await first, 17, 'timeout selects fallback before application dispatch');
  timedOut.pendingProbes[0].resolve('true');
  await flush();
  assert.equal(await timedOut.call('echo', '18'), 18);
  assert.equal(timedOut.stats.replyRPCs, 0, 'late policy cannot enable transport after timeout');
  assert.equal(timedOut.stats.legacyRPCs, 2);
  assert.equal(timedOut.stats.probes, 1);
  assert.equal(timedOut.probeTimers.size, 0);

  const abandoned = document(js, {holdPolicy: true});
  const waiting = abandoned.call('echo', '19');
  abandoned.event('pagehide');
  await assert.rejects(waiting, /unloading/);
  abandoned.pendingProbes[0].resolve('true');
  await flush();
  assert.equal(abandoned.stats.legacyRPCs + abandoned.stats.replyRPCs, 0);
  assert.equal(abandoned.probeTimers.size, 0, 'navigation clears the probe timer');
  abandoned.event('pageshow');
  const fresh = abandoned.call('echo', '20');
  abandoned.pendingProbes[1].resolve('true');
  assert.equal(await fresh, 20, 'restored document can perform a fresh policy check');

  const notReady = document(js, {policy: 'pending'});
  await assert.rejects(notReady.call('echo', '1'), /owner is not ready/);
  assert.equal(notReady.stats.legacyRPCs + notReady.stats.replyRPCs, 0, 'uncreated owner cannot leave an RPC waiting');
  assert.equal(notReady.probeTimers.size, 0);
  const policyDenied = document(js, {policyError: 'origin denied'});
  await assert.rejects(policyDenied.call('echo', '1'), /origin denied/);
  assert.equal(policyDenied.stats.legacyRPCs + policyDenied.stats.replyRPCs, 0);
  assert.equal(policyDenied.probeTimers.size, 0);

  const pendingLegacy = document(js, {replyAvailable: false});
  const legacy = pendingLegacy.call('echo', '123');
  pendingLegacy.inject();
  assert.equal(await legacy, 123, 'reinjection retains pending legacy resolutions');
  console.log(`${platform}: production JS parity, 256 concurrent replies, isolation, no-retry, bootstrap, lifecycle and default-OFF passed`);
}

async function benchmark() {
  const js = bootstrap('macos');
  const records = [];
  for (const bytes of [64, 65536, 1048576]) {
    const raw = JSON.stringify({text: 'x'.repeat(bytes)});
    for (const mode of ['legacy', 'reply']) {
      const bootstrapStart = performance.now();
      const doc = document(js, {replyAvailable: mode === 'reply'});
      const firstStart = performance.now();
      await doc.call('echo', raw);
      const firstCallMs = performance.now() - firstStart;
      const bootstrapAndFirstCallMs = performance.now() - bootstrapStart;
      const startupTransitions = {...doc.stats};
      const samples = [];
      const count = bytes > 1000000 ? 100 : 500;
      for (let i = 0; i < count; i++) {
        const start = performance.now();
        await doc.call('echo', raw);
        samples.push(performance.now() - start);
      }
      samples.sort((a, b) => a - b);
      records.push({mode, payloadBytes: Buffer.byteLength(raw), calls: count, firstCallMs, bootstrapAndFirstCallMs, startupTransitions, probeDeadlineMs: 1000, medianMs: samples[Math.floor(count / 2)], p95Ms: samples[Math.floor(count * .95)], harnessTransitions: doc.stats});
    }
  }
  console.log(JSON.stringify({kind: 'V8 production-JS harness; no WebKit/Flutter/native CPU or allocation measurements', runtime: process.version, platform: process.platform, nativeMainThreadMs: null, nativeAllocations: null, records}, null, 2));
}

if (require.main === module) {
  (async () => {
    if (process.argv.includes('--benchmark')) await benchmark();
    else for (const platform of ['ios', 'macos']) await parity(platform);
  })().catch(error => { console.error(error); process.exitCode = 1; });
}
module.exports = {bootstrap, document};
