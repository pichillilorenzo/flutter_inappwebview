window.flutter_inappwebview = {
    webViews: {},
    /**
     * @param viewId {number | string}
     * @param iframe {HTMLIFrameElement}
     * @param iframeContainer {HTMLDivElement}
     */
    createFlutterInAppWebView: function(viewId, iframe, iframeContainer) {
        const iframeId = iframe.id;
        var webView = {
            viewId: viewId,
            iframeId: iframeId,
            iframe: null,
            iframeContainer: null,
            windowAutoincrementId: 0,
            windows: {},
            isFullscreen: false,
            documentTitle: null,
            functionMap: {},
            settings: {},
            disableContextMenuHandler: function(event) {
                event.preventDefault();
                event.stopPropagation();
                return false;
            },
            prepare: function(settings) {
                webView.settings = settings;

                document.addEventListener('fullscreenchange', function(event) {
                    // document.fullscreenElement will point to the element that
                    // is in fullscreen mode if there is one. If there isn't one,
                    // the value of the property is null.
                    if (document.fullscreenElement && document.fullscreenElement.id == iframeId) {
                        webView.isFullscreen = true;
                        window.flutter_inappwebview.nativeCommunication('onEnterFullscreen', viewId);
                    } else if (!document.fullscreenElement && webView.isFullscreen) {
                        webView.isFullscreen = false;
                        window.flutter_inappwebview.nativeCommunication('onExitFullscreen', viewId);
                    } else {
                        webView.isFullscreen = false;
                    }
                });

                if (iframe != null) {
                    webView.iframe = iframe;
                    webView.iframeContainer = iframeContainer;
                    iframe.addEventListener('load', function (event) {
                        webView.windowAutoincrementId = 0;
                        webView.windows = {};

                        var url = iframe.src;
                        try {
                            url = iframe.contentWindow.location.href;
                        } catch (e) {
                            console.log(e);
                        }
                        window.flutter_inappwebview.nativeCommunication('onLoadStart', viewId, [url]);

                        try {
                            var oldLogs = {
                                'log': iframe.contentWindow.console.log,
                                'debug': iframe.contentWindow.console.debug,
                                'error': iframe.contentWindow.console.error,
                                'info': iframe.contentWindow.console.info,
                                'warn': iframe.contentWindow.console.warn
                            };
                            for (var k in oldLogs) {
                                (function(oldLog) {
                                    iframe.contentWindow.console[oldLog] = function() {
                                        var message = '';
                                        for (var i in arguments) {
                                            if (message == '') {
                                                message += arguments[i];
                                            } else {
                                                message += ' ' + arguments[i];
                                            }
                                        }
                                        oldLogs[oldLog].call(iframe.contentWindow.console, ...arguments);
                                        window.flutter_inappwebview.nativeCommunication('onConsoleMessage', viewId, [oldLog, message]);
                                    }
                                })(k);
                            }
                        } catch (e) {
                            console.log(e);
                        }

                        try {
                            var originalPushState = iframe.contentWindow.history.pushState;
                            iframe.contentWindow.history.pushState = function (state, unused, url) {
                                originalPushState.call(iframe.contentWindow.history, state, unused, url);
                                var iframeUrl = iframe.src;
                                try {
                                    iframeUrl = iframe.contentWindow.location.href;
                                } catch (e) {
                                    console.log(e);
                                }
                                window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', viewId, [iframeUrl]);
                            };

                            var originalReplaceState = iframe.contentWindow.history.replaceState;
                            iframe.contentWindow.history.replaceState = function (state, unused, url) {
                                originalReplaceState.call(iframe.contentWindow.history, state, unused, url);
                                var iframeUrl = iframe.src;
                                try {
                                    iframeUrl = iframe.contentWindow.location.href;
                                } catch (e) {
                                    console.log(e);
                                }
                                window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', viewId, [iframeUrl]);
                            };

                            var originalOpen = iframe.contentWindow.open;
                            iframe.contentWindow.open = function (url, target, windowFeatures) {
                                var newWindow = originalOpen.call(iframe.contentWindow, ...arguments);
                                var windowId = webView.windowAutoincrementId;
                                webView.windowAutoincrementId++;
                                webView.windows[windowId] = newWindow;
                                window.flutter_inappwebview.nativeCommunication('onCreateWindow', viewId, [windowId, url, target, windowFeatures]).then(function(){}, function(handledByClient) {
                                    if (handledByClient) {
                                        newWindow.close();
                                    }
                                });
                                return newWindow;
                            };

                            var originalPrint = iframe.contentWindow.print;
                            iframe.contentWindow.print = function() {
                                var iframeUrl = iframe.src;
                                try {
                                    iframeUrl = iframe.contentWindow.location.href;
                                } catch (e) {
                                    console.log(e);
                                }
                                window.flutter_inappwebview.nativeCommunication('onPrintRequest', viewId, [iframeUrl]);
                                originalPrint.call(iframe.contentWindow);
                            };

                            webView.functionMap = {
                                "window.open": iframe.contentWindow.open,
                                "window.print": iframe.contentWindow.print,
                                "window.history.pushState": iframe.contentWindow.history.pushState,
                                "window.history.replaceState": iframe.contentWindow.history.replaceState,
                            }

                            var initialTitle = iframe.contentDocument.title;
                            var titleEl = iframe.contentDocument.querySelector('title');
                            webView.documentTitle = initialTitle;
                            window.flutter_inappwebview.nativeCommunication('onTitleChanged', viewId, [initialTitle]);
                            if (titleEl != null) {
                                new MutationObserver(function(mutations) {
                                    var title = mutations[0].target.innerText;
                                    if (title != webView.documentTitle) {
                                        webView.documentTitle = title;
                                        window.flutter_inappwebview.nativeCommunication('onTitleChanged', viewId, [title]);
                                    }
                                }).observe(
                                    titleEl,
                                    { subtree: true, characterData: true, childList: true }
                                );
                            }

                            var oldPixelRatio = iframe.contentWindow.devicePixelRatio;
                            iframe.contentWindow.addEventListener('resize', function (e) {
                                var newPixelRatio = iframe.contentWindow.devicePixelRatio;
                                if(newPixelRatio !== oldPixelRatio){
                                    window.flutter_inappwebview.nativeCommunication('onZoomScaleChanged', viewId, [oldPixelRatio, newPixelRatio]);
                                    oldPixelRatio = newPixelRatio;
                                }
                            });

                            iframe.contentWindow.addEventListener('popstate', function (event) {
                                var iframeUrl = iframe.src;
                                try {
                                    iframeUrl = iframe.contentWindow.location.href;
                                } catch (e) {
                                    console.log(e);
                                }
                                window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', viewId, [iframeUrl]);
                            });

                            iframe.contentWindow.addEventListener('scroll', function (event) {
                                var x = 0;
                                var y = 0;
                                try {
                                    x = iframe.contentWindow.scrollX;
                                    y = iframe.contentWindow.scrollY;
                                } catch (e) {
                                    console.log(e);
                                }
                                window.flutter_inappwebview.nativeCommunication('onScrollChanged', viewId, [x, y]);
                            });

                            iframe.contentWindow.addEventListener('focus', function (event) {
                                window.flutter_inappwebview.nativeCommunication('onWindowFocus', viewId);
                            });

                            iframe.contentWindow.addEventListener('blur', function (event) {
                                window.flutter_inappwebview.nativeCommunication('onWindowBlur', viewId);
                            });
                        } catch (e) {
                            console.log(e);
                        }

                        try {

                            if (!webView.settings.javaScriptCanOpenWindowsAutomatically) {
                                iframe.contentWindow.open = function() {
                                    throw new Error('JavaScript cannot open windows automatically');
                                };
                            }

                            if (!webView.settings.verticalScrollBarEnabled && !webView.settings.horizontalScrollBarEnabled) {
                                var style = iframe.contentDocument.createElement('style');
                                style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                                style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                                iframe.contentDocument.head.append(style);
                            }

                            if (webView.settings.disableVerticalScroll) {
                                var style = iframe.contentDocument.createElement('style');
                                style.id = "settings.disableVerticalScroll";
                                style.innerHTML = "body { overflow-y: hidden; }";
                                iframe.contentDocument.head.append(style);
                            }

                            if (webView.settings.disableHorizontalScroll) {
                                var style = iframe.contentDocument.createElement('style');
                                style.id = "settings.disableHorizontalScroll";
                                style.innerHTML = "body { overflow-x: hidden; }";
                                iframe.contentDocument.head.append(style);
                            }

                            if (webView.settings.disableContextMenu) {
                                iframe.contentWindow.addEventListener('contextmenu', webView.disableContextMenuHandler);
                            }
                        } catch (e) {
                            console.log(e);
                        }

                        window.flutter_inappwebview.nativeCommunication('onLoadStop', viewId, [url]);
                    });
                }
            },
            setSettings: function(newSettings) {
                var iframe = webView.iframe;
                try {
                    if (webView.settings.javaScriptCanOpenWindowsAutomatically != newSettings.javaScriptCanOpenWindowsAutomatically) {
                        if (!newSettings.javaScriptCanOpenWindowsAutomatically) {
                            iframe.contentWindow.open = function() {
                                throw new Error('JavaScript cannot open windows automatically');
                            };
                        } else {
                            iframe.contentWindow.open = webView.functionMap["window.open"];
                        }
                    }

                    if (webView.settings.verticalScrollBarEnabled != newSettings.verticalScrollBarEnabled &&
                        webView.settings.horizontalScrollBarEnabled != newSettings.horizontalScrollBarEnabled) {
                        if (!newSettings.verticalScrollBarEnabled && !newSettings.horizontalScrollBarEnabled) {
                            var style = iframe.contentDocument.createElement('style');
                            style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                            style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                            iframe.contentDocument.head.append(style);
                        } else {
                            var styleElement = iframe.contentDocument.getElementById("settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled");
                            if (styleElement) { styleElement.remove() }
                        }
                    }

                    if (webView.settings.disableVerticalScroll != newSettings.disableVerticalScroll) {
                        if (newSettings.disableVerticalScroll) {
                            var style = iframe.contentDocument.createElement('style');
                            style.id = "settings.disableVerticalScroll";
                            style.innerHTML = "body { overflow-y: hidden; }";
                            iframe.contentDocument.head.append(style);
                        } else {
                             var styleElement = iframe.contentDocument.getElementById("settings.disableVerticalScroll");
                            if (styleElement) { styleElement.remove() }
                        }
                    }

                    if (webView.settings.disableHorizontalScroll != newSettings.disableHorizontalScroll) {
                        if (newSettings.disableHorizontalScroll) {
                            var style = iframe.contentDocument.createElement('style');
                            style.id = "settings.disableHorizontalScroll";
                            style.innerHTML = "body { overflow-x: hidden; }";
                            iframe.contentDocument.head.append(style);
                        } else {
                             var styleElement = iframe.contentDocument.getElementById("settings.disableHorizontalScroll");
                            if (styleElement) { styleElement.remove() }
                        }
                    }

                    if (webView.settings.disableContextMenu != newSettings.disableContextMenu) {
                        if (newSettings.disableContextMenu) {
                            iframe.contentWindow.addEventListener('contextmenu', webView.disableContextMenuHandler);
                        } else {
                            iframe.contentWindow.removeEventListener('contextmenu', webView.disableContextMenuHandler);
                        }
                    }
                } catch (e) {
                    console.log(e);
                }

                webView.settings = newSettings;
            },
            reload: function() {
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
            goBack: function() {
                var iframe = webView.iframe;
                if (iframe != null) {
                    try {
                        iframe.contentWindow.history.back();
                    } catch (e) {
                        console.log(e);
                    }
                }
            },
            goForward: function() {
                var iframe = webView.iframe;
                if (iframe != null) {
                    try {
                        iframe.contentWindow.history.forward();
                    } catch (e) {
                        console.log(e);
                    }
                }
            },
            goBackOrForward: function(steps) {
                var iframe = webView.iframe;
                if (iframe != null) {
                    try {
                        iframe.contentWindow.history.go(steps);
                    } catch (e) {
                        console.log(e);
                    }
                }
            },
            evaluateJavascript: function(source) {
                var iframe = webView.iframe;
                var result = null;
                if (iframe != null) {
                    try {
                        result = JSON.stringify(iframe.contentWindow.eval(source));
                    } catch (e) {}
                }
                return result;
            },
            stopLoading: function(steps) {
                var iframe = webView.iframe;
                if (iframe != null) {
                    try {
                        iframe.contentWindow.stop();
                    } catch (e) {
                        console.log(e);
                    }
                }
            },
            getUrl: function() {
                var iframe = webView.iframe;
                var url = iframe.src;
                try {
                    url = iframe.contentWindow.location.href;
                } catch (e) {
                    console.log(e);
                }
                return url;
            },
            getTitle: function() {
                var iframe = webView.iframe;
                var title = null;
                try {
                    title = iframe.contentDocument.title;
                } catch (e) {
                    console.log(e);
                }
                return title;
            },
            injectJavascriptFileFromUrl: function(urlFile, scriptHtmlTagAttributes) {
                var iframe = webView.iframe;
                try {
                    var d = iframe.contentDocument;
                    var script = d.createElement('script');
                    for (var key of Object.keys(scriptHtmlTagAttributes)) {
                        if (scriptHtmlTagAttributes[key] != null) {
                            script[key] = scriptHtmlTagAttributes[key];
                        }
                    }
                    if (script.id != null) {
                        script.onload = function() {
                            window.flutter_inappwebview.nativeCommunication('onInjectedScriptLoaded', webView.viewId, [script.id]);
                        }
                        script.onerror = function() {
                            window.flutter_inappwebview.nativeCommunication('onInjectedScriptError', webView.viewId, [script.id]);
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
            injectCSSCode: function(source) {
                var iframe = webView.iframe;
                try {
                    var d = iframe.contentDocument;
                    var style = d.createElement('style');
                    style.innerHTML = source;
                    if (d.head != null) {
                        d.head.appendChild(style);
                    }
                } catch (e) {
                    console.log(e);
                }
            },
            injectCSSFileFromUrl: function(urlFile, cssLinkHtmlTagAttributes) {
                var iframe = webView.iframe;
                try {
                    var d = iframe.contentDocument;
                    var link = d.createElement('link');
                    for (var key of Object.keys(cssLinkHtmlTagAttributes)) {
                        if (cssLinkHtmlTagAttributes[key] != null) {
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
            scrollTo: function(x, y, animated) {
                var iframe = webView.iframe;
                try {
                    if (animated) {
                        iframe.contentWindow.scrollTo({top: y, left: x, behavior: 'smooth'});
                    } else {
                        iframe.contentWindow.scrollTo(x, y);
                    }
                } catch (e) {
                    console.log(e);
                }
            },
            scrollBy: function(x, y, animated) {
                var iframe = webView.iframe;
                try {
                    if (animated) {
                        iframe.contentWindow.scrollBy({top: y, left: x, behavior: 'smooth'});
                    } else {
                        iframe.contentWindow.scrollBy(x, y);
                    }
                } catch (e) {
                    console.log(e);
                }
            },
            printCurrentPage: function() {
                var iframe = webView.iframe;
                try {
                    iframe.contentWindow.print();
                } catch (e) {
                    console.log(e);
                }
            },
            getContentHeight: function() {
                var iframe = webView.iframe;
                try {
                    return iframe.contentDocument.documentElement.scrollHeight;
                } catch (e) {
                    console.log(e);
                }
                return null;
            },
            getContentWidth: function() {
                var iframe = webView.iframe;
                try {
                    return iframe.contentDocument.documentElement.scrollWidth;
                } catch (e) {
                    console.log(e);
                }
                return null;
            },
            getSelectedText: function() {
                var iframe = webView.iframe;
                try {
                    var txt;
                    var w = iframe.contentWindow;
                    if (w.getSelection) {
                        txt = w.getSelection().toString();
                    } else if (w.document.getSelection) {
                        txt = w.document.getSelection().toString();
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
                var iframe = webView.iframe;
                try {
                    return iframe.contentWindow.scrollX;
                } catch (e) {
                    console.log(e);
                }
                return null;
            },
            getScrollY: function() {
                var iframe = webView.iframe;
                try {
                    return iframe.contentWindow.scrollY;
                } catch (e) {
                    console.log(e);
                }
                return null;
            },
            isSecureContext: function() {
                var iframe = webView.iframe;
                try {
                    return iframe.contentWindow.isSecureContext;
                } catch (e) {
                    console.log(e);
                }
                return false;
            },
            canScrollVertically: function() {
                var iframe = webView.iframe;
                try {
                    return iframe.contentDocument.body.scrollHeight > iframe.contentWindow.innerHeight;
                } catch (e) {
                    console.log(e);
                }
                return false;
            },
            canScrollHorizontally: function() {
                var iframe = webView.iframe;
                try {
                    return iframe.contentDocument.body.scrollWidth > iframe.contentWindow.innerWidth;
                } catch (e) {
                    console.log(e);
                }
                return false;
            },
            getSize: function() {
                var iframeContainer = webView.iframeContainer;
                var width = 0.0;
                var height = 0.0;
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

                return {
                    width: width,
                    height: height
                };
            }
        };

        return webView;
    },
    getCookieExpirationDate: function(timestamp) {
        return (new Date(timestamp)).toUTCString();
    }
};