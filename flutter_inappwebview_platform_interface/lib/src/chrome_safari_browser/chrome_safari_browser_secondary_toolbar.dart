import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/android_resource.dart';
import '../web_uri.dart';
import 'platform_chrome_safari_browser.dart';
import '../types/enum_method.dart';

part 'chrome_safari_browser_secondary_toolbar.g.dart';

///Class that represents the [RemoteViews](https://developer.android.com/reference/android/widget/RemoteViews.html)
///that will be shown on the secondary toolbar of a custom tab.
///
///This class describes a view hierarchy that can be displayed in another process.
///The hierarchy is inflated from an Android layout resource file.
///
///RemoteViews has limited to support to Android layouts.
///Check the [RemoteViews Official API](https://developer.android.com/reference/android/widget/RemoteViews.html) for more details.
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(note: 'Not available in an Android Trusted Web Activity.'),
  ],
)
@ExchangeableObject()
class ChromeSafariBrowserSecondaryToolbar_ {
  ///The android layout resource.
  AndroidResource_ layout;

  ///The IDs of clickable views. The `onClick` event of these views will be handled by custom tabs.
  List<ChromeSafariBrowserSecondaryToolbarClickableID_> clickableIDs;

  ChromeSafariBrowserSecondaryToolbar_({
    required this.layout,
    this.clickableIDs = const [],
  });
}

///Class that represents a clickable ID item of the secondary toolbar for a [PlatformChromeSafariBrowser] instance.
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(note: 'Not available in an Android Trusted Web Activity.'),
  ],
)
@ExchangeableObject()
class ChromeSafariBrowserSecondaryToolbarClickableID_ {
  ///The android id resource
  AndroidResource_ id;

  ///Callback function to be invoked when the item is clicked
  void Function(WebUri? url)? onClick;

  ChromeSafariBrowserSecondaryToolbarClickableID_({
    required this.id,
    this.onClick,
  });
}
