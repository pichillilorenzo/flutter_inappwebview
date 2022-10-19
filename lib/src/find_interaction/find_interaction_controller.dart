import 'package:flutter/services.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../debug_logging_settings.dart';
import '../types/main.dart';
import '../util.dart';

///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class FindInteractionController {
  MethodChannel? _channel;

  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the [numberOfMatches] value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  ///
  ///**NOTE**: on iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true`, this event will not be called.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.FindListener.onFindResultReceived](https://developer.android.com/reference/android/webkit/WebView.FindListener#onFindResultReceived(int,%20int,%20boolean)))
  ///- iOS
  ///- MacOS
  final void Function(
      FindInteractionController controller,
      int activeMatchOrdinal,
      int numberOfMatches,
      bool isDoneCounting)? onFindResultReceived;

  FindInteractionController({this.onFindResultReceived}) {}

  void initMethodChannel(dynamic id) {
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_find_interaction_$id');

    this._channel?.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        debugLoggingSettings: FindInteractionController.debugLoggingSettings,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onFindResultReceived":
        if (onFindResultReceived != null) {
          int activeMatchOrdinal = call.arguments["activeMatchOrdinal"];
          int numberOfMatches = call.arguments["numberOfMatches"];
          bool isDoneCounting = call.arguments["isDoneCounting"];
          onFindResultReceived!(
              this, activeMatchOrdinal, numberOfMatches, isDoneCounting);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///Finds all instances of find on the page and highlights them. Notifies [FindInteractionController.onFindResultReceived] listener.
  ///
  ///[find] represents the string to find.
  ///
  ///**NOTE**: on Android native WebView, it finds all instances asynchronously. Successive calls to this will cancel any pending searches.
  ///
  ///**NOTE**: on iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true`,
  ///it uses the built-in find interaction native UI,
  ///otherwise this is implemented using CSS and Javascript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.findAllAsync](https://developer.android.com/reference/android/webkit/WebView#findAllAsync(java.lang.String)))
  ///- iOS (if [InAppWebViewSettings.isFindInteractionEnabled] is `true`: [Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2) with [Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2))
  ///- MacOS
  Future<void> findAll({String? find}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('find', () => find);
    await _channel?.invokeMethod('findAll', args);
  }

  ///Highlights and scrolls to the next match found by [findAll]. Notifies [FindInteractionController.onFindResultReceived] listener.
  ///
  ///[forward] represents the direction to search. The default value is `true`, meaning forward.
  ///
  ///**NOTE**: on iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true`,
  ///it uses the built-in find interaction native UI,
  ///otherwise this is implemented using CSS and Javascript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.findNext](https://developer.android.com/reference/android/webkit/WebView#findNext(boolean)))
  ///- iOS (if [InAppWebViewSettings.isFindInteractionEnabled] is `true`: [Official API - UIFindInteraction.findNext](https://developer.apple.com/documentation/uikit/uifindinteraction/3975829-findnext?changes=_2) and ([Official API - UIFindInteraction.findPrevious](https://developer.apple.com/documentation/uikit/uifindinteraction/3975830-findprevious?changes=_2)))
  ///- MacOS
  Future<void> findNext({bool forward = true}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('forward', () => forward);
    await _channel?.invokeMethod('findNext', args);
  }

  ///Clears the highlighting surrounding text matches created by [findAll].
  ///
  ///**NOTE**: on iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true`,
  ///it uses the built-in find interaction native UI,
  ///otherwise this is implemented using CSS and Javascript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearMatches](https://developer.android.com/reference/android/webkit/WebView#clearMatches()))
  ///- iOS (if [InAppWebViewSettings.isFindInteractionEnabled] is `true`: [Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2))
  ///- MacOS
  Future<void> clearMatches() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel?.invokeMethod('clearMatches', args);
  }

  ///Pre-populate the search text to be used.
  ///
  ///On iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true,
  ///it will pre-populate the system find panel's search text field with a search query.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2))
  ///- MacOS
  Future<void> setSearchText(String? searchText) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('searchText', () => searchText);
    await _channel?.invokeMethod('setSearchText', args);
  }

  ///Get the search text used.
  ///
  ///On iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true,
  ///it will get the system find panel's search text field value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2))
  ///- MacOS
  Future<String?> getSearchText() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('getSearchText', args);
  }

  ///A Boolean value that indicates when the find panel displays onscreen.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.isFindNavigatorVisible](https://developer.apple.com/documentation/uikit/uifindinteraction/3975828-isfindnavigatorvisible?changes=_2))
  Future<bool?> isFindNavigatorVisible() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('isFindNavigatorVisible', args);
  }

  ///Updates the results the interface displays for the active search.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.updateResultCount](https://developer.apple.com/documentation/uikit/uifindinteraction/3975835-updateresultcount?changes=_2))
  Future<void> updateResultCount() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel?.invokeMethod('updateResultCount', args);
  }

  ///Begins a search, displaying the find panel.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2))
  Future<void> presentFindNavigator() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel?.invokeMethod('presentFindNavigator', args);
  }

  ///Dismisses the find panel, if present.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2))
  Future<void> dismissFindNavigator() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel?.invokeMethod('dismissFindNavigator', args);
  }

  ///If there's a currently active find session, returns the active find session.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.activeFindSession](https://developer.apple.com/documentation/uikit/uifindinteraction/3975825-activefindsession?changes=_7____4_8&language=objc))
  ///- MacOS
  Future<FindSession?> getActiveFindSession() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? result =
        (await _channel?.invokeMethod('getActiveFindSession', args))
            ?.cast<String, dynamic>();
    return FindSession.fromMap(result);
  }
}
