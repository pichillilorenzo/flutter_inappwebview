const _InAppWebViewEvaluateJavascriptPort = browser.runtime.connectNative("evaluateJavascript");
browser = null;
_InAppWebViewEvaluateJavascriptPort.onMessage.addListener(_InAppWebViewEvaluateJavascriptResponse => {
  _InAppWebViewEvaluateJavascriptResponse.result = null;
  try {
    _InAppWebViewEvaluateJavascriptResponse.result = window.wrappedJSObject.eval(_InAppWebViewEvaluateJavascriptResponse.source);
  } catch(e) {
    if (e.name === 'EvalError') {
      if (_InAppWebViewEvaluateJavascriptResponse.source != null) {
        _InAppWebViewEvaluateJavascriptResponse.source = _InAppWebViewEvaluateJavascriptResponse.source
          .replace(/_InAppWebViewEvaluateJavascriptPort/g, '')
          .replace(/_InAppWebViewEvaluateJavascriptResponse/g, '');
      }
      try {
        _InAppWebViewEvaluateJavascriptResponse.result = eval(_InAppWebViewEvaluateJavascriptResponse.source);
      } catch(e) {
        console.error(e);
      }
    } else {
      console.error(e);
    }
  }
  _InAppWebViewEvaluateJavascriptPort.postMessage(_InAppWebViewEvaluateJavascriptResponse);
});
_InAppWebViewEvaluateJavascriptPort.postMessage("I'm ready!");