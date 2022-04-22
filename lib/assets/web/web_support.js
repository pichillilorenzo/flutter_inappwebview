window.flutter_inappwebview = {
    viewId: null,
    iframeId: null,
    iframe: null,
    prepare: function () {
        var iframe = document.getElementById(window.flutter_inappwebview.iframeId);
        if (iframe != null) {
            window.flutter_inappwebview.iframe = iframe;
            iframe.addEventListener('load', function (event) {
                var url = iframe.src;
                try {
                    url = iframe.contentWindow.location.href;
                } catch (e) {
                    console.log(e);
                }
                window.flutter_inappwebview.nativeCommunication('onLoadStart', window.flutter_inappwebview.viewId, [url]);
                window.flutter_inappwebview.nativeCommunication('onLoadStop', window.flutter_inappwebview.viewId, [url]);

                iframe.contentWindow.addEventListener('popstate', function (event) {
                    var iframeUrl = iframe.src;
                    try {
                        iframeUrl = iframe.contentWindow.location.href;
                    } catch (e) {
                        console.log(e);
                    }
                    window.flutter_inappwebview.nativeCommunication('onUpdateVisitedHistory', window.flutter_inappwebview.viewId, [iframeUrl]);
                });
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
                } catch (e) {
                    console.log(e);
                }
            });
        }
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
                result = iframe.contentWindow.eval(source);
            } catch (e) {
                console.log(e);
            }
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
