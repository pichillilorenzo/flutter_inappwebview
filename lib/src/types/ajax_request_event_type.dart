import 'ajax_request_event.dart';

///Class used by [AjaxRequestEvent] class.
class AjaxRequestEventType {
  final String _value;

  const AjaxRequestEventType._internal(this._value);

  ///Set of all values of [AjaxRequestEventType].
  static final Set<AjaxRequestEventType> values = [
    AjaxRequestEventType.LOADSTART,
    AjaxRequestEventType.LOAD,
    AjaxRequestEventType.LOADEND,
    AjaxRequestEventType.PROGRESS,
    AjaxRequestEventType.ERROR,
    AjaxRequestEventType.ABORT,
    AjaxRequestEventType.TIMEOUT,
  ].toSet();

  ///Gets a possible [AjaxRequestEventType] instance from a [String] value.
  static AjaxRequestEventType? fromValue(String? value) {
    if (value != null) {
      try {
        return AjaxRequestEventType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  String toString() => _value;

  ///The LOADSTART event is fired when a request has started to load data.
  static const LOADSTART = const AjaxRequestEventType._internal("loadstart");

  ///The LOAD event is fired when an `XMLHttpRequest` transaction completes successfully.
  static const LOAD = const AjaxRequestEventType._internal("load");

  ///The LOADEND event is fired when a request has completed, whether successfully (after [AjaxRequestEventType.LOAD]) or
  ///unsuccessfully (after [AjaxRequestEventType.ABORT] or [AjaxRequestEventType.ERROR]).
  static const LOADEND = const AjaxRequestEventType._internal("loadend");

  ///The PROGRESS event is fired periodically when a request receives more data.
  static const PROGRESS = const AjaxRequestEventType._internal("progress");

  ///The ERROR event is fired when the request encountered an error.
  static const ERROR = const AjaxRequestEventType._internal("error");

  ///The ABORT event is fired when a request has been aborted.
  static const ABORT = const AjaxRequestEventType._internal("abort");

  ///The TIMEOUT event is fired when progression is terminated due to preset time expiring.
  static const TIMEOUT = const AjaxRequestEventType._internal("timeout");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}