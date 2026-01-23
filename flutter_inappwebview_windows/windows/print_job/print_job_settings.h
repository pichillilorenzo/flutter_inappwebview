#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_SETTINGS_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>
#include <WebView2.h>
#include <wil/com.h>

namespace flutter_inappwebview_plugin
{
  // Print orientation enumeration (matches Dart PrintJobOrientation)
  enum class PrintJobOrientation : int64_t {
    portrait = 0,
    landscape = 1,
  };

  // Print dialog kind enumeration (matches Dart PrintJobDialogKind)
  enum class PrintJobDialogKind : int64_t {
    browser = 0,
    system = 1,
  };

  // Print color mode enumeration (matches COREWEBVIEW2_PRINT_COLOR_MODE)
  // COREWEBVIEW2_PRINT_COLOR_MODE_DEFAULT = 0
  // COREWEBVIEW2_PRINT_COLOR_MODE_COLOR = 1
  // COREWEBVIEW2_PRINT_COLOR_MODE_GRAYSCALE = 2
  // Dart PrintJobColorMode: COLOR = 2 (native 0 for Windows), MONOCHROME = 1 (native 1 for Windows)
  enum class PrintColorMode : int64_t {
    color = 0,      // COREWEBVIEW2_PRINT_COLOR_MODE_COLOR (Dart native value)
    grayscale = 1,  // COREWEBVIEW2_PRINT_COLOR_MODE_GRAYSCALE (Dart native value)
  };

  // Print duplex enumeration (matches COREWEBVIEW2_PRINT_DUPLEX and Dart native values)
  // COREWEBVIEW2_PRINT_DUPLEX_DEFAULT = 0
  // COREWEBVIEW2_PRINT_DUPLEX_ONE_SIDED = 1
  // COREWEBVIEW2_PRINT_DUPLEX_TWO_SIDED_LONG_EDGE = 2
  // COREWEBVIEW2_PRINT_DUPLEX_TWO_SIDED_SHORT_EDGE = 3
  // Dart PrintJobDuplexMode native values for Windows: NONE=1, LONG_EDGE=2, SHORT_EDGE=3
  enum class PrintDuplex : int64_t {
    oneSided = 1,
    twoSidedLongEdge = 2,
    twoSidedShortEdge = 3,
  };

  // Print media size enumeration (matches COREWEBVIEW2_PRINT_MEDIA_SIZE)
  enum class PrintMediaSize : int64_t {
    defaultValue = 0,
    custom = 1,
  };

  // Helper to convert media size ID string to enum
  inline PrintMediaSize mediaSizeIdToEnum(const std::string& id) {
    // WebView2 only supports Default and Custom - specific sizes need custom dimensions
    if (id == "custom" || id == "CUSTOM") {
      return PrintMediaSize::custom;
    }
    return PrintMediaSize::defaultValue;
  }

  // Helper to convert media size enum to ID string
  inline std::string mediaSizeEnumToId(PrintMediaSize size) {
    switch (size) {
    case PrintMediaSize::custom:
      return "custom";
    default:
      return "default";
    }
  }

  // Edge insets structure for margins
  struct EdgeInsets {
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;
    double left = 0.0;

    EdgeInsets() = default;
    EdgeInsets(double top, double right, double bottom, double left)
      : top(top), right(right), bottom(bottom), left(left) {}

    static std::optional<EdgeInsets> fromEncodableMap(const flutter::EncodableMap& map);
    flutter::EncodableMap toEncodableMap() const;
  };

  class PrintJobSettings
  {
  public:
    // Common settings
    std::optional<bool> handledByClient;
    std::optional<std::string> jobName;

    // Windows-specific settings (ICoreWebView2PrintSettings)
    std::optional<bool> showUI;
    std::optional<PrintJobDialogKind> printDialogKind;
    std::optional<PrintJobOrientation> orientation;
    std::optional<EdgeInsets> margins;
    std::optional<double> scalingFactor;
    std::optional<double> pageHeight;
    std::optional<double> pageWidth;
    std::optional<bool> shouldPrintBackgrounds;
    std::optional<bool> shouldPrintHeaderAndFooter;
    std::optional<bool> shouldPrintSelectionOnly;
    std::optional<std::string> headerTitle;
    std::optional<std::string> footerUri;
    std::optional<bool> headerAndFooter;

    // ICoreWebView2PrintSettings2 properties
    std::optional<bool> collate;
    std::optional<PrintColorMode> colorMode;
    std::optional<int32_t> copies;
    std::optional<PrintDuplex> duplex;
    std::optional<PrintMediaSize> mediaSize;
    std::optional<std::string> pageRanges;
    std::optional<int32_t> pagesPerSide;
    std::optional<std::string> printerName;

    PrintJobSettings();
    PrintJobSettings(const flutter::EncodableMap& map);
    ~PrintJobSettings() = default;

    flutter::EncodableMap toEncodableMap() const;

    /// Creates ICoreWebView2PrintSettings from this settings object.
    /// Returns nullptr if creation fails.
    wil::com_ptr<ICoreWebView2PrintSettings> createPrintSettings(
      ICoreWebView2Environment6* environment) const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_SETTINGS_H_
