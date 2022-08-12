package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Point;
import android.net.http.SslCertificate;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.ActionMode;
import android.view.ContextMenu;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.webkit.CookieManager;
import android.webkit.DownloadListener;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebChromeClient;
import android.webkit.WebHistoryItem;
import android.webkit.WebSettings;
import android.webkit.WebStorage;
import android.webkit.WebViewClient;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Keep;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;
import androidx.webkit.WebViewRenderProcessClient;

import com.pichillilorenzo.flutter_inappwebview.ContentBlocker.ContentBlocker;
import com.pichillilorenzo.flutter_inappwebview.ContentBlocker.ContentBlockerAction;
import com.pichillilorenzo.flutter_inappwebview.ContentBlocker.ContentBlockerHandler;
import com.pichillilorenzo.flutter_inappwebview.ContentBlocker.ContentBlockerTrigger;
import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappwebview.JavaScriptBridgeInterface;
import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Shared;
import com.pichillilorenzo.flutter_inappwebview.Util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.security.cert.CertificateEncodingException;
import java.security.cert.CertificateExpiredException;
import java.security.cert.CertificateNotYetValidException;
import java.security.cert.CertificateParsingException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.OkHttpClient;

import static android.content.Context.INPUT_METHOD_SERVICE;
import static com.pichillilorenzo.flutter_inappwebview.InAppWebView.PreferredContentModeOptionType.fromValue;

final public class InAppWebView extends InputAwareWebView {

  static final String LOG_TAG = "InAppWebView";

  public InAppBrowserActivity inAppBrowserActivity;
  public FlutterWebView flutterWebView;
  public MethodChannel channel;
  public Object id;
  public Integer windowId;
  public InAppWebViewClient inAppWebViewClient;
  public InAppWebViewChromeClient inAppWebViewChromeClient;
  public InAppWebViewRenderProcessClient inAppWebViewRenderProcessClient;
  public JavaScriptBridgeInterface javaScriptBridgeInterface;
  public InAppWebViewOptions options;
  public boolean isLoading = false;
  public OkHttpClient httpClient;
  public float scale = getResources().getDisplayMetrics().density;
  int okHttpClientCacheSize = 10 * 1024 * 1024; // 10MB
  public ContentBlockerHandler contentBlockerHandler = new ContentBlockerHandler();
  public Pattern regexToCancelSubFramesLoadingCompiled;
  public GestureDetector gestureDetector = null;
  public LinearLayout floatingContextMenu = null;
  public Map<String, Object> contextMenu = null;
  public Handler headlessHandler = new Handler(Looper.getMainLooper());
  static Handler mHandler = new Handler();

  public Runnable checkScrollStoppedTask;
  public int initialPositionScrollStoppedTask;
  public int newCheckScrollStoppedTask = 100; // ms

  public Runnable checkContextMenuShouldBeClosedTask;
  public int newCheckContextMenuShouldBeClosedTaskTask = 100; // ms

  static final String scriptsWrapperJS = "(function(){" +
          "  if (window." + JavaScriptBridgeInterface.name + "._scriptsLoaded == null) {" +
          "    $PLACEHOLDER_VALUE" +
          "    window." + JavaScriptBridgeInterface.name + "._scriptsLoaded = true;" +
          "  }" +
          "})();";

  static final String consoleLogJS = "(function(console) {" +
          "   var oldLogs = {" +
          "       'log': console.log," +
          "       'debug': console.debug," +
          "       'error': console.error," +
          "       'info': console.info," +
          "       'warn': console.warn" +
          "   };" +
          "   for (var k in oldLogs) {" +
          "       (function(oldLog) {" +
          "           console[oldLog] = function() {" +
          "               var message = '';" +
          "               for (var i in arguments) {" +
          "                   if (message == '') {" +
          "                       message += arguments[i];" +
          "                   }" +
          "                   else {" +
          "                       message += ' ' + arguments[i];" +
          "                   }" +
          "               }" +
          "               oldLogs[oldLog].call(console, message);" +
          "           }" +
          "       })(k);" +
          "   }" +
          "})(window.console);";

  static final String printJS = "window.print = function() {" +
          "  window." + JavaScriptBridgeInterface.name + ".callHandler('onPrint', window.location.href);" +
          "};";

  static final String platformReadyJS = "(function() {" +
          "  if (window." + JavaScriptBridgeInterface.name + "._platformReady == null) {" +
          "    window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));" +
          "    window." + JavaScriptBridgeInterface.name + "._platformReady = true;" +
          "  }" +
          "})();";

  static final String variableForOnLoadResourceJS = "window._flutter_inappwebview_useOnLoadResource";
  static final String enableVariableForOnLoadResourceJS = variableForOnLoadResourceJS + " = $PLACEHOLDER_VALUE;";

  static final String resourceObserverJS = "(function() {" +
          "   var observer = new PerformanceObserver(function(list) {" +
          "       list.getEntries().forEach(function(entry) {" +
          "         if (window." + variableForOnLoadResourceJS + " == null || window." + variableForOnLoadResourceJS + " == true) {" +
          "           window." + JavaScriptBridgeInterface.name + ".callHandler('onLoadResource', entry);" +
          "         }" +
          "       });" +
          "   });" +
          "   observer.observe({entryTypes: ['resource']});" +
          "})();";

  static final String variableForShouldInterceptAjaxRequestJS = "window._flutter_inappwebview_useShouldInterceptAjaxRequest";
  static final String enableVariableForShouldInterceptAjaxRequestJS = variableForShouldInterceptAjaxRequestJS + " = $PLACEHOLDER_VALUE;";

