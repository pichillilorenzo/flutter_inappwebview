// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that is used by [PlatformWebViewCreationParams.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
class NavigationResponseAction {
  final int _value;
  final int _nativeValue;
  const NavigationResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory NavigationResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      NavigationResponseAction._internal(value, nativeValue());

  ///Allow the navigation to continue.
  static const ALLOW = NavigationResponseAction._internal(1, 1);

  ///Cancel the navigation.
  static const CANCEL = NavigationResponseAction._internal(0, 0);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = NavigationResponseAction._internal(2, 2);

  ///Set of all values of [NavigationResponseAction].
  static final Set<NavigationResponseAction> values = [
    NavigationResponseAction.ALLOW,
    NavigationResponseAction.CANCEL,
    NavigationResponseAction.DOWNLOAD,
  ].toSet();

  ///Gets a possible [NavigationResponseAction] instance from [int] value.
  static NavigationResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return NavigationResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [NavigationResponseAction] instance from a native value.
  static NavigationResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return NavigationResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [NavigationResponseAction] instance value with name [name].
  ///
  /// Goes through [NavigationResponseAction.values] looking for a value with
  /// name [name], as reported by [NavigationResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static NavigationResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return NavigationResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [NavigationResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, NavigationResponseAction> asNameMap() =>
      <String, NavigationResponseAction>{
        for (final value in NavigationResponseAction.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ALLOW';
      case 0:
        return 'CANCEL';
      case 2:
        return 'DOWNLOAD';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}

///Class that is used by [PlatformWebViewCreationParams.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
///Use [NavigationResponseAction] instead.
@Deprecated('Use NavigationResponseAction instead')
class IOSNavigationResponseAction {
  final int _value;
  final int _nativeValue;
  const IOSNavigationResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSNavigationResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSNavigationResponseAction._internal(value, nativeValue());

  ///Allow the navigation to continue.
  static const ALLOW = IOSNavigationResponseAction._internal(1, 1);

  ///Cancel the navigation.
  static const CANCEL = IOSNavigationResponseAction._internal(0, 0);

  ///Set of all values of [IOSNavigationResponseAction].
  static final Set<IOSNavigationResponseAction> values = [
    IOSNavigationResponseAction.ALLOW,
    IOSNavigationResponseAction.CANCEL,
  ].toSet();

  ///Gets a possible [IOSNavigationResponseAction] instance from [int] value.
  static IOSNavigationResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSNavigationResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSNavigationResponseAction] instance from a native value.
  static IOSNavigationResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSNavigationResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSNavigationResponseAction] instance value with name [name].
  ///
  /// Goes through [IOSNavigationResponseAction.values] looking for a value with
  /// name [name], as reported by [IOSNavigationResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSNavigationResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return IOSNavigationResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSNavigationResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSNavigationResponseAction> asNameMap() =>
      <String, IOSNavigationResponseAction>{
        for (final value in IOSNavigationResponseAction.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ALLOW';
      case 0:
        return 'CANCEL';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
