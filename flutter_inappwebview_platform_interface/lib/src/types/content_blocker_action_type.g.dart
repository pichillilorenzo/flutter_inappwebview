// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_action_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the kind of action that can be used with a [ContentBlockerTrigger].
class ContentBlockerActionType {
  final String _value;
  final String _nativeValue;
  const ContentBlockerActionType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ContentBlockerActionType._internalMultiPlatform(
          String value, Function nativeValue) =>
      ContentBlockerActionType._internal(value, nativeValue());

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final BLOCK =
      ContentBlockerActionType._internalMultiPlatform('block', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'block';
      case TargetPlatform.iOS:
        return 'block';
      case TargetPlatform.macOS:
        return 'block';
      default:
        break;
    }
    return null;
  });

  ///Strips cookies from the header before sending it to the server.
  ///This only blocks cookies otherwise acceptable to WebView's privacy policy.
  ///Combining with [IGNORE_PREVIOUS_RULES] doesn't override the browser’s privacy settings.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  static final BLOCK_COOKIES =
      ContentBlockerActionType._internalMultiPlatform('block-cookies', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'block-cookies';
      case TargetPlatform.macOS:
        return 'block-cookies';
      default:
        break;
    }
    return null;
  });

  ///Hides elements of the page based on a CSS selector.
  ///A selector field contains the selector list.
  ///Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final CSS_DISPLAY_NONE =
      ContentBlockerActionType._internalMultiPlatform('css-display-none', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'css-display-none';
      case TargetPlatform.iOS:
        return 'css-display-none';
      case TargetPlatform.macOS:
        return 'css-display-none';
      default:
        break;
    }
    return null;
  });

  ///Ignores previously triggered actions.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  static final IGNORE_PREVIOUS_RULES =
      ContentBlockerActionType._internalMultiPlatform('ignore-previous-rules',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ignore-previous-rules';
      case TargetPlatform.macOS:
        return 'ignore-previous-rules';
      default:
        break;
    }
    return null;
  });

  ///Changes a URL from http to https.
  ///URLs with a specified (nondefault) port and links using other protocols are unaffected.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final MAKE_HTTPS =
      ContentBlockerActionType._internalMultiPlatform('make-https', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'make-https';
      case TargetPlatform.iOS:
        return 'make-https';
      case TargetPlatform.macOS:
        return 'make-https';
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [ContentBlockerActionType].
  static final Set<ContentBlockerActionType> values = [
    ContentBlockerActionType.BLOCK,
    ContentBlockerActionType.BLOCK_COOKIES,
    ContentBlockerActionType.CSS_DISPLAY_NONE,
    ContentBlockerActionType.IGNORE_PREVIOUS_RULES,
    ContentBlockerActionType.MAKE_HTTPS,
  ].toSet();

  ///Gets a possible [ContentBlockerActionType] instance from [String] value.
  static ContentBlockerActionType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerActionType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ContentBlockerActionType] instance from a native value.
  static ContentBlockerActionType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerActionType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ContentBlockerActionType] instance value with name [name].
  ///
  /// Goes through [ContentBlockerActionType.values] looking for a value with
  /// name [name], as reported by [ContentBlockerActionType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ContentBlockerActionType? byName(String? name) {
    if (name != null) {
      try {
        return ContentBlockerActionType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ContentBlockerActionType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ContentBlockerActionType> asNameMap() =>
      <String, ContentBlockerActionType>{
        for (final value in ContentBlockerActionType.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'block':
        return 'BLOCK';
      case 'block-cookies':
        return 'BLOCK_COOKIES';
      case 'css-display-none':
        return 'CSS_DISPLAY_NONE';
      case 'ignore-previous-rules':
        return 'IGNORE_PREVIOUS_RULES';
      case 'make-https':
        return 'MAKE_HTTPS';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
