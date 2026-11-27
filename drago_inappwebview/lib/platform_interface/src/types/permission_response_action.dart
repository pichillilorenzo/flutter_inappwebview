import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'permission_response.dart';

part 'permission_response_action.g.dart';

///Class used by [PermissionResponse] class.
@ExchangeableEnum()
class PermissionResponseAction_ {
  // ignore: unused_field
  final int _value;
  const PermissionResponseAction_._internal(this._value);

  ///Denies the request.
  static const DENY = PermissionResponseAction_._internal(0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = PermissionResponseAction_._internal(1);

  ///Prompt the user for permission for the requested resource.
  static const PROMPT = PermissionResponseAction_._internal(2);
}

///Class used by [PermissionRequestResponse] class.
///Use [PermissionResponseAction] instead.
@Deprecated("Use PermissionResponseAction instead")
@ExchangeableEnum()
class PermissionRequestResponseAction_ {
  // ignore: unused_field
  final int _value;
  const PermissionRequestResponseAction_._internal(this._value);

  ///Denies the request.
  static const DENY = PermissionRequestResponseAction_._internal(0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = PermissionRequestResponseAction_._internal(1);
}
