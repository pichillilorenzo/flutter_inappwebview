import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';
import 'package:drago_inappwebview/platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../debug_logging_settings.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';

part 'platform_find_interaction_controller.g.dart';

///{@template drago_inappwebview.PlatformFindInteractionControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformFindInteractionController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformFindInteractionControllerCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    LinuxPlatform(),
    WindowsPlatform(),
  ],
)
@immutable
class PlatformFindInteractionControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformFindInteractionController].
  const PlatformFindInteractionControllerCreationParams({
    this.onFindResultReceived,
  });

  ///{@template drago_inappwebview.PlatformFindInteractionControllerCreationParams.onFindResultReceived}
  ///Event fired as find-on-page operations progress.
  ///The listener may be notified multiple times while the operation is underway, and the [numberOfMatches] value should not be considered final unless [isDoneCounting] is true.
  ///
  ///[activeMatchOrdinal] represents the zero-based ordinal of the currently selected match.
  ///
  ///[numberOfMatches] represents how many matches have been found.
  ///
  ///[isDoneCounting] whether the find operation has actually completed.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionControllerCreationParams.onFindResultReceived.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.FindListener.onFindResultReceived',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView.FindListener#onFindResultReceived(int,%20int,%20boolean)',
      ),
      IOSPlatform(
        note:
            'If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, this event will not be called.',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'WebKitFindController::counted-matches',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.FindController.counted-matches.html',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2Find.ActiveMatchIndexChanged/MatchCountChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find',
      ),
    ],
  )
  final void Function(
    PlatformFindInteractionController controller,
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  )?
  onFindResultReceived;

  ///{@template drago_inappwebview.PlatformFindInteractionControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformFindInteractionControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template drago_inappwebview.PlatformFindInteractionControllerCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformFindInteractionControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformFindInteractionControllerCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );
}

