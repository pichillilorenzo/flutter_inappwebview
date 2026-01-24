#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CURSOR_DETECTION_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CURSOR_DETECTION_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for detecting cursor style changes in the WebView.
 *
 * This script monitors cursor style changes as the user moves the mouse,
 * and reports them to native code. WPE WebKit doesn't expose cursor information
 * directly like GTK does, so we use JavaScript to detect CSS cursor properties.
 */
class CursorDetectionJS {
 public:
  inline static const std::string CURSOR_DETECTION_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_CURSOR_DETECTION_JS_PLUGIN_SCRIPT";

  /**
   * JavaScript source code for cursor detection.
   * 
   * The script detects the effective cursor style by:
   * 1. First checking the computed CSS cursor value
   * 2. If "auto", analyzing the element to determine appropriate cursor:
   *    - Links (<a> with href) -> pointer
   *    - Editable elements (input, textarea, contenteditable) -> text
   *    - Buttons and controls -> pointer
   *    - Images with onclick/links -> pointer
   * 3. Check if the mouse is over a text node's bounding boxes to show text cursor only when
   *    actually over text characters.
   */
  static std::string CURSOR_DETECTION_JS_SOURCE() {
    return R"JS(
(function() {
  if (window._flutterCursorDetectorInstalled) return;
  window._flutterCursorDetectorInstalled = true;
  
  var lastCursor = '';
  
  // Helper to check if element is editable
  function isEditable(el) {
    if (!el) return false;
    var tagName = el.tagName ? el.tagName.toLowerCase() : '';
    
    // Input fields (except hidden, button types, etc.)
    if (tagName === 'input') {
      var type = (el.type || 'text').toLowerCase();
      // These input types should show text cursor
      var textTypes = ['text', 'password', 'email', 'number', 'search', 
                       'tel', 'url', 'date', 'datetime-local', 'month', 
                       'week', 'time'];
      return textTypes.indexOf(type) !== -1;
    }
    
    // Textarea
    if (tagName === 'textarea') return true;
    
    // Contenteditable
    if (el.isContentEditable) return true;
    
    return false;
  }
  
  // Helper to check if element is a clickable control
  function isClickable(el) {
    if (!el) return false;
    var tagName = el.tagName ? el.tagName.toLowerCase() : '';
    
    // Links with href
    if (tagName === 'a' && el.hasAttribute('href')) return true;
    
    // Buttons
    if (tagName === 'button') return true;
    
    // Input buttons/submits
    if (tagName === 'input') {
      var type = (el.type || 'text').toLowerCase();
      if (['button', 'submit', 'reset', 'image', 'file', 'checkbox', 'radio'].indexOf(type) !== -1) {
        return true;
      }
    }
    
    // Select dropdowns
    if (tagName === 'select') return true;
    
    // Labels (clickable for form controls)
    if (tagName === 'label') return true;
    
    // Summary in details element
    if (tagName === 'summary') return true;
    
    // Elements with onclick handler or role="button"
    if (el.onclick || el.getAttribute('role') === 'button' ||
        el.getAttribute('role') === 'link' ||
        el.getAttribute('role') === 'menuitem' ||
        el.getAttribute('role') === 'tab') {
      return true;
    }
    
    // Check for click event listeners via data attribute (common pattern)
    if (el.dataset && (el.dataset.click || el.dataset.action)) return true;
    
    return false;
  }
  
  // Determine effective cursor for "auto" mode
  function getEffectiveCursor(el, computedCursor, mouseX, mouseY) {
    // If cursor is explicitly set (not auto/default), use it
    if (computedCursor && computedCursor !== 'auto' && computedCursor !== 'default') {
      return computedCursor;
    }
    
    if (!el) return 'default';
    
    // Check element and ancestors for context
    var current = el;
    var maxDepth = 10; // Prevent infinite loops
    var depth = 0;
    
    while (current && current !== document.body && depth < maxDepth) {
      // Check if this element provides cursor context
      if (isEditable(current)) {
        return 'text';
      }
      
      if (isClickable(current)) {
        return 'pointer';
      }
      
      current = current.parentElement;
      depth++;
    }
    
    // Use precise hit-testing to check if mouse is actually over text characters
    // This avoids showing text cursor in padding/margin areas
    if (isOverActualText(mouseX, mouseY)) {
      // Double-check we're not in a clickable context
      if (!isClickable(el) && !isClickableAncestor(el)) {
        return 'text';
      }
    }
    
    return 'default';
  }
  
  // Check if any ancestor is clickable (to avoid text cursor on buttons with text)
  function isClickableAncestor(el) {
    var current = el.parentElement;
    var maxDepth = 5;
    var depth = 0;
    
    while (current && current !== document.body && depth < maxDepth) {
      if (isClickable(current)) return true;
      current = current.parentElement;
      depth++;
    }
    return false;
  }
  
  // Check if mouse coordinates are actually over text characters
  // https://stackoverflow.com/questions/10389459/is-there-a-way-to-detect-if-im-hovering-over-text
  function isOverActualText(x, y) {
    const element = document.elementFromPoint(x, y);
    if (element == null) return false;
    const nodes = element.childNodes;
    for (let i = 0, node; (node = nodes[i++]); ) {
      if (node.nodeType === 3) {
        const range = document.createRange();
        range.selectNode(node);
        const rects = range.getClientRects();
        for (let j = 0, rect; (rect = rects[j++]); ) {
          if (
              x > rect.left &&
              x < rect.right &&
              y > rect.top &&
              y < rect.bottom
            ) {
            if (node.nodeType === Node.TEXT_NODE) return true;
          }
        }
      }
    }
    return false;
  }
  
  // Report cursor change to native
  function reportCursor(cursor) {
    if (cursor !== lastCursor) {
      lastCursor = cursor;
      try {
        if (window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           R"JS( && window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           R"JS(.callHandler) {
          window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           R"JS(.callHandler('_cursorChanged', cursor);
        }
      } catch(_) {}
    }
  }
  
  // Handle mouse movement
  function handleMouseMove(e) {
    var el = document.elementFromPoint(e.clientX, e.clientY);
    if (!el) {
      reportCursor('default');
      return;
    }
    
    // Get computed cursor style
    var computedCursor = '';
    try {
      computedCursor = window.getComputedStyle(el).cursor;
    } catch(_) {}
    
    // Determine effective cursor (pass mouse coordinates for precise text detection)
    var effectiveCursor = getEffectiveCursor(el, computedCursor, e.clientX, e.clientY);
    reportCursor(effectiveCursor);
  }
  
  // Use both mousemove and mouseover for comprehensive coverage
  document.addEventListener('mousemove', handleMouseMove, { passive: true });
  
  // Also handle mouseout to reset cursor when leaving elements
  document.addEventListener('mouseout', function(e) {
    if (e.relatedTarget === null) {
      // Mouse left the document
      reportCursor('default');
    }
  }, { passive: true });
  
})();
)JS";
  }

  /**
   * Creates a PluginScript for cursor detection.
   *
   * This plugin runs in the main frame only to avoid performance overhead
   * from multiple iframe instances.
   */
  static std::unique_ptr<PluginScript> CURSOR_DETECTION_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly = true) {
    return std::make_unique<PluginScript>(
        CURSOR_DETECTION_JS_PLUGIN_SCRIPT_GROUP_NAME, 
        CURSOR_DETECTION_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentEnd,  // Inject after DOM is ready
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,                    // contentWorld
        true,                       // requiredInAllContentWorlds
        std::vector<std::string>{}  // no additional message handlers needed
    );
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CURSOR_DETECTION_JS_H_
