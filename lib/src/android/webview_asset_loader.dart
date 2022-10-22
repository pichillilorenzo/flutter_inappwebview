import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/web_resource_response.dart';
import '../util.dart';
import '../in_app_webview/webview.dart';

part 'webview_asset_loader.g.dart';

///Helper class to load local files including application's static assets and resources using http(s):// URLs inside a [WebView] class.
///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
///
///For more context about application's assets and resources and how to normally access them please refer to
///[Android Developer Docs: App resources overview](https://developer.android.com/guide/topics/resources/providing-resources).
///
///Using http(s):// URLs to access local resources may conflict with a real website.
///This means that local files should only be hosted on domains your organization owns
///(at paths reserved for this purpose) or the default domain reserved for this: `appassets.androidplatform.net`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
@ExchangeableObject(copyMethod: true)
class WebViewAssetLoader_ {
  ///An unused domain reserved for Android applications to intercept requests for app assets.
  ///
  ///It is used by default unless the user specified a different domain.
  static final String DEFAULT_DOMAIN = "appassets.androidplatform.net";

  ///Set the domain under which app assets can be accessed. The default domain is `appassets.androidplatform.net`.
  String? domain;

  ///Allow using the HTTP scheme in addition to HTTPS. The default is to not allow HTTP.
  bool? httpAllowed;

  ///List of registered path handlers.
  ///
  ///[WebViewAssetLoader] will try Path Handlers in the order they're registered,
  ///and will use whichever is the first to return a non-null.
  List<PathHandler_>? pathHandlers;

  WebViewAssetLoader_({this.domain, this.httpAllowed, this.pathHandlers});
}

///A handler that produces responses for a registered path.
///
///Implement this interface to handle other use-cases according to your app's needs.
@ExchangeableObject(fromMapFactory: false)
abstract class PathHandler_ {
  late final String _type;
  late final String _id;
  late final MethodChannel _channel;

  ///The suffix path to be handled.
  ///
  ///The path should start and end with a `"/"` and it shouldn't collide with a real web path.
  String path;

  @ExchangeableObjectConstructor()
  PathHandler_({required this.path}) {
    _type = this.runtimeType.toString();
    _id = IdGenerator.generate();
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_custompathhandler_$_id');
    this._channel.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "handle":
        String path = call.arguments["path"];
        return (await handle(path))?.toMap();
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Handles the requested URL by returning the appropriate response.
  ///
  ///Returning a `null` value means that the handler decided not to handle this path.
  ///In this case, [WebViewAssetLoader] will try the next handler registered on this path or pass to [WebView] that will fall back to network to try to resolve the URL.
  ///
  ///However, if the handler wants to save unnecessary processing either by another handler or by falling back to network,
  ///in cases like a file cannot be found, it may return a `WebResourceResponse(data: null)`
  ///which is received as an HTTP response with status code `404` and no body.
  Future<WebResourceResponse?> handle(String path) async {
    return null;
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith() {
    return {"type": _type, "id": _id};
  }
}

///Handler class to open a file from assets directory in the application APK.
///
///Opens the requested file from the application's assets directory.
///
///The matched prefix path used shouldn't be a prefix of a real web path.
///Thus, if the requested file cannot be found a [WebResourceResponse] object with a `null` data will be returned instead of `null`.
///This saves the time of falling back to network and trying to resolve a path that doesn't exist.
///A [WebResourceResponse] with `null` data will be received as an HTTP response with status code `404` and no body.
///
///The MIME type for the file will be determined from the file's extension using
///[guessContentTypeFromName](https://developer.android.com/reference/java/net/URLConnection.html#guessContentTypeFromName-java.lang.String-).
///Developers should ensure that asset files are named using standard file extensions.
///If the file does not have a recognised extension, `text/plain` will be used by default.
@ExchangeableObject()
class AssetsPathHandler_ extends PathHandler_ {
  AssetsPathHandler_({required String path}) : super(path: path) {}

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith() {
    return {"type": _type};
  }
}

///Handler class to open a file from resources directory in the application APK.
///
///Opens the requested file from application's resources directory.
///
///The matched prefix path used shouldn't be a prefix of a real web path.
///Thus, if the requested file cannot be found a [WebResourceResponse] object with a `null` data will be returned instead of `null`.
///This saves the time of falling back to network and trying to resolve a path that doesn't exist.
///A [WebResourceResponse] with `null` data will be received as an HTTP response with status code `404` and no body.
///
///The MIME type for the file will be determined from the file's extension using
///[guessContentTypeFromName](https://developer.android.com/reference/java/net/URLConnection.html#guessContentTypeFromName-java.lang.String-).
///Developers should ensure that asset files are named using standard file extensions.
///If the file does not have a recognised extension, `text/plain` will be used by default.
@ExchangeableObject()
class ResourcesPathHandler_ extends PathHandler_ {
  ResourcesPathHandler_({required String path}) : super(path: path) {}

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith() {
    return {"type": _type};
  }
}

///Handler class to open files from application internal storage.
///For more information about android storage please refer to
///[Android Developers Docs: Data and file storage overview](https://developer.android.com/guide/topics/data/data-storage).
///
///To avoid leaking user or app data to the web, make sure to choose [directory] carefully,
///and assume any file under this directory could be accessed by any web page subject to same-origin rules.
///
///Opens the requested file from the exposed data directory.
///
///The matched prefix path used shouldn't be a prefix of a real web path.
///Thus, if the requested file cannot be found a [WebResourceResponse] object with a `null` data will be returned instead of `null`.
///This saves the time of falling back to network and trying to resolve a path that doesn't exist.
///A [WebResourceResponse] with `null` data will be received as an HTTP response with status code `404` and no body.
///
///The MIME type for the file will be determined from the file's extension using
///[guessContentTypeFromName](https://developer.android.com/reference/java/net/URLConnection.html#guessContentTypeFromName-java.lang.String-).
///Developers should ensure that asset files are named using standard file extensions.
///If the file does not have a recognised extension, `text/plain` will be used by default.
@ExchangeableObject()
class InternalStoragePathHandler_ extends PathHandler_ {
  String directory;

  InternalStoragePathHandler_({required String path, required this.directory})
      : super(path: path) {}

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith() {
    return {"type": _type};
  }
}
