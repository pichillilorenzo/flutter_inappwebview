import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidFindInteractionController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformFindInteractionControllerCreationParams] for
/// more information.
@immutable
class AndroidFindInteractionControllerCreationParams
    extends PlatformFindInteractionControllerCreationParams {
  /// Creates a new [AndroidFindInteractionControllerCreationParams] instance.
  const AndroidFindInteractionControllerCreationParams(
      {super.onFindResultReceived});

  /// Creates a [AndroidFindInteractionControllerCreationParams] instance based on [PlatformFindInteractionControllerCreationParams].
  factory AndroidFindInteractionControllerCreationParams.fromPlatformFindInteractionControllerCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformFindInteractionControllerCreationParams params) {
    return AndroidFindInteractionControllerCreationParams(
        onFindResultReceived: params.onFindResultReceived);
  }
}

///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class AndroidFindInteractionController extends PlatformFindInteractionController
    with ChannelController {
  /// Constructs a [AndroidFindInteractionController].
  AndroidFindInteractionController(
      PlatformFindInteractionControllerCreationParams params)
      : super.implementation(
          params is AndroidFindInteractionControllerCreationParams
              ? params
              : AndroidFindInteractionControllerCreationParams
                  .fromPlatformFindInteractionControllerCreationParams(params),
        );

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        debugLoggingSettings:
            PlatformFindInteractionController.debugLoggingSettings,
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

  ///Finds all instances of find on the page and highlights them. Notifies [AndroidFindInteractionController.onFindResultReceived] listener.
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
    await channel?.invokeMethod('findAll', args);
  }

  ///Highlights and scrolls to the next match found by [findAll]. Notifies [AndroidFindInteractionController.onFindResultReceived] listener.
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
    await channel?.invokeMethod('findNext', args);
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
    await channel?.invokeMethod('clearMatches', args);
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
    await channel?.invokeMethod('setSearchText', args);
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
    return await channel?.invokeMethod<String?>('getSearchText', args);
  }

  ///A Boolean value that indicates when the find panel displays onscreen.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.isFindNavigatorVisible](https://developer.apple.com/documentation/uikit/uifindinteraction/3975828-isfindnavigatorvisible?changes=_2))
  Future<bool?> isFindNavigatorVisible() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool?>('isFindNavigatorVisible', args);
  }

  ///Updates the results the interface displays for the active search.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.updateResultCount](https://developer.apple.com/documentation/uikit/uifindinteraction/3975835-updateresultcount?changes=_2))
  Future<void> updateResultCount() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('updateResultCount', args);
  }

  ///Begins a search, displaying the find panel.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2))
  Future<void> presentFindNavigator() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('presentFindNavigator', args);
  }

  ///Dismisses the find panel, if present.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2))
  Future<void> dismissFindNavigator() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('dismissFindNavigator', args);
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
        (await channel?.invokeMethod('getActiveFindSession', args))
            ?.cast<String, dynamic>();
    return FindSession.fromMap(result);
  }

  ///Disposes the controller.
  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
  }
}

extension InternalFindInteractionController
    on AndroidFindInteractionController {
  void init(dynamic id) {
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_find_interaction_$id');
    handler = _handleMethod;
    initMethodCallHandler();
  }
}
