import 'permission_response.dart';

///Class used by [PermissionResponse] class.
class PermissionResponseAction {
  final int _value;

  const PermissionResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Denies the request.
  static const DENY = const PermissionResponseAction._internal(0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = const PermissionResponseAction._internal(1);

  ///Prompt the user for permission for the requested resource.
  ///
  ///**NOTE**: available only on iOS 15.0+. It will fallback to [DENY].
  static const PROMPT = const PermissionResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class used by [PermissionRequestResponse] class.
///Use [PermissionResponseAction] instead.
@Deprecated("Use PermissionResponseAction instead")
class PermissionRequestResponseAction {
  final int _value;

  const PermissionRequestResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Denies the request.
  static const DENY = const PermissionRequestResponseAction._internal(0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = const PermissionRequestResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}