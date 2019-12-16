package com.pichillilorenzo.flutter_inappwebview;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;

import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class JavaScriptBridgeInterface {
  private static final String LOG_TAG = "JSBridgeInterface";
  public static final String name = "flutter_inappwebview";
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;

  // https://github.com/taylorhakes/promise-polyfill/blob/master/src/index.js
  public static final String promisePolyfillJS = "if (window.Promise == null) {" +
          "  var setTimeoutFunc = setTimeout;" +
          "  function isArray(x) {" +
          "    return Boolean(x && typeof x.length !== \"undefined\");" +
          "  };" +
          "  function noop() {}" +
          "  function bind(fn, thisArg) {" +
          "    return function() {" +
          "      fn.apply(thisArg, arguments);" +
          "    };" +
          "  };" +
          "  function Promise(fn) {" +
          "    if (!(this instanceof Promise))" +
          "      throw new TypeError(\"Promises must be constructed via new\");" +
          "    if (typeof fn !== \"function\") throw new TypeError(\"not a function\");" +
          "    this._state = 0;" +
          "    this._handled = false;" +
          "    this._value = undefined;" +
          "    this._deferreds = [];" +
          "    doResolve(fn, this);" +
          "  };" +
          "  function handle(self, deferred) {" +
          "    while (self._state === 3) {" +
          "      self = self._value;" +
          "    }" +
          "    if (self._state === 0) {" +
          "      self._deferreds.push(deferred);" +
          "      return;" +
          "    }" +
          "    self._handled = true;" +
          "    Promise._immediateFn(function() {" +
          "      var cb = self._state === 1 ? deferred.onFulfilled : deferred.onRejected;" +
          "      if (cb === null) {" +
          "        (self._state === 1 ? resolve : reject)(deferred.promise, self._value);" +
          "        return;" +
          "      }" +
          "      var ret;" +
          "      try {" +
          "        ret = cb(self._value);" +
          "      } catch (e) {" +
          "        reject(deferred.promise, e);" +
          "        return;" +
          "      }" +
          "      resolve(deferred.promise, ret);" +
          "    });" +
          "  };" +
          "  function resolve(self, newValue) {" +
          "    try {" +
          "      if (newValue === self)" +
          "        throw new TypeError(\"A promise cannot be resolved with itself.\");" +
          "      if (" +
          "        newValue &&" +
          "        (typeof newValue === \"object\" || typeof newValue === \"function\")" +
          "      ) {" +
          "        var then = newValue.then;" +
          "        if (newValue instanceof Promise) {" +
          "          self._state = 3;" +
          "          self._value = newValue;" +
          "          finale(self);" +
          "          return;" +
          "        } else if (typeof then === \"function\") {" +
          "          doResolve(bind(then, newValue), self);" +
          "          return;" +
          "        }" +
          "      }" +
          "      self._state = 1;" +
          "      self._value = newValue;" +
          "      finale(self);" +
          "    } catch (e) {" +
          "      reject(self, e);" +
          "    }" +
          "  };" +
          "  function reject(self, newValue) {" +
          "    self._state = 2;" +
          "    self._value = newValue;" +
          "    finale(self);" +
          "  };" +
          "  function finale(self) {" +
          "    if (self._state === 2 && self._deferreds.length === 0) {" +
          "      Promise._immediateFn(function() {" +
          "        if (!self._handled) {" +
          "          Promise._unhandledRejectionFn(self._value);" +
          "        }" +
          "      });" +
          "    }" +
          "    for (var i = 0, len = self._deferreds.length; i < len; i++) {" +
          "      handle(self, self._deferreds[i]);" +
          "    }" +
          "    self._deferreds = null;" +
          "  };" +
          "  function Handler(onFulfilled, onRejected, promise) {" +
          "    this.onFulfilled = typeof onFulfilled === \"function\" ? onFulfilled : null;" +
          "    this.onRejected = typeof onRejected === \"function\" ? onRejected : null;" +
          "    this.promise = promise;" +
          "  };" +
          "  function doResolve(fn, self) {" +
          "    var done = false;" +
          "    try {" +
          "      fn(" +
          "        function(value) {" +
          "          if (done) return;" +
          "          done = true;" +
          "          resolve(self, value);" +
          "        }," +
          "        function(reason) {" +
          "          if (done) return;" +
          "          done = true;" +
          "          reject(self, reason);" +
          "        }" +
          "      );" +
          "    } catch (ex) {" +
          "      if (done) return;" +
          "      done = true;" +
          "      reject(self, ex);" +
          "    }" +
          "  };" +
          "  Promise.prototype[\"catch\"] = function(onRejected) {" +
          "    return this.then(null, onRejected);" +
          "  };" +
          "  Promise.prototype.then = function(onFulfilled, onRejected) {" +
          "    var prom = new this.constructor(noop);" +
          "    handle(this, new Handler(onFulfilled, onRejected, prom));" +
          "    return prom;" +
          "  };" +
          "  Promise.prototype[\"finally\"] = function finallyConstructor(callback) {" +
          "    var constructor = this.constructor;" +
          "    return this.then(" +
          "      function(value) {" +
          "        return constructor.resolve(callback()).then(function() {" +
          "          return value;" +
          "        });" +
          "      }," +
          "      function(reason) {" +
          "        return constructor.resolve(callback()).then(function() {" +
          "          return constructor.reject(reason);" +
          "        });" +
          "      }" +
          "    );" +
          "  };" +
          "  Promise.all = function(arr) {" +
          "    return new Promise(function(resolve, reject) {" +
          "      if (!isArray(arr)) {" +
          "        return reject(new TypeError(\"Promise.all accepts an array\"));" +
          "      }" +
          "      var args = Array.prototype.slice.call(arr);" +
          "      if (args.length === 0) return resolve([]);" +
          "      var remaining = args.length;" +
          "      function res(i, val) {" +
          "        try {" +
          "          if (val && (typeof val === \"object\" || typeof val === \"function\")) {" +
          "            var then = val.then;" +
          "            if (typeof then === \"function\") {" +
          "              then.call(" +
          "                val," +
          "                function(val) {" +
          "                  res(i, val);" +
          "                }," +
          "                reject" +
          "              );" +
          "              return;" +
          "            }" +
          "          }" +
          "          args[i] = val;" +
          "          if (--remaining === 0) {" +
          "            resolve(args);" +
          "          }" +
          "        } catch (ex) {" +
          "          reject(ex);" +
          "        }" +
          "      }" +
          "      for (var i = 0; i < args.length; i++) {" +
          "        res(i, args[i]);" +
          "      }" +
          "    });" +
          "  };" +
          "  Promise.resolve = function(value) {" +
          "    if (value && typeof value === \"object\" && value.constructor === Promise) {" +
          "      return value;" +
          "    }" +
          "" +
          "    return new Promise(function(resolve) {" +
          "      resolve(value);" +
          "    });" +
          "  };" +
          "  Promise.reject = function(value) {" +
          "    return new Promise(function(resolve, reject) {" +
          "      reject(value);" +
          "    });" +
          "  };" +
          "  Promise.race = function(arr) {" +
          "    return new Promise(function(resolve, reject) {" +
          "      if (!isArray(arr)) {" +
          "        return reject(new TypeError(\"Promise.race accepts an array\"));" +
          "      }" +
          "      for (var i = 0, len = arr.length; i < len; i++) {" +
          "        Promise.resolve(arr[i]).then(resolve, reject);" +
          "      }" +
          "    });" +
          "  };" +
          "  Promise._immediateFn =" +
          "    (typeof setImmediate === \"function\" &&" +
          "      function(fn) {" +
          "        setImmediate(fn);" +
          "      }) ||" +
          "    function(fn) {" +
          "      setTimeoutFunc(fn, 0);" +
          "    };" +
          "  Promise._unhandledRejectionFn = function _unhandledRejectionFn(err) {" +
          "    if (typeof console !== \"undefined\" && console) {" +
          "      console.warn(\"Possible Unhandled Promise Rejection:\", err);" +
          "    }" +
          "  };" +
          "}";

  public static final String flutterInAppBroserJSClass = promisePolyfillJS + " " + "window." + name + ".callHandler = function() {" +
    "var _callHandlerID = setTimeout(function(){});" +
    "window." + name + "._callHandler(arguments[0], _callHandlerID, JSON.stringify(Array.prototype.slice.call(arguments, 1)));" +
    "return new Promise(function(resolve, reject) {" +
    "  window." + name + "[_callHandlerID] = resolve;" +
    "});" +
  "};";

  public JavaScriptBridgeInterface(Object obj) {
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
  }

  @JavascriptInterface
  public void _callHandler(final String handlerName, final String _callHandlerID, final String args) {
    final InAppWebView webView = (inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView;

    final Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("handlerName", handlerName);
    obj.put("args", args);

    // java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread.
    // https://github.com/pichillilorenzo/flutter_inappwebview/issues/98
    final Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {

        if (handlerName.equals("onPrint") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView.printCurrentPage();
        }

        getChannel().invokeMethod("onCallJsHandler", obj, new MethodChannel.Result() {
          @Override
          public void success(Object json) {
            if (webView == null) {
              // The webview has already been disposed, ignore.
              return;
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
              webView.evaluateJavascript("if(window." + name + "[" + _callHandlerID + "] != null) {window." + name + "[" + _callHandlerID + "](" + json + "); delete window." + name + "[" + _callHandlerID + "];}", (ValueCallback<String>) null);
            }
            else {
              webView.loadUrl("javascript:if(window." + name + "[" + _callHandlerID + "] != null) {window." + name + "[" + _callHandlerID + "](" + json + "); delete window." + name + "[" + _callHandlerID + "];}");
            }
          }

          @Override
          public void error(String s, String s1, Object o) {
            Log.d(LOG_TAG, "ERROR: " + s + " " + s1);
          }

          @Override
          public void notImplemented() {

          }
        });
      }
    });
  }

  private MethodChannel getChannel() {
    return (inAppBrowserActivity != null) ? InAppWebViewFlutterPlugin.inAppBrowser.channel : flutterWebView.channel;
  }
}
