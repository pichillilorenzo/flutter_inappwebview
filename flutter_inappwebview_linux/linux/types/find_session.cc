#include "find_session.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

FindSession::FindSession(int resultCount, int highlightedResultIndex)
    : resultCount(resultCount), highlightedResultIndex(highlightedResultIndex) {}

FindSession::FindSession(FlValue* value)
    : resultCount(get_fl_map_value<int32_t>(value, "resultCount", 0)),
      highlightedResultIndex(get_fl_map_value<int32_t>(value, "highlightedResultIndex", 0)) {}

FlValue* FindSession::toFlValue() const {
  return to_fl_map({
      {"resultCount", make_fl_value(resultCount)},
      {"highlightedResultIndex", make_fl_value(highlightedResultIndex)},
  });
}

}  // namespace flutter_inappwebview_plugin
