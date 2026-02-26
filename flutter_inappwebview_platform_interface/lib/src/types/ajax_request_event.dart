import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'ajax_request.dart';
import 'ajax_request_event_type.dart';
import 'enum_method.dart';

part 'ajax_request_event.g.dart';

///Class used by [AjaxRequest] class. It represents events measuring progress of an [AjaxRequest].
@ExchangeableObject()
class AjaxRequestEvent_ {
  ///Event type.
  AjaxRequestEventType_? type;

  ///Is a Boolean flag indicating if the total work to be done, and the amount of work already done, by the underlying process is calculable.
  ///In other words, it tells if the progress is measurable or not.
  bool? lengthComputable;

  ///Is an integer representing the amount of work already performed by the underlying process.
  ///The ratio of work done can be calculated with the property and [AjaxRequestEvent.total].
  ///When downloading a resource using HTTP, this only represent the part of the content itself, not headers and other overhead.
  int? loaded;

  ///Is an integer representing the total amount of work that the underlying process is in the progress of performing.
  ///When downloading a resource using HTTP, this only represent the content itself, not headers and other overhead.
  int? total;

  AjaxRequestEvent_({
    this.type,
    this.lengthComputable,
    this.loaded,
    this.total,
  });
}
