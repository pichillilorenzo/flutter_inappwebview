#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_SETTINGS_H_

#include <cstdint>
#include <optional>
#include <string>
#include <flutter/standard_method_codec.h>
#include <WebView2.h>
#include <wil/com.h>

namespace flutter_inappwebview_plugin
{
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
    // Values are expected to match COREWEBVIEW2_PRINT_DIALOG_KIND
    std::optional<int64_t> printDialogKind;
    // Values are expected to match COREWEBVIEW2_PRINT_ORIENTATION
    std::optional<int64_t> orientation;
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
    // Values are expected to match COREWEBVIEW2_PRINT_COLOR_MODE
    std::optional<int64_t> colorMode;
    std::optional<int32_t> copies;
    // Values are expected to match COREWEBVIEW2_PRINT_DUPLEX
    std::optional<int64_t> duplex;
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
