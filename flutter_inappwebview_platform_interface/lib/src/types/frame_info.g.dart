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
  ///- Windows WebView2
  int? frameId;

  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool isMainFrame;

  ///The kind of the frame.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  FrameKind? kind;

  ///Gets the name attribute of the frame, as in <iframe name="frame-name">...</iframe>.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  String? name;

  ///The frame’s current request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  URLRequest? request;

  ///The frame’s security origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  SecurityOrigin? securityOrigin;
  FrameInfo(
      {this.frameId,
      required this.isMainFrame,
      this.kind,
      this.name,
      this.request,
      this.securityOrigin});

  ///Gets a possible [FrameInfo] instance from a [Map] value.
  static FrameInfo? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = FrameInfo(
      frameId: map['frameId'],
      isMainFrame: map['isMainFrame'],
      kind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => FrameKind.fromNativeValue(map['kind']),
        EnumMethod.value => FrameKind.fromValue(map['kind']),
        EnumMethod.name => FrameKind.byName(map['kind'])
      },
      name: map['name'],
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      securityOrigin: SecurityOrigin.fromMap(
          map['securityOrigin']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "frameId": frameId,
      "isMainFrame": isMainFrame,
      "kind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => kind?.toNativeValue(),
        EnumMethod.value => kind?.toValue(),
        EnumMethod.name => kind?.name()
      },
      "name": name,
      "request": request?.toMap(enumMethod: enumMethod),
      "securityOrigin": securityOrigin?.toMap(enumMethod: enumMethod),
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
  static IOSWKFrameInfo? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = IOSWKFrameInfo(
      isMainFrame: map['isMainFrame'],
      request: URLRequest.fromMap(map['request']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      securityOrigin: IOSWKSecurityOrigin.fromMap(
          map['securityOrigin']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(enumMethod: enumMethod),
      "securityOrigin": securityOrigin?.toMap(enumMethod: enumMethod),
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
