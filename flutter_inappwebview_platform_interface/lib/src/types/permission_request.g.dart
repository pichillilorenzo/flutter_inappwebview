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
  ///**NOTE for iOS, macOS and Windows**: this list will have only 1 element and will be used by the [PermissionResponse.action]
  ///as the resource to consider when applying the corresponding action.
  List<PermissionResourceType> resources;
  PermissionRequest(
      {this.frame, required this.origin, this.resources = const []});

  ///Gets a possible [PermissionRequest] instance from a [Map] value.
  static PermissionRequest? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PermissionRequest(
      frame: FrameInfo.fromMap(map['frame']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      origin: WebUri(map['origin']),
    );
    if (map['resources'] != null) {
      instance.resources = List<PermissionResourceType>.from(map['resources']
          .map((e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                EnumMethod.nativeValue =>
                  PermissionResourceType.fromNativeValue(e),
                EnumMethod.value => PermissionResourceType.fromValue(e),
                EnumMethod.name => PermissionResourceType.byName(e)
              }!));
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "frame": frame?.toMap(enumMethod: enumMethod),
      "origin": origin.toString(),
      "resources": resources
          .map((e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                EnumMethod.nativeValue => e.toNativeValue(),
                EnumMethod.value => e.toValue(),
                EnumMethod.name => e.name()
              })
          .toList(),
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
