import '../types/main.dart';
import '../util.dart';
import '../web_message/platform_web_message_channel.dart';
import '../web_message/platform_web_message_listener.dart';
import 'platform_inappwebview_widget.dart';
import 'platform_inappwebview_controller.dart';

///Class used to keep alive a [PlatformInAppWebViewWidget].
class InAppWebViewKeepAlive {
  String _id = IdGenerator.generate();
}

///Used internally
extension InternalInAppWebViewKeepAlive on InAppWebViewKeepAlive {
  String get id => _id;

  set id(String id) {
    _id = id;
  }
}

///Used internally to save and restore [PlatformInAppWebViewController] properties
///for the keep alive feature.
class InAppWebViewControllerKeepAliveProps {
  Map<String, Function> javaScriptHandlersMap;
  Map<UserScriptInjectionTime, List<UserScript>> userScripts;
  Set<String> webMessageListenerObjNames;
  Map<String, ScriptHtmlTagAttributes> injectedScriptsFromURL;
  Set<PlatformWebMessageChannel> webMessageChannels = Set();
  Set<PlatformWebMessageListener> webMessageListeners = Set();
  Map<String, Function(dynamic data)> devToolsProtocolEventListenerMap;

  InAppWebViewControllerKeepAliveProps({
    this.javaScriptHandlersMap = const {},
    this.userScripts = const {},
    this.webMessageListenerObjNames = const {},
    this.injectedScriptsFromURL = const {},
    this.webMessageChannels = const {},
    this.webMessageListeners = const {},
    this.devToolsProtocolEventListenerMap = const {},
  });
}