///{@template drago_inappwebview.PlatformFindInteractionController}
///This class represents the controller used by the `WebView` to add
///text-finding capabilities, such as the "Find on page" feature.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformFindInteractionController.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    LinuxPlatform(),
    WindowsPlatform(),
  ],
)
abstract class PlatformFindInteractionController extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Creates a new [PlatformFindInteractionController]
  factory PlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformFindInteractionController webViewControllerDelegate =
        InAppWebViewPlatform.instance!.createPlatformFindInteractionController(
          params,
        );
    PlatformInterface.verify(webViewControllerDelegate, _token);
    return webViewControllerDelegate;
  }

  /// Creates a new [PlatformFindInteractionController]
  factory PlatformFindInteractionController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformFindInteractionController findInteractionControllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformFindInteractionControllerStatic();
    PlatformInterface.verify(findInteractionControllerStatic, _token);
    return findInteractionControllerStatic;
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

  ///{@macro drago_inappwebview.PlatformFindInteractionControllerCreationParams.onFindResultReceived}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionControllerCreationParams.onFindResultReceived.supported_platforms}
  void Function(
    PlatformFindInteractionController controller,
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  )?
  get onFindResultReceived => params.onFindResultReceived;

  ///{@template drago_inappwebview.PlatformFindInteractionController.findAll}
  ///Finds all instances of find on the page and highlights them. Notifies [PlatformFindInteractionController.onFindResultReceived] listener.
  ///
  ///[find] represents the string to find.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.findAll.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.findAllAsync',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#findAllAsync(java.lang.String)',
        note:
            'It finds all instances asynchronously. Successive calls to this will cancel any pending searches.',
      ),
      IOSPlatform(
        note:
            'If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it uses the built-in find interaction native UI, otherwise this is implemented using CSS and Javascript. In this case, it will use the [Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2) with [Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2)',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'webkit_find_controller_search',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search.html',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2Find.Start',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find#start',
      ),
    ],
  )
  Future<void> findAll({String? find}) {
    throw UnimplementedError(
      'findAll is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.setFindOptions}
  ///Sets the options used for find-on-page operations.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.setFindOptions.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Environment15.CreateFindOptions',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment15?view=webview2-1.0.2849.39#createfindoptions',
      ),
    ],
  )
  Future<void> setFindOptions({FindOptions? options}) {
    throw UnimplementedError(
      'setFindOptions is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.findNext}
  ///Highlights and scrolls to the next match found by [findAll]. Notifies [PlatformFindInteractionController.onFindResultReceived] listener.
  ///
  ///[forward] represents the direction to search. The default value is `true`, meaning forward.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.findNext.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.findNext',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#findNext(boolean)',
      ),
      IOSPlatform(
        note:
            'If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it uses the built-in find interaction native UI, otherwise this is implemented using CSS and Javascript. In this case, it will use the [Official API - UIFindInteraction.findNext](https://developer.apple.com/documentation/uikit/uifindinteraction/3975829-findnext?changes=_2) and ([Official API - UIFindInteraction.findPrevious](https://developer.apple.com/documentation/uikit/uifindinteraction/3975830-findprevious?changes=_2)',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'webkit_find_controller_search_next',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search_next.html',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2Find.FindNext/FindPrevious',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find#findnext',
      ),
    ],
  )
  Future<void> findNext({bool forward = true}) {
    throw UnimplementedError(
      'findNext is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.clearMatches}
  ///Clears the highlighting surrounding text matches created by [findAll].
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.clearMatches.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.clearMatches',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#clearMatches()',
      ),
      IOSPlatform(
        note:
            'If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it uses the built-in find interaction native UI, otherwise this is implemented using CSS and Javascript. In this case, it will use the [Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2)',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'webkit_find_controller_search_finish',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search_finish.html',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2Find.Stop',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find#stop',
      ),
    ],
  )
  Future<void> clearMatches() {
    throw UnimplementedError(
      'clearMatches is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.setSearchText}
  ///Pre-populate the search text to be used.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.setSearchText.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'UIFindInteraction.searchText',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2',
        note:
            'If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it will pre-populate the system find panel\'s search text field with a search query.',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'webkit_find_controller_search',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search.html',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2FindOptions.put_FindTerm',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2findoptions',
      ),
    ],
  )
  Future<void> setSearchText(String? searchText) {
    throw UnimplementedError(
      'setSearchText is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.getSearchText}
  ///Get the search text used.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.getSearchText.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'UIFindInteraction.getSearchText',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2',
        note:
            'If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it will get the system find panel\'s search text field value.',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'webkit_find_controller_get_search_text',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.get_search_text.html',
      ),
      WindowsPlatform(),
    ],
  )
  Future<String?> getSearchText() {
    throw UnimplementedError(
      'getSearchText is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.isFindNavigatorVisible}
  ///A Boolean value that indicates when the find panel displays onscreen.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.isFindNavigatorVisible.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIFindInteraction.isFindNavigatorVisible',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975828-isfindnavigatorvisible?changes=_2',
        note:
            'Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.',
      ),
    ],
  )
  Future<bool?> isFindNavigatorVisible() {
    throw UnimplementedError(
      'isFindNavigatorVisible is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.updateResultCount}
  ///Updates the results the interface displays for the active search.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.updateResultCount.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIFindInteraction.updateResultCount',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975835-updateresultcount?changes=_2',
        note:
            'Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.',
      ),
    ],
  )
  Future<void> updateResultCount() {
    throw UnimplementedError(
      'updateResultCount is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.presentFindNavigator}
  ///Begins a search, displaying the find panel.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.presentFindNavigator.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIFindInteraction.presentFindNavigator',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2',
        note:
            'Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.',
      ),
    ],
  )
  Future<void> presentFindNavigator() {
    throw UnimplementedError(
      'presentFindNavigator is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.dismissFindNavigator}
  ///Dismisses the find panel, if present.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.dismissFindNavigator.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIFindInteraction.dismissFindNavigator',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2',
        note:
            'Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.',
      ),
    ],
  )
  Future<void> dismissFindNavigator() {
    throw UnimplementedError(
      'dismissFindNavigator is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.getActiveFindSession}
  ///If there's a currently active find session, returns the active find session.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.getActiveFindSession.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'UIFindInteraction.activeFindSession',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uifindinteraction/3975825-activefindsession?changes=_7____4_8&language=objc',
      ),
      MacOSPlatform(),
      LinuxPlatform(
        apiName: 'WebKitFindController',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.FindController.html',
      ),
      WindowsPlatform(
        apiName: 'ICoreWebView2Find',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find',
      ),
    ],
  )
  Future<FindSession?> getActiveFindSession() {
    throw UnimplementedError(
      'getActiveFindSession is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformFindInteractionController.dispose}
  ///Disposes the controller.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformFindInteractionController.dispose.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(),
      WindowsPlatform(),
    ],
  )
  @override
  void dispose({bool isKeepAlive = false}) {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformFindInteractionControllerCreationParams.isPropertySupported}
  bool isPropertySupported(
    PlatformFindInteractionControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => params.isPropertySupported(property, platform: platform);

  ///{@template drago_inappwebview.PlatformFindInteractionController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformFindInteractionControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformFindInteractionControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
