// Fast source invariants shared with the full Swift/JavaScript harnesses.
// These checks do not compile Swift or replace native authorization/one-way tests.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

function assertHandlerAuthorization(nativeSource) {
  const routeStart = nativeSource.indexOf('func handleScriptMessage(');
  const ownerCheck = nativeSource.indexOf('guard let webView = message.webView as? InAppWebView', routeStart);
  const secretCheck = nativeSource.indexOf('guard let bridgeSecret = body["_bridgeSecret"]', ownerCheck);
  const originCheck = nativeSource.indexOf('guard isOriginAllowed else {', secretCheck);
  const dispatch = nativeSource.indexOf('if message.name == "callHandler" || message.name == "callHandlerWithReply" {', originCheck);
  assert.ok(routeStart >= 0 && ownerCheck > routeStart && secretCheck > ownerCheck &&
    originCheck > secretCheck && dispatch > originCheck,
    'both transports authorize the native sender, secret and origin before handler dispatch');
  const authorization = nativeSource.slice(ownerCheck, dispatch);
  assert.match(authorization, /webView\.configuration\.userContentController === userContentController/,
    'the sender belongs to the receiving controller');
  assert.match(nativeSource.slice(secretCheck, originCheck),
    /bridgeSecret == userContentController\.javaScriptBridgeSecret else \{\s*reply\?\.fail\([^\n]+\)\s*return\s*\}/,
    'a mismatched shared bridge secret returns before handler dispatch');
  assert.match(authorization, /webView\.settings\?\.javaScriptHandlersOriginAllowList/,
    'origin authorization uses the actual sender settings');
  assert.match(nativeSource.slice(originCheck, dispatch), /guard isOriginAllowed else \{\s*reply\?\.fail\([^\n]+\)\s*return\s*\}/,
    'denied origins return before application or internal handler dispatch');
  assert.match(authorization, /suppliedWindowId != webView\.windowId/,
    'a supplied popup ID must agree with the native sender');
  assert.doesNotMatch(authorization, /windowWebViews\[/,
    'a JavaScript window ID cannot select a different native owner');
}

function assertInternalOneWay(nativeSource) {
  const route = nativeSource.indexOf('func handleScriptMessage(');
  const start = nativeSource.indexOf('            if isInternalHandler {', route);
  const end = nativeSource.indexOf('            let args = body["args"]', start);
  assert.ok(route >= 0 && start > route && end > start, 'find the complete internal reply branch');
  assert.match(nativeSource.slice(start, end),
    /if body\["_callHandlerOneWay"\] as\? Bool == true \{\s*return\s*\}\s*webView\.evaluateJavaScript/,
    'internal one-way calls return before the owning view evaluates a Promise reply');
}

if (require.main === module) {
  for (const platform of ['ios', 'macos']) {
    const native = fs.readFileSync(path.join(__dirname, '..', 'flutter_inappwebview_' + platform,
      platform, 'flutter_inappwebview_' + platform, 'Sources', 'flutter_inappwebview_' + platform,
      'InAppWebView/InAppWebView.swift'), 'utf8');
    assertHandlerAuthorization(native);
    assertInternalOneWay(native);
    const mutations = [
      [native.replace('guard let webView = message.webView as? InAppWebView',
        'guard let webView = self as? InAppWebView'), assertHandlerAuthorization],
      [native.replace('bridgeSecret == userContentController.javaScriptBridgeSecret',
        'true'), assertHandlerAuthorization],
      [native.replace('guard isOriginAllowed else {', 'guard true else {'), assertHandlerAuthorization],
      [native.replace('webView.settings?.javaScriptHandlersOriginAllowList',
        'self.settings?.javaScriptHandlersOriginAllowList'), assertHandlerAuthorization],
      [native.replace(/(if body\["_callHandlerOneWay"\] as\? Bool == true \{)\s*return/,
        '$1 print("missing early return")'), assertInternalOneWay],
    ];
    for (const [mutated, check] of mutations) {
      assert.notEqual(mutated, native, 'the negative check must alter the production source');
      assert.throws(() => check(mutated), assert.AssertionError,
        'removing a protection must fail the shared source invariant');
    }
    console.log(platform + ': shared native source authorization/one-way checks and five negative mutations passed');
  }
}

module.exports = {assertHandlerAuthorization, assertInternalOneWay};
