import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../util.dart';
import '../print_job/main.dart';
import 'in_app_webview_rect.dart';
import 'print_job_color_mode.dart';
import 'print_job_duplex_mode.dart';
import 'print_job_orientation.dart';
import 'print_job_media_size.dart';
import 'print_job_resolution.dart';

part 'print_job_attributes.g.dart';

///Class representing the attributes of a [PrintJobController].
///These attributes describe how the printed content should be laid out.
@ExchangeableObject()
class PrintJobAttributes_ {
  ///The color mode.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  PrintJobColorMode_? colorMode;

  ///The duplex mode to use for the print job.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(available: "23"), IOSPlatform()]
  )
  PrintJobDuplexMode_? duplex;

  ///The orientation of the printed content, portrait or landscape.
  PrintJobOrientation_? orientation;

  ///The media size.
  @SupportedPlatforms(
      platforms: [AndroidPlatform()]
  )
  PrintJobMediaSize_? mediaSize;

  ///The supported resolution in DPI (dots per inch).
  @SupportedPlatforms(
      platforms: [AndroidPlatform()]
  )
  PrintJobResolution_? resolution;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  EdgeInsets? margins;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? footerHeight;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? headerHeight;

  ///The area in which printing can occur.
  ///
  ///The value of this property is a rectangle that defines the area in which the printer can print content.
  ///Sometimes this is referred to as the imageable area of the paper.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  InAppWebViewRect_? printableRect;

  ///The size of the paper used for printing.
  ///
  ///The value of this property is a rectangle that defines the size of paper chosen for the print job.
  ///The origin is always (0,0).
  @SupportedPlatforms(platforms: [IOSPlatform()])
  InAppWebViewRect_? paperRect;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? maximumContentWidth;

  PrintJobAttributes_(
      {this.colorMode,
      this.duplex,
      this.orientation,
      this.mediaSize,
      this.resolution,
      this.margins,
      this.maximumContentHeight,
      this.maximumContentWidth,
      this.footerHeight,
      this.headerHeight,
      this.paperRect,
      this.printableRect});
}
