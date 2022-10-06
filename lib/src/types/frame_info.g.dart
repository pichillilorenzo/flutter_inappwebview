// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information about a frame on a webpage.
class FrameInfo {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest? request;

  ///The frame’s security origin.
  SecurityOrigin? securityOrigin;
  FrameInfo({required this.isMainFrame, this.request, this.securityOrigin});

  ///Gets a possible [FrameInfo] instance from a [Map] value.
  static FrameInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FrameInfo(
      isMainFrame: map['isMainFrame'],
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>()),
      securityOrigin: SecurityOrigin.fromMap(
          map['securityOrigin']?.cast<String, dynamic>()),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(),
      "securityOrigin": securityOrigin?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FrameInfo{isMainFrame: $isMainFrame, request: $request, securityOrigin: $securityOrigin}';
  }
}

///An object that contains information about a frame on a webpage.
///
///**NOTE**: available only on iOS.
///
///Use [FrameInfo] instead.
@Deprecated('Use FrameInfo instead')
class IOSWKFrameInfo {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest? request;

  ///The frame’s security origin.
  IOSWKSecurityOrigin? securityOrigin;
  IOSWKFrameInfo(
      {required this.isMainFrame, this.request, this.securityOrigin});

  ///Gets a possible [IOSWKFrameInfo] instance from a [Map] value.
  static IOSWKFrameInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = IOSWKFrameInfo(
      isMainFrame: map['isMainFrame'],
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>()),
      securityOrigin: IOSWKSecurityOrigin.fromMap(
          map['securityOrigin']?.cast<String, dynamic>()),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(),
      "securityOrigin": securityOrigin?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSWKFrameInfo{isMainFrame: $isMainFrame, request: $request, securityOrigin: $securityOrigin}';
  }
}
