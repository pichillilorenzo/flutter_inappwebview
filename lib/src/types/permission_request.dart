import '../in_app_webview/webview.dart';
import 'permission_resource_type.dart';
import 'permission_response.dart';
import 'frame_info.dart';

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

    List<PermissionResourceType> resources = [];
    if (map["resources"] != null) {
      (map["resources"].cast<dynamic>() as List<dynamic>).forEach((element) {
        var resource = PermissionResourceType.fromNativeValue(element);
        if (resource != null) {
          resources.add(resource);
        }
      });
    }

    return PermissionRequest(
        origin: Uri.parse(map["origin"]),
        resources: resources,
        frame: FrameInfo.fromMap(map["frame"]?.cast<String, dynamic>()));
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "origin": origin.toString(),
      "resources": resources.map((e) => e.toValue()).toList(),
      "frame": frame?.toMap()
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