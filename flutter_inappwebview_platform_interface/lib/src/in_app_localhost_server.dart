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

///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer}
class DefaultInAppLocalhostServer extends PlatformInAppLocalhostServer {
  bool _started = false;
  HttpServer? _server;
  int _port = 8080;
  bool _shared = false;
  String _directoryIndex = 'index.html';
  String _documentRoot = './';
  Future<bool> Function(HttpRequest)? _customOnData;

  /// Creates a new [DefaultInAppLocalhostServer].
  DefaultInAppLocalhostServer(PlatformInAppLocalhostServerCreationParams params)
      : super.implementation(
          params is DefaultInAppLocalhostServerCreationParams
              ? params
              : DefaultInAppLocalhostServerCreationParams
                  .fromPlatformInAppLocalhostServerCreationParams(params),
        ) {
    this._port = params.port;
    this._directoryIndex = params.directoryIndex;
    this._documentRoot = (params.documentRoot.endsWith('/'))
        ? params.documentRoot
        : '${params.documentRoot}/';
    this._shared = params.shared;
    this._customOnData = params.onData;
  }

  @override
  int get port => _port;

  @override
  String get directoryIndex => _directoryIndex;

  @override
  String get documentRoot => _documentRoot;

  @override
  bool get shared => _shared;

  @override
  Future<bool> Function(HttpRequest request)? get onData => _customOnData;

  @override
  Future<void> start() async {
    if (this._started) {
      throw Exception('Server already started on http://localhost:$_port');
    }
    this._started = true;

    final completer = Completer();

    runZonedGuarded(() {
      HttpServer.bind('127.0.0.1', _port, shared: _shared).then((server) {
        if (kDebugMode) {
          print('Server running on http://localhost:' + _port.toString());
        }

        this._server = server;

        server.listen((HttpRequest request) async {
          if (await _customOnData?.call(request) ?? false) {
            // if _customOnData returns true,
            // it means that the request has been handled
            return;
          }

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
            if (kDebugMode) {
              print(Uri.decodeFull(path));
              print(e.toString());
            }
            request.response.close();
            return;
          }

          var contentType = ContentType('text', 'html', charset: 'utf-8');
          if (!request.requestedUri.path.endsWith('/') &&
              request.requestedUri.pathSegments.isNotEmpty) {
            final mimeType = MimeTypeResolver.lookup(request.requestedUri.path);
            if (mimeType != null) {
              contentType = _getContentTypeFromMimeType(mimeType);
            }
          }

          request.response.headers.contentType = contentType;
          print(request.response.headers);
          request.response.add(body);
          request.response.close();
        });

        completer.complete();
      });
    }, (e, stackTrace) {
      if (kDebugMode) {
        print('Error: $e $stackTrace');
      }
    });

    return completer.future;
  }

  @override
  Future<void> close() async {
    if (this._server == null) {
      return;
    }
    await this._server!.close(force: true);
    if (kDebugMode) {
      print('Server running on http://localhost:$_port closed');
    }
    this._started = false;
    this._server = null;
  }

  @override
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
