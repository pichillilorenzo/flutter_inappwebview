// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onPermissionRequest] event.
class PermissionRequest {
  ///The origin of web content which attempt to access the restricted resources.
  Uri origin;

  ///List of resources the web content wants to access.
  ///
  ///**NOTE for iOS**: this list will have only 1 element and will be used by the [PermissionResponse.action]
  ///as the resource to consider when applying the corresponding action.
  List<PermissionResourceType> resources;

  ///The frame that initiates the request in the web view.
  FrameInfo? frame;
  PermissionRequest(
      {required this.origin, this.resources = const [], this.frame});

  ///Gets a possible [PermissionRequest] instance from a [Map] value.
  static PermissionRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PermissionRequest(
      origin: Uri.parse(map['origin']),
      frame: FrameInfo.fromMap(map['frame']?.cast<String, dynamic>()),
    );
    instance.resources = List<PermissionResourceType>.from(map['resources']
        .map((e) => PermissionResourceType.fromNativeValue(e)!));
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "origin": origin.toString(),
      "resources": resources.map((e) => e.toNativeValue()).toList(),
      "frame": frame?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PermissionRequest{origin: $origin, resources: $resources, frame: $frame}';
  }
}
