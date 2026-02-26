#include "print_job_settings.h"
#include "../utils/flutter.h"
#include "../utils/string.h"
#include "../utils/log.h"

namespace flutter_inappwebview_plugin
{
  std::optional<EdgeInsets> EdgeInsets::fromEncodableMap(const flutter::EncodableMap& map)
  {
    EdgeInsets insets;
    insets.top = get_fl_map_value<double>(map, "top", 0.0);
    insets.right = get_fl_map_value<double>(map, "right", 0.0);
    insets.bottom = get_fl_map_value<double>(map, "bottom", 0.0);
    insets.left = get_fl_map_value<double>(map, "left", 0.0);
    return insets;
  }

  flutter::EncodableMap EdgeInsets::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"top", make_fl_value(top)},
      {"right", make_fl_value(right)},
      {"bottom", make_fl_value(bottom)},
      {"left", make_fl_value(left)}
    };
  }

  PrintJobSettings::PrintJobSettings()
  {}

  PrintJobSettings::PrintJobSettings(const flutter::EncodableMap& map)
  {
    // Common settings
    handledByClient = get_optional_fl_map_value<bool>(map, "handledByClient");
    jobName = get_optional_fl_map_value<std::string>(map, "jobName");

    // Windows-specific (ICoreWebView2PrintSettings)
    showUI = get_optional_fl_map_value<bool>(map, "showUI");

    if (auto dialogKindVal = get_optional_fl_map_value<int64_t>(map, "printDialogKind")) {
      printDialogKind = *dialogKindVal;
    }

    if (auto orientationVal = get_optional_fl_map_value<int64_t>(map, "orientation")) {
      orientation = *orientationVal;
    }

    if (fl_map_contains_not_null(map, "margins")) {
      auto marginsMap = get_fl_map_value<flutter::EncodableMap>(map, "margins");
      margins = EdgeInsets::fromEncodableMap(marginsMap);
    }

    scalingFactor = get_optional_fl_map_value<double>(map, "scalingFactor");
    pageHeight = get_optional_fl_map_value<double>(map, "pageHeight");
    pageWidth = get_optional_fl_map_value<double>(map, "pageWidth");
    shouldPrintBackgrounds = get_optional_fl_map_value<bool>(map, "shouldPrintBackgrounds");
    shouldPrintHeaderAndFooter = get_optional_fl_map_value<bool>(map, "shouldPrintHeaderAndFooter");
    shouldPrintSelectionOnly = get_optional_fl_map_value<bool>(map, "shouldPrintSelectionOnly");
    headerTitle = get_optional_fl_map_value<std::string>(map, "headerTitle");
    footerUri = get_optional_fl_map_value<std::string>(map, "footerUri");
    headerAndFooter = get_optional_fl_map_value<bool>(map, "headerAndFooter");

    // ICoreWebView2PrintSettings2 properties
    collate = get_optional_fl_map_value<bool>(map, "collate");

    if (auto colorModeVal = get_optional_fl_map_value<int64_t>(map, "colorMode")) {
      colorMode = *colorModeVal;
    }

    if (auto copiesVal = get_optional_fl_map_value<int64_t>(map, "copies")) {
      copies = static_cast<int32_t>(*copiesVal);
    }

    if (auto duplexVal = get_optional_fl_map_value<int64_t>(map, "duplexMode")) {
      duplex = *duplexVal;
    }

    pageRanges = get_optional_fl_map_value<std::string>(map, "pageRanges");

    if (auto pagesPerSideVal = get_optional_fl_map_value<int64_t>(map, "pagesPerSide")) {
      pagesPerSide = static_cast<int32_t>(*pagesPerSideVal);
    }

    printerName = get_optional_fl_map_value<std::string>(map, "printerName");
  }

  flutter::EncodableMap PrintJobSettings::toEncodableMap() const
  {
    flutter::EncodableMap map;

    // Common settings
    map.insert({ make_fl_value("handledByClient"), make_fl_value(handledByClient) });
    map.insert({ make_fl_value("jobName"), make_fl_value(jobName) });

    // Windows-specific (ICoreWebView2PrintSettings)
    map.insert({ make_fl_value("showUI"), make_fl_value(showUI) });
    map.insert({ make_fl_value("printDialogKind"), make_fl_value(printDialogKind) });
    map.insert({ make_fl_value("orientation"), make_fl_value(orientation) });
    map.insert({ make_fl_value("margins"),
      margins.has_value() ? make_fl_value(margins->toEncodableMap()) : make_fl_value() });
    map.insert({ make_fl_value("scalingFactor"), make_fl_value(scalingFactor) });
    map.insert({ make_fl_value("pageHeight"), make_fl_value(pageHeight) });
    map.insert({ make_fl_value("pageWidth"), make_fl_value(pageWidth) });
    map.insert({ make_fl_value("shouldPrintBackgrounds"), make_fl_value(shouldPrintBackgrounds) });
    map.insert({ make_fl_value("shouldPrintHeaderAndFooter"), make_fl_value(shouldPrintHeaderAndFooter) });
    map.insert({ make_fl_value("shouldPrintSelectionOnly"), make_fl_value(shouldPrintSelectionOnly) });
    map.insert({ make_fl_value("headerTitle"), make_fl_value(headerTitle) });
    map.insert({ make_fl_value("footerUri"), make_fl_value(footerUri) });
    map.insert({ make_fl_value("headerAndFooter"), make_fl_value(headerAndFooter) });

    // ICoreWebView2PrintSettings2 properties
    map.insert({ make_fl_value("collate"), make_fl_value(collate) });
    map.insert({ make_fl_value("colorMode"), make_fl_value(colorMode) });
    map.insert({ make_fl_value("copies"),
      copies.has_value() ? make_fl_value(static_cast<int64_t>(*copies)) : make_fl_value() });
    map.insert({ make_fl_value("duplexMode"), make_fl_value(duplex) });
    map.insert({ make_fl_value("pageRanges"), make_fl_value(pageRanges) });
    map.insert({ make_fl_value("pagesPerSide"),
      pagesPerSide.has_value() ? make_fl_value(static_cast<int64_t>(*pagesPerSide)) : make_fl_value() });
    map.insert({ make_fl_value("printerName"), make_fl_value(printerName) });

    return map;
  }

  wil::com_ptr<ICoreWebView2PrintSettings> PrintJobSettings::createPrintSettings(
    ICoreWebView2Environment6* environment) const
  {
    if (!environment) {
      return nullptr;
    }

    wil::com_ptr<ICoreWebView2PrintSettings> printSettings;
    if (FAILED(environment->CreatePrintSettings(&printSettings)) || !printSettings) {
      return nullptr;
    }

    // Apply ICoreWebView2PrintSettings properties
    if (orientation.has_value()) {
      printSettings->put_Orientation(static_cast<COREWEBVIEW2_PRINT_ORIENTATION>(orientation.value()));
    }
    if (scalingFactor.has_value()) {
      printSettings->put_ScaleFactor(scalingFactor.value());
    }
    if (pageWidth.has_value()) {
      printSettings->put_PageWidth(pageWidth.value());
    }
    if (pageHeight.has_value()) {
      printSettings->put_PageHeight(pageHeight.value());
    }
    // Handle margins from EdgeInsets
    if (margins.has_value()) {
      printSettings->put_MarginTop(margins.value().top);
      printSettings->put_MarginBottom(margins.value().bottom);
      printSettings->put_MarginLeft(margins.value().left);
      printSettings->put_MarginRight(margins.value().right);
    }
    if (shouldPrintBackgrounds.has_value()) {
      printSettings->put_ShouldPrintBackgrounds(shouldPrintBackgrounds.value() ? TRUE : FALSE);
    }
    if (shouldPrintSelectionOnly.has_value()) {
      printSettings->put_ShouldPrintSelectionOnly(shouldPrintSelectionOnly.value() ? TRUE : FALSE);
    }
    if (shouldPrintHeaderAndFooter.has_value()) {
      printSettings->put_ShouldPrintHeaderAndFooter(shouldPrintHeaderAndFooter.value() ? TRUE : FALSE);
    }
    if (headerTitle.has_value()) {
      printSettings->put_HeaderTitle(utf8_to_wide(headerTitle.value()).c_str());
    }
    if (footerUri.has_value()) {
      printSettings->put_FooterUri(utf8_to_wide(footerUri.value()).c_str());
    }

    // Apply ICoreWebView2PrintSettings2 properties (requires WebView2 1.0.1518.46+)
    wil::com_ptr<ICoreWebView2PrintSettings2> printSettings2;
    if (SUCCEEDED(printSettings->QueryInterface(IID_PPV_ARGS(&printSettings2))) && printSettings2) {
      if (copies.has_value()) {
        printSettings2->put_Copies(copies.value());
      }
      if (collate.has_value()) {
        printSettings2->put_Collation(collate.value() ? COREWEBVIEW2_PRINT_COLLATION_COLLATED : COREWEBVIEW2_PRINT_COLLATION_UNCOLLATED);
      }
      if (colorMode.has_value()) {
        printSettings2->put_ColorMode(static_cast<COREWEBVIEW2_PRINT_COLOR_MODE>(colorMode.value()));
      }
      if (duplex.has_value()) {
        printSettings2->put_Duplex(static_cast<COREWEBVIEW2_PRINT_DUPLEX>(duplex.value()));
      }
      if (pageRanges.has_value()) {
        printSettings2->put_PageRanges(utf8_to_wide(pageRanges.value()).c_str());
      }
      if (pagesPerSide.has_value()) {
        printSettings2->put_PagesPerSide(pagesPerSide.value());
      }
      if (printerName.has_value()) {
        printSettings2->put_PrinterName(utf8_to_wide(printerName.value()).c_str());
      }
    }

    return printSettings;
  }
}
