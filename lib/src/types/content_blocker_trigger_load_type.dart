import '../content_blocker.dart';

///Class that represents the possible load type for a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadType {
  final String _value;

  const ContentBlockerTriggerLoadType._internal(this._value);

  ///Set of all values of [ContentBlockerTriggerLoadType].
  static final Set<ContentBlockerTriggerLoadType> values = [
    ContentBlockerTriggerLoadType.FIRST_PARTY,
    ContentBlockerTriggerLoadType.THIRD_PARTY,
  ].toSet();

  ///Gets a possible [ContentBlockerTriggerLoadType] instance from a [String] value.
  static ContentBlockerTriggerLoadType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///FIRST_PARTY is triggered only if the resource has the same scheme, domain, and port as the main page resource.
  static const FIRST_PARTY =
  const ContentBlockerTriggerLoadType._internal('first-party');

  ///THIRD_PARTY is triggered if the resource is not from the same domain as the main page resource.
  static const THIRD_PARTY =
  const ContentBlockerTriggerLoadType._internal('third-party');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}