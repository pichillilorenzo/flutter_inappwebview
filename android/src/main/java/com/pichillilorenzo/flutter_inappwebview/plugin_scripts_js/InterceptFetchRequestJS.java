package com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js;

import com.pichillilorenzo.flutter_inappwebview.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview.types.UserScriptInjectionTime;

public class InterceptFetchRequestJS {

  public static final String INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT";
  public static final String FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE = JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "._useShouldInterceptFetchRequest";
  public static final PluginScript INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT = new PluginScript(
          InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT_GROUP_NAME,
          InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_SOURCE,
          UserScriptInjectionTime.AT_DOCUMENT_START,
          null,
          true
  );

  public static final String INTERCEPT_FETCH_REQUEST_JS_SOURCE = "(function(fetch) {" +
          "  var w = (window.top == null || window.top === window) ? window : window.top;" +
          "  w." + FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE + " = true;" +
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
          "    var w = (window.top == null || window.top === window) ? window : window.top;" +
          "    if (w." + FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE + " == null || w." + FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE + " == true) {" +
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
          "        return window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('shouldInterceptFetchRequest', fetchRequest).then(function(result) {" +
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
}
