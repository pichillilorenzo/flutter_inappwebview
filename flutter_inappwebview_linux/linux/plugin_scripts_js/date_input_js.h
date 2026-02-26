#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DATE_INPUT_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DATE_INPUT_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for intercepting date/time input elements.
 *
 * WPE WebKit doesn't have built-in date picker support,
 * so we intercept clicks on date-related input elements and handle them
 * natively via the JavaScript bridge.
 *
 * Supported input types:
 * - date: Full date (YYYY-MM-DD)
 * - datetime-local: Date and time (YYYY-MM-DDTHH:MM)
 * - time: Time only (HH:MM)
 * - month: Year and month (YYYY-MM)
 * - week: Year and week (YYYY-Www)
 */
class DateInputJS {
 public:
  inline static const std::string DATE_INPUT_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_DATE_INPUT_JS_PLUGIN_SCRIPT";

  /**
   * JavaScript source code for date input interception.
   * 
   * This script:
   * 1. Injects CSS to ensure the calendar picker icon is visible and styled
   * 2. Only intercepts clicks on the calendar icon (not the text field)
   * 3. Allows users to type directly in the input field
   * 4. Passes screen coordinates for proper popup positioning
   */
  static std::string DATE_INPUT_JS_SOURCE() {
    return R"JS(
(function() {
  // Avoid re-registering
  if (window._flutterInAppWebViewDateInputInit) return;
  window._flutterInAppWebViewDateInputInit = true;

  // Supported date input types
  var DATE_INPUT_TYPES = ['date', 'datetime-local', 'time', 'month', 'week'];

  // Icon mapping for different input types
  var ICON_MAP = {
    'date': '📅',
    'datetime-local': '📅',
    'month': '📅',
    'week': '📅',
    'time': '🕐'
  };

  // Inject CSS to style the date/time inputs with a visible picker icon
  // WebKit uses ::-webkit-calendar-picker-indicator for the icon
  var style = document.createElement('style');
  style.textContent = [
    // Ensure the picker indicator is visible and clickable
    'input[type="date"]::-webkit-calendar-picker-indicator,',
    'input[type="datetime-local"]::-webkit-calendar-picker-indicator,',
    'input[type="time"]::-webkit-calendar-picker-indicator,',
    'input[type="month"]::-webkit-calendar-picker-indicator,',
    'input[type="week"]::-webkit-calendar-picker-indicator {',
    '  cursor: pointer;',
    '  opacity: 1;',
    '  display: block;',
    '  width: 20px;',
    '  height: 20px;',
    '  background: transparent;',
    '  position: relative;',
    '}',
    // Style for our custom icon overlay
    '._flutter_date_picker_icon {',
    '  position: absolute;',
    '  right: 4px;',
    '  top: 50%;',
    '  transform: translateY(-50%);',
    '  cursor: pointer;',
    '  font-size: 16px;',
    '  user-select: none;',
    '  pointer-events: auto;',
    '  z-index: 1;',
    '  padding: 2px 4px;',
    '  opacity: 0.7;',
    '  transition: opacity 0.15s;',
    '}',
    '._flutter_date_picker_icon:hover {',
    '  opacity: 1;',
    '}',
    '._flutter_date_input_wrapper {',
    '  position: relative;',
    '  display: inline-block;',
    '}',
    '._flutter_date_input_wrapped {',
    '  padding-right: 28px !important;',
    '}'
  ].join('\n');
  (document.head || document.documentElement).appendChild(style);

  // Track wrapped inputs to avoid double-wrapping
  var wrappedInputs = new WeakSet();

  // Wrap a date input with our custom icon
  function wrapDateInput(input) {
    if (wrappedInputs.has(input)) return;
    if (input.disabled || input.readOnly) return;
    
    var inputType = input.attributes.type ? input.attributes.type.value : input.type;
    if (DATE_INPUT_TYPES.indexOf(inputType) === -1) return;

    wrappedInputs.add(input);

    // Create wrapper if input is not already wrapped
    var parent = input.parentNode;
    if (!parent || parent.classList.contains('_flutter_date_input_wrapper')) return;

    // Create wrapper
    var wrapper = document.createElement('span');
    wrapper.className = '_flutter_date_input_wrapper';
    wrapper.style.display = getComputedStyle(input).display === 'block' ? 'block' : 'inline-block';
    
    // Insert wrapper and move input inside
    parent.insertBefore(wrapper, input);
    wrapper.appendChild(input);
    
    // Add padding to input for icon space
    input.classList.add('_flutter_date_input_wrapped');

    // Create icon
    var icon = document.createElement('span');
    icon.className = '_flutter_date_picker_icon';
    icon.textContent = ICON_MAP[inputType] || '📅';
    icon.setAttribute('role', 'button');
    icon.setAttribute('aria-label', 'Open ' + inputType + ' picker');
    wrapper.appendChild(icon);

    // Handle icon click
    icon.addEventListener('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      openDatePicker(input, event);
    }, true);

    // Prevent default on the webkit picker indicator clicks
    input.addEventListener('click', function(event) {
      var rect = input.getBoundingClientRect();
      var clickX = event.clientX;
      // If clicking in the rightmost 30px (icon area), open our picker
      if (clickX > rect.right - 30) {
        event.preventDefault();
        event.stopPropagation();
        openDatePicker(input, event);
      }
      // Otherwise let the user type in the field
    }, true);
  }

  // Function to get element's absolute position (relative to viewport and page)
  function getElementRect(element) {
    var rect = element.getBoundingClientRect();
    return {
      // Position relative to page (with scroll)
      x: Math.round(rect.left + window.scrollX),
      y: Math.round(rect.top + window.scrollY),
      width: Math.round(rect.width),
      height: Math.round(rect.height),
      // Position relative to viewport (without scroll) - for dialog positioning
      viewportX: Math.round(rect.left),
      viewportY: Math.round(rect.bottom + 2),  // Position just below the input
      viewportBottom: Math.round(rect.bottom)
    };
  }

  // Open date picker for an input
  function openDatePicker(input, event) {
    if (input.disabled || input.readOnly) return;
    
    var inputType = input.attributes.type ? input.attributes.type.value : input.type;
    if (DATE_INPUT_TYPES.indexOf(inputType) === -1) return;

    // Get current value
    var currentValue = input.value || '';

    // Get min/max constraints
    var minValue = input.min || '';
    var maxValue = input.max || '';

    // Get step attribute (for time inputs)
    var step = input.step || '';

    // Get element rect with screen coordinates
    var elemRect = getElementRect(input);

    // Use the unified callHandler API through the JavaScript bridge
    // This uses the with_reply API which works correctly for iframes
    try {
      window.)JS" + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + R"JS(.callHandler('_onDateInputClicked', {
        inputType: inputType,
        currentValue: currentValue,
        minValue: minValue,
        maxValue: maxValue,
        step: step,
        elemRect: elemRect
      }).then(function(result) {
        // Check if the result is a valid value (non-null, non-undefined)
        if (result != null && result !== undefined) {
          input.value = result;
          // Dispatch input and change events to notify the page
          input.dispatchEvent(new Event('input', { bubbles: true }));
          input.dispatchEvent(new Event('change', { bubbles: true }));
        }
        // If result is null/undefined, user cancelled - do nothing
      }).catch(function(e) {
        console.error('Date picker error:', e);
      });
    } catch(e) {
      console.error('Failed to open date picker:', e);
    }
  }

  // Process existing date inputs on page load
  function processExistingInputs() {
    DATE_INPUT_TYPES.forEach(function(type) {
      document.querySelectorAll('input[type="' + type + '"]').forEach(wrapDateInput);
    });
  }

  // Observe for new date inputs added dynamically
  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.nodeType === Node.ELEMENT_NODE) {
          if (node.tagName === 'INPUT') {
            wrapDateInput(node);
          } else if (node.querySelectorAll) {
            DATE_INPUT_TYPES.forEach(function(type) {
              node.querySelectorAll('input[type="' + type + '"]').forEach(wrapDateInput);
            });
          }
        }
      });
    });
  });

  // Start observing when DOM is ready
  if (document.body) {
    processExistingInputs();
    observer.observe(document.body, { childList: true, subtree: true });
  } else {
    document.addEventListener('DOMContentLoaded', function() {
      processExistingInputs();
      observer.observe(document.body, { childList: true, subtree: true });
    });
  }
})();
)JS";
  }

  /**
   * Creates a PluginScript for date input interception.
   */
  static std::unique_ptr<PluginScript> DATE_INPUT_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_unique<PluginScript>(
        DATE_INPUT_JS_PLUGIN_SCRIPT_GROUP_NAME, DATE_INPUT_JS_SOURCE(),
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

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_DATE_INPUT_JS_H_
