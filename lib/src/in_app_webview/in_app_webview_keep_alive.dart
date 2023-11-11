import '../types/main.dart';
import '../util.dart';
import '../web_message/web_message_channel.dart';
import '../web_message/web_message_listener.dart';
import 'in_app_webview.dart';
import 'in_app_webview_controller.dart';

///Class used to keep alive a [InAppWebView].
class InAppWebViewKeepAlive {
  String _id = IdGenerator.generate();
}

///Used internally
extension InternalInAppWebViewKeepAlive on InAppWebViewKeepAlive {
  set id(String id) {
    _id = id;
  }

  String get id => _id;
}

///Used internally to save and restore [InAppWebViewController] properties
///for the keep alive feature.
class InAppWebViewControllerKeepAliveProps {
  Map<String, JavaScriptHandlerCallback> javaScriptHandlersMap;
  Map<UserScriptInjectionTime, List<UserScript>> userScripts;
  Set<String> webMessageListenerObjNames;
  Map<String, ScriptHtmlTagAttributes> injectedScriptsFromURL;
  Set<WebMessageChannel> webMessageChannels = Set();
  Set<WebMessageListener> webMessageListeners = Set();

  InAppWebViewControllerKeepAliveProps(
      {required this.javaScriptHandlersMap,
      required this.userScripts,
      required this.webMessageListenerObjNames,
      required this.injectedScriptsFromURL,
      required this.webMessageChannels,
      required this.webMessageListeners});
}
