import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';

part 'platform_container_controller.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformContainerControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformContainerController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '17.0'),
    MacOSPlatform(available: '14.0'),
    LinuxPlatform(),
  ],
)
@immutable
class PlatformContainerControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformContainerController].
  const PlatformContainerControllerCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformContainerControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformContainerControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformContainerController}
///Manages the named, persistent data partitions referenced by
///[InAppWebViewSettings.containerId]. A container groups its WebViews'
///cookies, `localStorage`, IndexedDB, ServiceWorkers and HTTP cache
///into one isolated store; multiple WebViews bound to the same
///`containerId` share that store.
///
///Use this controller to enumerate the containers created across app
///launches, check whether a given container already exists, or delete
///a container and all of its associated data. Containers are
///materialized lazily — a new `containerId` only appears in
///[getAllContainerNames] once a WebView has been constructed with it
///and Apple's data store has flushed to disk; on Android the entry
///is created eagerly by `ProfileStore.getOrCreateProfile`.
///
///On iOS / macOS Apple's underlying API stores data store identifiers
///as UUIDs, not as the original `containerId` strings the app supplied.
///This controller maintains an `id ↔ UUID` registry in
///`UserDefaults` so [getAllContainerNames] can return the original
///strings; the registry is updated automatically when a `containerId`
///is bound (via [InAppWebViewSettings.containerId]) or deleted (via
///[deleteContainer]).
///{@endtemplate}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'ProfileStore',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProfileStore',
      note:
          'Honored only when WebViewFeature.MULTI_PROFILE is supported (System WebView 119+).',
    ),
    IOSPlatform(
      apiName: 'WKWebsiteDataStore.allDataStoreIdentifiers',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188695-alldatastoreidentifiers',
      available: '17.0',
    ),
    MacOSPlatform(
      apiName: 'WKWebsiteDataStore.allDataStoreIdentifiers',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188695-alldatastoreidentifiers',
      available: '14.0',
    ),
  ],
)
abstract class PlatformContainerController extends PlatformInterface {
  /// Creates a new [PlatformContainerController]
  factory PlatformContainerController(
    PlatformContainerControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformContainerController containerController = InAppWebViewPlatform
        .instance!
        .createPlatformContainerController(params);
    PlatformInterface.verify(containerController, _token);
    return containerController;
  }

