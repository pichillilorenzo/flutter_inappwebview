const port = browser.runtime.connectNative("javascriptBridge");
port.onMessage.addListener(message => {
  if (message.initialOptions != null) {
    if (message.initialOptions.useShouldInterceptAjaxRequest) {
      overrideXMLHttpRequest();
    }
  }
  if (message._callHandlerID != null && window.wrappedJSObject.flutter_inappwebview[message._callHandlerID] != null) {
    window.wrappedJSObject.flutter_inappwebview[message._callHandlerID](window.wrappedJSObject.JSON.parse(message.json));
    delete window.wrappedJSObject.flutter_inappwebview[message._callHandlerID];
  }
});
port.postMessage("I'm ready!");

window.flutter_inappwebview = {
  _platformReady: false,
  _useShouldInterceptAjaxRequest: false,
  _lastAnchorOrImageTouched: null,
  _lastImageTouched: null,
  _webMessageChannels: {},
  callHandler: function() {
    var _callHandlerID = setTimeout(function(){});
    port.postMessage({
      handlerName: arguments[0],
      _callHandlerID: _callHandlerID,
      args: JSON.stringify(Array.prototype.slice.call(arguments, 1))
    });
    return new window.Promise(function(resolve, reject) {
      window.wrappedJSObject.flutter_inappwebview[_callHandlerID] = resolve;
    });
  },
  _Util: {
    support: {
        searchParams: 'URLSearchParams' in window,
        iterable: 'Symbol' in window && 'iterator' in Symbol,
        blob:
            'FileReader' in window &&
            'Blob' in window &&
            (function() {
              try {
                new window.Blob();
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
          return new window.Promise(function(resolve, reject) {
                reader.onload = function() {
                    resolve(reader.result);
                };
                reader.onerror = function() {
                    reject(reader.error);
                };
          });
    },
    readBlobAsArrayBuffer: function(blob) {
        var reader = new window.FileReader();
        var promise = window.flutter_inappwebview._Util.fileReaderReady(reader);
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
        if (window.flutter_inappwebview._Util.support.arrayBuffer) {
            isArrayBufferView =
                ArrayBuffer.isView ||
                function(obj) {
                    return obj && viewClasses.indexOf(Object.prototype.toString.call(obj)) > -1;
                };
        }
        var bodyUsed = false;
        this.wrappedJSObject._bodyInit = body;
        if (!body) {
            this.wrappedJSObject._bodyText = '';
        } else if (typeof body === 'string') {
            this.wrappedJSObject._bodyText = body;
        } else if (window.flutter_inappwebview._Util.support.blob && Blob.prototype.isPrototypeOf(body)) {
            this.wrappedJSObject._bodyBlob = body;
        } else if (window.flutter_inappwebview._Util.support.formData && FormData.prototype.isPrototypeOf(body)) {
            this.wrappedJSObject._bodyFormData = body;
        } else if (window.flutter_inappwebview._Util.support.searchParams && URLSearchParams.prototype.isPrototypeOf(body)) {
            this.wrappedJSObject._bodyText = body.toString();
        } else if (window.flutter_inappwebview._Util.support.arrayBuffer && window.flutter_inappwebview._Util.support.blob && window.flutter_inappwebview._Util.isDataView(body)) {
            this.wrappedJSObject._bodyArrayBuffer = bufferClone(body.buffer);
            this.wrappedJSObject._bodyInit = new window.Blob([this.wrappedJSObject._bodyArrayBuffer]);
        } else if (window.flutter_inappwebview._Util.support.arrayBuffer && (ArrayBuffer.prototype.isPrototypeOf(body) || isArrayBufferView(body))) {
            this.wrappedJSObject._bodyArrayBuffer = bufferClone(body);
        } else {
            this.wrappedJSObject._bodyText = body = Object.prototype.toString.call(body);
        }
        this.wrappedJSObject.blob = function () {
            if (bodyUsed) {
                return window.Promise.reject(new window.TypeError('Already read'));
            }
            bodyUsed = true;
            if (this.wrappedJSObject._bodyBlob) {
                return window.Promise.resolve(this.wrappedJSObject._bodyBlob);
            } else if (this.wrappedJSObject._bodyArrayBuffer) {
                return window.Promise.resolve(new window.Blob([this.wrappedJSObject._bodyArrayBuffer]));
            } else if (this.wrappedJSObject._bodyFormData) {
                throw new window.Error('could not read FormData body as blob');
            } else {
                return window.Promise.resolve(new window.Blob([this.wrappedJSObject._bodyText]));
            }
        };
        if (this.wrappedJSObject._bodyArrayBuffer) {
            if (bodyUsed) {
                return window.Promise.reject(new window.TypeError('Already read'));
            }
            bodyUsed = true;
            if (ArrayBuffer.isView(this.wrappedJSObject._bodyArrayBuffer)) {
                return window.Promise.resolve(
                  this.wrappedJSObject._bodyArrayBuffer.buffer.slice(
                    this.wrappedJSObject._bodyArrayBuffer.byteOffset,
                    this.wrappedJSObject._bodyArrayBuffer.byteOffset + this.wrappedJSObject._bodyArrayBuffer.byteLength
                  )
                );
            } else {
                return window.Promise.resolve(this.wrappedJSObject._bodyArrayBuffer);
            }
        }
        return this.wrappedJSObject.blob().then(window.flutter_inappwebview._Util.readBlobAsArrayBuffer);
    },
    isString: function(variable) {
        return typeof variable === 'string' || variable instanceof String;
    },
    convertBodyRequest: function(body) {
        if (body == null) {
            return new window.Promise((resolve, reject) => resolve(null));
        }
        if (window.flutter_inappwebview._Util.isString(body) || (window.flutter_inappwebview._Util.support.searchParams && body instanceof URLSearchParams)) {
            return new window.Promise((resolve, reject) => resolve(body.toString()));
        }
        if (window.Response != null) {
            return new window.Response(body).arrayBuffer().then(function(arrayBuffer) {
                return window.Array.from(new window.Uint8Array(arrayBuffer));
            });
        }
        return window.flutter_inappwebview._Util.convertBodyToArrayBuffer(body).then(function(arrayBuffer) {
            return window.Array.from(new window.Uint8Array(arrayBuffer));
        });
    },
    arrayBufferToString: function(arrayBuffer) {
        return window.String.fromCharCode.apply(String, arrayBuffer);
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
        return new window.Headers(headersJson);
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
          credentials = new window.FederatedCredential({
            id: credentialsJson.id,
            name: credentialsJson.name,
            protocol: credentialsJson.protocol,
            provider: credentialsJson.provider,
            iconURL: credentialsJson.iconURL
          });
        } else if (window.PasswordCredential != null && credentialsJson.type === 'password') {
          credentials = new window.PasswordCredential({
            id: credentialsJson.id,
            name: credentialsJson.name,
            password: credentialsJson.password,
            iconURL: credentialsJson.iconURL
          });
        } else {
          credentials = credentialsJson.value == null ? undefined : credentialsJson.value;
        }
        return credentials;
    },
    _normalizeIPv6: function(ip_string) {
        // replace ipv4 address if any
        var ipv4 = ip_string.match(/(.*:)([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$)/);
        if (ipv4) {
            ip_string = ipv4[1];
            ipv4 = ipv4[2].match(/[0-9]+/g);
            for (var i = 0;i < 4;i ++) {
                var byte = parseInt(ipv4[i],10);
                ipv4[i] = ("0" + byte.toString(16)).substr(-2);
            }
            ip_string += ipv4[0] + ipv4[1] + ':' + ipv4[2] + ipv4[3];
        }

        // take care of leading and trailing ::
        ip_string = ip_string.replace(/^:|:$/g, '');

        var ipv6 = ip_string.split(':');

        for (var i = 0; i < ipv6.length; i ++) {
            var hex = ipv6[i];
            if (hex != "") {
                // normalize leading zeros
                ipv6[i] = ("0000" + hex).substr(-4);
            }
            else {
                // normalize grouped zeros ::
                hex = [];
                for (var j = ipv6.length; j <= 8; j ++) {
                    hex.push('0000');
                }
                ipv6[i] = hex.join(':');
            }
        }

        return ipv6.join(':');
    }
  },
  _findElementsAtPoint: function(x, y) {
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
      return JSON.stringify(data);
  },
  _isOriginAllowed: function(allowedOriginRules, scheme, host, port) {
      for (var rule of allowedOriginRules) {
          if (rule === "*") {
              return true;
          }
          if (scheme == null || scheme === "") {
              continue;
          }
          if ((scheme == null || scheme === "") && (host == null || host === "") && (port === 0 || port === "" || port == null)) {
              continue;
          }
          var rulePort = rule.port == null || rule.port === 0 ? (rule.scheme == "https" ? 443 : 80) : rule.port;
          var currentPort = port === 0 || port === "" || port == null ? (scheme == "https" ? 443 : 80) : port;
          var IPv6 = null;
          if (rule.host != null && rule.host[0] === "[") {
              try {
                  IPv6 = window.flutter_inappwebview._Util._normalizeIPv6(rule.host.substring(1, rule.host.length - 1));
              } catch {}
          }
          var hostIPv6 = null;
          try {
              hostIPv6 = window.flutter_inappwebview._Util._normalizeIPv6(host);
          } catch {}

          var schemeAllowed = scheme == rule.scheme;

          var hostAllowed = rule.host == null ||
              rule.host === "" ||
              host === rule.host ||
              (rule.host[0] === "*" && host != null && host.indexOf(rule.host.split("*")[1]) >= 0) ||
              (hostIPv6 != null && IPv6 != null && hostIPv6 === IPv6);

          var portAllowed = rulePort === currentPort;

          if (schemeAllowed && hostAllowed && portAllowed) {
              return true;
          }
      }
      return false;
  }
};

window.wrappedJSObject.flutter_inappwebview = cloneInto(window.flutter_inappwebview, window, {cloneFunctions: true});

var oldLogs = {
    'log': window.wrappedJSObject.console.log,
    'debug': window.wrappedJSObject.console.debug,
    'error': window.wrappedJSObject.console.error,
    'info': window.wrappedJSObject.console.info,
    'warn': window.wrappedJSObject.console.warn
};
for (var k in oldLogs) {
    (function(oldLog) {
        window.wrappedJSObject.console[oldLog] = exportFunction(function() {
            oldLogs[oldLog](...arguments);

            let message = '';
            for (let i in arguments) {
                if (message == '') {
                    message += arguments[i];
                }
                else {
                    message += ' ' + arguments[i];
                }
            }

            let messageLevel = "LOG";
            switch (oldLog) {
                case "log":
                    messageLevel = "LOG"
                    break;
                case "debug":
                    // on Android, console.debug is TIP
                    messageLevel = "TIP"
                    break;
                case "error":
                    messageLevel = "ERROR"
                    break;
                case "info":
                    // on Android, console.info is LOG
                    messageLevel = "LOG"
                    break;
                case "warn":
                    messageLevel = "WARNING"
                    break;
                default:
                    messageLevel = "LOG"
                    break;
            }

            port.postMessage({
              event: "onConsoleMessage",
              message: message,
              messageLevel: messageLevel
            });
        }, window.console, {defineAs: oldLog});
    })(k);
}

function overrideXMLHttpRequest() {
  var ajax = window.wrappedJSObject.XMLHttpRequest;
  window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest = true;
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
  ajax.prototype._flutter_inappwebview_request_headers = new window.wrappedJSObject.Object();
  function convertRequestResponse(request, callback) {
    if (request.response != null && request.responseType != null) {
      switch (request.responseType) {
        case 'arraybuffer':
          callback(new window.wrappedJSObject.Uint8Array(request.response));
          return;
        case 'blob':
          const reader = new window.wrappedJSObject.FileReader();
          reader.addEventListener('loadend', function() {
            callback(new window.wrappedJSObject.Uint8Array(reader.result));
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
  ajax.prototype.open = exportFunction(function(method, url, isAsync, user, password) {
    isAsync = (isAsync != null) ? isAsync : true;
    this.wrappedJSObject._flutter_inappwebview_url = url;
    this.wrappedJSObject._flutter_inappwebview_method = method;
    this.wrappedJSObject._flutter_inappwebview_isAsync = isAsync;
    this.wrappedJSObject._flutter_inappwebview_user = user;
    this.wrappedJSObject._flutter_inappwebview_password = password;
    this.wrappedJSObject._flutter_inappwebview_request_headers = new window.wrappedJSObject.Object();
    open.call(this.wrappedJSObject, method, url, isAsync, user, password);
  }, ajax.prototype, {defineAs: 'open'});
  ajax.prototype.setRequestHeader = exportFunction(function(header, value) {
    this.wrappedJSObject._flutter_inappwebview_request_headers[header] = value;
    setRequestHeader.call(this.wrappedJSObject, header, value);
  }, ajax.prototype, {defineAs: 'setRequestHeader'});
  function handleEvent(e) {
    var self = this.wrappedJSObject;
    if (window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest == null || window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest == true) {
      var headers = this.wrappedJSObject.getAllResponseHeaders();
      var responseHeaders = new window.wrappedJSObject.Object();
      if (headers != null) {
        var arr = headers.trim().split(/[\r\n]+/);
        arr.forEach(function (line) {
          var parts = line.split(': ');
          var header = parts.shift();
          var value = parts.join(': ');
          responseHeaders[header] = value;
        });
      }
      convertRequestResponse(this.wrappedJSObject, function(response) {
        var ajaxRequest = new window.wrappedJSObject.Object({
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
        });
        window.flutter_inappwebview.callHandler('onAjaxProgress', ajaxRequest).then(function(result) {
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
  ajax.prototype.send = exportFunction(function(data) {
    var self = this.wrappedJSObject;
    if (window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest == null || window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest == true) {
      if (!this.wrappedJSObject._flutter_inappwebview_already_onreadystatechange_wrapped) {
        this.wrappedJSObject._flutter_inappwebview_already_onreadystatechange_wrapped = true;
        var onreadystatechange = this.wrappedJSObject.onreadystatechange;
        this.onreadystatechange = function() {
          if (window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest == null || window.wrappedJSObject.flutter_inappwebview._useShouldInterceptAjaxRequest == true) {
            var headers = this.wrappedJSObject.getAllResponseHeaders();
            var responseHeaders = new window.wrappedJSObject.Object();
            if (headers != null) {
              var arr = headers.trim().split(/[\r\n]+/);
              arr.forEach(function (line) {
                var parts = line.split(': ');
                var header = parts.shift();
                var value = parts.join(': ');
                responseHeaders[header] = value;
              });
            }
            convertRequestResponse(this.wrappedJSObject, function(response) {
              var ajaxRequest = new window.wrappedJSObject.Object({
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
              });
              window.flutter_inappwebview.callHandler('onAjaxReadyStateChange', ajaxRequest).then(function(result) {
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
      this.wrappedJSObject.addEventListener('loadstart', handleEvent);
      this.wrappedJSObject.addEventListener('load', handleEvent);
      this.wrappedJSObject.addEventListener('loadend', handleEvent);
      this.wrappedJSObject.addEventListener('progress', handleEvent);
      this.wrappedJSObject.addEventListener('error', handleEvent);
      this.wrappedJSObject.addEventListener('abort', handleEvent);
      this.wrappedJSObject.addEventListener('timeout', handleEvent);
      window.flutter_inappwebview._Util.convertBodyRequest(data).then(function(data) {
        var ajaxRequest = new window.wrappedJSObject.Object({
          data: data,
          method: self._flutter_inappwebview_method,
          url: self._flutter_inappwebview_url,
          isAsync: self._flutter_inappwebview_isAsync,
          user: self._flutter_inappwebview_user,
          password: self._flutter_inappwebview_password,
          withCredentials: self.withCredentials,
          headers: self._flutter_inappwebview_request_headers,
          responseType: self.responseType
        });
        window.flutter_inappwebview.callHandler('shouldInterceptAjaxRequest', ajaxRequest).then(function(result) {
          if (result != null) {
            switch (result.action) {
              case 0:
                self.abort();
                return;
            };
            if (result.data != null && !window.wrappedJSObject.flutter_inappwebview._Util.isString(result.data) && result.data.length > 0) {
              var bodyString = window.wrappedJSObject.flutter_inappwebview._Util.arrayBufferToString(result.data);
              if (window.wrappedJSObject.flutter_inappwebview._Util.isBodyFormData(bodyString)) {
                var formDataContentType = window.wrappedJSObject.flutter_inappwebview._Util.getFormDataContentType(bodyString);
                if (result.headers != null) {
                  result.headers['Content-Type'] = result.headers['Content-Type'] == null ? formDataContentType : result.headers['Content-Type'];
                } else {
                  result.headers = { 'Content-Type': formDataContentType };
                }
              }
            }
            if (window.wrappedJSObject.flutter_inappwebview._Util.isString(result.data) || result.data == null) {
              data = result.data;
            } else if (result.data.length > 0) {
              data = new window.wrappedJSObject.Uint8Array(result.data);
            }
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
      });
    } else {
      send.call(this.wrappedJSObject, data);
    }
  }, ajax.prototype, {defineAs: 'send'});
}

window.wrappedJSObject.print = exportFunction(function() {
  window.flutter_inappwebview.callHandler('onPrint', window.wrappedJSObject.location.href);
}, window, {defineAs: 'print'});

window.addEventListener('touchstart', function(event) {
    var target = event.target;
    while (target) {
        if (target.tagName === 'IMG') {
            var img = target;
            window.wrappedJSObject.flutter_inappwebview._lastImageTouched = cloneInto({
                url: img.src
            }, window.flutter_inappwebview);
            window.flutter_inappwebview.callHandler('onLastImageTouched',
              window.wrappedJSObject.flutter_inappwebview._lastImageTouched);
            var parent = img.parentNode;
            while (parent) {
                if (parent.tagName === 'A') {
                    window.wrappedJSObject.flutter_inappwebview._lastAnchorOrImageTouched = cloneInto({
                        title: parent.textContent,
                        url: parent.href,
                        src: img.src
                    }, window.flutter_inappwebview);
                    window.flutter_inappwebview.callHandler('onLastAnchorOrImageTouched',
                      window.wrappedJSObject.flutter_inappwebview._lastAnchorOrImageTouched);
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
            window.wrappedJSObject.flutter_inappwebview._lastImageTouched = (img != null) ?
                cloneInto({url: imgSrc}, window.flutter_inappwebview) :
                cloneInto(window.wrappedJSObject.flutter_inappwebview, window.flutter_inappwebview._lastImageTouched);
            window.flutter_inappwebview.callHandler('onLastImageTouched',
              window.wrappedJSObject.flutter_inappwebview._lastImageTouched);
            window.wrappedJSObject.flutter_inappwebview._lastAnchorOrImageTouched = cloneInto({
                title: link.textContent,
                url: link.href,
                src: imgSrc
            }, window.flutter_inappwebview);
            window.flutter_inappwebview.callHandler('onLastAnchorOrImageTouched',
              window.wrappedJSObject.flutter_inappwebview._lastAnchorOrImageTouched);
            return;
        }
        target = target.parentNode;
    }
});

function FlutterInAppWebViewWebMessageListener(jsObjectName) {
    this.jsObjectName = jsObjectName;
    this.listeners = [];
    this.onmessage = null;
}
FlutterInAppWebViewWebMessageListener.prototype.postMessage = function(message) {
    window.flutter_inappwebview.callHandler('onWebMessageListenerPostMessageReceived', {jsObjectName: this.jsObjectName, message: message});
};
FlutterInAppWebViewWebMessageListener.prototype.addEventListener = function(type, listener) {
    if (listener == null) {
        return;
    }
    this.listeners.push(listener);
};
FlutterInAppWebViewWebMessageListener.prototype.removeEventListener = function(type, listener) {
    if (listener == null) {
        return;
    }
    var index = this.listeners.indexOf(listener);
    if (index >= 0) {
        this.listeners.splice(index, 1);
    }
};
window.wrappedJSObject.FlutterInAppWebViewWebMessageListener = cloneInto(FlutterInAppWebViewWebMessageListener, window, {cloneFunctions: true});