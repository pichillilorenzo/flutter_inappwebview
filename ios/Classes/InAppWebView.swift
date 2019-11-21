//
//  InAppWebView.swift
//  flutter_inappbrowser
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

let JAVASCRIPT_BRIDGE_NAME = "flutter_inappbrowser"

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
                window.webkit.messageHandlers[oldLog].postMessage(message);
            }
        })(k);
    }
})(window.console);
"""

let javaScriptBridgeJS = """
window.\(JAVASCRIPT_BRIDGE_NAME) = {};
window.\(JAVASCRIPT_BRIDGE_NAME).callHandler = function() {
    var _callHandlerID = setTimeout(function(){});
    window.webkit.messageHandlers['callHandler'].postMessage( {'handlerName': arguments[0], '_callHandlerID': _callHandlerID, 'args': JSON.stringify(Array.prototype.slice.call(arguments, 1))} );
    return new Promise(function(resolve, reject) {
        window.\(JAVASCRIPT_BRIDGE_NAME)[_callHandlerID] = resolve;
    });
}
"""

let platformReadyJS = "window.dispatchEvent(new Event('flutterInAppBrowserPlatformReady'));";

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

        window.webkit.messageHandlers["onFindResultReceived"].postMessage(
          JSON.stringify({
            activeMatchOrdinal: wkwebview_CurrentHighlight,
            numberOfMatches: wkwebview_SearchResultCount,
            isDoneCounting: wkwebview_IsDoneCounting
          })
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
  window.webkit.messageHandlers["onFindResultReceived"].postMessage(
    JSON.stringify({
      activeMatchOrdinal: wkwebview_CurrentHighlight,
      numberOfMatches: wkwebview_SearchResultCount,
      isDoneCounting: wkwebview_IsDoneCounting
    })
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

    window.webkit.messageHandlers["onFindResultReceived"].postMessage(
      JSON.stringify({
        activeMatchOrdinal: wkwebview_CurrentHighlight,
        numberOfMatches: wkwebview_SearchResultCount,
        isDoneCounting: wkwebview_IsDoneCounting
      })
    );
  }
}
"""

let variableForOnLoadResourceJS = "window._flutter_inappbrowser_useOnLoadResource"
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

let variableForShouldInterceptAjaxRequestJS = "window._flutter_inappbrowser_useShouldInterceptAjaxRequest"
let enableVariableForShouldInterceptAjaxRequestJS = "\(variableForShouldInterceptAjaxRequestJS) = $PLACEHOLDER_VALUE;"

