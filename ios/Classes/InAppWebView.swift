//
//  InAppWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 21/10/18.
//

import Flutter
import Foundation
import WebKit

func currentTimeInMilliSeconds() -> Int64 {
    let currentDate = Date()
    let since1970 = currentDate.timeIntervalSince1970
    return Int64(since1970 * 1000)
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func JSONStringify(value: Any, prettyPrinted: Bool = false) -> String {
    let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : .init(rawValue: 0)
    if JSONSerialization.isValidJSONObject(value) {
        let data = try? JSONSerialization.data(withJSONObject: value, options: options)
        if data != nil {
            if let string = String(data: data!, encoding: .utf8) {
                return string
            }
        }
    }
    return ""
}

let JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview"

// https://github.com/tildeio/rsvp.js
let promisePolyfillJS = """
if (window.Promise == null) {
    !function(t,e){"object"==typeof exports&&"undefined"!=typeof module?e(exports):"function"==typeof define&&define.amd?define(["exports"],e):e(t.RSVP={})}(this,function(t){"use strict";function e(t){var e=t._promiseCallbacks;return e||(e=t._promiseCallbacks={}),e}var r={mixin:function(t){return t.on=this.on,t.off=this.off,t.trigger=this.trigger,t._promiseCallbacks=void 0,t},on:function(t,r){if("function"!=typeof r)throw new TypeError("Callback must be a function");var n=e(this),o=n[t];o||(o=n[t]=[]),-1===o.indexOf(r)&&o.push(r)},off:function(t,r){var n=e(this);if(r){var o=n[t],i=o.indexOf(r);-1!==i&&o.splice(i,1)}else n[t]=[]},trigger:function(t,r,n){var o=e(this)[t];if(o)for(var i=0;i<o.length;i++)(0,o[i])(r,n)}},n={instrument:!1};function o(t,e){if(2!==arguments.length)return n[t];n[t]=e}r.mixin(n);var i=[];function s(t,e,r){1===i.push({name:t,payload:{key:e._guidKey,id:e._id,eventName:t,detail:e._result,childId:r&&r._id,label:e._label,timeStamp:Date.now(),error:n["instrument-with-stack"]?new Error(e._label):null}})&&setTimeout(function(){for(var t=0;t<i.length;t++){var e=i[t],r=e.payload;r.guid=r.key+r.id,r.childGuid=r.key+r.childId,r.error&&(r.stack=r.error.stack),n.trigger(e.name,e.payload)}i.length=0},50)}function u(t,e){if(t&&"object"==typeof t&&t.constructor===this)return t;var r=new this(c,e);return m(r,t),r}function c(){}var a=void 0,f=1,l=2,h={error:null};function p(t){try{return t.then}catch(t){return h.error=t,h}}var y=void 0;function _(){try{var t=y;return y=null,t.apply(this,arguments)}catch(t){return h.error=t,h}}function v(t){return y=t,_}function d(t,e,r){if(e.constructor===t.constructor&&r===A&&t.constructor.resolve===u)!function(t,e){e._state===f?b(t,e._result):e._state===l?(e._onError=null,g(t,e._result)):j(e,void 0,function(r){e===r?b(t,r):m(t,r)},function(e){return g(t,e)})}(t,e);else if(r===h){var o=h.error;h.error=null,g(t,o)}else"function"==typeof r?function(t,e,r){n.async(function(t){var n=!1,o=v(r).call(e,function(r){n||(n=!0,e===r?b(t,r):m(t,r))},function(e){n||(n=!0,g(t,e))},"Settle: "+(t._label||" unknown promise"));if(!n&&o===h){n=!0;var i=h.error;h.error=null,g(t,i)}},t)}(t,e,r):b(t,e)}function m(t,e){var r,n;t===e?b(t,e):(n=typeof(r=e),null===r||"object"!==n&&"function"!==n?b(t,e):d(t,e,p(e)))}function w(t){t._onError&&t._onError(t._result),O(t)}function b(t,e){t._state===a&&(t._result=e,t._state=f,0===t._subscribers.length?n.instrument&&s("fulfilled",t):n.async(O,t))}function g(t,e){t._state===a&&(t._state=l,t._result=e,n.async(w,t))}function j(t,e,r,o){var i=t._subscribers,s=i.length;t._onError=null,i[s]=e,i[s+f]=r,i[s+l]=o,0===s&&t._state&&n.async(O,t)}function O(t){var e=t._subscribers,r=t._state;if(n.instrument&&s(r===f?"fulfilled":"rejected",t),0!==e.length){for(var o=void 0,i=void 0,u=t._result,c=0;c<e.length;c+=3)o=e[c],i=e[c+r],o?E(r,o,i,u):i(u);t._subscribers.length=0}}function E(t,e,r,n){var o="function"==typeof r,i=void 0;if(i=o?v(r)(n):n,e._state!==a);else if(i===e)g(e,new TypeError("A promises callback cannot return that same promise."));else if(i===h){var s=h.error;h.error=null,g(e,s)}else o?m(e,i):t===f?b(e,i):t===l&&g(e,i)}function A(t,e,r){var o=this._state;if(o===f&&!t||o===l&&!e)return n.instrument&&s("chained",this,this),this;this._onError=null;var i=new this.constructor(c,r),u=this._result;if(n.instrument&&s("chained",this,i),o===a)j(this,i,t,e);else{var h=o===f?t:e;n.async(function(){return E(o,i,h,u)})}return i}var T=function(){function t(t,e,r,n){this._instanceConstructor=t,this.promise=new t(c,n),this._abortOnReject=r,this._isUsingOwnPromise=t===k,this._isUsingOwnResolve=t.resolve===u,this._init.apply(this,arguments)}return t.prototype._init=function(t,e){var r=e.length||0;this.length=r,this._remaining=r,this._result=new Array(r),this._enumerate(e)},t.prototype._enumerate=function(t){for(var e=this.length,r=this.promise,n=0;r._state===a&&n<e;n++)this._eachEntry(t[n],n,!0);this._checkFullfillment()},t.prototype._checkFullfillment=function(){if(0===this._remaining){var t=this._result;b(this.promise,t),this._result=null}},t.prototype._settleMaybeThenable=function(t,e,r){var n=this._instanceConstructor;if(this._isUsingOwnResolve){var o=p(t);if(o===A&&t._state!==a)t._onError=null,this._settledAt(t._state,e,t._result,r);else if("function"!=typeof o)this._settledAt(f,e,t,r);else if(this._isUsingOwnPromise){var i=new n(c);d(i,t,o),this._willSettleAt(i,e,r)}else this._willSettleAt(new n(function(e){return e(t)}),e,r)}else this._willSettleAt(n.resolve(t),e,r)},t.prototype._eachEntry=function(t,e,r){null!==t&&"object"==typeof t?this._settleMaybeThenable(t,e,r):this._setResultAt(f,e,t,r)},t.prototype._settledAt=function(t,e,r,n){var o=this.promise;o._state===a&&(this._abortOnReject&&t===l?g(o,r):(this._setResultAt(t,e,r,n),this._checkFullfillment()))},t.prototype._setResultAt=function(t,e,r,n){this._remaining--,this._result[e]=r},t.prototype._willSettleAt=function(t,e,r){var n=this;j(t,void 0,function(t){return n._settledAt(f,e,t,r)},function(t){return n._settledAt(l,e,t,r)})},t}();function P(t,e,r){this._remaining--,this._result[e]=t===f?{state:"fulfilled",value:r}:{state:"rejected",reason:r}}var S="rsvp_"+Date.now()+"-",R=0;var k=function(){function t(e,r){this._id=R++,this._label=r,this._state=void 0,this._result=void 0,this._subscribers=[],n.instrument&&s("created",this),c!==e&&("function"!=typeof e&&function(){throw new TypeError("You must pass a resolver function as the first argument to the promise constructor")}(),this instanceof t?function(t,e){var r=!1;try{e(function(e){r||(r=!0,m(t,e))},function(e){r||(r=!0,g(t,e))})}catch(e){g(t,e)}}(this,e):function(){throw new TypeError("Failed to construct 'Promise': Please use the 'new' operator, this object constructor cannot be called as a function.")}())}return t.prototype._onError=function(t){var e=this;n.after(function(){e._onError&&n.trigger("error",t,e._label)})},t.prototype.catch=function(t,e){return this.then(void 0,t,e)},t.prototype.finally=function(t,e){var r=this.constructor;return"function"==typeof t?this.then(function(e){return r.resolve(t()).then(function(){return e})},function(e){return r.resolve(t()).then(function(){throw e})}):this.then(t,t)},t}();function x(t,e){return{then:function(r,n){return t.call(e,r,n)}}}function M(t,e){var r=function(){for(var r=arguments.length,n=new Array(r+1),o=!1,i=0;i<r;++i){var s=arguments[i];if(!o){if((o=F(s))===h){var u=h.error;h.error=null;var a=new k(c);return g(a,u),a}o&&!0!==o&&(s=x(o,s))}n[i]=s}var f=new k(c);return n[r]=function(t,r){t?g(f,t):void 0===e?m(f,r):!0===e?m(f,function(t){for(var e=t.length,r=new Array(e-1),n=1;n<e;n++)r[n-1]=t[n];return r}(arguments)):Array.isArray(e)?m(f,function(t,e){for(var r={},n=t.length,o=new Array(n),i=0;i<n;i++)o[i]=t[i];for(var s=0;s<e.length;s++)r[e[s]]=o[s+1];return r}(arguments,e)):m(f,r)},o?function(t,e,r,n){return k.all(e).then(function(e){return C(t,e,r,n)})}(f,n,t,this):C(f,n,t,this)};return r.__proto__=t,r}function C(t,e,r,n){if(v(r).apply(n,e)===h){var o=h.error;h.error=null,g(t,o)}return t}function F(t){return null!==t&&"object"==typeof t&&(t.constructor===k||p(t))}function I(t,e){return k.all(t,e)}k.cast=u,k.all=function(t,e){return Array.isArray(t)?new T(this,t,!0,e).promise:this.reject(new TypeError("Promise.all must be called with an array"),e)},k.race=function(t,e){var r=new this(c,e);if(!Array.isArray(t))return g(r,new TypeError("Promise.race must be called with an array")),r;for(var n=0;r._state===a&&n<t.length;n++)j(this.resolve(t[n]),void 0,function(t){return m(r,t)},function(t){return g(r,t)});return r},k.resolve=u,k.reject=function(t,e){var r=new this(c,e);return g(r,t),r},k.prototype._guidKey=S,k.prototype.then=A;var N=function(t){function e(e,r,n){return function(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}(this,t.call(this,e,r,!1,n))}return function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}(e,t),e}(T);function U(t,e){return Array.isArray(t)?new N(k,t,e).promise:k.reject(new TypeError("Promise.allSettled must be called with an array"),e)}function D(t,e){return k.race(t,e)}N.prototype._setResultAt=P;var K=function(t){function e(e,r){var n=!(arguments.length>2&&void 0!==arguments[2])||arguments[2],o=arguments[3];return function(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}(this,t.call(this,e,r,n,o))}return function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}(e,t),e.prototype._init=function(t,e){this._result={},this._enumerate(e)},e.prototype._enumerate=function(t){var e=Object.keys(t),r=e.length,n=this.promise;this._remaining=r;for(var o=void 0,i=void 0,s=0;n._state===a&&s<r;s++)i=t[o=e[s]],this._eachEntry(i,o,!0);this._checkFullfillment()},e}(T);function q(t,e){return k.resolve(t,e).then(function(t){if(null===t||"object"!=typeof t)throw new TypeError("Promise.hash must be called with an object");return new K(k,t,e).promise})}var G=function(t){function e(e,r,n){return function(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}(this,t.call(this,e,r,!1,n))}return function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}(e,t),e}(K);function L(t,e){return k.resolve(t,e).then(function(t){if(null===t||"object"!=typeof t)throw new TypeError("hashSettled must be called with an object");return new G(k,t,!1,e).promise})}function V(t){throw setTimeout(function(){throw t}),t}function W(t){var e={resolve:void 0,reject:void 0};return e.promise=new k(function(t,r){e.resolve=t,e.reject=r},t),e}G.prototype._setResultAt=P;var Y=function(t){function e(e,r,n,o){return function(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}(this,t.call(this,e,r,!0,o,n))}return function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}(e,t),e.prototype._init=function(t,e,r,n,o){var i=e.length||0;this.length=i,this._remaining=i,this._result=new Array(i),this._mapFn=o,this._enumerate(e)},e.prototype._setResultAt=function(t,e,r,n){if(n){var o=v(this._mapFn)(r,e);o===h?this._settledAt(l,e,o.error,!1):this._eachEntry(o,e,!1)}else this._remaining--,this._result[e]=r},e}(T);function $(t,e,r){return"function"!=typeof e?k.reject(new TypeError("map expects a function as a second argument"),r):k.resolve(t,r).then(function(t){if(!Array.isArray(t))throw new TypeError("map must be called with an array");return new Y(k,t,e,r).promise})}function z(t,e){return k.resolve(t,e)}function B(t,e){return k.reject(t,e)}var H={},J=function(t){function e(){return function(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}(this,t.apply(this,arguments))}return function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}(e,t),e.prototype._checkFullfillment=function(){if(0===this._remaining&&null!==this._result){var t=this._result.filter(function(t){return t!==H});b(this.promise,t),this._result=null}},e.prototype._setResultAt=function(t,e,r,n){if(n){this._result[e]=r;var o=v(this._mapFn)(r,e);o===h?this._settledAt(l,e,o.error,!1):this._eachEntry(o,e,!1)}else this._remaining--,r||(this._result[e]=H)},e}(Y);function Q(t,e,r){return"function"!=typeof e?k.reject(new TypeError("filter expects function as a second argument"),r):k.resolve(t,r).then(function(t){if(!Array.isArray(t))throw new TypeError("filter must be called with an array");return new J(k,t,e,r).promise})}var X=0,Z=void 0;function tt(t,e){ut[X]=t,ut[X+1]=e,2===(X+=2)&&_t()}var et="undefined"!=typeof window?window:void 0,rt=et||{},nt=rt.MutationObserver||rt.WebKitMutationObserver,ot="undefined"==typeof self&&"undefined"!=typeof process&&"[object process]"==={}.toString.call(process),it="undefined"!=typeof Uint8ClampedArray&&"undefined"!=typeof importScripts&&"undefined"!=typeof MessageChannel;function st(){return function(){return setTimeout(ct,1)}}var ut=new Array(1e3);function ct(){for(var t=0;t<X;t+=2){(0,ut[t])(ut[t+1]),ut[t]=void 0,ut[t+1]=void 0}X=0}var at,ft,lt,ht,pt,yt,_t=void 0;ot?(pt=process.nextTick,yt=process.versions.node.match(/^(?:(\\d+)\\.)?(?:(\\d+)\\.)?(\\*|\\d+)$/),Array.isArray(yt)&&"0"===yt[1]&&"10"===yt[2]&&(pt=setImmediate),_t=function(){return pt(ct)}):nt?(ft=0,lt=new nt(ct),ht=document.createTextNode(""),lt.observe(ht,{characterData:!0}),_t=function(){return ht.data=ft=++ft%2}):it?((at=new MessageChannel).port1.onmessage=ct,_t=function(){return at.port2.postMessage(0)}):_t=void 0===et&&"function"==typeof require?function(){try{var t=Function("return this")().require("vertx");return void 0!==(Z=t.runOnLoop||t.runOnContext)?function(){Z(ct)}:st()}catch(t){return st()}}():st(),n.async=tt,n.after=function(t){return setTimeout(t,0)};var vt=z,dt=function(t,e){return n.async(t,e)};function mt(){n.on.apply(n,arguments)}function wt(){n.off.apply(n,arguments)}if("undefined"!=typeof window&&"object"==typeof window.__PROMISE_INSTRUMENTATION__){var bt=window.__PROMISE_INSTRUMENTATION__;for(var gt in o("instrument",!0),bt)bt.hasOwnProperty(gt)&&mt(gt,bt[gt])}var jt={asap:tt,cast:vt,Promise:k,EventTarget:r,all:I,allSettled:U,race:D,hash:q,hashSettled:L,rethrow:V,defer:W,denodeify:M,configure:o,on:mt,off:wt,resolve:z,reject:B,map:$,async:dt,filter:Q};t.default=jt,t.asap=tt,t.cast=vt,t.Promise=k,t.EventTarget=r,t.all=I,t.allSettled=U,t.race=D,t.hash=q,t.hashSettled=L,t.rethrow=V,t.defer=W,t.denodeify=M,t.configure=o,t.on=mt,t.off=wt,t.resolve=z,t.reject=B,t.map=$,t.async=dt,t.filter=Q,Object.defineProperty(t,"__esModule",{value:!0})});
    window.Promise = RSVP.Promise;
}
"""

let javaScriptBridgeJS = """
window.\(JAVASCRIPT_BRIDGE_NAME) = {};
window.\(JAVASCRIPT_BRIDGE_NAME).callHandler = function() {
    var _windowId = window._flutter_inappwebview_windowId;
    var _callHandlerID = setTimeout(function(){});
    window.webkit.messageHandlers['callHandler'].postMessage( {'handlerName': arguments[0], '_callHandlerID': _callHandlerID, 'args': JSON.stringify(Array.prototype.slice.call(arguments, 1)), '_windowId': _windowId} );
    return new Promise(function(resolve, reject) {
        window.\(JAVASCRIPT_BRIDGE_NAME)[_callHandlerID] = resolve;
    });
}
"""

// the message needs to be concatenated with '' in order to have the same behavior like on Android
let consoleLogJS = """
(function(console) {

    var oldLogs = {
        'consoleLog': console.log,
        'consoleDebug': console.debug,
        'consoleError': console.error,
        'consoleInfo': console.info,
        'consoleWarn': console.warn
    };

    for (var k in oldLogs) {
        (function(oldLog) {
            console[oldLog.replace('console', '').toLowerCase()] = function() {
                var message = '';
                for (var i in arguments) {
                    if (message == '') {
                        message += arguments[i];
                    }
                    else {
                        message += ' ' + arguments[i];
                    }
                }

                var _windowId = window._flutter_inappwebview_windowId;
                window.webkit.messageHandlers[oldLog].postMessage({'message': message, '_windowId': _windowId});
                oldLogs[oldLog].apply(null, arguments);
            }
        })(k);
    }
})(window.console);
"""

let printJS = """
window.print = function() {
    window.\(JAVASCRIPT_BRIDGE_NAME).callHandler("onPrint", window.location.href);
}
"""

let platformReadyJS = "window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));";

let findTextHighlightJS = """
var wkwebview_SearchResultCount = 0;
var wkwebview_CurrentHighlight = 0;
var wkwebview_IsDoneCounting = false;

function wkwebview_FindAllAsyncForElement(element, keyword) {
  if (element) {
    if (element.nodeType == 3) {
      // Text node

      var elementTmp = element;
      while (true) {
        var value = elementTmp.nodeValue; // Search for keyword in text node
        var idx = value.toLowerCase().indexOf(keyword);

        if (idx < 0) break;

        var span = document.createElement("span");
        var text = document.createTextNode(value.substr(idx, keyword.length));
        span.appendChild(text);

        span.setAttribute(
          "id",
          "WKWEBVIEW_SEARCH_WORD_" + wkwebview_SearchResultCount
        );
        span.setAttribute("class", "wkwebview_Highlight");
        var backgroundColor = wkwebview_SearchResultCount == 0 ? "#FF9732" : "#FFFF00";
        span.setAttribute("style", "color: #000 !important; background: " + backgroundColor + " !important; padding: 0px !important; margin: 0px !important; border: 0px !important;");

        text = document.createTextNode(value.substr(idx + keyword.length));
        element.deleteData(idx, value.length - idx);

        var next = element.nextSibling;
        element.parentNode.insertBefore(span, next);
        element.parentNode.insertBefore(text, next);
        element = text;

        wkwebview_SearchResultCount++;
        elementTmp = document.createTextNode(
          value.substr(idx + keyword.length)
        );

        var _windowId = window._flutter_inappwebview_windowId;

        window.webkit.messageHandlers["onFindResultReceived"].postMessage(
            {
                'findResult': {
                    'activeMatchOrdinal': wkwebview_CurrentHighlight,
                    'numberOfMatches': wkwebview_SearchResultCount,
                    'isDoneCounting': wkwebview_IsDoneCounting
                },
                '_windowId': _windowId
            }
        );
      }
    } else if (element.nodeType == 1) {
      // Element node
      if (
        element.style.display != "none" &&
        element.nodeName.toLowerCase() != "select"
      ) {
        for (var i = element.childNodes.length - 1; i >= 0; i--) {
          wkwebview_FindAllAsyncForElement(
            element.childNodes[element.childNodes.length - 1 - i],
            keyword
          );
        }
      }
    }
  }
}

// the main entry point to start the search
function wkwebview_FindAllAsync(keyword) {
  wkwebview_ClearMatches();
  wkwebview_FindAllAsyncForElement(document.body, keyword.toLowerCase());
  wkwebview_IsDoneCounting = true;

  var _windowId = window._flutter_inappwebview_windowId;

  window.webkit.messageHandlers["onFindResultReceived"].postMessage(
      {
          'findResult': {
              'activeMatchOrdinal': wkwebview_CurrentHighlight,
              'numberOfMatches': wkwebview_SearchResultCount,
              'isDoneCounting': wkwebview_IsDoneCounting
          },
          '_windowId': _windowId
      }
  );
}

// helper function, recursively removes the highlights in elements and their childs
function wkwebview_ClearMatchesForElement(element) {
  if (element) {
    if (element.nodeType == 1) {
      if (element.getAttribute("class") == "wkwebview_Highlight") {
        var text = element.removeChild(element.firstChild);
        element.parentNode.insertBefore(text, element);
        element.parentNode.removeChild(element);
        return true;
      } else {
        var normalize = false;
        for (var i = element.childNodes.length - 1; i >= 0; i--) {
          if (wkwebview_ClearMatchesForElement(element.childNodes[i])) {
            normalize = true;
          }
        }
        if (normalize) {
          element.normalize();
        }
      }
    }
  }
  return false;
}

// the main entry point to remove the highlights
function wkwebview_ClearMatches() {
  wkwebview_SearchResultCount = 0;
  wkwebview_CurrentHighlight = 0;
  wkwebview_ClearMatchesForElement(document.body);
}

function wkwebview_FindNext(forward) {
  if (wkwebview_SearchResultCount <= 0) return;

  var idx = wkwebview_CurrentHighlight + (forward ? +1 : -1);
  idx =
    idx < 0
      ? wkwebview_SearchResultCount - 1
      : idx >= wkwebview_SearchResultCount
      ? 0
      : idx;
  wkwebview_CurrentHighlight = idx;

  var scrollTo = document.getElementById("WKWEBVIEW_SEARCH_WORD_" + idx);
  if (scrollTo) {
    var highlights = document.getElementsByClassName("wkwebview_Highlight");
    for (var i = 0; i < highlights.length; i++) {
      var span = highlights[i];
      span.style.backgroundColor = "#FFFF00";
    }
    scrollTo.style.backgroundColor = "#FF9732";

    scrollTo.scrollIntoView({
      behavior: "auto",
      block: "center"
    });

    var _windowId = window._flutter_inappwebview_windowId;

    window.webkit.messageHandlers["onFindResultReceived"].postMessage(
        {
            'findResult': {
                'activeMatchOrdinal': wkwebview_CurrentHighlight,
                'numberOfMatches': wkwebview_SearchResultCount,
                'isDoneCounting': wkwebview_IsDoneCounting
            },
            '_windowId': _windowId
        }
    );
  }
}
"""

let variableForOnLoadResourceJS = "window._flutter_inappwebview_useOnLoadResource"
let enableVariableForOnLoadResourceJS = "\(variableForOnLoadResourceJS) = $PLACEHOLDER_VALUE;"

let resourceObserverJS = """
(function() {
    var observer = new PerformanceObserver(function(list) {
        list.getEntries().forEach(function(entry) {
            if (window.\(variableForOnLoadResourceJS) == null || window.\(variableForOnLoadResourceJS) == true) {
                window.\(JAVASCRIPT_BRIDGE_NAME).callHandler("onLoadResource", entry);
            }
        });
    });
    observer.observe({entryTypes: ['resource']});
})();
"""

let variableForShouldInterceptAjaxRequestJS = "window._flutter_inappwebview_useShouldInterceptAjaxRequest"
let enableVariableForShouldInterceptAjaxRequestJS = "\(variableForShouldInterceptAjaxRequestJS) = $PLACEHOLDER_VALUE;"

let interceptAjaxRequestsJS = """
(function(ajax) {
  var send = ajax.prototype.send;
  var open = ajax.prototype.open;
  var setRequestHeader = ajax.prototype.setRequestHeader;
  ajax.prototype._flutter_inappwebview_url = null;
  ajax.prototype._flutter_inappwebview_method = null;
  ajax.prototype._flutter_inappwebview_isAsync = null;
  ajax.prototype._flutter_inappwebview_user = null;
  ajax.prototype._flutter_inappwebview_password = null;
  ajax.prototype._flutter_inappwebview_password = null;
  ajax.prototype._flutter_inappwebview_already_onreadystatechange_wrapped = false;
  ajax.prototype._flutter_inappwebview_request_headers = {};
  function convertRequestResponse(request, callback) {
    if (request.response != null && request.responseType != null) {
      switch (request.responseType) {
        case 'arraybuffer':
          callback(new Uint8Array(request.response));
          return;
        case 'blob':
          const reader = new FileReader();
          reader.addEventListener('loadend', function() {
            callback(new Uint8Array(reader.result));
          });
          reader.readAsArrayBuffer(blob);
          return;
        case 'document':
          callback(request.response.documentElement.outerHTML);
          return;
        case 'json':
          callback(request.response);
          return;
      };
    }
    callback(null);
  };
  ajax.prototype.open = function(method, url, isAsync, user, password) {
    isAsync = (isAsync != null) ? isAsync : true;
    this._flutter_inappwebview_url = url;
    this._flutter_inappwebview_method = method;
    this._flutter_inappwebview_isAsync = isAsync;
    this._flutter_inappwebview_user = user;
    this._flutter_inappwebview_password = password;
    this._flutter_inappwebview_request_headers = {};
    open.call(this, method, url, isAsync, user, password);
  };
  ajax.prototype.setRequestHeader = function(header, value) {
    this._flutter_inappwebview_request_headers[header] = value;
    setRequestHeader.call(this, header, value);
  };
  function handleEvent(e) {
    var self = this;
    if (\(variableForShouldInterceptAjaxRequestJS) == null || \(variableForShouldInterceptAjaxRequestJS) == true) {
      var headers = this.getAllResponseHeaders();
      var responseHeaders = {};
      if (headers != null) {
        var arr = headers.trim().split(/[\\r\\n]+/);
        arr.forEach(function (line) {
          var parts = line.split(': ');
          var header = parts.shift();
          var value = parts.join(': ');
          responseHeaders[header] = value;
        });
      }
      convertRequestResponse(this, function(response) {
        var ajaxRequest = {
          method: self._flutter_inappwebview_method,
          url: self._flutter_inappwebview_url,
          isAsync: self._flutter_inappwebview_isAsync,
          user: self._flutter_inappwebview_user,
          password: self._flutter_inappwebview_password,
          withCredentials: self.withCredentials,
          headers: self._flutter_inappwebview_request_headers,
          readyState: self.readyState,
          status: self.status,
          responseURL: self.responseURL,
          responseType: self.responseType,
          response: response,
          responseText: (self.responseType == 'text' || self.responseType == '') ? self.responseText : null,
          responseXML: (self.responseType == 'document' && self.responseXML != null) ? self.responseXML.documentElement.outerHTML : null,
          statusText: self.statusText,
          responseHeaders, responseHeaders,
          event: {
            type: e.type,
            loaded: e.loaded,
            lengthComputable: e.lengthComputable,
            total: e.total
          }
        };
        window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('onAjaxProgress', ajaxRequest).then(function(result) {
          if (result != null) {
            switch (result) {
              case 0:
                self.abort();
                return;
            };
          }
        });
      });
    }
  };
  ajax.prototype.send = function(data) {
    var self = this;
    if (\(variableForShouldInterceptAjaxRequestJS) == null || \(variableForShouldInterceptAjaxRequestJS) == true) {
      if (!this._flutter_inappwebview_already_onreadystatechange_wrapped) {
        this._flutter_inappwebview_already_onreadystatechange_wrapped = true;
        var onreadystatechange = this.onreadystatechange;
        this.onreadystatechange = function() {
          if (\(variableForShouldInterceptAjaxRequestJS) == null || \(variableForShouldInterceptAjaxRequestJS) == true) {
            var headers = this.getAllResponseHeaders();
            var responseHeaders = {};
            if (headers != null) {
              var arr = headers.trim().split(/[\\r\\n]+/);
              arr.forEach(function (line) {
                var parts = line.split(': ');
                var header = parts.shift();
                var value = parts.join(': ');
                responseHeaders[header] = value;
              });
            }
            convertRequestResponse(this, function(response) {
              var ajaxRequest = {
                method: self._flutter_inappwebview_method,
                url: self._flutter_inappwebview_url,
                isAsync: self._flutter_inappwebview_isAsync,
                user: self._flutter_inappwebview_user,
                password: self._flutter_inappwebview_password,
                withCredentials: self.withCredentials,
                headers: self._flutter_inappwebview_request_headers,
                readyState: self.readyState,
                status: self.status,
                responseURL: self.responseURL,
                responseType: self.responseType,
                response: response,
                responseText: (self.responseType == 'text' || self.responseType == '') ? self.responseText : null,
                responseXML: (self.responseType == 'document' && self.responseXML != null) ? self.responseXML.documentElement.outerHTML : null,
                statusText: self.statusText,
                responseHeaders: responseHeaders
              };
              window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('onAjaxReadyStateChange', ajaxRequest).then(function(result) {
                if (result != null) {
                  switch (result) {
                    case 0:
                      self.abort();
                      return;
                  };
                }
                if (onreadystatechange != null) {
                  onreadystatechange();
                }
              });
            });
          } else if (onreadystatechange != null) {
            onreadystatechange();
          }
        };
      }
      this.addEventListener('loadstart', handleEvent);
      this.addEventListener('load', handleEvent);
      this.addEventListener('loadend', handleEvent);
      this.addEventListener('progress', handleEvent);
      this.addEventListener('error', handleEvent);
      this.addEventListener('abort', handleEvent);
      this.addEventListener('timeout', handleEvent);
      var ajaxRequest = {
        data: data,
        method: this._flutter_inappwebview_method,
        url: this._flutter_inappwebview_url,
        isAsync: this._flutter_inappwebview_isAsync,
        user: this._flutter_inappwebview_user,
        password: this._flutter_inappwebview_password,
        withCredentials: this.withCredentials,
        headers: this._flutter_inappwebview_request_headers,
        responseType: this.responseType
      };
      window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('shouldInterceptAjaxRequest', ajaxRequest).then(function(result) {
        if (result != null) {
          switch (result.action) {
            case 0:
              self.abort();
              return;
          };
          data = result.data;
          self.withCredentials = result.withCredentials;
          if (result.responseType != null) {
            self.responseType = result.responseType;
          };
          for (var header in result.headers) {
            var value = result.headers[header];
            var flutter_inappwebview_value = self._flutter_inappwebview_request_headers[header];
            if (flutter_inappwebview_value == null) {
              self._flutter_inappwebview_request_headers[header] = value;
            } else {
              self._flutter_inappwebview_request_headers[header] += ', ' + value;
            }
            setRequestHeader.call(self, header, value);
          };
          if ((self._flutter_inappwebview_method != result.method && result.method != null) || (self._flutter_inappwebview_url != result.url && result.url != null)) {
            self.abort();
            self.open(result.method, result.url, result.isAsync, result.user, result.password);
            return;
          }
        }
        send.call(self, data);
      });
    } else {
      send.call(this, data);
    }
  };
})(window.XMLHttpRequest);
"""

let variableForShouldInterceptFetchRequestsJS = "window._flutter_inappwebview_useShouldInterceptFetchRequest"
let enableVariableForShouldInterceptFetchRequestsJS = "\(variableForShouldInterceptFetchRequestsJS) = $PLACEHOLDER_VALUE;"

let interceptFetchRequestsJS = """
(function(fetch) {
  if (fetch == null) {
    return;
  }
  function convertHeadersToJson(headers) {
    var headersObj = {};
    for (var header of headers.keys()) {
      var value = headers.get(header);
      headersObj[header] = value;
    }
    return headersObj;
  }
  function convertJsonToHeaders(headersJson) {
    return new Headers(headersJson);
  }
  function convertBodyToArray(body) {
    return new Response(body).arrayBuffer().then(function(arrayBuffer) {
      var arr = Array.from(new Uint8Array(arrayBuffer));
      return arr;
    })
  }
  function convertArrayIntBodyToUint8Array(arrayIntBody) {
    return new Uint8Array(arrayIntBody);
  }
  function convertCredentialsToJson(credentials) {
    var credentialsObj = {};
    if (window.FederatedCredential != null && credentials instanceof FederatedCredential) {
      credentialsObj.type = credentials.type;
      credentialsObj.id = credentials.id;
      credentialsObj.name = credentials.name;
      credentialsObj.protocol = credentials.protocol;
      credentialsObj.provider = credentials.provider;
      credentialsObj.iconURL = credentials.iconURL;
    } else if (window.PasswordCredential != null && credentials instanceof PasswordCredential) {
      credentialsObj.type = credentials.type;
      credentialsObj.id = credentials.id;
      credentialsObj.name = credentials.name;
      credentialsObj.password = credentials.password;
      credentialsObj.iconURL = credentials.iconURL;
    } else {
      credentialsObj.type = 'default';
      credentialsObj.value = credentials;
    }
  }
  function convertJsonToCredential(credentialsJson) {
    var credentials;
    if (window.FederatedCredential != null && credentialsJson.type === 'federated') {
      credentials = new FederatedCredential({
        id: credentialsJson.id,
        name: credentialsJson.name,
        protocol: credentialsJson.protocol,
        provider: credentialsJson.provider,
        iconURL: credentialsJson.iconURL
      });
    } else if (window.PasswordCredential != null && credentialsJson.type === 'password') {
      credentials = new PasswordCredential({
        id: credentialsJson.id,
        name: credentialsJson.name,
        password: credentialsJson.password,
        iconURL: credentialsJson.iconURL
      });
    } else {
      credentials = credentialsJson;
    }
    return credentials;
  }
  window.fetch = async function(resource, init) {
    if (window.\(variableForShouldInterceptFetchRequestsJS) == null || window.\(variableForShouldInterceptFetchRequestsJS) == true) {
      var fetchRequest = {
        url: null,
        method: null,
        headers: null,
        body: null,
        mode: null,
        credentials: null,
        cache: null,
        redirect: null,
        referrer: null,
        referrerPolicy: null,
        integrity: null,
        keepalive: null
      };
      if (resource instanceof Request) {
        fetchRequest.url = resource.url;
        fetchRequest.method = resource.method;
        fetchRequest.headers = resource.headers;
        fetchRequest.body = resource.body;
        fetchRequest.mode = resource.mode;
        fetchRequest.credentials = resource.credentials;
        fetchRequest.cache = resource.cache;
        fetchRequest.redirect = resource.redirect;
        fetchRequest.referrer = resource.referrer;
        fetchRequest.referrerPolicy = resource.referrerPolicy;
        fetchRequest.integrity = resource.integrity;
        fetchRequest.keepalive = resource.keepalive;
      } else {
        fetchRequest.url = resource;
        if (init != null) {
          fetchRequest.method = init.method;
          fetchRequest.headers = init.headers;
          fetchRequest.body = init.body;
          fetchRequest.mode = init.mode;
          fetchRequest.credentials = init.credentials;
          fetchRequest.cache = init.cache;
          fetchRequest.redirect = init.redirect;
          fetchRequest.referrer = init.referrer;
          fetchRequest.referrerPolicy = init.referrerPolicy;
          fetchRequest.integrity = init.integrity;
          fetchRequest.keepalive = init.keepalive;
        }
      }
      if (fetchRequest.headers instanceof Headers) {
        fetchRequest.headers = convertHeadersToJson(fetchRequest.headers);
      }
      fetchRequest.credentials = convertCredentialsToJson(fetchRequest.credentials);
      return convertBodyToArray(fetchRequest.body).then(function(body) {
        fetchRequest.body = body;
        return window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('shouldInterceptFetchRequest', fetchRequest).then(function(result) {
          if (result != null) {
            switch (result.action) {
              case 0:
                var controller = new AbortController();
                if (init != null) {
                  init.signal = controller.signal;
                } else {
                  init = {
                    signal: controller.signal
                  };
                }
                controller.abort();
                break;
            }
            resource = (result.url != null) ? result.url : resource;
            if (init == null) {
              init = {};
            }
            if (result.method != null && result.method.length > 0) {
              init.method = result.method;
            }
            if (result.headers != null && Object.keys(result.headers).length > 0) {
              init.headers = convertJsonToHeaders(result.headers);
            }
            if (result.body != null && result.body.length > 0)   {
              init.body = convertArrayIntBodyToUint8Array(result.body);
            }
            if (result.mode != null && result.mode.length > 0) {
              init.mode = result.mode;
            }
            if (result.credentials != null) {
              init.credentials = convertJsonToCredential(result.credentials);
            }
            if (result.cache != null && result.cache.length > 0) {
              init.cache = result.cache;
            }
            if (result.redirect != null && result.redirect.length > 0) {
              init.redirect = result.redirect;
            }
            if (result.referrer != null && result.referrer.length > 0) {
              init.referrer = result.referrer;
            }
            if (result.referrerPolicy != null && result.referrerPolicy.length > 0) {
              init.referrerPolicy = result.referrerPolicy;
            }
            if (result.integrity != null && result.integrity.length > 0) {
              init.integrity = result.integrity;
            }
            if (result.keepalive != null) {
              init.keepalive = result.keepalive;
            }
            return fetch(resource, init);
          }
          return fetch(resource, init);
        });
      });
    } else {
      return fetch(resource, init);
    }
  };
})(window.fetch);
"""

/**
 https://developer.android.com/reference/android/webkit/WebView.HitTestResult
 */
let findElementsAtPointJS = """
window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint = function(x, y) {
    var hitTestResultType = {
        UNKNOWN_TYPE: 0,
        PHONE_TYPE: 2,
        GEO_TYPE: 3,
        EMAIL_TYPE: 4,
        IMAGE_TYPE: 5,
        SRC_ANCHOR_TYPE: 7,
        SRC_IMAGE_ANCHOR_TYPE: 8,
        EDIT_TEXT_TYPE: 9
    };
    var element = document.elementFromPoint(x, y);
    var data = {
        type: 0,
        extra: null
    };
    while (element) {
        if (element.tagName === 'IMG' && element.src) {
            if (element.parentNode && element.parentNode.tagName === 'A' && element.parentNode.href) {
                data.type = hitTestResultType.SRC_IMAGE_ANCHOR_TYPE;
            } else {
                data.type = hitTestResultType.IMAGE_TYPE;
            }
            data.extra = element.src;
            break;
        } else if (element.tagName === 'A' && element.href) {
            if (element.href.indexOf('mailto:') === 0) {
                data.type = hitTestResultType.EMAIL_TYPE;
                data.extra = element.href.replace('mailto:', '');
            } else if (element.href.indexOf('tel:') === 0) {
                data.type = hitTestResultType.PHONE_TYPE;
                data.extra = element.href.replace('tel:', '');
            } else if (element.href.indexOf('geo:') === 0) {
                data.type = hitTestResultType.GEO_TYPE;
                data.extra = element.href.replace('geo:', '');
            } else {
                data.type = hitTestResultType.SRC_ANCHOR_TYPE;
                data.extra = element.href;
            }
            break;
        } else if (
            (element.tagName === 'INPUT' && ['text', 'email', 'password', 'number', 'search', 'tel', 'url'].indexOf(element.type) >= 0) ||
            element.tagName === 'TEXTAREA') {
            data.type = hitTestResultType.EDIT_TEXT_TYPE
        }
        element = element.parentNode;
    }
    return data;
}
"""

let getSelectedTextJS = """
(function(){
    var txt;
    if (window.getSelection) {
      txt = window.getSelection().toString();
    } else if (window.document.getSelection) {
      txt = window.document.getSelection().toString();
    } else if (window.document.selection) {
      txt = window.document.selection.createRange().text;
    }
    return txt;
})();
"""

let lastTouchedAnchorOrImageJS = """
window.\(JAVASCRIPT_BRIDGE_NAME)._lastAnchorOrImageTouched = null;
window.\(JAVASCRIPT_BRIDGE_NAME)._lastImageTouched = null;
(function() {
    document.addEventListener('touchstart', function(event) {
        var target = event.target;
        while (target) {
            if (target.tagName === 'IMG') {
                var img = target;
                window.flutter_inappwebview._lastImageTouched = {
                    src: img.src
                };
                var parent = img.parentNode;
                while (parent) {
                    if (parent.tagName === 'A') {
                        window.flutter_inappwebview._lastAnchorOrImageTouched = {
                            title: parent.textContent,
                            url: parent.href,
                            src: img.src
                        };
                        break;
                    }
                    parent = parent.parentNode;
                }
                return;
            } else if (target.tagName === 'A') {
                var link = target;
                var images = link.getElementsByTagName('img');
                var img = (images.length > 0) ? images[0] : null;
                var imgSrc = (img != null) ? img.src : null;
                window.flutter_inappwebview._lastImageTouched = (img != null) ? {src: img.src} : window.flutter_inappwebview._lastImageTouched;
                window.flutter_inappwebview._lastAnchorOrImageTouched = {
                    title: link.textContent,
                    url: link.href,
                    src: imgSrc
                };
                return;
            }
            target = target.parentNode;
        }
    });
})();
"""

let originalViewPortMetaTagContentJS = """
window.\(JAVASCRIPT_BRIDGE_NAME)._originalViewPortMetaTagContent = "";
(function() {
    var metaTagNodes = document.head.getElementsByTagName('meta');
    for (var i = 0; i < metaTagNodes.length; i++) {
        var metaTagNode = metaTagNodes[i];
        if (metaTagNode.name === "viewport") {
            window.\(JAVASCRIPT_BRIDGE_NAME)._originalViewPortMetaTagContent = metaTagNode.content;
        }
    }
})();
"""

let onWindowFocusEventJS = """
(function(){
    window.addEventListener('focus', function(e) {
        window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('onWindowFocus');
    });
})();
"""

let onWindowBlurEventJS = """
(function(){
    window.addEventListener('blur', function(e) {
        window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('onWindowBlur');
    });
})();
"""

var SharedLastTouchPointTimestamp: [InAppWebView: Int64] = [:]

public class WebViewTransport: NSObject {
    var webView: InAppWebView
    var request: URLRequest
    
    init(webView: InAppWebView, request: URLRequest) {
        self.webView = webView
        self.request = request
    }
}

public class InAppWebView: WKWebView, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate {

    var windowId: Int64?
    var IABController: InAppBrowserWebViewController?
    var channel: FlutterMethodChannel?
    var options: InAppWebViewOptions?
    var currentURL: URL?
    var x509CertificateData: Data?
    static var sslCertificateMap: [String: Data] = [:] // [URL host name : x509Certificate Data]
    var startPageTime: Int64 = 0
    static var credentialsProposed: [URLCredential] = []
    var lastScrollX: CGFloat = 0
    var lastScrollY: CGFloat = 0
    var isPausedTimers = false
    var isPausedTimersCompletionHandler: (() -> Void)?
    // This flag is used to block the "shouldOverrideUrlLoading" event when the WKWebView is loading the first time,
    // in order to have the same behavior as Android
    var activateShouldOverrideUrlLoading = false
    var contextMenu: [String: Any]?
    
    // https://github.com/mozilla-mobile/firefox-ios/blob/50531a7e9e4d459fb11d4fcb7d4322e08103501f/Client/Frontend/Browser/ContextMenuHelper.swift
    fileprivate var nativeHighlightLongPressRecognizer: UILongPressGestureRecognizer?
    var longPressRecognizer: UILongPressGestureRecognizer?
    var lastLongPressTouchPoint: CGPoint?
    
    var lastTouchPoint: CGPoint?
    var lastTouchPointTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
    
    var contextMenuIsShowing = false
    // flag used for the workaround to trigger onCreateContextMenu event as the same on Android
    var onCreateContextMenuEventTriggeredWhenMenuDisabled = false
    
    var customIMPs: [IMP] = []
    
    static var windowWebViews: [Int64:WebViewTransport] = [:]
    static var windowAutoincrementId: Int64 = 0;
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, IABController: InAppBrowserWebViewController?, contextMenu: [String: Any]?, channel: FlutterMethodChannel?) {
        super.init(frame: frame, configuration: configuration)
        self.channel = channel
        self.contextMenu = contextMenu
        self.IABController = IABController
        uiDelegate = self
        navigationDelegate = self
        scrollView.delegate = self
        self.longPressRecognizer = UILongPressGestureRecognizer()
        self.longPressRecognizer!.delegate = self
        self.longPressRecognizer!.addTarget(self, action: #selector(longPressGestureDetected))
    }
    
    override public var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            
            self.scrollView.contentInset = UIEdgeInsets.zero;
            if #available(iOS 11, *) {
                // Above iOS 11, adjust contentInset to compensate the adjustedContentInset so the sum will
                // always be 0.
                if (scrollView.adjustedContentInset != UIEdgeInsets.zero) {
                    let insetToAdjust = self.scrollView.adjustedContentInset;
                    scrollView.contentInset = UIEdgeInsets(top: -insetToAdjust.top, left: -insetToAdjust.left,
                                                                bottom: -insetToAdjust.bottom, right: -insetToAdjust.right);
                }
            }
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // BVC KVO events for all changes on the webview will call this.
    // It is called frequently during a page load (particularly on progress changes and URL changes).
    // As of iOS 12, WKContentView gesture setup is async, but it has been called by the time
    // the webview is ready to load an URL. After this has happened, we can override the gesture.
    func replaceGestureHandlerIfNeeded() {
        DispatchQueue.main.async {
            if self.gestureRecognizerWithDescriptionFragment("InAppWebView") == nil {
                self.replaceWebViewLongPress()
            }
        }
    }
    
    private func replaceWebViewLongPress() {
        // WebKit installs gesture handlers async. If `replaceWebViewLongPress` is called after a wkwebview in most cases a small delay is sufficient
        // See also https://bugs.webkit.org/show_bug.cgi?id=193366
        nativeHighlightLongPressRecognizer = gestureRecognizerWithDescriptionFragment("action=_highlightLongPressRecognized:")

        if let nativeLongPressRecognizer = gestureRecognizerWithDescriptionFragment("action=_longPressRecognized:") {
            nativeLongPressRecognizer.removeTarget(nil, action: nil)
            nativeLongPressRecognizer.addTarget(self, action: #selector(self.longPressGestureDetected))
        }
    }
    
    private func gestureRecognizerWithDescriptionFragment(_ descriptionFragment: String) -> UILongPressGestureRecognizer? {
        let result = self.scrollView.subviews.compactMap({ $0.gestureRecognizers }).joined().first(where: {
            (($0 as? UILongPressGestureRecognizer) != nil) && $0.description.contains(descriptionFragment)
        })
        return result as? UILongPressGestureRecognizer
    }
    
    @objc func longPressGestureDetected(_ sender: UIGestureRecognizer) {
        if sender.state == .cancelled {
            return
        }

        guard sender.state == .began else {
            return
        }

        // To prevent the tapped link from proceeding with navigation, "cancel" the native WKWebView
        // `_highlightLongPressRecognizer`. This preserves the original behavior as seen here:
        // https://github.com/WebKit/webkit/blob/d591647baf54b4b300ca5501c21a68455429e182/Source/WebKit/UIProcess/ios/WKContentViewInteraction.mm#L1600-L1614
        if let nativeHighlightLongPressRecognizer = self.nativeHighlightLongPressRecognizer,
            nativeHighlightLongPressRecognizer.isEnabled {
            nativeHighlightLongPressRecognizer.isEnabled = false
            nativeHighlightLongPressRecognizer.isEnabled = true
        }
        
        //Finding actual touch location in webView
        var touchLocation = sender.location(in: self)
        touchLocation.x -= self.scrollView.contentInset.left
        touchLocation.y -= self.scrollView.contentInset.top
        touchLocation.x /= self.scrollView.zoomScale
        touchLocation.y /= self.scrollView.zoomScale
        
        lastLongPressTouchPoint = touchLocation

        self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint(\(touchLocation.x),\(touchLocation.y))", completionHandler: {(value, error) in
            if error != nil {
                print("Long press gesture recognizer error: \(error?.localizedDescription ?? "")")
            } else {
                self.onLongPressHitTestResult(hitTestResult: value as! [String: Any?])
            }
        })
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        lastTouchPoint = point
        lastTouchPointTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        SharedLastTouchPointTimestamp[self] = lastTouchPointTimestamp
        
        // re-build context menu items for the current webview
        UIMenuController.shared.menuItems = []
        if let menu = self.contextMenu {
            if let menuItems = menu["menuItems"] as? [[String : Any]] {
                for menuItem in menuItems {
                    let id = menuItem["iosId"] as! String
                    let title = menuItem["title"] as! String
                    let targetMethodName = "onContextMenuActionItemClicked-" + String(self.hash) + "-" + id
                    if !self.responds(to: Selector(targetMethodName)) {
                        let customAction: () -> Void = {
                            let arguments: [String: Any?] = [
                                "iosId": id,
                                "androidId": nil,
                                "title": title
                            ]
                            self.channel?.invokeMethod("onContextMenuActionItemClicked", arguments: arguments)
                        }
                        let castedCustomAction: AnyObject = unsafeBitCast(customAction as @convention(block) () -> Void, to: AnyObject.self)
                        let swizzledImplementation = imp_implementationWithBlock(castedCustomAction)
                        class_addMethod(InAppWebView.self, Selector(targetMethodName), swizzledImplementation, nil)
                        self.customIMPs.append(swizzledImplementation)
                    }
                    let item = UIMenuItem(title: title, action: Selector(targetMethodName))
                    UIMenuController.shared.menuItems!.append(item)
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let _ = sender as? UIMenuController {
            if self.options?.disableContextMenu == true {
                if !onCreateContextMenuEventTriggeredWhenMenuDisabled {
                    // workaround to trigger onCreateContextMenu event as the same on Android
                    self.onCreateContextMenu()
                    onCreateContextMenuEventTriggeredWhenMenuDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.onCreateContextMenuEventTriggeredWhenMenuDisabled = false
                    }
                }
                return false
            }
            
            if let menu = contextMenu {
                let contextMenuOptions = ContextMenuOptions()
                if let contextMenuOptionsMap = menu["options"] as? [String: Any?] {
                    let _ = contextMenuOptions.parse(options: contextMenuOptionsMap)
                    if !action.description.starts(with: "onContextMenuActionItemClicked-") && contextMenuOptions.hideDefaultSystemContextMenuItems {
                        return false
                    }
                }
            }
            
            if contextMenuIsShowing, !action.description.starts(with: "onContextMenuActionItemClicked-") {
                let id = action.description.compactMap({ $0.asciiValue?.description }).joined()
                let arguments: [String: Any?] = [
                    "iosId": id,
                    "androidId": nil,
                    "title": action.description
                ]
                self.channel?.invokeMethod("onContextMenuActionItemClicked", arguments: arguments)
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    public func prepare() {
        
        self.scrollView.addGestureRecognizer(self.longPressRecognizer!)
        
        addObserver(self,
                    forKeyPath: #keyPath(WKWebView.estimatedProgress),
                    options: .new,
                    context: nil)
        
        addObserver(self,
                    forKeyPath: #keyPath(WKWebView.url),
                    options: [.new, .old],
                    context: nil)
        
        addObserver(self,
            forKeyPath: #keyPath(WKWebView.title),
            options: [.new, .old],
            context: nil)

        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(onCreateContextMenu),
                        name: UIMenuController.willShowMenuNotification,
                        object: nil)
        
        
        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(onHideContextMenu),
                        name: UIMenuController.didHideMenuNotification,
                        object: nil)
        
        // listen for videos playing in fullscreen
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onEnterFullscreen(_:)),
                                               name: UIWindow.didBecomeVisibleNotification,
                                               object: window)

        // listen for videos stopping to play in fullscreen
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onExitFullscreen(_:)),
                                               name: UIWindow.didBecomeHiddenNotification,
                                               object: window)
        
        if let options = options {
            if options.transparentBackground {
                isOpaque = false
                backgroundColor = UIColor.clear
                scrollView.backgroundColor = UIColor.clear
            }
            
            // prevent webView from bouncing
            if options.disallowOverScroll {
                if responds(to: #selector(getter: scrollView)) {
                    scrollView.bounces = false
                }
                else {
                    for subview: UIView in subviews {
                        if subview is UIScrollView {
                            (subview as! UIScrollView).bounces = false
                        }
                    }
                }
            }
            
            if #available(iOS 11.0, *) {
                accessibilityIgnoresInvertColors = options.accessibilityIgnoresInvertColors
                scrollView.contentInsetAdjustmentBehavior =
                    UIScrollView.ContentInsetAdjustmentBehavior.init(rawValue: options.contentInsetAdjustmentBehavior)!
            }
            
            allowsBackForwardNavigationGestures = options.allowsBackForwardNavigationGestures
            if #available(iOS 9.0, *) {
                allowsLinkPreview = options.allowsLinkPreview
                if !options.userAgent.isEmpty {
                    customUserAgent = options.userAgent
                }
            }
            
            if #available(iOS 13.0, *) {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = options.automaticallyAdjustsScrollIndicatorInsets
            }
            
            scrollView.showsVerticalScrollIndicator = !options.disableVerticalScroll
            scrollView.showsHorizontalScrollIndicator = !options.disableHorizontalScroll
            scrollView.showsVerticalScrollIndicator = options.verticalScrollBarEnabled
            scrollView.showsHorizontalScrollIndicator = options.horizontalScrollBarEnabled

            scrollView.decelerationRate = InAppWebView.getDecelerationRate(type: options.decelerationRate)
            scrollView.alwaysBounceVertical = options.alwaysBounceVertical
            scrollView.alwaysBounceHorizontal = options.alwaysBounceHorizontal
            scrollView.scrollsToTop = options.scrollsToTop
            scrollView.isPagingEnabled = options.isPagingEnabled
            scrollView.maximumZoomScale = CGFloat(options.maximumZoomScale)
            scrollView.minimumZoomScale = CGFloat(options.minimumZoomScale)
            
            // options.debuggingEnabled is always enabled for iOS,
            // there isn't any option to set about it such as on Android.
            
            if options.clearCache {
                clearCache()
            }
        }
        
        let userScript = WKUserScript(source: "window._flutter_inappwebview_windowId = \(windowId == nil ? "null" : String(windowId!));" , injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)
        
        if windowId != nil {
            // the new created window webview has the same WKWebViewConfiguration variable reference
            return
        }
        
        configuration.userContentController = WKUserContentController()
        configuration.preferences = WKPreferences()
        
        if let options = options {
           
            let originalViewPortMetaTagContentJSScript = WKUserScript(source: originalViewPortMetaTagContentJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            configuration.userContentController.addUserScript(originalViewPortMetaTagContentJSScript)
            
            if !options.supportZoom {
                let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);"
                let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                configuration.userContentController.addUserScript(userScript)
            } else if options.enableViewportScale {
                let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
                let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                configuration.userContentController.addUserScript(userScript)
            }
            
            let promisePolyfillJSScript = WKUserScript(source: promisePolyfillJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(promisePolyfillJSScript)
            
            let javaScriptBridgeJSScript = WKUserScript(source: javaScriptBridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(javaScriptBridgeJSScript)
            configuration.userContentController.add(self, name: "callHandler")
            
            let consoleLogJSScript = WKUserScript(source: consoleLogJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(consoleLogJSScript)
            configuration.userContentController.add(self, name: "consoleLog")
            configuration.userContentController.add(self, name: "consoleDebug")
            configuration.userContentController.add(self, name: "consoleError")
            configuration.userContentController.add(self, name: "consoleInfo")
            configuration.userContentController.add(self, name: "consoleWarn")
            
            let findElementsAtPointJSScript = WKUserScript(source: findElementsAtPointJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(findElementsAtPointJSScript)
            
            let printJSScript = WKUserScript(source: printJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(printJSScript)
            
            let lastTouchedAnchorOrImageJSScript = WKUserScript(source: lastTouchedAnchorOrImageJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(lastTouchedAnchorOrImageJSScript)
            
            if options.useOnLoadResource {
                let resourceObserverJSScript = WKUserScript(source: resourceObserverJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                configuration.userContentController.addUserScript(resourceObserverJSScript)
            }
            
            let findTextHighlightJSScript = WKUserScript(source: findTextHighlightJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(findTextHighlightJSScript)
            configuration.userContentController.add(self, name: "onFindResultReceived")
            
            let onWindowFocusEventJSScript = WKUserScript(source: onWindowFocusEventJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(onWindowFocusEventJSScript)
            
            let onWindowBlurEventJSScript = WKUserScript(source: onWindowBlurEventJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(onWindowBlurEventJSScript)
            
            if options.useShouldInterceptAjaxRequest {
                let interceptAjaxRequestsJSScript = WKUserScript(source: interceptAjaxRequestsJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                configuration.userContentController.addUserScript(interceptAjaxRequestsJSScript)
            }
            
            if options.useShouldInterceptFetchRequest {
                let interceptFetchRequestsJSScript = WKUserScript(source: interceptFetchRequestsJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                configuration.userContentController.addUserScript(interceptFetchRequestsJSScript)
            }
            
            if #available(iOS 9.0, *) {
                configuration.allowsAirPlayForMediaPlayback = options.allowsAirPlayForMediaPlayback
                configuration.allowsPictureInPictureMediaPlayback = options.allowsPictureInPictureMediaPlayback
                if !options.applicationNameForUserAgent.isEmpty {
                    configuration.applicationNameForUserAgent = options.applicationNameForUserAgent
                }
            }
            
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = options.javaScriptCanOpenWindowsAutomatically
            configuration.preferences.javaScriptEnabled = options.javaScriptEnabled
            configuration.preferences.minimumFontSize = CGFloat(options.minimumFontSize)
            
            if #available(iOS 13.0, *) {
                configuration.preferences.isFraudulentWebsiteWarningEnabled = options.isFraudulentWebsiteWarningEnabled
                configuration.defaultWebpagePreferences.preferredContentMode = WKWebpagePreferences.ContentMode(rawValue: options.preferredContentMode)!
            }
        }
    }
    
    @available(iOS 10.0, *)
    static public func getDataDetectorType(type: String) -> WKDataDetectorTypes {
        switch type {
            case "NONE":
                return WKDataDetectorTypes.init(rawValue: 0)
            case "PHONE_NUMBER":
                return .phoneNumber
            case "LINK":
                return .link
            case "ADDRESS":
                return .address
            case "CALENDAR_EVENT":
                return .calendarEvent
            case "TRACKING_NUMBER":
                return .trackingNumber
            case "FLIGHT_NUMBER":
                return .flightNumber
            case "LOOKUP_SUGGESTION":
                return .lookupSuggestion
            case "SPOTLIGHT_SUGGESTION":
                return .spotlightSuggestion
            case "ALL":
                return .all
            default:
                return WKDataDetectorTypes.init(rawValue: 0)
        }
    }
    
    @available(iOS 10.0, *)
    static public func getDataDetectorTypeString(type: WKDataDetectorTypes) -> [String] {
        var dataDetectorTypeString: [String] = []
        if type.contains(.all) {
            dataDetectorTypeString.append("ALL")
        } else {
            if type.contains(.phoneNumber) {
                dataDetectorTypeString.append("PHONE_NUMBER")
            }
            if type.contains(.link) {
                dataDetectorTypeString.append("LINK")
            }
            if type.contains(.address) {
                dataDetectorTypeString.append("ADDRESS")
            }
            if type.contains(.calendarEvent) {
                dataDetectorTypeString.append("CALENDAR_EVENT")
            }
            if type.contains(.trackingNumber) {
                dataDetectorTypeString.append("TRACKING_NUMBER")
            }
            if type.contains(.flightNumber) {
                dataDetectorTypeString.append("FLIGHT_NUMBER")
            }
            if type.contains(.lookupSuggestion) {
                dataDetectorTypeString.append("LOOKUP_SUGGESTION")
            }
            if type.contains(.spotlightSuggestion) {
                dataDetectorTypeString.append("SPOTLIGHT_SUGGESTION")
            }
        }
        if dataDetectorTypeString.count == 0 {
            dataDetectorTypeString = ["NONE"]
        }
        return dataDetectorTypeString
    }
    
    static public func getDecelerationRate(type: String) -> UIScrollView.DecelerationRate {
        switch type {
            case "NORMAL":
                return .normal
            case "FAST":
                return .fast
            default:
                return .normal
        }
    }
    
    static public func getDecelerationRateString(type: UIScrollView.DecelerationRate) -> String {
        switch type {
            case .normal:
                return "NORMAL"
            case .fast:
                return "FAST"
            default:
                return "NORMAL"
        }
    }
    
    public static func preWKWebViewConfiguration(options: InAppWebViewOptions?) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        configuration.processPool = WKProcessPoolManager.sharedProcessPool
        
        if let options = options {
            configuration.allowsInlineMediaPlayback = options.allowsInlineMediaPlayback
            configuration.suppressesIncrementalRendering = options.suppressesIncrementalRendering
            configuration.selectionGranularity = WKSelectionGranularity.init(rawValue: options.selectionGranularity)!
            
            if #available(iOS 9.0, *) {
                if options.incognito {
                    configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                } else if options.cacheEnabled {
                    configuration.websiteDataStore = WKWebsiteDataStore.default()
                }
            }
            
            if #available(iOS 10.0, *) {
                configuration.ignoresViewportScaleLimits = options.ignoresViewportScaleLimits
                
                var dataDetectorTypes = WKDataDetectorTypes.init(rawValue: 0)
                for type in options.dataDetectorTypes {
                    let dataDetectorType = InAppWebView.getDataDetectorType(type: type)
                    dataDetectorTypes = WKDataDetectorTypes(rawValue: dataDetectorTypes.rawValue | dataDetectorType.rawValue)
                }
                configuration.dataDetectorTypes = dataDetectorTypes
                
                configuration.mediaTypesRequiringUserActionForPlayback = options.mediaPlaybackRequiresUserGesture ? .all : []
            } else {
                // Fallback on earlier versions
                configuration.mediaPlaybackRequiresUserAction = options.mediaPlaybackRequiresUserGesture
            }
            
            if #available(iOS 11.0, *) {
                for scheme in options.resourceCustomSchemes {
                    configuration.setURLSchemeHandler(CustomeSchemeHandler(), forURLScheme: scheme)
                }
                if options.sharedCookiesEnabled {
                    // More info to sending cookies with WKWebView
                    // https://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303
                    // Set Cookies in iOS 11 and above, initialize websiteDataStore before setting cookies
                    // See also https://forums.developer.apple.com/thread/97194
                    // check if websiteDataStore has not been initialized before
                    if(!options.incognito && options.cacheEnabled) {
                        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                    }
                    for cookie in HTTPCookieStorage.shared.cookies ?? [] {
                        configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
                    }
                }
            }
        }
        
        return configuration
    }
    
    @objc func onCreateContextMenu() {
        let mapSorted = SharedLastTouchPointTimestamp.sorted { $0.value > $1.value }
        if (mapSorted.first?.key != self) {
            return
        }
        
        contextMenuIsShowing = true
        
        var arguments: [String: Any?] = [
            "hitTestResult": nil
        ]
        if let lastLongPressTouhLocation = lastLongPressTouchPoint {
            if configuration.preferences.javaScriptEnabled {
                self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint(\(lastLongPressTouhLocation.x),\(lastLongPressTouhLocation.y))", completionHandler: {(value, error) in
                    if error != nil {
                        print("Long press gesture recognizer error: \(error?.localizedDescription ?? "")")
                    } else {
                        let hitTestResult = value as! [String: Any?]
                        arguments["hitTestResult"] = hitTestResult
                        self.channel?.invokeMethod("onCreateContextMenu", arguments: arguments)
                    }
                })
            } else {
                channel?.invokeMethod("onCreateContextMenu", arguments: arguments)
            }
        } else {
            channel?.invokeMethod("onCreateContextMenu", arguments: arguments)
        }
    }
    
    @objc func onHideContextMenu() {
        if contextMenuIsShowing == false {
            return
        }
        
        contextMenuIsShowing = false
        
        let arguments: [String: Any] = [:]
        channel?.invokeMethod("onHideContextMenu", arguments: arguments)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            let progress = Int(estimatedProgress * 100)
            onProgressChanged(progress: progress)
        } else if keyPath == #keyPath(WKWebView.url) && change?[NSKeyValueChangeKey.newKey] is URL {
            let newUrl = change?[NSKeyValueChangeKey.newKey] as? URL
            onUpdateVisitedHistory(url: newUrl?.absoluteString)
        } else if keyPath == #keyPath(WKWebView.title) && change?[NSKeyValueChangeKey.newKey] is String {
            let newTitle = change?[NSKeyValueChangeKey.newKey] as? String
            onTitleChanged(title: newTitle)
       }
        replaceGestureHandlerIfNeeded()
    }
    
    public func goBackOrForward(steps: Int) {
        if canGoBackOrForward(steps: steps) {
            if (steps > 0) {
                let index = steps - 1
                go(to: self.backForwardList.forwardList[index])
            }
            else if (steps < 0){
                let backListLength = self.backForwardList.backList.count
                let index = backListLength + steps
                go(to: self.backForwardList.backList[index])
            }
        }
    }
    
    public func canGoBackOrForward(steps: Int) -> Bool {
        let currentIndex = self.backForwardList.backList.count
        return (steps >= 0)
            ? steps <= self.backForwardList.forwardList.count
            : currentIndex + steps >= 0
    }
    
    public func takeScreenshot (completionHandler: @escaping (_ screenshot: Data?) -> Void) {
        if #available(iOS 11.0, *) {
            takeSnapshot(with: nil, completionHandler: {(image, error) -> Void in
                var imageData: Data? = nil
                if let screenshot = image {
                    imageData = screenshot.pngData()!
                }
                completionHandler(imageData)
            })
        } else {
            completionHandler(nil)
        }
    }
    
    public func loadUrl(url: URL, headers: [String: String]?) {
        var request = URLRequest(url: url)
        currentURL = url
        if headers != nil {
            if let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
                for (key, value) in headers! {
                    mutableRequest.setValue(value, forHTTPHeaderField: key)
                }
                request = mutableRequest as URLRequest
            }
        }
        load(request)
    }
    
    public func postUrl(url: URL, postData: Data, completionHandler: @escaping () -> Void) {
        var request = URLRequest(url: url)
        currentURL = url
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
            var returnString = ""
            if data != nil {
                returnString = String(data: data!, encoding: .utf8) ?? ""
            }
            DispatchQueue.main.async(execute: {() -> Void in
                self.loadHTMLString(returnString, baseURL: url)
                completionHandler()
            })
        }
        task.resume()
    }
    
    public func loadData(data: String, mimeType: String, encoding: String, baseUrl: String) {
        let url = URL(string: baseUrl)!
        currentURL = url
        if #available(iOS 9.0, *) {
            load(data.data(using: .utf8)!, mimeType: mimeType, characterEncodingName: encoding, baseURL: url)
        } else {
            loadHTMLString(data, baseURL: url)
        }
    }
    
    public func loadFile(url: String, headers: [String: String]?) throws {
        let key = SwiftFlutterPlugin.instance!.registrar!.lookupKey(forAsset: url)
        let assetURL = Bundle.main.url(forResource: key, withExtension: nil)
        if assetURL == nil {
            throw NSError(domain: url + " asset file cannot be found!", code: 0)
        }
        loadUrl(url: assetURL!, headers: headers)
    }
    
    func setOptions(newOptions: InAppWebViewOptions, newOptionsMap: [String: Any]) {
        
        if newOptionsMap["transparentBackground"] != nil && options?.transparentBackground != newOptions.transparentBackground {
            if newOptions.transparentBackground {
                isOpaque = false
                backgroundColor = UIColor.clear
                scrollView.backgroundColor = UIColor.clear
            } else {
                isOpaque = true
                backgroundColor = nil
                scrollView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
        if newOptionsMap["disallowOverScroll"] != nil && options?.disallowOverScroll != newOptions.disallowOverScroll {
            if responds(to: #selector(getter: scrollView)) {
                scrollView.bounces = !newOptions.disallowOverScroll
            }
            else {
                for subview: UIView in subviews {
                    if subview is UIScrollView {
                        (subview as! UIScrollView).bounces = !newOptions.disallowOverScroll
                    }
                }
            }
        }
        
        if #available(iOS 9.0, *) {
            if (newOptionsMap["incognito"] != nil && options?.incognito != newOptions.incognito && newOptions.incognito) {
                configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            } else if (newOptionsMap["cacheEnabled"] != nil && options?.cacheEnabled != newOptions.cacheEnabled && newOptions.cacheEnabled) {
                configuration.websiteDataStore = WKWebsiteDataStore.default()
            }
        }
        
        if #available(iOS 11.0, *) {
            if (newOptionsMap["sharedCookiesEnabled"] != nil && options?.sharedCookiesEnabled != newOptions.sharedCookiesEnabled && newOptions.sharedCookiesEnabled) {
                if(!newOptions.incognito && !newOptions.cacheEnabled) {
                    configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                }
                for cookie in HTTPCookieStorage.shared.cookies ?? [] {
                    configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
                }
            }
            if newOptionsMap["accessibilityIgnoresInvertColors"] != nil && options?.accessibilityIgnoresInvertColors != newOptions.accessibilityIgnoresInvertColors {
                accessibilityIgnoresInvertColors = newOptions.accessibilityIgnoresInvertColors
            }
            if newOptionsMap["contentInsetAdjustmentBehavior"] != nil && options?.contentInsetAdjustmentBehavior != newOptions.contentInsetAdjustmentBehavior {
                scrollView.contentInsetAdjustmentBehavior =
                    UIScrollView.ContentInsetAdjustmentBehavior.init(rawValue: newOptions.contentInsetAdjustmentBehavior)!
            }
        }
        
        if newOptionsMap["enableViewportScale"] != nil && options?.enableViewportScale != newOptions.enableViewportScale {
            var jscript = ""
            if (newOptions.enableViewportScale) {
                jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            } else {
                jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', window.\(JAVASCRIPT_BRIDGE_NAME)._originalViewPortMetaTagContent); document.getElementsByTagName('head')[0].appendChild(meta);"
            }
            evaluateJavaScript(jscript, completionHandler: nil)
        }
        
        if newOptionsMap["supportZoom"] != nil && options?.supportZoom != newOptions.supportZoom {
            var jscript = ""
            if (newOptions.supportZoom) {
                jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', window.\(JAVASCRIPT_BRIDGE_NAME)._originalViewPortMetaTagContent); document.getElementsByTagName('head')[0].appendChild(meta);"
            } else {
                jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);"
            }
            evaluateJavaScript(jscript, completionHandler: nil)
        }
        
        if newOptionsMap["useOnLoadResource"] != nil && options?.useOnLoadResource != newOptions.useOnLoadResource && newOptions.useOnLoadResource {
            let placeholderValue = newOptions.useOnLoadResource ? "true" : "false"
            evaluateJavaScript(enableVariableForOnLoadResourceJS.replacingOccurrences(of: "$PLACEHOLDER_VALUE", with: placeholderValue), completionHandler: nil)
        }
        
        if newOptionsMap["useShouldInterceptAjaxRequest"] != nil && options?.useShouldInterceptAjaxRequest != newOptions.useShouldInterceptAjaxRequest && newOptions.useShouldInterceptAjaxRequest {
            let placeholderValue = newOptions.useShouldInterceptAjaxRequest ? "true" : "false"
            evaluateJavaScript(enableVariableForShouldInterceptAjaxRequestJS.replacingOccurrences(of: "$PLACEHOLDER_VALUE", with: placeholderValue), completionHandler: nil)
        }
        
        if newOptionsMap["useShouldInterceptFetchRequest"] != nil && options?.useShouldInterceptFetchRequest != newOptions.useShouldInterceptFetchRequest && newOptions.useShouldInterceptFetchRequest {
            let placeholderValue = newOptions.useShouldInterceptFetchRequest ? "true" : "false"
            evaluateJavaScript(enableVariableForShouldInterceptFetchRequestsJS.replacingOccurrences(of: "$PLACEHOLDER_VALUE", with: placeholderValue), completionHandler: nil)
        }
        
        if newOptionsMap["mediaPlaybackRequiresUserGesture"] != nil && options?.mediaPlaybackRequiresUserGesture != newOptions.mediaPlaybackRequiresUserGesture {
            if #available(iOS 10.0, *) {
                configuration.mediaTypesRequiringUserActionForPlayback = (newOptions.mediaPlaybackRequiresUserGesture) ? .all : []
            } else {
                // Fallback on earlier versions
                configuration.mediaPlaybackRequiresUserAction = newOptions.mediaPlaybackRequiresUserGesture
            }
        }
        
        if newOptionsMap["allowsInlineMediaPlayback"] != nil && options?.allowsInlineMediaPlayback != newOptions.allowsInlineMediaPlayback {
            configuration.allowsInlineMediaPlayback = newOptions.allowsInlineMediaPlayback
        }
        
        if newOptionsMap["suppressesIncrementalRendering"] != nil && options?.suppressesIncrementalRendering != newOptions.suppressesIncrementalRendering {
            configuration.suppressesIncrementalRendering = newOptions.suppressesIncrementalRendering
        }
        
        if newOptionsMap["allowsBackForwardNavigationGestures"] != nil && options?.allowsBackForwardNavigationGestures != newOptions.allowsBackForwardNavigationGestures {
            allowsBackForwardNavigationGestures = newOptions.allowsBackForwardNavigationGestures
        }
        
        if newOptionsMap["javaScriptCanOpenWindowsAutomatically"] != nil && options?.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically {
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = newOptions.javaScriptCanOpenWindowsAutomatically
        }
        
        if newOptionsMap["javaScriptEnabled"] != nil && options?.javaScriptEnabled != newOptions.javaScriptEnabled {
            configuration.preferences.javaScriptEnabled = newOptions.javaScriptEnabled
        }
        
        if newOptionsMap["minimumFontSize"] != nil && options?.minimumFontSize != newOptions.minimumFontSize {
            configuration.preferences.minimumFontSize = CGFloat(newOptions.minimumFontSize)
        }
        
        if newOptionsMap["selectionGranularity"] != nil && options?.selectionGranularity != newOptions.selectionGranularity {
            configuration.selectionGranularity = WKSelectionGranularity.init(rawValue: newOptions.selectionGranularity)!
        }
        
        if #available(iOS 10.0, *) {
            if newOptionsMap["ignoresViewportScaleLimits"] != nil && options?.ignoresViewportScaleLimits != newOptions.ignoresViewportScaleLimits {
                configuration.ignoresViewportScaleLimits = newOptions.ignoresViewportScaleLimits
            }
            
            if newOptionsMap["dataDetectorTypes"] != nil && options?.dataDetectorTypes != newOptions.dataDetectorTypes {
                var dataDetectorTypes = WKDataDetectorTypes.init(rawValue: 0)
                for type in newOptions.dataDetectorTypes {
                    let dataDetectorType = InAppWebView.getDataDetectorType(type: type)
                    dataDetectorTypes = WKDataDetectorTypes(rawValue: dataDetectorTypes.rawValue | dataDetectorType.rawValue)
                }
                configuration.dataDetectorTypes = dataDetectorTypes
            }
        }
        
        if #available(iOS 13.0, *) {
            if newOptionsMap["isFraudulentWebsiteWarningEnabled"] != nil && options?.isFraudulentWebsiteWarningEnabled != newOptions.isFraudulentWebsiteWarningEnabled {
                configuration.preferences.isFraudulentWebsiteWarningEnabled = newOptions.isFraudulentWebsiteWarningEnabled
            }
            if newOptionsMap["preferredContentMode"] != nil && options?.preferredContentMode != newOptions.preferredContentMode {
                configuration.defaultWebpagePreferences.preferredContentMode = WKWebpagePreferences.ContentMode(rawValue: newOptions.preferredContentMode)!
            }
            if newOptionsMap["automaticallyAdjustsScrollIndicatorInsets"] != nil && options?.automaticallyAdjustsScrollIndicatorInsets != newOptions.automaticallyAdjustsScrollIndicatorInsets {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = newOptions.automaticallyAdjustsScrollIndicatorInsets
            }
        }
        
        if newOptionsMap["disableVerticalScroll"] != nil && options?.disableVerticalScroll != newOptions.disableVerticalScroll {
            scrollView.showsVerticalScrollIndicator = !newOptions.disableVerticalScroll
        }
        if newOptionsMap["disableHorizontalScroll"] != nil && options?.disableHorizontalScroll != newOptions.disableHorizontalScroll {
            scrollView.showsHorizontalScrollIndicator = !newOptions.disableHorizontalScroll
        }
        
        if newOptionsMap["verticalScrollBarEnabled"] != nil && options?.verticalScrollBarEnabled != newOptions.verticalScrollBarEnabled {
            scrollView.showsVerticalScrollIndicator = newOptions.verticalScrollBarEnabled
        }
        if newOptionsMap["horizontalScrollBarEnabled"] != nil && options?.horizontalScrollBarEnabled != newOptions.horizontalScrollBarEnabled {
            scrollView.showsHorizontalScrollIndicator = newOptions.horizontalScrollBarEnabled
        }
        
        if newOptionsMap["decelerationRate"] != nil && options?.decelerationRate != newOptions.decelerationRate {
            scrollView.decelerationRate = InAppWebView.getDecelerationRate(type: newOptions.decelerationRate)
        }
        if newOptionsMap["alwaysBounceVertical"] != nil && options?.alwaysBounceVertical != newOptions.alwaysBounceVertical {
            scrollView.alwaysBounceVertical = newOptions.alwaysBounceVertical
        }
        if newOptionsMap["alwaysBounceHorizontal"] != nil && options?.alwaysBounceHorizontal != newOptions.alwaysBounceHorizontal {
            scrollView.alwaysBounceHorizontal = newOptions.alwaysBounceHorizontal
        }
        if newOptionsMap["scrollsToTop"] != nil && options?.scrollsToTop != newOptions.scrollsToTop {
            scrollView.scrollsToTop = newOptions.scrollsToTop
        }
        if newOptionsMap["isPagingEnabled"] != nil && options?.isPagingEnabled != newOptions.isPagingEnabled {
            scrollView.scrollsToTop = newOptions.isPagingEnabled
        }
        if newOptionsMap["maximumZoomScale"] != nil && options?.maximumZoomScale != newOptions.maximumZoomScale {
            scrollView.maximumZoomScale = CGFloat(newOptions.maximumZoomScale)
        }
        if newOptionsMap["minimumZoomScale"] != nil && options?.minimumZoomScale != newOptions.minimumZoomScale {
            scrollView.minimumZoomScale = CGFloat(newOptions.minimumZoomScale)
        }
        
        if #available(iOS 9.0, *) {
            if newOptionsMap["allowsLinkPreview"] != nil && options?.allowsLinkPreview != newOptions.allowsLinkPreview {
                allowsLinkPreview = newOptions.allowsLinkPreview
            }
            if newOptionsMap["allowsAirPlayForMediaPlayback"] != nil && options?.allowsAirPlayForMediaPlayback != newOptions.allowsAirPlayForMediaPlayback {
                configuration.allowsAirPlayForMediaPlayback = newOptions.allowsAirPlayForMediaPlayback
            }
            if newOptionsMap["allowsPictureInPictureMediaPlayback"] != nil && options?.allowsPictureInPictureMediaPlayback != newOptions.allowsPictureInPictureMediaPlayback {
                configuration.allowsPictureInPictureMediaPlayback = newOptions.allowsPictureInPictureMediaPlayback
            }
            if newOptionsMap["applicationNameForUserAgent"] != nil && options?.applicationNameForUserAgent != newOptions.applicationNameForUserAgent && newOptions.applicationNameForUserAgent != "" {
                configuration.applicationNameForUserAgent = newOptions.applicationNameForUserAgent
            }
            if newOptionsMap["userAgent"] != nil && options?.userAgent != newOptions.userAgent && newOptions.userAgent != "" {
                customUserAgent = newOptions.userAgent
            }
        }
        
        if newOptionsMap["clearCache"] != nil && newOptions.clearCache {
            clearCache()
        }
        
        if #available(iOS 11.0, *), newOptionsMap["contentBlockers"] != nil {
            configuration.userContentController.removeAllContentRuleLists()
            let contentBlockers = newOptions.contentBlockers
            if contentBlockers.count > 0 {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: contentBlockers, options: [])
                    let blockRules = String(data: jsonData, encoding: String.Encoding.utf8)
                    WKContentRuleListStore.default().compileContentRuleList(
                        forIdentifier: "ContentBlockingRules",
                        encodedContentRuleList: blockRules) { (contentRuleList, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            self.configuration.userContentController.add(contentRuleList!)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        self.options = newOptions
    }
    
    func getOptions() -> [String: Any?]? {
        if (self.options == nil) {
            return nil
        }
        return self.options!.getRealOptions(obj: self)
    }
    
    public func clearCache() {
        if #available(iOS 9.0, *) {
            //let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("can't clear cache")
            }
            URLCache.shared.removeAllCachedResponses()
        }
    }
    
    public func injectDeferredObject(source: String, withWrapper jsWrapper: String?, result: FlutterResult?) {
        var jsToInject = source
        if let wrapper = jsWrapper {
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
            let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
            let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.count ?? 0) - 2))
            jsToInject = String(format: wrapper, sourceString!)
        }
        evaluateJavaScript(jsToInject, completionHandler: {(value, error) in
            if result == nil {
                return
            }
            
            if error != nil {
                let userInfo = (error! as NSError).userInfo
                self.onConsoleMessage(message: userInfo["WKJavaScriptExceptionMessage"] as? String ?? "", messageLevel: 3)
            }
            
            if value == nil {
                result!(nil)
                return
            }
            
            result!(value)
        })
    }
    
    public func evaluateJavascript(source: String, result: FlutterResult?) {
        injectDeferredObject(source: source, withWrapper: nil, result: result)
    }
    
    public func injectJavascriptFileFromUrl(urlFile: String) {
        let jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(source: urlFile, withWrapper: jsWrapper, result: nil)
    }
    
    public func injectCSSCode(source: String) {
        let jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(source: source, withWrapper: jsWrapper, result: nil)
    }
    
    public func injectCSSFileFromUrl(urlFile: String) {
        let jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet', c.type='text/css'; c.href = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(source: urlFile, withWrapper: jsWrapper, result: nil)
    }
    
    public func getCopyBackForwardList() -> [String: Any] {
        let currentList = backForwardList
        let currentIndex = currentList.backList.count
        var completeList = currentList.backList
        if currentList.currentItem != nil {
            completeList.append(currentList.currentItem!)
        }
        completeList.append(contentsOf: currentList.forwardList)
        
        var history: [[String: String]] = []
        
        for historyItem in completeList {
            var historyItemMap: [String: String] = [:]
            historyItemMap["originalUrl"] = historyItem.initialURL.absoluteString
            historyItemMap["title"] = historyItem.title
            historyItemMap["url"] = historyItem.url.absoluteString
            history.append(historyItemMap)
        }
        
        var result: [String: Any] = [:]
        result["history"] = history
        result["currentIndex"] = currentIndex
        
        return result;
    }
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            
            if activateShouldOverrideUrlLoading && (options?.useShouldOverrideUrlLoading)! {
                
                let isForMainFrame = navigationAction.targetFrame?.isMainFrame ?? false
                
                shouldOverrideUrlLoading(url: url, method: navigationAction.request.httpMethod, headers: navigationAction.request.allHTTPHeaderFields, isForMainFrame: isForMainFrame, navigationType: navigationAction.navigationType, result: { (result) -> Void in
                    if result is FlutterError {
                        print((result as! FlutterError).message ?? "")
                        decisionHandler(.allow)
                        return
                    }
                    else if (result as? NSObject) == FlutterMethodNotImplemented {
                        self.updateUrlTextFieldForIABController(navigationAction: navigationAction)
                        decisionHandler(.allow)
                        return
                    }
                    else {
                        var response: [String: Any]
                        if let r = result {
                            response = r as! [String: Any]
                            var action = response["action"] as? Int
                            action = action != nil ? action : 0;
                            switch action {
                                case 1:
                                    self.updateUrlTextFieldForIABController(navigationAction: navigationAction)
                                    decisionHandler(.allow)
                                    break
                                default:
                                    decisionHandler(.cancel)
                            }
                            return;
                        }
                        self.updateUrlTextFieldForIABController(navigationAction: navigationAction)
                        decisionHandler(.allow)
                    }
                })
                return
                
            }
            
            updateUrlTextFieldForIABController(navigationAction: navigationAction)
        }
        
        if !activateShouldOverrideUrlLoading {
            activateShouldOverrideUrlLoading = true
        }
        
        decisionHandler(.allow)
    }
    
    public func updateUrlTextFieldForIABController(navigationAction: WKNavigationAction) {
        if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .backForward {
            currentURL = url
            if IABController != nil {
                IABController!.updateUrlTextField(url: currentURL?.absoluteString ?? "")
            }
        }
    }
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.isForMainFrame, let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode >= 400 {
                onLoadHttpError(url: response.url?.absoluteString, statusCode: response.statusCode, description: "")
            }
        }
        
        if (options?.useOnDownloadStart)! {
            let mimeType = navigationResponse.response.mimeType
            if let url = navigationResponse.response.url, navigationResponse.isForMainFrame {
                if mimeType != nil && !mimeType!.starts(with: "text/") {
                    onDownloadStart(url: url.absoluteString)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.x509CertificateData = nil
        
        self.startPageTime = currentTimeInMilliSeconds()
        
        onLoadStart(url: url?.absoluteString)
        
        if IABController != nil {
            // loading url, start spinner, update back/forward
            IABController!.backButton.isEnabled = canGoBack
            IABController!.forwardButton.isEnabled = canGoForward
            
            if (IABController!.browserOptions?.spinner)! {
                IABController!.spinner.startAnimating()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        currentURL = url
        InAppWebView.credentialsProposed = []
        evaluateJavaScript(platformReadyJS, completionHandler: nil)
        onLoadStop(url: url?.absoluteString)
                
        if IABController != nil {
            IABController!.updateUrlTextField(url: currentURL?.absoluteString ?? "")
            IABController!.backButton.isEnabled = canGoBack
            IABController!.forwardButton.isEnabled = canGoForward
            IABController!.spinner.stopAnimating()
        }
    }
    
    public func webView(_ view: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        webView(view, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        InAppWebView.credentialsProposed = []
        
        var urlError = url?.absoluteString
        if let info = error._userInfo as? [String: Any] {
            if let failingUrl = info[NSURLErrorFailingURLErrorKey] as? URL {
                urlError = failingUrl.absoluteString
            }
            if let failingUrlString = info[NSURLErrorFailingURLStringErrorKey] as? String {
                urlError = failingUrlString
            }
        }
        
        onLoadError(url: urlError, error: error)
        
        if IABController != nil {
            IABController!.backButton.isEnabled = canGoBack
            IABController!.forwardButton.isEnabled = canGoForward
            IABController!.spinner.stopAnimating()
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic ||
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault ||
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
            let host = challenge.protectionSpace.host
            let prot = challenge.protectionSpace.protocol
            let realm = challenge.protectionSpace.realm
            let port = challenge.protectionSpace.port
            onReceivedHttpAuthRequest(challenge: challenge, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    completionHandler(.performDefaultHandling, nil)
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 0:
                                InAppWebView.credentialsProposed = []
                                // used .performDefaultHandling to mantain consistency with Android
                                // because .cancelAuthenticationChallenge will call webView(_:didFail:withError:)
                                completionHandler(.performDefaultHandling, nil)
                                //completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            case 1:
                                let username = response["username"] as! String
                                let password = response["password"] as! String
                                let permanentPersistence = response["permanentPersistence"] as? Bool ?? false
                                let persistence = (permanentPersistence) ? URLCredential.Persistence.permanent : URLCredential.Persistence.forSession
                                let credential = URLCredential(user: username, password: password, persistence: persistence)
                                completionHandler(.useCredential, credential)
                                break
                            case 2:
                                if InAppWebView.credentialsProposed.count == 0 {
                                    for (protectionSpace, credentials) in CredentialDatabase.credentialStore!.allCredentials {
                                        if protectionSpace.host == host && protectionSpace.realm == realm &&
                                        protectionSpace.protocol == prot && protectionSpace.port == port {
                                            for credential in credentials {
                                                InAppWebView.credentialsProposed.append(credential.value)
                                            }
                                            break
                                        }
                                    }
                                }
                                if InAppWebView.credentialsProposed.count == 0, let credential = challenge.proposedCredential {
                                    InAppWebView.credentialsProposed.append(credential)
                                }
                                
                                if let credential = InAppWebView.credentialsProposed.popLast() {
                                    completionHandler(.useCredential, credential)
                                }
                                else {
                                    completionHandler(.performDefaultHandling, nil)
                                }
                                break
                            default:
                                InAppWebView.credentialsProposed = []
                                completionHandler(.performDefaultHandling, nil)
                        }
                        return;
                    }
                    completionHandler(.performDefaultHandling, nil)
                }
            })
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {

            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            onReceivedServerTrustAuthRequest(challenge: challenge, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    completionHandler(.performDefaultHandling, nil)
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 0:
                                InAppWebView.credentialsProposed = []
                                completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            case 1:
                                let exceptions = SecTrustCopyExceptions(serverTrust)
                                SecTrustSetExceptions(serverTrust, exceptions)
                                let credential = URLCredential(trust: serverTrust)
                                completionHandler(.useCredential, credential)
                                break
                            default:
                                InAppWebView.credentialsProposed = []
                                completionHandler(.performDefaultHandling, nil)
                        }
                        return;
                    }
                    completionHandler(.performDefaultHandling, nil)
                }
            })
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            onReceivedClientCertRequest(challenge: challenge, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    completionHandler(.performDefaultHandling, nil)
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 0:
                                completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            case 1:
                                let certificatePath = response["certificatePath"] as! String;
                                let certificatePassword = response["certificatePassword"] as? String ?? "";
                                
                                let key = SwiftFlutterPlugin.instance!.registrar!.lookupKey(forAsset: certificatePath)
                                let path = Bundle.main.path(forResource: key, ofType: nil)!
                                let PKCS12Data = NSData(contentsOfFile: path)!
                                
                                if let identityAndTrust: IdentityAndTrust = self.extractIdentity(PKCS12Data: PKCS12Data, password: certificatePassword) {
                                    let urlCredential: URLCredential = URLCredential(
                                        identity: identityAndTrust.identityRef,
                                        certificates: identityAndTrust.certArray as? [AnyObject],
                                        persistence: URLCredential.Persistence.forSession);
                                    completionHandler(.useCredential, urlCredential)
                                } else {
                                    completionHandler(.performDefaultHandling, nil)
                                }
                                break
                            case 2:
                                completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            default:
                                completionHandler(.performDefaultHandling, nil)
                        }
                        return;
                    }
                    completionHandler(.performDefaultHandling, nil)
                }
            })
        }
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    struct IdentityAndTrust {

        var identityRef:SecIdentity
        var trust:SecTrust
        var certArray:AnyObject
    }

    func extractIdentity(PKCS12Data:NSData, password: String) -> IdentityAndTrust? {
        var identityAndTrust:IdentityAndTrust?
        var securityError:OSStatus = errSecSuccess

        var importResult: CFArray? = nil
        securityError = SecPKCS12Import(
            PKCS12Data as NSData,
            [kSecImportExportPassphrase as String: password] as NSDictionary,
            &importResult
        )

        if securityError == errSecSuccess {
            let certItems:CFArray = importResult! as CFArray;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = (identityPointer as! SecIdentity?)!;
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
            }
        } else {
            print("Security Error: " + securityError.description)
            if #available(iOS 11.3, *) {
                print(SecCopyErrorMessageString(securityError,nil) ?? "")
            }
        }
        return identityAndTrust;
    }

    
    func createAlertDialog(message: String?, responseMessage: String?, confirmButtonTitle: String?, completionHandler: @escaping () -> Void) {
        let title = responseMessage != nil && !responseMessage!.isEmpty ? responseMessage : message
        let okButton = confirmButtonTitle != nil && !confirmButtonTitle!.isEmpty ? confirmButtonTitle : NSLocalizedString("Ok", comment: "")
        let alertController = UIAlertController(title: title, message: nil,
                                                preferredStyle: UIAlertController.Style.alert);
        
        alertController.addAction(UIAlertAction(title: okButton, style: UIAlertAction.Style.default) {
            _ in completionHandler()}
        );
        
        let presentingViewController = ((self.IABController != nil) ? self.IABController! : self.window!.rootViewController!)
        presentingViewController.present(alertController, animated: true, completion: {})
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        if (isPausedTimers) {
            isPausedTimersCompletionHandler = completionHandler
            return
        }
        
        onJsAlert(frame: frame, message: message, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.createAlertDialog(message: message, responseMessage: nil, confirmButtonTitle: nil, completionHandler: completionHandler)
            }
            else {
                let response: [String: Any]
                var responseMessage: String?;
                var confirmButtonTitle: String?;
                
                if let r = result {
                    response = r as! [String: Any]
                    responseMessage = response["message"] as? String
                    confirmButtonTitle = response["confirmButtonTitle"] as? String
                    let handledByClient = response["handledByClient"] as? Bool
                    if handledByClient != nil, handledByClient! {
                        var action = response["action"] as? Int
                        action = action != nil ? action : 1;
                        switch action {
                            case 0:
                                completionHandler()
                                break
                            default:
                                completionHandler()
                        }
                        return;
                    }
                }
                
                self.createAlertDialog(message: message, responseMessage: responseMessage, confirmButtonTitle: confirmButtonTitle, completionHandler: completionHandler)
            }
        })
    }
    
    func createConfirmDialog(message: String?, responseMessage: String?, confirmButtonTitle: String?, cancelButtonTitle: String?, completionHandler: @escaping (Bool) -> Void) {
        let dialogMessage = responseMessage != nil && !responseMessage!.isEmpty ? responseMessage : message
        let okButton = confirmButtonTitle != nil && !confirmButtonTitle!.isEmpty ? confirmButtonTitle : NSLocalizedString("Ok", comment: "")
        let cancelButton = cancelButtonTitle != nil && !cancelButtonTitle!.isEmpty ? cancelButtonTitle : NSLocalizedString("Cancel", comment: "")
        
        let alertController = UIAlertController(title: nil, message: dialogMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okButton, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        
        let presentingViewController = ((self.IABController != nil) ? self.IABController! : self.window!.rootViewController!)
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {

        onJsConfirm(frame: frame, message: message, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.createConfirmDialog(message: message, responseMessage: nil, confirmButtonTitle: nil, cancelButtonTitle: nil, completionHandler: completionHandler)
            }
            else {
                let response: [String: Any]
                var responseMessage: String?;
                var confirmButtonTitle: String?;
                var cancelButtonTitle: String?;
                
                if let r = result {
                    response = r as! [String: Any]
                    responseMessage = response["message"] as? String
                    confirmButtonTitle = response["confirmButtonTitle"] as? String
                    cancelButtonTitle = response["cancelButtonTitle"] as? String
                    let handledByClient = response["handledByClient"] as? Bool
                    if handledByClient != nil, handledByClient! {
                        var action = response["action"] as? Int
                        action = action != nil ? action : 1;
                        switch action {
                            case 0:
                                completionHandler(true)
                                break
                            case 1:
                                completionHandler(false)
                                break
                            default:
                                completionHandler(false)
                        }
                        return;
                    }
                }
                self.createConfirmDialog(message: message, responseMessage: responseMessage, confirmButtonTitle: confirmButtonTitle, cancelButtonTitle: cancelButtonTitle, completionHandler: completionHandler)
            }
        })
    }

    func createPromptDialog(message: String, defaultValue: String?, responseMessage: String?, confirmButtonTitle: String?, cancelButtonTitle: String?, value: String?, completionHandler: @escaping (String?) -> Void) {
        let dialogMessage = responseMessage != nil && !responseMessage!.isEmpty ? responseMessage : message
        let okButton = confirmButtonTitle != nil && !confirmButtonTitle!.isEmpty ? confirmButtonTitle : NSLocalizedString("Ok", comment: "")
        let cancelButton = cancelButtonTitle != nil && !cancelButtonTitle!.isEmpty ? cancelButtonTitle : NSLocalizedString("Cancel", comment: "")
        
        let alertController = UIAlertController(title: nil, message: dialogMessage, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultValue
        }
        
        alertController.addAction(UIAlertAction(title: okButton, style: .default, handler: { (action) in
            if let v = value {
                completionHandler(v)
            }
            else if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler("")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (action) in
            completionHandler(nil)
        }))
        
        let presentingViewController = ((self.IABController != nil) ? self.IABController! : self.window!.rootViewController!)
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt message: String, defaultText defaultValue: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        onJsPrompt(frame: frame, message: message, defaultValue: defaultValue, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.createPromptDialog(message: message, defaultValue: defaultValue, responseMessage: nil, confirmButtonTitle: nil, cancelButtonTitle: nil, value: nil, completionHandler: completionHandler)
            }
            else {
                let response: [String: Any]
                var responseMessage: String?;
                var confirmButtonTitle: String?;
                var cancelButtonTitle: String?;
                var value: String?;
                
                if let r = result {
                    response = r as! [String: Any]
                    responseMessage = response["message"] as? String
                    confirmButtonTitle = response["confirmButtonTitle"] as? String
                    cancelButtonTitle = response["cancelButtonTitle"] as? String
                    let handledByClient = response["handledByClient"] as? Bool
                    value = response["value"] as? String;
                    if handledByClient != nil, handledByClient! {
                        var action = response["action"] as? Int
                        action = action != nil ? action : 1;
                        switch action {
                            case 0:
                                completionHandler(value)
                                break
                            case 1:
                                completionHandler(nil)
                                break
                            default:
                                completionHandler(nil)
                        }
                        return;
                    }
                }
                
                self.createPromptDialog(message: message, defaultValue: defaultValue, responseMessage: responseMessage, confirmButtonTitle: confirmButtonTitle, cancelButtonTitle: cancelButtonTitle, value: value, completionHandler: completionHandler)
            }
        })
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let disableVerticalScroll = options?.disableVerticalScroll ?? false
        let disableHorizontalScroll = options?.disableHorizontalScroll ?? false
        if disableVerticalScroll && disableHorizontalScroll {
            scrollView.contentOffset = CGPoint(x: lastScrollX, y: lastScrollY);
        }
        else if disableVerticalScroll {
            if (scrollView.contentOffset.y >= 0 || scrollView.contentOffset.y < 0) {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: lastScrollY);
            }
        }
        else if disableHorizontalScroll {
            if (scrollView.contentOffset.x >= 0 || scrollView.contentOffset.x < 0) {
                scrollView.contentOffset = CGPoint(x: lastScrollX, y: scrollView.contentOffset.y);
            }
        }
        if navigationDelegate != nil && !(disableVerticalScroll && disableHorizontalScroll) {
            let x = Int(scrollView.contentOffset.x / scrollView.contentScaleFactor)
            let y = Int(scrollView.contentOffset.y / scrollView.contentScaleFactor)
            onScrollChanged(x: x, y: y)
        }
        setNeedsLayout()
        lastScrollX = scrollView.contentOffset.x
        lastScrollY = scrollView.contentOffset.y
    }
    
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                  for navigationAction: WKNavigationAction,
                  windowFeatures: WKWindowFeatures) -> WKWebView? {
        InAppWebView.windowAutoincrementId += 1
        let windowId = InAppWebView.windowAutoincrementId
        
        let windowWebView = InAppWebView(frame: CGRect.zero, configuration: configuration, IABController: nil, contextMenu: nil, channel: nil)
        windowWebView.windowId = windowId
        
        let webViewTransport = WebViewTransport(
            webView: windowWebView,
            request: navigationAction.request
        )

        InAppWebView.windowWebViews[windowId] = webViewTransport
        windowWebView.stopLoading()
        
        let arguments: [String: Any?] = [
            "url": navigationAction.request.url?.absoluteString,
            "windowId": windowId,
            "androidIsDialog": nil,
            "androidIsUserGesture": nil,
            "iosWKNavigationType": navigationAction.navigationType.rawValue,
            "iosIsForMainFrame": navigationAction.targetFrame?.isMainFrame ?? false
        ]
        channel?.invokeMethod("onCreateWindow", arguments: arguments, result: { (result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
                if InAppWebView.windowWebViews[windowId] != nil {
                    InAppWebView.windowWebViews.removeValue(forKey: windowId)
                }
                return
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.updateUrlTextFieldForIABController(navigationAction: navigationAction)
                if InAppWebView.windowWebViews[windowId] != nil {
                    InAppWebView.windowWebViews.removeValue(forKey: windowId)
                }
                return
            }
            else {
                var handledByClient = false
                if result != nil, result is Bool {
                    handledByClient = result as! Bool
                }
                if !handledByClient, InAppWebView.windowWebViews[windowId] != nil {
                    InAppWebView.windowWebViews.removeValue(forKey: windowId)
                }
            }
        })
        
        return windowWebView
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onCloseWindow", arguments: arguments)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        onWebContentProcessDidTerminate()
    }
    
    public func webView(_ webView: WKWebView,
                        didCommit navigation: WKNavigation!) {
        onPageCommitVisible(url: url?.absoluteString)
    }
    
    public func webView(_ webView: WKWebView,
                        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        onDidReceiveServerRedirectForProvisionalNavigation()
    }
    
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo,
//                        completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
//        print("contextMenuConfigurationForElement")
//        let actionProvider: UIContextMenuActionProvider = { _ in
//            let editMenu = UIMenu(title: "Edit...", children: [
//                UIAction(title: "Copy") { action in
//
//                },
//                UIAction(title: "Duplicate") { action in
//
//                }
//            ])
//            return UIMenu(title: "Title", children: [
//                UIAction(title: "Share") { action in
//
//                },
//                editMenu
//            ])
//        }
//        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
//        //completionHandler(contextMenuConfiguration)
//        completionHandler(nil)
////        onContextMenuConfigurationForElement(linkURL: elementInfo.linkURL?.absoluteString, result: nil/*{(result) -> Void in
////            if result is FlutterError {
////                print((result as! FlutterError).message ?? "")
////            }
////            else if (result as? NSObject) == FlutterMethodNotImplemented {
////                completionHandler(nil)
////            }
////            else {
////                var response: [String: Any]
////                if let r = result {
////                    response = r as! [String: Any]
////                    var action = response["action"] as? Int
////                    action = action != nil ? action : 0;
////                    switch action {
////                        case 0:
////                            break
////                        case 1:
////                            break
////                        default:
////                            completionHandler(nil)
////                    }
////                    return;
////                }
////                completionHandler(nil)
////            }
////        }*/)
//    }
////
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
//        print("contextMenuDidEndForElement")
//        print(elementInfo)
//        //onContextMenuDidEndForElement(linkURL: elementInfo.linkURL?.absoluteString)
//    }
//
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuForElement elementInfo: WKContextMenuElementInfo,
//                        willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
//        print("willCommitWithAnimator")
//        print(elementInfo)
////        onWillCommitWithAnimator(linkURL: elementInfo.linkURL?.absoluteString, result: nil/*{(result) -> Void in
////            if result is FlutterError {
////                print((result as! FlutterError).message ?? "")
////            }
////            else if (result as? NSObject) == FlutterMethodNotImplemented {
////
////            }
////            else {
////                var response: [String: Any]
////                if let r = result {
////                    response = r as! [String: Any]
////                    var action = response["action"] as? Int
////                    action = action != nil ? action : 0;
//////                    switch action {
//////                        case 0:
//////                            break
//////                        case 1:
//////                            break
//////                        default:
//////
//////                    }
////                    return;
////                }
////
////            }
////        }*/)
//    }
//
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
//        print("contextMenuWillPresentForElement")
//        print(elementInfo.linkURL)
//        //onContextMenuWillPresentForElement(linkURL: elementInfo.linkURL?.absoluteString)
//    }
    
    public func onLoadStart(url: String?) {
        let arguments: [String: Any?] = ["url": url]
        channel?.invokeMethod("onLoadStart", arguments: arguments)
    }
    
    public func onLoadStop(url: String?) {
        let arguments: [String: Any?] = ["url": url]
        channel?.invokeMethod("onLoadStop", arguments: arguments)
    }
    
    public func onLoadError(url: String?, error: Error) {
        let arguments: [String: Any?] = ["url": url, "code": error._code, "message": error.localizedDescription]
        channel?.invokeMethod("onLoadError", arguments: arguments)
    }
    
    public func onLoadHttpError(url: String?, statusCode: Int, description: String) {
        let arguments: [String: Any?] = ["url": url, "statusCode": statusCode, "description": description]
        channel?.invokeMethod("onLoadHttpError", arguments: arguments)
    }
    
    public func onProgressChanged(progress: Int) {
        let arguments: [String: Any] = ["progress": progress]
        channel?.invokeMethod("onProgressChanged", arguments: arguments)
    }
    
    public func onFindResultReceived(activeMatchOrdinal: Int, numberOfMatches: Int, isDoneCounting: Bool) {
        let arguments: [String : Any] = [
            "activeMatchOrdinal": activeMatchOrdinal,
            "numberOfMatches": numberOfMatches,
            "isDoneCounting": isDoneCounting
        ]
        channel?.invokeMethod("onFindResultReceived", arguments: arguments)
    }
    
    public func onScrollChanged(x: Int, y: Int) {
        let arguments: [String: Any] = ["x": x, "y": y]
        channel?.invokeMethod("onScrollChanged", arguments: arguments)
    }
    
    public func onDownloadStart(url: String) {
        let arguments: [String: Any] = ["url": url]
        channel?.invokeMethod("onDownloadStart", arguments: arguments)
    }
    
    public func onLoadResourceCustomScheme(scheme: String, url: String, result: FlutterResult?) {
        let arguments: [String: Any] = ["scheme": scheme, "url": url]
        channel?.invokeMethod("onLoadResourceCustomScheme", arguments: arguments, result: result)
    }
    
    public func shouldOverrideUrlLoading(url: URL, method: String?, headers: [String: String]?, isForMainFrame: Bool, navigationType: WKNavigationType, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": url.absoluteString,
            "method": method,
            "headers": headers,
            "isForMainFrame": isForMainFrame,
            "androidHasGesture": nil,
            "androidIsRedirect": nil,
            "iosWKNavigationType": navigationType.rawValue
        ]
        channel?.invokeMethod("shouldOverrideUrlLoading", arguments: arguments, result: result)
    }
    
    public func onReceivedHttpAuthRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "host": challenge.protectionSpace.host,
            "protocol": challenge.protectionSpace.protocol,
            "realm": challenge.protectionSpace.realm,
            "port": challenge.protectionSpace.port,
            "previousFailureCount": challenge.previousFailureCount
        ]
        channel?.invokeMethod("onReceivedHttpAuthRequest", arguments: arguments, result: result)
    }
    
    public func onReceivedServerTrustAuthRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        var serverCertificateData: NSData?
        let serverTrust = challenge.protectionSpace.serverTrust!
        
        var secResult = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &secResult);
        
        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let serverCertificateCFData = SecCertificateCopyData(serverCertificate)
            let data = CFDataGetBytePtr(serverCertificateCFData)
            let size = CFDataGetLength(serverCertificateCFData)
            serverCertificateData = NSData(bytes: data, length: size)
            if (x509CertificateData == nil) {
                x509CertificateData = Data(serverCertificateData!)
                InAppWebView.sslCertificateMap[challenge.protectionSpace.host] = x509CertificateData;
            }
        }
        
        let error = secResult != SecTrustResultType.proceed ? secResult.rawValue : nil
        
        var message = ""
        switch secResult {
            case .deny:
                message = "Indicates a user-configured deny; do not proceed."
                break
            case .fatalTrustFailure:
                message = "Indicates a trust failure which cannot be overridden by the user."
                break
            case .invalid:
                message = "Indicates an invalid setting or result."
                break
            case .otherError:
                message = "Indicates a failure other than that of trust evaluation."
                break
            case .recoverableTrustFailure:
                message = "Indicates a trust policy failure which can be overridden by the user."
                break
            case .unspecified:
                message = "Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified."
                break
            default:
                message = ""
        }
        
        let arguments: [String: Any?] = [
            "host": challenge.protectionSpace.host,
            "protocol": challenge.protectionSpace.protocol,
            "realm": challenge.protectionSpace.realm,
            "port": challenge.protectionSpace.port,
            "previousFailureCount": challenge.previousFailureCount,
            "sslCertificate": InAppWebView.getCertificateMap(x509Certificate:
                ((serverCertificateData != nil) ? Data(serverCertificateData!) : nil)),
            "androidError": nil,
            "iosError": error,
            "message": message,
        ]
        channel?.invokeMethod("onReceivedServerTrustAuthRequest", arguments: arguments, result: result)
    }
    
    public func onReceivedClientCertRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "host": challenge.protectionSpace.host,
            "protocol": challenge.protectionSpace.protocol,
            "realm": challenge.protectionSpace.realm,
            "port": challenge.protectionSpace.port
        ]
        channel?.invokeMethod("onReceivedClientCertRequest", arguments: arguments, result: result)
    }
    
    public func onJsAlert(frame: WKFrameInfo, message: String, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": frame.request.url?.absoluteString,
            "message": message,
            "iosIsMainFrame": frame.isMainFrame
        ]
        channel?.invokeMethod("onJsAlert", arguments: arguments, result: result)
    }
    
    public func onJsConfirm(frame: WKFrameInfo, message: String, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": frame.request.url?.absoluteString,
            "message": message,
            "iosIsMainFrame": frame.isMainFrame
        ]
        channel?.invokeMethod("onJsConfirm", arguments: arguments, result: result)
    }
    
    public func onJsPrompt(frame: WKFrameInfo, message: String, defaultValue: String?, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": frame.request.url?.absoluteString,
            "message": message,
            "defaultValue": defaultValue as Any,
            "iosIsMainFrame": frame.isMainFrame
        ]
        channel?.invokeMethod("onJsPrompt", arguments: arguments, result: result)
    }
    
    public func onConsoleMessage(message: String, messageLevel: Int) {
        let arguments: [String: Any] = ["message": message, "messageLevel": messageLevel]
        channel?.invokeMethod("onConsoleMessage", arguments: arguments)
    }
    
    public func onUpdateVisitedHistory(url: String?) {
        let arguments: [String: Any?] = [
            "url": url,
            "androidIsReload": nil
        ]
        channel?.invokeMethod("onUpdateVisitedHistory", arguments: arguments)
    }
    
    public func onTitleChanged(title: String?) {
        let arguments: [String: Any?] = [
            "title": title
        ]
        channel?.invokeMethod("onTitleChanged", arguments: arguments)
    }
    
    public func onLongPressHitTestResult(hitTestResult: [String: Any?]) {
        let arguments: [String: Any?] = [
            "hitTestResult": hitTestResult
        ]
        channel?.invokeMethod("onLongPressHitTestResult", arguments: arguments)
    }
    
    public func onCallJsHandler(handlerName: String, _callHandlerID: Int64, args: String) {
        let arguments: [String: Any] = ["handlerName": handlerName, "args": args]
        channel?.invokeMethod("onCallJsHandler", arguments: arguments, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {}
            else {
                var json = "null"
                if let r = result {
                    json = r as! String
                }
                
                self.evaluateJavaScript("""
if(window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)] != null) {
    window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)](\(json));
    delete window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)];
}
""", completionHandler: nil)
            }
        })
    }
    
    public func onWebContentProcessDidTerminate() {
        channel?.invokeMethod("onWebContentProcessDidTerminate", arguments: [])
    }
    
    public func onPageCommitVisible(url: String?) {
        let arguments: [String: Any?] = [
            "url": url
        ]
        channel?.invokeMethod("onPageCommitVisible", arguments: arguments)
    }
    
    public func onDidReceiveServerRedirectForProvisionalNavigation() {
        channel?.invokeMethod("onDidReceiveServerRedirectForProvisionalNavigation", arguments: [])
    }
    
    // https://stackoverflow.com/a/42840541/4637638
    public func isVideoPlayerWindow(_ notificationObject: AnyObject?) -> Bool {
        let nonVideoClasses = ["_UIAlertControllerShimPresenterWindow",
                               "UITextEffectsWindow",
                               "UIRemoteKeyboardWindow"]
        var isVideo = true
        if let obj = notificationObject {
            for nonVideoClass in nonVideoClasses {
                if let clazz = NSClassFromString(nonVideoClass) {
                    isVideo = isVideo && !(obj.isKind(of: clazz))
                }
            }
        }
        return isVideo
    }
    
    @objc func onEnterFullscreen(_ notification: Notification) {
        if (isVideoPlayerWindow(notification.object as AnyObject?)) {
            channel?.invokeMethod("onEnterFullscreen", arguments: [])
        }
    }
    
    @objc func onExitFullscreen(_ notification: Notification) {
        if (isVideoPlayerWindow(notification.object as AnyObject?)) {
            channel?.invokeMethod("onExitFullscreen", arguments: [])
        }
    }
    
