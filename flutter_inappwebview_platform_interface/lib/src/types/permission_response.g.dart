// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onPermissionRequest] event.
class PermissionResponse {
  ///Indicate the [PermissionResponseAction] to take in response of a permission request.
  PermissionResponseAction? action;

  ///Resources granted to be accessed by origin.
  ///
  ///**NOTE for iOS, macOS and Windows**: not used. The [action] taken is based on the [PermissionRequest.resources].
  List<PermissionResourceType> resources;
  PermissionResponse(
      {this.action = PermissionResponseAction.DENY, this.resources = const []});

  ///Gets a possible [PermissionResponse] instance from a [Map] value.
  static PermissionResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PermissionResponse();
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        PermissionResponseAction.fromNativeValue(map['action']),
      EnumMethod.value => PermissionResponseAction.fromValue(map['action']),
      EnumMethod.name => PermissionResponseAction.byName(map['action'])
    };
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
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name()
      },
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
    return 'PermissionResponse{action: $action, resources: $resources}';
  }
}

///Class that represents the response used by the [PlatformWebViewCreationParams.androidOnPermissionRequest] event.
///Use [PermissionResponse] instead.
@Deprecated('Use PermissionResponse instead')
class PermissionRequestResponse {
  ///Indicate the [PermissionRequestResponseAction] to take in response of a permission request.
  PermissionRequestResponseAction? action;

  ///Resources granted to be accessed by origin.
  List<String> resources;
  PermissionRequestResponse(
      {this.action = PermissionRequestResponseAction.DENY,
      this.resources = const []});

  ///Gets a possible [PermissionRequestResponse] instance from a [Map] value.
  static PermissionRequestResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PermissionRequestResponse();
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        PermissionRequestResponseAction.fromNativeValue(map['action']),
      EnumMethod.value =>
        PermissionRequestResponseAction.fromValue(map['action']),
      EnumMethod.name => PermissionRequestResponseAction.byName(map['action'])
    };
    if (map['resources'] != null) {
      instance.resources = List<String>.from(map['resources']!.cast<String>());
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name()
      },
      "resources": resources,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PermissionRequestResponse{action: $action, resources: $resources}';
  }
}
