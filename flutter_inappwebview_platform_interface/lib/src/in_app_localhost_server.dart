import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'mime_type_resolver.dart';
import 'platform_in_app_localhost_server.dart';

/// Object specifying creation parameters for creating a [DefaultInAppLocalhostServer].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppLocalhostServerCreationParams] for
/// more information.
@immutable
class DefaultInAppLocalhostServerCreationParams
    extends PlatformInAppLocalhostServerCreationParams {
  /// Creates a new [DefaultInAppLocalhostServerCreationParams] instance.
  const DefaultInAppLocalhostServerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformInAppLocalhostServerCreationParams params,
  ) : super();

  /// Creates a [DefaultInAppLocalhostServerCreationParams] instance based on [PlatformInAppLocalhostServerCreationParams].
  factory DefaultInAppLocalhostServerCreationParams.fromPlatformInAppLocalhostServerCreationParams(
      PlatformInAppLocalhostServerCreationParams params) {
    return DefaultInAppLocalhostServerCreationParams(params);
  }
}

///This class allows you to create a simple server on `http://localhost:[port]/`
///in order to be able to load your assets file on a local server.
///The default `port` value is `8080`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class DefaultInAppLocalhostServer extends PlatformInAppLocalhostServer {
  bool _started = false;
  HttpServer? _server;
  int _port = 8080;
  bool _shared = false;
  String _directoryIndex = 'index.html';
  String _documentRoot = './';

  /// Creates a new [DefaultInAppLocalhostServer].
  DefaultInAppLocalhostServer(PlatformInAppLocalhostServerCreationParams params)
      : super.implementation(
          params is DefaultInAppLocalhostServerCreationParams
              ? params
              : DefaultInAppLocalhostServerCreationParams
                  .fromPlatformInAppLocalhostServerCreationParams(params),
        ) {
    this._port = port;
    this._directoryIndex = directoryIndex;
    this._documentRoot =
        (documentRoot.endsWith('/')) ? documentRoot : '$documentRoot/';
    this._shared = shared;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.port}
  int get port => _port;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  String get directoryIndex => _directoryIndex;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  String get documentRoot => _documentRoot;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  bool get shared => _shared;

  ///Starts the server on `http://localhost:[port]/`.
  ///
  ///**NOTE for iOS**: For the iOS Platform, you need to add the `NSAllowsLocalNetworking` key with `true` in the `Info.plist` file
  ///(See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35)):
  ///```xml
  ///<key>NSAppTransportSecurity</key>
  ///<dict>
  ///    <key>NSAllowsLocalNetworking</key>
  ///    <true/>
  ///</dict>
  ///```
  ///The `NSAllowsLocalNetworking` key is available since **iOS 10**.
  Future<void> start() async {
    if (this._started) {
      throw Exception('Server already started on http://localhost:$_port');
    }
    this._started = true;

    var completer = Completer();

    runZonedGuarded(() {
      HttpServer.bind('127.0.0.1', _port, shared: _shared).then((server) {
        print('Server running on http://localhost:' + _port.toString());

        this._server = server;

        server.listen((HttpRequest request) async {
          Uint8List body = Uint8List(0);

          var path = request.requestedUri.path;
          path = (path.startsWith('/')) ? path.substring(1) : path;
          path += (path.endsWith('/')) ? _directoryIndex : '';
          if (path == '') {
            // if the path still empty, try to load the index file
            path = _directoryIndex;
          }
          path = _documentRoot + path;

          try {
            body = (await rootBundle.load(Uri.decodeFull(path)))
                .buffer
                .asUint8List();
          } catch (e) {
            print(e.toString());
            request.response.close();
            return;
          }

          var contentType = ContentType('text', 'html', charset: 'utf-8');
          if (!request.requestedUri.path.endsWith('/') &&
              request.requestedUri.pathSegments.isNotEmpty) {
            var mimeType = MimeTypeResolver.lookup(request.requestedUri.path);
            if (mimeType != null) {
              contentType = _getContentTypeFromMimeType(mimeType);
            }
          }

          request.response.headers.contentType = contentType;
          request.response.add(body);
          request.response.close();
        });

        completer.complete();
      });
    }, (e, stackTrace) => print('Error: $e $stackTrace'));

    return completer.future;
  }

  ///Closes the server.
  Future<void> close() async {
    if (this._server == null) {
      return;
    }
    await this._server!.close(force: true);
    print('Server running on http://localhost:$_port closed');
    this._started = false;
    this._server = null;
  }

  ///Indicates if the server is running or not.
  bool isRunning() {
    return this._server != null;
  }

  ContentType _getContentTypeFromMimeType(String mimeType) {
    final contentType = mimeType.split('/');
    String? charset;

    if (_isTextFile(mimeType)) {
      charset = 'utf-8';
    }

    return ContentType(contentType[0], contentType[1], charset: charset);
  }

  bool _isTextFile(String mimeType) {
    final textFile = RegExp(r'^text\/|^application\/(javascript|json)');
    return textFile.hasMatch(mimeType);
  }
}
