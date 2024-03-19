// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onPermissionRequest] event.
class PermissionRequest {
  ///The frame that initiates the request in the web view.
  FrameInfo? frame;

  ///The origin of web content which attempt to access the restricted resources.
  WebUri origin;

  ///List of resources the web content wants to access.
  ///
  ///**NOTE for iOS**: this list will have only 1 element and will be used by the [PermissionResponse.action]
  ///as the resource to consider when applying the corresponding action.
  List<PermissionResourceType> resources;
  PermissionRequest(
      {this.frame, required this.origin, this.resources = const []});

  ///Gets a possible [PermissionRequest] instance from a [Map] value.
  static PermissionRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PermissionRequest(
      frame: FrameInfo.fromMap(map['frame']?.cast<String, dynamic>()),
      origin: WebUri(map['origin']),
    );
    instance.resources = List<PermissionResourceType>.from(map['resources']
        .map((e) => PermissionResourceType.fromNativeValue(e)!));
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "frame": frame?.toMap(),
      "origin": origin.toString(),
      "resources": resources.map((e) => e.toNativeValue()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PermissionRequest{frame: $frame, origin: $origin, resources: $resources}';
  }
}
