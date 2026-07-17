//
//  CallAsyncJavaScriptBelowIOS14WrapperJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class CallAsyncJavaScriptBelowIOS14WrapperJS {

    public static let RESULT_MESSAGE_HANDLER_NAME = "flutterInAppWebViewCallAsyncJavaScriptResult"
    public static let VAR_WINDOW_ID = "$IN_APP_WEBVIEW_CALL_ASYNC_JAVASCRIPT_WINDOW_ID"
    
    public static func CALL_ASYNC_JAVASCRIPT_BELOW_IOS_14_WRAPPER_JS() -> String {
        return """
        (function(obj) {
            var messageHandler = window.webkit.messageHandlers['\(RESULT_MESSAGE_HANDLER_NAME)'];
            var jsonStringify = window.JSON.stringify;
            var resultUuid = '\(PluginScriptsUtil.VAR_RESULT_UUID)';
            var windowId = \(VAR_WINDOW_ID);
            var sendResult = function(value, error) {
                var message;
                try {
                    message = jsonStringify({
                        'value': value === undefined ? null : value,
                        'error': error,
                        'resultUuid': resultUuid,
                        'windowId': windowId
                    });
                } catch (serializationError) {
                    message = jsonStringify({
                        'value': null,
                        'error': serializationError + '',
                        'resultUuid': resultUuid,
                        'windowId': windowId
                    });
                }
                messageHandler.postMessage(message);
            };
            (async function(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES)) {
                \(PluginScriptsUtil.VAR_FUNCTION_BODY)
            })(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES)).then(function(value) {
                sendResult(value, null);
            }).catch(function(error) {
                sendResult(null, error + '');
            });
            return null;
        })(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ));
        """
    }
}