  static final String interceptAjaxRequestsJS = "(function(ajax) {" +
          "  var send = ajax.prototype.send;" +
          "  var open = ajax.prototype.open;" +
          "  var setRequestHeader = ajax.prototype.setRequestHeader;" +
          "  ajax.prototype._flutter_inappwebview_url = null;" +
          "  ajax.prototype._flutter_inappwebview_method = null;" +
          "  ajax.prototype._flutter_inappwebview_isAsync = null;" +
          "  ajax.prototype._flutter_inappwebview_user = null;" +
          "  ajax.prototype._flutter_inappwebview_password = null;" +
          "  ajax.prototype._flutter_inappwebview_password = null;" +
          "  ajax.prototype._flutter_inappwebview_already_onreadystatechange_wrapped = false;" +
          "  ajax.prototype._flutter_inappwebview_request_headers = {};" +
          "  function convertRequestResponse(request, callback) {" +
          "    if (request.response != null && request.responseType != null) {" +
          "      switch (request.responseType) {" +
          "        case 'arraybuffer':" +
          "          callback(new Uint8Array(request.response));" +
          "          return;" +
          "        case 'blob':" +
          "          const reader = new FileReader();" +
          "          reader.addEventListener('loadend', function() {  " +
          "            callback(new Uint8Array(reader.result));" +
          "          });" +
          "          reader.readAsArrayBuffer(blob);" +
          "          return;" +
          "        case 'document':" +
          "          callback(request.response.documentElement.outerHTML);" +
          "          return;" +
          "        case 'json':" +
          "          callback(request.response);" +
          "          return;" +
          "      };" +
          "    }" +
          "    callback(null);" +
          "  };" +
          "  ajax.prototype.open = function(method, url, isAsync, user, password) {" +
          "    isAsync = (isAsync != null) ? isAsync : true;" +
          "    this._flutter_inappwebview_url = url;" +
          "    this._flutter_inappwebview_method = method;" +
          "    this._flutter_inappwebview_isAsync = isAsync;" +
          "    this._flutter_inappwebview_user = user;" +
          "    this._flutter_inappwebview_password = password;" +
          "    this._flutter_inappwebview_request_headers = {};" +
          "    open.call(this, method, url, isAsync, user, password);" +
          "  };" +
          "  ajax.prototype.setRequestHeader = function(header, value) {" +
          "    this._flutter_inappwebview_request_headers[header] = value;" +
          "    setRequestHeader.call(this, header, value);" +
          "  };" +
          "  function handleEvent(e) {" +
          "    var self = this;" +
          "    if (" + variableForShouldInterceptAjaxRequestJS + " == null || " + variableForShouldInterceptAjaxRequestJS + " == true) {" +
          "      var headers = this.getAllResponseHeaders();" +
          "      var responseHeaders = {};" +
          "      if (headers != null) {" +
          "        var arr = headers.trim().split(/[\\r\\n]+/);" +
          "        arr.forEach(function (line) {" +
          "          var parts = line.split(': ');" +
          "          var header = parts.shift();" +
          "          var value = parts.join(': ');" +
          "          responseHeaders[header] = value;" +
          "        });" +
          "      }" +
          "      convertRequestResponse(this, function(response) {" +
          "        var ajaxRequest = {" +
          "          method: self._flutter_inappwebview_method," +
          "          url: self._flutter_inappwebview_url," +
          "          isAsync: self._flutter_inappwebview_isAsync," +
          "          user: self._flutter_inappwebview_user," +
          "          password: self._flutter_inappwebview_password," +
          "          withCredentials: self.withCredentials," +
          "          headers: self._flutter_inappwebview_request_headers," +
          "          readyState: self.readyState," +
          "          status: self.status," +
          "          responseURL: self.responseURL," +
          "          responseType: self.responseType," +
          "          response: response," +
          "          responseText: (self.responseType == 'text' || self.responseType == '') ? self.responseText : null," +
          "          responseXML: (self.responseType == 'document' && self.responseXML != null) ? self.responseXML.documentElement.outerHTML : null," +
          "          statusText: self.statusText," +
          "          responseHeaders, responseHeaders," +
          "          event: {" +
          "            type: e.type," +
          "            loaded: e.loaded," +
          "            lengthComputable: e.lengthComputable," +
          "            total: e.total" +
          "          }" +
          "        };" +
          "        window." + JavaScriptBridgeInterface.name + ".callHandler('onAjaxProgress', ajaxRequest).then(function(result) {" +
          "          if (result != null) {" +
          "            switch (result) {" +
          "              case 0:" +
          "                self.abort();" +
          "                return;" +
          "            };" +
          "          }" +
          "        });" +
          "      });" +
          "    }" +
          "  };" +
          "  ajax.prototype.send = function(data) {" +
          "    var self = this;" +
          "    if (" + variableForShouldInterceptAjaxRequestJS + " == null || " + variableForShouldInterceptAjaxRequestJS + " == true) {" +
          "      if (!this._flutter_inappwebview_already_onreadystatechange_wrapped) {" +
          "        this._flutter_inappwebview_already_onreadystatechange_wrapped = true;" +
          "        var onreadystatechange = this.onreadystatechange;" +
          "        this.onreadystatechange = function() {" +
          "          if (" + variableForShouldInterceptAjaxRequestJS + " == null || " + variableForShouldInterceptAjaxRequestJS + " == true) {" +
          "            var headers = this.getAllResponseHeaders();" +
          "            var responseHeaders = {};" +
          "            if (headers != null) {" +
          "              var arr = headers.trim().split(/[\\r\\n]+/);" +
          "              arr.forEach(function (line) {" +
          "                var parts = line.split(': ');" +
          "                var header = parts.shift();" +
          "                var value = parts.join(': ');" +
          "                responseHeaders[header] = value;" +
          "              });" +
          "            }" +
          "            convertRequestResponse(this, function(response) {" +
          "              var ajaxRequest = {" +
          "                method: self._flutter_inappwebview_method," +
          "                url: self._flutter_inappwebview_url," +
          "                isAsync: self._flutter_inappwebview_isAsync," +
          "                user: self._flutter_inappwebview_user," +
          "                password: self._flutter_inappwebview_password," +
          "                withCredentials: self.withCredentials," +
          "                headers: self._flutter_inappwebview_request_headers," +
          "                readyState: self.readyState," +
          "                status: self.status," +
          "                responseURL: self.responseURL," +
          "                responseType: self.responseType," +
          "                response: response," +
          "                responseText: (self.responseType == 'text' || self.responseType == '') ? self.responseText : null," +
          "                responseXML: (self.responseType == 'document' && self.responseXML != null) ? self.responseXML.documentElement.outerHTML : null," +
          "                statusText: self.statusText," +
          "                responseHeaders: responseHeaders" +
          "              };" +
          "              window." + JavaScriptBridgeInterface.name + ".callHandler('onAjaxReadyStateChange', ajaxRequest).then(function(result) {" +
          "                if (result != null) {" +
          "                  switch (result) {" +
          "                    case 0:" +
          "                      self.abort();" +
          "                      return;" +
          "                  };" +
          "                }" +
          "                if (onreadystatechange != null) {" +
          "                  onreadystatechange();" +
          "                }" +
          "              });" +
          "            });" +
          "          } else if (onreadystatechange != null) {" +
          "            onreadystatechange();" +
          "          }" +
          "        };" +
          "      }" +
          "      this.addEventListener('loadstart', handleEvent);" +
          "      this.addEventListener('load', handleEvent);" +
          "      this.addEventListener('loadend', handleEvent);" +
          "      this.addEventListener('progress', handleEvent);" +
          "      this.addEventListener('error', handleEvent);" +
          "      this.addEventListener('abort', handleEvent);" +
          "      this.addEventListener('timeout', handleEvent);" +
          "      var ajaxRequest = {" +
          "        data: data," +
          "        method: this._flutter_inappwebview_method," +
          "        url: this._flutter_inappwebview_url," +
          "        isAsync: this._flutter_inappwebview_isAsync," +
          "        user: this._flutter_inappwebview_user," +
          "        password: this._flutter_inappwebview_password," +
          "        withCredentials: this.withCredentials," +
          "        headers: this._flutter_inappwebview_request_headers," +
          "        responseType: this.responseType" +
          "      };" +
          "      window." + JavaScriptBridgeInterface.name + ".callHandler('shouldInterceptAjaxRequest', ajaxRequest).then(function(result) {" +
          "        if (result != null) {" +
          "          switch (result.action) {" +
          "            case 0:" +
          "              self.abort();" +
          "              return;" +
          "          };" +
          "          data = result.data;" +
          "          self.withCredentials = result.withCredentials;" +
          "          if (result.responseType != null) {" +
          "            self.responseType = result.responseType;" +
          "          };" +
          "          for (var header in result.headers) {" +
          "            var value = result.headers[header];" +
          "            var flutter_inappwebview_value = self._flutter_inappwebview_request_headers[header];" +
          "            if (flutter_inappwebview_value == null) {" +
          "              self._flutter_inappwebview_request_headers[header] = value;" +
          "            } else {" +
          "              self._flutter_inappwebview_request_headers[header] += ', ' + value;" +
          "            }" +
          "            setRequestHeader.call(self, header, value);" +
          "          };" +
          "          if ((self._flutter_inappwebview_method != result.method && result.method != null) || (self._flutter_inappwebview_url != result.url && result.url != null)) {" +
          "            self.abort();" +
          "            self.open(result.method, result.url, result.isAsync, result.user, result.password);" +
          "            return;" +
          "          }" +
          "        }" +
          "        send.call(self, data);" +
          "      });" +
          "    } else {" +
          "      send.call(this, data);" +
          "    }" +
          "  };" +
          "})(window.XMLHttpRequest);";

  static final String  variableForShouldInterceptFetchRequestsJS = "window._flutter_inappwebview_useShouldInterceptFetchRequest";
  static final String  enableVariableForShouldInterceptFetchRequestsJS = variableForShouldInterceptFetchRequestsJS + " = $PLACEHOLDER_VALUE;";

  static final String interceptFetchRequestsJS = "(function(fetch) {" +
          "  if (fetch == null) {" +
          "    return;" +
          "  }" +
          "  function convertHeadersToJson(headers) {" +
          "    var headersObj = {};" +
          "    for (var header of headers.keys()) {" +
          "      var value = headers.get(header);" +
          "      headersObj[header] = value;" +
          "    }" +
          "    return headersObj;" +
          "  }" +
          "  function convertJsonToHeaders(headersJson) {" +
          "    return new Headers(headersJson);" +
          "  }" +
          "  function convertBodyToArray(body) {" +
          "    return new Response(body).arrayBuffer().then(function(arrayBuffer) {" +
          "      var arr = Array.from(new Uint8Array(arrayBuffer));" +
          "      return arr;" +
          "    })" +
          "  }" +
          "  function convertArrayIntBodyToUint8Array(arrayIntBody) {" +
          "    return new Uint8Array(arrayIntBody);" +
          "  }" +
          "  function convertCredentialsToJson(credentials) {" +
          "    var credentialsObj = {};" +
          "    if (window.FederatedCredential != null && credentials instanceof FederatedCredential) {" +
          "      credentialsObj.type = credentials.type;" +
          "      credentialsObj.id = credentials.id;" +
          "      credentialsObj.name = credentials.name;" +
          "      credentialsObj.protocol = credentials.protocol;" +
          "      credentialsObj.provider = credentials.provider;" +
          "      credentialsObj.iconURL = credentials.iconURL;" +
          "    } else if (window.PasswordCredential != null && credentials instanceof PasswordCredential) {" +
          "      credentialsObj.type = credentials.type;" +
          "      credentialsObj.id = credentials.id;" +
          "      credentialsObj.name = credentials.name;" +
          "      credentialsObj.password = credentials.password;" +
          "      credentialsObj.iconURL = credentials.iconURL;" +
          "    } else {" +
          "      credentialsObj.type = 'default';" +
          "      credentialsObj.value = credentials;" +
          "    }" +
          "  }" +
          "  function convertJsonToCredential(credentialsJson) {" +
          "    var credentials;" +
          "    if (window.FederatedCredential != null && credentialsJson.type === 'federated') {" +
          "      credentials = new FederatedCredential({" +
          "        id: credentialsJson.id," +
          "        name: credentialsJson.name," +
          "        protocol: credentialsJson.protocol," +
          "        provider: credentialsJson.provider," +
          "        iconURL: credentialsJson.iconURL" +
          "      });" +
          "    } else if (window.PasswordCredential != null && credentialsJson.type === 'password') {" +
          "      credentials = new PasswordCredential({" +
          "        id: credentialsJson.id," +
          "        name: credentialsJson.name," +
          "        password: credentialsJson.password," +
          "        iconURL: credentialsJson.iconURL" +
          "      });" +
          "    } else {" +
          "      credentials = credentialsJson;" +
          "    }" +
          "    return credentials;" +
          "  }" +
          "  window.fetch = async function(resource, init) {" +
          "    if (window." + variableForShouldInterceptFetchRequestsJS + " == null || window." + variableForShouldInterceptFetchRequestsJS + " == true) {" +
          "      var fetchRequest = {" +
          "        url: null," +
          "        method: null," +
          "        headers: null," +
          "        body: null," +
          "        mode: null," +
          "        credentials: null," +
          "        cache: null," +
          "        redirect: null," +
          "        referrer: null," +
          "        referrerPolicy: null," +
          "        integrity: null," +
          "        keepalive: null" +
          "      };" +
          "      if (resource instanceof Request) {" +
          "        fetchRequest.url = resource.url;" +
          "        fetchRequest.method = resource.method;" +
          "        fetchRequest.headers = resource.headers;" +
          "        fetchRequest.body = resource.body;" +
          "        fetchRequest.mode = resource.mode;" +
          "        fetchRequest.credentials = resource.credentials;" +
          "        fetchRequest.cache = resource.cache;" +
          "        fetchRequest.redirect = resource.redirect;" +
          "        fetchRequest.referrer = resource.referrer;" +
          "        fetchRequest.referrerPolicy = resource.referrerPolicy;" +
          "        fetchRequest.integrity = resource.integrity;" +
          "        fetchRequest.keepalive = resource.keepalive;" +
          "      } else {" +
          "        fetchRequest.url = resource;" +
          "        if (init != null) {" +
          "          fetchRequest.method = init.method;" +
          "          fetchRequest.headers = init.headers;" +
          "          fetchRequest.body = init.body;" +
          "          fetchRequest.mode = init.mode;" +
          "          fetchRequest.credentials = init.credentials;" +
          "          fetchRequest.cache = init.cache;" +
          "          fetchRequest.redirect = init.redirect;" +
          "          fetchRequest.referrer = init.referrer;" +
          "          fetchRequest.referrerPolicy = init.referrerPolicy;" +
          "          fetchRequest.integrity = init.integrity;" +
          "          fetchRequest.keepalive = init.keepalive;" +
          "        }" +
          "      }" +
          "      if (fetchRequest.headers instanceof Headers) {" +
          "        fetchRequest.headers = convertHeadersToJson(fetchRequest.headers);" +
          "      }" +
          "      fetchRequest.credentials = convertCredentialsToJson(fetchRequest.credentials);" +
          "      return convertBodyToArray(fetchRequest.body).then(function(body) {" +
          "        fetchRequest.body = body;" +
          "        return window." + JavaScriptBridgeInterface.name + ".callHandler('shouldInterceptFetchRequest', fetchRequest).then(function(result) {" +
          "          if (result != null) {" +
          "            switch (result.action) {" +
          "              case 0:" +
          "                var controller = new AbortController();" +
          "                if (init != null) {" +
          "                  init.signal = controller.signal;" +
          "                } else {" +
          "                  init = {" +
          "                    signal: controller.signal" +
          "                  };" +
          "                }" +
          "                controller.abort();" +
          "                break;" +
          "            }" +
          "            resource = (result.url != null) ? result.url : resource;" +
          "            if (init == null) {" +
          "              init = {};" +
          "            }" +
          "            if (result.method != null && result.method.length > 0) {" +
          "              init.method = result.method;" +
          "            }" +
          "            if (result.headers != null && Object.keys(result.headers).length > 0) {" +
          "              init.headers = convertJsonToHeaders(result.headers);" +
          "            }" +
          "            if (result.body != null && result.body.length > 0)   {" +
          "              init.body = convertArrayIntBodyToUint8Array(result.body);" +
          "            }" +
          "            if (result.mode != null && result.mode.length > 0) {" +
          "              init.mode = result.mode;" +
          "            }" +
          "            if (result.credentials != null) {" +
          "              init.credentials = convertJsonToCredential(result.credentials);" +
          "            }" +
          "            if (result.cache != null && result.cache.length > 0) {" +
          "              init.cache = result.cache;" +
          "            }" +
          "            if (result.redirect != null && result.redirect.length > 0) {" +
          "              init.redirect = result.redirect;" +
          "            }" +
          "            if (result.referrer != null && result.referrer.length > 0) {" +
          "              init.referrer = result.referrer;" +
          "            }" +
          "            if (result.referrerPolicy != null && result.referrerPolicy.length > 0) {" +
          "              init.referrerPolicy = result.referrerPolicy;" +
          "            }" +
          "            if (result.integrity != null && result.integrity.length > 0) {" +
          "              init.integrity = result.integrity;" +
          "            }" +
          "            if (result.keepalive != null) {" +
          "              init.keepalive = result.keepalive;" +
          "            }" +
          "            return fetch(resource, init);" +
          "          }" +
          "          return fetch(resource, init);" +
          "        });" +
          "      });" +
          "    } else {" +
          "      return fetch(resource, init);" +
          "    }" +
          "  };" +
          "})(window.fetch);";

