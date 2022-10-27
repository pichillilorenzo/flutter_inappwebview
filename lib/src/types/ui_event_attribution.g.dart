// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_event_attribution.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an object that contains event attribution information for Private Click Measurement.
///
///Apps use event attribution objects to send data to the browser when opening an external website that supports Private Click Measurement (PCM).
///For more information on the proposed PCM web standard, see [Introducing Private Click Measurement](https://webkit.org/blog/11529/introducing-private-click-measurement-pcm/)
///and [Private Click Measurement Draft Community Group Report](https://privacycg.github.io/private-click-measurement/).
///
///Check [UIEventAttribution](https://developer.apple.com/documentation/uikit/uieventattribution) for details.
///
///**Supported Platforms/Implementations**:
///- iOS
class UIEventAttribution {
  ///An 8-bit number that identifies the source of the click for attribution. Value must be between 0 and 255.
  int sourceIdentifier;

  ///The destination URL of the attribution.
  WebUri destinationURL;

  ///A description of the source of the attribution.
  String sourceDescription;

  ///A string that describes the entity that purchased the attributed content.
  String purchaser;
  UIEventAttribution(
      {required this.sourceIdentifier,
      required this.destinationURL,
      required this.sourceDescription,
      required this.purchaser});

  ///Gets a possible [UIEventAttribution] instance from a [Map] value.
  static UIEventAttribution? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = UIEventAttribution(
      sourceIdentifier: map['sourceIdentifier'],
      destinationURL: WebUri(map['destinationURL']),
      sourceDescription: map['sourceDescription'],
      purchaser: map['purchaser'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "sourceIdentifier": sourceIdentifier,
      "destinationURL": destinationURL.toString(),
      "sourceDescription": sourceDescription,
      "purchaser": purchaser,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UIEventAttribution{sourceIdentifier: $sourceIdentifier, destinationURL: $destinationURL, sourceDescription: $sourceDescription, purchaser: $purchaser}';
  }
}
