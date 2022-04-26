import 'renderer_priority_policy.dart';

///Class used by [RendererPriorityPolicy] class.
class RendererPriority {
  final int _value;

  const RendererPriority._internal(this._value);

  ///Set of all values of [RendererPriority].
  static final Set<RendererPriority> values = [
    RendererPriority.RENDERER_PRIORITY_WAIVED,
    RendererPriority.RENDERER_PRIORITY_BOUND,
    RendererPriority.RENDERER_PRIORITY_IMPORTANT,
  ].toSet();

  ///Gets a possible [RendererPriority] instance from an [int] value.
  static RendererPriority? fromValue(int? value) {
    if (value != null) {
      try {
        return RendererPriority.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "RENDERER_PRIORITY_WAIVED";
      case 1:
        return "RENDERER_PRIORITY_BOUND";
      case 2:
      default:
        return "RENDERER_PRIORITY_IMPORTANT";
    }
  }

  ///The renderer associated with this WebView is bound with Android `Context#BIND_WAIVE_PRIORITY`.
  ///At this priority level WebView renderers will be strong targets for out of memory killing.
  static const RENDERER_PRIORITY_WAIVED = const RendererPriority._internal(0);

  ///The renderer associated with this WebView is bound with the default priority for services.
  static const RENDERER_PRIORITY_BOUND = const RendererPriority._internal(1);

  ///The renderer associated with this WebView is bound with Android `Context#BIND_IMPORTANT`.
  static const RENDERER_PRIORITY_IMPORTANT =
  const RendererPriority._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}