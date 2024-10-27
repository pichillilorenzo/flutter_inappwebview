//
//  CallAsyncJavaScriptBelowIOS14WrapperJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class CallAsyncJavaScriptBelowIOS14WrapperJS {
    
    public static func CALL_ASYNC_JAVASCRIPT_BELOW_IOS_14_WRAPPER_JS() -> String {
        return """
        (function(obj) {
            (async function(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES) {
                \(PluginScriptsUtil.VAR_FUNCTION_BODY)
            })(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES)).then(function(value) {
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onCallAsyncJavaScriptResultBelowIOS14Received', {
                    'value': value, 
                    'error': null,
                    'resultUuid': '\(PluginScriptsUtil.VAR_RESULT_UUID)'
                });
            }).catch(function(error) {
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onCallAsyncJavaScriptResultBelowIOS14Received', {
                    'value': null, 
                    'error': error + '',
                    'resultUuid': '\(PluginScriptsUtil.VAR_RESULT_UUID)'
                });
            });
            return null;
        })(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ));
        """
    }
}
