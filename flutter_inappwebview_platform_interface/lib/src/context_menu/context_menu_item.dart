import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'context_menu.dart';
import '../util.dart';
import '../types/enum_method.dart';

part 'context_menu_item.g.dart';

///Class that represent an item of the [ContextMenu].
@ExchangeableObject()
class ContextMenuItem_ {
  ///Use [id] instead.
  @Deprecated("Use id instead")
  int? androidId;

  ///Use [id] instead.
  @Deprecated("Use id instead")
  String? iosId;

  ///Menu item ID. It cannot be `null` and it can be a [String] or an [int].
  ///
  ///**NOTE for Android**: it must be an [int] value.
  dynamic id;

  ///Menu item title.
  String title;

  ///Menu item action that will be called when an user clicks on it.
  Function()? action;

  @ExchangeableObjectConstructor()
  ContextMenuItem_({
    this.id,
    @Deprecated("Use id instead") this.androidId,
    @Deprecated("Use id instead") this.iosId,
    required this.title,
    this.action,
  }) {
    if (Util.isAndroid) {
      // ignore: deprecated_member_use_from_same_package
      this.id = this.id ?? this.androidId;
      assert(this.id is int);
    } else if (Util.isIOS) {
      // ignore: deprecated_member_use_from_same_package
      this.id = this.id ?? this.iosId;
    }
    assert(this.id != null && (this.id is int || this.id is String));
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {"androidId": androidId, "iosId": iosId};
  }
}
