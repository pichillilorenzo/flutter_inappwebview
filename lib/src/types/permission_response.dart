import '../in_app_webview/webview.dart';
import 'permission_resource_type.dart';
import 'permission_response_action.dart';

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

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "resources": resources.map((e) => e.toValue()).toList(),
      "action": action?.toValue()
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the response used by the [WebView.androidOnPermissionRequest] event.
///Use [PermissionResponse] instead.
@Deprecated("Use PermissionResponse instead")
class PermissionRequestResponse {
  ///Resources granted to be accessed by origin.
  List<String> resources;

  ///Indicate the [PermissionRequestResponseAction] to take in response of a permission request.
  PermissionRequestResponseAction? action;

  PermissionRequestResponse(
      {this.resources = const [],
        this.action = PermissionRequestResponseAction.DENY});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"resources": resources, "action": action?.toValue()};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}