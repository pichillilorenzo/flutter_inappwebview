//
//  FindTextHighlightJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class FindTextHighlightJS {
    public static let FIND_TEXT_HIGHLIGHT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_FIND_TEXT_HIGHLIGHT_JS_PLUGIN_SCRIPT"
    public static func FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE() -> String {
        return "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._searchResultCount"
    }
    public static func FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE() -> String {
        return "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._currentHighlight"
    }
    public static func FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE() -> String {
        return "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._isDoneCounting"
    }
    
    // This plugin is only for main frame
    public static func FIND_TEXT_HIGHLIGHT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: FIND_TEXT_HIGHLIGHT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: FIND_TEXT_HIGHLIGHT_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func FIND_TEXT_HIGHLIGHT_JS_SOURCE() -> String {
        return """
        \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()) = 0;
        \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()) = 0;
        \(FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE()) = false;
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findAllAsyncForElement = function(element, keyword) {
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
                  "\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_SEARCH_WORD_" + \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE())
                );
                span.setAttribute("class", "\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_Highlight");
                var backgroundColor = \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()) == 0 ? "#FF9732" : "#FFFF00";
                span.setAttribute("style", "color: #000 !important; background: " + backgroundColor + " !important; padding: 0px !important; margin: 0px !important; border: 0px !important;");
        
                text = document.createTextNode(value.substr(idx + keyword.length));
                element.deleteData(idx, value.length - idx);
        
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
        
                \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE())++;
                elementTmp = document.createTextNode(
                  value.substr(idx + keyword.length)
                );
                
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onFindResultReceived', {
                    'findResult': {
                        'activeMatchOrdinal': \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()),
                        'numberOfMatches': \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()),
                        'isDoneCounting': \(FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE())
                    }
                });
              }
            } else if (element.nodeType == 1) {
              // Element node
              if (
                element.style.display != "none" &&
                element.nodeName.toLowerCase() != "select"
              ) {
                for (var i = element.childNodes.length - 1; i >= 0; i--) {
                  window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findAllAsyncForElement(
                    element.childNodes[element.childNodes.length - 1 - i],
                    keyword
                  );
                }
              }
            }
          }
        }
        
        // the main entry point to start the search
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findAllAsync = function(keyword) {
          window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._clearMatches();
          window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findAllAsyncForElement(document.body, keyword.toLowerCase());
          \(FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE()) = true;
        
          window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onFindResultReceived', {
              'findResult': {
                  'activeMatchOrdinal': \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()),
                  'numberOfMatches': \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()),
                  'isDoneCounting': \(FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE())
              }
          });
        }
        
        // helper function, recursively removes the highlights in elements and their children
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._clearMatchesForElement = function(element) {
          if (element) {
            if (element.nodeType == 1) {
              if (element.getAttribute("class") == "\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_Highlight") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text, element);
                element.parentNode.removeChild(element);
                return true;
              } else {
                var normalize = false;
                for (var i = element.childNodes.length - 1; i >= 0; i--) {
                  if (window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._clearMatchesForElement(element.childNodes[i])) {
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
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._clearMatches = function() {
          \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()) = 0;
          \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()) = 0;
          \(FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE()) = false;
          window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._clearMatchesForElement(document.body);
        }
        
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findNext = function(forward) {
          if (\(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()) <= 0) return;
        
          var idx = \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()) + (forward ? +1 : -1);
          idx =
            idx < 0
              ? \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()) - 1
              : idx >= \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE())
              ? 0
              : idx;
          \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()) = idx;
        
          var scrollTo = document.getElementById("\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_SEARCH_WORD_" + idx);
          if (scrollTo) {
            var highlights = document.getElementsByClassName("\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_Highlight");
            for (var i = 0; i < highlights.length; i++) {
              var span = highlights[i];
              span.style.backgroundColor = "#FFFF00";
            }
            scrollTo.style.backgroundColor = "#FF9732";
        
            scrollTo.scrollIntoView({
              behavior: "auto",
              block: "center"
            });
        
            window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onFindResultReceived', {
                'findResult': {
                    'activeMatchOrdinal': \(FIND_TEXT_HIGHLIGHT_CURRENT_HIGHLIGHT_JS_SOURCE()),
                    'numberOfMatches': \(FIND_TEXT_HIGHLIGHT_SEARCH_RESULT_COUNT_JS_SOURCE()),
                    'isDoneCounting': \(FIND_TEXT_HIGHLIGHT_IS_DONE_COUNTING_JS_SOURCE())
                }
            });
          }
        }
        """
    }
}