//    public func onContextMenuConfigurationForElement(linkURL: String?, result: FlutterResult?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onContextMenuConfigurationForElement", arguments: arguments, result: result)
//    }
//
//    public func onContextMenuDidEndForElement(linkURL: String?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onContextMenuDidEndForElement", arguments: arguments)
//    }
//
//    public func onWillCommitWithAnimator(linkURL: String?, result: FlutterResult?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onWillCommitWithAnimator", arguments: arguments, result: result)
//    }
//
//    public func onContextMenuWillPresentForElement(linkURL: String?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onContextMenuWillPresentForElement", arguments: arguments)
//    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name.starts(with: "console") {
            var messageLevel = 1
            switch (message.name) {
                case "consoleLog":
                    messageLevel = 1
                    break;
                case "consoleDebug":
                    // on Android, console.debug is TIP
                    messageLevel = 0
                    break;
                case "consoleError":
                    messageLevel = 3
                    break;
                case "consoleInfo":
                    // on Android, console.info is LOG
                    messageLevel = 1
                    break;
                case "consoleWarn":
                    messageLevel = 2
                    break;
                default:
                    messageLevel = 1
                    break;
            }
            let body = message.body as! [String: Any?]
            let consoleMessage = body["message"] as! String
            
            let _windowId = body["_windowId"] as? Int64
            var webView = self
            if let wId = _windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                webView = webViewTransport.webView
            }
            webView.onConsoleMessage(message: consoleMessage, messageLevel: messageLevel)
        } else if message.name == "callHandler" {
            let body = message.body as! [String: Any?]
            let handlerName = body["handlerName"] as! String
            if handlerName == "onPrint" {
                printCurrentPage(printCompletionHandler: nil)
            }
            let _callHandlerID = body["_callHandlerID"] as! Int64
            let args = body["args"] as! String
            
            let _windowId = body["_windowId"] as? Int64
            var webView = self
            if let wId = _windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                webView = webViewTransport.webView
            }
            webView.onCallJsHandler(handlerName: handlerName, _callHandlerID: _callHandlerID, args: args)
        } else if message.name == "onFindResultReceived" {
            let body = message.body as! [String: Any?]
            let findResult = body["findResult"] as! [String: Any]
            let activeMatchOrdinal = findResult["activeMatchOrdinal"] as! Int
            let numberOfMatches = findResult["numberOfMatches"] as! Int
            let isDoneCounting = findResult["isDoneCounting"] as! Bool
            
            let _windowId = body["_windowId"] as? Int64
            var webView = self
            if let wId = _windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                webView = webViewTransport.webView
            }
            webView.onFindResultReceived(activeMatchOrdinal: activeMatchOrdinal, numberOfMatches: numberOfMatches, isDoneCounting: isDoneCounting)
        }
    }
    
    public func findAllAsync(find: String?, completionHandler: ((Any?, Error?) -> Void)?) {
        let startSearch = "wkwebview_FindAllAsync('\(find ?? "")');"
        evaluateJavaScript(startSearch, completionHandler: completionHandler)
    }

    public func findNext(forward: Bool, completionHandler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript("wkwebview_FindNext(\(forward ? "true" : "false"));", completionHandler: completionHandler)
    }

    public func clearMatches(completionHandler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript("wkwebview_ClearMatches();", completionHandler: completionHandler)
    }
    
    public func scrollTo(x: Int, y: Int, animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    public func scrollBy(x: Int, y: Int, animated: Bool) {
        let newX = CGFloat(x) + scrollView.contentOffset.x
        let newY = CGFloat(y) + scrollView.contentOffset.y
        scrollView.setContentOffset(CGPoint(x: newX, y: newY), animated: animated)
    }
    
    
    public func pauseTimers() {
        if !isPausedTimers {
            isPausedTimers = true
            let script = "alert();";
            self.evaluateJavaScript(script, completionHandler: nil)
        }
    }
    
    public func resumeTimers() {
        if isPausedTimers {
            if let completionHandler = isPausedTimersCompletionHandler {
                self.isPausedTimersCompletionHandler = nil
                completionHandler()
            }
            isPausedTimers = false
        }
    }
    
    public func printCurrentPage(printCompletionHandler: ((_ completed: Bool, _ error: Error?) -> Void)?) {
        let printController = UIPrintInteractionController.shared
        let printFormatter = self.viewPrintFormatter()
        printController.printFormatter = printFormatter
        
        let completionHandler: UIPrintInteractionController.CompletionHandler = { (printController, completed, error) in
            if !completed {
                if let e = error {
                    print("[PRINT] Failed: \(e.localizedDescription)")
                } else {
                    print("[PRINT] Canceled")
                }
            }
            if let callback = printCompletionHandler {
                callback(completed, error)
            }
        }
        
        printController.present(animated: true, completionHandler: completionHandler)
    }
    
    public func getContentHeight() -> Int64 {
        return Int64(scrollView.contentSize.height)
    }
    
    public func zoomBy(zoomFactor: Float) {
        let currentZoomScale = scrollView.zoomScale
        scrollView.setZoomScale(currentZoomScale * CGFloat(zoomFactor), animated: false)
    }
    
    public func getScale() -> Float {
        return Float(scrollView.zoomScale)
    }
    
    public func getSelectedText(completionHandler: @escaping (Any?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled {
            evaluateJavaScript(getSelectedTextJS, completionHandler: completionHandler)
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func getHitTestResult(completionHandler: @escaping (Any?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled, let lastTouchLocation = lastTouchPoint {
            self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint(\(lastTouchLocation.x),\(lastTouchLocation.y))", completionHandler: {(value, error) in
                completionHandler(value, error)
            })
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func requestFocusNodeHref(completionHandler: @escaping ([String: Any?]?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled {
            // add some delay to make it sure _lastAnchorOrImageTouched is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._lastAnchorOrImageTouched", completionHandler: {(value, error) in
                    let lastAnchorOrImageTouched = value as? [String: Any?]
                    completionHandler(lastAnchorOrImageTouched, error)
                })
            }
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func requestImageRef(completionHandler: @escaping ([String: Any?]?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled {
            // add some delay to make it sure _lastImageTouched is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._lastImageTouched", completionHandler: {(value, error) in
                    let lastImageTouched = value as? [String: Any?]
                    completionHandler(lastImageTouched, error)
                })
            }
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func clearFocus() {
        self.scrollView.subviews.first?.resignFirstResponder()
    }
    
    public func getCertificate() -> Data? {
        var x509Certificate = self.x509CertificateData
        if x509Certificate == nil, let scheme = url?.scheme, scheme == "https",
            let host = url?.host, let cert = InAppWebView.sslCertificateMap[host] {
            x509Certificate = cert
        }
        return x509Certificate
    }
    
    public func getCertificateMap() -> [String: Any?]? {
        return InAppWebView.getCertificateMap(x509Certificate: getCertificate())
    }
    
    public static func getCertificateMap(x509Certificate: Data?) -> [String: Any?]? {
        return x509Certificate != nil ? [
            "issuedBy": nil,
            "issuedTo": nil,
            "validNotAfterDate": nil,
            "validNotBeforeDate": nil,
            "x509Certificate": x509Certificate
        ] : nil;
    }
    
    public func dispose() {
        if isPausedTimers, let completionHandler = isPausedTimersCompletionHandler {
            isPausedTimersCompletionHandler = nil
            completionHandler()
        }
        stopLoading()
        if windowId == nil {
            configuration.userContentController.removeScriptMessageHandler(forName: "consoleLog")
            configuration.userContentController.removeScriptMessageHandler(forName: "consoleDebug")
            configuration.userContentController.removeScriptMessageHandler(forName: "consoleError")
            configuration.userContentController.removeScriptMessageHandler(forName: "consoleInfo")
            configuration.userContentController.removeScriptMessageHandler(forName: "consoleWarn")
            configuration.userContentController.removeScriptMessageHandler(forName: "callHandler")
            configuration.userContentController.removeScriptMessageHandler(forName: "onFindResultReceived")
            configuration.userContentController.removeAllUserScripts()
            if #available(iOS 11.0, *) {
                configuration.userContentController.removeAllContentRuleLists()
            }
        }
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        NotificationCenter.default.removeObserver(self)
        for imp in customIMPs {
            imp_removeBlock(imp)
        }
        longPressRecognizer?.removeTarget(self, action: #selector(longPressGestureDetected))
        longPressRecognizer?.delegate = nil
        scrollView.removeGestureRecognizer(longPressRecognizer!)
        uiDelegate = nil
        navigationDelegate = nil
        scrollView.delegate = nil
        IABController?.webView = nil
        isPausedTimersCompletionHandler = nil
        channel = nil
        SharedLastTouchPointTimestamp.removeValue(forKey: self)
        if let wId = windowId, InAppWebView.windowWebViews[wId] != nil {
            InAppWebView.windowWebViews.removeValue(forKey: wId)
        }
        super.removeFromSuperview()
    }
    
    deinit {
        print("InAppWebView - dealloc")
    }
    
//    var accessoryView: UIView?
//
//    // https://stackoverflow.com/a/58001395/4637638
//    public override var inputAccessoryView: UIView? {
//        // remove/replace the default accessory view
//        return accessoryView
//    }
}
