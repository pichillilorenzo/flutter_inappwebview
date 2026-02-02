//
//  javaScriptBridgeJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class JavaScriptBridgeJS {
    private static var _JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview"
    public static func set_JAVASCRIPT_BRIDGE_NAME(bridgeName: String) {
        _JAVASCRIPT_BRIDGE_NAME = bridgeName
    }
    public static func get_JAVASCRIPT_BRIDGE_NAME() -> String {
        return _JAVASCRIPT_BRIDGE_NAME
    }
    
    public static let JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT"
    
    public static let VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET = "$IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_BRIDGE_SECRET"

    public static func JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(expectedBridgeSecret: String, allowedOriginRules: [String]?, forMainFrameOnly: Bool) -> PluginScript {
        let source = JAVASCRIPT_BRIDGE_JS_SOURCE().replacingOccurrences(of: VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET, with: expectedBridgeSecret)
        return PluginScript(
            groupName: JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: source,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: forMainFrameOnly,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: true,
            messageHandlerNames: ["callHandler"])
    }

    public static func JAVASCRIPT_BRIDGE_JS_SOURCE() -> String {
        return """
            window.\(get_JAVASCRIPT_BRIDGE_NAME()) = {};
            \(WebMessageChannelJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME()) = {};
            (function(window) {
                var bridgeSecret = '\(VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET)';
                var _JSON_stringify;
                var _Array_slice;
                var _setTimeout;
                var _Promise;
                var _UserMessageHandler;
                var _postMessage;
                try {
                  _JSON_stringify = window.JSON.stringify;
                  _Array_slice = window.Array.prototype.slice;
                  _Array_slice.call = window.Function.prototype.call;
                  _setTimeout = window.setTimeout;
                  _Promise = window.Promise;
                  _UserMessageHandler = window.webkit.messageHandlers['callHandler'];
                  _postMessage = _UserMessageHandler.postMessage;
                  _postMessage.call = window.Function.prototype.call;
                } catch (_) { return; }
                window.\(get_JAVASCRIPT_BRIDGE_NAME()).callHandler = function() {
                    var _windowId = \(WindowIdJS.WINDOW_ID_VARIABLE_JS_SOURCE());
                    var _callHandlerID = _setTimeout(function(){});
                    _postMessage.call(_UserMessageHandler, {
                        'handlerName': arguments[0],
                        '_callHandlerID': _callHandlerID,
                        '_bridgeSecret': bridgeSecret,
                        'args': _JSON_stringify(_Array_slice.call(arguments, 1)),
                        '_windowId': _windowId
                    });
                    return new _Promise(function(resolve, reject) {
                        try {
                            (window.top === window ? window : window.top).\(get_JAVASCRIPT_BRIDGE_NAME())[_callHandlerID] = {resolve: resolve, reject: reject};
                        } catch (e) {
                            resolve();
                        }
                    });
                };
            })(window);
            \(WebMessageListenerJS.WEB_MESSAGE_LISTENER_JS_SOURCE())
            \(UTIL_JS_SOURCE())
        """
    }

    public static let PLATFORM_READY_JS_SOURCE = "window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));";

    public static func JAVASCRIPT_UTIL_VAR_NAME() -> String {
        return "window.\(get_JAVASCRIPT_BRIDGE_NAME())._Util"
    }

    /*
     https://github.com/github/fetch/blob/master/fetch.js
     */
    public static func UTIL_JS_SOURCE() -> String {
        return """
        \(JAVASCRIPT_UTIL_VAR_NAME()) = {
            support: {
                searchParams: 'URLSearchParams' in window,
                iterable: 'Symbol' in window && 'iterator' in Symbol,
                blob:
                    'FileReader' in window &&
                    'Blob' in window &&
                    (function() {
                      try {
                        new Blob();
                        return true;
                      } catch (e) {
                        return false;
                      }
                    })(),
                formData: 'FormData' in window,
                arrayBuffer: 'ArrayBuffer' in window
            },
            isDataView: function(obj) {
                return obj && DataView.prototype.isPrototypeOf(obj);
            },
            fileReaderReady: function(reader) {
                  return new Promise(function(resolve, reject) {
                        reader.onload = function() {
                            resolve(reader.result);
                        };
                        reader.onerror = function() {
                            reject(reader.error);
                        };
                  });
            },
            readBlobAsArrayBuffer: function(blob) {
                var reader = new FileReader();
                var promise = \(JAVASCRIPT_UTIL_VAR_NAME()).fileReaderReady(reader);
                reader.readAsArrayBuffer(blob);
                return promise;
            },
            convertBodyToArrayBuffer: function(body) {
                var viewClasses = [
                    '[object Int8Array]',
                    '[object Uint8Array]',
                    '[object Uint8ClampedArray]',
                    '[object Int16Array]',
                    '[object Uint16Array]',
                    '[object Int32Array]',
                    '[object Uint32Array]',
                    '[object Float32Array]',
                    '[object Float64Array]'
                ];
                var isArrayBufferView = null;
                if (\(JAVASCRIPT_UTIL_VAR_NAME()).support.arrayBuffer) {
                    isArrayBufferView =
                        ArrayBuffer.isView ||
                        function(obj) {
                            return obj && viewClasses.indexOf(Object.prototype.toString.call(obj)) > -1;
                        };
                }
    
                var bodyUsed = false;
    
                this._bodyInit = body;
                if (!body) {
                    this._bodyText = '';
                } else if (typeof body === 'string') {
                    this._bodyText = body;
                } else if (\(JAVASCRIPT_UTIL_VAR_NAME()).support.blob && Blob.prototype.isPrototypeOf(body)) {
                    this._bodyBlob = body;
                } else if (\(JAVASCRIPT_UTIL_VAR_NAME()).support.formData && FormData.prototype.isPrototypeOf(body)) {
                    this._bodyFormData = body;
                } else if (\(JAVASCRIPT_UTIL_VAR_NAME()).support.searchParams && URLSearchParams.prototype.isPrototypeOf(body)) {
                    this._bodyText = body.toString();
                } else if (\(JAVASCRIPT_UTIL_VAR_NAME()).support.arrayBuffer && \(JAVASCRIPT_UTIL_VAR_NAME()).support.blob && \(JAVASCRIPT_UTIL_VAR_NAME()).isDataView(body)) {
                    this._bodyArrayBuffer = bufferClone(body.buffer);
                    this._bodyInit = new Blob([this._bodyArrayBuffer]);
                } else if (\(JAVASCRIPT_UTIL_VAR_NAME()).support.arrayBuffer && (ArrayBuffer.prototype.isPrototypeOf(body) || isArrayBufferView(body))) {
                    this._bodyArrayBuffer = bufferClone(body);
                } else {
                    this._bodyText = body = Object.prototype.toString.call(body);
                }
    
                this.blob = function () {
                    if (bodyUsed) {
                        return Promise.reject(new TypeError('Already read'));
                    }
                    bodyUsed = true;
                    if (this._bodyBlob) {
                        return Promise.resolve(this._bodyBlob);
                    } else if (this._bodyArrayBuffer) {
                        return Promise.resolve(new Blob([this._bodyArrayBuffer]));
                    } else if (this._bodyFormData) {
                        throw new Error('could not read FormData body as blob');
                    } else {
                        return Promise.resolve(new Blob([this._bodyText]));
                    }
                };
    
                if (this._bodyArrayBuffer) {
                    if (bodyUsed) {
                        return Promise.reject(new TypeError('Already read'));
                    }
                    bodyUsed = true;
                    if (ArrayBuffer.isView(this._bodyArrayBuffer)) {
                        return Promise.resolve(
                          this._bodyArrayBuffer.buffer.slice(
                            this._bodyArrayBuffer.byteOffset,
                            this._bodyArrayBuffer.byteOffset + this._bodyArrayBuffer.byteLength
                          )
                        );
                    } else {
                        return Promise.resolve(this._bodyArrayBuffer);
                    }
                }
                return this.blob().then(\(JAVASCRIPT_UTIL_VAR_NAME()).readBlobAsArrayBuffer);
            },
            isString: function(variable) {
                return typeof variable === 'string' || variable instanceof String;
            },
            convertBodyRequest: function(body) {
                if (body == null) {
                    return new Promise((resolve, reject) => resolve(null));
                }
                if (\(JAVASCRIPT_UTIL_VAR_NAME()).isString(body) || (\(JAVASCRIPT_UTIL_VAR_NAME()).support.searchParams && body instanceof URLSearchParams)) {
                    return new Promise((resolve, reject) => resolve(body.toString()));
                }
                if (window.Response != null) {
                    return new Response(body).arrayBuffer().then(function(arrayBuffer) {
                        return Array.from(new Uint8Array(arrayBuffer));
                    });
                }
                return \(JAVASCRIPT_UTIL_VAR_NAME()).convertBodyToArrayBuffer(body).then(function(arrayBuffer) {
                    return Array.from(new Uint8Array(arrayBuffer));
                });
            },
            arrayBufferToString: function(arrayBuffer) {
                var uint8Array = new Uint8Array(arrayBuffer);
                return uint8Array.reduce(function(acc, i) { return acc += String.fromCharCode.apply(null, [i]); }, '');
            },
            isBodyFormData: function(bodyString) {
                return bodyString.indexOf('------WebKitFormBoundary') >= 0;
            },
            getFormDataContentType: function(bodyString) {
                var boundary = bodyString.substr(2, 40);
                return 'multipart/form-data; boundary=' + boundary;
            },
            convertHeadersToJson: function(headers) {
                var headersObj = {};
                for (var header of headers.keys()) {
                  var value = headers.get(header);
                  headersObj[header] = value;
                }
                return headersObj;
            },
            convertJsonToHeaders: function(headersJson) {
                return new Headers(headersJson);
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
    """
    }
}
