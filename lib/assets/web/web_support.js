window.flutter_inappwebview = {
    viewId: null,
    iframeId: null,
    iframe: null,
    windowAutoincrementId: 0,
    windows: {},
    isFullscreen: false,
    documentTitle: null,
    functionMap: {},
    settings: {},
    prepare: function (settings) {
        window.flutter_inappwebview.settings = settings;
        var iframe = document.getElementById(window.flutter_inappwebview.iframeId);

        document.addEventListener('fullscreenchange', function(event) {
            // document.fullscreenElement will point to the element that
            // is in fullscreen mode if there is one. If there isn't one,
            // the value of the property is null.
            if (document.fullscreenElement && document.fullscreenElement.id == window.flutter_inappwebview.iframeId) {
                window.flutter_inappwebview.isFullscreen = true;
                window.flutter_inappwebview.nativeCommunication('onEnterFullscreen', window.flutter_inappwebview.viewId);
            } else if (!document.fullscreenElement && window.flutter_inappwebview.isFullscreen) {
                window.flutter_inappwebview.isFullscreen = false;
                window.flutter_inappwebview.nativeCommunication('onExitFullscreen', window.flutter_inappwebview.viewId);
            } else {
                window.flutter_inappwebview.isFullscreen = false;
            }
        });

        if (iframe != null) {
            window.flutter_inappwebview.iframe = iframe;
            iframe.addEventListener('load', function (event) {
                window.flutter_inappwebview.windowAutoincrementId = 0;
                window.flutter_inappwebview.windows = {};

                var url = iframe.src;
                try {
                    url = iframe.contentWindow.location.href;
                } catch (e) {
                    console.log(e);
                }
                window.flutter_inappwebview.nativeCommunication('onLoadStart', window.flutter_inappwebview.viewId, [url]);

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
                                window.flutter_inappwebview.nativeCommunication('onConsoleMessage', window.flutter_inappwebview.viewId, [oldLog, message]);
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
                        window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', window.flutter_inappwebview.viewId, [iframeUrl]);
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
                        window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', window.flutter_inappwebview.viewId, [iframeUrl]);
                    };

                    var originalOpen = iframe.contentWindow.open;
                    iframe.contentWindow.open = function (url, target, windowFeatures) {
                        var newWindow = originalOpen.call(iframe.contentWindow, ...arguments);
                        var windowId = window.flutter_inappwebview.windowAutoincrementId;
                        window.flutter_inappwebview.windowAutoincrementId++;
                        window.flutter_inappwebview.windows[windowId] = newWindow;
                        window.flutter_inappwebview.nativeCommunication('onCreateWindow', window.flutter_inappwebview.viewId, [windowId, url, target, windowFeatures]).then(function(){}, function(handledByClient) {
                            if (handledByClient) {
                                newWindow.close();
                            }
                        });
                        return newWindow;
                    };

                    var originalPrint = iframe.contentWindow.print;
                    iframe.contentWindow.print = function () {
                        var iframeUrl = iframe.src;
                        try {
                            iframeUrl = iframe.contentWindow.location.href;
                        } catch (e) {
                            console.log(e);
                        }
                        window.flutter_inappwebview.nativeCommunication('onPrint', window.flutter_inappwebview.viewId, [iframeUrl]);
                        originalPrint.call(iframe.contentWindow);
                    };

                    window.flutter_inappwebview.functionMap = {
                        "window.open": iframe.contentWindow.open,
                        "window.print": iframe.contentWindow.print,
                        "window.history.pushState": iframe.contentWindow.history.pushState,
                        "window.history.replaceState": iframe.contentWindow.history.replaceState,
                    }

                    var initialTitle = iframe.contentDocument.title;
                    window.flutter_inappwebview.documentTitle = initialTitle;
                    window.flutter_inappwebview.nativeCommunication('onTitleChanged', window.flutter_inappwebview.viewId, [initialTitle]);
                    new MutationObserver(function(mutations) {
                        var title = mutations[0].target.nodeValue;
                        if (title != window.flutter_inappwebview.documentTitle) {
                            window.flutter_inappwebview.documentTitle = title;
                            window.flutter_inappwebview.nativeCommunication('onTitleChanged', window.flutter_inappwebview.viewId, [title]);
                        }
                    }).observe(
                        iframe.contentDocument.querySelector('title'),
                        { subtree: true, characterData: true, childList: true }
                    );

                    var oldPixelRatio = iframe.contentWindow.devicePixelRatio;
                    iframe.contentWindow.addEventListener('resize', function (e) {
                        var newPixelRatio = iframe.contentWindow.devicePixelRatio;
                        if(newPixelRatio !== oldPixelRatio){
                            window.flutter_inappwebview.nativeCommunication('onZoomScaleChanged', window.flutter_inappwebview.viewId, [oldPixelRatio, newPixelRatio]);
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
                        window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', window.flutter_inappwebview.viewId, [iframeUrl]);
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
                        window.flutter_inappwebview.nativeCommunication('onScrollChanged', window.flutter_inappwebview.viewId, [x, y]);
                    });

                    iframe.contentWindow.addEventListener('focus', function (event) {
                        window.flutter_inappwebview.nativeCommunication('onWindowFocus', window.flutter_inappwebview.viewId);
                    });

                    iframe.contentWindow.addEventListener('blur', function (event) {
                        window.flutter_inappwebview.nativeCommunication('onWindowBlur', window.flutter_inappwebview.viewId);
                    });
                } catch (e) {
                    console.log(e);
                }

                try {

                    if (!window.flutter_inappwebview.settings.javaScriptCanOpenWindowsAutomatically) {
                        iframe.contentWindow.open = function () {
                            throw new Error('JavaScript cannot open windows automatically');
                        };
                    }

                    if (!window.flutter_inappwebview.settings.verticalScrollBarEnabled && !window.flutter_inappwebview.settings.horizontalScrollBarEnabled) {
                        var style = iframe.contentDocument.createElement('style');
                        style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                        style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                        iframe.contentDocument.head.append(style);
                    }

                    if (window.flutter_inappwebview.settings.disableVerticalScroll) {
                        var style = iframe.contentDocument.createElement('style');
                        style.id = "settings.disableVerticalScroll";
                        style.innerHTML = "body { overflow-y: hidden; }";
                        iframe.contentDocument.head.append(style);
                    }

                    if (window.flutter_inappwebview.settings.disableHorizontalScroll) {
                        var style = iframe.contentDocument.createElement('style');
                        style.id = "settings.disableHorizontalScroll";
                        style.innerHTML = "body { overflow-x: hidden; }";
                        iframe.contentDocument.head.append(style);
                    }
                } catch (e) {
                    console.log(e);
                }

                window.flutter_inappwebview.nativeCommunication('onLoadStop', window.flutter_inappwebview.viewId, [url]);
            });
        }
    },
    setSettings: function (newSettings) {
        var iframe = window.flutter_inappwebview.iframe;
        try {
            if (window.flutter_inappwebview.settings.javaScriptCanOpenWindowsAutomatically != newSettings.javaScriptCanOpenWindowsAutomatically) {
                if (!newSettings.javaScriptCanOpenWindowsAutomatically) {
                    iframe.contentWindow.open = function () {
                        throw new Error('JavaScript cannot open windows automatically');
                    };
                } else {
                    iframe.contentWindow.open = window.flutter_inappwebview.functionMap["window.open"];
                }
            }

            if (window.flutter_inappwebview.settings.verticalScrollBarEnabled != newSettings.verticalScrollBarEnabled &&
                window.flutter_inappwebview.settings.horizontalScrollBarEnabled != newSettings.horizontalScrollBarEnabled) {
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

            if (window.flutter_inappwebview.settings.disableVerticalScroll != newSettings.disableVerticalScroll) {
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

            if (window.flutter_inappwebview.settings.disableHorizontalScroll != newSettings.disableHorizontalScroll) {
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
        } catch (e) {
            console.log(e);
        }
        window.flutter_inappwebview.settings = newSettings;
    },
    reload: function () {
        var iframe = window.flutter_inappwebview.iframe;
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
        var iframe = window.flutter_inappwebview.iframe;
        if (iframe != null) {
            try {
                iframe.contentWindow.history.back();
            } catch (e) {
                console.log(e);
            }
        }
    },
    goForward: function () {
        var iframe = window.flutter_inappwebview.iframe;
        if (iframe != null) {
            try {
                iframe.contentWindow.history.forward();
            } catch (e) {
                console.log(e);
            }
        }
    },
    goForwardOrForward: function (steps) {
        var iframe = window.flutter_inappwebview.iframe;
        if (iframe != null) {
            try {
                iframe.contentWindow.history.go(steps);
            } catch (e) {
                console.log(e);
            }
        }
    },
    evaluateJavascript: function (source) {
        var iframe = window.flutter_inappwebview.iframe;
        var result = null;
        if (iframe != null) {
            try {
                result = JSON.stringify(iframe.contentWindow.eval(source));
            } catch (e) {}
        }
        return result;
    },
    stopLoading: function (steps) {
        var iframe = window.flutter_inappwebview.iframe;
        if (iframe != null) {
            try {
                iframe.contentWindow.stop();
            } catch (e) {
                console.log(e);
            }
        }
    }
};