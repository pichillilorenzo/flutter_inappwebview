#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>
#include <variant>
#include <vector>

namespace flutter_inappwebview_plugin {

/**
 * Context menu settings - matches Dart ContextMenuSettings class.
 */
class ContextMenuSettings {
 public:
  /// Whether all the default system context menu items should be hidden or not.
  bool hideDefaultSystemContextMenuItems = false;

  ContextMenuSettings() = default;

  explicit ContextMenuSettings(FlValue* map) {
    if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
      return;
    }

    FlValue* hideDefault = fl_value_lookup_string(map, "hideDefaultSystemContextMenuItems");
    if (hideDefault != nullptr && fl_value_get_type(hideDefault) == FL_VALUE_TYPE_BOOL) {
      hideDefaultSystemContextMenuItems = fl_value_get_bool(hideDefault);
    }
  }
};

/**
 * Context menu item - matches Dart ContextMenuItem class.
 */
class ContextMenuItem {
 public:
  /// Menu item ID - can be a string or int
  std::variant<std::string, int64_t> id;

  /// Menu item title
  std::string title;

  ContextMenuItem() = default;

  explicit ContextMenuItem(FlValue* map) {
    if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
      return;
    }

    // Parse id - can be string or int
    FlValue* idValue = fl_value_lookup_string(map, "id");
    if (idValue != nullptr) {
      if (fl_value_get_type(idValue) == FL_VALUE_TYPE_STRING) {
        id = std::string(fl_value_get_string(idValue));
      } else if (fl_value_get_type(idValue) == FL_VALUE_TYPE_INT) {
        id = fl_value_get_int(idValue);
      }
    }

    // Parse title
    FlValue* titleValue = fl_value_lookup_string(map, "title");
    if (titleValue != nullptr && fl_value_get_type(titleValue) == FL_VALUE_TYPE_STRING) {
      title = std::string(fl_value_get_string(titleValue));
    }
  }

  /// Get the ID as a string for comparison/storage
  std::string getIdAsString() const {
    if (std::holds_alternative<std::string>(id)) {
      return std::get<std::string>(id);
    } else {
      return std::to_string(std::get<int64_t>(id));
    }
  }
};

/**
 * Context menu configuration - matches Dart ContextMenu class.
 */
class ContextMenu {
 public:
  /// Context menu settings
  ContextMenuSettings settings;

  /// List of custom menu items
  std::vector<ContextMenuItem> menuItems;

  ContextMenu() = default;

  explicit ContextMenu(FlValue* map) {
    if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
      return;
    }

    // Parse settings
    FlValue* settingsValue = fl_value_lookup_string(map, "settings");
    if (settingsValue != nullptr && fl_value_get_type(settingsValue) == FL_VALUE_TYPE_MAP) {
      settings = ContextMenuSettings(settingsValue);
    }

    // Parse menu items
    FlValue* menuItemsValue = fl_value_lookup_string(map, "menuItems");
    if (menuItemsValue != nullptr && fl_value_get_type(menuItemsValue) == FL_VALUE_TYPE_LIST) {
      size_t length = fl_value_get_length(menuItemsValue);
      for (size_t i = 0; i < length; ++i) {
        FlValue* item = fl_value_get_list_value(menuItemsValue, i);
        if (item != nullptr && fl_value_get_type(item) == FL_VALUE_TYPE_MAP) {
          menuItems.emplace_back(item);
        }
      }
    }
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_H_
