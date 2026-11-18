import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../debug_logging_settings.dart';
import '../in_app_browser/platform_in_app_browser.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../in_app_webview/platform_webview.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';
import 'pull_to_refresh_settings.dart';

// ignore: uri_has_not_been_generated
part 'platform_pull_to_refresh_controller.g.dart';

///{@template drago_inappwebview.PlatformPullToRefreshControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformPullToRefreshController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
class PlatformPullToRefreshControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformPullToRefreshController].
  PlatformPullToRefreshControllerCreationParams({
    @Deprecated("Use settings instead") PullToRefreshOptions? options,
    PullToRefreshSettings? settings,
    this.onRefresh,
  }) : options = options ?? PullToRefreshOptions(),
       settings = settings ?? PullToRefreshSettings();

  ///{@template drago_inappwebview.PlatformPullToRefreshControllerCreationParams.options}
  /// Use [settings] instead.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.options.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @Deprecated("Use settings instead")
  late PullToRefreshOptions options;

  ///{@template drago_inappwebview.PlatformPullToRefreshControllerCreationParams.settings}
  /// Initial settings.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.settings.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  late PullToRefreshSettings settings;

  ///{@template drago_inappwebview.PlatformPullToRefreshControllerCreationParams.onRefresh}
  ///Event called when a swipe gesture triggers a refresh.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.onRefresh.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final void Function()? onRefresh;

  ///{@template drago_inappwebview.PlatformPullToRefreshControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformPullToRefreshControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template drago_inappwebview.PlatformPullToRefreshControllerCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformPullToRefreshControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformPullToRefreshControllerCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );
}

