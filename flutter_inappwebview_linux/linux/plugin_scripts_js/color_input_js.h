#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_COLOR_INPUT_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_COLOR_INPUT_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for intercepting color input elements.
 *
 * WPE WebKit doesn't have built-in color picker support like WebKitGTK,
 * so we intercept clicks on <input type="color"> elements and handle them
 * natively via the JavaScript bridge.
 */
class ColorInputJS {
 public:
  inline static const std::string COLOR_INPUT_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_COLOR_INPUT_JS_PLUGIN_SCRIPT";

  /**
   * JavaScript source code for color input interception.
   * This code intercepts clicks on color inputs and calls the native handler.
   * Supports the 'list' attribute for predefined color swatches.
   */
  static std::string COLOR_INPUT_JS_SOURCE() {
    return R"JS(
(function() {
  // Avoid re-registering
  if (window._flutterInAppWebViewColorInputInit) return;
  window._flutterInAppWebViewColorInputInit = true;

  // Store references to active color inputs
  var activeColorInput = null;
  var activeElementRect = null;

  // Function to get element's absolute position
  function getElementRect(element) {
    var rect = element.getBoundingClientRect();
    return {
      x: Math.round(rect.left + window.scrollX),
      y: Math.round(rect.top + window.scrollY),
      width: Math.round(rect.width),
      height: Math.round(rect.height)
    };
  }

  // Function to get predefined colors from datalist (list attribute)
  function getPredefinedColors(input) {
    var colors = [];
    var listId = input.getAttribute('list');
    if (listId) {
      var datalist = document.getElementById(listId);
      if (datalist) {
        var options = datalist.querySelectorAll('option');
        for (var i = 0; i < options.length; i++) {
          var color = options[i].value || options[i].textContent;
          if (color && /^#[0-9A-Fa-f]{6}$/.test(color)) {
            colors.push(color.toUpperCase());
          }
        }
      }
    }
    return colors;
  }

  // Handle color input click
  function handleColorInputClick(event) {
    var input = event.target;
    if (input.tagName !== 'INPUT' || input.attributes.type.value !== 'color') return;
    
    // Prevent default browser behavior (which doesn't work in WPE anyway)
    event.preventDefault();
    event.stopPropagation();

    // Store reference to the active input
    activeColorInput = input;
    activeElementRect = getElementRect(input);

    // Get current color value (default is #000000)
    var currentColor = input.value || '#000000';

    // Get predefined colors from list attribute
    var predefinedColors = getPredefinedColors(input);

    // Detect alpha attribute (HTML boolean attribute)
    var alphaEnabled = input.hasAttribute('alpha');

    // Detect colorspace attribute (limited-srgb or display-p3)
    var colorSpace = input.getAttribute('colorspace') || 'limited-srgb';

    // Call native handler
    try {
      window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           R"JS(.callHandler('_onColorInputClicked', {
        color: currentColor,
        rect: activeElementRect,
        predefinedColors: predefinedColors,
        alpha: alphaEnabled,
        colorSpace: colorSpace
      });
    } catch(_) {}
  }

  // Function to set color value from native
  window._flutterInAppWebViewSetColorInputValue = function(color) {
    if (activeColorInput) {
      activeColorInput.value = color;
      
      // Dispatch input and change events to notify the page
      activeColorInput.dispatchEvent(new Event('input', { bubbles: true }));
      activeColorInput.dispatchEvent(new Event('change', { bubbles: true }));
      
      activeColorInput = null;
      activeElementRect = null;
    }
  };

  // Function to cancel color selection from native
  window._flutterInAppWebViewCancelColorInput = function() {
    activeColorInput = null;
    activeElementRect = null;
  };

  // Listen for clicks on color inputs using event delegation
  document.addEventListener('click', function(event) {
    var target = event.target;
    if (target.tagName === 'INPUT' && target.attributes && target.attributes.type && target.attributes.type.value === 'color') {
      handleColorInputClick(event);
    }
  }, true); // Use capture phase to intercept before bubbling

  // Also intercept on mousedown to prevent focus issues
  document.addEventListener('mousedown', function(event) {
    var target = event.target;
    if (target.tagName === 'INPUT' && target.attributes && target.attributes.type && target.attributes.type.value === 'color') {
      event.preventDefault();
    }
  }, true);

  // Handle dynamically created color inputs via MutationObserver
  // This ensures color inputs added after page load are also handled
  var observer = new MutationObserver(function(mutations) {
    // No specific action needed - click delegation handles new elements
  });

  observer.observe(document.body || document.documentElement, {
    childList: true,
    subtree: true
  });
})();
)JS";
  }

  /**
   * Creates a PluginScript for color input interception.
   */
  static std::unique_ptr<PluginScript> COLOR_INPUT_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_unique<PluginScript>(
        COLOR_INPUT_JS_PLUGIN_SCRIPT_GROUP_NAME, COLOR_INPUT_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentEnd,  // Inject after DOM is ready
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,                                 // contentWorld
        false,                                   // requiredInAllContentWorlds
        std::vector<std::string>{}               // messageHandlerNames - uses existing bridge
    );
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_COLOR_INPUT_JS_H_