  /// Creates a new [PlatformContainerController] to access static methods.
  factory PlatformContainerController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformContainerController containerControllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformContainerControllerStatic();
    PlatformInterface.verify(containerControllerStatic, _token);
    return containerControllerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformContainerController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformContainerController.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformContainerController].
  final PlatformContainerControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformContainerController.getAllContainerNames}
  ///Returns the names of all containers known to the runtime, in
  ///unspecified order. On Android these are the names tracked by
  ///`ProfileStore`; on iOS / macOS they are the entries from the
  ///plugin's UUID registry that still appear in
  ///`WKWebsiteDataStore.allDataStoreIdentifiers` — stale registry
  ///entries (where the underlying store has been removed out of band)
  ///are filtered out.
  ///
  ///Throws [UnimplementedError] on platforms without per-container
  ///partitioning. Use
  ///[PlatformContainerController.params.isClassSupported] to gate
  ///UI that depends on listing.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.getAllProfileNames',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#getAllProfileNames()',
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.allDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188695-alldatastoreidentifiers',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName: 'WKWebsiteDataStore.allDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188695-alldatastoreidentifiers',
        available: '14.0',
      ),
      LinuxPlatform(
        note:
            "Returns the names of subdirectories under `<XDG_DATA_HOME>/flutter_inappwebview/containers/`. Empty when the directory does not exist.",
      ),
    ],
  )
  Future<List<String>> getAllContainerNames() {
    throw UnimplementedError(
      'getAllContainerNames is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformContainerController.hasContainer}
  ///Returns whether a container with [containerId] currently exists. On
  ///iOS / macOS this checks whether the derived UUID appears in
  ///`WKWebsiteDataStore.allDataStoreIdentifiers`; an existing
  ///registry entry alone is not sufficient.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.getAllProfileNames',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#getAllProfileNames()',
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.allDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188695-alldatastoreidentifiers',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName: 'WKWebsiteDataStore.allDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188695-alldatastoreidentifiers',
        available: '14.0',
      ),
      LinuxPlatform(
        note:
            "Checks for `<XDG_DATA_HOME>/flutter_inappwebview/containers/<id>/`.",
      ),
    ],
  )
  Future<bool> hasContainer(String containerId) {
    throw UnimplementedError(
      'hasContainer is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformContainerController.deleteContainer}
  ///Deletes the container with [containerId] and all of its data
  ///(cookies, `localStorage`, IndexedDB, ServiceWorkers, HTTP cache).
  ///Returns `true` if the container existed and was deleted, `false`
  ///otherwise.
  ///
  ///A container in use cannot be deleted. On iOS / macOS that is one a
  ///live WebView is bound to: `WKWebsiteDataStore.remove(forIdentifier:)`
  ///returns an error, so dispose those WebViews first. WebKit releases a
  ///disposed WebView's data store asynchronously, so a delete right after
  ///dispose can still fail and is worth retrying. On Android it is any
  ///container used since the app started; see the platform note.
  ///
  ///A deleted container also loses the proxy set for it through
  ///[PlatformProxyController.setProxyOverride] or
  ///[InAppWebViewSettings.proxySettings]: one created again under the same
  ///[containerId] starts from the app-wide proxy, like any new container.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.deleteProfile',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#deleteProfile(java.lang.String)',
        note:
            "Returns false for a container used since the app started: WebView keeps a profile loaded for the rest of the process once it has been used, and ProfileStore.deleteProfile refuses a loaded profile. Delete it on a later launch, before any WebView joins it.",
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.remove(forIdentifier:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188696-remove',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName: 'WKWebsiteDataStore.remove(forIdentifier:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4188696-remove',
        available: '14.0',
      ),
      LinuxPlatform(
        note:
            "Recursively removes both `<XDG_DATA_HOME>/flutter_inappwebview/containers/<id>/` and `<XDG_CACHE_HOME>/flutter_inappwebview/containers/<id>/`. The container's data is gone after the next process restart; if any WebView is still attached to its `WebKitNetworkSession` the in-memory state of that session is unaffected, except its proxy, which falls back to the app-wide one — dispose those WebViews first.",
      ),
    ],
  )
  Future<bool> deleteContainer(String containerId) {
    throw UnimplementedError(
      'deleteContainer is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformContainerController.clearContainerData}
  ///Clears the data inside the container named [containerId] without
  ///removing the container itself. Use this when WebViews are still
  ///bound to the container — unlike [deleteContainer], the underlying
  ///native store stays alive and any live WebView keeps working
  ///against an empty fresh state.
  ///
  ///Returns `true` if the platform reported the clear succeeded for
  ///the subsystems it can touch (see per-platform notes below). The
  ///set of subsystems isn't uniform — Apple's
  ///[`removeData(ofTypes:modifiedSince:completionHandler:)`](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata)
  ///is a single primitive that scopes cookies, DOM storage,
  ///IndexedDB, ServiceWorkers and the HTTP cache; Linux's
  ///[`webkit_website_data_manager_clear`](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.clear.html)
  ///is similarly comprehensive. Android's `androidx.webkit.Profile`
  ///doesn't expose a single clear-all; the implementation composes
  ///per-subsystem clears via `Profile.getCookieManager`,
  ///`Profile.getWebStorage` and `Profile.getGeolocationPermissions`,
  ///and the per-WebView HTTP cache + the *global* `ServiceWorker
  ///ControllerCompat` aren't reached by this call. Apps that need
  ///those wiped on Android should also call
  ///[PlatformInAppWebViewController.clearCache] on every live WebView
  ///in the container.
  ///
  ///Returns `false` if the container does not exist or the platform
  ///reported an error.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName:
            'Profile.getCookieManager / getWebStorage / getGeolocationPermissions',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile',
        note:
            "Best-effort: clears cookies, DOM storage (localStorage / IndexedDB / WebSQL / AppCache) and geolocation permissions. The per-WebView HTTP cache and the global ServiceWorkerControllerCompat are NOT cleared by this call. Honored only when WebViewFeature.MULTI_PROFILE is supported (System WebView 119+).",
      ),
      IOSPlatform(
        apiName:
            'WKWebsiteDataStore.removeData(ofTypes:modifiedSince:completionHandler:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata',
        available: '17.0',
        note:
            "Scoped to `WKWebsiteDataStore.allWebsiteDataTypes()` since the distant past — cookies, DOM storage, IndexedDB, ServiceWorkers, HTTP cache, fetch cache and more. Works while a WKWebView is still bound to the data store, which is the use-case `deleteContainer` cannot serve.",
      ),
      MacOSPlatform(
        apiName:
            'WKWebsiteDataStore.removeData(ofTypes:modifiedSince:completionHandler:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata',
        available: '14.0',
        note:
            "Scoped to `WKWebsiteDataStore.allWebsiteDataTypes()` since the distant past. Works while a WKWebView is still bound.",
      ),
      LinuxPlatform(
        apiName: 'webkit_website_data_manager_clear',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.clear.html',
        note:
            "Scoped to `WEBKIT_WEBSITE_DATA_ALL` with timespan 0 (since epoch). Works while a WebView is still bound to the container's `WebKitNetworkSession`. Returns false if the container's session has not been materialized yet (no WebView has joined it this process).",
      ),
    ],
  )
  Future<bool> clearContainerData(String containerId) {
    throw UnimplementedError(
      'clearContainerData is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformContainerController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformContainerControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformContainerControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