let interceptAjaxRequestsJS = """
(function(ajax) {
  var send = ajax.prototype.send;
  var open = ajax.prototype.open;
  var setRequestHeader = ajax.prototype.setRequestHeader;
  ajax.prototype._flutter_inappbrowser_url = null;
  ajax.prototype._flutter_inappbrowser_method = null;
  ajax.prototype._flutter_inappbrowser_isAsync = null;
  ajax.prototype._flutter_inappbrowser_user = null;
  ajax.prototype._flutter_inappbrowser_password = null;
  ajax.prototype._flutter_inappbrowser_password = null;
  ajax.prototype._flutter_inappbrowser_already_onreadystatechange_wrapped = false;
  ajax.prototype._flutter_inappbrowser_request_headers = {};
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
    this._flutter_inappbrowser_url = url;
    this._flutter_inappbrowser_method = method;
    this._flutter_inappbrowser_isAsync = isAsync;
    this._flutter_inappbrowser_user = user;
    this._flutter_inappbrowser_password = password;
    this._flutter_inappbrowser_request_headers = {};
    open.call(this, method, url, isAsync, user, password);
  };
  ajax.prototype.setRequestHeader = function(header, value) {
    this._flutter_inappbrowser_request_headers[header] = value;
    setRequestHeader.call(this, header, value);
  };
  function handleEvent(e) {
    var self = this;
    if (window.\(variableForShouldInterceptAjaxRequestJS) == null || window.\(variableForShouldInterceptAjaxRequestJS) == true) {
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
          method: self._flutter_inappbrowser_method,
          url: self._flutter_inappbrowser_url,
          isAsync: self._flutter_inappbrowser_isAsync,
          user: self._flutter_inappbrowser_user,
          password: self._flutter_inappbrowser_password,
          withCredentials: self.withCredentials,
          headers: self._flutter_inappbrowser_request_headers,
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
    if (window.\(variableForShouldInterceptAjaxRequestJS) == null || window.\(variableForShouldInterceptAjaxRequestJS) == true) {
      if (!this._flutter_inappbrowser_already_onreadystatechange_wrapped) {
        this._flutter_inappbrowser_already_onreadystatechange_wrapped = true;
        var onreadystatechange = this.onreadystatechange;
        this.onreadystatechange = function() {
          if (window.\(variableForShouldInterceptAjaxRequestJS) == null || window.\(variableForShouldInterceptAjaxRequestJS) == true) {
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
                method: self._flutter_inappbrowser_method,
                url: self._flutter_inappbrowser_url,
                isAsync: self._flutter_inappbrowser_isAsync,
                user: self._flutter_inappbrowser_user,
                password: self._flutter_inappbrowser_password,
                withCredentials: self.withCredentials,
                headers: self._flutter_inappbrowser_request_headers,
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
        method: this._flutter_inappbrowser_method,
        url: this._flutter_inappbrowser_url,
        isAsync: this._flutter_inappbrowser_isAsync,
        user: this._flutter_inappbrowser_user,
        password: this._flutter_inappbrowser_password,
        withCredentials: this.withCredentials,
        headers: this._flutter_inappbrowser_request_headers,
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
            var flutter_inappbrowser_value = self._flutter_inappbrowser_request_headers[header];
            if (flutter_inappbrowser_value == null) {
              self._flutter_inappbrowser_request_headers[header] = value;
            } else {
              self._flutter_inappbrowser_request_headers[header] += ', ' + value;
            }
            setRequestHeader.call(self, header, value);
          };
          if ((self._flutter_inappbrowser_method != result.method && result.method != null) || (self._flutter_inappbrowser_url != result.url && result.url != null)) {
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

let variableForShouldInterceptFetchRequestsJS = "window._flutter_inappbrowser_useShouldInterceptFetchRequest"
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

let interceptNavigationStateChangeJS = """
(function(window, document, history) {
  history.pushState = (function(f) {
    return function pushState(){
      var ret = f.apply(this, arguments);
      window.dispatchEvent(new Event('pushstate'));
      window.dispatchEvent(new Event('_flutter_inappbrowser_locationchange'));
      return ret;
    };
  })(history.pushState);
  history.replaceState = ( function(f) {
    return function replaceState(){
      var ret = f.apply(this, arguments);
      window.dispatchEvent(new Event('replacestate'));
      window.dispatchEvent(new Event('_flutter_inappbrowser_locationchange'));
      return ret;
    };
  })(history.replaceState);
  window.addEventListener('popstate',function() {
    window.dispatchEvent(new Event('_flutter_inappbrowser_locationchange'));
  });
  window.addEventListener('_flutter_inappbrowser_locationchange', function() {
    window.webkit.messageHandlers["onNavigationStateChange"].postMessage(JSON.stringify({
      url: document.location.href
    }));
  });
})(window, window.document, window.history);
"""

public class InAppWebView: WKWebView, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    var IABController: InAppBrowserWebViewController?
    var IAWController: FlutterWebViewController?
    var options: InAppWebViewOptions?
    var currentURL: URL?
    var startPageTime: Int64 = 0
    static var credentialsProposed: [URLCredential] = []
    var lastScrollX: CGFloat = 0
    var lastScrollY: CGFloat = 0
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, IABController: InAppBrowserWebViewController?, IAWController: FlutterWebViewController?) {
        
        super.init(frame: frame, configuration: configuration)
        self.IABController = IABController
        self.IAWController = IAWController
        uiDelegate = self
        navigationDelegate = self
        scrollView.delegate = self
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public func prepare() {
        addObserver(self,
                    forKeyPath: #keyPath(WKWebView.estimatedProgress),
                    options: .new,
                    context: nil)
        
        configuration.userContentController = WKUserContentController()
        configuration.preferences = WKPreferences()
        
        if (options?.transparentBackground)! {
            isOpaque = false
            backgroundColor = UIColor.clear
            scrollView.backgroundColor = UIColor.clear
        }
        
        // prevent webView from bouncing
        if (options?.disallowOverScroll)! {
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
        
        if (options?.enableViewportScale)! {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            configuration.userContentController.addUserScript(userScript)
        }
        
        // Prevents long press on links that cause WKWebView exit
        let jscriptWebkitTouchCallout = WKUserScript(source: "document.body.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(jscriptWebkitTouchCallout)
        
        let consoleLogJSScript = WKUserScript(source: consoleLogJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(consoleLogJSScript)
        configuration.userContentController.add(self, name: "consoleLog")
        configuration.userContentController.add(self, name: "consoleDebug")
        configuration.userContentController.add(self, name: "consoleError")
        configuration.userContentController.add(self, name: "consoleInfo")
        configuration.userContentController.add(self, name: "consoleWarn")
        
        let javaScriptBridgeJSScript = WKUserScript(source: javaScriptBridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(javaScriptBridgeJSScript)
        configuration.userContentController.add(self, name: "callHandler")
        
        if (options?.useOnLoadResource)! {
            let resourceObserverJSScript = WKUserScript(source: resourceObserverJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(resourceObserverJSScript)
        }
        
        let findTextHighlightJSScript = WKUserScript(source: findTextHighlightJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(findTextHighlightJSScript)
        configuration.userContentController.add(self, name: "onFindResultReceived")
        
        let interceptNavigationStateChangeJSScript = WKUserScript(source: interceptNavigationStateChangeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(interceptNavigationStateChangeJSScript)
        configuration.userContentController.add(self, name: "onNavigationStateChange")
        
        
        if (options?.useShouldInterceptAjaxRequest)! {
            let interceptAjaxRequestsJSScript = WKUserScript(source: interceptAjaxRequestsJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(interceptAjaxRequestsJSScript)
        }
        
        if (options?.useShouldInterceptFetchRequest)! {
            let interceptFetchRequestsJSScript = WKUserScript(source: interceptFetchRequestsJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(interceptFetchRequestsJSScript)
        }
        
        if #available(iOS 9.0, *) {
            if ((options?.incognito)!) {
                configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            } else if ((options?.cacheEnabled)!) {
                configuration.websiteDataStore = WKWebsiteDataStore.default()
            }
        }
        
        if #available(iOS 11.0, *) {
            if((options?.sharedCookiesEnabled)!) {
                // More info to sending cookies with WKWebView
                // https://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303
                // Set Cookies in iOS 11 and above, initialize websiteDataStore before setting cookies
                // See also https://forums.developer.apple.com/thread/97194
                // check if websiteDataStore has not been initialized before
                if(!(options?.incognito)! && !(options?.cacheEnabled)!) {
                    configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                }
                for cookie in HTTPCookieStorage.shared.cookies ?? [] {
                    configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
                }
            }
        }
        
        configuration.suppressesIncrementalRendering = (options?.suppressesIncrementalRendering)!
        allowsBackForwardNavigationGestures = (options?.allowsBackForwardNavigationGestures)!
        if #available(iOS 9.0, *) {
            allowsLinkPreview = (options?.allowsLinkPreview)!
            configuration.allowsPictureInPictureMediaPlayback = (options?.allowsPictureInPictureMediaPlayback)!
            if (options?.applicationNameForUserAgent != nil && (options?.applicationNameForUserAgent)! != "") {
                configuration.applicationNameForUserAgent = (options?.applicationNameForUserAgent)!
            }
            if (options?.userAgent != nil && (options?.userAgent)! != "") {
                customUserAgent = (options?.userAgent)!
            }
        }
        
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = (options?.javaScriptCanOpenWindowsAutomatically)!
        configuration.preferences.javaScriptEnabled = (options?.javaScriptEnabled)!
        configuration.preferences.minimumFontSize = CGFloat((options?.minimumFontSize)!)
        configuration.selectionGranularity = WKSelectionGranularity.init(rawValue: (options?.selectionGranularity)!)!
        
        if #available(iOS 10.0, *) {
            configuration.ignoresViewportScaleLimits = (options?.ignoresViewportScaleLimits)!
            
            var dataDetectorTypes = WKDataDetectorTypes.init(rawValue: 0)
            for type in options?.dataDetectorTypes ?? [] {
                let dataDetectorType = getDataDetectorType(type: type)
                dataDetectorTypes = WKDataDetectorTypes(rawValue: dataDetectorTypes.rawValue | dataDetectorType.rawValue)
            }
            configuration.dataDetectorTypes = dataDetectorTypes
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 13.0, *) {
            configuration.preferences.isFraudulentWebsiteWarningEnabled = (options?.isFraudulentWebsiteWarningEnabled)!
            if options?.preferredContentMode != nil {
                configuration.defaultWebpagePreferences.preferredContentMode = WKWebpagePreferences.ContentMode(rawValue: (options?.preferredContentMode)!)!
            }
        } else {
            // Fallback on earlier versions
        }
        
        scrollView.showsVerticalScrollIndicator = (options?.verticalScrollBarEnabled)!
        scrollView.showsHorizontalScrollIndicator = (options?.horizontalScrollBarEnabled)!
        scrollView.showsVerticalScrollIndicator = !(options?.disableVerticalScroll)!
        scrollView.showsHorizontalScrollIndicator = !(options?.disableHorizontalScroll)!
        
        // options.debuggingEnabled is always enabled for iOS.
        
        if (options?.clearCache)! {
            clearCache()
        }
    }
    
    @available(iOS 10.0, *)
    public func getDataDetectorType(type: String) -> WKDataDetectorTypes {
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
    
    public static func preWKWebViewConfiguration(options: InAppWebViewOptions?) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        configuration.processPool = WKProcessPoolManager.sharedProcessPool
        
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = ((options?.mediaPlaybackRequiresUserGesture)!) ? .all : []
        } else {
            // Fallback on earlier versions
            configuration.mediaPlaybackRequiresUserAction = (options?.mediaPlaybackRequiresUserGesture)!
        }
        
        configuration.allowsInlineMediaPlayback = (options?.allowsInlineMediaPlayback)!
        
        if #available(iOS 11.0, *) {
            if let schemes = options?.resourceCustomSchemes {
                for scheme in schemes {
                    configuration.setURLSchemeHandler(CustomeSchemeHandler(), forURLScheme: scheme)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        return configuration
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            let progress = Int(estimatedProgress * 100)
            onProgressChanged(progress: progress)
        }
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
        }
        
        if newOptionsMap["enableViewportScale"] != nil && options?.enableViewportScale != newOptions.enableViewportScale && newOptions.enableViewportScale {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
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
        
        if newOptionsMap["allowsInlineMediaPlayback"] != nil && options?.allowsInlineMediaPlayback != newOptions.allowsInlineMediaPlayback {
            configuration.allowsInlineMediaPlayback = newOptions.allowsInlineMediaPlayback
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
                    let dataDetectorType = getDataDetectorType(type: type)
                    dataDetectorTypes = WKDataDetectorTypes(rawValue: dataDetectorTypes.rawValue | dataDetectorType.rawValue)
                }
                configuration.dataDetectorTypes = dataDetectorTypes
            }
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 13.0, *) {
            configuration.preferences.isFraudulentWebsiteWarningEnabled = (options?.isFraudulentWebsiteWarningEnabled)!
            configuration.defaultWebpagePreferences.preferredContentMode = WKWebpagePreferences.ContentMode(rawValue: (options?.preferredContentMode)!)!
        } else {
            // Fallback on earlier versions
        }
        
        if newOptionsMap["verticalScrollBarEnabled"] != nil && options?.verticalScrollBarEnabled != newOptions.verticalScrollBarEnabled {
            scrollView.showsVerticalScrollIndicator = newOptions.verticalScrollBarEnabled
        }
        if newOptionsMap["horizontalScrollBarEnabled"] != nil && options?.horizontalScrollBarEnabled != newOptions.horizontalScrollBarEnabled {
            scrollView.showsHorizontalScrollIndicator = newOptions.horizontalScrollBarEnabled
        }
        
        if newOptionsMap["disableVerticalScroll"] != nil && options?.disableVerticalScroll != newOptions.disableVerticalScroll {
            scrollView.showsVerticalScrollIndicator = !newOptions.disableVerticalScroll
        }
        if newOptionsMap["disableHorizontalScroll"] != nil && options?.disableHorizontalScroll != newOptions.disableHorizontalScroll {
            scrollView.showsHorizontalScrollIndicator = !newOptions.disableHorizontalScroll
        }
        
        if #available(iOS 9.0, *) {
            if newOptionsMap["allowsLinkPreview"] != nil && options?.allowsLinkPreview != newOptions.allowsLinkPreview {
                allowsLinkPreview = newOptions.allowsLinkPreview
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
    
    func getOptions() -> [String: Any]? {
        if (self.options == nil) {
            return nil
        }
        return self.options!.getHashMap()
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
                self.onConsoleMessage(message: userInfo["WKJavaScriptExceptionMessage"] as! String, messageLevel: 3)
            }
            
            if value == nil {
                result!("")
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
        
        let app = UIApplication.shared
        
        if let url = navigationAction.request.url {
            // Handle target="_blank"
            if navigationAction.targetFrame == nil && (options?.useOnTargetBlank)! {
                onTargetBlank(url: url)
                decisionHandler(.cancel)
                return
            }
            
            if navigationAction.navigationType == .linkActivated && (options?.useShouldOverrideUrlLoading)! {
                shouldOverrideUrlLoading(url: url)
                decisionHandler(.cancel)
                return
            }
            
            // Handle phone and email links
            if url.scheme == "tel" || url.scheme == "mailto" {
                if app.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        app.open(url)
                    } else {
                        app.openURL(url)
                    }
                }
                decisionHandler(.cancel)
                return
            }
            
            if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .backForward {
                currentURL = url
                if IABController != nil {
                    IABController!.updateUrlTextField(url: (currentURL?.absoluteString)!)
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.isForMainFrame, let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode >= 400 {
                onLoadHttpError(url: response.url!.absoluteString, statusCode: response.statusCode, description: "")
            }
        }
        
        if (options?.useOnDownloadStart)! {
            let mimeType = navigationResponse.response.mimeType
            if let url = navigationResponse.response.url {
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
        self.startPageTime = currentTimeInMilliSeconds()
        onLoadStart(url: (currentURL?.absoluteString)!)
        
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
        onLoadStop(url: (currentURL?.absoluteString)!)
        
        if IABController != nil {
            IABController!.updateUrlTextField(url: (currentURL?.absoluteString)!)
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
        
        onLoadError(url: (currentURL?.absoluteString)!, error: error)
        
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
                    print((result as! FlutterError).message)
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
                    print((result as! FlutterError).message)
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
                    print((result as! FlutterError).message)
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
                print(SecCopyErrorMessageString(securityError,nil))
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
        
        onJsAlert(message: message, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message)
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
        
        onJsConfirm(message: message, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message)
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
        onJsPrompt(message: message, defaultValue: defaultValue, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message)
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
    
    public func onLoadStart(url: String) {
        var arguments: [String: Any] = ["url": url]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadStart", arguments: arguments)
        }
    }
    
    public func onLoadStop(url: String) {
        var arguments: [String: Any] = ["url": url]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadStop", arguments: arguments)
        }
    }
    
    public func onLoadError(url: String, error: Error) {
        var arguments: [String: Any] = ["url": url, "code": error._code, "message": error.localizedDescription]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadError", arguments: arguments)
        }
    }
    
    public func onLoadHttpError(url: String, statusCode: Int, description: String) {
        var arguments: [String: Any] = ["url": url, "statusCode": statusCode, "description": description]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadHttpError", arguments: arguments)
        }
    }
    
    public func onProgressChanged(progress: Int) {
        var arguments: [String: Any] = ["progress": progress]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onProgressChanged", arguments: arguments)
        }
    }
    
    public func onFindResultReceived(activeMatchOrdinal: Int, numberOfMatches: Int, isDoneCounting: Bool) {
        var arguments: [String : Any] = [
            "activeMatchOrdinal": activeMatchOrdinal,
            "numberOfMatches": numberOfMatches,
            "isDoneCounting": isDoneCounting
        ]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onFindResultReceived", arguments: arguments)
        }
    }
    
    public func onNavigationStateChange(url: String) {
        var arguments: [String : Any] = [
            "url": url
        ]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onNavigationStateChange", arguments: arguments)
        }
    }
    
    public func onScrollChanged(x: Int, y: Int) {
        var arguments: [String: Any] = ["x": x, "y": y]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onScrollChanged", arguments: arguments)
        }
    }
    
    public func onDownloadStart(url: String) {
        var arguments: [String: Any] = ["url": url]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onDownloadStart", arguments: arguments)
        }
    }
    
    public func onLoadResourceCustomScheme(scheme: String, url: String, result: FlutterResult?) {
        var arguments: [String: Any] = ["scheme": scheme, "url": url]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadResourceCustomScheme", arguments: arguments, result: result)
        }
    }
    
    public func shouldOverrideUrlLoading(url: URL) {
        var arguments: [String: Any] = ["url": url.absoluteString]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("shouldOverrideUrlLoading", arguments: arguments)
        }
    }
    
    public func onTargetBlank(url: URL) {
        var arguments: [String: Any] = ["url": url.absoluteString]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onTargetBlank", arguments: arguments)
        }
    }
    
    public func onReceivedHttpAuthRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        var arguments: [String: Any?] = [
            "host": challenge.protectionSpace.host,
            "protocol": challenge.protectionSpace.protocol,
            "realm": challenge.protectionSpace.realm,
            "port": challenge.protectionSpace.port,
            "previousFailureCount": challenge.previousFailureCount
        ]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onReceivedHttpAuthRequest", arguments: arguments, result: result)
        }
    }
    
    public func onReceivedServerTrustAuthRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        var serverCertificateData: NSData?
        let serverTrust = challenge.protectionSpace.serverTrust!
        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let serverCertificateCFData = SecCertificateCopyData(serverCertificate)
            let data = CFDataGetBytePtr(serverCertificateCFData)
            let size = CFDataGetLength(serverCertificateCFData)
            serverCertificateData = NSData(bytes: data, length: size)
        }
        
        var arguments: [String: Any?] = [
            "host": challenge.protectionSpace.host,
            "protocol": challenge.protectionSpace.protocol,
            "realm": challenge.protectionSpace.realm,
            "port": challenge.protectionSpace.port,
            "previousFailureCount": challenge.previousFailureCount,
            "serverCertificate": serverCertificateData,
            "error": -1,
            "message": "",
        ]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onReceivedServerTrustAuthRequest", arguments: arguments, result: result)
        }
    }
    
    public func onReceivedClientCertRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        var arguments: [String: Any?] = [
            "host": challenge.protectionSpace.host,
            "protocol": challenge.protectionSpace.protocol,
            "realm": challenge.protectionSpace.realm,
            "port": challenge.protectionSpace.port
        ]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onReceivedClientCertRequest", arguments: arguments, result: result)
        }
    }
    
    public func onJsAlert(message: String, result: FlutterResult?) {
        var arguments: [String: Any] = ["message": message]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onJsAlert", arguments: arguments, result: result)
        }
    }
    
    public func onJsConfirm(message: String, result: FlutterResult?) {
        var arguments: [String: Any] = ["message": message]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onJsConfirm", arguments: arguments, result: result)
        }
    }
    
    public func onJsPrompt(message: String, defaultValue: String?, result: FlutterResult?) {
        var arguments: [String: Any] = ["message": message, "defaultValue": defaultValue as Any]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onJsPrompt", arguments: arguments, result: result)
        }
    }
    
    public func onConsoleMessage(message: String, messageLevel: Int) {
        var arguments: [String: Any] = ["message": message, "messageLevel": messageLevel]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onConsoleMessage", arguments: arguments)
        }
    }
    
    public func onCallJsHandler(handlerName: String, _callHandlerID: Int64, args: String) {
        var arguments: [String: Any] = ["handlerName": handlerName, "args": args]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        
        if let channel = getChannel() {
            channel.invokeMethod("onCallJsHandler", arguments: arguments, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message)
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {}
                else {
                    var json = "null"
                    if let r = result {
                        json = r as! String
                    }
                    self.evaluateJavaScript("if(window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)] != null) {window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)](\(json)); delete window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)];}", completionHandler: nil)
                }
            })
        }
    }
    
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
            onConsoleMessage(message: message.body as! String, messageLevel: messageLevel)
        }
        else if message.name == "callHandler" {
            let body = message.body as! [String: Any]
            let handlerName = body["handlerName"] as! String
            let _callHandlerID = body["_callHandlerID"] as! Int64
            let args = body["args"] as! String
            onCallJsHandler(handlerName: handlerName, _callHandlerID: _callHandlerID, args: args)
        } else if message.name == "onFindResultReceived" {
            if let resource = convertToDictionary(text: message.body as! String) {
                let activeMatchOrdinal = resource["activeMatchOrdinal"] as! Int
                let numberOfMatches = resource["numberOfMatches"] as! Int
                let isDoneCounting = resource["isDoneCounting"] as! Bool
                
                self.onFindResultReceived(activeMatchOrdinal: activeMatchOrdinal, numberOfMatches: numberOfMatches, isDoneCounting: isDoneCounting)
            }
        } else if message.name == "onNavigationStateChange" {
            if let resource = convertToDictionary(text: message.body as! String) {
                let url = resource["url"] as! String
                
                self.onNavigationStateChange(url: url)
            }
           
        }
    }
    
    private func getChannel() -> FlutterMethodChannel? {
        return (IABController != nil) ? SwiftFlutterPlugin.instance!.channel! : ((IAWController != nil) ? IAWController!.channel! : nil);
    }
    
    func findAllAsync(find: String?, completionHandler: ((Any?, Error?) -> Void)?) {
        let startSearch = "wkwebview_FindAllAsync('\(find ?? "")');"
        evaluateJavaScript(startSearch, completionHandler: completionHandler)
    }

    func findNext(forward: Bool, completionHandler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript("wkwebview_FindNext(\(forward ? "true" : "false"));", completionHandler: completionHandler)
    }

    func clearMatches(completionHandler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript("wkwebview_ClearMatches();", completionHandler: completionHandler)
    }
    
    func scrollTo(x: Int, y: Int) {
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    func scrollBy(x: Int, y: Int) {
        let newX = CGFloat(x) + scrollView.contentOffset.x
        let newY = CGFloat(y) + scrollView.contentOffset.y
        scrollView.setContentOffset(CGPoint(x: newX, y: newY), animated: false)
    }
    
    public override func removeFromSuperview() {
        configuration.userContentController.removeScriptMessageHandler(forName: "consoleLog")
        configuration.userContentController.removeScriptMessageHandler(forName: "consoleDebug")
        configuration.userContentController.removeScriptMessageHandler(forName: "consoleError")
        configuration.userContentController.removeScriptMessageHandler(forName: "consoleInfo")
        configuration.userContentController.removeScriptMessageHandler(forName: "consoleWarn")
        configuration.userContentController.removeScriptMessageHandler(forName: "callHandler")
        configuration.userContentController.removeScriptMessageHandler(forName: "onFindResultReceived")
        configuration.userContentController.removeScriptMessageHandler(forName: "onNavigationStateChange")
        configuration.userContentController.removeAllUserScripts()
        removeObserver(self, forKeyPath: "estimatedProgress")
        super.removeFromSuperview()
        uiDelegate = nil
        navigationDelegate = nil
        scrollView.delegate = nil
        IAWController?.channel?.setMethodCallHandler(nil)
        IABController?.webView = nil
        IAWController?.webView = nil
    }
}
