#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_INTERCEPT_FETCH_REQUEST_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_INTERCEPT_FETCH_REQUEST_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"
#include "intercept_ajax_request_js.h"  // For JAVASCRIPT_UTIL_VAR_NAME

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for intercepting fetch() requests.
 *
 * This script wraps the global fetch() function to intercept requests
 * before they're sent and allow modification of the request/response.
 *
 * Matches iOS implementation: InterceptFetchRequestJS.swift
 */
class InterceptFetchRequestJS {
 public:
  inline static const std::string INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT";

  /**
   * Flag variable name used to enable/disable fetch request interception at runtime.
   */
  static std::string FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._useShouldInterceptFetchRequest";
  }

  /**
   * JavaScript source code for fetch request interception.
   * Wraps the global fetch() function to intercept requests.
   *
   * Matches iOS InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_SOURCE()
   */
  static std::string INTERCEPT_FETCH_REQUEST_JS_SOURCE() {
    const std::string flagIntercept = FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE();
    const std::string utilVarName = InterceptAjaxRequestJS::JAVASCRIPT_UTIL_VAR_NAME();
    const std::string bridgeName = JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME();

    // Ensure utility functions exist (may already be defined by AJAX script)
    std::string utilitySetup = R"JS(
if (typeof )JS" + utilVarName + R"JS( === 'undefined') {
  )JS" + InterceptAjaxRequestJS::JAVASCRIPT_UTIL_JS_SOURCE() + R"JS(
}
)JS";

    return utilitySetup + flagIntercept + R"JS( = true;
(function(fetch) {
  if (fetch == null) {
    return;
  }
  window.fetch = async function(resource, init) {
    if ()JS" + flagIntercept + R"JS( == null || )JS" + flagIntercept + R"JS( == true) {
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
        fetchRequest.url = resource != null ? resource.toString() : null;
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
        fetchRequest.headers = )JS" + utilVarName + R"JS(.convertHeadersToJson(fetchRequest.headers);
      }
      fetchRequest.credentials = )JS" + utilVarName + R"JS(.convertCredentialsToJson(fetchRequest.credentials);
      return )JS" + utilVarName + R"JS(.convertBodyRequest(fetchRequest.body).then(function(body) {
        fetchRequest.body = body;
        return window.)JS" + bridgeName + R"JS(.callHandler('shouldInterceptFetchRequest', fetchRequest).then(function(result) {
          if (result != null) {
            try {
              result = JSON.parse(result);
            } catch(e) {}
            if (result != null && result.action === 0) {
              var controller = new AbortController();
              if (init != null) {
                init.signal = controller.signal;
              } else {
                init = {
                  signal: controller.signal
                };
              }
              controller.abort();
              return fetch(resource, init);
            }
            if (result != null) {
              if (result.body != null && !)JS" + utilVarName + R"JS(.isString(result.body) && result.body.length > 0) {
                var bodyString = )JS" + utilVarName + R"JS(.arrayBufferToString(result.body);
                if ()JS" + utilVarName + R"JS(.isBodyFormData(bodyString)) {
                  var formDataContentType = )JS" + utilVarName + R"JS(.getFormDataContentType(bodyString);
                  if (result.headers != null) {
                    result.headers['Content-Type'] = result.headers['Content-Type'] == null ? formDataContentType : result.headers['Content-Type'];
                  } else {
                    result.headers = { 'Content-Type': formDataContentType };
                  }
                }
              }
              resource = result.url;
              if (init == null) {
                init = {};
              }
              if (result.method != null && result.method.length > 0) {
                init.method = result.method;
              }
              if (result.headers != null && Object.keys(result.headers).length > 0) {
                init.headers = )JS" + utilVarName + R"JS(.convertJsonToHeaders(result.headers);
              }
              if ()JS" + utilVarName + R"JS(.isString(result.body) || result.body == null) {
                init.body = result.body;
              } else if (result.body.length > 0) {
                init.body = new Uint8Array(result.body);
              }
              if (result.mode != null && result.mode.length > 0) {
                init.mode = result.mode;
              }
              if (result.credentials != null) {
                init.credentials = )JS" + utilVarName + R"JS(.convertJsonToCredential(result.credentials);
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
          }
          return fetch(resource, init);
        });
      });
    } else {
      return fetch(resource, init);
    }
  };
})(window.fetch);
)JS";
  }

  /**
   * Creates a PluginScript for fetch request interception.
   *
   * @param allowedOriginRules Optional list of origin rules to restrict script injection.
   * @param forMainFrameOnly Whether to inject only in main frame.
   */
  static std::unique_ptr<PluginScript> INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_unique<PluginScript>(
        INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT_GROUP_NAME,
        INTERCEPT_FETCH_REQUEST_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentStart,
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,                    // contentWorld
        true,                       // requiredInAllContentWorlds
        std::vector<std::string>{}  // no additional message handlers needed
    );
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_INTERCEPT_FETCH_REQUEST_JS_H_
