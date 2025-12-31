import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_request.dart';
import 'security_origin.dart';
import 'frame_kind.dart';
import 'enum_method.dart';

part 'frame_info.g.dart';

///An object that contains information about a frame on a webpage.
@ExchangeableObject()
class FrameInfo_ {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  @SupportedPlatforms(
    platforms: [IOSPlatform(), MacOSPlatform(), WindowsPlatform()],
  )
  bool isMainFrame;

  ///The frame’s current request.
  @SupportedPlatforms(
    platforms: [IOSPlatform(), MacOSPlatform(), WindowsPlatform()],
  )
  URLRequest_? request;

  ///The frame’s security origin.
  @SupportedPlatforms(
    platforms: [IOSPlatform(), MacOSPlatform(), WindowsPlatform()],
  )
  SecurityOrigin_? securityOrigin;

  ///Gets the name attribute of the frame, as in <iframe name="frame-name">...</iframe>.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  String? name;

  ///The unique identifier of the frame associated with the current [FrameInfo].
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  int? frameId;

  ///The kind of the frame.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  FrameKind_? kind;

  FrameInfo_({
    required this.isMainFrame,
    required this.request,
    this.securityOrigin,
    this.name,
    this.frameId,
    this.kind,
  });
}

///An object that contains information about a frame on a webpage.
///
///**NOTE**: available only on iOS.
///
///Use [FrameInfo] instead.
@Deprecated("Use FrameInfo instead")
@ExchangeableObject()
class IOSWKFrameInfo_ {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest_? request;

  ///The frame’s security origin.
  IOSWKSecurityOrigin_? securityOrigin;

  IOSWKFrameInfo_({
    required this.isMainFrame,
    required this.request,
    this.securityOrigin,
  });
}
