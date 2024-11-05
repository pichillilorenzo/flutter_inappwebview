// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information about a frame on a webpage.
class FrameInfo {
  ///The unique identifier of the frame associated with the current [FrameInfo].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  int? frameId;

  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///- Windows
  bool isMainFrame;

  ///The kind of the frame.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  FrameKind? kind;

  ///Gets the name attribute of the frame, as in <iframe name="frame-name">...</iframe>.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  String? name;

  ///The frame’s current request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///- Windows
  URLRequest? request;

  ///The frame’s security origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///- Windows
  SecurityOrigin? securityOrigin;
  FrameInfo(
      {this.frameId,
      required this.isMainFrame,
      this.kind,
      this.name,
      this.request,
      this.securityOrigin});

  ///Gets a possible [FrameInfo] instance from a [Map] value.
  static FrameInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FrameInfo(
      frameId: map['frameId'],
      isMainFrame: map['isMainFrame'],
      kind: FrameKind.fromNativeValue(map['kind']),
      name: map['name'],
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>()),
      securityOrigin: SecurityOrigin.fromMap(
          map['securityOrigin']?.cast<String, dynamic>()),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "frameId": frameId,
      "isMainFrame": isMainFrame,
      "kind": kind?.toNativeValue(),
      "name": name,
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
    return 'FrameInfo{frameId: $frameId, isMainFrame: $isMainFrame, kind: $kind, name: $name, request: $request, securityOrigin: $securityOrigin}';
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