  static final String isActiveElementInputEditableJS =
          "var activeEl = document.activeElement;" +
          "var nodeName = (activeEl != null) ? activeEl.nodeName.toLowerCase() : '';" +
          "var isActiveElementInputEditable = activeEl != null && " +
                  "(activeEl.nodeType == 1 && (nodeName == 'textarea' || (nodeName == 'input' && /^(?:text|email|number|search|tel|url|password)$/i.test(activeEl.type != null ? activeEl.type : 'text')))) && " +
                  "!activeEl.disabled && !activeEl.readOnly;" +
          "var isActiveElementEditable = isActiveElementInputEditable || (activeEl != null && activeEl.isContentEditable) || document.designMode === 'on';";

  static final String getSelectedTextJS = "(function(){" +
          "  var txt;" +
          "  if (window.getSelection) {" +
          "    txt = window.getSelection().toString();" +
          "  } else if (window.document.getSelection) {" +
          "    txt = window.document.getSelection().toString();" +
          "  } else if (window.document.selection) {" +
          "    txt = window.document.selection.createRange().text;" +
          "  }" +
          "  return txt;" +
          "})();";

  // android Workaround to hide context menu when selected text is empty
  // and the document active element is not an input element.
  static final String checkContextMenuShouldBeHiddenJS = "(function(){" +
          "  var txt;" +
          "  if (window.getSelection) {" +
          "    txt = window.getSelection().toString();" +
          "  } else if (window.document.getSelection) {" +
          "    txt = window.document.getSelection().toString();" +
          "  } else if (window.document.selection) {" +
          "    txt = window.document.selection.createRange().text;" +
          "  }" +
             isActiveElementInputEditableJS +
          "  return txt === '' && !isActiveElementEditable;" +
          "})();";

  // android Workaround to hide context menu when user emit a keydown event
  static final String checkGlobalKeyDownEventToHideContextMenuJS = "(function(){" +
          "  document.addEventListener('keydown', function(e) {" +
          "    window." + JavaScriptBridgeInterface.name + "._hideContextMenu();" +
          "  });" +
          "})();";

  static final String onWindowFocusEventJS = "(function(){" +
          "  window.addEventListener('focus', function(e) {" +
          "    window." + JavaScriptBridgeInterface.name + ".callHandler('onWindowFocus');" +
          "  });" +
          "})();";

    static final String onWindowBlurEventJS = "(function(){" +
          "  window.addEventListener('blur', function(e) {" +
          "    window." + JavaScriptBridgeInterface.name + ".callHandler('onWindowBlur');" +
          "  });" +
          "})();";

  public InAppWebView(Context context) {
    super(context);
  }

  public InAppWebView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppWebView(Context context, AttributeSet attrs, int defaultStyle) {
    super(context, attrs, defaultStyle);
  }

  public InAppWebView(Context context, Object obj, Object id, Integer windowId, InAppWebViewOptions options, Map<String, Object> contextMenu, View containerView) {
    super(context, containerView);
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
    this.channel = (this.inAppBrowserActivity != null) ? this.inAppBrowserActivity.channel : this.flutterWebView.channel;
    this.id = id;
    this.windowId = windowId;
    this.options = options;
    this.contextMenu = contextMenu;
    Shared.activity.registerForContextMenu(this);
  }

  @Override
  public void reload() {
    super.reload();
  }