///{@template drago_inappwebview.PlatformPullToRefreshController}
///A standard controller that can initiate the refreshing of a scroll view’s contents.
///This should be used whenever the user can refresh the contents of a WebView via a vertical swipe gesture.
///
///All the methods should be called only when the WebView has been created or is already running
///(for example [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformInAppBrowserEvents.onBrowserCreated]).
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformPullToRefreshController.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      note:
          '**NOTE**: to be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.',
    ),
    IOSPlatform(),
  ],
)
abstract class PlatformPullToRefreshController extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Creates a new [PlatformPullToRefreshController]
  factory PlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPullToRefreshController webViewControllerDelegate =
        InAppWebViewPlatform.instance!.createPlatformPullToRefreshController(
          params,
        );
    PlatformInterface.verify(webViewControllerDelegate, _token);
    return webViewControllerDelegate;
  }

  /// Creates a new empty [PlatformPullToRefreshController] to access static methods.
  factory PlatformPullToRefreshController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `drago_inappwebview` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPullToRefreshController controllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformPullToRefreshControllerStatic();
    PlatformInterface.verify(controllerStatic, _token);
    return controllerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformPullToRefreshController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformPullToRefreshController.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformPullToRefreshController].
  final PlatformPullToRefreshControllerCreationParams params;

  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.options}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.options.supported_platforms}
  @Deprecated("Use settings instead")
  PullToRefreshOptions get options => params.options;

  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.settings}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.settings.supported_platforms}
  PullToRefreshSettings get settings => params.settings;

  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.onRefresh}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.onRefresh.supported_platforms}
  void Function()? get onRefresh => params.onRefresh;

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setEnabled}
  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setEnabled',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setEnabled(boolean)',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.refreshControl',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol',
      ),
    ],
  )
  Future<void> setEnabled(bool enabled) {
    throw UnimplementedError(
      'setEnabled is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.isEnabled}
  ///Returns `true` is pull-to-refresh feature is enabled, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.isEnabled',
        apiUrl:
            'https://developer.android.com/reference/android/view/View#isEnabled()',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.refreshControl',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol',
      ),
    ],
  )
  Future<bool> isEnabled() {
    throw UnimplementedError(
      'isEnabled is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.beginRefreshing}
  ///Tells the controller that a refresh operation was started programmatically.
  ///
  ///Call this method when an external event source triggers a programmatic refresh of your scrolling view.
  ///This method updates the state of the refresh control to reflect the in-progress refresh operation.
  ///When the refresh operation ends, be sure to call the [endRefreshing] method to return the controller to its default state.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.beginRefreshing.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setRefreshing',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setRefreshing(boolean)',
      ),
      IOSPlatform(
        apiName: 'UIRefreshControl.beginRefreshing',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624842-beginrefreshing',
      ),
    ],
  )
  Future<void> beginRefreshing() {
    throw UnimplementedError(
      'beginRefreshing is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.endRefreshing}
  ///Tells the controller that a refresh operation has ended.
  ///
  ///Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user)
  ///to return the refresh control to its default state.
  ///If the refresh control is at least partially visible, calling this method also hides it.
  ///If animations are also enabled, the control is hidden using an animation.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.endRefreshing.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setRefreshing',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setRefreshing(boolean)',
      ),
      IOSPlatform(
        apiName: 'UIRefreshControl.endRefreshing',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624846-endrefreshing',
      ),
    ],
  )
  Future<void> endRefreshing() {
    throw UnimplementedError(
      'endRefreshing is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.isRefreshing}
  ///Returns whether a refresh operation has been triggered and is in progress.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isRefreshing.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.isRefreshing',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#isRefreshing()',
      ),
      IOSPlatform(
        apiName: 'UIRefreshControl.isRefreshing',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624844-isrefreshing',
      ),
    ],
  )
  Future<bool> isRefreshing() {
    throw UnimplementedError(
      'isRefreshing is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setColor}
  ///Sets the color of the refresh control.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setColor.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setColorSchemeColors',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setColorSchemeColors(int...)',
      ),
      IOSPlatform(
        apiName: 'UIRefreshControl.tintColor',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624847-tintcolor',
      ),
    ],
  )
  Future<void> setColor(Color color) {
    throw UnimplementedError(
      'setColor is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setBackgroundColor}
  ///Sets the background color of the refresh control.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setBackgroundColor.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setProgressBackgroundColorSchemeColor',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setProgressBackgroundColorSchemeColor(int)',
      ),
      IOSPlatform(
        apiName: 'UIView.backgroundColor',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor',
      ),
    ],
  )
  Future<void> setBackgroundColor(Color color) {
    throw UnimplementedError(
      'setBackgroundColor is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setDistanceToTriggerSync}
  ///Set the distance to trigger a sync in dips.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setDistanceToTriggerSync.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setDistanceToTriggerSync',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setDistanceToTriggerSync(int)',
      ),
    ],
  )
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) {
    throw UnimplementedError(
      'setDistanceToTriggerSync is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setSlingshotDistance}
  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setSlingshotDistance.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setSlingshotDistance',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSlingshotDistance(int)',
      ),
    ],
  )
  Future<void> setSlingshotDistance(int slingshotDistance) {
    throw UnimplementedError(
      'setSlingshotDistance is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.getDefaultSlingshotDistance}
  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.getDefaultSlingshotDistance.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#DEFAULT_SLINGSHOT_DISTANCE()',
      ),
    ],
  )
  Future<int> getDefaultSlingshotDistance() {
    throw UnimplementedError(
      'getDefaultSlingshotDistance is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setSize}
  ///Use [setIndicatorSize] instead.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setSize.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setSize',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)',
      ),
    ],
  )
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) {
    throw UnimplementedError(
      'setSize is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setIndicatorSize}
  ///Sets the size of the refresh indicator. One of [PullToRefreshSize.DEFAULT], or [PullToRefreshSize.LARGE].
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setIndicatorSize.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'SwipeRefreshLayout.setSize',
        apiUrl:
            'https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)',
      ),
    ],
  )
  Future<void> setIndicatorSize(PullToRefreshSize size) {
    throw UnimplementedError(
      'setIndicatorSize is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setAttributedTitle}
  ///Use [setStyledTitle] instead.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setAttributedTitle.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIRefreshControl.attributedTitle',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle',
      ),
    ],
  )
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) {
    throw UnimplementedError(
      'setAttributedTitle is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.setStyledTitle}
  ///Sets the styled title text to display in the refresh control.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setStyledTitle.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIRefreshControl.attributedTitle',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle',
      ),
    ],
  )
  Future<void> setStyledTitle(AttributedString attributedTitle) {
    throw UnimplementedError(
      'setStyledTitle is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformPullToRefreshController.dispose}
  ///Disposes the controller.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @override
  void dispose({bool isKeepAlive = false}) {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@macro drago_inappwebview.PlatformPullToRefreshControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformPullToRefreshControllerClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template drago_inappwebview.PlatformPullToRefreshController.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformPullToRefreshControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => params.isPropertySupported(property, platform: platform);

  ///{@template drago_inappwebview.PlatformPullToRefreshController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformPullToRefreshControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformPullToRefreshControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
