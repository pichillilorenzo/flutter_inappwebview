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

    static std::string JAVASCRIPT_BRIDGE_JS_SOURCE()
    {
      return "window." + get_JAVASCRIPT_BRIDGE_NAME() + " = {}; \
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
        })(window);";
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