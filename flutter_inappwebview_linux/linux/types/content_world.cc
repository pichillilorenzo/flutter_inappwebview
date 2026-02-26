#include "content_world.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// Static member initialization
std::shared_ptr<ContentWorld> ContentWorld::pageWorld_;
std::shared_ptr<ContentWorld> ContentWorld::defaultClientWorld_;

ContentWorld::ContentWorld(const std::string& name) : name(name) {}

ContentWorld::ContentWorld(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    name = "page";
    return;
  }

  name = get_fl_map_value<std::string>(map, "name", "page");
}

FlValue* ContentWorld::toFlValue() const {
  return to_fl_map({
      {"name", make_fl_value(name)},
  });
}

bool ContentWorld::operator==(const ContentWorld& other) const {
  return name == other.name;
}

std::shared_ptr<ContentWorld> ContentWorld::page() {
  if (!pageWorld_) {
    pageWorld_ = std::make_shared<ContentWorld>("page");
  }
  return pageWorld_;
}

std::shared_ptr<ContentWorld> ContentWorld::defaultClient() {
  if (!defaultClientWorld_) {
    defaultClientWorld_ = std::make_shared<ContentWorld>("defaultClient");
  }
  return defaultClientWorld_;
}

std::shared_ptr<ContentWorld> ContentWorld::world(const std::string& name) {
  return std::make_shared<ContentWorld>(name);
}

}  // namespace flutter_inappwebview_plugin
