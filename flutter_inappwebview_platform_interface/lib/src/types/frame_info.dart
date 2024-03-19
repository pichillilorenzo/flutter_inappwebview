import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_request.dart';
import 'security_origin.dart';

part 'frame_info.g.dart';

///An object that contains information about a frame on a webpage.
@ExchangeableObject()
class FrameInfo_ {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest_? request;

  ///The frame’s security origin.
  SecurityOrigin_? securityOrigin;

  FrameInfo_(
      {required this.isMainFrame, required this.request, this.securityOrigin});
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

  IOSWKFrameInfo_(
      {required this.isMainFrame, required this.request, this.securityOrigin});
}
