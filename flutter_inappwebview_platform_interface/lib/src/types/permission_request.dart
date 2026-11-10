import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../web_uri.dart';
import 'permission_resource_type.dart';
import 'permission_response.dart';
import 'frame_info.dart';
import 'enum_method.dart';

part 'permission_request.g.dart';

List<PermissionResourceType> _deserializePermissionResources(
  dynamic value, {
  EnumMethod? enumMethod,
}) {
  if (value == null) {
    return const [];
  }

  final method = enumMethod ?? EnumMethod.nativeValue;
  return (value as Iterable<dynamic>).map((resourceValue) {
    final resource = switch (method) {
      EnumMethod.nativeValue => PermissionResourceType.fromNativeValue(
        resourceValue,
      ),
      EnumMethod.value => PermissionResourceType.fromValue(resourceValue),
      EnumMethod.name => PermissionResourceType.byName(resourceValue),
    };
    if (resource == null &&
        method == EnumMethod.nativeValue &&
        defaultTargetPlatform == TargetPlatform.windows) {
      return PermissionResourceType.UNKNOWN;
    }
    return resource!;
  }).toList();
}

///Class that represents the response used by the [PlatformWebViewCreationParams.onPermissionRequest] event.
@ExchangeableObject()
class PermissionRequest_ {
  ///The origin of web content which attempt to access the restricted resources.
  WebUri origin;

  ///List of resources the web content wants to access.
  ///
  ///**NOTE for iOS, macOS and Windows**: this list will have only 1 element and will be used by the [PermissionResponse.action]
  ///as the resource to consider when applying the corresponding action.
  @ExchangeableObjectProperty(deserializer: _deserializePermissionResources)
  List<PermissionResourceType_> resources;

  ///The frame that initiates the request in the web view.
  FrameInfo_? frame;

  PermissionRequest_({
    required this.origin,
    this.resources = const [],
    this.frame,
  });
}
