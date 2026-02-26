import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'window_features.g.dart';

///Class that specifies optional attributes for the containing window when a new web view is requested.
@ExchangeableObject()
class WindowFeatures_ {
  ///A Boolean value indicating whether the containing window should be resizable, or `null` if resizability is not specified.
  bool? allowsResizing;

  ///A Double value specifying the height of the containing window, or `null` if the height is not specified.
  double? height;

  ///A Boolean value indicating whether the menu bar should be visible, or `null` if menu bar visibility is not specified.
  bool? menuBarVisibility;

  ///A Boolean value indicating whether the status bar should be visible, or `null` if status bar visibility is not specified.
  bool? statusBarVisibility;

  ///A Boolean value indicating whether toolbars should be visible, or `null` if toolbars visibility is not specified.
  bool? toolbarsVisibility;

  ///A Double value specifying the width of the containing window, or `null` if the width is not specified.
  double? width;

  ///A Double value specifying the x-coordinate of the containing window, or `null` if the x-coordinate is not specified.
  double? x;

  ///A Double value specifying the y-coordinate of the containing window, or `null` if the y-coordinate is not specified.
  double? y;

  WindowFeatures_({
    this.allowsResizing,
    this.height,
    this.menuBarVisibility,
    this.statusBarVisibility,
    this.toolbarsVisibility,
    this.width,
    this.x,
    this.y,
  });
}

///An iOS-specific class that specifies optional attributes for the containing window when a new web view is requested.
///Use [WindowFeatures] instead.
@Deprecated("Use WindowFeatures instead")
@ExchangeableObject()
class IOSWKWindowFeatures_ {
  ///A Boolean value indicating whether the containing window should be resizable, or `null` if resizability is not specified.
  bool? allowsResizing;

  ///A Double value specifying the height of the containing window, or `null` if the height is not specified.
  double? height;

  ///A Boolean value indicating whether the menu bar should be visible, or `null` if menu bar visibility is not specified.
  bool? menuBarVisibility;

  ///A Boolean value indicating whether the status bar should be visible, or `null` if status bar visibility is not specified.
  bool? statusBarVisibility;

  ///A Boolean value indicating whether toolbars should be visible, or `null` if toolbars visibility is not specified.
  bool? toolbarsVisibility;

  ///A Double value specifying the width of the containing window, or `null` if the width is not specified.
  double? width;

  ///A Double value specifying the x-coordinate of the containing window, or `null` if the x-coordinate is not specified.
  double? x;

  ///A Double value specifying the y-coordinate of the containing window, or `null` if the y-coordinate is not specified.
  double? y;

  IOSWKWindowFeatures_({
    this.allowsResizing,
    this.height,
    this.menuBarVisibility,
    this.statusBarVisibility,
    this.toolbarsVisibility,
    this.width,
    this.x,
    this.y,
  });
}
