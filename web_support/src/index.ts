import {
  InAppWebView,
  InAppWebViewPlugin,
  InAppWebViewSettings,
  JavaScriptBridgeHandler,
  UserScript,
  UserScriptInjectionTime
} from "./types";

declare global {
  interface Window {
    flutter_inappwebview_plugin: InAppWebViewPlugin;
    flutter_inappwebview?: JavaScriptBridgeHandler | null;
    console: Console;

    eval(x: string): any;
  }
}

(function () {
  let _JSON_stringify = window.JSON.stringify;
  let _Array_slice = window.Array.prototype.slice;
  _Array_slice.call = window.Function.prototype.call;

  window.flutter_inappwebview_plugin = {
    createFlutterInAppWebView: function (viewId: number | string, iframe: HTMLIFrameElement, iframeContainer: HTMLDivElement, bridgeSecret: string) {
      const iframeId = iframe.id;
      const webView: InAppWebView = {
        viewId: viewId,
        iframeId: iframeId,
        iframe: null,
        iframeContainer: null,
        isFullscreen: false,
        documentTitle: null,
        functionMap: {},
        settings: {},
        javaScriptBridgeEnabled: true,
        disableContextMenuHandler: function (event: Event) {
          event.preventDefault();
          event.stopPropagation();
          return false;
        },
        prepare: function (settings: InAppWebViewSettings) {
          webView.settings = settings;

          webView.javaScriptBridgeEnabled = webView.settings.javaScriptBridgeEnabled ?? true;
          const javaScriptBridgeOriginAllowList = webView.settings.javaScriptBridgeOriginAllowList;
          if (javaScriptBridgeOriginAllowList != null && !javaScriptBridgeOriginAllowList.includes("*")) {
            if (javaScriptBridgeOriginAllowList.length === 0) {
              // an empty list means that the JavaScript Bridge is not allowed for any origin.
              webView.javaScriptBridgeEnabled = false;
            }
          }

          document.addEventListener('fullscreenchange', function (event: Event) {
            // document.fullscreenElement will point to the element that
            // is in fullscreen mode if there is one. If there isn't one,
            // the value of the property is null.
            if (document.fullscreenElement && document.fullscreenElement.id == iframeId) {
              webView.isFullscreen = true;
              _nativeCommunication('onEnterFullscreen', viewId);
            } else if (!document.fullscreenElement && webView.isFullscreen) {
              webView.isFullscreen = false;
              _nativeCommunication('onExitFullscreen', viewId);
            } else {
              webView.isFullscreen = false;
            }
          });

          if (iframe != null) {
            webView.iframe = iframe;
            webView.iframeContainer = iframeContainer;
            iframe.addEventListener('load', function (event: Event) {
              if (iframe.contentWindow == null) {
                return;
              }

              const userScriptsAtStart = _nativeCommunication<UserScript[]>('getUserOnlyScriptsAt', viewId, [UserScriptInjectionTime.AT_DOCUMENT_START]);
              const userScriptsAtEnd = _nativeCommunication<UserScript[]>('getUserOnlyScriptsAt', viewId, [UserScriptInjectionTime.AT_DOCUMENT_END]);

              try {
                let javaScriptBridgeEnabled = webView.javaScriptBridgeEnabled;
                if (javaScriptBridgeOriginAllowList != null) {
                  javaScriptBridgeEnabled = javaScriptBridgeOriginAllowList
                      .map(allowedOriginRule => new RegExp(allowedOriginRule))
                      .some((rx) => {
                        return rx.test(iframe.contentWindow!.location.origin);
                      })
                }
                if (javaScriptBridgeEnabled) {
                  const javaScriptBridgeName = _nativeCommunication<string>('getJavaScriptBridgeName', viewId);
                  // @ts-ignore
                  iframe.contentWindow![javaScriptBridgeName] = {
                    callHandler: function () {
                      let origin = '';
                      let requestUrl = '';
                      try {
                        origin = iframe.contentWindow!.location.origin;
                      } catch (_) {
                      }
                      try {
                        requestUrl = iframe.contentWindow!.location.href;
                      } catch (_) {
                      }
                      return _nativeCommunication('onCallJsHandler',
                          viewId,
                          [arguments[0], _JSON_stringify({
                            'origin': origin,
                            'requestUrl': requestUrl,
                            'isMainFrame': true,
                            '_bridgeSecret': bridgeSecret,
                            'args': _JSON_stringify(_Array_slice.call(arguments, 1))
                          })]);
                    }
                  } as JavaScriptBridgeHandler;
                }
              } catch (e) {
                console.log(e);
              }

              for (const userScript of [...userScriptsAtStart, ...userScriptsAtEnd]) {
                let ifStatement = "if (";
                let source = userScript.source;
                if (userScript.allowedOriginRules != null && !userScript.allowedOriginRules.includes("*")) {
                  if (userScript.allowedOriginRules.length === 0) {
                    // return empty source string if allowedOriginRules is an empty list.
                    // an empty list means that this UserScript is not allowed for any origin.
                    source = "";
                  }
                  let jsRegExpArray = "[";
                  for (const allowedOriginRule of userScript.allowedOriginRules) {
                    if (jsRegExpArray.length > 1) {
                      jsRegExpArray += ",";
                    }
                    jsRegExpArray += `new RegExp('${allowedOriginRule.replace("\'", "\\'")}')`;
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
              _nativeCommunication('onLoadStart', viewId, [url]);

              try {
                const oldLogs = {
                  'log': iframe.contentWindow.console.log,
                  'debug': iframe.contentWindow.console.debug,
                  'error': iframe.contentWindow.console.error,
                  'info': iframe.contentWindow.console.info,
                  'warn': iframe.contentWindow.console.warn
                };
                for (const k in oldLogs) {
                  (function (oldLog) {
                    // @ts-ignore
                    iframe.contentWindow.console[oldLog] = function () {
                      var message = '';
                      for (var i in arguments) {
                        if (message == '') {
                          message += arguments[i];
                        } else {
                          message += ' ' + arguments[i];
                        }
                      }
                      // @ts-ignore
                      oldLogs[oldLog].call(iframe.contentWindow.console, ...arguments);
                      _nativeCommunication('onConsoleMessage', viewId, [oldLog, message]);
                    }
                  })(k);
                }
              } catch (e) {
                console.log(e);
              }

              try {
                const originalPushState = iframe.contentWindow.history.pushState;
                iframe.contentWindow.history.pushState = function (state, unused, url) {
                  originalPushState.call(iframe.contentWindow!.history, state, unused, url);
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow!.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication('onUpdateVisitedHistory', viewId, [iframeUrl]);
                };

                const originalReplaceState = iframe.contentWindow.history.replaceState;
                iframe.contentWindow.history.replaceState = function (state, unused, url) {
                  originalReplaceState.call(iframe.contentWindow!.history, state, unused, url);
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow!.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication('onUpdateVisitedHistory', viewId, [iframeUrl]);
                };

                const originalClose = iframe.contentWindow.close;
                iframe.contentWindow.close = function () {
                  originalClose.call(iframe.contentWindow);
                  _nativeCommunication('onCloseWindow', viewId);
                };

                const originalOpen = iframe.contentWindow.open;
                iframe.contentWindow.open = function (url, target, windowFeatures) {
                  const newWindow = originalOpen.call(iframe.contentWindow, ...arguments);
                  _nativeCommunication<Promise<boolean>>('onCreateWindow', viewId, [url, target, windowFeatures]).then(function (handledByClient) {
                    if (handledByClient) {
                      newWindow?.close();
                    }
                  });
                  return newWindow;
                };

                const originalPrint = iframe.contentWindow.print;
                iframe.contentWindow.print = function () {
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow!.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication('onPrintRequest', viewId, [iframeUrl]);
                  originalPrint.call(iframe.contentWindow);
                };

                webView.functionMap = {
                  "window.open": iframe.contentWindow.open,
                }

                const initialTitle = iframe.contentDocument?.title;
                const titleEl = iframe.contentDocument?.querySelector('title');
                webView.documentTitle = initialTitle;
                _nativeCommunication('onTitleChanged', viewId, [initialTitle]);
                if (titleEl != null) {
                  new MutationObserver(function (mutations) {
                    const title = (mutations[0].target as HTMLElement).innerText;
                    if (title != webView.documentTitle) {
                      webView.documentTitle = title;
                      _nativeCommunication('onTitleChanged', viewId, [title]);
                    }
                  }).observe(
                      titleEl,
                      {subtree: true, characterData: true, childList: true}
                  );
                }

                let oldPixelRatio = iframe.contentWindow.devicePixelRatio;
                iframe.contentWindow.addEventListener('resize', function (e) {
                  const newPixelRatio = iframe.contentWindow!.devicePixelRatio;
                  if (newPixelRatio !== oldPixelRatio) {
                    _nativeCommunication('onZoomScaleChanged', viewId, [oldPixelRatio, newPixelRatio]);
                    oldPixelRatio = newPixelRatio;
                  }
                });

                iframe.contentWindow.addEventListener('popstate', function (event: Event) {
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow!.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication('onUpdateVisitedHistory', viewId, [iframeUrl]);
                });

                iframe.contentWindow.addEventListener('scroll', function (event: Event) {
                  let x = 0;
                  let y = 0;
                  try {
                    x = iframe.contentWindow!.scrollX;
                    y = iframe.contentWindow!.scrollY;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication('onScrollChanged', viewId, [x, y]);
                });

                iframe.contentWindow.addEventListener('focus', function (event: Event) {
                  _nativeCommunication('onWindowFocus', viewId);
                });

                iframe.contentWindow.addEventListener('blur', function (event: Event) {
                  _nativeCommunication('onWindowBlur', viewId);
                });
              } catch (e) {
                console.log(e);
              }

              try {
                if (!webView.settings.javaScriptCanOpenWindowsAutomatically) {
                  iframe.contentWindow.open = function () {
                    throw new Error('JavaScript cannot open windows automatically');
                  };
                }

                if (!webView.settings.verticalScrollBarEnabled && !webView.settings.horizontalScrollBarEnabled) {
                  const style = iframe.contentDocument?.createElement('style');
                  if (style != null) {
                    style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                    style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }

                if (webView.settings.disableVerticalScroll) {
                  const style = iframe.contentDocument?.createElement('style');
                  if (style != null) {
                    style.id = "settings.disableVerticalScroll";
                    style.innerHTML = "body { overflow-y: hidden; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }

                if (webView.settings.disableHorizontalScroll) {
                  const style = iframe.contentDocument?.createElement('style');
                  if (style != null) {
                    style.id = "settings.disableHorizontalScroll";
                    style.innerHTML = "body { overflow-x: hidden; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }

                if (webView.settings.disableContextMenu) {
                  iframe.contentWindow.addEventListener('contextmenu', webView.disableContextMenuHandler);
                }
              } catch (e) {
                console.log(e);
              }

              _nativeCommunication('onLoadStop', viewId, [url]);

              try {
                iframe.contentWindow.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));
              } catch (e) {
                console.log(e);
              }

            });
          }
        },
        setSettings: function (newSettings: InAppWebViewSettings) {
          const iframe = webView.iframe;
          if (iframe == null) {
            return;
          }
          try {
            if (webView.settings.javaScriptCanOpenWindowsAutomatically != newSettings.javaScriptCanOpenWindowsAutomatically) {
              if (!newSettings.javaScriptCanOpenWindowsAutomatically) {
                iframe.contentWindow!.open = function () {
                  throw new Error('JavaScript cannot open windows automatically');
                };
              } else {
                iframe.contentWindow!.open = webView.functionMap["window.open"];
              }
            }

            if (webView.settings.verticalScrollBarEnabled != newSettings.verticalScrollBarEnabled &&
                webView.settings.horizontalScrollBarEnabled != newSettings.horizontalScrollBarEnabled) {
              if (!newSettings.verticalScrollBarEnabled && !newSettings.horizontalScrollBarEnabled) {
                const style = iframe.contentDocument?.createElement('style');
                if (style != null) {
                  style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                  style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                  iframe.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe.contentDocument?.getElementById("settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled");
                if (styleElement) {
                  styleElement.remove()
                }
              }
            }

            if (webView.settings.disableVerticalScroll != newSettings.disableVerticalScroll) {
              if (newSettings.disableVerticalScroll) {
                const style = iframe.contentDocument?.createElement('style');
                if (style != null) {
                  style.id = "settings.disableVerticalScroll";
                  style.innerHTML = "body { overflow-y: hidden; }";
                  iframe.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe.contentDocument?.getElementById("settings.disableVerticalScroll");
                if (styleElement) {
                  styleElement.remove()
                }
              }
            }

            if (webView.settings.disableHorizontalScroll != newSettings.disableHorizontalScroll) {
              if (newSettings.disableHorizontalScroll) {
                const style = iframe.contentDocument?.createElement('style');
                if (style != null) {
                  style.id = "settings.disableHorizontalScroll";
                  style.innerHTML = "body { overflow-x: hidden; }";
                  iframe.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe.contentDocument?.getElementById("settings.disableHorizontalScroll");
                if (styleElement) {
                  styleElement.remove()
                }
              }
            }

            if (webView.settings.disableContextMenu != newSettings.disableContextMenu) {
              if (newSettings.disableContextMenu) {
                iframe.contentWindow?.addEventListener('contextmenu', webView.disableContextMenuHandler);
              } else {
                iframe.contentWindow?.removeEventListener('contextmenu', webView.disableContextMenuHandler);
              }
            }
          } catch (e) {
            console.log(e);
          }

          webView.settings = newSettings;
        },
        reload: function () {
          var iframe = webView.iframe;
          if (iframe != null && iframe.contentWindow != null) {
            try {
              iframe.contentWindow.location.reload();
            } catch (e) {
              console.log(e);
              iframe.contentWindow.location.href = iframe.src;
            }
          }
        },
        goBack: function () {
          var iframe = webView.iframe;
          if (iframe != null) {
            try {
              iframe.contentWindow?.history.back();
            } catch (e) {
              console.log(e);
            }
          }
        },
        goForward: function () {
          var iframe = webView.iframe;
          if (iframe != null) {
            try {
              iframe.contentWindow?.history.forward();
            } catch (e) {
              console.log(e);
            }
          }
        },
        goBackOrForward: function (steps) {
          var iframe = webView.iframe;
          if (iframe != null) {
            try {
              iframe.contentWindow?.history.go(steps);
            } catch (e) {
              console.log(e);
            }
          }
        },
        evaluateJavascript: function (source) {
          const iframe = webView.iframe;
          let result = null;
          if (iframe != null) {
            try {
              result = JSON.stringify(iframe.contentWindow?.eval(source));
            } catch (e) {
            }
          }
          return result;
        },
        stopLoading: function () {
          const iframe = webView.iframe;
          if (iframe != null) {
            try {
              iframe.contentWindow?.stop();
            } catch (e) {
              console.log(e);
            }
          }
        },
        getUrl: function () {
          const iframe = webView.iframe;
          let url = iframe?.src;
          try {
            url = iframe?.contentWindow?.location.href;
          } catch (e) {
            console.log(e);
          }
          return url;
        },
        getTitle: function () {
          const iframe = webView.iframe;
          let title = null;
          try {
            title = iframe?.contentDocument?.title;
          } catch (e) {
            console.log(e);
          }
          return title;
        },
        injectJavascriptFileFromUrl: function (urlFile, scriptHtmlTagAttributes) {
          const iframe = webView.iframe;
          try {
            const d = iframe?.contentDocument;
            if (d == null) {
              return;
            }
            const script = d.createElement('script');
            for (const key of Object.keys(scriptHtmlTagAttributes)) {
              if (scriptHtmlTagAttributes[key] != null) {
                // @ts-ignore
                script[key] = scriptHtmlTagAttributes[key];
              }
            }
            if (script.id != null) {
              script.onload = function () {
                _nativeCommunication('onInjectedScriptLoaded', webView.viewId, [script.id]);
              }
              script.onerror = function () {
                _nativeCommunication('onInjectedScriptError', webView.viewId, [script.id]);
              }
            }
            script.src = urlFile;
            if (d.body != null) {
              d.body.appendChild(script);
            }
          } catch (e) {
            console.log(e);
          }
        },
        injectCSSCode: function (source) {
          const iframe = webView.iframe;
          try {
            const d = iframe?.contentDocument;
            if (d == null) {
              return;
            }
            const style = d.createElement('style');
            style.innerHTML = source;
            if (d.head != null) {
              d.head.appendChild(style);
            }
          } catch (e) {
            console.log(e);
          }
        },
        injectCSSFileFromUrl: function (urlFile, cssLinkHtmlTagAttributes) {
          const iframe = webView.iframe;
          try {
            const d = iframe?.contentDocument;
            if (d == null) {
              return;
            }
            const link = d.createElement('link');
            for (const key of Object.keys(cssLinkHtmlTagAttributes)) {
              if (cssLinkHtmlTagAttributes[key] != null) {
                // @ts-ignore
                link[key] = cssLinkHtmlTagAttributes[key];
              }
            }
            link.type = 'text/css';
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
        scrollTo: function (x, y, animated) {
          const iframe = webView.iframe;
          try {
            if (animated) {
              iframe?.contentWindow?.scrollTo({top: y, left: x, behavior: 'smooth'});
            } else {
              iframe?.contentWindow?.scrollTo(x, y);
            }
          } catch (e) {
            console.log(e);
          }
        },
        scrollBy: function (x, y, animated) {
          const iframe = webView.iframe;
          try {
            if (animated) {
              iframe?.contentWindow?.scrollBy({top: y, left: x, behavior: 'smooth'});
            } else {
              iframe?.contentWindow?.scrollBy(x, y);
            }
          } catch (e) {
            console.log(e);
          }
        },
        printCurrentPage: function () {
          const iframe = webView.iframe;
          try {
            iframe?.contentWindow?.print();
          } catch (e) {
            console.log(e);
          }
        },
        getContentHeight: function () {
          const iframe = webView.iframe;
          try {
            return iframe?.contentDocument?.documentElement.scrollHeight;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getContentWidth: function () {
          const iframe = webView.iframe;
          try {
            return iframe?.contentDocument?.documentElement.scrollWidth;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getSelectedText: function () {
          const iframe = webView.iframe;
          try {
            let txt;
            const w = iframe?.contentWindow;
            if (w == null) {
              return null;
            }
            if (w.getSelection) {
              txt = w.getSelection()?.toString();
            } else if (w.document.getSelection) {
              txt = w.document.getSelection()?.toString();
              // @ts-ignore
            } else if (w.document.selection) {
              // @ts-ignore
              txt = w.document.selection.createRange().text;
            }
            return txt;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getScrollX: function () {
          const iframe = webView.iframe;
          try {
            return iframe?.contentWindow?.scrollX;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getScrollY: function () {
          const iframe = webView.iframe;
          try {
            return iframe?.contentWindow?.scrollY;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        isSecureContext: function () {
          const iframe = webView.iframe;
          try {
            return iframe?.contentWindow?.isSecureContext ?? false;
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        canScrollVertically: function () {
          const iframe = webView.iframe;
          try {
            return (iframe?.contentDocument?.body.scrollHeight ?? 0) > (iframe?.contentWindow?.innerHeight ?? 0);
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        canScrollHorizontally: function () {
          const iframe = webView.iframe;
          try {
            return (iframe?.contentDocument?.body.scrollWidth ?? 0) > (iframe?.contentWindow?.innerWidth ?? 0);
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        getSize: function () {
          const iframeContainer = webView.iframeContainer;
          let width = 0.0;
          let height = 0.0;
          if (iframeContainer != null) {
            if (iframeContainer.style.width != null && iframeContainer.style.width != '' && iframeContainer.style.width.indexOf('px') > 0) {
              width = parseFloat(iframeContainer.style.width);
            }
            if (width == null || width == 0.0) {
              width = iframeContainer.getBoundingClientRect().width;
            }
            if (iframeContainer.style.height != null && iframeContainer.style.height != '' && iframeContainer.style.height.indexOf('px') > 0) {
              height = parseFloat(iframeContainer.style.height);
            }
            if (height == null || height == 0.0) {
              height = iframeContainer.getBoundingClientRect().height;
            }
          }
          return {
            width: width,
            height: height
          };
        }
      };

      return webView;
    },
    getCookieExpirationDate: function (timestamp: number) {
      return (new Date(timestamp)).toUTCString();
    },
    nativeAsyncCommunication: function (method: string, viewId: number | string, args?: any[]) {
      throw new Error("Method not implemented.");
    },
    nativeSyncCommunication: function (method: string, viewId: number | string, args?: any[]) {
      throw new Error("Method not implemented.");
    },
    nativeCommunication: function (method: string, viewId: number | string, args?: any[]) {
      try {
        const result = window.flutter_inappwebview_plugin.nativeSyncCommunication(method, viewId, args);
        return result != null ? JSON.parse(result) : null;
      } catch (e1) {
        try {
          const promise = window.flutter_inappwebview_plugin.nativeAsyncCommunication(method, viewId, args);
          return promise.then(function (result) {
            return result != null ? JSON.parse(result) : null;
          });
        } catch (e2) {
          return null;
        }
      }
    },
  };

  let _nativeCommunication = window.flutter_inappwebview_plugin.nativeCommunication;
})();