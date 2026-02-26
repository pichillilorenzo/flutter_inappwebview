// src/index.ts
(function() {
  let _JSON_stringify = window.JSON.stringify;
  let _Array_slice = window.Array.prototype.slice;
  _Array_slice.call = window.Function.prototype.call;
  window.flutter_inappwebview_plugin = {
    createFlutterInAppWebView: function(viewId, iframe, iframeContainer, bridgeSecret) {
      const iframeId = iframe.id;
      const webView = {
        viewId,
        iframeId,
        iframe: null,
        iframeContainer: null,
        isFullscreen: false,
        documentTitle: null,
        functionMap: {},
        settings: {},
        javaScriptBridgeEnabled: true,
        disableContextMenuHandler: function(event) {
          event.preventDefault();
          event.stopPropagation();
          return false;
        },
        prepare: function(settings) {
          webView.settings = settings;
          webView.javaScriptBridgeEnabled = webView.settings.javaScriptBridgeEnabled ?? true;
          const javaScriptBridgeOriginAllowList = webView.settings.javaScriptBridgeOriginAllowList;
          if (javaScriptBridgeOriginAllowList != null && !javaScriptBridgeOriginAllowList.includes("*")) {
            if (javaScriptBridgeOriginAllowList.length === 0) {
              webView.javaScriptBridgeEnabled = false;
            }
          }
          document.addEventListener("fullscreenchange", function(event) {
            if (document.fullscreenElement && document.fullscreenElement.id == iframeId) {
              webView.isFullscreen = true;
              _nativeCommunication("onEnterFullscreen", viewId);
            } else if (!document.fullscreenElement && webView.isFullscreen) {
              webView.isFullscreen = false;
              _nativeCommunication("onExitFullscreen", viewId);
            } else {
              webView.isFullscreen = false;
            }
          });
          if (iframe != null) {
            webView.iframe = iframe;
            webView.iframeContainer = iframeContainer;
            iframe.addEventListener("load", function(event) {
              if (iframe.contentWindow == null) {
                return;
              }
              const userScriptsAtStart = _nativeCommunication("getUserOnlyScriptsAt", viewId, [0 /* AT_DOCUMENT_START */]);
              const userScriptsAtEnd = _nativeCommunication("getUserOnlyScriptsAt", viewId, [1 /* AT_DOCUMENT_END */]);
              try {
                let javaScriptBridgeEnabled = webView.javaScriptBridgeEnabled;
                if (javaScriptBridgeOriginAllowList != null) {
                  javaScriptBridgeEnabled = javaScriptBridgeOriginAllowList.map((allowedOriginRule) => new RegExp(allowedOriginRule)).some((rx) => {
                    return rx.test(iframe.contentWindow.location.origin);
                  });
                }
                if (javaScriptBridgeEnabled) {
                  const javaScriptBridgeName = _nativeCommunication("getJavaScriptBridgeName", viewId);
                  iframe.contentWindow[javaScriptBridgeName] = {
                    callHandler: function() {
                      let origin = "";
                      let requestUrl = "";
                      try {
                        origin = iframe.contentWindow.location.origin;
                      } catch (_) {
                      }
                      try {
                        requestUrl = iframe.contentWindow.location.href;
                      } catch (_) {
                      }
                      return _nativeCommunication(
                        "onCallJsHandler",
                        viewId,
                        [arguments[0], _JSON_stringify({
                          "origin": origin,
                          "requestUrl": requestUrl,
                          "isMainFrame": true,
                          "_bridgeSecret": bridgeSecret,
                          "args": _JSON_stringify(_Array_slice.call(arguments, 1))
                        })]
                      );
                    }
                  };
                }
              } catch (e) {
                console.log(e);
              }
              for (const userScript of [...userScriptsAtStart, ...userScriptsAtEnd]) {
                let ifStatement = "if (";
                let source = userScript.source;
                if (userScript.allowedOriginRules != null && !userScript.allowedOriginRules.includes("*")) {
                  if (userScript.allowedOriginRules.length === 0) {
                    source = "";
                  }
                  let jsRegExpArray = "[";
                  for (const allowedOriginRule of userScript.allowedOriginRules) {
                    if (jsRegExpArray.length > 1) {
                      jsRegExpArray += ",";
                    }
                    jsRegExpArray += `new RegExp('${allowedOriginRule.replace("'", "\\'")}')`;
                  }
                  if (jsRegExpArray.length > 1) {
                    jsRegExpArray += "]";
                    ifStatement += `${jsRegExpArray}.some(function(rx) { return rx.test(window.location.origin); })`;
                  }
                }
                webView.evaluateJavascript(ifStatement.length > 4 ? `${ifStatement}) { ${source} }` : source);
              }
              let url = iframe.src;
              try {
                url = iframe.contentWindow.location.href;
              } catch (e) {
                console.log(e);
              }
              _nativeCommunication("onLoadStart", viewId, [url]);
              try {
                const oldLogs = {
                  "log": iframe.contentWindow.console.log,
                  "debug": iframe.contentWindow.console.debug,
                  "error": iframe.contentWindow.console.error,
                  "info": iframe.contentWindow.console.info,
                  "warn": iframe.contentWindow.console.warn
                };
                for (const k in oldLogs) {
                  (function(oldLog) {
                    iframe.contentWindow.console[oldLog] = function() {
                      var message = "";
                      for (var i in arguments) {
                        if (message == "") {
                          message += arguments[i];
                        } else {
                          message += " " + arguments[i];
                        }
                      }
                      oldLogs[oldLog].call(iframe.contentWindow.console, ...arguments);
                      _nativeCommunication("onConsoleMessage", viewId, [oldLog, message]);
                    };
                  })(k);
                }
              } catch (e) {
                console.log(e);
              }
              try {
                const originalPushState = iframe.contentWindow.history.pushState;
                iframe.contentWindow.history.pushState = function(state, unused, url2) {
                  originalPushState.call(iframe.contentWindow.history, state, unused, url2);
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onUpdateVisitedHistory", viewId, [iframeUrl]);
                };
                const originalReplaceState = iframe.contentWindow.history.replaceState;
                iframe.contentWindow.history.replaceState = function(state, unused, url2) {
                  originalReplaceState.call(iframe.contentWindow.history, state, unused, url2);
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onUpdateVisitedHistory", viewId, [iframeUrl]);
                };
                const originalClose = iframe.contentWindow.close;
                iframe.contentWindow.close = function() {
                  originalClose.call(iframe.contentWindow);
                  _nativeCommunication("onCloseWindow", viewId);
                };
                const originalOpen = iframe.contentWindow.open;
                iframe.contentWindow.open = function(url2, target, windowFeatures) {
                  const newWindow = originalOpen.call(iframe.contentWindow, ...arguments);
                  _nativeCommunication("onCreateWindow", viewId, [url2, target, windowFeatures]).then(function(handledByClient) {
                    if (handledByClient) {
                      newWindow?.close();
                    }
                  });
                  return newWindow;
                };
                const originalPrint = iframe.contentWindow.print;
                iframe.contentWindow.print = function() {
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onPrintRequest", viewId, [iframeUrl]);
                  originalPrint.call(iframe.contentWindow);
                };
                webView.functionMap = {
                  "window.open": iframe.contentWindow.open
                };
                const initialTitle = iframe.contentDocument?.title;
                const titleEl = iframe.contentDocument?.querySelector("title");
                webView.documentTitle = initialTitle;
                _nativeCommunication("onTitleChanged", viewId, [initialTitle]);
                if (titleEl != null) {
                  new MutationObserver(function(mutations) {
                    const title = mutations[0].target.innerText;
                    if (title != webView.documentTitle) {
                      webView.documentTitle = title;
                      _nativeCommunication("onTitleChanged", viewId, [title]);
                    }
                  }).observe(
                    titleEl,
                    { subtree: true, characterData: true, childList: true }
                  );
                }
                let oldPixelRatio = iframe.contentWindow.devicePixelRatio;
                iframe.contentWindow.addEventListener("resize", function(e) {
                  const newPixelRatio = iframe.contentWindow.devicePixelRatio;
                  if (newPixelRatio !== oldPixelRatio) {
                    _nativeCommunication("onZoomScaleChanged", viewId, [oldPixelRatio, newPixelRatio]);
                    oldPixelRatio = newPixelRatio;
                  }
                });
                iframe.contentWindow.addEventListener("popstate", function(event2) {
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onUpdateVisitedHistory", viewId, [iframeUrl]);
                });
                iframe.contentWindow.addEventListener("scroll", function(event2) {
                  let x = 0;
                  let y = 0;
                  try {
                    x = iframe.contentWindow.scrollX;
                    y = iframe.contentWindow.scrollY;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onScrollChanged", viewId, [x, y]);
                });
                iframe.contentWindow.addEventListener("focus", function(event2) {
                  _nativeCommunication("onWindowFocus", viewId);
                });
                iframe.contentWindow.addEventListener("blur", function(event2) {
                  _nativeCommunication("onWindowBlur", viewId);
                });
              } catch (e) {
                console.log(e);
              }
              try {
                if (!webView.settings.javaScriptCanOpenWindowsAutomatically) {
                  iframe.contentWindow.open = function() {
                    throw new Error("JavaScript cannot open windows automatically");
                  };
                }
                if (!webView.settings.verticalScrollBarEnabled && !webView.settings.horizontalScrollBarEnabled) {
                  const style = iframe.contentDocument?.createElement("style");
                  if (style != null) {
                    style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                    style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }
                if (webView.settings.disableVerticalScroll) {
                  const style = iframe.contentDocument?.createElement("style");
                  if (style != null) {
                    style.id = "settings.disableVerticalScroll";
                    style.innerHTML = "body { overflow-y: hidden; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }
                if (webView.settings.disableHorizontalScroll) {
                  const style = iframe.contentDocument?.createElement("style");
                  if (style != null) {
                    style.id = "settings.disableHorizontalScroll";
                    style.innerHTML = "body { overflow-x: hidden; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }
                if (webView.settings.disableContextMenu) {
                  iframe.contentWindow.addEventListener("contextmenu", webView.disableContextMenuHandler);
                }
              } catch (e) {
                console.log(e);
              }
              _nativeCommunication("onLoadStop", viewId, [url]);
              try {
                iframe.contentWindow.dispatchEvent(new Event("flutterInAppWebViewPlatformReady"));
              } catch (e) {
                console.log(e);
              }
            });
          }
        },
        setSettings: function(newSettings) {
          const iframe2 = webView.iframe;
          if (iframe2 == null) {
            return;
          }
          try {
            if (webView.settings.javaScriptCanOpenWindowsAutomatically != newSettings.javaScriptCanOpenWindowsAutomatically) {
              if (!newSettings.javaScriptCanOpenWindowsAutomatically) {
                iframe2.contentWindow.open = function() {
                  throw new Error("JavaScript cannot open windows automatically");
                };
              } else {
                iframe2.contentWindow.open = webView.functionMap["window.open"];
              }
            }
            if (webView.settings.verticalScrollBarEnabled != newSettings.verticalScrollBarEnabled && webView.settings.horizontalScrollBarEnabled != newSettings.horizontalScrollBarEnabled) {
              if (!newSettings.verticalScrollBarEnabled && !newSettings.horizontalScrollBarEnabled) {
                const style = iframe2.contentDocument?.createElement("style");
                if (style != null) {
                  style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                  style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                  iframe2.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe2.contentDocument?.getElementById("settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled");
                if (styleElement) {
                  styleElement.remove();
                }
              }
            }
            if (webView.settings.disableVerticalScroll != newSettings.disableVerticalScroll) {
              if (newSettings.disableVerticalScroll) {
                const style = iframe2.contentDocument?.createElement("style");
                if (style != null) {
                  style.id = "settings.disableVerticalScroll";
                  style.innerHTML = "body { overflow-y: hidden; }";
                  iframe2.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe2.contentDocument?.getElementById("settings.disableVerticalScroll");
                if (styleElement) {
                  styleElement.remove();
                }
              }
            }
            if (webView.settings.disableHorizontalScroll != newSettings.disableHorizontalScroll) {
              if (newSettings.disableHorizontalScroll) {
                const style = iframe2.contentDocument?.createElement("style");
                if (style != null) {
                  style.id = "settings.disableHorizontalScroll";
                  style.innerHTML = "body { overflow-x: hidden; }";
                  iframe2.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe2.contentDocument?.getElementById("settings.disableHorizontalScroll");
                if (styleElement) {
                  styleElement.remove();
                }
              }
            }
            if (webView.settings.disableContextMenu != newSettings.disableContextMenu) {
              if (newSettings.disableContextMenu) {
                iframe2.contentWindow?.addEventListener("contextmenu", webView.disableContextMenuHandler);
              } else {
                iframe2.contentWindow?.removeEventListener("contextmenu", webView.disableContextMenuHandler);
              }
            }
          } catch (e) {
            console.log(e);
          }
          webView.settings = newSettings;
        },
        reload: function() {
          var iframe2 = webView.iframe;
          if (iframe2 != null && iframe2.contentWindow != null) {
            try {
              iframe2.contentWindow.location.reload();
            } catch (e) {
              console.log(e);
              iframe2.contentWindow.location.href = iframe2.src;
            }
          }
        },
        goBack: function() {
          var iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.history.back();
            } catch (e) {
              console.log(e);
            }
          }
        },
        goForward: function() {
          var iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.history.forward();
            } catch (e) {
              console.log(e);
            }
          }
        },
        goBackOrForward: function(steps) {
          var iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.history.go(steps);
            } catch (e) {
              console.log(e);
            }
          }
        },
        evaluateJavascript: function(source) {
          const iframe2 = webView.iframe;
          let result = null;
          if (iframe2 != null) {
            try {
              result = JSON.stringify(iframe2.contentWindow?.eval(source));
            } catch (e) {
            }
          }
          return result;
        },
        stopLoading: function() {
          const iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.stop();
            } catch (e) {
              console.log(e);
            }
          }
        },
        getUrl: function() {
          const iframe2 = webView.iframe;
          let url = iframe2?.src;
          try {
            url = iframe2?.contentWindow?.location.href;
          } catch (e) {
            console.log(e);
          }
          return url;
        },
        getTitle: function() {
          const iframe2 = webView.iframe;
          let title = null;
          try {
            title = iframe2?.contentDocument?.title;
          } catch (e) {
            console.log(e);
          }
          return title;
        },
        injectJavascriptFileFromUrl: function(urlFile, scriptHtmlTagAttributes) {
          const iframe2 = webView.iframe;
          try {
            const d = iframe2?.contentDocument;
            if (d == null) {
              return;
            }
            const script = d.createElement("script");
            for (const key of Object.keys(scriptHtmlTagAttributes)) {
              if (scriptHtmlTagAttributes[key] != null) {
                script[key] = scriptHtmlTagAttributes[key];
              }
            }
            if (script.id != null) {
              script.onload = function() {
                _nativeCommunication("onInjectedScriptLoaded", webView.viewId, [script.id]);
              };
              script.onerror = function() {
                _nativeCommunication("onInjectedScriptError", webView.viewId, [script.id]);
              };
            }
            script.src = urlFile;
            if (d.body != null) {
              d.body.appendChild(script);
            }
          } catch (e) {
            console.log(e);
          }
        },
        injectCSSCode: function(source) {
          const iframe2 = webView.iframe;
          try {
            const d = iframe2?.contentDocument;
            if (d == null) {
              return;
            }
            const style = d.createElement("style");
            style.innerHTML = source;
            if (d.head != null) {
              d.head.appendChild(style);
            }
          } catch (e) {
            console.log(e);
          }
        },
        injectCSSFileFromUrl: function(urlFile, cssLinkHtmlTagAttributes) {
          const iframe2 = webView.iframe;
          try {
            const d = iframe2?.contentDocument;
            if (d == null) {
              return;
            }
            const link = d.createElement("link");
            for (const key of Object.keys(cssLinkHtmlTagAttributes)) {
              if (cssLinkHtmlTagAttributes[key] != null) {
                link[key] = cssLinkHtmlTagAttributes[key];
              }
            }
            link.type = "text/css";
            var alternateStylesheet = "";
            if (cssLinkHtmlTagAttributes.alternateStylesheet) {
              alternateStylesheet = "alternate ";
            }
            link.rel = alternateStylesheet + "stylesheet";
            link.href = urlFile;
            if (d.head != null) {
              d.head.appendChild(link);
            }
          } catch (e) {
            console.log(e);
          }
        },
        scrollTo: function(x, y, animated) {
          const iframe2 = webView.iframe;
          try {
            if (animated) {
              iframe2?.contentWindow?.scrollTo({ top: y, left: x, behavior: "smooth" });
            } else {
              iframe2?.contentWindow?.scrollTo(x, y);
            }
          } catch (e) {
            console.log(e);
          }
        },
        scrollBy: function(x, y, animated) {
          const iframe2 = webView.iframe;
          try {
            if (animated) {
              iframe2?.contentWindow?.scrollBy({ top: y, left: x, behavior: "smooth" });
            } else {
              iframe2?.contentWindow?.scrollBy(x, y);
            }
          } catch (e) {
            console.log(e);
          }
        },
        printCurrentPage: function() {
          const iframe2 = webView.iframe;
          try {
            iframe2?.contentWindow?.print();
          } catch (e) {
            console.log(e);
          }
        },
        getContentHeight: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentDocument?.documentElement.scrollHeight;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getContentWidth: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentDocument?.documentElement.scrollWidth;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getSelectedText: function() {
          const iframe2 = webView.iframe;
          try {
            let txt;
            const w = iframe2?.contentWindow;
            if (w == null) {
              return null;
            }
            if (w.getSelection) {
              txt = w.getSelection()?.toString();
            } else if (w.document.getSelection) {
              txt = w.document.getSelection()?.toString();
            } else if (w.document.selection) {
              txt = w.document.selection.createRange().text;
            }
            return txt;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getScrollX: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentWindow?.scrollX;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getScrollY: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentWindow?.scrollY;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        isSecureContext: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentWindow?.isSecureContext ?? false;
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        canScrollVertically: function() {
          const iframe2 = webView.iframe;
          try {
            return (iframe2?.contentDocument?.body.scrollHeight ?? 0) > (iframe2?.contentWindow?.innerHeight ?? 0);
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        canScrollHorizontally: function() {
          const iframe2 = webView.iframe;
          try {
            return (iframe2?.contentDocument?.body.scrollWidth ?? 0) > (iframe2?.contentWindow?.innerWidth ?? 0);
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        getSize: function() {
          const iframeContainer2 = webView.iframeContainer;
          let width = 0;
          let height = 0;
          if (iframeContainer2 != null) {
            if (iframeContainer2.style.width != null && iframeContainer2.style.width != "" && iframeContainer2.style.width.indexOf("px") > 0) {
              width = parseFloat(iframeContainer2.style.width);
            }
            if (width == null || width == 0) {
              width = iframeContainer2.getBoundingClientRect().width;
            }
            if (iframeContainer2.style.height != null && iframeContainer2.style.height != "" && iframeContainer2.style.height.indexOf("px") > 0) {
              height = parseFloat(iframeContainer2.style.height);
            }
            if (height == null || height == 0) {
              height = iframeContainer2.getBoundingClientRect().height;
            }
          }
          return {
            width,
            height
          };
        }
      };
      return webView;
    },
    getCookieExpirationDate: function(timestamp) {
      return new Date(timestamp).toUTCString();
    },
    nativeAsyncCommunication: function(method, viewId, args) {
      throw new Error("Method not implemented.");
    },
    nativeSyncCommunication: function(method, viewId, args) {
      throw new Error("Method not implemented.");
    },
    nativeCommunication: function(method, viewId, args) {
      try {
        const result = window.flutter_inappwebview_plugin.nativeSyncCommunication(method, viewId, args);
        return result != null ? JSON.parse(result) : null;
      } catch (e1) {
        try {
          const promise = window.flutter_inappwebview_plugin.nativeAsyncCommunication(method, viewId, args);
          return promise.then(function(result) {
            return result != null ? JSON.parse(result) : null;
          });
        } catch (e2) {
          return null;
        }
      }
    }
  };
  let _nativeCommunication = window.flutter_inappwebview_plugin.nativeCommunication;
})();
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vLi4vLi4vLi4vd2ViX3N1cHBvcnQvc3JjL2luZGV4LnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQge1xuICBJbkFwcFdlYlZpZXcsXG4gIEluQXBwV2ViVmlld1BsdWdpbixcbiAgSW5BcHBXZWJWaWV3U2V0dGluZ3MsXG4gIEphdmFTY3JpcHRCcmlkZ2VIYW5kbGVyLFxuICBVc2VyU2NyaXB0LFxuICBVc2VyU2NyaXB0SW5qZWN0aW9uVGltZVxufSBmcm9tIFwiLi90eXBlc1wiO1xuXG5kZWNsYXJlIGdsb2JhbCB7XG4gIGludGVyZmFjZSBXaW5kb3cge1xuICAgIGZsdXR0ZXJfaW5hcHB3ZWJ2aWV3X3BsdWdpbjogSW5BcHBXZWJWaWV3UGx1Z2luO1xuICAgIGZsdXR0ZXJfaW5hcHB3ZWJ2aWV3PzogSmF2YVNjcmlwdEJyaWRnZUhhbmRsZXIgfCBudWxsO1xuICAgIGNvbnNvbGU6IENvbnNvbGU7XG5cbiAgICBldmFsKHg6IHN0cmluZyk6IGFueTtcbiAgfVxufVxuXG4oZnVuY3Rpb24gKCkge1xuICBsZXQgX0pTT05fc3RyaW5naWZ5ID0gd2luZG93LkpTT04uc3RyaW5naWZ5O1xuICBsZXQgX0FycmF5X3NsaWNlID0gd2luZG93LkFycmF5LnByb3RvdHlwZS5zbGljZTtcbiAgX0FycmF5X3NsaWNlLmNhbGwgPSB3aW5kb3cuRnVuY3Rpb24ucHJvdG90eXBlLmNhbGw7XG5cbiAgd2luZG93LmZsdXR0ZXJfaW5hcHB3ZWJ2aWV3X3BsdWdpbiA9IHtcbiAgICBjcmVhdGVGbHV0dGVySW5BcHBXZWJWaWV3OiBmdW5jdGlvbiAodmlld0lkOiBudW1iZXIgfCBzdHJpbmcsIGlmcmFtZTogSFRNTElGcmFtZUVsZW1lbnQsIGlmcmFtZUNvbnRhaW5lcjogSFRNTERpdkVsZW1lbnQsIGJyaWRnZVNlY3JldDogc3RyaW5nKSB7XG4gICAgICBjb25zdCBpZnJhbWVJZCA9IGlmcmFtZS5pZDtcbiAgICAgIGNvbnN0IHdlYlZpZXc6IEluQXBwV2ViVmlldyA9IHtcbiAgICAgICAgdmlld0lkOiB2aWV3SWQsXG4gICAgICAgIGlmcmFtZUlkOiBpZnJhbWVJZCxcbiAgICAgICAgaWZyYW1lOiBudWxsLFxuICAgICAgICBpZnJhbWVDb250YWluZXI6IG51bGwsXG4gICAgICAgIGlzRnVsbHNjcmVlbjogZmFsc2UsXG4gICAgICAgIGRvY3VtZW50VGl0bGU6IG51bGwsXG4gICAgICAgIGZ1bmN0aW9uTWFwOiB7fSxcbiAgICAgICAgc2V0dGluZ3M6IHt9LFxuICAgICAgICBqYXZhU2NyaXB0QnJpZGdlRW5hYmxlZDogdHJ1ZSxcbiAgICAgICAgZGlzYWJsZUNvbnRleHRNZW51SGFuZGxlcjogZnVuY3Rpb24gKGV2ZW50OiBFdmVudCkge1xuICAgICAgICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KCk7XG4gICAgICAgICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKCk7XG4gICAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgICAgICB9LFxuICAgICAgICBwcmVwYXJlOiBmdW5jdGlvbiAoc2V0dGluZ3M6IEluQXBwV2ViVmlld1NldHRpbmdzKSB7XG4gICAgICAgICAgd2ViVmlldy5zZXR0aW5ncyA9IHNldHRpbmdzO1xuXG4gICAgICAgICAgd2ViVmlldy5qYXZhU2NyaXB0QnJpZGdlRW5hYmxlZCA9IHdlYlZpZXcuc2V0dGluZ3MuamF2YVNjcmlwdEJyaWRnZUVuYWJsZWQgPz8gdHJ1ZTtcbiAgICAgICAgICBjb25zdCBqYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0ID0gd2ViVmlldy5zZXR0aW5ncy5qYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0O1xuICAgICAgICAgIGlmIChqYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0ICE9IG51bGwgJiYgIWphdmFTY3JpcHRCcmlkZ2VPcmlnaW5BbGxvd0xpc3QuaW5jbHVkZXMoXCIqXCIpKSB7XG4gICAgICAgICAgICBpZiAoamF2YVNjcmlwdEJyaWRnZU9yaWdpbkFsbG93TGlzdC5sZW5ndGggPT09IDApIHtcbiAgICAgICAgICAgICAgLy8gYW4gZW1wdHkgbGlzdCBtZWFucyB0aGF0IHRoZSBKYXZhU2NyaXB0IEJyaWRnZSBpcyBub3QgYWxsb3dlZCBmb3IgYW55IG9yaWdpbi5cbiAgICAgICAgICAgICAgd2ViVmlldy5qYXZhU2NyaXB0QnJpZGdlRW5hYmxlZCA9IGZhbHNlO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cblxuICAgICAgICAgIGRvY3VtZW50LmFkZEV2ZW50TGlzdGVuZXIoJ2Z1bGxzY3JlZW5jaGFuZ2UnLCBmdW5jdGlvbiAoZXZlbnQ6IEV2ZW50KSB7XG4gICAgICAgICAgICAvLyBkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudCB3aWxsIHBvaW50IHRvIHRoZSBlbGVtZW50IHRoYXRcbiAgICAgICAgICAgIC8vIGlzIGluIGZ1bGxzY3JlZW4gbW9kZSBpZiB0aGVyZSBpcyBvbmUuIElmIHRoZXJlIGlzbid0IG9uZSxcbiAgICAgICAgICAgIC8vIHRoZSB2YWx1ZSBvZiB0aGUgcHJvcGVydHkgaXMgbnVsbC5cbiAgICAgICAgICAgIGlmIChkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudCAmJiBkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudC5pZCA9PSBpZnJhbWVJZCkge1xuICAgICAgICAgICAgICB3ZWJWaWV3LmlzRnVsbHNjcmVlbiA9IHRydWU7XG4gICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvbkVudGVyRnVsbHNjcmVlbicsIHZpZXdJZCk7XG4gICAgICAgICAgICB9IGVsc2UgaWYgKCFkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudCAmJiB3ZWJWaWV3LmlzRnVsbHNjcmVlbikge1xuICAgICAgICAgICAgICB3ZWJWaWV3LmlzRnVsbHNjcmVlbiA9IGZhbHNlO1xuICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25FeGl0RnVsbHNjcmVlbicsIHZpZXdJZCk7XG4gICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICB3ZWJWaWV3LmlzRnVsbHNjcmVlbiA9IGZhbHNlO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsKSB7XG4gICAgICAgICAgICB3ZWJWaWV3LmlmcmFtZSA9IGlmcmFtZTtcbiAgICAgICAgICAgIHdlYlZpZXcuaWZyYW1lQ29udGFpbmVyID0gaWZyYW1lQ29udGFpbmVyO1xuICAgICAgICAgICAgaWZyYW1lLmFkZEV2ZW50TGlzdGVuZXIoJ2xvYWQnLCBmdW5jdGlvbiAoZXZlbnQ6IEV2ZW50KSB7XG4gICAgICAgICAgICAgIGlmIChpZnJhbWUuY29udGVudFdpbmRvdyA9PSBudWxsKSB7XG4gICAgICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgY29uc3QgdXNlclNjcmlwdHNBdFN0YXJ0ID0gX25hdGl2ZUNvbW11bmljYXRpb248VXNlclNjcmlwdFtdPignZ2V0VXNlck9ubHlTY3JpcHRzQXQnLCB2aWV3SWQsIFtVc2VyU2NyaXB0SW5qZWN0aW9uVGltZS5BVF9ET0NVTUVOVF9TVEFSVF0pO1xuICAgICAgICAgICAgICBjb25zdCB1c2VyU2NyaXB0c0F0RW5kID0gX25hdGl2ZUNvbW11bmljYXRpb248VXNlclNjcmlwdFtdPignZ2V0VXNlck9ubHlTY3JpcHRzQXQnLCB2aWV3SWQsIFtVc2VyU2NyaXB0SW5qZWN0aW9uVGltZS5BVF9ET0NVTUVOVF9FTkRdKTtcblxuICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgIGxldCBqYXZhU2NyaXB0QnJpZGdlRW5hYmxlZCA9IHdlYlZpZXcuamF2YVNjcmlwdEJyaWRnZUVuYWJsZWQ7XG4gICAgICAgICAgICAgICAgaWYgKGphdmFTY3JpcHRCcmlkZ2VPcmlnaW5BbGxvd0xpc3QgIT0gbnVsbCkge1xuICAgICAgICAgICAgICAgICAgamF2YVNjcmlwdEJyaWRnZUVuYWJsZWQgPSBqYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0XG4gICAgICAgICAgICAgICAgICAgICAgLm1hcChhbGxvd2VkT3JpZ2luUnVsZSA9PiBuZXcgUmVnRXhwKGFsbG93ZWRPcmlnaW5SdWxlKSlcbiAgICAgICAgICAgICAgICAgICAgICAuc29tZSgocngpID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiByeC50ZXN0KGlmcmFtZS5jb250ZW50V2luZG93IS5sb2NhdGlvbi5vcmlnaW4pO1xuICAgICAgICAgICAgICAgICAgICAgIH0pXG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIGlmIChqYXZhU2NyaXB0QnJpZGdlRW5hYmxlZCkge1xuICAgICAgICAgICAgICAgICAgY29uc3QgamF2YVNjcmlwdEJyaWRnZU5hbWUgPSBfbmF0aXZlQ29tbXVuaWNhdGlvbjxzdHJpbmc+KCdnZXRKYXZhU2NyaXB0QnJpZGdlTmFtZScsIHZpZXdJZCk7XG4gICAgICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdyFbamF2YVNjcmlwdEJyaWRnZU5hbWVdID0ge1xuICAgICAgICAgICAgICAgICAgICBjYWxsSGFuZGxlcjogZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgICAgICAgICAgIGxldCBvcmlnaW4gPSAnJztcbiAgICAgICAgICAgICAgICAgICAgICBsZXQgcmVxdWVzdFVybCA9ICcnO1xuICAgICAgICAgICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgICAgICAgICBvcmlnaW4gPSBpZnJhbWUuY29udGVudFdpbmRvdyEubG9jYXRpb24ub3JpZ2luO1xuICAgICAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKF8pIHtcbiAgICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICAgICAgICAgIHJlcXVlc3RVcmwgPSBpZnJhbWUuY29udGVudFdpbmRvdyEubG9jYXRpb24uaHJlZjtcbiAgICAgICAgICAgICAgICAgICAgICB9IGNhdGNoIChfKSB7XG4gICAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgICAgIHJldHVybiBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25DYWxsSnNIYW5kbGVyJyxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgdmlld0lkLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBbYXJndW1lbnRzWzBdLCBfSlNPTl9zdHJpbmdpZnkoe1xuICAgICAgICAgICAgICAgICAgICAgICAgICAgICdvcmlnaW4nOiBvcmlnaW4sXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgJ3JlcXVlc3RVcmwnOiByZXF1ZXN0VXJsLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICdpc01haW5GcmFtZSc6IHRydWUsXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgJ19icmlkZ2VTZWNyZXQnOiBicmlkZ2VTZWNyZXQsXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgJ2FyZ3MnOiBfSlNPTl9zdHJpbmdpZnkoX0FycmF5X3NsaWNlLmNhbGwoYXJndW1lbnRzLCAxKSlcbiAgICAgICAgICAgICAgICAgICAgICAgICAgfSldKTtcbiAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgfSBhcyBKYXZhU2NyaXB0QnJpZGdlSGFuZGxlcjtcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIGZvciAoY29uc3QgdXNlclNjcmlwdCBvZiBbLi4udXNlclNjcmlwdHNBdFN0YXJ0LCAuLi51c2VyU2NyaXB0c0F0RW5kXSkge1xuICAgICAgICAgICAgICAgIGxldCBpZlN0YXRlbWVudCA9IFwiaWYgKFwiO1xuICAgICAgICAgICAgICAgIGxldCBzb3VyY2UgPSB1c2VyU2NyaXB0LnNvdXJjZTtcbiAgICAgICAgICAgICAgICBpZiAodXNlclNjcmlwdC5hbGxvd2VkT3JpZ2luUnVsZXMgIT0gbnVsbCAmJiAhdXNlclNjcmlwdC5hbGxvd2VkT3JpZ2luUnVsZXMuaW5jbHVkZXMoXCIqXCIpKSB7XG4gICAgICAgICAgICAgICAgICBpZiAodXNlclNjcmlwdC5hbGxvd2VkT3JpZ2luUnVsZXMubGVuZ3RoID09PSAwKSB7XG4gICAgICAgICAgICAgICAgICAgIC8vIHJldHVybiBlbXB0eSBzb3VyY2Ugc3RyaW5nIGlmIGFsbG93ZWRPcmlnaW5SdWxlcyBpcyBhbiBlbXB0eSBsaXN0LlxuICAgICAgICAgICAgICAgICAgICAvLyBhbiBlbXB0eSBsaXN0IG1lYW5zIHRoYXQgdGhpcyBVc2VyU2NyaXB0IGlzIG5vdCBhbGxvd2VkIGZvciBhbnkgb3JpZ2luLlxuICAgICAgICAgICAgICAgICAgICBzb3VyY2UgPSBcIlwiO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgbGV0IGpzUmVnRXhwQXJyYXkgPSBcIltcIjtcbiAgICAgICAgICAgICAgICAgIGZvciAoY29uc3QgYWxsb3dlZE9yaWdpblJ1bGUgb2YgdXNlclNjcmlwdC5hbGxvd2VkT3JpZ2luUnVsZXMpIHtcbiAgICAgICAgICAgICAgICAgICAgaWYgKGpzUmVnRXhwQXJyYXkubGVuZ3RoID4gMSkge1xuICAgICAgICAgICAgICAgICAgICAgIGpzUmVnRXhwQXJyYXkgKz0gXCIsXCI7XG4gICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgICAganNSZWdFeHBBcnJheSArPSBgbmV3IFJlZ0V4cCgnJHthbGxvd2VkT3JpZ2luUnVsZS5yZXBsYWNlKFwiXFwnXCIsIFwiXFxcXCdcIil9JylgO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgaWYgKGpzUmVnRXhwQXJyYXkubGVuZ3RoID4gMSkge1xuICAgICAgICAgICAgICAgICAgICBqc1JlZ0V4cEFycmF5ICs9IFwiXVwiO1xuICAgICAgICAgICAgICAgICAgICBpZlN0YXRlbWVudCArPSBgJHtqc1JlZ0V4cEFycmF5fS5zb21lKGZ1bmN0aW9uKHJ4KSB7IHJldHVybiByeC50ZXN0KHdpbmRvdy5sb2NhdGlvbi5vcmlnaW4pOyB9KWA7XG4gICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIHdlYlZpZXcuZXZhbHVhdGVKYXZhc2NyaXB0KGlmU3RhdGVtZW50Lmxlbmd0aCA+IDQgPyBgJHtpZlN0YXRlbWVudH0pIHsgJHtzb3VyY2V9IH1gIDogc291cmNlKTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIGxldCB1cmwgPSBpZnJhbWUuc3JjO1xuICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgIHVybCA9IGlmcmFtZS5jb250ZW50V2luZG93LmxvY2F0aW9uLmhyZWY7XG4gICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25Mb2FkU3RhcnQnLCB2aWV3SWQsIFt1cmxdKTtcblxuICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgIGNvbnN0IG9sZExvZ3MgPSB7XG4gICAgICAgICAgICAgICAgICAnbG9nJzogaWZyYW1lLmNvbnRlbnRXaW5kb3cuY29uc29sZS5sb2csXG4gICAgICAgICAgICAgICAgICAnZGVidWcnOiBpZnJhbWUuY29udGVudFdpbmRvdy5jb25zb2xlLmRlYnVnLFxuICAgICAgICAgICAgICAgICAgJ2Vycm9yJzogaWZyYW1lLmNvbnRlbnRXaW5kb3cuY29uc29sZS5lcnJvcixcbiAgICAgICAgICAgICAgICAgICdpbmZvJzogaWZyYW1lLmNvbnRlbnRXaW5kb3cuY29uc29sZS5pbmZvLFxuICAgICAgICAgICAgICAgICAgJ3dhcm4nOiBpZnJhbWUuY29udGVudFdpbmRvdy5jb25zb2xlLndhcm5cbiAgICAgICAgICAgICAgICB9O1xuICAgICAgICAgICAgICAgIGZvciAoY29uc3QgayBpbiBvbGRMb2dzKSB7XG4gICAgICAgICAgICAgICAgICAoZnVuY3Rpb24gKG9sZExvZykge1xuICAgICAgICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmNvbnNvbGVbb2xkTG9nXSA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgICAgICAgICAgICB2YXIgbWVzc2FnZSA9ICcnO1xuICAgICAgICAgICAgICAgICAgICAgIGZvciAodmFyIGkgaW4gYXJndW1lbnRzKSB7XG4gICAgICAgICAgICAgICAgICAgICAgICBpZiAobWVzc2FnZSA9PSAnJykge1xuICAgICAgICAgICAgICAgICAgICAgICAgICBtZXNzYWdlICs9IGFyZ3VtZW50c1tpXTtcbiAgICAgICAgICAgICAgICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgIG1lc3NhZ2UgKz0gJyAnICsgYXJndW1lbnRzW2ldO1xuICAgICAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICAgICAgICAgICAgb2xkTG9nc1tvbGRMb2ddLmNhbGwoaWZyYW1lLmNvbnRlbnRXaW5kb3cuY29uc29sZSwgLi4uYXJndW1lbnRzKTtcbiAgICAgICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25Db25zb2xlTWVzc2FnZScsIHZpZXdJZCwgW29sZExvZywgbWVzc2FnZV0pO1xuICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICB9KShrKTtcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgY29uc3Qgb3JpZ2luYWxQdXNoU3RhdGUgPSBpZnJhbWUuY29udGVudFdpbmRvdy5oaXN0b3J5LnB1c2hTdGF0ZTtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5oaXN0b3J5LnB1c2hTdGF0ZSA9IGZ1bmN0aW9uIChzdGF0ZSwgdW51c2VkLCB1cmwpIHtcbiAgICAgICAgICAgICAgICAgIG9yaWdpbmFsUHVzaFN0YXRlLmNhbGwoaWZyYW1lLmNvbnRlbnRXaW5kb3chLmhpc3RvcnksIHN0YXRlLCB1bnVzZWQsIHVybCk7XG4gICAgICAgICAgICAgICAgICBsZXQgaWZyYW1lVXJsID0gaWZyYW1lLnNyYztcbiAgICAgICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZVVybCA9IGlmcmFtZS5jb250ZW50V2luZG93IS5sb2NhdGlvbi5ocmVmO1xuICAgICAgICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvblVwZGF0ZVZpc2l0ZWRIaXN0b3J5Jywgdmlld0lkLCBbaWZyYW1lVXJsXSk7XG4gICAgICAgICAgICAgICAgfTtcblxuICAgICAgICAgICAgICAgIGNvbnN0IG9yaWdpbmFsUmVwbGFjZVN0YXRlID0gaWZyYW1lLmNvbnRlbnRXaW5kb3cuaGlzdG9yeS5yZXBsYWNlU3RhdGU7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuaGlzdG9yeS5yZXBsYWNlU3RhdGUgPSBmdW5jdGlvbiAoc3RhdGUsIHVudXNlZCwgdXJsKSB7XG4gICAgICAgICAgICAgICAgICBvcmlnaW5hbFJlcGxhY2VTdGF0ZS5jYWxsKGlmcmFtZS5jb250ZW50V2luZG93IS5oaXN0b3J5LCBzdGF0ZSwgdW51c2VkLCB1cmwpO1xuICAgICAgICAgICAgICAgICAgbGV0IGlmcmFtZVVybCA9IGlmcmFtZS5zcmM7XG4gICAgICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgICAgICBpZnJhbWVVcmwgPSBpZnJhbWUuY29udGVudFdpbmRvdyEubG9jYXRpb24uaHJlZjtcbiAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25VcGRhdGVWaXNpdGVkSGlzdG9yeScsIHZpZXdJZCwgW2lmcmFtZVVybF0pO1xuICAgICAgICAgICAgICAgIH07XG5cbiAgICAgICAgICAgICAgICBjb25zdCBvcmlnaW5hbENsb3NlID0gaWZyYW1lLmNvbnRlbnRXaW5kb3cuY2xvc2U7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuY2xvc2UgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgICBvcmlnaW5hbENsb3NlLmNhbGwoaWZyYW1lLmNvbnRlbnRXaW5kb3cpO1xuICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uQ2xvc2VXaW5kb3cnLCB2aWV3SWQpO1xuICAgICAgICAgICAgICAgIH07XG5cbiAgICAgICAgICAgICAgICBjb25zdCBvcmlnaW5hbE9wZW4gPSBpZnJhbWUuY29udGVudFdpbmRvdy5vcGVuO1xuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93Lm9wZW4gPSBmdW5jdGlvbiAodXJsLCB0YXJnZXQsIHdpbmRvd0ZlYXR1cmVzKSB7XG4gICAgICAgICAgICAgICAgICBjb25zdCBuZXdXaW5kb3cgPSBvcmlnaW5hbE9wZW4uY2FsbChpZnJhbWUuY29udGVudFdpbmRvdywgLi4uYXJndW1lbnRzKTtcbiAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uPFByb21pc2U8Ym9vbGVhbj4+KCdvbkNyZWF0ZVdpbmRvdycsIHZpZXdJZCwgW3VybCwgdGFyZ2V0LCB3aW5kb3dGZWF0dXJlc10pLnRoZW4oZnVuY3Rpb24gKGhhbmRsZWRCeUNsaWVudCkge1xuICAgICAgICAgICAgICAgICAgICBpZiAoaGFuZGxlZEJ5Q2xpZW50KSB7XG4gICAgICAgICAgICAgICAgICAgICAgbmV3V2luZG93Py5jbG9zZSgpO1xuICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICB9KTtcbiAgICAgICAgICAgICAgICAgIHJldHVybiBuZXdXaW5kb3c7XG4gICAgICAgICAgICAgICAgfTtcblxuICAgICAgICAgICAgICAgIGNvbnN0IG9yaWdpbmFsUHJpbnQgPSBpZnJhbWUuY29udGVudFdpbmRvdy5wcmludDtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5wcmludCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgICAgICAgIGxldCBpZnJhbWVVcmwgPSBpZnJhbWUuc3JjO1xuICAgICAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICAgICAgaWZyYW1lVXJsID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLmxvY2F0aW9uLmhyZWY7XG4gICAgICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uUHJpbnRSZXF1ZXN0Jywgdmlld0lkLCBbaWZyYW1lVXJsXSk7XG4gICAgICAgICAgICAgICAgICBvcmlnaW5hbFByaW50LmNhbGwoaWZyYW1lLmNvbnRlbnRXaW5kb3cpO1xuICAgICAgICAgICAgICAgIH07XG5cbiAgICAgICAgICAgICAgICB3ZWJWaWV3LmZ1bmN0aW9uTWFwID0ge1xuICAgICAgICAgICAgICAgICAgXCJ3aW5kb3cub3BlblwiOiBpZnJhbWUuY29udGVudFdpbmRvdy5vcGVuLFxuICAgICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICAgIGNvbnN0IGluaXRpYWxUaXRsZSA9IGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LnRpdGxlO1xuICAgICAgICAgICAgICAgIGNvbnN0IHRpdGxlRWwgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5xdWVyeVNlbGVjdG9yKCd0aXRsZScpO1xuICAgICAgICAgICAgICAgIHdlYlZpZXcuZG9jdW1lbnRUaXRsZSA9IGluaXRpYWxUaXRsZTtcbiAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25UaXRsZUNoYW5nZWQnLCB2aWV3SWQsIFtpbml0aWFsVGl0bGVdKTtcbiAgICAgICAgICAgICAgICBpZiAodGl0bGVFbCAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgICBuZXcgTXV0YXRpb25PYnNlcnZlcihmdW5jdGlvbiAobXV0YXRpb25zKSB7XG4gICAgICAgICAgICAgICAgICAgIGNvbnN0IHRpdGxlID0gKG11dGF0aW9uc1swXS50YXJnZXQgYXMgSFRNTEVsZW1lbnQpLmlubmVyVGV4dDtcbiAgICAgICAgICAgICAgICAgICAgaWYgKHRpdGxlICE9IHdlYlZpZXcuZG9jdW1lbnRUaXRsZSkge1xuICAgICAgICAgICAgICAgICAgICAgIHdlYlZpZXcuZG9jdW1lbnRUaXRsZSA9IHRpdGxlO1xuICAgICAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvblRpdGxlQ2hhbmdlZCcsIHZpZXdJZCwgW3RpdGxlXSk7XG4gICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIH0pLm9ic2VydmUoXG4gICAgICAgICAgICAgICAgICAgICAgdGl0bGVFbCxcbiAgICAgICAgICAgICAgICAgICAgICB7c3VidHJlZTogdHJ1ZSwgY2hhcmFjdGVyRGF0YTogdHJ1ZSwgY2hpbGRMaXN0OiB0cnVlfVxuICAgICAgICAgICAgICAgICAgKTtcbiAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICBsZXQgb2xkUGl4ZWxSYXRpbyA9IGlmcmFtZS5jb250ZW50V2luZG93LmRldmljZVBpeGVsUmF0aW87XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuYWRkRXZlbnRMaXN0ZW5lcigncmVzaXplJywgZnVuY3Rpb24gKGUpIHtcbiAgICAgICAgICAgICAgICAgIGNvbnN0IG5ld1BpeGVsUmF0aW8gPSBpZnJhbWUuY29udGVudFdpbmRvdyEuZGV2aWNlUGl4ZWxSYXRpbztcbiAgICAgICAgICAgICAgICAgIGlmIChuZXdQaXhlbFJhdGlvICE9PSBvbGRQaXhlbFJhdGlvKSB7XG4gICAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvblpvb21TY2FsZUNoYW5nZWQnLCB2aWV3SWQsIFtvbGRQaXhlbFJhdGlvLCBuZXdQaXhlbFJhdGlvXSk7XG4gICAgICAgICAgICAgICAgICAgIG9sZFBpeGVsUmF0aW8gPSBuZXdQaXhlbFJhdGlvO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuYWRkRXZlbnRMaXN0ZW5lcigncG9wc3RhdGUnLCBmdW5jdGlvbiAoZXZlbnQ6IEV2ZW50KSB7XG4gICAgICAgICAgICAgICAgICBsZXQgaWZyYW1lVXJsID0gaWZyYW1lLnNyYztcbiAgICAgICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZVVybCA9IGlmcmFtZS5jb250ZW50V2luZG93IS5sb2NhdGlvbi5ocmVmO1xuICAgICAgICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvblVwZGF0ZVZpc2l0ZWRIaXN0b3J5Jywgdmlld0lkLCBbaWZyYW1lVXJsXSk7XG4gICAgICAgICAgICAgICAgfSk7XG5cbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5hZGRFdmVudExpc3RlbmVyKCdzY3JvbGwnLCBmdW5jdGlvbiAoZXZlbnQ6IEV2ZW50KSB7XG4gICAgICAgICAgICAgICAgICBsZXQgeCA9IDA7XG4gICAgICAgICAgICAgICAgICBsZXQgeSA9IDA7XG4gICAgICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgICAgICB4ID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLnNjcm9sbFg7XG4gICAgICAgICAgICAgICAgICAgIHkgPSBpZnJhbWUuY29udGVudFdpbmRvdyEuc2Nyb2xsWTtcbiAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25TY3JvbGxDaGFuZ2VkJywgdmlld0lkLCBbeCwgeV0pO1xuICAgICAgICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuYWRkRXZlbnRMaXN0ZW5lcignZm9jdXMnLCBmdW5jdGlvbiAoZXZlbnQ6IEV2ZW50KSB7XG4gICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25XaW5kb3dGb2N1cycsIHZpZXdJZCk7XG4gICAgICAgICAgICAgICAgfSk7XG5cbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5hZGRFdmVudExpc3RlbmVyKCdibHVyJywgZnVuY3Rpb24gKGV2ZW50OiBFdmVudCkge1xuICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uV2luZG93Qmx1cicsIHZpZXdJZCk7XG4gICAgICAgICAgICAgICAgfSk7XG4gICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgaWYgKCF3ZWJWaWV3LnNldHRpbmdzLmphdmFTY3JpcHRDYW5PcGVuV2luZG93c0F1dG9tYXRpY2FsbHkpIHtcbiAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93Lm9wZW4gPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgICAgIHRocm93IG5ldyBFcnJvcignSmF2YVNjcmlwdCBjYW5ub3Qgb3BlbiB3aW5kb3dzIGF1dG9tYXRpY2FsbHknKTtcbiAgICAgICAgICAgICAgICAgIH07XG4gICAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgICAgaWYgKCF3ZWJWaWV3LnNldHRpbmdzLnZlcnRpY2FsU2Nyb2xsQmFyRW5hYmxlZCAmJiAhd2ViVmlldy5zZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZCkge1xuICAgICAgICAgICAgICAgICAgY29uc3Qgc3R5bGUgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5jcmVhdGVFbGVtZW50KCdzdHlsZScpO1xuICAgICAgICAgICAgICAgICAgaWYgKHN0eWxlICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgICAgc3R5bGUuaWQgPSBcInNldHRpbmdzLnZlcnRpY2FsU2Nyb2xsQmFyRW5hYmxlZC1zZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZFwiO1xuICAgICAgICAgICAgICAgICAgICBzdHlsZS5pbm5lckhUTUwgPSBcImJvZHk6Oi13ZWJraXQtc2Nyb2xsYmFyIHsgd2lkdGg6IDBweDsgaGVpZ2h0OiAwcHg7IH1cIjtcbiAgICAgICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uaGVhZC5hcHBlbmQoc3R5bGUpO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICAgIGlmICh3ZWJWaWV3LnNldHRpbmdzLmRpc2FibGVWZXJ0aWNhbFNjcm9sbCkge1xuICAgICAgICAgICAgICAgICAgY29uc3Qgc3R5bGUgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5jcmVhdGVFbGVtZW50KCdzdHlsZScpO1xuICAgICAgICAgICAgICAgICAgaWYgKHN0eWxlICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgICAgc3R5bGUuaWQgPSBcInNldHRpbmdzLmRpc2FibGVWZXJ0aWNhbFNjcm9sbFwiO1xuICAgICAgICAgICAgICAgICAgICBzdHlsZS5pbm5lckhUTUwgPSBcImJvZHkgeyBvdmVyZmxvdy15OiBoaWRkZW47IH1cIjtcbiAgICAgICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uaGVhZC5hcHBlbmQoc3R5bGUpO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICAgIGlmICh3ZWJWaWV3LnNldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsKSB7XG4gICAgICAgICAgICAgICAgICBjb25zdCBzdHlsZSA9IGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmNyZWF0ZUVsZW1lbnQoJ3N0eWxlJyk7XG4gICAgICAgICAgICAgICAgICBpZiAoc3R5bGUgIT0gbnVsbCkge1xuICAgICAgICAgICAgICAgICAgICBzdHlsZS5pZCA9IFwic2V0dGluZ3MuZGlzYWJsZUhvcml6b250YWxTY3JvbGxcIjtcbiAgICAgICAgICAgICAgICAgICAgc3R5bGUuaW5uZXJIVE1MID0gXCJib2R5IHsgb3ZlcmZsb3cteDogaGlkZGVuOyB9XCI7XG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmhlYWQuYXBwZW5kKHN0eWxlKTtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy5kaXNhYmxlQ29udGV4dE1lbnUpIHtcbiAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ2NvbnRleHRtZW51Jywgd2ViVmlldy5kaXNhYmxlQ29udGV4dE1lbnVIYW5kbGVyKTtcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvbkxvYWRTdG9wJywgdmlld0lkLCBbdXJsXSk7XG5cbiAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5kaXNwYXRjaEV2ZW50KG5ldyBFdmVudCgnZmx1dHRlckluQXBwV2ViVmlld1BsYXRmb3JtUmVhZHknKSk7XG4gICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICB9KTtcbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIHNldFNldHRpbmdzOiBmdW5jdGlvbiAobmV3U2V0dGluZ3M6IEluQXBwV2ViVmlld1NldHRpbmdzKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgaWYgKGlmcmFtZSA9PSBudWxsKSB7XG4gICAgICAgICAgICByZXR1cm47XG4gICAgICAgICAgfVxuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy5qYXZhU2NyaXB0Q2FuT3BlbldpbmRvd3NBdXRvbWF0aWNhbGx5ICE9IG5ld1NldHRpbmdzLmphdmFTY3JpcHRDYW5PcGVuV2luZG93c0F1dG9tYXRpY2FsbHkpIHtcbiAgICAgICAgICAgICAgaWYgKCFuZXdTZXR0aW5ncy5qYXZhU2NyaXB0Q2FuT3BlbldpbmRvd3NBdXRvbWF0aWNhbGx5KSB7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3chLm9wZW4gPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgICB0aHJvdyBuZXcgRXJyb3IoJ0phdmFTY3JpcHQgY2Fubm90IG9wZW4gd2luZG93cyBhdXRvbWF0aWNhbGx5Jyk7XG4gICAgICAgICAgICAgICAgfTtcbiAgICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdyEub3BlbiA9IHdlYlZpZXcuZnVuY3Rpb25NYXBbXCJ3aW5kb3cub3BlblwiXTtcbiAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy52ZXJ0aWNhbFNjcm9sbEJhckVuYWJsZWQgIT0gbmV3U2V0dGluZ3MudmVydGljYWxTY3JvbGxCYXJFbmFibGVkICYmXG4gICAgICAgICAgICAgICAgd2ViVmlldy5zZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZCAhPSBuZXdTZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZCkge1xuICAgICAgICAgICAgICBpZiAoIW5ld1NldHRpbmdzLnZlcnRpY2FsU2Nyb2xsQmFyRW5hYmxlZCAmJiAhbmV3U2V0dGluZ3MuaG9yaXpvbnRhbFNjcm9sbEJhckVuYWJsZWQpIHtcbiAgICAgICAgICAgICAgICBjb25zdCBzdHlsZSA9IGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmNyZWF0ZUVsZW1lbnQoJ3N0eWxlJyk7XG4gICAgICAgICAgICAgICAgaWYgKHN0eWxlICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgIHN0eWxlLmlkID0gXCJzZXR0aW5ncy52ZXJ0aWNhbFNjcm9sbEJhckVuYWJsZWQtc2V0dGluZ3MuaG9yaXpvbnRhbFNjcm9sbEJhckVuYWJsZWRcIjtcbiAgICAgICAgICAgICAgICAgIHN0eWxlLmlubmVySFRNTCA9IFwiYm9keTo6LXdlYmtpdC1zY3JvbGxiYXIgeyB3aWR0aDogMHB4OyBoZWlnaHQ6IDBweDsgfVwiO1xuICAgICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uaGVhZC5hcHBlbmQoc3R5bGUpO1xuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgICBjb25zdCBzdHlsZUVsZW1lbnQgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5nZXRFbGVtZW50QnlJZChcInNldHRpbmdzLnZlcnRpY2FsU2Nyb2xsQmFyRW5hYmxlZC1zZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZFwiKTtcbiAgICAgICAgICAgICAgICBpZiAoc3R5bGVFbGVtZW50KSB7XG4gICAgICAgICAgICAgICAgICBzdHlsZUVsZW1lbnQucmVtb3ZlKClcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgaWYgKHdlYlZpZXcuc2V0dGluZ3MuZGlzYWJsZVZlcnRpY2FsU2Nyb2xsICE9IG5ld1NldHRpbmdzLmRpc2FibGVWZXJ0aWNhbFNjcm9sbCkge1xuICAgICAgICAgICAgICBpZiAobmV3U2V0dGluZ3MuZGlzYWJsZVZlcnRpY2FsU2Nyb2xsKSB7XG4gICAgICAgICAgICAgICAgY29uc3Qgc3R5bGUgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5jcmVhdGVFbGVtZW50KCdzdHlsZScpO1xuICAgICAgICAgICAgICAgIGlmIChzdHlsZSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgICBzdHlsZS5pZCA9IFwic2V0dGluZ3MuZGlzYWJsZVZlcnRpY2FsU2Nyb2xsXCI7XG4gICAgICAgICAgICAgICAgICBzdHlsZS5pbm5lckhUTUwgPSBcImJvZHkgeyBvdmVyZmxvdy15OiBoaWRkZW47IH1cIjtcbiAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmhlYWQuYXBwZW5kKHN0eWxlKTtcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICAgICAgY29uc3Qgc3R5bGVFbGVtZW50ID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uZ2V0RWxlbWVudEJ5SWQoXCJzZXR0aW5ncy5kaXNhYmxlVmVydGljYWxTY3JvbGxcIik7XG4gICAgICAgICAgICAgICAgaWYgKHN0eWxlRWxlbWVudCkge1xuICAgICAgICAgICAgICAgICAgc3R5bGVFbGVtZW50LnJlbW92ZSgpXG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG5cbiAgICAgICAgICAgIGlmICh3ZWJWaWV3LnNldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsICE9IG5ld1NldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsKSB7XG4gICAgICAgICAgICAgIGlmIChuZXdTZXR0aW5ncy5kaXNhYmxlSG9yaXpvbnRhbFNjcm9sbCkge1xuICAgICAgICAgICAgICAgIGNvbnN0IHN0eWxlID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uY3JlYXRlRWxlbWVudCgnc3R5bGUnKTtcbiAgICAgICAgICAgICAgICBpZiAoc3R5bGUgIT0gbnVsbCkge1xuICAgICAgICAgICAgICAgICAgc3R5bGUuaWQgPSBcInNldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsXCI7XG4gICAgICAgICAgICAgICAgICBzdHlsZS5pbm5lckhUTUwgPSBcImJvZHkgeyBvdmVyZmxvdy14OiBoaWRkZW47IH1cIjtcbiAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmhlYWQuYXBwZW5kKHN0eWxlKTtcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICAgICAgY29uc3Qgc3R5bGVFbGVtZW50ID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uZ2V0RWxlbWVudEJ5SWQoXCJzZXR0aW5ncy5kaXNhYmxlSG9yaXpvbnRhbFNjcm9sbFwiKTtcbiAgICAgICAgICAgICAgICBpZiAoc3R5bGVFbGVtZW50KSB7XG4gICAgICAgICAgICAgICAgICBzdHlsZUVsZW1lbnQucmVtb3ZlKClcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgaWYgKHdlYlZpZXcuc2V0dGluZ3MuZGlzYWJsZUNvbnRleHRNZW51ICE9IG5ld1NldHRpbmdzLmRpc2FibGVDb250ZXh0TWVudSkge1xuICAgICAgICAgICAgICBpZiAobmV3U2V0dGluZ3MuZGlzYWJsZUNvbnRleHRNZW51KSB7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3c/LmFkZEV2ZW50TGlzdGVuZXIoJ2NvbnRleHRtZW51Jywgd2ViVmlldy5kaXNhYmxlQ29udGV4dE1lbnVIYW5kbGVyKTtcbiAgICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdz8ucmVtb3ZlRXZlbnRMaXN0ZW5lcignY29udGV4dG1lbnUnLCB3ZWJWaWV3LmRpc2FibGVDb250ZXh0TWVudUhhbmRsZXIpO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuXG4gICAgICAgICAgd2ViVmlldy5zZXR0aW5ncyA9IG5ld1NldHRpbmdzO1xuICAgICAgICB9LFxuICAgICAgICByZWxvYWQ6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICB2YXIgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsICYmIGlmcmFtZS5jb250ZW50V2luZG93ICE9IG51bGwpIHtcbiAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmxvY2F0aW9uLnJlbG9hZCgpO1xuICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cubG9jYXRpb24uaHJlZiA9IGlmcmFtZS5zcmM7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBnb0JhY2s6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICB2YXIgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsKSB7XG4gICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdz8uaGlzdG9yeS5iYWNrKCk7XG4gICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgZ29Gb3J3YXJkOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgdmFyIGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIGlmIChpZnJhbWUgIT0gbnVsbCkge1xuICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3c/Lmhpc3RvcnkuZm9yd2FyZCgpO1xuICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIGdvQmFja09yRm9yd2FyZDogZnVuY3Rpb24gKHN0ZXBzKSB7XG4gICAgICAgICAgdmFyIGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIGlmIChpZnJhbWUgIT0gbnVsbCkge1xuICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3c/Lmhpc3RvcnkuZ28oc3RlcHMpO1xuICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIGV2YWx1YXRlSmF2YXNjcmlwdDogZnVuY3Rpb24gKHNvdXJjZSkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIGxldCByZXN1bHQgPSBudWxsO1xuICAgICAgICAgIGlmIChpZnJhbWUgIT0gbnVsbCkge1xuICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgcmVzdWx0ID0gSlNPTi5zdHJpbmdpZnkoaWZyYW1lLmNvbnRlbnRXaW5kb3c/LmV2YWwoc291cmNlKSk7XG4gICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiByZXN1bHQ7XG4gICAgICAgIH0sXG4gICAgICAgIHN0b3BMb2FkaW5nOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsKSB7XG4gICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdz8uc3RvcCgpO1xuICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIGdldFVybDogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIGxldCB1cmwgPSBpZnJhbWU/LnNyYztcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgdXJsID0gaWZyYW1lPy5jb250ZW50V2luZG93Py5sb2NhdGlvbi5ocmVmO1xuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4gdXJsO1xuICAgICAgICB9LFxuICAgICAgICBnZXRUaXRsZTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIGxldCB0aXRsZSA9IG51bGw7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIHRpdGxlID0gaWZyYW1lPy5jb250ZW50RG9jdW1lbnQ/LnRpdGxlO1xuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4gdGl0bGU7XG4gICAgICAgIH0sXG4gICAgICAgIGluamVjdEphdmFzY3JpcHRGaWxlRnJvbVVybDogZnVuY3Rpb24gKHVybEZpbGUsIHNjcmlwdEh0bWxUYWdBdHRyaWJ1dGVzKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIGNvbnN0IGQgPSBpZnJhbWU/LmNvbnRlbnREb2N1bWVudDtcbiAgICAgICAgICAgIGlmIChkID09IG51bGwpIHtcbiAgICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgY29uc3Qgc2NyaXB0ID0gZC5jcmVhdGVFbGVtZW50KCdzY3JpcHQnKTtcbiAgICAgICAgICAgIGZvciAoY29uc3Qga2V5IG9mIE9iamVjdC5rZXlzKHNjcmlwdEh0bWxUYWdBdHRyaWJ1dGVzKSkge1xuICAgICAgICAgICAgICBpZiAoc2NyaXB0SHRtbFRhZ0F0dHJpYnV0ZXNba2V5XSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgLy8gQHRzLWlnbm9yZVxuICAgICAgICAgICAgICAgIHNjcmlwdFtrZXldID0gc2NyaXB0SHRtbFRhZ0F0dHJpYnV0ZXNba2V5XTtcbiAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgfVxuICAgICAgICAgICAgaWYgKHNjcmlwdC5pZCAhPSBudWxsKSB7XG4gICAgICAgICAgICAgIHNjcmlwdC5vbmxvYWQgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uSW5qZWN0ZWRTY3JpcHRMb2FkZWQnLCB3ZWJWaWV3LnZpZXdJZCwgW3NjcmlwdC5pZF0pO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIHNjcmlwdC5vbmVycm9yID0gZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvbkluamVjdGVkU2NyaXB0RXJyb3InLCB3ZWJWaWV3LnZpZXdJZCwgW3NjcmlwdC5pZF0pO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBzY3JpcHQuc3JjID0gdXJsRmlsZTtcbiAgICAgICAgICAgIGlmIChkLmJvZHkgIT0gbnVsbCkge1xuICAgICAgICAgICAgICBkLmJvZHkuYXBwZW5kQ2hpbGQoc2NyaXB0KTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIGluamVjdENTU0NvZGU6IGZ1bmN0aW9uIChzb3VyY2UpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgY29uc3QgZCA9IGlmcmFtZT8uY29udGVudERvY3VtZW50O1xuICAgICAgICAgICAgaWYgKGQgPT0gbnVsbCkge1xuICAgICAgICAgICAgICByZXR1cm47XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBjb25zdCBzdHlsZSA9IGQuY3JlYXRlRWxlbWVudCgnc3R5bGUnKTtcbiAgICAgICAgICAgIHN0eWxlLmlubmVySFRNTCA9IHNvdXJjZTtcbiAgICAgICAgICAgIGlmIChkLmhlYWQgIT0gbnVsbCkge1xuICAgICAgICAgICAgICBkLmhlYWQuYXBwZW5kQ2hpbGQoc3R5bGUpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgaW5qZWN0Q1NTRmlsZUZyb21Vcmw6IGZ1bmN0aW9uICh1cmxGaWxlLCBjc3NMaW5rSHRtbFRhZ0F0dHJpYnV0ZXMpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgY29uc3QgZCA9IGlmcmFtZT8uY29udGVudERvY3VtZW50O1xuICAgICAgICAgICAgaWYgKGQgPT0gbnVsbCkge1xuICAgICAgICAgICAgICByZXR1cm47XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBjb25zdCBsaW5rID0gZC5jcmVhdGVFbGVtZW50KCdsaW5rJyk7XG4gICAgICAgICAgICBmb3IgKGNvbnN0IGtleSBvZiBPYmplY3Qua2V5cyhjc3NMaW5rSHRtbFRhZ0F0dHJpYnV0ZXMpKSB7XG4gICAgICAgICAgICAgIGlmIChjc3NMaW5rSHRtbFRhZ0F0dHJpYnV0ZXNba2V5XSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgLy8gQHRzLWlnbm9yZVxuICAgICAgICAgICAgICAgIGxpbmtba2V5XSA9IGNzc0xpbmtIdG1sVGFnQXR0cmlidXRlc1trZXldO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBsaW5rLnR5cGUgPSAndGV4dC9jc3MnO1xuICAgICAgICAgICAgdmFyIGFsdGVybmF0ZVN0eWxlc2hlZXQgPSBcIlwiO1xuICAgICAgICAgICAgaWYgKGNzc0xpbmtIdG1sVGFnQXR0cmlidXRlcy5hbHRlcm5hdGVTdHlsZXNoZWV0KSB7XG4gICAgICAgICAgICAgIGFsdGVybmF0ZVN0eWxlc2hlZXQgPSBcImFsdGVybmF0ZSBcIjtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGxpbmsucmVsID0gYWx0ZXJuYXRlU3R5bGVzaGVldCArIFwic3R5bGVzaGVldFwiO1xuICAgICAgICAgICAgbGluay5ocmVmID0gdXJsRmlsZTtcbiAgICAgICAgICAgIGlmIChkLmhlYWQgIT0gbnVsbCkge1xuICAgICAgICAgICAgICBkLmhlYWQuYXBwZW5kQ2hpbGQobGluayk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBzY3JvbGxUbzogZnVuY3Rpb24gKHgsIHksIGFuaW1hdGVkKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIGlmIChhbmltYXRlZCkge1xuICAgICAgICAgICAgICBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LnNjcm9sbFRvKHt0b3A6IHksIGxlZnQ6IHgsIGJlaGF2aW9yOiAnc21vb3RoJ30pO1xuICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgaWZyYW1lPy5jb250ZW50V2luZG93Py5zY3JvbGxUbyh4LCB5KTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIHNjcm9sbEJ5OiBmdW5jdGlvbiAoeCwgeSwgYW5pbWF0ZWQpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgaWYgKGFuaW1hdGVkKSB7XG4gICAgICAgICAgICAgIGlmcmFtZT8uY29udGVudFdpbmRvdz8uc2Nyb2xsQnkoe3RvcDogeSwgbGVmdDogeCwgYmVoYXZpb3I6ICdzbW9vdGgnfSk7XG4gICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LnNjcm9sbEJ5KHgsIHkpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgcHJpbnRDdXJyZW50UGFnZTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LnByaW50KCk7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBnZXRDb250ZW50SGVpZ2h0OiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIHJldHVybiBpZnJhbWU/LmNvbnRlbnREb2N1bWVudD8uZG9jdW1lbnRFbGVtZW50LnNjcm9sbEhlaWdodDtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgIH0sXG4gICAgICAgIGdldENvbnRlbnRXaWR0aDogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICByZXR1cm4gaWZyYW1lPy5jb250ZW50RG9jdW1lbnQ/LmRvY3VtZW50RWxlbWVudC5zY3JvbGxXaWR0aDtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgIH0sXG4gICAgICAgIGdldFNlbGVjdGVkVGV4dDogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICBsZXQgdHh0O1xuICAgICAgICAgICAgY29uc3QgdyA9IGlmcmFtZT8uY29udGVudFdpbmRvdztcbiAgICAgICAgICAgIGlmICh3ID09IG51bGwpIHtcbiAgICAgICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBpZiAody5nZXRTZWxlY3Rpb24pIHtcbiAgICAgICAgICAgICAgdHh0ID0gdy5nZXRTZWxlY3Rpb24oKT8udG9TdHJpbmcoKTtcbiAgICAgICAgICAgIH0gZWxzZSBpZiAody5kb2N1bWVudC5nZXRTZWxlY3Rpb24pIHtcbiAgICAgICAgICAgICAgdHh0ID0gdy5kb2N1bWVudC5nZXRTZWxlY3Rpb24oKT8udG9TdHJpbmcoKTtcbiAgICAgICAgICAgICAgLy8gQHRzLWlnbm9yZVxuICAgICAgICAgICAgfSBlbHNlIGlmICh3LmRvY3VtZW50LnNlbGVjdGlvbikge1xuICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICAgIHR4dCA9IHcuZG9jdW1lbnQuc2VsZWN0aW9uLmNyZWF0ZVJhbmdlKCkudGV4dDtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIHJldHVybiB0eHQ7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiBudWxsO1xuICAgICAgICB9LFxuICAgICAgICBnZXRTY3JvbGxYOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIHJldHVybiBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LnNjcm9sbFg7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiBudWxsO1xuICAgICAgICB9LFxuICAgICAgICBnZXRTY3JvbGxZOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIHJldHVybiBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LnNjcm9sbFk7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiBudWxsO1xuICAgICAgICB9LFxuICAgICAgICBpc1NlY3VyZUNvbnRleHQ6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgcmV0dXJuIGlmcmFtZT8uY29udGVudFdpbmRvdz8uaXNTZWN1cmVDb250ZXh0ID8/IGZhbHNlO1xuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4gZmFsc2U7XG4gICAgICAgIH0sXG4gICAgICAgIGNhblNjcm9sbFZlcnRpY2FsbHk6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgcmV0dXJuIChpZnJhbWU/LmNvbnRlbnREb2N1bWVudD8uYm9keS5zY3JvbGxIZWlnaHQgPz8gMCkgPiAoaWZyYW1lPy5jb250ZW50V2luZG93Py5pbm5lckhlaWdodCA/PyAwKTtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgICAgICB9LFxuICAgICAgICBjYW5TY3JvbGxIb3Jpem9udGFsbHk6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgcmV0dXJuIChpZnJhbWU/LmNvbnRlbnREb2N1bWVudD8uYm9keS5zY3JvbGxXaWR0aCA/PyAwKSA+IChpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LmlubmVyV2lkdGggPz8gMCk7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgICAgfSxcbiAgICAgICAgZ2V0U2l6ZTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZUNvbnRhaW5lciA9IHdlYlZpZXcuaWZyYW1lQ29udGFpbmVyO1xuICAgICAgICAgIGxldCB3aWR0aCA9IDAuMDtcbiAgICAgICAgICBsZXQgaGVpZ2h0ID0gMC4wO1xuICAgICAgICAgIGlmIChpZnJhbWVDb250YWluZXIgIT0gbnVsbCkge1xuICAgICAgICAgICAgaWYgKGlmcmFtZUNvbnRhaW5lci5zdHlsZS53aWR0aCAhPSBudWxsICYmIGlmcmFtZUNvbnRhaW5lci5zdHlsZS53aWR0aCAhPSAnJyAmJiBpZnJhbWVDb250YWluZXIuc3R5bGUud2lkdGguaW5kZXhPZigncHgnKSA+IDApIHtcbiAgICAgICAgICAgICAgd2lkdGggPSBwYXJzZUZsb2F0KGlmcmFtZUNvbnRhaW5lci5zdHlsZS53aWR0aCk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBpZiAod2lkdGggPT0gbnVsbCB8fCB3aWR0aCA9PSAwLjApIHtcbiAgICAgICAgICAgICAgd2lkdGggPSBpZnJhbWVDb250YWluZXIuZ2V0Qm91bmRpbmdDbGllbnRSZWN0KCkud2lkdGg7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBpZiAoaWZyYW1lQ29udGFpbmVyLnN0eWxlLmhlaWdodCAhPSBudWxsICYmIGlmcmFtZUNvbnRhaW5lci5zdHlsZS5oZWlnaHQgIT0gJycgJiYgaWZyYW1lQ29udGFpbmVyLnN0eWxlLmhlaWdodC5pbmRleE9mKCdweCcpID4gMCkge1xuICAgICAgICAgICAgICBoZWlnaHQgPSBwYXJzZUZsb2F0KGlmcmFtZUNvbnRhaW5lci5zdHlsZS5oZWlnaHQpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgaWYgKGhlaWdodCA9PSBudWxsIHx8IGhlaWdodCA9PSAwLjApIHtcbiAgICAgICAgICAgICAgaGVpZ2h0ID0gaWZyYW1lQ29udGFpbmVyLmdldEJvdW5kaW5nQ2xpZW50UmVjdCgpLmhlaWdodDtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIHtcbiAgICAgICAgICAgIHdpZHRoOiB3aWR0aCxcbiAgICAgICAgICAgIGhlaWdodDogaGVpZ2h0XG4gICAgICAgICAgfTtcbiAgICAgICAgfVxuICAgICAgfTtcblxuICAgICAgcmV0dXJuIHdlYlZpZXc7XG4gICAgfSxcbiAgICBnZXRDb29raWVFeHBpcmF0aW9uRGF0ZTogZnVuY3Rpb24gKHRpbWVzdGFtcDogbnVtYmVyKSB7XG4gICAgICByZXR1cm4gKG5ldyBEYXRlKHRpbWVzdGFtcCkpLnRvVVRDU3RyaW5nKCk7XG4gICAgfSxcbiAgICBuYXRpdmVBc3luY0NvbW11bmljYXRpb246IGZ1bmN0aW9uIChtZXRob2Q6IHN0cmluZywgdmlld0lkOiBudW1iZXIgfCBzdHJpbmcsIGFyZ3M/OiBhbnlbXSkge1xuICAgICAgdGhyb3cgbmV3IEVycm9yKFwiTWV0aG9kIG5vdCBpbXBsZW1lbnRlZC5cIik7XG4gICAgfSxcbiAgICBuYXRpdmVTeW5jQ29tbXVuaWNhdGlvbjogZnVuY3Rpb24gKG1ldGhvZDogc3RyaW5nLCB2aWV3SWQ6IG51bWJlciB8IHN0cmluZywgYXJncz86IGFueVtdKSB7XG4gICAgICB0aHJvdyBuZXcgRXJyb3IoXCJNZXRob2Qgbm90IGltcGxlbWVudGVkLlwiKTtcbiAgICB9LFxuICAgIG5hdGl2ZUNvbW11bmljYXRpb246IGZ1bmN0aW9uIChtZXRob2Q6IHN0cmluZywgdmlld0lkOiBudW1iZXIgfCBzdHJpbmcsIGFyZ3M/OiBhbnlbXSkge1xuICAgICAgdHJ5IHtcbiAgICAgICAgY29uc3QgcmVzdWx0ID0gd2luZG93LmZsdXR0ZXJfaW5hcHB3ZWJ2aWV3X3BsdWdpbi5uYXRpdmVTeW5jQ29tbXVuaWNhdGlvbihtZXRob2QsIHZpZXdJZCwgYXJncyk7XG4gICAgICAgIHJldHVybiByZXN1bHQgIT0gbnVsbCA/IEpTT04ucGFyc2UocmVzdWx0KSA6IG51bGw7XG4gICAgICB9IGNhdGNoIChlMSkge1xuICAgICAgICB0cnkge1xuICAgICAgICAgIGNvbnN0IHByb21pc2UgPSB3aW5kb3cuZmx1dHRlcl9pbmFwcHdlYnZpZXdfcGx1Z2luLm5hdGl2ZUFzeW5jQ29tbXVuaWNhdGlvbihtZXRob2QsIHZpZXdJZCwgYXJncyk7XG4gICAgICAgICAgcmV0dXJuIHByb21pc2UudGhlbihmdW5jdGlvbiAocmVzdWx0KSB7XG4gICAgICAgICAgICByZXR1cm4gcmVzdWx0ICE9IG51bGwgPyBKU09OLnBhcnNlKHJlc3VsdCkgOiBudWxsO1xuICAgICAgICAgIH0pO1xuICAgICAgICB9IGNhdGNoIChlMikge1xuICAgICAgICAgIHJldHVybiBudWxsO1xuICAgICAgICB9XG4gICAgICB9XG4gICAgfSxcbiAgfTtcblxuICBsZXQgX25hdGl2ZUNvbW11bmljYXRpb24gPSB3aW5kb3cuZmx1dHRlcl9pbmFwcHdlYnZpZXdfcGx1Z2luLm5hdGl2ZUNvbW11bmljYXRpb247XG59KSgpOyJdLAogICJtYXBwaW5ncyI6ICI7Q0FtQkMsV0FBWTtBQUNYLE1BQUksa0JBQWtCLE9BQU8sS0FBSztBQUNsQyxNQUFJLGVBQWUsT0FBTyxNQUFNLFVBQVU7QUFDMUMsZUFBYSxPQUFPLE9BQU8sU0FBUyxVQUFVO0FBRTlDLFNBQU8sOEJBQThCO0FBQUEsSUFDbkMsMkJBQTJCLFNBQVUsUUFBeUIsUUFBMkIsaUJBQWlDLGNBQXNCO0FBQzlJLFlBQU0sV0FBVyxPQUFPO0FBQ3hCLFlBQU0sVUFBd0I7QUFBQSxRQUM1QjtBQUFBLFFBQ0E7QUFBQSxRQUNBLFFBQVE7QUFBQSxRQUNSLGlCQUFpQjtBQUFBLFFBQ2pCLGNBQWM7QUFBQSxRQUNkLGVBQWU7QUFBQSxRQUNmLGFBQWEsQ0FBQztBQUFBLFFBQ2QsVUFBVSxDQUFDO0FBQUEsUUFDWCx5QkFBeUI7QUFBQSxRQUN6QiwyQkFBMkIsU0FBVSxPQUFjO0FBQ2pELGdCQUFNLGVBQWU7QUFDckIsZ0JBQU0sZ0JBQWdCO0FBQ3RCLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsU0FBUyxTQUFVLFVBQWdDO0FBQ2pELGtCQUFRLFdBQVc7QUFFbkIsa0JBQVEsMEJBQTBCLFFBQVEsU0FBUywyQkFBMkI7QUFDOUUsZ0JBQU0sa0NBQWtDLFFBQVEsU0FBUztBQUN6RCxjQUFJLG1DQUFtQyxRQUFRLENBQUMsZ0NBQWdDLFNBQVMsR0FBRyxHQUFHO0FBQzdGLGdCQUFJLGdDQUFnQyxXQUFXLEdBQUc7QUFFaEQsc0JBQVEsMEJBQTBCO0FBQUEsWUFDcEM7QUFBQSxVQUNGO0FBRUEsbUJBQVMsaUJBQWlCLG9CQUFvQixTQUFVLE9BQWM7QUFJcEUsZ0JBQUksU0FBUyxxQkFBcUIsU0FBUyxrQkFBa0IsTUFBTSxVQUFVO0FBQzNFLHNCQUFRLGVB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
