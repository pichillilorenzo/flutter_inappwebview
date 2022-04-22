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
                window.flutter_inappwebview.nativeCommunication('iframeLoaded', window.flutter_inappwebview.viewId, [url]);
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
    }
};
