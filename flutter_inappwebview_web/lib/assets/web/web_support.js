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
        listenerAbortController: new AbortController(),
        dispose: function() {
          webView.listenerAbortController.abort();
          webView.iframe = null;
          webView.iframeContainer = null;
          webView.functionMap = {};
        },
        disableContextMenuHandler: function(event) {
          event.preventDefault();
          event.stopPropagation();
          return false;
        },
        prepare: function(settings) {
          webView.listenerAbortController.abort();
          webView.listenerAbortController = new AbortController();
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
          }, { signal: webView.listenerAbortController.signal });
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
            }, { signal: webView.listenerAbortController.signal });
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
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vLi4vLi4vLi4vd2ViX3N1cHBvcnQvc3JjL2luZGV4LnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQge1xuICBJbkFwcFdlYlZpZXcsXG4gIEluQXBwV2ViVmlld1BsdWdpbixcbiAgSW5BcHBXZWJWaWV3U2V0dGluZ3MsXG4gIEphdmFTY3JpcHRCcmlkZ2VIYW5kbGVyLFxuICBVc2VyU2NyaXB0LFxuICBVc2VyU2NyaXB0SW5qZWN0aW9uVGltZVxufSBmcm9tIFwiLi90eXBlc1wiO1xuXG5kZWNsYXJlIGdsb2JhbCB7XG4gIGludGVyZmFjZSBXaW5kb3cge1xuICAgIGZsdXR0ZXJfaW5hcHB3ZWJ2aWV3X3BsdWdpbjogSW5BcHBXZWJWaWV3UGx1Z2luO1xuICAgIGZsdXR0ZXJfaW5hcHB3ZWJ2aWV3PzogSmF2YVNjcmlwdEJyaWRnZUhhbmRsZXIgfCBudWxsO1xuICAgIGNvbnNvbGU6IENvbnNvbGU7XG5cbiAgICBldmFsKHg6IHN0cmluZyk6IGFueTtcbiAgfVxufVxuXG4oZnVuY3Rpb24gKCkge1xuICBsZXQgX0pTT05fc3RyaW5naWZ5ID0gd2luZG93LkpTT04uc3RyaW5naWZ5O1xuICBsZXQgX0FycmF5X3NsaWNlID0gd2luZG93LkFycmF5LnByb3RvdHlwZS5zbGljZTtcbiAgX0FycmF5X3NsaWNlLmNhbGwgPSB3aW5kb3cuRnVuY3Rpb24ucHJvdG90eXBlLmNhbGw7XG5cbiAgd2luZG93LmZsdXR0ZXJfaW5hcHB3ZWJ2aWV3X3BsdWdpbiA9IHtcbiAgICBjcmVhdGVGbHV0dGVySW5BcHBXZWJWaWV3OiBmdW5jdGlvbiAodmlld0lkOiBudW1iZXIgfCBzdHJpbmcsIGlmcmFtZTogSFRNTElGcmFtZUVsZW1lbnQsIGlmcmFtZUNvbnRhaW5lcjogSFRNTERpdkVsZW1lbnQsIGJyaWRnZVNlY3JldDogc3RyaW5nKSB7XG4gICAgICBjb25zdCBpZnJhbWVJZCA9IGlmcmFtZS5pZDtcbiAgICAgIGNvbnN0IHdlYlZpZXc6IEluQXBwV2ViVmlldyA9IHtcbiAgICAgICAgdmlld0lkOiB2aWV3SWQsXG4gICAgICAgIGlmcmFtZUlkOiBpZnJhbWVJZCxcbiAgICAgICAgaWZyYW1lOiBudWxsLFxuICAgICAgICBpZnJhbWVDb250YWluZXI6IG51bGwsXG4gICAgICAgIGlzRnVsbHNjcmVlbjogZmFsc2UsXG4gICAgICAgIGRvY3VtZW50VGl0bGU6IG51bGwsXG4gICAgICAgIGZ1bmN0aW9uTWFwOiB7fSxcbiAgICAgICAgc2V0dGluZ3M6IHt9LFxuICAgICAgICBqYXZhU2NyaXB0QnJpZGdlRW5hYmxlZDogdHJ1ZSxcbiAgICAgICAgbGlzdGVuZXJBYm9ydENvbnRyb2xsZXI6IG5ldyBBYm9ydENvbnRyb2xsZXIoKSxcbiAgICAgICAgZGlzcG9zZTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIC8vIFRoZSBkb2N1bWVudCBsaXN0ZW5lciBvdGhlcndpc2UgcmV0YWlucyB0aGUgV2ViVmlldyBhbmQgaXRzIGlmcmFtZS5cbiAgICAgICAgICB3ZWJWaWV3Lmxpc3RlbmVyQWJvcnRDb250cm9sbGVyLmFib3J0KCk7XG4gICAgICAgICAgd2ViVmlldy5pZnJhbWUgPSBudWxsO1xuICAgICAgICAgIHdlYlZpZXcuaWZyYW1lQ29udGFpbmVyID0gbnVsbDtcbiAgICAgICAgICB3ZWJWaWV3LmZ1bmN0aW9uTWFwID0ge307XG4gICAgICAgIH0sXG4gICAgICAgIGRpc2FibGVDb250ZXh0TWVudUhhbmRsZXI6IGZ1bmN0aW9uIChldmVudDogRXZlbnQpIHtcbiAgICAgICAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpO1xuICAgICAgICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpO1xuICAgICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgICAgfSxcbiAgICAgICAgcHJlcGFyZTogZnVuY3Rpb24gKHNldHRpbmdzOiBJbkFwcFdlYlZpZXdTZXR0aW5ncykge1xuICAgICAgICAgIC8vIFJlLXByZXBhcmluZyBhIHZpZXcgcmVwbGFjZXMgaXRzIGxpc3RlbmVycyBpbnN0ZWFkIG9mIGFkZGluZyBjb3BpZXMuXG4gICAgICAgICAgd2ViVmlldy5saXN0ZW5lckFib3J0Q29udHJvbGxlci5hYm9ydCgpO1xuICAgICAgICAgIHdlYlZpZXcubGlzdGVuZXJBYm9ydENvbnRyb2xsZXIgPSBuZXcgQWJvcnRDb250cm9sbGVyKCk7XG4gICAgICAgICAgd2ViVmlldy5zZXR0aW5ncyA9IHNldHRpbmdzO1xuXG4gICAgICAgICAgd2ViVmlldy5qYXZhU2NyaXB0QnJpZGdlRW5hYmxlZCA9IHdlYlZpZXcuc2V0dGluZ3MuamF2YVNjcmlwdEJyaWRnZUVuYWJsZWQgPz8gdHJ1ZTtcbiAgICAgICAgICBjb25zdCBqYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0ID0gd2ViVmlldy5zZXR0aW5ncy5qYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0O1xuICAgICAgICAgIGlmIChqYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0ICE9IG51bGwgJiYgIWphdmFTY3JpcHRCcmlkZ2VPcmlnaW5BbGxvd0xpc3QuaW5jbHVkZXMoXCIqXCIpKSB7XG4gICAgICAgICAgICBpZiAoamF2YVNjcmlwdEJyaWRnZU9yaWdpbkFsbG93TGlzdC5sZW5ndGggPT09IDApIHtcbiAgICAgICAgICAgICAgLy8gYW4gZW1wdHkgbGlzdCBtZWFucyB0aGF0IHRoZSBKYXZhU2NyaXB0IEJyaWRnZSBpcyBub3QgYWxsb3dlZCBmb3IgYW55IG9yaWdpbi5cbiAgICAgICAgICAgICAgd2ViVmlldy5qYXZhU2NyaXB0QnJpZGdlRW5hYmxlZCA9IGZhbHNlO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cblxuICAgICAgICAgIGRvY3VtZW50LmFkZEV2ZW50TGlzdGVuZXIoJ2Z1bGxzY3JlZW5jaGFuZ2UnLCBmdW5jdGlvbiAoZXZlbnQ6IEV2ZW50KSB7XG4gICAgICAgICAgICAvLyBkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudCB3aWxsIHBvaW50IHRvIHRoZSBlbGVtZW50IHRoYXRcbiAgICAgICAgICAgIC8vIGlzIGluIGZ1bGxzY3JlZW4gbW9kZSBpZiB0aGVyZSBpcyBvbmUuIElmIHRoZXJlIGlzbid0IG9uZSxcbiAgICAgICAgICAgIC8vIHRoZSB2YWx1ZSBvZiB0aGUgcHJvcGVydHkgaXMgbnVsbC5cbiAgICAgICAgICAgIGlmIChkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudCAmJiBkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudC5pZCA9PSBpZnJhbWVJZCkge1xuICAgICAgICAgICAgICB3ZWJWaWV3LmlzRnVsbHNjcmVlbiA9IHRydWU7XG4gICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvbkVudGVyRnVsbHNjcmVlbicsIHZpZXdJZCk7XG4gICAgICAgICAgICB9IGVsc2UgaWYgKCFkb2N1bWVudC5mdWxsc2NyZWVuRWxlbWVudCAmJiB3ZWJWaWV3LmlzRnVsbHNjcmVlbikge1xuICAgICAgICAgICAgICB3ZWJWaWV3LmlzRnVsbHNjcmVlbiA9IGZhbHNlO1xuICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25FeGl0RnVsbHNjcmVlbicsIHZpZXdJZCk7XG4gICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICB3ZWJWaWV3LmlzRnVsbHNjcmVlbiA9IGZhbHNlO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0sIHsgc2lnbmFsOiB3ZWJWaWV3Lmxpc3RlbmVyQWJvcnRDb250cm9sbGVyLnNpZ25hbCB9KTtcblxuICAgICAgICAgIGlmIChpZnJhbWUgIT0gbnVsbCkge1xuICAgICAgICAgICAgd2ViVmlldy5pZnJhbWUgPSBpZnJhbWU7XG4gICAgICAgICAgICB3ZWJWaWV3LmlmcmFtZUNvbnRhaW5lciA9IGlmcmFtZUNvbnRhaW5lcjtcbiAgICAgICAgICAgIGlmcmFtZS5hZGRFdmVudExpc3RlbmVyKCdsb2FkJywgZnVuY3Rpb24gKGV2ZW50OiBFdmVudCkge1xuICAgICAgICAgICAgICBpZiAoaWZyYW1lLmNvbnRlbnRXaW5kb3cgPT0gbnVsbCkge1xuICAgICAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIGNvbnN0IHVzZXJTY3JpcHRzQXRTdGFydCA9IF9uYXRpdmVDb21tdW5pY2F0aW9uPFVzZXJTY3JpcHRbXT4oJ2dldFVzZXJPbmx5U2NyaXB0c0F0Jywgdmlld0lkLCBbVXNlclNjcmlwdEluamVjdGlvblRpbWUuQVRfRE9DVU1FTlRfU1RBUlRdKTtcbiAgICAgICAgICAgICAgY29uc3QgdXNlclNjcmlwdHNBdEVuZCA9IF9uYXRpdmVDb21tdW5pY2F0aW9uPFVzZXJTY3JpcHRbXT4oJ2dldFVzZXJPbmx5U2NyaXB0c0F0Jywgdmlld0lkLCBbVXNlclNjcmlwdEluamVjdGlvblRpbWUuQVRfRE9DVU1FTlRfRU5EXSk7XG5cbiAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICBsZXQgamF2YVNjcmlwdEJyaWRnZUVuYWJsZWQgPSB3ZWJWaWV3LmphdmFTY3JpcHRCcmlkZ2VFbmFibGVkO1xuICAgICAgICAgICAgICAgIGlmIChqYXZhU2NyaXB0QnJpZGdlT3JpZ2luQWxsb3dMaXN0ICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgIGphdmFTY3JpcHRCcmlkZ2VFbmFibGVkID0gamF2YVNjcmlwdEJyaWRnZU9yaWdpbkFsbG93TGlzdFxuICAgICAgICAgICAgICAgICAgICAgIC5tYXAoYWxsb3dlZE9yaWdpblJ1bGUgPT4gbmV3IFJlZ0V4cChhbGxvd2VkT3JpZ2luUnVsZSkpXG4gICAgICAgICAgICAgICAgICAgICAgLnNvbWUoKHJ4KSA9PiB7XG4gICAgICAgICAgICAgICAgICAgICAgICByZXR1cm4gcngudGVzdChpZnJhbWUuY29udGVudFdpbmRvdyEubG9jYXRpb24ub3JpZ2luKTtcbiAgICAgICAgICAgICAgICAgICAgICB9KVxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICBpZiAoamF2YVNjcmlwdEJyaWRnZUVuYWJsZWQpIHtcbiAgICAgICAgICAgICAgICAgIGNvbnN0IGphdmFTY3JpcHRCcmlkZ2VOYW1lID0gX25hdGl2ZUNvbW11bmljYXRpb248c3RyaW5nPignZ2V0SmF2YVNjcmlwdEJyaWRnZU5hbWUnLCB2aWV3SWQpO1xuICAgICAgICAgICAgICAgICAgLy8gQHRzLWlnbm9yZVxuICAgICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3chW2phdmFTY3JpcHRCcmlkZ2VOYW1lXSA9IHtcbiAgICAgICAgICAgICAgICAgICAgY2FsbEhhbmRsZXI6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgICAgICAgICAgICBsZXQgb3JpZ2luID0gJyc7XG4gICAgICAgICAgICAgICAgICAgICAgbGV0IHJlcXVlc3RVcmwgPSAnJztcbiAgICAgICAgICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgICAgICAgICAgb3JpZ2luID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLmxvY2F0aW9uLm9yaWdpbjtcbiAgICAgICAgICAgICAgICAgICAgICB9IGNhdGNoIChfKSB7XG4gICAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgICAgICAgICByZXF1ZXN0VXJsID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLmxvY2F0aW9uLmhyZWY7XG4gICAgICAgICAgICAgICAgICAgICAgfSBjYXRjaCAoXykge1xuICAgICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgICAgICByZXR1cm4gX25hdGl2ZUNvbW11bmljYXRpb24oJ29uQ2FsbEpzSGFuZGxlcicsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIHZpZXdJZCxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgW2FyZ3VtZW50c1swXSwgX0pTT05fc3RyaW5naWZ5KHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAnb3JpZ2luJzogb3JpZ2luLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICdyZXF1ZXN0VXJsJzogcmVxdWVzdFVybCxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAnaXNNYWluRnJhbWUnOiB0cnVlLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICdfYnJpZGdlU2VjcmV0JzogYnJpZGdlU2VjcmV0LFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICdhcmdzJzogX0pTT05fc3RyaW5naWZ5KF9BcnJheV9zbGljZS5jYWxsKGFyZ3VtZW50cywgMSkpXG4gICAgICAgICAgICAgICAgICAgICAgICAgIH0pXSk7XG4gICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIH0gYXMgSmF2YVNjcmlwdEJyaWRnZUhhbmRsZXI7XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICBmb3IgKGNvbnN0IHVzZXJTY3JpcHQgb2YgWy4uLnVzZXJTY3JpcHRzQXRTdGFydCwgLi4udXNlclNjcmlwdHNBdEVuZF0pIHtcbiAgICAgICAgICAgICAgICBsZXQgaWZTdGF0ZW1lbnQgPSBcImlmIChcIjtcbiAgICAgICAgICAgICAgICBsZXQgc291cmNlID0gdXNlclNjcmlwdC5zb3VyY2U7XG4gICAgICAgICAgICAgICAgaWYgKHVzZXJTY3JpcHQuYWxsb3dlZE9yaWdpblJ1bGVzICE9IG51bGwgJiYgIXVzZXJTY3JpcHQuYWxsb3dlZE9yaWdpblJ1bGVzLmluY2x1ZGVzKFwiKlwiKSkge1xuICAgICAgICAgICAgICAgICAgaWYgKHVzZXJTY3JpcHQuYWxsb3dlZE9yaWdpblJ1bGVzLmxlbmd0aCA9PT0gMCkge1xuICAgICAgICAgICAgICAgICAgICAvLyByZXR1cm4gZW1wdHkgc291cmNlIHN0cmluZyBpZiBhbGxvd2VkT3JpZ2luUnVsZXMgaXMgYW4gZW1wdHkgbGlzdC5cbiAgICAgICAgICAgICAgICAgICAgLy8gYW4gZW1wdHkgbGlzdCBtZWFucyB0aGF0IHRoaXMgVXNlclNjcmlwdCBpcyBub3QgYWxsb3dlZCBmb3IgYW55IG9yaWdpbi5cbiAgICAgICAgICAgICAgICAgICAgc291cmNlID0gXCJcIjtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIGxldCBqc1JlZ0V4cEFycmF5ID0gXCJbXCI7XG4gICAgICAgICAgICAgICAgICBmb3IgKGNvbnN0IGFsbG93ZWRPcmlnaW5SdWxlIG9mIHVzZXJTY3JpcHQuYWxsb3dlZE9yaWdpblJ1bGVzKSB7XG4gICAgICAgICAgICAgICAgICAgIGlmIChqc1JlZ0V4cEFycmF5Lmxlbmd0aCA+IDEpIHtcbiAgICAgICAgICAgICAgICAgICAgICBqc1JlZ0V4cEFycmF5ICs9IFwiLFwiO1xuICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICAgIGpzUmVnRXhwQXJyYXkgKz0gYG5ldyBSZWdFeHAoJyR7YWxsb3dlZE9yaWdpblJ1bGUucmVwbGFjZShcIlxcJ1wiLCBcIlxcXFwnXCIpfScpYDtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIGlmIChqc1JlZ0V4cEFycmF5Lmxlbmd0aCA+IDEpIHtcbiAgICAgICAgICAgICAgICAgICAganNSZWdFeHBBcnJheSArPSBcIl1cIjtcbiAgICAgICAgICAgICAgICAgICAgaWZTdGF0ZW1lbnQgKz0gYCR7anNSZWdFeHBBcnJheX0uc29tZShmdW5jdGlvbihyeCkgeyByZXR1cm4gcngudGVzdCh3aW5kb3cubG9jYXRpb24ub3JpZ2luKTsgfSlgO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICB3ZWJWaWV3LmV2YWx1YXRlSmF2YXNjcmlwdChpZlN0YXRlbWVudC5sZW5ndGggPiA0ID8gYCR7aWZTdGF0ZW1lbnR9KSB7ICR7c291cmNlfSB9YCA6IHNvdXJjZSk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICBsZXQgdXJsID0gaWZyYW1lLnNyYztcbiAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICB1cmwgPSBpZnJhbWUuY29udGVudFdpbmRvdy5sb2NhdGlvbi5ocmVmO1xuICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uTG9hZFN0YXJ0Jywgdmlld0lkLCBbdXJsXSk7XG5cbiAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICBjb25zdCBvbGRMb2dzID0ge1xuICAgICAgICAgICAgICAgICAgJ2xvZyc6IGlmcmFtZS5jb250ZW50V2luZG93LmNvbnNvbGUubG9nLFxuICAgICAgICAgICAgICAgICAgJ2RlYnVnJzogaWZyYW1lLmNvbnRlbnRXaW5kb3cuY29uc29sZS5kZWJ1ZyxcbiAgICAgICAgICAgICAgICAgICdlcnJvcic6IGlmcmFtZS5jb250ZW50V2luZG93LmNvbnNvbGUuZXJyb3IsXG4gICAgICAgICAgICAgICAgICAnaW5mbyc6IGlmcmFtZS5jb250ZW50V2luZG93LmNvbnNvbGUuaW5mbyxcbiAgICAgICAgICAgICAgICAgICd3YXJuJzogaWZyYW1lLmNvbnRlbnRXaW5kb3cuY29uc29sZS53YXJuXG4gICAgICAgICAgICAgICAgfTtcbiAgICAgICAgICAgICAgICBmb3IgKGNvbnN0IGsgaW4gb2xkTG9ncykge1xuICAgICAgICAgICAgICAgICAgKGZ1bmN0aW9uIChvbGRMb2cpIHtcbiAgICAgICAgICAgICAgICAgICAgLy8gQHRzLWlnbm9yZVxuICAgICAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5jb25zb2xlW29sZExvZ10gPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgICAgICAgdmFyIG1lc3NhZ2UgPSAnJztcbiAgICAgICAgICAgICAgICAgICAgICBmb3IgKHZhciBpIGluIGFyZ3VtZW50cykge1xuICAgICAgICAgICAgICAgICAgICAgICAgaWYgKG1lc3NhZ2UgPT0gJycpIHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgbWVzc2FnZSArPSBhcmd1bWVudHNbaV07XG4gICAgICAgICAgICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgICAgICAgICAgICBtZXNzYWdlICs9ICcgJyArIGFyZ3VtZW50c1tpXTtcbiAgICAgICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICAgICAgLy8gQHRzLWlnbm9yZVxuICAgICAgICAgICAgICAgICAgICAgIG9sZExvZ3Nbb2xkTG9nXS5jYWxsKGlmcmFtZS5jb250ZW50V2luZG93LmNvbnNvbGUsIC4uLmFyZ3VtZW50cyk7XG4gICAgICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uQ29uc29sZU1lc3NhZ2UnLCB2aWV3SWQsIFtvbGRMb2csIG1lc3NhZ2VdKTtcbiAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgfSkoayk7XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgIGNvbnN0IG9yaWdpbmFsUHVzaFN0YXRlID0gaWZyYW1lLmNvbnRlbnRXaW5kb3cuaGlzdG9yeS5wdXNoU3RhdGU7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuaGlzdG9yeS5wdXNoU3RhdGUgPSBmdW5jdGlvbiAoc3RhdGUsIHVudXNlZCwgdXJsKSB7XG4gICAgICAgICAgICAgICAgICBvcmlnaW5hbFB1c2hTdGF0ZS5jYWxsKGlmcmFtZS5jb250ZW50V2luZG93IS5oaXN0b3J5LCBzdGF0ZSwgdW51c2VkLCB1cmwpO1xuICAgICAgICAgICAgICAgICAgbGV0IGlmcmFtZVVybCA9IGlmcmFtZS5zcmM7XG4gICAgICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgICAgICBpZnJhbWVVcmwgPSBpZnJhbWUuY29udGVudFdpbmRvdyEubG9jYXRpb24uaHJlZjtcbiAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25VcGRhdGVWaXNpdGVkSGlzdG9yeScsIHZpZXdJZCwgW2lmcmFtZVVybF0pO1xuICAgICAgICAgICAgICAgIH07XG5cbiAgICAgICAgICAgICAgICBjb25zdCBvcmlnaW5hbFJlcGxhY2VTdGF0ZSA9IGlmcmFtZS5jb250ZW50V2luZG93Lmhpc3RvcnkucmVwbGFjZVN0YXRlO1xuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93Lmhpc3RvcnkucmVwbGFjZVN0YXRlID0gZnVuY3Rpb24gKHN0YXRlLCB1bnVzZWQsIHVybCkge1xuICAgICAgICAgICAgICAgICAgb3JpZ2luYWxSZXBsYWNlU3RhdGUuY2FsbChpZnJhbWUuY29udGVudFdpbmRvdyEuaGlzdG9yeSwgc3RhdGUsIHVudXNlZCwgdXJsKTtcbiAgICAgICAgICAgICAgICAgIGxldCBpZnJhbWVVcmwgPSBpZnJhbWUuc3JjO1xuICAgICAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICAgICAgaWZyYW1lVXJsID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLmxvY2F0aW9uLmhyZWY7XG4gICAgICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uVXBkYXRlVmlzaXRlZEhpc3RvcnknLCB2aWV3SWQsIFtpZnJhbWVVcmxdKTtcbiAgICAgICAgICAgICAgICB9O1xuXG4gICAgICAgICAgICAgICAgY29uc3Qgb3JpZ2luYWxDbG9zZSA9IGlmcmFtZS5jb250ZW50V2luZG93LmNsb3NlO1xuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmNsb3NlID0gZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgICAgICAgb3JpZ2luYWxDbG9zZS5jYWxsKGlmcmFtZS5jb250ZW50V2luZG93KTtcbiAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvbkNsb3NlV2luZG93Jywgdmlld0lkKTtcbiAgICAgICAgICAgICAgICB9O1xuXG4gICAgICAgICAgICAgICAgY29uc3Qgb3JpZ2luYWxPcGVuID0gaWZyYW1lLmNvbnRlbnRXaW5kb3cub3BlbjtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5vcGVuID0gZnVuY3Rpb24gKHVybCwgdGFyZ2V0LCB3aW5kb3dGZWF0dXJlcykge1xuICAgICAgICAgICAgICAgICAgY29uc3QgbmV3V2luZG93ID0gb3JpZ2luYWxPcGVuLmNhbGwoaWZyYW1lLmNvbnRlbnRXaW5kb3csIC4uLmFyZ3VtZW50cyk7XG4gICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbjxQcm9taXNlPGJvb2xlYW4+Pignb25DcmVhdGVXaW5kb3cnLCB2aWV3SWQsIFt1cmwsIHRhcmdldCwgd2luZG93RmVhdHVyZXNdKS50aGVuKGZ1bmN0aW9uIChoYW5kbGVkQnlDbGllbnQpIHtcbiAgICAgICAgICAgICAgICAgICAgaWYgKGhhbmRsZWRCeUNsaWVudCkge1xuICAgICAgICAgICAgICAgICAgICAgIG5ld1dpbmRvdz8uY2xvc2UoKTtcbiAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgfSk7XG4gICAgICAgICAgICAgICAgICByZXR1cm4gbmV3V2luZG93O1xuICAgICAgICAgICAgICAgIH07XG5cbiAgICAgICAgICAgICAgICBjb25zdCBvcmlnaW5hbFByaW50ID0gaWZyYW1lLmNvbnRlbnRXaW5kb3cucHJpbnQ7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cucHJpbnQgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgICBsZXQgaWZyYW1lVXJsID0gaWZyYW1lLnNyYztcbiAgICAgICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZVVybCA9IGlmcmFtZS5jb250ZW50V2luZG93IS5sb2NhdGlvbi5ocmVmO1xuICAgICAgICAgICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvblByaW50UmVxdWVzdCcsIHZpZXdJZCwgW2lmcmFtZVVybF0pO1xuICAgICAgICAgICAgICAgICAgb3JpZ2luYWxQcmludC5jYWxsKGlmcmFtZS5jb250ZW50V2luZG93KTtcbiAgICAgICAgICAgICAgICB9O1xuXG4gICAgICAgICAgICAgICAgd2ViVmlldy5mdW5jdGlvbk1hcCA9IHtcbiAgICAgICAgICAgICAgICAgIFwid2luZG93Lm9wZW5cIjogaWZyYW1lLmNvbnRlbnRXaW5kb3cub3BlbixcbiAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICBjb25zdCBpbml0aWFsVGl0bGUgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py50aXRsZTtcbiAgICAgICAgICAgICAgICBjb25zdCB0aXRsZUVsID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8ucXVlcnlTZWxlY3RvcigndGl0bGUnKTtcbiAgICAgICAgICAgICAgICB3ZWJWaWV3LmRvY3VtZW50VGl0bGUgPSBpbml0aWFsVGl0bGU7XG4gICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uVGl0bGVDaGFuZ2VkJywgdmlld0lkLCBbaW5pdGlhbFRpdGxlXSk7XG4gICAgICAgICAgICAgICAgaWYgKHRpdGxlRWwgIT0gbnVsbCkge1xuICAgICAgICAgICAgICAgICAgbmV3IE11dGF0aW9uT2JzZXJ2ZXIoZnVuY3Rpb24gKG11dGF0aW9ucykge1xuICAgICAgICAgICAgICAgICAgICBjb25zdCB0aXRsZSA9IChtdXRhdGlvbnNbMF0udGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5pbm5lclRleHQ7XG4gICAgICAgICAgICAgICAgICAgIGlmICh0aXRsZSAhPSB3ZWJWaWV3LmRvY3VtZW50VGl0bGUpIHtcbiAgICAgICAgICAgICAgICAgICAgICB3ZWJWaWV3LmRvY3VtZW50VGl0bGUgPSB0aXRsZTtcbiAgICAgICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25UaXRsZUNoYW5nZWQnLCB2aWV3SWQsIFt0aXRsZV0pO1xuICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICB9KS5vYnNlcnZlKFxuICAgICAgICAgICAgICAgICAgICAgIHRpdGxlRWwsXG4gICAgICAgICAgICAgICAgICAgICAge3N1YnRyZWU6IHRydWUsIGNoYXJhY3RlckRhdGE6IHRydWUsIGNoaWxkTGlzdDogdHJ1ZX1cbiAgICAgICAgICAgICAgICAgICk7XG4gICAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgICAgbGV0IG9sZFBpeGVsUmF0aW8gPSBpZnJhbWUuY29udGVudFdpbmRvdy5kZXZpY2VQaXhlbFJhdGlvO1xuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ3Jlc2l6ZScsIGZ1bmN0aW9uIChlKSB7XG4gICAgICAgICAgICAgICAgICBjb25zdCBuZXdQaXhlbFJhdGlvID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLmRldmljZVBpeGVsUmF0aW87XG4gICAgICAgICAgICAgICAgICBpZiAobmV3UGl4ZWxSYXRpbyAhPT0gb2xkUGl4ZWxSYXRpbykge1xuICAgICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25ab29tU2NhbGVDaGFuZ2VkJywgdmlld0lkLCBbb2xkUGl4ZWxSYXRpbywgbmV3UGl4ZWxSYXRpb10pO1xuICAgICAgICAgICAgICAgICAgICBvbGRQaXhlbFJhdGlvID0gbmV3UGl4ZWxSYXRpbztcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICB9KTtcblxuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ3BvcHN0YXRlJywgZnVuY3Rpb24gKGV2ZW50OiBFdmVudCkge1xuICAgICAgICAgICAgICAgICAgbGV0IGlmcmFtZVVybCA9IGlmcmFtZS5zcmM7XG4gICAgICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgICAgICBpZnJhbWVVcmwgPSBpZnJhbWUuY29udGVudFdpbmRvdyEubG9jYXRpb24uaHJlZjtcbiAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25VcGRhdGVWaXNpdGVkSGlzdG9yeScsIHZpZXdJZCwgW2lmcmFtZVVybF0pO1xuICAgICAgICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuYWRkRXZlbnRMaXN0ZW5lcignc2Nyb2xsJywgZnVuY3Rpb24gKGV2ZW50OiBFdmVudCkge1xuICAgICAgICAgICAgICAgICAgbGV0IHggPSAwO1xuICAgICAgICAgICAgICAgICAgbGV0IHkgPSAwO1xuICAgICAgICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgICAgICAgeCA9IGlmcmFtZS5jb250ZW50V2luZG93IS5zY3JvbGxYO1xuICAgICAgICAgICAgICAgICAgICB5ID0gaWZyYW1lLmNvbnRlbnRXaW5kb3chLnNjcm9sbFk7XG4gICAgICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uU2Nyb2xsQ2hhbmdlZCcsIHZpZXdJZCwgW3gsIHldKTtcbiAgICAgICAgICAgICAgICB9KTtcblxuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ2ZvY3VzJywgZnVuY3Rpb24gKGV2ZW50OiBFdmVudCkge1xuICAgICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uV2luZG93Rm9jdXMnLCB2aWV3SWQpO1xuICAgICAgICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuYWRkRXZlbnRMaXN0ZW5lcignYmx1cicsIGZ1bmN0aW9uIChldmVudDogRXZlbnQpIHtcbiAgICAgICAgICAgICAgICAgIF9uYXRpdmVDb21tdW5pY2F0aW9uKCdvbldpbmRvd0JsdXInLCB2aWV3SWQpO1xuICAgICAgICAgICAgICAgIH0pO1xuICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICAgIGlmICghd2ViVmlldy5zZXR0aW5ncy5qYXZhU2NyaXB0Q2FuT3BlbldpbmRvd3NBdXRvbWF0aWNhbGx5KSB7XG4gICAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5vcGVuID0gZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgICAgICAgICB0aHJvdyBuZXcgRXJyb3IoJ0phdmFTY3JpcHQgY2Fubm90IG9wZW4gd2luZG93cyBhdXRvbWF0aWNhbGx5Jyk7XG4gICAgICAgICAgICAgICAgICB9O1xuICAgICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICAgIGlmICghd2ViVmlldy5zZXR0aW5ncy52ZXJ0aWNhbFNjcm9sbEJhckVuYWJsZWQgJiYgIXdlYlZpZXcuc2V0dGluZ3MuaG9yaXpvbnRhbFNjcm9sbEJhckVuYWJsZWQpIHtcbiAgICAgICAgICAgICAgICAgIGNvbnN0IHN0eWxlID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uY3JlYXRlRWxlbWVudCgnc3R5bGUnKTtcbiAgICAgICAgICAgICAgICAgIGlmIChzdHlsZSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgICAgIHN0eWxlLmlkID0gXCJzZXR0aW5ncy52ZXJ0aWNhbFNjcm9sbEJhckVuYWJsZWQtc2V0dGluZ3MuaG9yaXpvbnRhbFNjcm9sbEJhckVuYWJsZWRcIjtcbiAgICAgICAgICAgICAgICAgICAgc3R5bGUuaW5uZXJIVE1MID0gXCJib2R5Ojotd2Via2l0LXNjcm9sbGJhciB7IHdpZHRoOiAwcHg7IGhlaWdodDogMHB4OyB9XCI7XG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmhlYWQuYXBwZW5kKHN0eWxlKTtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy5kaXNhYmxlVmVydGljYWxTY3JvbGwpIHtcbiAgICAgICAgICAgICAgICAgIGNvbnN0IHN0eWxlID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uY3JlYXRlRWxlbWVudCgnc3R5bGUnKTtcbiAgICAgICAgICAgICAgICAgIGlmIChzdHlsZSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgICAgIHN0eWxlLmlkID0gXCJzZXR0aW5ncy5kaXNhYmxlVmVydGljYWxTY3JvbGxcIjtcbiAgICAgICAgICAgICAgICAgICAgc3R5bGUuaW5uZXJIVE1MID0gXCJib2R5IHsgb3ZlcmZsb3cteTogaGlkZGVuOyB9XCI7XG4gICAgICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmhlYWQuYXBwZW5kKHN0eWxlKTtcbiAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy5kaXNhYmxlSG9yaXpvbnRhbFNjcm9sbCkge1xuICAgICAgICAgICAgICAgICAgY29uc3Qgc3R5bGUgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5jcmVhdGVFbGVtZW50KCdzdHlsZScpO1xuICAgICAgICAgICAgICAgICAgaWYgKHN0eWxlICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgICAgc3R5bGUuaWQgPSBcInNldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsXCI7XG4gICAgICAgICAgICAgICAgICAgIHN0eWxlLmlubmVySFRNTCA9IFwiYm9keSB7IG92ZXJmbG93LXg6IGhpZGRlbjsgfVwiO1xuICAgICAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudERvY3VtZW50Py5oZWFkLmFwcGVuZChzdHlsZSk7XG4gICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgICAgaWYgKHdlYlZpZXcuc2V0dGluZ3MuZGlzYWJsZUNvbnRleHRNZW51KSB7XG4gICAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5hZGRFdmVudExpc3RlbmVyKCdjb250ZXh0bWVudScsIHdlYlZpZXcuZGlzYWJsZUNvbnRleHRNZW51SGFuZGxlcik7XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25Mb2FkU3RvcCcsIHZpZXdJZCwgW3VybF0pO1xuXG4gICAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cuZGlzcGF0Y2hFdmVudChuZXcgRXZlbnQoJ2ZsdXR0ZXJJbkFwcFdlYlZpZXdQbGF0Zm9ybVJlYWR5JykpO1xuICAgICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgfSwgeyBzaWduYWw6IHdlYlZpZXcubGlzdGVuZXJBYm9ydENvbnRyb2xsZXIuc2lnbmFsIH0pO1xuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgc2V0U2V0dGluZ3M6IGZ1bmN0aW9uIChuZXdTZXR0aW5nczogSW5BcHBXZWJWaWV3U2V0dGluZ3MpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICBpZiAoaWZyYW1lID09IG51bGwpIHtcbiAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgICB9XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIGlmICh3ZWJWaWV3LnNldHRpbmdzLmphdmFTY3JpcHRDYW5PcGVuV2luZG93c0F1dG9tYXRpY2FsbHkgIT0gbmV3U2V0dGluZ3MuamF2YVNjcmlwdENhbk9wZW5XaW5kb3dzQXV0b21hdGljYWxseSkge1xuICAgICAgICAgICAgICBpZiAoIW5ld1NldHRpbmdzLmphdmFTY3JpcHRDYW5PcGVuV2luZG93c0F1dG9tYXRpY2FsbHkpIHtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdyEub3BlbiA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgICAgICAgIHRocm93IG5ldyBFcnJvcignSmF2YVNjcmlwdCBjYW5ub3Qgb3BlbiB3aW5kb3dzIGF1dG9tYXRpY2FsbHknKTtcbiAgICAgICAgICAgICAgICB9O1xuICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93IS5vcGVuID0gd2ViVmlldy5mdW5jdGlvbk1hcFtcIndpbmRvdy5vcGVuXCJdO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG5cbiAgICAgICAgICAgIGlmICh3ZWJWaWV3LnNldHRpbmdzLnZlcnRpY2FsU2Nyb2xsQmFyRW5hYmxlZCAhPSBuZXdTZXR0aW5ncy52ZXJ0aWNhbFNjcm9sbEJhckVuYWJsZWQgJiZcbiAgICAgICAgICAgICAgICB3ZWJWaWV3LnNldHRpbmdzLmhvcml6b250YWxTY3JvbGxCYXJFbmFibGVkICE9IG5ld1NldHRpbmdzLmhvcml6b250YWxTY3JvbGxCYXJFbmFibGVkKSB7XG4gICAgICAgICAgICAgIGlmICghbmV3U2V0dGluZ3MudmVydGljYWxTY3JvbGxCYXJFbmFibGVkICYmICFuZXdTZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZCkge1xuICAgICAgICAgICAgICAgIGNvbnN0IHN0eWxlID0gaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uY3JlYXRlRWxlbWVudCgnc3R5bGUnKTtcbiAgICAgICAgICAgICAgICBpZiAoc3R5bGUgIT0gbnVsbCkge1xuICAgICAgICAgICAgICAgICAgc3R5bGUuaWQgPSBcInNldHRpbmdzLnZlcnRpY2FsU2Nyb2xsQmFyRW5hYmxlZC1zZXR0aW5ncy5ob3Jpem9udGFsU2Nyb2xsQmFyRW5hYmxlZFwiO1xuICAgICAgICAgICAgICAgICAgc3R5bGUuaW5uZXJIVE1MID0gXCJib2R5Ojotd2Via2l0LXNjcm9sbGJhciB7IHdpZHRoOiAwcHg7IGhlaWdodDogMHB4OyB9XCI7XG4gICAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudERvY3VtZW50Py5oZWFkLmFwcGVuZChzdHlsZSk7XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgIGNvbnN0IHN0eWxlRWxlbWVudCA9IGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmdldEVsZW1lbnRCeUlkKFwic2V0dGluZ3MudmVydGljYWxTY3JvbGxCYXJFbmFibGVkLXNldHRpbmdzLmhvcml6b250YWxTY3JvbGxCYXJFbmFibGVkXCIpO1xuICAgICAgICAgICAgICAgIGlmIChzdHlsZUVsZW1lbnQpIHtcbiAgICAgICAgICAgICAgICAgIHN0eWxlRWxlbWVudC5yZW1vdmUoKVxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy5kaXNhYmxlVmVydGljYWxTY3JvbGwgIT0gbmV3U2V0dGluZ3MuZGlzYWJsZVZlcnRpY2FsU2Nyb2xsKSB7XG4gICAgICAgICAgICAgIGlmIChuZXdTZXR0aW5ncy5kaXNhYmxlVmVydGljYWxTY3JvbGwpIHtcbiAgICAgICAgICAgICAgICBjb25zdCBzdHlsZSA9IGlmcmFtZS5jb250ZW50RG9jdW1lbnQ/LmNyZWF0ZUVsZW1lbnQoJ3N0eWxlJyk7XG4gICAgICAgICAgICAgICAgaWYgKHN0eWxlICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgIHN0eWxlLmlkID0gXCJzZXR0aW5ncy5kaXNhYmxlVmVydGljYWxTY3JvbGxcIjtcbiAgICAgICAgICAgICAgICAgIHN0eWxlLmlubmVySFRNTCA9IFwiYm9keSB7IG92ZXJmbG93LXk6IGhpZGRlbjsgfVwiO1xuICAgICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uaGVhZC5hcHBlbmQoc3R5bGUpO1xuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgICBjb25zdCBzdHlsZUVsZW1lbnQgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5nZXRFbGVtZW50QnlJZChcInNldHRpbmdzLmRpc2FibGVWZXJ0aWNhbFNjcm9sbFwiKTtcbiAgICAgICAgICAgICAgICBpZiAoc3R5bGVFbGVtZW50KSB7XG4gICAgICAgICAgICAgICAgICBzdHlsZUVsZW1lbnQucmVtb3ZlKClcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgaWYgKHdlYlZpZXcuc2V0dGluZ3MuZGlzYWJsZUhvcml6b250YWxTY3JvbGwgIT0gbmV3U2V0dGluZ3MuZGlzYWJsZUhvcml6b250YWxTY3JvbGwpIHtcbiAgICAgICAgICAgICAgaWYgKG5ld1NldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsKSB7XG4gICAgICAgICAgICAgICAgY29uc3Qgc3R5bGUgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5jcmVhdGVFbGVtZW50KCdzdHlsZScpO1xuICAgICAgICAgICAgICAgIGlmIChzdHlsZSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgICAgICBzdHlsZS5pZCA9IFwic2V0dGluZ3MuZGlzYWJsZUhvcml6b250YWxTY3JvbGxcIjtcbiAgICAgICAgICAgICAgICAgIHN0eWxlLmlubmVySFRNTCA9IFwiYm9keSB7IG92ZXJmbG93LXg6IGhpZGRlbjsgfVwiO1xuICAgICAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnREb2N1bWVudD8uaGVhZC5hcHBlbmQoc3R5bGUpO1xuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgICBjb25zdCBzdHlsZUVsZW1lbnQgPSBpZnJhbWUuY29udGVudERvY3VtZW50Py5nZXRFbGVtZW50QnlJZChcInNldHRpbmdzLmRpc2FibGVIb3Jpem9udGFsU2Nyb2xsXCIpO1xuICAgICAgICAgICAgICAgIGlmIChzdHlsZUVsZW1lbnQpIHtcbiAgICAgICAgICAgICAgICAgIHN0eWxlRWxlbWVudC5yZW1vdmUoKVxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICBpZiAod2ViVmlldy5zZXR0aW5ncy5kaXNhYmxlQ29udGV4dE1lbnUgIT0gbmV3U2V0dGluZ3MuZGlzYWJsZUNvbnRleHRNZW51KSB7XG4gICAgICAgICAgICAgIGlmIChuZXdTZXR0aW5ncy5kaXNhYmxlQ29udGV4dE1lbnUpIHtcbiAgICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdz8uYWRkRXZlbnRMaXN0ZW5lcignY29udGV4dG1lbnUnLCB3ZWJWaWV3LmRpc2FibGVDb250ZXh0TWVudUhhbmRsZXIpO1xuICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93Py5yZW1vdmVFdmVudExpc3RlbmVyKCdjb250ZXh0bWVudScsIHdlYlZpZXcuZGlzYWJsZUNvbnRleHRNZW51SGFuZGxlcik7XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG5cbiAgICAgICAgICB3ZWJWaWV3LnNldHRpbmdzID0gbmV3U2V0dGluZ3M7XG4gICAgICAgIH0sXG4gICAgICAgIHJlbG9hZDogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIHZhciBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICBpZiAoaWZyYW1lICE9IG51bGwgJiYgaWZyYW1lLmNvbnRlbnRXaW5kb3cgIT0gbnVsbCkge1xuICAgICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgICAgaWZyYW1lLmNvbnRlbnRXaW5kb3cubG9jYXRpb24ucmVsb2FkKCk7XG4gICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdy5sb2NhdGlvbi5ocmVmID0gaWZyYW1lLnNyYztcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIGdvQmFjazogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIHZhciBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICBpZiAoaWZyYW1lICE9IG51bGwpIHtcbiAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93Py5oaXN0b3J5LmJhY2soKTtcbiAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBnb0ZvcndhcmQ6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICB2YXIgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsKSB7XG4gICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdz8uaGlzdG9yeS5mb3J3YXJkKCk7XG4gICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgZ29CYWNrT3JGb3J3YXJkOiBmdW5jdGlvbiAoc3RlcHMpIHtcbiAgICAgICAgICB2YXIgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsKSB7XG4gICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICBpZnJhbWUuY29udGVudFdpbmRvdz8uaGlzdG9yeS5nbyhzdGVwcyk7XG4gICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgZXZhbHVhdGVKYXZhc2NyaXB0OiBmdW5jdGlvbiAoc291cmNlKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgbGV0IHJlc3VsdCA9IG51bGw7XG4gICAgICAgICAgaWYgKGlmcmFtZSAhPSBudWxsKSB7XG4gICAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgICByZXN1bHQgPSBKU09OLnN0cmluZ2lmeShpZnJhbWUuY29udGVudFdpbmRvdz8uZXZhbChzb3VyY2UpKTtcbiAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIHJlc3VsdDtcbiAgICAgICAgfSxcbiAgICAgICAgc3RvcExvYWRpbmc6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICBpZiAoaWZyYW1lICE9IG51bGwpIHtcbiAgICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICAgIGlmcmFtZS5jb250ZW50V2luZG93Py5zdG9wKCk7XG4gICAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgZ2V0VXJsOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgbGV0IHVybCA9IGlmcmFtZT8uc3JjO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICB1cmwgPSBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LmxvY2F0aW9uLmhyZWY7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiB1cmw7XG4gICAgICAgIH0sXG4gICAgICAgIGdldFRpdGxlOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgbGV0IHRpdGxlID0gbnVsbDtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgdGl0bGUgPSBpZnJhbWU/LmNvbnRlbnREb2N1bWVudD8udGl0bGU7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiB0aXRsZTtcbiAgICAgICAgfSxcbiAgICAgICAgaW5qZWN0SmF2YXNjcmlwdEZpbGVGcm9tVXJsOiBmdW5jdGlvbiAodXJsRmlsZSwgc2NyaXB0SHRtbFRhZ0F0dHJpYnV0ZXMpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgY29uc3QgZCA9IGlmcmFtZT8uY29udGVudERvY3VtZW50O1xuICAgICAgICAgICAgaWYgKGQgPT0gbnVsbCkge1xuICAgICAgICAgICAgICByZXR1cm47XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBjb25zdCBzY3JpcHQgPSBkLmNyZWF0ZUVsZW1lbnQoJ3NjcmlwdCcpO1xuICAgICAgICAgICAgZm9yIChjb25zdCBrZXkgb2YgT2JqZWN0LmtleXMoc2NyaXB0SHRtbFRhZ0F0dHJpYnV0ZXMpKSB7XG4gICAgICAgICAgICAgIGlmIChzY3JpcHRIdG1sVGFnQXR0cmlidXRlc1trZXldICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICAgICAgc2NyaXB0W2tleV0gPSBzY3JpcHRIdG1sVGFnQXR0cmlidXRlc1trZXldO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBpZiAoc2NyaXB0LmlkICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgc2NyaXB0Lm9ubG9hZCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgICAgICBfbmF0aXZlQ29tbXVuaWNhdGlvbignb25JbmplY3RlZFNjcmlwdExvYWRlZCcsIHdlYlZpZXcudmlld0lkLCBbc2NyaXB0LmlkXSk7XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgc2NyaXB0Lm9uZXJyb3IgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICAgICAgX25hdGl2ZUNvbW11bmljYXRpb24oJ29uSW5qZWN0ZWRTY3JpcHRFcnJvcicsIHdlYlZpZXcudmlld0lkLCBbc2NyaXB0LmlkXSk7XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIHNjcmlwdC5zcmMgPSB1cmxGaWxlO1xuICAgICAgICAgICAgaWYgKGQuYm9keSAhPSBudWxsKSB7XG4gICAgICAgICAgICAgIGQuYm9keS5hcHBlbmRDaGlsZChzY3JpcHQpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgaW5qZWN0Q1NTQ29kZTogZnVuY3Rpb24gKHNvdXJjZSkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICBjb25zdCBkID0gaWZyYW1lPy5jb250ZW50RG9jdW1lbnQ7XG4gICAgICAgICAgICBpZiAoZCA9PSBudWxsKSB7XG4gICAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGNvbnN0IHN0eWxlID0gZC5jcmVhdGVFbGVtZW50KCdzdHlsZScpO1xuICAgICAgICAgICAgc3R5bGUuaW5uZXJIVE1MID0gc291cmNlO1xuICAgICAgICAgICAgaWYgKGQuaGVhZCAhPSBudWxsKSB7XG4gICAgICAgICAgICAgIGQuaGVhZC5hcHBlbmRDaGlsZChzdHlsZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBpbmplY3RDU1NGaWxlRnJvbVVybDogZnVuY3Rpb24gKHVybEZpbGUsIGNzc0xpbmtIdG1sVGFnQXR0cmlidXRlcykge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICBjb25zdCBkID0gaWZyYW1lPy5jb250ZW50RG9jdW1lbnQ7XG4gICAgICAgICAgICBpZiAoZCA9PSBudWxsKSB7XG4gICAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGNvbnN0IGxpbmsgPSBkLmNyZWF0ZUVsZW1lbnQoJ2xpbmsnKTtcbiAgICAgICAgICAgIGZvciAoY29uc3Qga2V5IG9mIE9iamVjdC5rZXlzKGNzc0xpbmtIdG1sVGFnQXR0cmlidXRlcykpIHtcbiAgICAgICAgICAgICAgaWYgKGNzc0xpbmtIdG1sVGFnQXR0cmlidXRlc1trZXldICE9IG51bGwpIHtcbiAgICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICAgICAgbGlua1trZXldID0gY3NzTGlua0h0bWxUYWdBdHRyaWJ1dGVzW2tleV07XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGxpbmsudHlwZSA9ICd0ZXh0L2Nzcyc7XG4gICAgICAgICAgICB2YXIgYWx0ZXJuYXRlU3R5bGVzaGVldCA9IFwiXCI7XG4gICAgICAgICAgICBpZiAoY3NzTGlua0h0bWxUYWdBdHRyaWJ1dGVzLmFsdGVybmF0ZVN0eWxlc2hlZXQpIHtcbiAgICAgICAgICAgICAgYWx0ZXJuYXRlU3R5bGVzaGVldCA9IFwiYWx0ZXJuYXRlIFwiO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgbGluay5yZWwgPSBhbHRlcm5hdGVTdHlsZXNoZWV0ICsgXCJzdHlsZXNoZWV0XCI7XG4gICAgICAgICAgICBsaW5rLmhyZWYgPSB1cmxGaWxlO1xuICAgICAgICAgICAgaWYgKGQuaGVhZCAhPSBudWxsKSB7XG4gICAgICAgICAgICAgIGQuaGVhZC5hcHBlbmRDaGlsZChsaW5rKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIHNjcm9sbFRvOiBmdW5jdGlvbiAoeCwgeSwgYW5pbWF0ZWQpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgaWYgKGFuaW1hdGVkKSB7XG4gICAgICAgICAgICAgIGlmcmFtZT8uY29udGVudFdpbmRvdz8uc2Nyb2xsVG8oe3RvcDogeSwgbGVmdDogeCwgYmVoYXZpb3I6ICdzbW9vdGgnfSk7XG4gICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICBpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LnNjcm9sbFRvKHgsIHkpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgfSxcbiAgICAgICAgc2Nyb2xsQnk6IGZ1bmN0aW9uICh4LCB5LCBhbmltYXRlZCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICBpZiAoYW5pbWF0ZWQpIHtcbiAgICAgICAgICAgICAgaWZyYW1lPy5jb250ZW50V2luZG93Py5zY3JvbGxCeSh7dG9wOiB5LCBsZWZ0OiB4LCBiZWhhdmlvcjogJ3Ntb290aCd9KTtcbiAgICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICAgIGlmcmFtZT8uY29udGVudFdpbmRvdz8uc2Nyb2xsQnkoeCwgeSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBwcmludEN1cnJlbnRQYWdlOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIGlmcmFtZT8uY29udGVudFdpbmRvdz8ucHJpbnQoKTtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIGdldENvbnRlbnRIZWlnaHQ6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgcmV0dXJuIGlmcmFtZT8uY29udGVudERvY3VtZW50Py5kb2N1bWVudEVsZW1lbnQuc2Nyb2xsSGVpZ2h0O1xuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4gbnVsbDtcbiAgICAgICAgfSxcbiAgICAgICAgZ2V0Q29udGVudFdpZHRoOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIHJldHVybiBpZnJhbWU/LmNvbnRlbnREb2N1bWVudD8uZG9jdW1lbnRFbGVtZW50LnNjcm9sbFdpZHRoO1xuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4gbnVsbDtcbiAgICAgICAgfSxcbiAgICAgICAgZ2V0U2VsZWN0ZWRUZXh0OiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lID0gd2ViVmlldy5pZnJhbWU7XG4gICAgICAgICAgdHJ5IHtcbiAgICAgICAgICAgIGxldCB0eHQ7XG4gICAgICAgICAgICBjb25zdCB3ID0gaWZyYW1lPy5jb250ZW50V2luZG93O1xuICAgICAgICAgICAgaWYgKHcgPT0gbnVsbCkge1xuICAgICAgICAgICAgICByZXR1cm4gbnVsbDtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGlmICh3LmdldFNlbGVjdGlvbikge1xuICAgICAgICAgICAgICB0eHQgPSB3LmdldFNlbGVjdGlvbigpPy50b1N0cmluZygpO1xuICAgICAgICAgICAgfSBlbHNlIGlmICh3LmRvY3VtZW50LmdldFNlbGVjdGlvbikge1xuICAgICAgICAgICAgICB0eHQgPSB3LmRvY3VtZW50LmdldFNlbGVjdGlvbigpPy50b1N0cmluZygpO1xuICAgICAgICAgICAgICAvLyBAdHMtaWdub3JlXG4gICAgICAgICAgICB9IGVsc2UgaWYgKHcuZG9jdW1lbnQuc2VsZWN0aW9uKSB7XG4gICAgICAgICAgICAgIC8vIEB0cy1pZ25vcmVcbiAgICAgICAgICAgICAgdHh0ID0gdy5kb2N1bWVudC5zZWxlY3Rpb24uY3JlYXRlUmFuZ2UoKS50ZXh0O1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgcmV0dXJuIHR4dDtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgIH0sXG4gICAgICAgIGdldFNjcm9sbFg6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgcmV0dXJuIGlmcmFtZT8uY29udGVudFdpbmRvdz8uc2Nyb2xsWDtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgIH0sXG4gICAgICAgIGdldFNjcm9sbFk6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICBjb25zdCBpZnJhbWUgPSB3ZWJWaWV3LmlmcmFtZTtcbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgcmV0dXJuIGlmcmFtZT8uY29udGVudFdpbmRvdz8uc2Nyb2xsWTtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgIH0sXG4gICAgICAgIGlzU2VjdXJlQ29udGV4dDogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICByZXR1cm4gaWZyYW1lPy5jb250ZW50V2luZG93Py5pc1NlY3VyZUNvbnRleHQgPz8gZmFsc2U7XG4gICAgICAgICAgfSBjYXRjaCAoZSkge1xuICAgICAgICAgICAgY29uc29sZS5sb2coZSk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgICAgfSxcbiAgICAgICAgY2FuU2Nyb2xsVmVydGljYWxseTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICByZXR1cm4gKGlmcmFtZT8uY29udGVudERvY3VtZW50Py5ib2R5LnNjcm9sbEhlaWdodCA/PyAwKSA+IChpZnJhbWU/LmNvbnRlbnRXaW5kb3c/LmlubmVySGVpZ2h0ID8/IDApO1xuICAgICAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgICAgIGNvbnNvbGUubG9nKGUpO1xuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4gZmFsc2U7XG4gICAgICAgIH0sXG4gICAgICAgIGNhblNjcm9sbEhvcml6b250YWxseTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgIGNvbnN0IGlmcmFtZSA9IHdlYlZpZXcuaWZyYW1lO1xuICAgICAgICAgIHRyeSB7XG4gICAgICAgICAgICByZXR1cm4gKGlmcmFtZT8uY29udGVudERvY3VtZW50Py5ib2R5LnNjcm9sbFdpZHRoID8/IDApID4gKGlmcmFtZT8uY29udGVudFdpbmRvdz8uaW5uZXJXaWR0aCA/PyAwKTtcbiAgICAgICAgICB9IGNhdGNoIChlKSB7XG4gICAgICAgICAgICBjb25zb2xlLmxvZyhlKTtcbiAgICAgICAgICB9XG4gICAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgICAgICB9LFxuICAgICAgICBnZXRTaXplOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY29uc3QgaWZyYW1lQ29udGFpbmVyID0gd2ViVmlldy5pZnJhbWVDb250YWluZXI7XG4gICAgICAgICAgbGV0IHdpZHRoID0gMC4wO1xuICAgICAgICAgIGxldCBoZWlnaHQgPSAwLjA7XG4gICAgICAgICAgaWYgKGlmcmFtZUNvbnRhaW5lciAhPSBudWxsKSB7XG4gICAgICAgICAgICBpZiAoaWZyYW1lQ29udGFpbmVyLnN0eWxlLndpZHRoICE9IG51bGwgJiYgaWZyYW1lQ29udGFpbmVyLnN0eWxlLndpZHRoICE9ICcnICYmIGlmcmFtZUNvbnRhaW5lci5zdHlsZS53aWR0aC5pbmRleE9mKCdweCcpID4gMCkge1xuICAgICAgICAgICAgICB3aWR0aCA9IHBhcnNlRmxvYXQoaWZyYW1lQ29udGFpbmVyLnN0eWxlLndpZHRoKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGlmICh3aWR0aCA9PSBudWxsIHx8IHdpZHRoID09IDAuMCkge1xuICAgICAgICAgICAgICB3aWR0aCA9IGlmcmFtZUNvbnRhaW5lci5nZXRCb3VuZGluZ0NsaWVudFJlY3QoKS53aWR0aDtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGlmIChpZnJhbWVDb250YWluZXIuc3R5bGUuaGVpZ2h0ICE9IG51bGwgJiYgaWZyYW1lQ29udGFpbmVyLnN0eWxlLmhlaWdodCAhPSAnJyAmJiBpZnJhbWVDb250YWluZXIuc3R5bGUuaGVpZ2h0LmluZGV4T2YoJ3B4JykgPiAwKSB7XG4gICAgICAgICAgICAgIGhlaWdodCA9IHBhcnNlRmxvYXQoaWZyYW1lQ29udGFpbmVyLnN0eWxlLmhlaWdodCk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBpZiAoaGVpZ2h0ID09IG51bGwgfHwgaGVpZ2h0ID09IDAuMCkge1xuICAgICAgICAgICAgICBoZWlnaHQgPSBpZnJhbWVDb250YWluZXIuZ2V0Qm91bmRpbmdDbGllbnRSZWN0KCkuaGVpZ2h0O1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgICByZXR1cm4ge1xuICAgICAgICAgICAgd2lkdGg6IHdpZHRoLFxuICAgICAgICAgICAgaGVpZ2h0OiBoZWlnaHRcbiAgICAgICAgICB9O1xuICAgICAgICB9XG4gICAgICB9O1xuXG4gICAgICByZXR1cm4gd2ViVmlldztcbiAgICB9LFxuICAgIGdldENvb2tpZUV4cGlyYXRpb25EYXRlOiBmdW5jdGlvbiAodGltZXN0YW1wOiBudW1iZXIpIHtcbiAgICAgIHJldHVybiAobmV3IERhdGUodGltZXN0YW1wKSkudG9VVENTdHJpbmcoKTtcbiAgICB9LFxuICAgIG5hdGl2ZUFzeW5jQ29tbXVuaWNhdGlvbjogZnVuY3Rpb24gKG1ldGhvZDogc3RyaW5nLCB2aWV3SWQ6IG51bWJlciB8IHN0cmluZywgYXJncz86IGFueVtdKSB7XG4gICAgICB0aHJvdyBuZXcgRXJyb3IoXCJNZXRob2Qgbm90IGltcGxlbWVudGVkLlwiKTtcbiAgICB9LFxuICAgIG5hdGl2ZVN5bmNDb21tdW5pY2F0aW9uOiBmdW5jdGlvbiAobWV0aG9kOiBzdHJpbmcsIHZpZXdJZDogbnVtYmVyIHwgc3RyaW5nLCBhcmdzPzogYW55W10pIHtcbiAgICAgIHRocm93IG5ldyBFcnJvcihcIk1ldGhvZCBub3QgaW1wbGVtZW50ZWQuXCIpO1xuICAgIH0sXG4gICAgbmF0aXZlQ29tbXVuaWNhdGlvbjogZnVuY3Rpb24gKG1ldGhvZDogc3RyaW5nLCB2aWV3SWQ6IG51bWJlciB8IHN0cmluZywgYXJncz86IGFueVtdKSB7XG4gICAgICB0cnkge1xuICAgICAgICBjb25zdCByZXN1bHQgPSB3aW5kb3cuZmx1dHRlcl9pbmFwcHdlYnZpZXdfcGx1Z2luLm5hdGl2ZVN5bmNDb21tdW5pY2F0aW9uKG1ldGhvZCwgdmlld0lkLCBhcmdzKTtcbiAgICAgICAgcmV0dXJuIHJlc3VsdCAhPSBudWxsID8gSlNPTi5wYXJzZShyZXN1bHQpIDogbnVsbDtcbiAgICAgIH0gY2F0Y2ggKGUxKSB7XG4gICAgICAgIHRyeSB7XG4gICAgICAgICAgY29uc3QgcHJvbWlzZSA9IHdpbmRvdy5mbHV0dGVyX2luYXBwd2Vidmlld19wbHVnaW4ubmF0aXZlQXN5bmNDb21tdW5pY2F0aW9uKG1ldGhvZCwgdmlld0lkLCBhcmdzKTtcbiAgICAgICAgICByZXR1cm4gcHJvbWlzZS50aGVuKGZ1bmN0aW9uIChyZXN1bHQpIHtcbiAgICAgICAgICAgIHJldHVybiByZXN1bHQgIT0gbnVsbCA/IEpTT04ucGFyc2UocmVzdWx0KSA6IG51bGw7XG4gICAgICAgICAgfSk7XG4gICAgICAgIH0gY2F0Y2ggKGUyKSB7XG4gICAgICAgICAgcmV0dXJuIG51bGw7XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9LFxuICB9O1xuXG4gIGxldCBfbmF0aXZlQ29tbXVuaWNhdGlvbiA9IHdpbmRvdy5mbHV0dGVyX2luYXBwd2Vidmlld19wbHVnaW4ubmF0aXZlQ29tbXVuaWNhdGlvbjtcbn0pKCk7XG4iXSwKICAibWFwcGluZ3MiOiAiO0NBbUJDLFdBQVk7QUFDWCxNQUFJLGtCQUFrQixPQUFPLEtBQUs7QUFDbEMsTUFBSSxlQUFlLE9BQU8sTUFBTSxVQUFVO0FBQzFDLGVBQWEsT0FBTyxPQUFPLFNBQVMsVUFBVTtBQUU5QyxTQUFPLDhCQUE4QjtBQUFBLElBQ25DLDJCQUEyQixTQUFVLFFBQXlCLFFBQTJCLGlCQUFpQyxjQUFzQjtBQUM5SSxZQUFNLFdBQVcsT0FBTztBQUN4QixZQUFNLFVBQXdCO0FBQUEsUUFDNUI7QUFBQSxRQUNBO0FBQUEsUUFDQSxRQUFRO0FBQUEsUUFDUixpQkFBaUI7QUFBQSxRQUNqQixjQUFjO0FBQUEsUUFDZCxlQUFlO0FBQUEsUUFDZixhQUFhLENBQUM7QUFBQSxRQUNkLFVBQVUsQ0FBQztBQUFBLFFBQ1gseUJBQXlCO0FBQUEsUUFDekIseUJBQXlCLElBQUksZ0JBQWdCO0FBQUEsUUFDN0MsU0FBUyxXQUFZO0FBRW5CLGtCQUFRLHdCQUF3QixNQUFNO0FBQ3RDLGtCQUFRLFNBQVM7QUFDakIsa0JBQVEsa0JBQWtCO0FBQzFCLGtCQUFRLGNBQWMsQ0FBQztBQUFBLFFBQ3pCO0FBQUEsUUFDQSwyQkFBMkIsU0FBVSxPQUFjO0FBQ2pELGdCQUFNLGVBQWU7QUFDckIsZ0JBQU0sZ0JBQWdCO0FBQ3RCLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsU0FBUyxTQUFVLFVBQWdDO0FBRWpELGtCQUFRLHdCQUF3QixNQUFNO0FBQ3RDLGtCQUFRLDBCQUEwQixJQUFJLGdCQUFnQjtBQUN0RCxrQkFBUSxXQUFXO0FBRW5CLGtCQUFRLDBCQUEwQixRQUFRLFNBQVMsMkJBQTJCO0FBQzlFLGdCQUFNLGtDQUFrQyxRQUFRLFNBQVM7QUFDekQsY0FBSSxtQ0FBbUMsUUFBUSxDQUFDLGdDQUFnQyxTQUFTLEdBQUcsR0FBRztBQUM3RixnQkFBSSxnQ0FBZ0MsV0FBVyxHQUFHO0FBRWhELHNCQUFRLDBCQUEwQjtBQUFBLFlBQ3BDO0FBQUEsVUFDRjtBQUVBLG1CQUFTLGlCQUFpQixvQkFBb0IsU0FBVSxPQUFjO0FBSXBFLGdCQUFJLFNBQVMscUJBQXFCLFNBQVMsa0JBQWtCLE1BQU0sVUFBVTtBQUMzRSxzQkFBUSxlQUFlO0FBQ3ZCLG1DQUFxQixxQkFBcUIsTUFBTTtBQUFBLFlBQ2xELFdBQVcsQ0FBQyxTQUFTLHFCQUFxQixRQUFRLGNBQWM7QUFDOUQsc0JBQVEsZUFBZTtBQUN2QixtQ0FBcUIsb0JBQW9CLE1BQU07QUFBQSxZQUNqRCxPQUFPO0FBQ0wsc0JBQVEsZUFBZTtBQUFBLFlBQ3pCO0FBQUEsVUFDRixHQUFHLEVBQUUsUUFBUSxRQUFRLHdCQUF3QixPQUFPLENBQUM7QUFFckQsY0FBSSxVQUFVLE1BQU07QUFDbEIsb0JBQVEsU0FBUztBQUNqQixvQkFBUSxrQkFBa0I7QUFDMUIsbUJBQU8saUJBQWlCLFFBQVEsU0FBVSxPQUFjO0FBQ3RELGtCQUFJLE9BQU8saUJBQWlCLE1BQU07QUFDaEM7QUFBQSxjQUNGO0FBRUEsb0JBQU0scUJBQXFCLHFCQUFtQyx3QkFBd0IsUUFBUSwwQkFBMEMsQ0FBQztBQUN6SSxvQkFBTSxtQkFBbUIscUJBQW1DLHdCQUF3QixRQUFRLHdCQUF3QyxDQUFDO0FBRXJJLGtCQUFJO0FBQ0Ysb0JBQUksMEJBQTBCLFFBQVE7QUFDdEMsb0JBQUksbUNBQW1DLE1BQU07QUFDM0MsNENBQTBCLGdDQUNyQixJQUFJLHVCQUFxQixJQUFJLE9BQU8saUJBQWlCLENBQUMsRUFDdEQsS0FBSyxDQUFDLE9BQU87QUFDWiwyQkFBTyxHQUFHLEtBQUssT0FBTyxjQUFlLFNBQVMsTUFBTTtBQUFBLGtCQUN0RCxDQUFDO0FBQUEsZ0JBQ1A7QUFDQSxvQkFBSSx5QkFBeUI7QUFDM0Isd0JBQU0sdUJBQXVCLHFCQUE2QiwyQkFBMkIsTUFBTTtBQUUzRix5QkFBTyxjQUFlLG9CQUFvQixJQUFJO0FBQUEsb0JBQzVDLGFBQWEsV0FBWTtBQUN2QiwwQkFBSSxTQUFTO0FBQ2IsMEJBQUksYUFBYTtBQUNqQiwwQkFBSTtBQUNGLGlDQUFTLE9BQU8sY0FBZSxTQUFTO0FBQUEsc0JBQzFDLFNBQVMsR0FBRztBQUFBLHNCQUNaO0FBQ0EsMEJBQUk7QUFDRixxQ0FBYSxPQUFPLGNBQWUsU0FBUztBQUFBLHNCQUM5QyxTQUFTLEdBQUc7QUFBQSxzQkFDWjtBQUNBLDZCQUFPO0FBQUEsd0JBQXFCO0FBQUEsd0JBQ3hCO0FBQUEsd0JBQ0EsQ0FBQyxVQUFVLENBQUMsR0FBRyxnQkFBZ0I7QUFBQSwwQkFDN0IsVUFBVTtBQUFBLDBCQUNWLGNBQWM7QUFBQSwwQkFDZCxlQUFlO0FBQUEsMEJBQ2YsaUJBQWlCO0FBQUEsMEJBQ2pCLFFBQVEsZ0JBQWdCLGFBQWEsS0FBSyxXQUFXLENBQUMsQ0FBQztBQUFBLHdCQUN6RCxDQUFDLENBQUM7QUFBQSxzQkFBQztBQUFBLG9CQUNUO0FBQUEsa0JBQ0Y7QUFBQSxnQkFDRjtBQUFBLGNBQ0YsU0FBUyxHQUFHO0FBQ1Ysd0JBQVEsSUFBSSxDQUFDO0FBQUEsY0FDZjtBQUVBLHlCQUFXLGNBQWMsQ0FBQyxHQUFHLG9CQUFvQixHQUFHLGdCQUFnQixHQUFHO0FBQ3JFLG9CQUFJLGNBQWM7QUFDbEIsb0JBQUksU0FBUyxXQUFXO0FBQ3hCLG9CQUFJLFdBQVcsc0JBQXNCLFFBQVEsQ0FBQyxXQUFXLG1CQUFtQixTQUFTLEdBQUcsR0FBRztBQUN6RixzQkFBSSxXQUFXLG1CQUFtQixXQUFXLEdBQUc7QUFHOUMsNkJBQVM7QUFBQSxrQkFDWDtBQUNBLHNCQUFJLGdCQUFnQjtBQUNwQiw2QkFBVyxxQkFBcUIsV0FBVyxvQkFBb0I7QUFDN0Qsd0JBQUksY0FBYyxTQUFTLEdBQUc7QUFDNUIsdUNBQWlCO0FBQUEsb0JBQ25CO0FBQ0EscUNBQWlCLGVBQWUsa0JBQWtCLFFBQVEsS0FBTSxLQUFLLENBQUM7QUFBQSxrQkFDeEU7QUFDQSxzQkFBSSxjQUFjLFNBQVMsR0FBRztBQUM1QixxQ0FBaUI7QUFDakIsbUNBQWUsR0FBRyxhQUFhO0FBQUEsa0JBQ2pDO0FBQUEsZ0JBQ0Y7QUFDQSx3QkFBUSxtQkFBbUIsWUFBWSxTQUFTLElBQUksR0FBRyxXQUFXLE9BQU8sTUFBTSxPQUFPLE1BQU07QUFBQSxjQUM5RjtBQUVBLGtCQUFJLE1BQU0sT0FBTztBQUNqQixrQkFBSTtBQUNGLHNCQUFNLE9BQU8sY0FBYyxTQUFTO0FBQUEsY0FDdEMsU0FBUyxHQUFHO0FBQ1Ysd0JBQVEsSUFBSSxDQUFDO0FBQUEsY0FDZjtBQUNBLG1DQUFxQixlQUFlLFFBQVEsQ0FBQyxHQUFHLENBQUM7QUFFakQsa0JBQUk7QUFDRixzQkFBTSxVQUFVO0FBQUEsa0JBQ2QsT0FBTyxPQUFPLGNBQWMsUUFBUTtBQUFBLGtCQUNwQyxTQUFTLE9BQU8sY0FBYyxRQUFRO0FBQUEsa0JBQ3RDLFNBQVMsT0FBTyxjQUFjLFFBQVE7QUFBQSxrQkFDdEMsUUFBUSxPQUFPLGNBQWMsUUFBUTtBQUFBLGtCQUNyQyxRQUFRLE9BQU8sY0FBYyxRQUFRO0FBQUEsZ0JBQ3ZDO0FBQ0EsMkJBQVcsS0FBSyxTQUFTO0FBQ3ZCLG1CQUFDLFNBQVUsUUFBUTtBQUVqQiwyQkFBTyxjQUFjLFFBQVEsTUFBTSxJQUFJLFdBQVk7QUFDakQsMEJBQUksVUFBVTtBQUNkLCtCQUFTLEtBQUssV0FBVztBQUN2Qiw0QkFBSSxXQUFXLElBQUk7QUFDakIscUNBQVcsVUFBVSxDQUFDO0FBQUEsd0JBQ3hCLE9BQU87QUFDTCxxQ0FBVyxNQUFNLFVBQVUsQ0FBQztBQUFBLHdCQUM5QjtBQUFBLHNCQUNGO0FBRUEsOEJBQVEsTUFBTSxFQUFFLEtBQUssT0FBTyxjQUFjLFNBQVMsR0FBRyxTQUFTO0FBQy9ELDJDQUFxQixvQkFBb0IsUUFBUSxDQUFDLFFBQVEsT0FBTyxDQUFDO0FBQUEsb0JBQ3BFO0FBQUEsa0JBQ0YsR0FBRyxDQUFDO0FBQUEsZ0JBQ047QUFBQSxjQUNGLFNBQVMsR0FBRztBQUNWLHdCQUFRLElBQUksQ0FBQztBQUFBLGNBQ2Y7QUFFQSxrQkFBSTtBQUNGLHNCQUFNLG9CQUFvQixPQUFPLGNBQWMsUUFBUTtBQUN2RCx1QkFBTyxjQUFjLFFBQVEsWUFBWSxTQUFVLE9BQU8sUUFBUUEsTUFBSztBQUNyRSxvQ0FBa0IsS0FBSyxPQUFPLGNBQWUsU0FBUyxPQUFPLFFBQVFBLElBQUc7QUFDeEUsc0JBQUksWUFBWSxPQUFPO0FBQ3ZCLHNCQUFJO0FBQ0YsZ0NBQVksT0FBTyxjQUFlLFNBQVM7QUFBQSxrQkFDN0MsU0FBUyxHQUFHO0FBQ1YsNEJBQVEsSUFBSSxDQUFDO0FBQUEsa0JBQ2Y7QUFDQSx1Q0FBcUIsMEJBQTBCLFFBQVEsQ0FBQyxTQUFTLENBQUM7QUFBQSxnQkFDcEU7QUFFQSxzQkFBTSx1QkFBdUIsT0FBTyxjQUFjLFFBQVE7QUFDMUQsdUJBQU8sY0FBYyxRQUFRLGVBQWUsU0FBVSxPQUFPLFFBQVFBLE1BQUs7QUFDeEUsdUNBQXFCLEtBQUssT0FBTyxjQUFlLFNBQVMsT0FBTyxRQUFRQSxJQUFHO0FBQzNFLHNCQUFJLFlBQVksT0FBTztBQUN2QixzQkFBSTtBQUNGLGdDQUFZLE9BQU8sY0FBZSxTQUFTO0FBQUEsa0JBQzdDLFNBQVMsR0FBRztBQUNWLDRCQUFRLElBQUksQ0FBQztBQUFBLGtCQUNmO0FBQ0EsdUNBQXFCLDBCQUEwQixRQUFRLENBQUMsU0FBUyxDQUFDO0FBQUEsZ0JBQ3BFO0FBRUEsc0JBQU0sZ0JBQWdCLE9BQU8sY0FBYztBQUMzQyx1QkFBTyxjQUFjLFFBQVEsV0FBWTtBQUN2QyxnQ0FBYyxLQUFLLE9BQU8sYUFBYTtBQUN2Qyx1Q0FBcUIsaUJBQWlCLE1BQU07QUFBQSxnQkFDOUM7QUFFQSxzQkFBTSxlQUFlLE9BQU8sY0FBYztBQUMxQyx1QkFBTyxjQUFjLE9BQU8sU0FBVUEsTUFBSyxRQUFRLGdCQUFnQjtBQUNqRSx3QkFBTSxZQUFZLGFBQWEsS0FBSyxPQUFPLGVBQWUsR0FBRyxTQUFTO0FBQ3RFLHVDQUF1QyxrQkFBa0IsUUFBUSxDQUFDQSxNQUFLLFFBQVEsY0FBYyxDQUFDLEVBQUUsS0FBSyxTQUFVLGlCQUFpQjtBQUM5SCx3QkFBSSxpQkFBaUI7QUFDbkIsaUNBQVcsTUFBTTtBQUFBLG9CQUNuQjtBQUFBLGtCQUNGLENBQUM7QUFDRCx5QkFBTztBQUFBLGdCQUNUO0FBRUEsc0JBQU0sZ0JBQWdCLE9BQU8sY0FBYztBQUMzQyx1QkFBTyxjQUFjLFFBQVEsV0FBWTtBQUN2QyxzQkFBSSxZQUFZLE9BQU87QUFDdkIsc0JBQUk7QUFDRixnQ0FBWSxPQUFPLGNBQWUsU0FBUztBQUFBLGtCQUM3QyxTQUFTLEdBQUc7QUFDViw0QkFBUSxJQUFJLENBQUM7QUFBQSxrQkFDZjtBQUNBLHVDQUFxQixrQkFBa0IsUUFBUSxDQUFDLFNBQVMsQ0FBQztBQUMxRCxnQ0FBYyxLQUFLLE9BQU8sYUFBYTtBQUFBLGdCQUN6QztBQUVBLHdCQUFRLGNBQWM7QUFBQSxrQkFDcEIsZUFBZSxPQUFPLGNBQWM7QUFBQSxnQkFDdEM7QUFFQSxzQkFBTSxlQUFlLE9BQU8saUJBQWlCO0FBQzdDLHNCQUFNLFVBQVUsT0FBTyxpQkFBaUIsY0FBYyxPQUFPO0FBQzdELHdCQUFRLGdCQUFnQjtBQUN4QixxQ0FBcUIsa0JBQWtCLFFBQVEsQ0FBQyxZQUFZLENBQUM7QUFDN0Qsb0JBQUksV0FBVyxNQUFNO0FBQ25CLHNCQUFJLGlCQUFpQixTQUFVLFdBQVc7QUFDeEMsMEJBQU0sUUFBUyxVQUFVLENBQUMsRUFBRSxPQUF1QjtBQUNuRCx3QkFBSSxTQUFTLFFBQVEsZUFBZTtBQUNsQyw4QkFBUSxnQkFBZ0I7QUFDeEIsMkNBQXFCLGtCQUFrQixRQUFRLENBQUMsS0FBSyxDQUFDO0FBQUEsb0JBQ3hEO0FBQUEsa0JBQ0YsQ0FBQyxFQUFFO0FBQUEsb0JBQ0M7QUFBQSxvQkFDQSxFQUFDLFNBQVMsTUFBTSxlQUFlLE1BQU0sV0FBVyxLQUFJO0FBQUEsa0JBQ3hEO0FBQUEsZ0JBQ0Y7QUFFQSxvQkFBSSxnQkFBZ0IsT0FBTyxjQUFjO0FBQ3pDLHVCQUFPLGNBQWMsaUJBQWlCLFVBQVUsU0FBVSxHQUFHO0FBQzNELHdCQUFNLGdCQUFnQixPQUFPLGNBQWU7QUFDNUMsc0JBQUksa0JBQWtCLGVBQWU7QUFDbkMseUNBQXFCLHNCQUFzQixRQUFRLENBQUMsZUFBZSxhQUFhLENBQUM7QUFDakYsb0NBQWdCO0FBQUEsa0JBQ2xCO0FBQUEsZ0JBQ0YsQ0FBQztBQUVELHVCQUFPLGNBQWMsaUJBQWlCLFlBQVksU0FBVUMsUUFBYztBQUN4RSxzQkFBSSxZQUFZLE9BQU87QUFDdkIsc0JBQUk7QUFDRixnQ0FBWSxPQUFPLGNBQWUsU0FBUztBQUFBLGtCQUM3QyxTQUFTLEdBQUc7QUFDViw0QkFBUSxJQUFJLENBQUM7QUFBQSxrQkFDZjtBQUNBLHVDQUFxQiwwQkFBMEIsUUFBUSxDQUFDLFNBQVMsQ0FBQztBQUFBLGdCQUNwRSxDQUFDO0FBRUQsdUJBQU8sY0FBYyxpQkFBaUIsVUFBVSxTQUFVQSxRQUFjO0FBQ3RFLHNCQUFJLElBQUk7QUFDUixzQkFBSSxJQUFJO0FBQ1Isc0JBQUk7QUFDRix3QkFBSSxPQUFPLGNBQWU7QUFDMUIsd0JBQUksT0FBTyxjQUFlO0FBQUEsa0JBQzVCLFNBQVMsR0FBRztBQUNWLDRCQUFRLElBQUksQ0FBQztBQUFBLGtCQUNmO0FBQ0EsdUNBQXFCLG1CQUFtQixRQUFRLENBQUMsR0FBRyxDQUFDLENBQUM7QUFBQSxnQkFDeEQsQ0FBQztBQUVELHVCQUFPLGNBQWMsaUJBQWlCLFNBQVMsU0FBVUEsUUFBYztBQUNyRSx1Q0FBcUIsaUJBQWlCLE1BQU07QUFBQSxnQkFDOUMsQ0FBQztBQUVELHVCQUFPLGNBQWMsaUJBQWlCLFFBQVEsU0FBVUEsUUFBYztBQUNwRSx1Q0FBcUIsZ0JBQWdCLE1BQU07QUFBQSxnQkFDN0MsQ0FBQztBQUFBLGNBQ0gsU0FBUyxHQUFHO0FBQ1Ysd0JBQVEsSUFBSSxDQUFDO0FBQUEsY0FDZjtBQUVBLGtCQUFJO0FBQ0Ysb0JBQUksQ0FBQyxRQUFRLFNBQVMsdUNBQXVDO0FBQzNELHlCQUFPLGNBQWMsT0FBTyxXQUFZO0FBQ3RDLDBCQUFNLElBQUksTUFBTSw4Q0FBOEM7QUFBQSxrQkFDaEU7QUFBQSxnQkFDRjtBQUVBLG9CQUFJLENBQUMsUUFBUSxTQUFTLDRCQUE0QixDQUFDLFFBQVEsU0FBUyw0QkFBNEI7QUFDOUYsd0JBQU0sUUFBUSxPQUFPLGlCQUFpQixjQUFjLE9BQU87QUFDM0Qsc0JBQUksU0FBUyxNQUFNO0FBQ2pCLDBCQUFNLEtBQUs7QUFDWCwwQkFBTSxZQUFZO0FBQ2xCLDJCQUFPLGlCQUFpQixLQUFLLE9BQU8sS0FBSztBQUFBLGtCQUMzQztBQUFBLGdCQUNGO0FBRUEsb0JBQUksUUFBUSxTQUFTLHVCQUF1QjtBQUMxQyx3QkFBTSxRQUFRLE9BQU8saUJBQWlCLGNBQWMsT0FBTztBQUMzRCxzQkFBSSxTQUFTLE1BQU07QUFDakIsMEJBQU0sS0FBSztBQUNYLDBCQUFNLFlBQVk7QUFDbEIsMkJBQU8saUJBQWlCLEtBQUssT0FBTyxLQUFLO0FBQUEsa0JBQzNDO0FBQUEsZ0JBQ0Y7QUFFQSxvQkFBSSxRQUFRLFNBQVMseUJBQXlCO0FBQzVDLHdCQUFNLFFBQVEsT0FBTyxpQkFBaUIsY0FBYyxPQUFPO0FBQzNELHNCQUFJLFNBQVMsTUFBTTtBQUNqQiwwQkFBTSxLQUFLO0FBQ1gsMEJBQU0sWUFBWTtBQUNsQiwyQkFBTyxpQkFBaUIsS0FBSyxPQUFPLEtBQUs7QUFBQSxrQkFDM0M7QUFBQSxnQkFDRjtBQUVBLG9CQUFJLFFBQVEsU0FBUyxvQkFBb0I7QUFDdkMseUJBQU8sY0FBYyxpQkFBaUIsZUFBZSxRQUFRLHlCQUF5QjtBQUFBLGdCQUN4RjtBQUFBLGNBQ0YsU0FBUyxHQUFHO0FBQ1Ysd0JBQVEsSUFBSSxDQUFDO0FBQUEsY0FDZjtBQUVBLG1DQUFxQixjQUFjLFFBQVEsQ0FBQyxHQUFHLENBQUM7QUFFaEQsa0JBQUk7QUFDRix1QkFBTyxjQUFjLGNBQWMsSUFBSSxNQUFNLGtDQUFrQyxDQUFDO0FBQUEsY0FDbEYsU0FBUyxHQUFHO0FBQ1Ysd0JBQVEsSUFBSSxDQUFDO0FBQUEsY0FDZjtBQUFBLFlBRUYsR0FBRyxFQUFFLFFBQVEsUUFBUSx3QkFBd0IsT0FBTyxDQUFDO0FBQUEsVUFDdkQ7QUFBQSxRQUNGO0FBQUEsUUFDQSxhQUFhLFNBQVUsYUFBbUM7QUFDeEQsZ0JBQU1DLFVBQVMsUUFBUTtBQUN2QixjQUFJQSxXQUFVLE1BQU07QUFDbEI7QUFBQSxVQUNGO0FBQ0EsY0FBSTtBQUNGLGdCQUFJLFFBQVEsU0FBUyx5Q0FBeUMsWUFBWSx1Q0FBdUM7QUFDL0csa0JBQUksQ0FBQyxZQUFZLHVDQUF1QztBQUN0RCxnQkFBQUEsUUFBTyxjQUFlLE9BQU8sV0FBWTtBQUN2Qyx3QkFBTSxJQUFJLE1BQU0sOENBQThDO0FBQUEsZ0JBQ2hFO0FBQUEsY0FDRixPQUFPO0FBQ0wsZ0JBQUFBLFFBQU8sY0FBZSxPQUFPLFFBQVEsWUFBWSxhQUFhO0FBQUEsY0FDaEU7QUFBQSxZQUNGO0FBRUEsZ0JBQUksUUFBUSxTQUFTLDRCQUE0QixZQUFZLDRCQUN6RCxRQUFRLFNBQVMsOEJBQThCLFlBQVksNEJBQTRCO0FBQ3pGLGtCQUFJLENBQUMsWUFBWSw0QkFBNEIsQ0FBQyxZQUFZLDRCQUE0QjtBQUNwRixzQkFBTSxRQUFRQSxRQUFPLGlCQUFpQixjQUFjLE9BQU87QUFDM0Qsb0JBQUksU0FBUyxNQUFNO0FBQ2pCLHdCQUFNLEtBQUs7QUFDWCx3QkFBTSxZQUFZO0FBQ2xCLGtCQUFBQSxRQUFPLGlCQUFpQixLQUFLLE9BQU8sS0FBSztBQUFBLGdCQUMzQztBQUFBLGNBQ0YsT0FBTztBQUNMLHNCQUFNLGVBQWVBLFFBQU8saUJBQWlCLGVBQWUsdUVBQXVFO0FBQ25JLG9CQUFJLGNBQWM7QUFDaEIsK0JBQWEsT0FBTztBQUFBLGdCQUN0QjtBQUFBLGNBQ0Y7QUFBQSxZQUNGO0FBRUEsZ0JBQUksUUFBUSxTQUFTLHlCQUF5QixZQUFZLHVCQUF1QjtBQUMvRSxrQkFBSSxZQUFZLHVCQUF1QjtBQUNyQyxzQkFBTSxRQUFRQSxRQUFPLGlCQUFpQixjQUFjLE9BQU87QUFDM0Qsb0JBQUksU0FBUyxNQUFNO0FBQ2pCLHdCQUFNLEtBQUs7QUFDWCx3QkFBTSxZQUFZO0FBQ2xCLGtCQUFBQSxRQUFPLGlCQUFpQixLQUFLLE9BQU8sS0FBSztBQUFBLGdCQUMzQztBQUFBLGNBQ0YsT0FBTztBQUNMLHNCQUFNLGVBQWVBLFFBQU8saUJBQWlCLGVBQWUsZ0NBQWdDO0FBQzVGLG9CQUFJLGNBQWM7QUFDaEIsK0JBQWEsT0FBTztBQUFBLGdCQUN0QjtBQUFBLGNBQ0Y7QUFBQSxZQUNGO0FBRUEsZ0JBQUksUUFBUSxTQUFTLDJCQUEyQixZQUFZLHlCQUF5QjtBQUNuRixrQkFBSSxZQUFZLHlCQUF5QjtBQUN2QyxzQkFBTSxRQUFRQSxRQUFPLGlCQUFpQixjQUFjLE9BQU87QUFDM0Qsb0JBQUksU0FBUyxNQUFNO0FBQ2pCLHdCQUFNLEtBQUs7QUFDWCx3QkFBTSxZQUFZO0FBQ2xCLGtCQUFBQSxRQUFPLGlCQUFpQixLQUFLLE9BQU8sS0FBSztBQUFBLGdCQUMzQztBQUFBLGNBQ0YsT0FBTztBQUNMLHNCQUFNLGVBQWVBLFFBQU8saUJBQWlCLGVBQWUsa0NBQWtDO0FBQzlGLG9CQUFJLGNBQWM7QUFDaEIsK0JBQWEsT0FBTztBQUFBLGdCQUN0QjtBQUFBLGNBQ0Y7QUFBQSxZQUNGO0FBRUEsZ0JBQUksUUFBUSxTQUFTLHNCQUFzQixZQUFZLG9CQUFvQjtBQUN6RSxrQkFBSSxZQUFZLG9CQUFvQjtBQUNsQyxnQkFBQUEsUUFBTyxlQUFlLGlCQUFpQixlQUFlLFFBQVEseUJBQXlCO0FBQUEsY0FDekYsT0FBTztBQUNMLGdCQUFBQSxRQUFPLGVBQWUsb0JBQW9CLGVBQWUsUUFBUSx5QkFBeUI7QUFBQSxjQUM1RjtBQUFBLFlBQ0Y7QUFBQSxVQUNGLFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFFQSxrQkFBUSxXQUFXO0FBQUEsUUFDckI7QUFBQSxRQUNBLFFBQVEsV0FBWTtBQUNsQixjQUFJQSxVQUFTLFFBQVE7QUFDckIsY0FBSUEsV0FBVSxRQUFRQSxRQUFPLGlCQUFpQixNQUFNO0FBQ2xELGdCQUFJO0FBQ0YsY0FBQUEsUUFBTyxjQUFjLFNBQVMsT0FBTztBQUFBLFlBQ3ZDLFNBQVMsR0FBRztBQUNWLHNCQUFRLElBQUksQ0FBQztBQUNiLGNBQUFBLFFBQU8sY0FBYyxTQUFTLE9BQU9BLFFBQU87QUFBQSxZQUM5QztBQUFBLFVBQ0Y7QUFBQSxRQUNGO0FBQUEsUUFDQSxRQUFRLFdBQVk7QUFDbEIsY0FBSUEsVUFBUyxRQUFRO0FBQ3JCLGNBQUlBLFdBQVUsTUFBTTtBQUNsQixnQkFBSTtBQUNGLGNBQUFBLFFBQU8sZUFBZSxRQUFRLEtBQUs7QUFBQSxZQUNyQyxTQUFTLEdBQUc7QUFDVixzQkFBUSxJQUFJLENBQUM7QUFBQSxZQUNmO0FBQUEsVUFDRjtBQUFBLFFBQ0Y7QUFBQSxRQUNBLFdBQVcsV0FBWTtBQUNyQixjQUFJQSxVQUFTLFFBQVE7QUFDckIsY0FBSUEsV0FBVSxNQUFNO0FBQ2xCLGdCQUFJO0FBQ0YsY0FBQUEsUUFBTyxlQUFlLFFBQVEsUUFBUTtBQUFBLFlBQ3hDLFNBQVMsR0FBRztBQUNWLHNCQUFRLElBQUksQ0FBQztBQUFBLFlBQ2Y7QUFBQSxVQUNGO0FBQUEsUUFDRjtBQUFBLFFBQ0EsaUJBQWlCLFNBQVUsT0FBTztBQUNoQyxjQUFJQSxVQUFTLFFBQVE7QUFDckIsY0FBSUEsV0FBVSxNQUFNO0FBQ2xCLGdCQUFJO0FBQ0YsY0FBQUEsUUFBTyxlQUFlLFFBQVEsR0FBRyxLQUFLO0FBQUEsWUFDeEMsU0FBUyxHQUFHO0FBQ1Ysc0JBQVEsSUFBSSxDQUFDO0FBQUEsWUFDZjtBQUFBLFVBQ0Y7QUFBQSxRQUNGO0FBQUEsUUFDQSxvQkFBb0IsU0FBVSxRQUFRO0FBQ3BDLGdCQUFNQSxVQUFTLFFBQVE7QUFDdkIsY0FBSSxTQUFTO0FBQ2IsY0FBSUEsV0FBVSxNQUFNO0FBQ2xCLGdCQUFJO0FBQ0YsdUJBQVMsS0FBSyxVQUFVQSxRQUFPLGVBQWUsS0FBSyxNQUFNLENBQUM7QUFBQSxZQUM1RCxTQUFTLEdBQUc7QUFBQSxZQUNaO0FBQUEsVUFDRjtBQUNBLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsYUFBYSxXQUFZO0FBQ3ZCLGdCQUFNQSxVQUFTLFFBQVE7QUFDdkIsY0FBSUEsV0FBVSxNQUFNO0FBQ2xCLGdCQUFJO0FBQ0YsY0FBQUEsUUFBTyxlQUFlLEtBQUs7QUFBQSxZQUM3QixTQUFTLEdBQUc7QUFDVixzQkFBUSxJQUFJLENBQUM7QUFBQSxZQUNmO0FBQUEsVUFDRjtBQUFBLFFBQ0Y7QUFBQSxRQUNBLFFBQVEsV0FBWTtBQUNsQixnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUksTUFBTUEsU0FBUTtBQUNsQixjQUFJO0FBQ0Ysa0JBQU1BLFNBQVEsZUFBZSxTQUFTO0FBQUEsVUFDeEMsU0FBUyxHQUFHO0FBQ1Ysb0JBQVEsSUFBSSxDQUFDO0FBQUEsVUFDZjtBQUNBLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsVUFBVSxXQUFZO0FBQ3BCLGdCQUFNQSxVQUFTLFFBQVE7QUFDdkIsY0FBSSxRQUFRO0FBQ1osY0FBSTtBQUNGLG9CQUFRQSxTQUFRLGlCQUFpQjtBQUFBLFVBQ25DLFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFDQSxpQkFBTztBQUFBLFFBQ1Q7QUFBQSxRQUNBLDZCQUE2QixTQUFVLFNBQVMseUJBQXlCO0FBQ3ZFLGdCQUFNQSxVQUFTLFFBQVE7QUFDdkIsY0FBSTtBQUNGLGtCQUFNLElBQUlBLFNBQVE7QUFDbEIsZ0JBQUksS0FBSyxNQUFNO0FBQ2I7QUFBQSxZQUNGO0FBQ0Esa0JBQU0sU0FBUyxFQUFFLGNBQWMsUUFBUTtBQUN2Qyx1QkFBVyxPQUFPLE9BQU8sS0FBSyx1QkFBdUIsR0FBRztBQUN0RCxrQkFBSSx3QkFBd0IsR0FBRyxLQUFLLE1BQU07QUFFeEMsdUJBQU8sR0FBRyxJQUFJLHdCQUF3QixHQUFHO0FBQUEsY0FDM0M7QUFBQSxZQUNGO0FBQ0EsZ0JBQUksT0FBTyxNQUFNLE1BQU07QUFDckIscUJBQU8sU0FBUyxXQUFZO0FBQzFCLHFDQUFxQiwwQkFBMEIsUUFBUSxRQUFRLENBQUMsT0FBTyxFQUFFLENBQUM7QUFBQSxjQUM1RTtBQUNBLHFCQUFPLFVBQVUsV0FBWTtBQUMzQixxQ0FBcUIseUJBQXlCLFFBQVEsUUFBUSxDQUFDLE9BQU8sRUFBRSxDQUFDO0FBQUEsY0FDM0U7QUFBQSxZQUNGO0FBQ0EsbUJBQU8sTUFBTTtBQUNiLGdCQUFJLEVBQUUsUUFBUSxNQUFNO0FBQ2xCLGdCQUFFLEtBQUssWUFBWSxNQUFNO0FBQUEsWUFDM0I7QUFBQSxVQUNGLFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFBQSxRQUNGO0FBQUEsUUFDQSxlQUFlLFNBQVUsUUFBUTtBQUMvQixnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixrQkFBTSxJQUFJQSxTQUFRO0FBQ2xCLGdCQUFJLEtBQUssTUFBTTtBQUNiO0FBQUEsWUFDRjtBQUNBLGtCQUFNLFFBQVEsRUFBRSxjQUFjLE9BQU87QUFDckMsa0JBQU0sWUFBWTtBQUNsQixnQkFBSSxFQUFFLFFBQVEsTUFBTTtBQUNsQixnQkFBRSxLQUFLLFlBQVksS0FBSztBQUFBLFlBQzFCO0FBQUEsVUFDRixTQUFTLEdBQUc7QUFDVixvQkFBUSxJQUFJLENBQUM7QUFBQSxVQUNmO0FBQUEsUUFDRjtBQUFBLFFBQ0Esc0JBQXNCLFNBQVUsU0FBUywwQkFBMEI7QUFDakUsZ0JBQU1BLFVBQVMsUUFBUTtBQUN2QixjQUFJO0FBQ0Ysa0JBQU0sSUFBSUEsU0FBUTtBQUNsQixnQkFBSSxLQUFLLE1BQU07QUFDYjtBQUFBLFlBQ0Y7QUFDQSxrQkFBTSxPQUFPLEVBQUUsY0FBYyxNQUFNO0FBQ25DLHVCQUFXLE9BQU8sT0FBTyxLQUFLLHdCQUF3QixHQUFHO0FBQ3ZELGtCQUFJLHlCQUF5QixHQUFHLEtBQUssTUFBTTtBQUV6QyxxQkFBSyxHQUFHLElBQUkseUJBQXlCLEdBQUc7QUFBQSxjQUMxQztBQUFBLFlBQ0Y7QUFDQSxpQkFBSyxPQUFPO0FBQ1osZ0JBQUksc0JBQXNCO0FBQzFCLGdCQUFJLHlCQUF5QixxQkFBcUI7QUFDaEQsb0NBQXNCO0FBQUEsWUFDeEI7QUFDQSxpQkFBSyxNQUFNLHNCQUFzQjtBQUNqQyxpQkFBSyxPQUFPO0FBQ1osZ0JBQUksRUFBRSxRQUFRLE1BQU07QUFDbEIsZ0JBQUUsS0FBSyxZQUFZLElBQUk7QUFBQSxZQUN6QjtBQUFBLFVBQ0YsU0FBUyxHQUFHO0FBQ1Ysb0JBQVEsSUFBSSxDQUFDO0FBQUEsVUFDZjtBQUFBLFFBQ0Y7QUFBQSxRQUNBLFVBQVUsU0FBVSxHQUFHLEdBQUcsVUFBVTtBQUNsQyxnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixnQkFBSSxVQUFVO0FBQ1osY0FBQUEsU0FBUSxlQUFlLFNBQVMsRUFBQyxLQUFLLEdBQUcsTUFBTSxHQUFHLFVBQVUsU0FBUSxDQUFDO0FBQUEsWUFDdkUsT0FBTztBQUNMLGNBQUFBLFNBQVEsZUFBZSxTQUFTLEdBQUcsQ0FBQztBQUFBLFlBQ3RDO0FBQUEsVUFDRixTQUFTLEdBQUc7QUFDVixvQkFBUSxJQUFJLENBQUM7QUFBQSxVQUNmO0FBQUEsUUFDRjtBQUFBLFFBQ0EsVUFBVSxTQUFVLEdBQUcsR0FBRyxVQUFVO0FBQ2xDLGdCQUFNQSxVQUFTLFFBQVE7QUFDdkIsY0FBSTtBQUNGLGdCQUFJLFVBQVU7QUFDWixjQUFBQSxTQUFRLGVBQWUsU0FBUyxFQUFDLEtBQUssR0FBRyxNQUFNLEdBQUcsVUFBVSxTQUFRLENBQUM7QUFBQSxZQUN2RSxPQUFPO0FBQ0wsY0FBQUEsU0FBUSxlQUFlLFNBQVMsR0FBRyxDQUFDO0FBQUEsWUFDdEM7QUFBQSxVQUNGLFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFBQSxRQUNGO0FBQUEsUUFDQSxrQkFBa0IsV0FBWTtBQUM1QixnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixZQUFBQSxTQUFRLGVBQWUsTUFBTTtBQUFBLFVBQy9CLFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFBQSxRQUNGO0FBQUEsUUFDQSxrQkFBa0IsV0FBWTtBQUM1QixnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixtQkFBT0EsU0FBUSxpQkFBaUIsZ0JBQWdCO0FBQUEsVUFDbEQsU0FBUyxHQUFHO0FBQ1Ysb0JBQVEsSUFBSSxDQUFDO0FBQUEsVUFDZjtBQUNBLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsaUJBQWlCLFdBQVk7QUFDM0IsZ0JBQU1BLFVBQVMsUUFBUTtBQUN2QixjQUFJO0FBQ0YsbUJBQU9BLFNBQVEsaUJBQWlCLGdCQUFnQjtBQUFBLFVBQ2xELFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFDQSxpQkFBTztBQUFBLFFBQ1Q7QUFBQSxRQUNBLGlCQUFpQixXQUFZO0FBQzNCLGdCQUFNQSxVQUFTLFFBQVE7QUFDdkIsY0FBSTtBQUNGLGdCQUFJO0FBQ0osa0JBQU0sSUFBSUEsU0FBUTtBQUNsQixnQkFBSSxLQUFLLE1BQU07QUFDYixxQkFBTztBQUFBLFlBQ1Q7QUFDQSxnQkFBSSxFQUFFLGNBQWM7QUFDbEIsb0JBQU0sRUFBRSxhQUFhLEdBQUcsU0FBUztBQUFBLFlBQ25DLFdBQVcsRUFBRSxTQUFTLGNBQWM7QUFDbEMsb0JBQU0sRUFBRSxTQUFTLGFBQWEsR0FBRyxTQUFTO0FBQUEsWUFFNUMsV0FBVyxFQUFFLFNBQVMsV0FBVztBQUUvQixvQkFBTSxFQUFFLFNBQVMsVUFBVSxZQUFZLEVBQUU7QUFBQSxZQUMzQztBQUNBLG1CQUFPO0FBQUEsVUFDVCxTQUFTLEdBQUc7QUFDVixvQkFBUSxJQUFJLENBQUM7QUFBQSxVQUNmO0FBQ0EsaUJBQU87QUFBQSxRQUNUO0FBQUEsUUFDQSxZQUFZLFdBQVk7QUFDdEIsZ0JBQU1BLFVBQVMsUUFBUTtBQUN2QixjQUFJO0FBQ0YsbUJBQU9BLFNBQVEsZUFBZTtBQUFBLFVBQ2hDLFNBQVMsR0FBRztBQUNWLG9CQUFRLElBQUksQ0FBQztBQUFBLFVBQ2Y7QUFDQSxpQkFBTztBQUFBLFFBQ1Q7QUFBQSxRQUNBLFlBQVksV0FBWTtBQUN0QixnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixtQkFBT0EsU0FBUSxlQUFlO0FBQUEsVUFDaEMsU0FBUyxHQUFHO0FBQ1Ysb0JBQVEsSUFBSSxDQUFDO0FBQUEsVUFDZjtBQUNBLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsaUJBQWlCLFdBQVk7QUFDM0IsZ0JBQU1BLFVBQVMsUUFBUTtBQUN2QixjQUFJO0FBQ0YsbUJBQU9BLFNBQVEsZUFBZSxtQkFBbUI7QUFBQSxVQUNuRCxTQUFTLEdBQUc7QUFDVixvQkFBUSxJQUFJLENBQUM7QUFBQSxVQUNmO0FBQ0EsaUJBQU87QUFBQSxRQUNUO0FBQUEsUUFDQSxxQkFBcUIsV0FBWTtBQUMvQixnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixvQkFBUUEsU0FBUSxpQkFBaUIsS0FBSyxnQkFBZ0IsTUFBTUEsU0FBUSxlQUFlLGVBQWU7QUFBQSxVQUNwRyxTQUFTLEdBQUc7QUFDVixvQkFBUSxJQUFJLENBQUM7QUFBQSxVQUNmO0FBQ0EsaUJBQU87QUFBQSxRQUNUO0FBQUEsUUFDQSx1QkFBdUIsV0FBWTtBQUNqQyxnQkFBTUEsVUFBUyxRQUFRO0FBQ3ZCLGNBQUk7QUFDRixvQkFBUUEsU0FBUSxpQkFBaUIsS0FBSyxlQUFlLE1BQU1BLFNBQVEsZUFBZSxjQUFjO0FBQUEsVUFDbEcsU0FBUyxHQUFHO0FBQ1Ysb0JBQVEsSUFBSSxDQUFDO0FBQUEsVUFDZjtBQUNBLGlCQUFPO0FBQUEsUUFDVDtBQUFBLFFBQ0EsU0FBUyxXQUFZO0FBQ25CLGdCQUFNQyxtQkFBa0IsUUFBUTtBQUNoQyxjQUFJLFFBQVE7QUFDWixjQUFJLFNBQVM7QUFDYixjQUFJQSxvQkFBbUIsTUFBTTtBQUMzQixnQkFBSUEsaUJBQWdCLE1BQU0sU0FBUyxRQUFRQSxpQkFBZ0IsTUFBTSxTQUFTLE1BQU1BLGlCQUFnQixNQUFNLE1BQU0sUUFBUSxJQUFJLElBQUksR0FBRztBQUM3SCxzQkFBUSxXQUFXQSxpQkFBZ0IsTUFBTSxLQUFLO0FBQUEsWUFDaEQ7QUFDQSxnQkFBSSxTQUFTLFFBQVEsU0FBUyxHQUFLO0FBQ2pDLHNCQUFRQSxpQkFBZ0Isc0JBQXNCLEVBQUU7QUFBQSxZQUNsRDtBQUNBLGdCQUFJQSxpQkFBZ0IsTUFBTSxVQUFVLFFBQVFBLGlCQUFnQixNQUFNLFVBQVUsTUFBTUEsaUJBQWdCLE1BQU0sT0FBTyxRQUFRLElBQUksSUFBSSxHQUFHO0FBQ2hJLHVCQUFTLFdBQVdBLGlCQUFnQixNQUFNLE1BQU07QUFBQSxZQUNsRDtBQUNBLGdCQUFJLFVBQVUsUUFBUSxVQUFVLEdBQUs7QUFDbkMsdUJBQVNBLGlCQUFnQixzQkFBc0IsRUFBRTtBQUFBLFlBQ25EO0FBQUEsVUFDRjtBQUNBLGlCQUFPO0FBQUEsWUFDTDtBQUFBLFlBQ0E7QUFBQSxVQUNGO0FBQUEsUUFDRjtBQUFBLE1BQ0Y7QUFFQSxhQUFPO0FBQUEsSUFDVDtBQUFBLElBQ0EseUJBQXlCLFNBQVUsV0FBbUI7QUFDcEQsYUFBUSxJQUFJLEtBQUssU0FBUyxFQUFHLFlBQVk7QUFBQSxJQUMzQztBQUFBLElBQ0EsMEJBQTBCLFNBQVUsUUFBZ0IsUUFBeUIsTUFBYztBQUN6RixZQUFNLElBQUksTUFBTSx5QkFBeUI7QUFBQSxJQUMzQztBQUFBLElBQ0EseUJBQXlCLFNBQVUsUUFBZ0IsUUFBeUIsTUFBYztBQUN4RixZQUFNLElBQUksTUFBTSx5QkFBeUI7QUFBQSxJQUMzQztBQUFBLElBQ0EscUJBQXFCLFNBQVUsUUFBZ0IsUUFBeUIsTUFBYztBQUNwRixVQUFJO0FBQ0YsY0FBTSxTQUFTLE9BQU8sNEJBQTRCLHdCQUF3QixRQUFRLFFBQVEsSUFBSTtBQUM5RixlQUFPLFVBQVUsT0FBTyxLQUFLLE1BQU0sTUFBTSxJQUFJO0FBQUEsTUFDL0MsU0FBUyxJQUFJO0FBQ1gsWUFBSTtBQUNGLGdCQUFNLFVBQVUsT0FBTyw0QkFBNEIseUJBQXlCLFFBQVEsUUFBUSxJQUFJO0FBQ2hHLGlCQUFPLFFBQVEsS0FBSyxTQUFVLFFBQVE7QUFDcEMsbUJBQU8sVUFBVSxPQUFPLEtBQUssTUFBTSxNQUFNLElBQUk7QUFBQSxVQUMvQyxDQUFDO0FBQUEsUUFDSCxTQUFTLElBQUk7QUFDWCxpQkFBTztBQUFBLFFBQ1Q7QUFBQSxNQUNGO0FBQUEsSUFDRjtBQUFBLEVBQ0Y7QUFFQSxNQUFJLHVCQUF1QixPQUFPLDRCQUE0QjtBQUNoRSxHQUFHOyIsCiAgIm5hbWVzIjogWyJ1cmwiLCAiZXZlbnQiLCAiaWZyYW1lIiwgImlmcmFtZUNvbnRhaW5lciJdCn0K
