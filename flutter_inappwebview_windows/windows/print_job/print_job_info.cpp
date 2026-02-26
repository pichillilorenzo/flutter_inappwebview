#include "print_job_info.h"
#include "print_job_controller.h"
#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
  PrintJobInfo::PrintJobInfo()
    : state(PrintJobState::created), creationTime(0)
  {}

  PrintJobInfo::PrintJobInfo(const PrintJobController* controller)
    : state(controller->getState()),
      creationTime(controller->getCreationTime()),
      label(controller->getLabel()),
      numberOfPages(std::nullopt),
      copies(std::nullopt)
  {
    // Get copies from settings if available
    if (controller->getSettings()) {
      copies = controller->getSettings()->copies;
    }
  }

  flutter::EncodableMap PrintJobInfo::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"state", make_fl_value(static_cast<int64_t>(state))},
      {"creationTime", make_fl_value(creationTime)},
      {"label", make_fl_value(label)},
      {"numberOfPages", make_fl_value(numberOfPages.has_value() ? std::optional<int64_t>(*numberOfPages) : std::nullopt)},
      {"copies", make_fl_value(copies.has_value() ? std::optional<int64_t>(*copies) : std::nullopt)}
    };
  }
}
