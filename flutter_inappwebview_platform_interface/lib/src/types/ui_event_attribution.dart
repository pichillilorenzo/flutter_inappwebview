import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'enum_method.dart';

part 'ui_event_attribution.g.dart';

///Class that represents an object that contains event attribution information for Private Click Measurement.
///
///Apps use event attribution objects to send data to the browser when opening an external website that supports Private Click Measurement (PCM).
///For more information on the proposed PCM web standard, see [Introducing Private Click Measurement](https://webkit.org/blog/11529/introducing-private-click-measurement-pcm/)
///and [Private Click Measurement Draft Community Group Report](https://privacycg.github.io/private-click-measurement/).
///
///Check [UIEventAttribution](https://developer.apple.com/documentation/uikit/uieventattribution) for details.
///
///**Officially Supported Platforms/Implementations**:
///- iOS
@ExchangeableObject()
class UIEventAttribution_ {
  ///An 8-bit number that identifies the source of the click for attribution. Value must be between 0 and 255.
  int sourceIdentifier;

  ///The destination URL of the attribution.
  WebUri destinationURL;

  ///A description of the source of the attribution.
  String sourceDescription;

  ///A string that describes the entity that purchased the attributed content.
  String purchaser;

  @ExchangeableObjectConstructor()
  UIEventAttribution_(
      {required this.sourceIdentifier,
      required this.destinationURL,
      required this.sourceDescription,
      required this.purchaser});
}
