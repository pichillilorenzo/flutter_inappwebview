import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class FindInteractionController {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  FindInteractionController(
      {void Function(PlatformFindInteractionController controller,
              int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)?
          onFindResultReceived})
      : this.fromPlatformCreationParams(
            params: PlatformFindInteractionControllerCreationParams(
                onFindResultReceived: onFindResultReceived));

  /// Constructs a [FindInteractionController].
  ///
  /// See [FindInteractionController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  FindInteractionController.fromPlatformCreationParams({
    required PlatformFindInteractionControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformFindInteractionController(params));

  /// Constructs a [FindInteractionController] from a specific platform implementation.
  FindInteractionController.fromPlatform({required this.platform});

  /// Implementation of [PlatformFindInteractionController] for the current platform.
  final PlatformFindInteractionController platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.onFindResultReceived}
  void Function(
      PlatformFindInteractionController controller,
      int activeMatchOrdinal,
      int numberOfMatches,
      bool isDoneCounting)? get onFindResultReceived => platform.onFindResultReceived;

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
  Future<void> findAll({String? find}) => platform.findAll(find: find);

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
  Future<void> findNext({bool forward = true}) =>
      platform.findNext(forward: forward);

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
  Future<void> clearMatches() => platform.clearMatches();

  ///Pre-populate the search text to be used.
  ///
  ///On iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true,
  ///it will pre-populate the system find panel's search text field with a search query.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2))
  ///- MacOS
  Future<void> setSearchText(String? searchText) =>
      platform.setSearchText(searchText);

  ///Get the search text used.
  ///
  ///On iOS, if [InAppWebViewSettings.isFindInteractionEnabled] is `true,
  ///it will get the system find panel's search text field value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2))
  ///- MacOS
  Future<String?> getSearchText() => platform.getSearchText();

  ///A Boolean value that indicates when the find panel displays onscreen.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.isFindNavigatorVisible](https://developer.apple.com/documentation/uikit/uifindinteraction/3975828-isfindnavigatorvisible?changes=_2))
  Future<bool?> isFindNavigatorVisible() => platform.isFindNavigatorVisible();

  ///Updates the results the interface displays for the active search.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.updateResultCount](https://developer.apple.com/documentation/uikit/uifindinteraction/3975835-updateresultcount?changes=_2))
  Future<void> updateResultCount() => platform.updateResultCount();

  ///Begins a search, displaying the find panel.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2))
  Future<void> presentFindNavigator() => platform.presentFindNavigator();

  ///Dismisses the find panel, if present.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2))
  Future<void> dismissFindNavigator() => platform.dismissFindNavigator();

  ///If there's a currently active find session, returns the active find session.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.activeFindSession](https://developer.apple.com/documentation/uikit/uifindinteraction/3975825-activefindsession?changes=_7____4_8&language=objc))
  ///- MacOS
  Future<FindSession?> getActiveFindSession() =>
      platform.getActiveFindSession();

  ///Disposes the controller.
  void dispose({bool isKeepAlive = false}) => platform.dispose();
}
