import 'url_request.dart';
import 'security_origin.dart';

///An object that contains information about a frame on a webpage.
class FrameInfo {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest? request;

  ///The frame’s security origin.
  SecurityOrigin? securityOrigin;

  FrameInfo(
      {required this.isMainFrame, required this.request, this.securityOrigin});

  ///Gets a possible [FrameInfo] instance from a [Map] value.
  static FrameInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return FrameInfo(
        isMainFrame: map["isMainFrame"],
        request: URLRequest.fromMap(map["request"]?.cast<String, dynamic>()),
        securityOrigin: SecurityOrigin.fromMap(
            map["securityOrigin"]?.cast<String, dynamic>()));
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(),
      "securityOrigin": securityOrigin?.toMap()
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///An object that contains information about a frame on a webpage.
///
///**NOTE**: available only on iOS.
///
///Use [FrameInfo] instead.
@Deprecated("Use FrameInfo instead")
class IOSWKFrameInfo {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest? request;

  ///The frame’s security origin.
  IOSWKSecurityOrigin? securityOrigin;

  IOSWKFrameInfo(
      {required this.isMainFrame, required this.request, this.securityOrigin});

  ///Gets a possible [IOSWKFrameInfo] instance from a [Map] value.
  static IOSWKFrameInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSWKFrameInfo(
        isMainFrame: map["isMainFrame"],
        request: URLRequest.fromMap(map["request"]?.cast<String, dynamic>()),
        securityOrigin: IOSWKSecurityOrigin.fromMap(
            map["securityOrigin"]?.cast<String, dynamic>()));
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(),
      "securityOrigin": securityOrigin?.toMap()
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}