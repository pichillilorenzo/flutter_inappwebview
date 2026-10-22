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
///**Officially Supported Platforms/Implementations**:
///- iOS
class UIEventAttribution {
  ///The destination URL of the attribution.
  WebUri destinationURL;

  ///A string that describes the entity that purchased the attributed content.
  String purchaser;

  ///A description of the source of the attribution.
  String sourceDescription;

  ///An 8-bit number that identifies the source of the click for attribution. Value must be between 0 and 255.
  int sourceIdentifier;
  UIEventAttribution({
    required this.sourceIdentifier,
    required this.destinationURL,
    required this.sourceDescription,
    required this.purchaser,
  });

  ///Gets a possible [UIEventAttribution] instance from a [Map] value.
  static UIEventAttribution? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = UIEventAttribution(
      destinationURL: WebUri(map['destinationURL']),
      purchaser: map['purchaser'],
      sourceDescription: map['sourceDescription'],
      sourceIdentifier: map['sourceIdentifier'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "destinationURL": destinationURL.toString(),
      "purchaser": purchaser,
      "sourceDescription": sourceDescription,
      "sourceIdentifier": sourceIdentifier,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UIEventAttribution{destinationURL: $destinationURL, purchaser: $purchaser, sourceDescription: $sourceDescription, sourceIdentifier: $sourceIdentifier}';
  }
}
