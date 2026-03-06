#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_

#include <memory>
#include <string>

#include "../types/plugin_script.h"
#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin
{

  class JavaScriptBridgeJS
  {
  public:
    static void set_JAVASCRIPT_BRIDGE_NAME(const std::string& bridgeName)
    {
      _JAVASCRIPT_BRIDGE_NAME = bridgeName;
    }

    static std::string get_JAVASCRIPT_BRIDGE_NAME()
    {
      return _JAVASCRIPT_BRIDGE_NAME;
    }

    inline static const std::string JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT";

    inline static const std::string VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET = "$IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_BRIDGE_SECRET";
    inline static const std::string BRIDGE_EVENTS_HANDLER_PREFIX = "__flutter_inappwebview_bridge_event__handler__:";
    inline static const std::string BRIDGE_EVENTS_DOM_EVENT_PREFIX = "__flutter_inappwebview_bridge_event__dispatch__:";

    static std::string BRIDGE_EVENTS_JS_SOURCE()
    {
      return "(function(window) { \
          var bridge = window." + get_JAVASCRIPT_BRIDGE_NAME() + "; \
          if (bridge == null || bridge.callHandler == null || bridge.bridgeEvents != null) { return; } \
          var handlerPrefix = '" + BRIDGE_EVENTS_HANDLER_PREFIX + "'; \
          var domEventPrefix = '" + BRIDGE_EVENTS_DOM_EVENT_PREFIX + "'; \
          var listeners = {}; \
          bridge.bridgeEvents = { \
            on: function(eventName, callback) { \
              var eventKey = domEventPrefix + String(eventName); \
              var handler = function(e) { callback(e.detail); }; \
              listeners[eventKey] = listeners[eventKey] || []; \
              listeners[eventKey].push({ callback: callback, handler: handler }); \
              window.addEventListener(eventKey, handler); \
            }, \
            off: function(eventName, callback) { \
              var eventKey = domEventPrefix + String(eventName); \
              var eventListeners = listeners[eventKey] || []; \
              for (var i = eventListeners.length - 1; i >= 0; i--) { \
                if (callback == null || eventListeners[i].callback === callback) { \
                  window.removeEventListener(eventKey, eventListeners[i].handler); \
                  eventListeners.splice(i, 1); \
                } \
              } \
              if (eventListeners.length === 0) { delete listeners[eventKey]; } \
            }, \
            emit: function(eventName, data) { \
              return bridge.callHandler(handlerPrefix + String(eventName), data); \
            } \
          }; \
        })(window);";
    }

    static std::string JAVASCRIPT_BRIDGE_JS_SOURCE()
    {
      return "window." + get_JAVASCRIPT_BRIDGE_NAME() + " = {}; \
        window." + get_JAVASCRIPT_BRIDGE_NAME() + "._webMessageChannels = {}; \
        (function(window) {\
          var bridgeSecret = '" + VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET + "';\
          var origin = '';\
          var requestUrl = '';\
          var isMainFrame = false;\
          var _JSON_stringify;\
          var _Array_slice;\
          var _setTimeout;\
          var _Promise;\
          var _postMessage;\
          try {\
            origin = window.location.origin;\
          } catch (_) {}\
          try {\
            requestUrl = window.location.href;\
          } catch (_) {}\
          try {\
            isMainFrame = window === window.top;\
          } catch (_) {}\
          try {\
            _JSON_stringify = window.JSON.stringify;\
            _Array_slice = window.Array.prototype.slice;\
            _Array_slice.call = window.Function.prototype.call;\
            _setTimeout = window.setTimeout;\
            _Promise = window.Promise;\
            _postMessage = window.chrome.webview.postMessage;\
          } catch (_) { return; }\
          window." + get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler = function() { \
            try {\
              requestUrl = window.location.href;\
            } catch (_) {}\
            var _callHandlerID = _setTimeout(function() {}); \
            _postMessage({ 'name': 'callHandler', 'body': {\
              'handlerName': arguments[0],\
              '_callHandlerID' : _callHandlerID,\
              '_bridgeSecret': bridgeSecret,\
              'origin': origin,\
              'requestUrl': requestUrl,\
              'args' : _JSON_stringify(_Array_slice.call(arguments, 1))}\
            });\
            return new _Promise(function(resolve, reject) { \
              try {\
                (isMainFrame ? window : window.top)." + get_JAVASCRIPT_BRIDGE_NAME() + "[_callHandlerID] = { resolve: resolve, reject : reject };\
              } catch(e) { resolve(); }\
            });\
          };\
        })(window);" + BRIDGE_EVENTS_JS_SOURCE();
    }

    static std::string PLATFORM_READY_JS_SOURCE()
    {
      return "(function() { \
         if ((window.top == null || window.top === window) && window." + get_JAVASCRIPT_BRIDGE_NAME() + " != null && window." + get_JAVASCRIPT_BRIDGE_NAME() + "._platformReady == null) { \
           window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady')); \
           window." + get_JAVASCRIPT_BRIDGE_NAME() + "._platformReady = true; \
         } \
       })();";
    }

    static std::unique_ptr<PluginScript> JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(const std::string& expectedBridgeSecret,
      const std::optional<std::vector<std::string>>& allowedOriginRules, const bool forMainFrameOnly)
    {
      auto source = replace_all_copy(JAVASCRIPT_BRIDGE_JS_SOURCE(), VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET, expectedBridgeSecret);
      return std::make_unique<PluginScript>(
        JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
        source,
        UserScriptInjectionTime::atDocumentStart,
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,
        true
      );
    }

  private:
    inline static std::string _JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview";
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_
