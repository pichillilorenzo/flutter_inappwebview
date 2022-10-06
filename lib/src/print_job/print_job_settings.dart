import 'package:flutter/cupertino.dart';

import '../types/main.dart';
import '../util.dart';
import 'print_job_controller.dart';

///Class that represents the settings of a [PrintJobController].
class PrintJobSettings {
  ///Set this to `true` to handle the [PrintJobController].
  ///Otherwise, it will be handled and disposed automatically by the system.
  ///The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool handledByClient;

  ///The name of the print job.
  ///An application should set this property to a name appropriate to the content being printed.
  ///The default job name is the current webpage title concatenated with the "Document" word at the end.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  String? jobName;

  ///`true` to animate the display of the sheet, `false` to display the sheet immediately.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool animated;

  ///The orientation of the printed content, portrait or landscape.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  PrintJobOrientation? orientation;

  ///The number of pages to render.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  int? numberOfPages;

  ///Force rendering quality.
  ///
  ///**NOTE for iOS**: available only on iOS 14.5+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  PrintJobRenderingQuality? forceRenderingQuality;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  EdgeInsets? margins;

  ///The media size.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobMediaSize? mediaSize;

  ///The color mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobColorMode? colorMode;

  ///The duplex mode to use for the print job.
  ///
  ///**NOTE for Android native WebView**: available only on Android 23+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  PrintJobDuplexMode? duplexMode;

  ///The kind of printable content.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  PrintJobOutputType? outputType;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobResolution? resolution;

  ///A Boolean value that determines whether the printing options include the number of copies.
  ///The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool showsNumberOfCopies;

  ///A Boolean value that determines whether the paper selection menu displays.
  ///The default value of this property is `false`.
  ///Setting the value to `true` enables a paper selection menu on printers that support different types of paper and have more than one paper type loaded.
  ///On printers where only one paper type is available, no paper selection menu is displayed, regardless of the value of this property.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool showsPaperSelectionForLoadedPapers;

  ///A Boolean value that determines whether the printing options include the paper orientation control when available.
  ///The default value is `true`.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool showsPaperOrientation;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? footerHeight;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? headerHeight;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? maximumContentWidth;

  PrintJobSettings(
      {this.handledByClient = false,
      this.jobName,
      this.animated = true,
      this.orientation,
      this.numberOfPages,
      this.forceRenderingQuality,
      this.margins,
      this.mediaSize,
      this.colorMode,
      this.duplexMode,
      this.outputType,
      this.resolution,
      this.showsNumberOfCopies = true,
      this.showsPaperSelectionForLoadedPapers = false,
      this.showsPaperOrientation = true,
      this.maximumContentHeight,
      this.maximumContentWidth,
      this.footerHeight,
      this.headerHeight});

  ///Gets a [PrintJobSettings] instance from a [Map] value.
  factory PrintJobSettings.fromMap(Map<String, dynamic> map) {
    return PrintJobSettings(
        handledByClient: map["handledByClient"],
        jobName: map["jobName"],
        animated: map["animated"],
        orientation: PrintJobOrientation.fromNativeValue(map["orientation"]),
        numberOfPages: map["numberOfPages"],
        forceRenderingQuality:
            PrintJobRenderingQuality.fromNativeValue(map["forceRenderingQuality"]),
        margins:
            MapEdgeInsets.fromMap(map["margins"]?.cast<String, dynamic>()),
        mediaSize:
            PrintJobMediaSize.fromMap(map["mediaSize"]?.cast<String, dynamic>()),
        colorMode: PrintJobColorMode.fromNativeValue(map["colorMode"]),
        duplexMode: PrintJobDuplexMode.fromNativeValue(map["duplexMode"]),
        outputType: PrintJobOutputType.fromNativeValue(map["outputType"]),
        resolution:
            PrintJobResolution.fromMap(map["resolution"]?.cast<String, dynamic>()),
        showsNumberOfCopies: map["showsNumberOfCopies"],
        showsPaperSelectionForLoadedPapers:
        map["showsPaperSelectionForLoadedPapers"],
        showsPaperOrientation: map["showsPaperOrientation"],
        maximumContentHeight: map["maximumContentHeight"],
        maximumContentWidth: map["maximumContentWidth"],
        footerHeight: map["footerHeight"],
        headerHeight: map["headerHeight"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "handledByClient": handledByClient,
      "jobName": jobName,
      "animated": animated,
      "orientation": orientation?.toNativeValue(),
      "numberOfPages": numberOfPages,
      "forceRenderingQuality": forceRenderingQuality?.toNativeValue(),
      "margins": margins?.toMap(),
      "mediaSize": mediaSize?.toMap(),
      "colorMode": colorMode?.toNativeValue(),
      "duplexMode": duplexMode?.toNativeValue(),
      "outputType": outputType?.toNativeValue(),
      "resolution": resolution?.toMap(),
      "showsNumberOfCopies": showsNumberOfCopies,
      "showsPaperSelectionForLoadedPapers": showsPaperSelectionForLoadedPapers,
      "showsPaperOrientation": showsPaperOrientation,
      "maximumContentHeight": maximumContentHeight,
      "maximumContentWidth": maximumContentWidth,
      "footerHeight": footerHeight,
      "headerHeight": headerHeight,
    };
  }

  PrintJobSettings copy() {
    return PrintJobSettings.fromMap(toMap());
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  String toString() {
    return toMap().toString();
  }
}