  public void prepare() {

    boolean isFromInAppBrowserActivity = inAppBrowserActivity != null;

    httpClient = new OkHttpClient().newBuilder().build();

    javaScriptBridgeInterface = new JavaScriptBridgeInterface((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView);
    addJavascriptInterface(javaScriptBridgeInterface, JavaScriptBridgeInterface.name);

    inAppWebViewChromeClient = new InAppWebViewChromeClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView);
    setWebChromeClient(inAppWebViewChromeClient);

    inAppWebViewClient = new InAppWebViewClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView);
    setWebViewClient(inAppWebViewClient);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)) {
      inAppWebViewRenderProcessClient = new InAppWebViewRenderProcessClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView);
      WebViewCompat.setWebViewRenderProcessClient(this, inAppWebViewRenderProcessClient);
    }

    if (options.useOnDownloadStart)
      setDownloadListener(new DownloadStartListener());

    WebSettings settings = getSettings();

    settings.setJavaScriptEnabled(options.javaScriptEnabled);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      setWebContentsDebuggingEnabled(options.debuggingEnabled);
    }
    settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
    settings.setBuiltInZoomControls(options.builtInZoomControls);
    settings.setDisplayZoomControls(options.displayZoomControls);
    settings.setSupportMultipleWindows(options.supportMultipleWindows);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(options.safeBrowsingEnabled);

    settings.setMediaPlaybackRequiresUserGesture(options.mediaPlaybackRequiresUserGesture);

    settings.setDatabaseEnabled(options.databaseEnabled);
    settings.setDomStorageEnabled(options.domStorageEnabled);

    if (options.userAgent != null && !options.userAgent.isEmpty())
      settings.setUserAgentString(options.userAgent);
    else if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
      settings.setUserAgentString(WebSettings.getDefaultUserAgent(getContext()));

    if (options.applicationNameForUserAgent != null && !options.applicationNameForUserAgent.isEmpty()) {
      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        String userAgent = (options.userAgent != null && !options.userAgent.isEmpty()) ? options.userAgent : WebSettings.getDefaultUserAgent(getContext());
        String userAgentWithApplicationName = userAgent + " " + options.applicationNameForUserAgent;
        settings.setUserAgentString(userAgentWithApplicationName);
      }
    }

    if (options.clearCache)
      clearAllCache();
    else if (options.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, options.thirdPartyCookiesEnabled);

    settings.setLoadWithOverviewMode(options.loadWithOverviewMode);
    settings.setUseWideViewPort(options.useWideViewPort);
    settings.setSupportZoom(options.supportZoom);
    settings.setTextZoom(options.textZoom);

    setVerticalScrollBarEnabled(!options.disableVerticalScroll && options.verticalScrollBarEnabled);
    setHorizontalScrollBarEnabled(!options.disableHorizontalScroll && options.horizontalScrollBarEnabled);

    if (options.transparentBackground)
      setBackgroundColor(Color.TRANSPARENT);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && options.mixedContentMode != null)
      settings.setMixedContentMode(options.mixedContentMode);

    settings.setAllowContentAccess(options.allowContentAccess);
    settings.setAllowFileAccess(options.allowFileAccess);
    settings.setAllowFileAccessFromFileURLs(options.allowFileAccessFromFileURLs);
    settings.setAllowUniversalAccessFromFileURLs(options.allowUniversalAccessFromFileURLs);
    setCacheEnabled(options.cacheEnabled);
    if (options.appCachePath != null && !options.appCachePath.isEmpty() && options.cacheEnabled)
      settings.setAppCachePath(options.appCachePath);
    settings.setBlockNetworkImage(options.blockNetworkImage);
    settings.setBlockNetworkLoads(options.blockNetworkLoads);
    if (options.cacheMode != null)
      settings.setCacheMode(options.cacheMode);
    settings.setCursiveFontFamily(options.cursiveFontFamily);
    settings.setDefaultFixedFontSize(options.defaultFixedFontSize);
    settings.setDefaultFontSize(options.defaultFontSize);
    settings.setDefaultTextEncodingName(options.defaultTextEncodingName);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && options.disabledActionModeMenuItems != null)
      settings.setDisabledActionModeMenuItems(options.disabledActionModeMenuItems);
    settings.setFantasyFontFamily(options.fantasyFontFamily);
    settings.setFixedFontFamily(options.fixedFontFamily);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.forceDark != null)
      settings.setForceDark(options.forceDark);
    settings.setGeolocationEnabled(options.geolocationEnabled);
    if (options.layoutAlgorithm != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && options.layoutAlgorithm.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
        settings.setLayoutAlgorithm(options.layoutAlgorithm);
      } else {
        settings.setLayoutAlgorithm(options.layoutAlgorithm);
      }
    }
    settings.setLoadsImagesAutomatically(options.loadsImagesAutomatically);
    settings.setMinimumFontSize(options.minimumFontSize);
    settings.setMinimumLogicalFontSize(options.minimumLogicalFontSize);
    setInitialScale(options.initialScale);
    settings.setNeedInitialFocus(options.needInitialFocus);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
      settings.setOffscreenPreRaster(options.offscreenPreRaster);
    settings.setSansSerifFontFamily(options.sansSerifFontFamily);
    settings.setSerifFontFamily(options.serifFontFamily);
    settings.setStandardFontFamily(options.standardFontFamily);
    if (options.preferredContentMode != null &&
            options.preferredContentMode == PreferredContentModeOptionType.DESKTOP.toValue()) {
      setDesktopMode(true);
    }
    settings.setSaveFormData(options.saveFormData);
    if (options.incognito)
      setIncognito(true);
    if (options.hardwareAcceleration)
      setLayerType(View.LAYER_TYPE_HARDWARE, null);
    else
      setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    if (options.regexToCancelSubFramesLoading != null) {
      regexToCancelSubFramesLoadingCompiled = Pattern.compile(options.regexToCancelSubFramesLoading);
    }
    setScrollBarStyle(options.scrollBarStyle);
    if (options.scrollBarDefaultDelayBeforeFade != null) {
      setScrollBarDefaultDelayBeforeFade(options.scrollBarDefaultDelayBeforeFade);
    } else {
      options.scrollBarDefaultDelayBeforeFade = getScrollBarDefaultDelayBeforeFade();
    }
    setScrollbarFadingEnabled(options.scrollbarFadingEnabled);
    if (options.scrollBarFadeDuration != null) {
      setScrollBarFadeDuration(options.scrollBarFadeDuration);
    } else {
      options.scrollBarFadeDuration = getScrollBarFadeDuration();
    }
    setVerticalScrollbarPosition(options.verticalScrollbarPosition);
    setOverScrollMode(options.overScrollMode);
    if (options.networkAvailable != null) {
      setNetworkAvailable(options.networkAvailable);
    }
    if (options.rendererPriorityPolicy != null && !options.rendererPriorityPolicy.isEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      setRendererPriorityPolicy(
              (int) options.rendererPriorityPolicy.get("rendererRequestedPriority"),
              (boolean) options.rendererPriorityPolicy.get("waivedWhenNotVisible"));
    } else if ((options.rendererPriorityPolicy == null || (options.rendererPriorityPolicy != null && options.rendererPriorityPolicy.isEmpty())) &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      options.rendererPriorityPolicy.put("rendererRequestedPriority", getRendererRequestedPriority());
      options.rendererPriorityPolicy.put("waivedWhenNotVisible", getRendererPriorityWaivedWhenNotVisible());
    }

    contentBlockerHandler.getRuleList().clear();
    for (Map<String, Map<String, Object>> contentBlocker : options.contentBlockers) {
      // compile ContentBlockerTrigger urlFilter
      ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
      ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
      contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
    }

    setFindListener(new FindListener() {
      @Override
      public void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, boolean isDoneCounting) {
        Map<String, Object> obj = new HashMap<>();
        if (inAppBrowserActivity != null)
          obj.put("uuid", inAppBrowserActivity.uuid);
        obj.put("activeMatchOrdinal", activeMatchOrdinal);
        obj.put("numberOfMatches", numberOfMatches);
        obj.put("isDoneCounting", isDoneCounting);
        channel.invokeMethod("onFindResultReceived", obj);
      }
    });

    gestureDetector = new GestureDetector(this.getContext(), new GestureDetector.SimpleOnGestureListener() {
      @Override
      public boolean onSingleTapUp(MotionEvent ev) {
        if (floatingContextMenu != null) {
          hideContextMenu();
        }
        return super.onSingleTapUp(ev);
      }
    });

    checkScrollStoppedTask = new Runnable() {
      @Override
      public void run() {
        int newPosition = getScrollY();
        if(initialPositionScrollStoppedTask - newPosition == 0){
          // has stopped
          onScrollStopped();
        } else {
          initialPositionScrollStoppedTask = getScrollY();
          headlessHandler.postDelayed(checkScrollStoppedTask, newCheckScrollStoppedTask);
        }
      }
    };

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      checkContextMenuShouldBeClosedTask = new Runnable() {
        @Override
        public void run() {
          if (floatingContextMenu != null) {
            evaluateJavascript(checkContextMenuShouldBeHiddenJS, new ValueCallback<String>() {
              @Override
              public void onReceiveValue(String value) {
                if (value == null || value.equals("true")) {
                  if (floatingContextMenu != null) {
                    hideContextMenu();
                  }
                } else {
                  headlessHandler.postDelayed(checkContextMenuShouldBeClosedTask, newCheckContextMenuShouldBeClosedTaskTask);
                }
              }
            });
          }
        }
      };
    }

    setOnTouchListener(new OnTouchListener() {
      float m_downX;
      float m_downY;

      @Override
      public boolean onTouch(View v, MotionEvent event) {
        gestureDetector.onTouchEvent(event);

        if (event.getAction() == MotionEvent.ACTION_UP) {
          checkScrollStoppedTask.run();
        }

        if (options.disableHorizontalScroll && options.disableVerticalScroll) {
          return (event.getAction() == MotionEvent.ACTION_MOVE);
        }
        else if (options.disableHorizontalScroll || options.disableVerticalScroll) {
          switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN: {
              // save the x
              m_downX = event.getX();
              // save the y
              m_downY = event.getY();
              break;
            }
            case MotionEvent.ACTION_MOVE:
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP: {
              if (options.disableHorizontalScroll) {
                // set x so that it doesn't move
                event.setLocation(m_downX, event.getY());
              } else {
                // set y so that it doesn't move
                event.setLocation(event.getX(), m_downY);
              }
              break;
            }
          }
        }
        return false;
      }
    });

    setOnLongClickListener(new OnLongClickListener() {
      @Override
      public boolean onLongClick(View v) {
        HitTestResult hitTestResult = getHitTestResult();
        Map<String, Object> hitTestResultMap = new HashMap<>();
        hitTestResultMap.put("type", hitTestResult.getType());
        hitTestResultMap.put("extra", hitTestResult.getExtra());

        Map<String, Object> obj = new HashMap<>();
        if (inAppBrowserActivity != null)
          obj.put("uuid", inAppBrowserActivity.uuid);
        obj.put("hitTestResult", hitTestResultMap);
        channel.invokeMethod("onLongPressHitTestResult", obj);
        return false;
      }
    });
  }

  private MotionEvent lastMotionEvent = null;

  public void setIncognito(boolean enabled) {
    WebSettings settings = getSettings();
    if (enabled) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        CookieManager.getInstance().removeAllCookies(null);
      } else {
        CookieManager.getInstance().removeAllCookie();
      }

      // Disable caching
      settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
      settings.setAppCacheEnabled(false);
      clearHistory();
      clearCache(true);

      // No form data or autofill enabled
      clearFormData();
      settings.setSavePassword(false);
      settings.setSaveFormData(false);
    }
    else {
      settings.setCacheMode(WebSettings.LOAD_DEFAULT);
      settings.setAppCacheEnabled(true);
      settings.setSavePassword(true);
      settings.setSaveFormData(true);
    }
  }

  public void setCacheEnabled(boolean enabled) {
    WebSettings settings = getSettings();
    if (enabled) {
      Context ctx = getContext();
      if (ctx != null) {
        settings.setAppCachePath(ctx.getCacheDir().getAbsolutePath());
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);
        settings.setAppCacheEnabled(true);
      }
    } else {
      settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
      settings.setAppCacheEnabled(false);
    }
  }

  public void loadUrl(String url, MethodChannel.Result result) {
    if (!url.isEmpty()) {
      loadUrl(url);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void loadUrl(String url, Map<String, String> headers, MethodChannel.Result result) {
    if (!url.isEmpty()) {
      loadUrl(url, headers);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void postUrl(String url, byte[] postData, MethodChannel.Result result) {
    if (!url.isEmpty()) {
      postUrl(url, postData);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void loadData(String data, String mimeType, String encoding, String baseUrl, String historyUrl, MethodChannel.Result result) {
    loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
    result.success(true);
  }

  public void loadFile(String url, MethodChannel.Result result) {
    try {
      url = Util.getUrlAsset(url);
    } catch (IOException e) {
      result.error(LOG_TAG, url + " asset file cannot be found!", e);
      return;
    }

    if (!url.isEmpty()) {
      loadUrl(url);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void loadFile(String url, Map<String, String> headers, MethodChannel.Result result) {
    try {
      url = Util.getUrlAsset(url);
    } catch (IOException e) {
      result.error(LOG_TAG, url + " asset file cannot be found!", e);
      return;
    }

    if (!url.isEmpty()) {
      loadUrl(url, headers);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public boolean isLoading() {
    return isLoading;
  }

  private void clearCookies() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean aBoolean) {

        }
      });
    } else {
      CookieManager.getInstance().removeAllCookie();
    }
  }

  public void clearAllCache() {
    clearCache(true);
    clearCookies();
    clearFormData();
    WebStorage.getInstance().deleteAllData();
  }

  public void takeScreenshot(final MethodChannel.Result result) {
    headlessHandler.post(new Runnable() {
      @Override
      public void run() {
        try {
          int height = (int) (getContentHeight() * scale + 0.5);

          Bitmap b = Bitmap.createBitmap(getWidth(),
                  height, Bitmap.Config.ARGB_8888);
          Canvas c = new Canvas(b);

          draw(c);

          int scrollY = getScrollY();
          int measuredHeight = getMeasuredHeight();
          int bitmapHeight = b.getHeight();

          int scrollOffset = (scrollY + measuredHeight > bitmapHeight)
                  ? (bitmapHeight - measuredHeight) : scrollY;

          if (scrollOffset < 0) {
            scrollOffset = 0;
          }

          Bitmap resized = Bitmap.createBitmap(
                  b, 0, scrollOffset, b.getWidth(), measuredHeight);

          ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

          resized.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
          try {
            byteArrayOutputStream.close();
          } catch (IOException e) {
            e.printStackTrace();
            String errorMessage = e.getMessage();
            if (errorMessage != null) {
              Log.e(LOG_TAG, errorMessage);
            }
          }
          resized.recycle();
          result.success(byteArrayOutputStream.toByteArray());

        } catch (IllegalArgumentException e) {
          String errorMessage = e.getMessage();
          if (errorMessage != null) {
            Log.e(LOG_TAG, errorMessage);
          }
          result.success(null);
        }
      }
    });
  }

  public void setOptions(InAppWebViewOptions newOptions, HashMap<String, Object> newOptionsMap) {

    WebSettings settings = getSettings();

    if (newOptionsMap.get("javaScriptEnabled") != null && options.javaScriptEnabled != newOptions.javaScriptEnabled)
      settings.setJavaScriptEnabled(newOptions.javaScriptEnabled);

    if (newOptionsMap.get("debuggingEnabled") != null && options.debuggingEnabled != newOptions.debuggingEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
      setWebContentsDebuggingEnabled(newOptions.debuggingEnabled);

    if (newOptionsMap.get("useShouldInterceptAjaxRequest") != null && options.useShouldInterceptAjaxRequest != newOptions.useShouldInterceptAjaxRequest) {
      String placeholderValue = newOptions.useShouldInterceptAjaxRequest ? "true" : "false";
      String sourceJs = InAppWebView.enableVariableForShouldInterceptAjaxRequestJS.replace("$PLACEHOLDER_VALUE", placeholderValue);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        evaluateJavascript(sourceJs, (ValueCallback<String>) null);
      } else {
        loadUrl("javascript:" + sourceJs);
      }
    }

    if (newOptionsMap.get("useShouldInterceptFetchRequest") != null && options.useShouldInterceptFetchRequest != newOptions.useShouldInterceptFetchRequest) {
      String placeholderValue = newOptions.useShouldInterceptFetchRequest ? "true" : "false";
      String sourceJs = InAppWebView.enableVariableForShouldInterceptFetchRequestsJS.replace("$PLACEHOLDER_VALUE", placeholderValue);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        evaluateJavascript(sourceJs, (ValueCallback<String>) null);
      } else {
        loadUrl("javascript:" + sourceJs);
      }
    }

    if (newOptionsMap.get("useOnLoadResource") != null && options.useOnLoadResource != newOptions.useOnLoadResource) {
      String placeholderValue = newOptions.useOnLoadResource ? "true" : "false";
      String sourceJs = InAppWebView.enableVariableForOnLoadResourceJS.replace("$PLACEHOLDER_VALUE", placeholderValue);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        evaluateJavascript(sourceJs, (ValueCallback<String>) null);
      } else {
        loadUrl("javascript:" + sourceJs);
      }
    }

    if (newOptionsMap.get("javaScriptCanOpenWindowsAutomatically") != null && options.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically)
      settings.setJavaScriptCanOpenWindowsAutomatically(newOptions.javaScriptCanOpenWindowsAutomatically);

    if (newOptionsMap.get("builtInZoomControls") != null && options.builtInZoomControls != newOptions.builtInZoomControls)
      settings.setBuiltInZoomControls(newOptions.builtInZoomControls);

    if (newOptionsMap.get("displayZoomControls") != null && options.displayZoomControls != newOptions.displayZoomControls)
      settings.setDisplayZoomControls(newOptions.displayZoomControls);

    if (newOptionsMap.get("safeBrowsingEnabled") != null && options.safeBrowsingEnabled != newOptions.safeBrowsingEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(newOptions.safeBrowsingEnabled);

    if (newOptionsMap.get("mediaPlaybackRequiresUserGesture") != null && options.mediaPlaybackRequiresUserGesture != newOptions.mediaPlaybackRequiresUserGesture)
      settings.setMediaPlaybackRequiresUserGesture(newOptions.mediaPlaybackRequiresUserGesture);

    if (newOptionsMap.get("databaseEnabled") != null && options.databaseEnabled != newOptions.databaseEnabled)
      settings.setDatabaseEnabled(newOptions.databaseEnabled);

    if (newOptionsMap.get("domStorageEnabled") != null && options.domStorageEnabled != newOptions.domStorageEnabled)
      settings.setDomStorageEnabled(newOptions.domStorageEnabled);

    if (newOptionsMap.get("userAgent") != null && !options.userAgent.equals(newOptions.userAgent) && !newOptions.userAgent.isEmpty())
      settings.setUserAgentString(newOptions.userAgent);

    if (newOptionsMap.get("applicationNameForUserAgent") != null && !options.applicationNameForUserAgent.equals(newOptions.applicationNameForUserAgent) && !newOptions.applicationNameForUserAgent.isEmpty()) {
      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        String userAgent = (newOptions.userAgent != null && !newOptions.userAgent.isEmpty()) ? newOptions.userAgent : WebSettings.getDefaultUserAgent(getContext());
        String userAgentWithApplicationName = userAgent + " " + options.applicationNameForUserAgent;
        settings.setUserAgentString(userAgentWithApplicationName);
      }
    }

    if (newOptionsMap.get("clearCache") != null && newOptions.clearCache)
      clearAllCache();
    else if (newOptionsMap.get("clearSessionCache") != null && newOptions.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (newOptionsMap.get("thirdPartyCookiesEnabled") != null && options.thirdPartyCookiesEnabled != newOptions.thirdPartyCookiesEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, newOptions.thirdPartyCookiesEnabled);

    if (newOptionsMap.get("useWideViewPort") != null && options.useWideViewPort != newOptions.useWideViewPort)
      settings.setUseWideViewPort(newOptions.useWideViewPort);

    if (newOptionsMap.get("supportZoom") != null && options.supportZoom != newOptions.supportZoom)
      settings.setSupportZoom(newOptions.supportZoom);

    if (newOptionsMap.get("textZoom") != null && !options.textZoom.equals(newOptions.textZoom))
      settings.setTextZoom(newOptions.textZoom);

    if (newOptionsMap.get("verticalScrollBarEnabled") != null && options.verticalScrollBarEnabled != newOptions.verticalScrollBarEnabled)
      setVerticalScrollBarEnabled(newOptions.verticalScrollBarEnabled);

    if (newOptionsMap.get("horizontalScrollBarEnabled") != null && options.horizontalScrollBarEnabled != newOptions.horizontalScrollBarEnabled)
      setHorizontalScrollBarEnabled(newOptions.horizontalScrollBarEnabled);

    if (newOptionsMap.get("transparentBackground") != null && options.transparentBackground != newOptions.transparentBackground) {
      if (newOptions.transparentBackground) {
        setBackgroundColor(Color.TRANSPARENT);
      } else {
        setBackgroundColor(Color.parseColor("#FFFFFF"));
      }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      if (newOptionsMap.get("mixedContentMode") != null && (options.mixedContentMode == null || !options.mixedContentMode.equals(newOptions.mixedContentMode)))
        settings.setMixedContentMode(newOptions.mixedContentMode);

    if (newOptionsMap.get("supportMultipleWindows") != null && options.supportMultipleWindows != newOptions.supportMultipleWindows)
      settings.setSupportMultipleWindows(newOptions.supportMultipleWindows);

    if (newOptionsMap.get("useOnDownloadStart") != null && options.useOnDownloadStart != newOptions.useOnDownloadStart) {
      if (newOptions.useOnDownloadStart) {
        setDownloadListener(new DownloadStartListener());
      } else {
        setDownloadListener(null);
      }
    }

    if (newOptionsMap.get("allowContentAccess") != null && options.allowContentAccess != newOptions.allowContentAccess)
      settings.setAllowContentAccess(newOptions.allowContentAccess);

    if (newOptionsMap.get("allowFileAccess") != null && options.allowFileAccess != newOptions.allowFileAccess)
      settings.setAllowFileAccess(newOptions.allowFileAccess);

    if (newOptionsMap.get("allowFileAccessFromFileURLs") != null && options.allowFileAccessFromFileURLs != newOptions.allowFileAccessFromFileURLs)
      settings.setAllowFileAccessFromFileURLs(newOptions.allowFileAccessFromFileURLs);

    if (newOptionsMap.get("allowUniversalAccessFromFileURLs") != null && options.allowUniversalAccessFromFileURLs != newOptions.allowUniversalAccessFromFileURLs)
      settings.setAllowUniversalAccessFromFileURLs(newOptions.allowUniversalAccessFromFileURLs);

    if (newOptionsMap.get("cacheEnabled") != null && options.cacheEnabled != newOptions.cacheEnabled)
      setCacheEnabled(newOptions.cacheEnabled);

    if (newOptionsMap.get("appCachePath") != null && (options.appCachePath == null || !options.appCachePath.equals(newOptions.appCachePath)))
      settings.setAppCachePath(newOptions.appCachePath);

    if (newOptionsMap.get("blockNetworkImage") != null && options.blockNetworkImage != newOptions.blockNetworkImage)
      settings.setBlockNetworkImage(newOptions.blockNetworkImage);

    if (newOptionsMap.get("blockNetworkLoads") != null && options.blockNetworkLoads != newOptions.blockNetworkLoads)
      settings.setBlockNetworkLoads(newOptions.blockNetworkLoads);

    if (newOptionsMap.get("cacheMode") != null && !options.cacheMode.equals(newOptions.cacheMode))
      settings.setCacheMode(newOptions.cacheMode);

    if (newOptionsMap.get("cursiveFontFamily") != null && !options.cursiveFontFamily.equals(newOptions.cursiveFontFamily))
      settings.setCursiveFontFamily(newOptions.cursiveFontFamily);

    if (newOptionsMap.get("defaultFixedFontSize") != null && !options.defaultFixedFontSize.equals(newOptions.defaultFixedFontSize))
      settings.setDefaultFixedFontSize(newOptions.defaultFixedFontSize);

    if (newOptionsMap.get("defaultFontSize") != null && !options.defaultFontSize.equals(newOptions.defaultFontSize))
      settings.setDefaultFontSize(newOptions.defaultFontSize);

    if (newOptionsMap.get("defaultTextEncodingName") != null && !options.defaultTextEncodingName.equals(newOptions.defaultTextEncodingName))
      settings.setDefaultTextEncodingName(newOptions.defaultTextEncodingName);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
      if (newOptionsMap.get("disabledActionModeMenuItems") != null && (options.disabledActionModeMenuItems == null ||
            !options.disabledActionModeMenuItems.equals(newOptions.disabledActionModeMenuItems)))
        settings.setDisabledActionModeMenuItems(newOptions.disabledActionModeMenuItems);

    if (newOptionsMap.get("fantasyFontFamily") != null && !options.fantasyFontFamily.equals(newOptions.fantasyFontFamily))
      settings.setFantasyFontFamily(newOptions.fantasyFontFamily);

    if (newOptionsMap.get("fixedFontFamily") != null && !options.fixedFontFamily.equals(newOptions.fixedFontFamily))
      settings.setFixedFontFamily(newOptions.fixedFontFamily);

    if (newOptionsMap.get("forceDark") != null && !options.forceDark.equals(newOptions.forceDark))
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        settings.setForceDark(newOptions.forceDark);

    if (newOptionsMap.get("geolocationEnabled") != null && options.geolocationEnabled != newOptions.geolocationEnabled)
      settings.setGeolocationEnabled(newOptions.geolocationEnabled);

    if (newOptionsMap.get("layoutAlgorithm") != null && options.layoutAlgorithm != newOptions.layoutAlgorithm) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && newOptions.layoutAlgorithm.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
        settings.setLayoutAlgorithm(newOptions.layoutAlgorithm);
      } else {
        settings.setLayoutAlgorithm(newOptions.layoutAlgorithm);
      }
    }

    if (newOptionsMap.get("loadWithOverviewMode") != null && options.loadWithOverviewMode != newOptions.loadWithOverviewMode)
      settings.setLoadWithOverviewMode(newOptions.loadWithOverviewMode);

    if (newOptionsMap.get("loadsImagesAutomatically") != null && options.loadsImagesAutomatically != newOptions.loadsImagesAutomatically)
      settings.setLoadsImagesAutomatically(newOptions.loadsImagesAutomatically);

    if (newOptionsMap.get("minimumFontSize") != null && !options.minimumFontSize.equals(newOptions.minimumFontSize))
      settings.setMinimumFontSize(newOptions.minimumFontSize);

    if (newOptionsMap.get("minimumLogicalFontSize") != null && !options.minimumLogicalFontSize.equals(newOptions.minimumLogicalFontSize))
      settings.setMinimumLogicalFontSize(newOptions.minimumLogicalFontSize);

    if (newOptionsMap.get("initialScale") != null && !options.initialScale.equals(newOptions.initialScale))
        setInitialScale(newOptions.initialScale);

    if (newOptionsMap.get("needInitialFocus") != null && options.needInitialFocus != newOptions.needInitialFocus)
      settings.setNeedInitialFocus(newOptions.needInitialFocus);

    if (newOptionsMap.get("offscreenPreRaster") != null && options.offscreenPreRaster != newOptions.offscreenPreRaster)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        settings.setOffscreenPreRaster(newOptions.offscreenPreRaster);

    if (newOptionsMap.get("sansSerifFontFamily") != null && !options.sansSerifFontFamily.equals(newOptions.sansSerifFontFamily))
      settings.setSansSerifFontFamily(newOptions.sansSerifFontFamily);

    if (newOptionsMap.get("serifFontFamily") != null && !options.serifFontFamily.equals(newOptions.serifFontFamily))
      settings.setSerifFontFamily(newOptions.serifFontFamily);

    if (newOptionsMap.get("standardFontFamily") != null && !options.standardFontFamily.equals(newOptions.standardFontFamily))
      settings.setStandardFontFamily(newOptions.standardFontFamily);

    if (newOptionsMap.get("preferredContentMode") != null && !options.preferredContentMode.equals(newOptions.preferredContentMode)) {
      switch (fromValue(newOptions.preferredContentMode)) {
        case DESKTOP:
          setDesktopMode(true);
          break;
        case MOBILE:
        case RECOMMENDED:
          setDesktopMode(false);
          break;
      }
    }

    if (newOptionsMap.get("saveFormData") != null && options.saveFormData != newOptions.saveFormData)
      settings.setSaveFormData(newOptions.saveFormData);

    if (newOptionsMap.get("incognito") != null && options.incognito != newOptions.incognito)
      setIncognito(newOptions.incognito);

    if (newOptionsMap.get("hardwareAcceleration") != null && options.hardwareAcceleration != newOptions.hardwareAcceleration) {
      if (newOptions.hardwareAcceleration)
        setLayerType(View.LAYER_TYPE_HARDWARE, null);
      else
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    }

    if (newOptionsMap.get("regexToCancelSubFramesLoading") != null && (options.regexToCancelSubFramesLoading == null ||
            !options.regexToCancelSubFramesLoading.equals(newOptions.regexToCancelSubFramesLoading))) {
      if (newOptions.regexToCancelSubFramesLoading == null)
        regexToCancelSubFramesLoadingCompiled = null;
      else
        regexToCancelSubFramesLoadingCompiled = Pattern.compile(options.regexToCancelSubFramesLoading);
    }

    if (newOptions.contentBlockers != null) {
      contentBlockerHandler.getRuleList().clear();
      for (Map<String, Map<String, Object>> contentBlocker : newOptions.contentBlockers) {
        // compile ContentBlockerTrigger urlFilter
        ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
        ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
        contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
      }
    }

    if (newOptionsMap.get("scrollBarStyle") != null && !options.scrollBarStyle.equals(newOptions.scrollBarStyle))
      setScrollBarStyle(newOptions.scrollBarStyle);

    if (newOptionsMap.get("scrollBarDefaultDelayBeforeFade") != null && (options.scrollBarDefaultDelayBeforeFade == null ||
            !options.scrollBarDefaultDelayBeforeFade.equals(newOptions.scrollBarDefaultDelayBeforeFade)))
      setScrollBarDefaultDelayBeforeFade(newOptions.scrollBarDefaultDelayBeforeFade);

    if (newOptionsMap.get("scrollbarFadingEnabled") != null && !options.scrollbarFadingEnabled.equals(newOptions.scrollbarFadingEnabled))
      setScrollbarFadingEnabled(newOptions.scrollbarFadingEnabled);

    if (newOptionsMap.get("scrollBarFadeDuration") != null && (options.scrollBarFadeDuration == null ||
            !options.scrollBarFadeDuration.equals(newOptions.scrollBarFadeDuration)))
      setScrollBarFadeDuration(newOptions.scrollBarFadeDuration);

    if (newOptionsMap.get("verticalScrollbarPosition") != null && !options.verticalScrollbarPosition.equals(newOptions.verticalScrollbarPosition))
      setVerticalScrollbarPosition(newOptions.verticalScrollbarPosition);

    if (newOptionsMap.get("disableVerticalScroll") != null && options.disableVerticalScroll != newOptions.disableVerticalScroll)
      setVerticalScrollBarEnabled(!newOptions.disableVerticalScroll && newOptions.verticalScrollBarEnabled);

    if (newOptionsMap.get("disableHorizontalScroll") != null && options.disableHorizontalScroll != newOptions.disableHorizontalScroll)
      setHorizontalScrollBarEnabled(!newOptions.disableHorizontalScroll && newOptions.horizontalScrollBarEnabled);

    if (newOptionsMap.get("overScrollMode") != null && !options.overScrollMode.equals(newOptions.overScrollMode))
      setOverScrollMode(newOptions.overScrollMode);

    if (newOptionsMap.get("networkAvailable") != null && options.networkAvailable != newOptions.networkAvailable)
      setNetworkAvailable(newOptions.networkAvailable);

    if (newOptionsMap.get("rendererPriorityPolicy") != null &&
            (options.rendererPriorityPolicy.get("rendererRequestedPriority") != newOptions.rendererPriorityPolicy.get("rendererRequestedPriority") ||
            options.rendererPriorityPolicy.get("waivedWhenNotVisible") != newOptions.rendererPriorityPolicy.get("waivedWhenNotVisible")) &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      setRendererPriorityPolicy(
              (int) newOptions.rendererPriorityPolicy.get("rendererRequestedPriority"),
              (boolean) newOptions.rendererPriorityPolicy.get("waivedWhenNotVisible"));
    }

    options = newOptions;
  }

  public Map<String, Object> getOptions() {
    return (options != null) ? options.getRealOptions(this) : null;
  }

  public void injectDeferredObject(String source, String jsWrapper, final MethodChannel.Result result) {
    String scriptToInject = source;
    if (jsWrapper != null) {
      org.json.JSONArray jsonEsc = new org.json.JSONArray();
      jsonEsc.put(source);
      String jsonRepr = jsonEsc.toString();
      String jsonSourceString = jsonRepr.substring(1, jsonRepr.length() - 1);
      scriptToInject = String.format(jsWrapper, jsonSourceString);
    }
    final String finalScriptToInject = scriptToInject;
    headlessHandler.post(new Runnable() {
      @Override
      public void run() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
          // This action will have the side-effect of blurring the currently focused element
          loadUrl("javascript:" + finalScriptToInject);
          result.success("");
        } else {
          evaluateJavascript(finalScriptToInject, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String s) {
              if (result == null)
                return;
              result.success(s);
            }
          });
        }
      }
    });
  }

  public void evaluateJavascript(String source, MethodChannel.Result result) {
    injectDeferredObject(source, null, result);
  }

  public void injectJavascriptFileFromUrl(String urlFile) {
    String jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %s; d.body.appendChild(c); })(document);";
    injectDeferredObject(urlFile, jsWrapper, null);
  }

  public void injectCSSCode(String source) {
    String jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %s; d.body.appendChild(c); })(document);";
    injectDeferredObject(source, jsWrapper, null);
  }

  public void injectCSSFileFromUrl(String urlFile) {
    String jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet'; c.type='text/css'; c.href = %s; d.head.appendChild(c); })(document);";
    injectDeferredObject(urlFile, jsWrapper, null);
  }

  public HashMap<String, Object> getCopyBackForwardList() {
    WebBackForwardList currentList = copyBackForwardList();
    int currentSize = currentList.getSize();
    int currentIndex = currentList.getCurrentIndex();

    List<HashMap<String, String>> history = new ArrayList<HashMap<String, String>>();

    for(int i = 0; i < currentSize; i++) {
      WebHistoryItem historyItem = currentList.getItemAtIndex(i);
      HashMap<String, String> historyItemMap = new HashMap<>();

      historyItemMap.put("originalUrl", historyItem.getOriginalUrl());
      historyItemMap.put("title", historyItem.getTitle());
      historyItemMap.put("url", historyItem.getUrl());

      history.add(historyItemMap);
    }

    HashMap<String, Object> result = new HashMap<>();

    result.put("history", history);
    result.put("currentIndex", currentIndex);

    return result;
  }

  @Override
  protected void onScrollChanged (int l,
                                  int t,
                                  int oldl,
                                  int oldt) {
    super.onScrollChanged(l, t, oldl, oldt);

    int x = (int) (l/scale);
    int y = (int) (t/scale);

    if (floatingContextMenu != null) {
      floatingContextMenu.setAlpha(0f);
      floatingContextMenu.setVisibility(View.GONE);
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("x", x);
    obj.put("y", y);
    channel.invokeMethod("onScrollChanged", obj);
  }

  public void scrollTo(Integer x, Integer y, Boolean animated) {
    if (animated) {
      PropertyValuesHolder pvhX = PropertyValuesHolder.ofInt("scrollX", x);
      PropertyValuesHolder pvhY = PropertyValuesHolder.ofInt("scrollY", y);
      ObjectAnimator anim = ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY);
      anim.setDuration(300).start();
    } else {
      scrollTo(x, y);
    }
  }

  public void scrollBy(Integer x, Integer y, Boolean animated) {
    if (animated) {
      PropertyValuesHolder pvhX = PropertyValuesHolder.ofInt("scrollX", getScrollX() + x);
      PropertyValuesHolder pvhY = PropertyValuesHolder.ofInt("scrollY", getScrollY() + y);
      ObjectAnimator anim = ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY);
      anim.setDuration(300).start();
    } else {
      scrollBy(x, y);
    }
  }

  class DownloadStartListener implements DownloadListener {
    @Override
    public void onDownloadStart(String url, String userAgent, String contentDisposition, String mimetype, long contentLength) {
      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("url", url);
      channel.invokeMethod("onDownloadStart", obj);
    }
  }

  public void setDesktopMode(final boolean enabled) {
    final WebSettings webSettings = getSettings();

    final String newUserAgent;
    if (enabled) {
      newUserAgent = webSettings.getUserAgentString().replace("Mobile", "eliboM").replace("Android", "diordnA");
    }
    else {
      newUserAgent = webSettings.getUserAgentString().replace("eliboM", "Mobile").replace("diordnA", "Android");
    }

    webSettings.setUserAgentString(newUserAgent);
    webSettings.setUseWideViewPort(enabled);
    webSettings.setLoadWithOverviewMode(enabled);
    webSettings.setSupportZoom(enabled);
    webSettings.setBuiltInZoomControls(enabled);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void printCurrentPage() {
    // Get a PrintManager instance
    PrintManager printManager = (PrintManager) Shared.activity.getSystemService(Context.PRINT_SERVICE);

    if (printManager != null) {
      String jobName = getTitle() + " Document";

      // Get a printCurrentPage adapter instance
      PrintDocumentAdapter printAdapter = createPrintDocumentAdapter(jobName);

      // Create a printCurrentPage job with name and adapter instance
      printManager.print(jobName, printAdapter,
              new PrintAttributes.Builder().build());
    } else {
      Log.e(LOG_TAG, "No PrintManager available");
    }
  }

  public Float getUpdatedScale() {
    return scale;
  }

  @Override
  public void onCreateContextMenu(ContextMenu menu) {
    super.onCreateContextMenu(menu);
    sendOnCreateContextMenuEvent();
  }

  private void sendOnCreateContextMenuEvent() {
    HitTestResult hitTestResult = getHitTestResult();
    Map<String, Object> hitTestResultMap = new HashMap<>();
    hitTestResultMap.put("type", hitTestResult.getType());
    hitTestResultMap.put("extra", hitTestResult.getExtra());

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("hitTestResult", hitTestResultMap);
    channel.invokeMethod("onCreateContextMenu", obj);
  }

  private Point contextMenuPoint = new Point(0, 0);
  private Point lastTouch = new Point(0, 0);

  @Override
  public boolean onTouchEvent(MotionEvent ev) {
    lastTouch = new Point((int) ev.getX(), (int) ev.getY());
    return super.onTouchEvent(ev);
  }

  @Override
  public boolean dispatchTouchEvent(MotionEvent event) {
    return super.dispatchTouchEvent(event);
  }

  @Override
  public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
    InputConnection connection = super.onCreateInputConnection(outAttrs);
    if (connection == null && containerView != null) {
      // workaround to hide the Keyboard when the user click outside
      // on something not focusable such as input or a textarea.
      containerView
        .getHandler()
        .postDelayed(
          new Runnable() {
            @Override
            public void run() {
              InputMethodManager imm =
                      (InputMethodManager) getContext().getSystemService(INPUT_METHOD_SERVICE);
              if (imm != null && !imm.isAcceptingText()) {

                imm.hideSoftInputFromWindow(
                        containerView.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
              }
            }
          },
          128);
    }
    return connection;
  }

  @Override
  public ActionMode startActionMode(ActionMode.Callback callback) {
    return rebuildActionMode(super.startActionMode(callback), callback);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public ActionMode startActionMode(ActionMode.Callback callback, int type) {
    return rebuildActionMode(super.startActionMode(callback, type), callback);
  }

  public ActionMode rebuildActionMode(
          final ActionMode actionMode,
          final ActionMode.Callback callback
  ) {
    boolean hasBeenRemovedAndRebuilt = false;
    if (floatingContextMenu != null) {
      hideContextMenu();
      hasBeenRemovedAndRebuilt = true;
    }
    if (actionMode == null) {
      return null;
    }

    Menu actionMenu = actionMode.getMenu();
    if (options.disableContextMenu) {
      actionMenu.clear();
      return actionMode;
    }

    floatingContextMenu = (LinearLayout) LayoutInflater.from(this.getContext())
            .inflate(R.layout.floating_action_mode, this, false);
    HorizontalScrollView horizontalScrollView = (HorizontalScrollView) floatingContextMenu.getChildAt(0);
    LinearLayout menuItemListLayout = (LinearLayout) horizontalScrollView.getChildAt(0);

    List<Map<String, Object>> customMenuItems = new ArrayList<>();
    ContextMenuOptions contextMenuOptions = new ContextMenuOptions();
    if (contextMenu != null) {
      customMenuItems = (List<Map<String, Object>>) contextMenu.get("menuItems");
      Map<String, Object> contextMenuOptionsMap = (Map<String, Object>) contextMenu.get("options");
     if (contextMenuOptionsMap != null) {
       contextMenuOptions.parse(contextMenuOptionsMap);
     }
    }
    customMenuItems = customMenuItems == null ? new ArrayList<Map<String, Object>>() : customMenuItems;

    if (contextMenuOptions.hideDefaultSystemContextMenuItems == null || !contextMenuOptions.hideDefaultSystemContextMenuItems) {
      for (int i = 0; i < actionMenu.size(); i++) {
        final MenuItem menuItem = actionMenu.getItem(i);
        final int itemId = menuItem.getItemId();
        final String itemTitle = menuItem.getTitle().toString();
        TextView text = (TextView) LayoutInflater.from(this.getContext())
                .inflate(R.layout.floating_action_mode_item, this, false);
        text.setText(itemTitle);
        text.setOnClickListener(new OnClickListener() {
          @Override
          public void onClick(View v) {
            hideContextMenu();
            callback.onActionItemClicked(actionMode, menuItem);

            Map<String, Object> obj = new HashMap<>();
            if (inAppBrowserActivity != null)
              obj.put("uuid", inAppBrowserActivity.uuid);
            obj.put("androidId", itemId);
            obj.put("iosId", null);
            obj.put("title", itemTitle);
            channel.invokeMethod("onContextMenuActionItemClicked", obj);
          }
        });
        if (floatingContextMenu != null) {
          menuItemListLayout.addView(text);
        }
      }
    }

    for (final Map<String, Object> menuItem : customMenuItems) {
      final int itemId = (int) menuItem.get("androidId");
      final String itemTitle = (String) menuItem.get("title");
      TextView text = (TextView) LayoutInflater.from(this.getContext())
              .inflate(R.layout.floating_action_mode_item, this, false);
      text.setText(itemTitle);
      text.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View v) {
          hideContextMenu();

          Map<String, Object> obj = new HashMap<>();
          if (inAppBrowserActivity != null)
            obj.put("uuid", inAppBrowserActivity.uuid);
          obj.put("androidId", itemId);
          obj.put("iosId", null);
          obj.put("title", itemTitle);
          channel.invokeMethod("onContextMenuActionItemClicked", obj);
        }
      });
      if (floatingContextMenu != null) {
        menuItemListLayout.addView(text);

      }
    }

    final int x = (lastTouch != null) ? lastTouch.x : 0;
    final int y = (lastTouch != null) ? lastTouch.y : 0;
    contextMenuPoint = new Point(x, y);

    if (floatingContextMenu != null) {
      floatingContextMenu.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {

        @Override
        public void onGlobalLayout() {
          if (floatingContextMenu != null) {
            floatingContextMenu.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            if (getSettings().getJavaScriptEnabled()) {
              onScrollStopped();
            } else {
              onFloatingActionGlobalLayout(x, y);
            }
          }
        }
      });
      addView(floatingContextMenu, new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, x, y));
      if (hasBeenRemovedAndRebuilt) {
        sendOnCreateContextMenuEvent();
      }
      if (checkContextMenuShouldBeClosedTask != null) {
        checkContextMenuShouldBeClosedTask.run();
      }
    }
    actionMenu.clear();

    return actionMode;
  }

  public void onFloatingActionGlobalLayout(int x, int y) {
    int maxWidth = getWidth();
    int maxHeight = getHeight();
    int width = floatingContextMenu.getWidth();
    int height = floatingContextMenu.getHeight();
    int curx = x - (width / 2);
    if (curx < 0) {
      curx = 0;
    } else if (curx + width > maxWidth) {
      curx = maxWidth - width;
    }
    // float size = 12 * scale;
    float cury = y - (height * 1.5f);
    if (cury < 0) {
      cury = y + height;
    }

    updateViewLayout(
            floatingContextMenu,
            new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, curx, ((int) cury) + getScrollY())
    );

    headlessHandler.post(new Runnable() {
      @Override
      public void run() {
        if (floatingContextMenu != null) {
          floatingContextMenu.setVisibility(View.VISIBLE);
          floatingContextMenu.animate().alpha(1f).setDuration(100).setListener(null);
        }
      }
    });
  }

  public void hideContextMenu() {
    removeView(floatingContextMenu);
    floatingContextMenu = null;
    onHideContextMenu();
  }

  public void onHideContextMenu() {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    channel.invokeMethod("onHideContextMenu", obj);
  }

  public void onScrollStopped() {
    if (floatingContextMenu != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      adjustFloatingContextMenuPosition();
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public void adjustFloatingContextMenuPosition() {
    evaluateJavascript("(function(){" +
            "  var selection = window.getSelection();" +
            "  var rangeY = null;" +
            "  if (selection != null && selection.rangeCount > 0) {" +
            "    var range = selection.getRangeAt(0);" +
            "    var clientRect = range.getClientRects();" +
            "    if (clientRect.length > 0) {" +
            "      rangeY = clientRect[0].y;" +
            "    } else if (document.activeElement) {" +
            "      var boundingClientRect = document.activeElement.getBoundingClientRect();" +
            "      rangeY = boundingClientRect.y;" +
            "    }" +
            "  }" +
            "  return rangeY;" +
            "})();", new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        if (floatingContextMenu != null) {
          if (value != null) {
            int x = contextMenuPoint.x;
            int y = (int) ((Float.parseFloat(value) * scale) + (floatingContextMenu.getHeight() / 3.5));
            contextMenuPoint.y = y;
            onFloatingActionGlobalLayout(x, y);
          } else {
            floatingContextMenu.setVisibility(View.VISIBLE);
            floatingContextMenu.animate().alpha(1f).setDuration(100).setListener(null);
          }
        }
      }
    });
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public void getSelectedText(final ValueCallback<String> resultCallback) {
    evaluateJavascript(getSelectedTextJS, new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        value = (value != null) ? value.substring(1, value.length() - 1) : null;
        resultCallback.onReceiveValue(value);
      }
    });
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public void getSelectedText(final MethodChannel.Result result) {
    getSelectedText(new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        result.success(value);
      }
    });
  }

  public Map<String, Object> requestFocusNodeHref() {
    Message msg = InAppWebView.mHandler.obtainMessage();
    requestFocusNodeHref(msg);
    Bundle bundle = msg.peekData();

    Map<String, Object> obj = new HashMap<>();
    obj.put("src", bundle.getString("src"));
    obj.put("url", bundle.getString("url"));
    obj.put("title", bundle.getString("title"));

    return obj;
  }

  public Map<String, Object> requestImageRef() {
    Message msg = InAppWebView.mHandler.obtainMessage();
    requestImageRef(msg);
    Bundle bundle = msg.peekData();

    Map<String, Object> obj = new HashMap<>();
    obj.put("url", bundle.getString("url"));

    return obj;
  }

  public Map<String, Object> getCertificateMap() {
    return InAppWebView.getCertificateMap(getCertificate());
  }

  public static Map<String, Object> getCertificateMap(SslCertificate sslCertificate) {
    if (sslCertificate != null) {
      SslCertificate.DName issuedByName = sslCertificate.getIssuedBy();
      Map<String, Object> issuedBy = new HashMap<>();
      issuedBy.put("CName", issuedByName.getCName());
      issuedBy.put("DName", issuedByName.getDName());
      issuedBy.put("OName", issuedByName.getOName());
      issuedBy.put("UName", issuedByName.getUName());

      SslCertificate.DName issuedToName = sslCertificate.getIssuedTo();
      Map<String, Object> issuedTo = new HashMap<>();
      issuedTo.put("CName", issuedToName.getCName());
      issuedTo.put("DName", issuedToName.getDName());
      issuedTo.put("OName", issuedToName.getOName());
      issuedTo.put("UName", issuedToName.getUName());

      byte[] x509CertificateData = null;

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        try {
          X509Certificate certificate = sslCertificate.getX509Certificate();
          if (certificate != null) {
            x509CertificateData = certificate.getEncoded();
          }
        } catch (CertificateEncodingException e) {
          e.printStackTrace();
        }
      } else {
        try {
          x509CertificateData = Util.getX509CertFromSslCertHack(sslCertificate).getEncoded();
        } catch (CertificateEncodingException e) {
          e.printStackTrace();
        }
      }

      Map<String, Object> obj = new HashMap<>();
      obj.put("issuedBy", issuedBy);
      obj.put("issuedTo", issuedTo);
      obj.put("validNotAfterDate", sslCertificate.getValidNotAfterDate().getTime());
      obj.put("validNotBeforeDate", sslCertificate.getValidNotBeforeDate().getTime());
      obj.put("x509Certificate", x509CertificateData);

      return obj;
    }

    return null;
  }

  @Override
  public void dispose() {
    if (windowId != null && InAppWebViewChromeClient.windowWebViewMessages.containsKey(windowId)) {
      InAppWebViewChromeClient.windowWebViewMessages.remove(windowId);
    }
    headlessHandler.removeCallbacksAndMessages(null);
    mHandler.removeCallbacksAndMessages(null);
    removeJavascriptInterface(JavaScriptBridgeInterface.name);
    removeAllViews();
    if (checkContextMenuShouldBeClosedTask != null)
      removeCallbacks(checkContextMenuShouldBeClosedTask);
    if (checkScrollStoppedTask != null)
      removeCallbacks(checkScrollStoppedTask);
    super.dispose();
  }

  @Override
  public void destroy() {
    super.destroy();
  }
}
