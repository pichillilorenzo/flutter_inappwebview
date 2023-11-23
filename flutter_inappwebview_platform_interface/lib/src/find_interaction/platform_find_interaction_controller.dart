import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../debug_logging_settings.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';

/// Object specifying creation parameters for creating a [PlatformFindInteractionController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformFindInteractionControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformFindInteractionController].
  const PlatformFindInteractionControllerCreationParams(
      {this.onFindResultReceived});

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.onFindResultReceived}
  final void Function(
      PlatformFindInteractionController controller,
      int activeMatchOrdinal,
      int numberOfMatches,
      bool isDoneCounting)? onFindResultReceived;
}

///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
abstract class PlatformFindInteractionController extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Creates a new [PlatformFindInteractionController]
  factory PlatformFindInteractionController(
      PlatformFindInteractionControllerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformFindInteractionController webViewControllerDelegate =
        InAppWebViewPlatform.instance!
            .createPlatformFindInteractionController(params);
    PlatformInterface.verify(webViewControllerDelegate, _token);
    return webViewControllerDelegate;
  }

  /// Used by the platform implementation to create a new [PlatformFindInteractionController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformFindInteractionController.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformFindInteractionController].
  final PlatformFindInteractionControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.onFindResultReceived}
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
  ///{@endtemplate}
  void Function(PlatformFindInteractionController controller,
          int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)?
      get onFindResultReceived => params.onFindResultReceived;

  ///Finds all instances of find on the page and highlights them. Notifies [PlatformFindInteractionController.onFindResultReceived] listener.
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
  Future<void> findAll({String? find}) {
    throw UnimplementedError(
        'findAll is not implemented on the current platform');
  }

  ///Highlights and scrolls to the next match found by [findAll]. Notifies [PlatformFindInteractionController.onFindResultReceived] listener.
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
  Future<void> findNext({bool forward = true}) {
    throw UnimplementedError(
        'findNext is not implemented on the current platform');
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
  Future<void> clearMatches() {
    throw UnimplementedError(
        'clearMatches is not implemented on the current platform');
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
  Future<void> setSearchText(String? searchText) {
    throw UnimplementedError(
        'setSearchText is not implemented on the current platform');
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
  Future<String?> getSearchText() {
    throw UnimplementedError(
        'getSearchText is not implemented on the current platform');
  }

  ///A Boolean value that indicates when the find panel displays onscreen.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.isFindNavigatorVisible](https://developer.apple.com/documentation/uikit/uifindinteraction/3975828-isfindnavigatorvisible?changes=_2))
  Future<bool?> isFindNavigatorVisible() {
    throw UnimplementedError(
        'isFindNavigatorVisible is not implemented on the current platform');
  }

  ///Updates the results the interface displays for the active search.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.updateResultCount](https://developer.apple.com/documentation/uikit/uifindinteraction/3975835-updateresultcount?changes=_2))
  Future<void> updateResultCount() {
    throw UnimplementedError(
        'updateResultCount is not implemented on the current platform');
  }

  ///Begins a search, displaying the find panel.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2))
  Future<void> presentFindNavigator() {
    throw UnimplementedError(
        'presentFindNavigator is not implemented on the current platform');
  }

  ///Dismisses the find panel, if present.
  ///
  ///**NOTE**: available only on iOS and only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2))
  Future<void> dismissFindNavigator() {
    throw UnimplementedError(
        'dismissFindNavigator is not implemented on the current platform');
  }

  ///If there's a currently active find session, returns the active find session.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIFindInteraction.activeFindSession](https://developer.apple.com/documentation/uikit/uifindinteraction/3975825-activefindsession?changes=_7____4_8&language=objc))
  ///- MacOS
  Future<FindSession?> getActiveFindSession() {
    throw UnimplementedError(
        'getActiveFindSession is not implemented on the current platform');
  }

  @override
  void dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}
