// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onPermissionRequest] event.
class PermissionResponse {
  ///Resources granted to be accessed by origin.
  ///
  ///**NOTE for iOS**: not used. The [action] taken is based on the [PermissionRequest.resources].
  List<PermissionResourceType> resources;

  ///Indicate the [PermissionResponseAction] to take in response of a permission request.
  PermissionResponseAction? action;
  PermissionResponse(
      {this.resources = const [], this.action = PermissionResponseAction.DENY});

  ///Gets a possible [PermissionResponse] instance from a [Map] value.
  static PermissionResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PermissionResponse();
    instance.resources = List<PermissionResourceType>.from(map['resources']
        .map((e) => PermissionResourceType.fromNativeValue(e)!));
    instance.action = PermissionResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "resources": resources.map((e) => e.toNativeValue()).toList(),
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PermissionResponse{resources: $resources, action: $action}';
  }
}

///Class that represents the response used by the [WebView.androidOnPermissionRequest] event.
///Use [PermissionResponse] instead.
@Deprecated('Use PermissionResponse instead')
class PermissionRequestResponse {
  ///Resources granted to be accessed by origin.
  List<String> resources;

  ///Indicate the [PermissionRequestResponseAction] to take in response of a permission request.
  PermissionRequestResponseAction? action;
  PermissionRequestResponse(
      {this.resources = const [],
      this.action = PermissionRequestResponseAction.DENY});

  ///Gets a possible [PermissionRequestResponse] instance from a [Map] value.
  static PermissionRequestResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PermissionRequestResponse();
    instance.resources = map['resources'].cast<String>();
    instance.action =
        PermissionRequestResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "resources": resources,
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PermissionRequestResponse{resources: $resources, action: $action}';
  }
}
