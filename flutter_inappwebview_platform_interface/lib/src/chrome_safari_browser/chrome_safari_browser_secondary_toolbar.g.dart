// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chrome_safari_browser_secondary_toolbar.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the [RemoteViews](https://developer.android.com/reference/android/widget/RemoteViews.html)
///that will be shown on the secondary toolbar of a custom tab.
///
///This class describes a view hierarchy that can be displayed in another process.
///The hierarchy is inflated from an Android layout resource file.
///
///RemoteViews has limited to support to Android layouts.
///Check the [RemoteViews Official API](https://developer.android.com/reference/android/widget/RemoteViews.html) for more details.
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView:
///    - Not available in an Android Trusted Web Activity.
class ChromeSafariBrowserSecondaryToolbar {
  ///The IDs of clickable views. The `onClick` event of these views will be handled by custom tabs.
  List<ChromeSafariBrowserSecondaryToolbarClickableID> clickableIDs;

  ///The android layout resource.
  AndroidResource layout;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Not available in an Android Trusted Web Activity.
  ChromeSafariBrowserSecondaryToolbar({
    this.clickableIDs = const [],
    required this.layout,
  });

  ///Gets a possible [ChromeSafariBrowserSecondaryToolbar] instance from a [Map] value.
  static ChromeSafariBrowserSecondaryToolbar? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ChromeSafariBrowserSecondaryToolbar(
      layout: AndroidResource.fromMap(
        map['layout']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
    );
    if (map['clickableIDs'] != null) {
      instance.clickableIDs =
          List<ChromeSafariBrowserSecondaryToolbarClickableID>.from(
            map['clickableIDs'].map(
              (e) => ChromeSafariBrowserSecondaryToolbarClickableID.fromMap(
                e?.cast<String, dynamic>(),
                enumMethod: enumMethod,
              )!,
            ),
          );
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "clickableIDs": clickableIDs
          .map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "layout": layout.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ChromeSafariBrowserSecondaryToolbar{clickableIDs: $clickableIDs, layout: $layout}';
  }
}

///Class that represents a clickable ID item of the secondary toolbar for a [PlatformChromeSafariBrowser] instance.
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView:
///    - Not available in an Android Trusted Web Activity.
class ChromeSafariBrowserSecondaryToolbarClickableID {
  ///The android id resource
  AndroidResource id;

  ///Callback function to be invoked when the item is clicked
  void Function(WebUri?)? onClick;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Not available in an Android Trusted Web Activity.
  ChromeSafariBrowserSecondaryToolbarClickableID({
    required this.id,
    this.onClick,
  });

  ///Gets a possible [ChromeSafariBrowserSecondaryToolbarClickableID] instance from a [Map] value.
  static ChromeSafariBrowserSecondaryToolbarClickableID? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ChromeSafariBrowserSecondaryToolbarClickableID(
      id: AndroidResource.fromMap(
        map['id']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"id": id.toMap(enumMethod: enumMethod)};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ChromeSafariBrowserSecondaryToolbarClickableID{id: $id}';
  }
}
