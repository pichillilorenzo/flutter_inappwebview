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
 *
 * This implementation uses Firefox/Chrome-style behavior:
 * - No DOM modifications (no wrapper elements or icon overlays)
 * - The entire color input is clickable (like native browsers)
 * - Uses document-level event delegation for efficient handling
 * - Supports keyboard navigation (Enter/Space)
 * - Works with dynamically added inputs automatically
 */
class ColorInputJS {
 public:
  inline static const std::string COLOR_INPUT_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_COLOR_INPUT_JS_PLUGIN_SCRIPT";

  /**
   * JavaScript source code for color input interception.
   * This code intercepts clicks on color inputs and calls the native handler.
   * Supports the 'list' attribute for predefined color swatches.
   * 
   * This script uses Firefox/Chrome-style behavior:
   * 1. Injects minimal CSS (cursor:pointer, disabled styling only)
   * 2. Uses document-level event delegation to intercept all color input clicks
   * 3. Intercepts the ENTIRE color input element (not just an icon area)
   * 4. Prevents default browser behavior and opens native GTK color picker
   * 5. Supports keyboard accessibility (Enter/Space keys)
   * 6. No DOM modifications - keeps the native color swatch appearance
   */
  static std::string COLOR_INPUT_JS_SOURCE() {
    return R"JS(
(function() {
  // Avoid re-registering
  if (window._flutterInAppWebViewColorInputInit) return;
  window._flutterInAppWebViewColorInputInit = true;

  // CSS to style color inputs like Firefox/Chrome (colored box, not text input)
  // WPE WebKit renders color inputs as text fields, so we need to style them properly
  var style = document.createElement('style');
  style.textContent = [
    'input[type="color"] {',
    '  -webkit-appearance: none;',
    '  appearance: none;',
    '  width: 44px;',
    '  height: 28px;',
    '  padding: 2px;',
    '  border: 1px solid #767676;',
    '  border-radius: 4px;',
    '  cursor: pointer;',
    '  background-color: transparent;',
    '}',
    'input[type="color"]::-webkit-color-swatch-wrapper {',
    '  padding: 0;',
    '}',
    'input[type="color"]::-webkit-color-swatch {',
    '  border: none;',
    '  border-radius: 2px;',
    '}',
    'input[type="color"]:disabled {',
    '  cursor: not-allowed;',
    '  opacity: 0.5;',
    '}',
    'input[type="color"]:focus {',
    '  outline: 2px solid #4A90D9;',
    '  outline-offset: 1px;',
    '}'
  ].join('\n');
  (document.head || document.documentElement).appendChild(style);

  // Calculate relative luminance of a color (0-1, where 0 is darkest, 1 is lightest)
  function getLuminance(hexColor) {
    var hex = hexColor.replace('#', '');
    if (hex.length === 3) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    var r = parseInt(hex.substr(0, 2), 16) / 255;
    var g = parseInt(hex.substr(2, 2), 16) / 255;
    var b = parseInt(hex.substr(4, 2), 16) / 255;
    // sRGB luminance formula
    r = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
    g = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
    b = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  // Function to apply color as background with contrasting text color
  function applyColorBackground(input) {
    if (input.attributes.type && input.attributes.type.value === 'color') {
      var color = input.value || '#000000';
      input.style.backgroundColor = color;
      // Set text color based on luminance for maximum contrast
      var luminance = getLuminance(color);
      input.style.color = luminance > 0.5 ? '#000000' : '#FFFFFF';
    }
  }

  // Update color background when value changes
  document.addEventListener('input', function(event) {
    if (event.target.tagName === 'INPUT' && event.target.attributes.type && event.target.attributes.type.value === 'color') {
      applyColorBackground(event.target);
    }
  }, true);

  // Apply to existing color inputs
  document.querySelectorAll('input[type="color"]').forEach(applyColorBackground);

  // Also apply when new color inputs are added
  var colorObserver = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.nodeType === Node.ELEMENT_NODE) {
          if (node.tagName === 'INPUT' && node.attributes.type && node.attributes.type.value === 'color') {
            applyColorBackground(node);
          } else if (node.querySelectorAll) {
            node.querySelectorAll('input[type="color"]').forEach(applyColorBackground);
          }
        }
      });
    });
  });
  if (document.body) {
    colorObserver.observe(document.body, { childList: true, subtree: true });
  } else {
    document.addEventListener('DOMContentLoaded', function() {
      document.querySelectorAll('input[type="color"]').forEach(applyColorBackground);
      colorObserver.observe(document.body, { childList: true, subtree: true });
    });
  }

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

  // Open color picker for an input
  function openColorPicker(input) {
    // Get element rect for positioning
    var elemRect = getElementRect(input);

    // Get current color value (default is #000000)
    var currentColor = input.value || '#000000';

    // Get predefined colors from list attribute
    var predefinedColors = getPredefinedColors(input);

    // Detect alpha attribute (HTML boolean attribute)
    var alphaEnabled = input.hasAttribute('alpha');

    // Detect colorspace attribute (limited-srgb or display-p3)
    var colorSpace = input.getAttribute('colorspace') || 'limited-srgb';

    // Use the unified callHandler API through the JavaScript bridge
    try {
      window.)JS" + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + R"JS(.callHandler('_onColorInputClicked', {
        currentColor: currentColor,
        elemRect: elemRect,
        predefinedColors: predefinedColors,
        alphaEnabled: alphaEnabled,
        colorSpace: colorSpace
      }).then(function(result) {
        // Check if the result is a valid color (non-null, non-undefined)
        if (result != null && result !== undefined) {
          input.value = result;
          // Update the background color and text color for contrast
          input.style.backgroundColor = result;
          var luminance = getLuminance(result);
          input.style.color = luminance > 0.5 ? '#000000' : '#FFFFFF';
          // Dispatch input and change events to notify the page
          input.dispatchEvent(new Event('input', { bubbles: true }));
          input.dispatchEvent(new Event('change', { bubbles: true }));
        }
        // If result is null/undefined, user cancelled - do nothing
      }).catch(function(e) {
        console.error('Color picker error:', e);
      });
    } catch(e) {
      console.error('Failed to open color picker:', e);
    }
  }

  // Intercept ALL clicks on color inputs using event delegation
  // Use capture phase to intercept before the browser's default handler
  document.addEventListener('click', function(event) {
    var target = event.target;

    // Check if this is a color input
    if (target.tagName === 'INPUT' && target.attributes.type && target.attributes.type.value === 'color') {
      // Skip if disabled
      if (target.disabled) return;

      // Prevent default browser behavior (WPE's basic color UI)
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();

      // Open our native color picker
      openColorPicker(target);
    }
  }, true); // true = capture phase

  // Also intercept mousedown to prevent any focus/selection issues
  document.addEventListener('mousedown', function(event) {
    var target = event.target;
    if (target.tagName === 'INPUT' && target.attributes.type && target.attributes.type.value === 'color' && !target.disabled) {
      event.preventDefault();
    }
  }, true);

  // Intercept Enter/Space key on focused color inputs for keyboard accessibility
  document.addEventListener('keydown', function(event) {
    var target = event.target;
    if (target.tagName === 'INPUT' && target.attributes.type && target.attributes.type.value === 'color' && !target.disabled) {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        event.stopPropagation();
        openColorPicker(target);
      }
    }
  }, true);
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
