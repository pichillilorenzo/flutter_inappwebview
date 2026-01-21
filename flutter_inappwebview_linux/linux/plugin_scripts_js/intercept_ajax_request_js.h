#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_INTERCEPT_AJAX_REQUEST_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_INTERCEPT_AJAX_REQUEST_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for intercepting XMLHttpRequest (AJAX) requests.
 *
 * This script wraps XMLHttpRequest prototype methods (open, send, setRequestHeader)
 * to intercept requests before they're sent and handle response callbacks.
 *
 * Matches iOS implementation: InterceptAjaxRequestJS.swift
 */
class InterceptAjaxRequestJS {
 public:
  inline static const std::string INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT";

  /**
   * Flag variable name used to enable/disable AJAX request interception at runtime.
   */
  static std::string FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._useShouldInterceptAjaxRequest";
  }

  /**
   * Flag variable for onAjaxReadyStateChange callback.
   */
  static std::string FLAG_VARIABLE_FOR_ON_AJAX_READY_STATE_CHANGE() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._useOnAjaxReadyStateChange";
  }

  /**
   * Flag variable for onAjaxProgress callback.
   */
  static std::string FLAG_VARIABLE_FOR_ON_AJAX_PROGRESS() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._useOnAjaxProgress";
  }

  /**
   * Flag variable for intercepting only async AJAX requests.
   */
  static std::string FLAG_VARIABLE_FOR_INTERCEPT_ONLY_ASYNC_AJAX_REQUESTS_JS_SOURCE() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._interceptOnlyAsyncAjaxRequests";
  }

  /**
   * JavaScript utility variable name reference.
   */
  static std::string JAVASCRIPT_UTIL_VAR_NAME() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "._util";
  }

  /**
   * JavaScript source code for utility functions needed by AJAX interception.
   * This must be injected before the AJAX interception script.
   */
  static std::string JAVASCRIPT_UTIL_JS_SOURCE() {
    const std::string utilVarName = JAVASCRIPT_UTIL_VAR_NAME();

    return utilVarName + R"JS( = {
  isString: function(variable) {
    return typeof variable === 'string' || variable instanceof String;
  },
  isBodyFormData: function(bodyString) {
    return bodyString.indexOf('------WebKitFormBoundary') === 0;
  },
  getFormDataContentType: function(bodyString) {
    var boundary = bodyString.split('\r\n')[0].trim();
    var contentType = 'multipart/form-data; boundary=' + boundary.substring(2);
    return contentType;
  },
  convertBodyRequest: function(body) {
    return new Promise(function(resolve, reject) {
      if (body == null) {
        resolve(null);
        return;
      }
      if (body instanceof ArrayBuffer) {
        resolve(Array.from(new Uint8Array(body)));
        return;
      }
      if (ArrayBuffer.isView(body)) {
        resolve(Array.from(new Uint8Array(body.buffer)));
        return;
      }
      if (body instanceof Blob) {
        var reader = new FileReader();
        reader.addEventListener('loadend', function() {
          resolve(Array.from(new Uint8Array(reader.result)));
        });
        reader.readAsArrayBuffer(body);
        return;
      }
      if (body instanceof FormData) {
        var entries = body.entries();
        var dataString = '';
        var boundary = '------WebKitFormBoundary' + Math.random().toString(36).substring(7);
        var entry = entries.next();
        while (!entry.done) {
          var name = entry.value[0];
          var value = entry.value[1];
          dataString += boundary + '\r\n';
          if (value instanceof File) {
            dataString += 'Content-Disposition: form-data; name="' + name + '"; filename="' + value.name + '"\r\n';
            dataString += 'Content-Type: ' + value.type + '\r\n\r\n';
            dataString += value.data + '\r\n';
          } else {
            dataString += 'Content-Disposition: form-data; name="' + name + '"\r\n\r\n';
            dataString += value + '\r\n';
          }
          entry = entries.next();
        }
        if (dataString.length > 0) {
          dataString += boundary + '--\r\n';
        }
        resolve(dataString);
        return;
      }
      resolve(body.toString());
    });
  },
  arrayBufferToString: function(arrayBuffer) {
    var decoder = new TextDecoder('utf-8');
    return decoder.decode(new Uint8Array(arrayBuffer));
  },
  convertHeadersToJson: function(headers) {
    var headersObj = {};
    if (headers instanceof Headers) {
      headers.forEach(function(value, key) {
        headersObj[key] = value;
      });
    }
    return headersObj;
  },
  convertJsonToHeaders: function(headersObj) {
    var headers = new Headers();
    for (var key in headersObj) {
      headers.append(key, headersObj[key]);
    }
    return headers;
  },
  convertCredentialsToJson: function(credentials) {
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
    return credentialsObj;
  },
  convertJsonToCredential: function(credentialsJson) {
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
      credentials = credentialsJson.value == null ? undefined : credentialsJson.value;
    }
    return credentials;
  }
};
)JS";
  }

  /**
   * JavaScript source code for AJAX request interception.
   * Wraps XMLHttpRequest prototype methods to intercept requests.
   *
   * Matches iOS InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_SOURCE()
   *
   * @param initialUseOnAjaxReadyStateChange Initial value for onAjaxReadyStateChange flag.
   * @param initialUseOnAjaxProgress Initial value for onAjaxProgress flag.
   */
  static std::string INTERCEPT_AJAX_REQUEST_JS_SOURCE(bool initialUseOnAjaxReadyStateChange,
                                                       bool initialUseOnAjaxProgress) {
    const std::string flagShouldIntercept = FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE();
    const std::string flagReadyStateChange = FLAG_VARIABLE_FOR_ON_AJAX_READY_STATE_CHANGE();
    const std::string flagProgress = FLAG_VARIABLE_FOR_ON_AJAX_PROGRESS();
    const std::string flagOnlyAsync = FLAG_VARIABLE_FOR_INTERCEPT_ONLY_ASYNC_AJAX_REQUESTS_JS_SOURCE();
    const std::string utilVarName = JAVASCRIPT_UTIL_VAR_NAME();
    const std::string bridgeName = JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME();

    return JAVASCRIPT_UTIL_JS_SOURCE() +
           flagShouldIntercept + " = true;\n" +
           flagReadyStateChange + " = " + (initialUseOnAjaxReadyStateChange ? "true" : "false") + ";\n" +
           flagProgress + " = " + (initialUseOnAjaxProgress ? "true" : "false") + ";\n" +
           flagOnlyAsync + " = true;\n" +
           R"JS(
(function(ajax) {
  var send = ajax.prototype.send;
  var open = ajax.prototype.open;
  var setRequestHeader = ajax.prototype.setRequestHeader;
  ajax.prototype._flutter_inappwebview_url = null;
  ajax.prototype._flutter_inappwebview_method = null;
  ajax.prototype._flutter_inappwebview_isAsync = null;
  ajax.prototype._flutter_inappwebview_user = null;
  ajax.prototype._flutter_inappwebview_password = null;
  ajax.prototype._flutter_inappwebview_already_onreadystatechange_wrapped = false;
  ajax.prototype._flutter_inappwebview_request_headers = {};

  function convertRequestResponse(request, callback) {
    if (request.response != null && request.responseType != null) {
      switch (request.responseType) {
        case 'arraybuffer':
          callback(Array.from(new Uint8Array(request.response)));
          return;
        case 'blob':
          var reader = new FileReader();
          reader.addEventListener('loadend', function() {
            callback(Array.from(new Uint8Array(reader.result)));
          });
          reader.readAsArrayBuffer(request.response);
          return;
        case 'document':
          callback(request.response.documentElement.outerHTML);
          return;
        case 'json':
          callback(request.response);
          return;
      }
    }
    callback(null);
  }

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
    if ()JS" + flagShouldIntercept + R"JS( === false || )JS" + flagProgress + R"JS( == null || )JS" + flagProgress + R"JS( === false) {
      return;
    }
    var self = this;
    if ()JS" + flagShouldIntercept + R"JS( == null || )JS" + flagShouldIntercept + R"JS( == true) {
      var headers = this.getAllResponseHeaders();
      var responseHeaders = {};
      if (headers != null) {
        var arr = headers.trim().split(/[\r\n]+/);
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
          responseHeaders: responseHeaders,
          event: {
            type: e.type,
            loaded: e.loaded,
            lengthComputable: e.lengthComputable,
            total: e.total
          }
        };
        window.)JS" + bridgeName + R"JS(.callHandler('onAjaxProgress', ajaxRequest).then(function(result) {
          if (result != null) {
            try {
              result = JSON.parse(result);
            } catch(e) {}
            if (result === 0) {
              self.abort();
              return;
            }
          }
        });
      });
    }
  }

  ajax.prototype.send = function(data) {
    var self = this;
    var canBeIntercepted = self._flutter_inappwebview_isAsync || )JS" + flagOnlyAsync + R"JS( === false;
    if (canBeIntercepted && ()JS" + flagShouldIntercept + R"JS( == null || )JS" + flagShouldIntercept + R"JS( == true)) {
      if ()JS" + flagReadyStateChange + R"JS( === true && !this._flutter_inappwebview_already_onreadystatechange_wrapped) {
        this._flutter_inappwebview_already_onreadystatechange_wrapped = true;
        var realOnreadystatechange = this.onreadystatechange;
        this.onreadystatechange = function() {
          if ()JS" + flagShouldIntercept + R"JS( == null || )JS" + flagShouldIntercept + R"JS( == true) {
            var headers = this.getAllResponseHeaders();
            var responseHeaders = {};
            if (headers != null) {
              var arr = headers.trim().split(/[\r\n]+/);
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
              window.)JS" + bridgeName + R"JS(.callHandler('onAjaxReadyStateChange', ajaxRequest).then(function(result) {
                if (result != null) {
                  try {
                    result = JSON.parse(result);
                  } catch(e) {}
                  if (result === 0) {
                    self.abort();
                    return;
                  }
                }
                if (realOnreadystatechange != null) {
                  realOnreadystatechange();
                }
              });
            });
          } else if (realOnreadystatechange != null) {
            realOnreadystatechange();
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

      )JS" + utilVarName + R"JS(.convertBodyRequest(data).then(function(convertedData) {
        var ajaxRequest = {
          data: convertedData,
          method: self._flutter_inappwebview_method,
          url: self._flutter_inappwebview_url,
          isAsync: self._flutter_inappwebview_isAsync,
          user: self._flutter_inappwebview_user,
          password: self._flutter_inappwebview_password,
          withCredentials: self.withCredentials,
          headers: self._flutter_inappwebview_request_headers,
          responseType: self.responseType
        };
        window.)JS" + bridgeName + R"JS(.callHandler('shouldInterceptAjaxRequest', ajaxRequest).then(function(result) {
          if (result != null) {
            try {
              result = JSON.parse(result);
            } catch(e) {}
            if (result === 0) {
              self.abort();
              return;
            }
            if (result.data != null && !)JS" + utilVarName + R"JS(.isString(result.data) && result.data.length > 0) {
              var bodyString = )JS" + utilVarName + R"JS(.arrayBufferToString(result.data);
              if ()JS" + utilVarName + R"JS(.isBodyFormData(bodyString)) {
                var formDataContentType = )JS" + utilVarName + R"JS(.getFormDataContentType(bodyString);
                if (result.headers != null) {
                  result.headers['Content-Type'] = result.headers['Content-Type'] == null ? formDataContentType : result.headers['Content-Type'];
                } else {
                  result.headers = { 'Content-Type': formDataContentType };
                }
              }
            }
            if ()JS" + utilVarName + R"JS(.isString(result.data) || result.data == null) {
              convertedData = result.data;
            } else if (result.data.length > 0) {
              convertedData = new Uint8Array(result.data);
            }
            self.withCredentials = result.withCredentials;
            if (result.responseType != null && self._flutter_inappwebview_isAsync) {
              self.responseType = result.responseType;
            }
            if (result.headers != null) {
              for (var header in result.headers) {
                var value = result.headers[header];
                var flutter_inappwebview_value = self._flutter_inappwebview_request_headers[header];
                if (flutter_inappwebview_value == null) {
                  self._flutter_inappwebview_request_headers[header] = value;
                } else {
                  self._flutter_inappwebview_request_headers[header] += ', ' + value;
                }
                setRequestHeader.call(self, header, value);
              }
            }
            if ((self._flutter_inappwebview_method != result.method && result.method != null) ||
                (self._flutter_inappwebview_url != result.url && result.url != null) ||
                (self._flutter_inappwebview_isAsync != result.isAsync && result.isAsync != null) ||
                (self._flutter_inappwebview_user != result.user && result.user != null) ||
                (self._flutter_inappwebview_password != result.password && result.password != null)) {
              self.abort();
              self.open(result.method, result.url, result.isAsync, result.user, result.password);
            }
          }
          send.call(self, convertedData);
        });
      });
    } else {
      send.call(this, data);
    }
  };
})(window.XMLHttpRequest);
)JS";
  }

  /**
   * Creates a PluginScript for AJAX request interception.
   *
   * @param allowedOriginRules Optional list of origin rules to restrict script injection.
   * @param forMainFrameOnly Whether to inject only in main frame.
   * @param initialUseOnAjaxReadyStateChange Initial value for onAjaxReadyStateChange flag.
   * @param initialUseOnAjaxProgress Initial value for onAjaxProgress flag.
   */
  static std::unique_ptr<PluginScript> INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly,
      bool initialUseOnAjaxReadyStateChange = false,
      bool initialUseOnAjaxProgress = false) {
    return std::make_unique<PluginScript>(
        INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT_GROUP_NAME,
        INTERCEPT_AJAX_REQUEST_JS_SOURCE(initialUseOnAjaxReadyStateChange, initialUseOnAjaxProgress),
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

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_INTERCEPT_AJAX_REQUEST_JS_H_
