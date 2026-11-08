#include <algorithm>
#include <cassert>
#include <cstdint>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <vector>

using gpointer = void*;
using gulong = unsigned long;
using gboolean = bool;
using gchar = char;
using GCallback = void (*)();
#define G_CALLBACK(x) reinterpret_cast<GCallback>(x)
#define GTK_WIDGET(x) reinterpret_cast<GtkWidget*>(x)
#define GTK_WINDOW(x) reinterpret_cast<GtkWindow*>(x)
#define FL_VIEW(x) reinterpret_cast<FlView*>(x)
#define GTK_DIALOG(x) reinterpret_cast<GtkDialog*>(x)
#define TRUE true
#define FALSE false
#define GTK_RESPONSE_CANCEL -6

struct GtkWidget {
  bool destroyed = false;
  int scale = 1;
  struct Signal { gulong id; std::string name; GCallback callback; gpointer data; };
  std::vector<Signal> signals;
};
using GtkWindow = GtkWidget;
using GtkDialog = GtkWidget;
struct FlView : GtkWidget {};
using GObject = GtkWidget;
struct GParamSpec {};
struct GdkEventConfigure {};
struct WebKitWebView {};
struct FlPluginRegistrar {};
struct FlBinaryMessenger {};
struct FlTextureRegistrar {};

static int destroyed_accesses = 0;
static int disconnects = 0;
static gulong next_signal_id = 1;
static GtkWindow* registrar_window = nullptr;
static FlView* registrar_view = nullptr;
FlView* flutter_inappwebview_linux_plugin_get_view(FlPluginRegistrar*) { return registrar_view; }
GtkWindow* flutter_inappwebview_linux_plugin_get_window(FlPluginRegistrar*) { return registrar_window; }

gulong g_signal_connect(GtkWidget* object, const char* name, GCallback callback, gpointer data) {
  if (object->destroyed) ++destroyed_accesses;
  const auto id = next_signal_id++;
  object->signals.push_back({id, name, callback, data});
  return id;
}
void g_signal_handler_disconnect(GtkWidget* object, gulong id) {
  if (object->destroyed) ++destroyed_accesses;
  ++disconnects;
  object->signals.erase(std::remove_if(object->signals.begin(), object->signals.end(),
      [id](const auto& signal) { return signal.id == id; }), object->signals.end());
}
void emit_destroy(GtkWidget* object) {
  auto signals = object->signals;
  for (const auto& signal : signals) {
    const auto still_connected = std::any_of(object->signals.begin(), object->signals.end(),
      [&](const auto& active) { return active.id == signal.id; });
    if (still_connected && signal.name == "destroy" && signal.callback) {
      reinterpret_cast<void (*)(GtkWidget*, gpointer)>(signal.callback)(object, signal.data);
    }
  }
  object->destroyed = true;
}
int gtk_widget_get_scale_factor(GtkWidget* widget) {
  if (widget->destroyed) ++destroyed_accesses;
  return widget->scale;
}
void wpe_toplevel_scale_changed(void*, double) {}

namespace flutter_inappwebview_plugin {
class PluginInstance {
 public:
  explicit PluginInstance(FlPluginRegistrar* registrar);
  ~PluginInstance();
  GtkWindow* gtkWindow() const { return gtk_window_; }
  FlView* flView() const { return fl_view_; }
  void InvalidateHost(GtkWindow*, FlView*);
 private:
  FlPluginRegistrar* registrar_ = nullptr;
  GtkWindow* gtk_window_ = nullptr;
  FlView* fl_view_ = nullptr;
  gulong host_window_destroy_handler_ = 0;
  gulong host_view_destroy_handler_ = 0;
};
}
using flutter_inappwebview_plugin::PluginInstance;

struct InAppWebView;
struct WebKitFileChooserRequest { int refs = 1; int cancels = 0; int selections = 0; };
struct FileChooserContext {
  WebKitFileChooserRequest* request;
  bool selectMultiple = false;
  InAppWebView* webview = nullptr;
  gulong response_handler_id = 0;
  explicit FileChooserContext(WebKitFileChooserRequest* req) : request(req) { ++request->refs; }
  ~FileChooserContext() { --request->refs; }
};
struct ShowFileChooserResponse { bool handledByClient = false; std::optional<std::vector<std::string>> filePaths; };
struct Delegate {
  std::function<void(ShowFileChooserResponse)> reply;
  void onShowFileChooser(int, const std::vector<std::string>&, bool, std::nullopt_t,
      std::nullopt_t, std::function<void(ShowFileChooserResponse)> callback) { reply = std::move(callback); }
};
bool webkit_file_chooser_request_get_select_multiple(WebKitFileChooserRequest*) { return false; }
const gchar* const* webkit_file_chooser_request_get_mime_types(WebKitFileChooserRequest*) { return nullptr; }
void g_object_ref(WebKitFileChooserRequest* request) { ++request->refs; }
void g_object_unref(WebKitFileChooserRequest* request) { --request->refs; }
void webkit_file_chooser_request_cancel(WebKitFileChooserRequest* request) { ++request->cancels; }
void webkit_file_chooser_request_select_files(WebKitFileChooserRequest* request, const char* const*) { ++request->selections; }
static int64_t fake_now = 300000;
int64_t g_get_monotonic_time() { return fake_now; }
void gtk_widget_destroy(GtkWidget* widget) { widget->destroyed = true; }
void g_object_unref(GtkWidget*) {}

static GtkWindow* observed_file_parent = nullptr;
static int native_file_chooser_count = 0;
static void ShowNativeFileChooser(InAppWebView*, WebKitFileChooserRequest*, bool,
    const std::vector<std::string>&, GtkWindow* parent);
static InAppWebView* dialog_owner = nullptr;
static int dialog_cancel_count = 0;
struct InAppWebView {
  std::unique_ptr<Delegate> channel_delegate_;
  static gboolean OnRunFileChooser(WebKitWebView*, WebKitFileChooserRequest*, gpointer);
  PluginInstance* plugin_ = nullptr;
  GtkWindow* gtk_window_ = nullptr;
  FlView* fl_view_ = nullptr;
  std::unique_ptr<int> option_menu_popup_, context_menu_popup_;
  gulong scale_changed_handler_ = 0;
  gulong configure_event_handler_id_ = 0;
  gulong host_destroy_handler_id_ = 0;
  gulong host_view_destroy_handler_id_ = 0;
  double scale_factor_ = 1;
  void* wpe_toplevel_ = nullptr;
  std::function<void()> on_frame_available_;
  GtkWidget* active_color_dialog_ = nullptr;
  GtkWidget* active_date_dialog_ = nullptr;
  GtkWidget* active_file_dialog_ = nullptr;
  std::shared_ptr<int> lifetime_token_ = std::make_shared<int>(0);
  int64_t file_dialog_show_time_ = 0;
  void* file_chooser_context_ = nullptr;
  void HideColorPicker() {}
  void HideAllPopups() { HideColorPicker(); }
  void HideFileChooser(bool force = false);
  void CancelHostBoundPopups();
  unsigned monitor_updates = 0;
  void UpdateMonitorRefreshRate() { ++monitor_updates; }
  void SetHostView(GtkWindow*, FlView*);
  void ConnectHostWindowDestroyHandler();
  void DisconnectHostWindowDestroyHandler();
  void ConnectHostViewDestroyHandler();
  void DisconnectHostViewDestroyHandler();
  void OnHostWindowDestroyed();
};
void gtk_dialog_response(GtkDialog* dialog, int response) {
  assert(response == GTK_RESPONSE_CANCEL);
  ++dialog_cancel_count;
  if (dialog_owner && dialog_owner->active_color_dialog_ == dialog) {
    dialog_owner->active_color_dialog_ = nullptr;
    gtk_widget_destroy(dialog);
  }
  if (dialog_owner && dialog_owner->active_date_dialog_ == dialog) {
    dialog_owner->active_date_dialog_ = nullptr;
    gtk_widget_destroy(dialog);
  }
}
void ShowNativeFileChooser(InAppWebView*, WebKitFileChooserRequest*, bool,
    const std::vector<std::string>&, GtkWindow* parent) {
  ++native_file_chooser_count;
  observed_file_parent = parent;
}

#include "plugin_instance_under_test.inc"
#include "host_under_test.inc"
#include "chooser_under_test.inc"

void CheckSharedHostSignalsAndIndependentReplies() {
  GtkWindow shared_window, replacement_window;
  FlView shared_view, replacement_view;
  auto first = std::make_unique<InAppWebView>();
  auto second = std::make_unique<InAppWebView>();
  first->SetHostView(&shared_window, &shared_view);
  second->SetHostView(&shared_window, &shared_view);
  first->channel_delegate_ = std::make_unique<Delegate>();
  second->channel_delegate_ = std::make_unique<Delegate>();
  const auto peer_destroy_handler = second->host_destroy_handler_id_;
  const auto peer_view_handler = second->host_view_destroy_handler_id_;
  const auto peer_configure_handler = second->configure_event_handler_id_;
  assert(peer_destroy_handler && peer_view_handler && peer_configure_handler);

  WebKitFileChooserRequest first_request, peer_request;
  InAppWebView::OnRunFileChooser(nullptr, &first_request, first.get());
  InAppWebView::OnRunFileChooser(nullptr, &peer_request, second.get());
  auto late_reply = first->channel_delegate_->reply;
  assert(first_request.refs == 2 && peer_request.refs == 2);

  // Detaching one borrower must disconnect only its own host handlers. The
  // production methods below are also used by native host teardown/rehosting.
  first->SetHostView(nullptr, nullptr);
  first->DisconnectHostWindowDestroyHandler();
  first->DisconnectHostViewDestroyHandler();  // Repeated detach is harmless.
  first.reset();
  assert(second->gtk_window_ == &shared_window && second->fl_view_ == &shared_view);
  assert(second->host_destroy_handler_id_ == peer_destroy_handler);
  assert(second->host_view_destroy_handler_id_ == peer_view_handler);
  assert(second->configure_event_handler_id_ == peer_configure_handler);
  for (const auto& signal : shared_window.signals) assert(signal.data == second.get());
  assert(shared_view.signals.size() == 1 && shared_view.signals.front().data == second.get());

  const auto updates = second->monitor_updates;
  for (const auto& signal : shared_window.signals) {
    if (signal.name == "configure-event") {
      reinterpret_cast<gboolean (*)(GtkWidget*, GdkEventConfigure*, gpointer)>(signal.callback)(
          &shared_window, nullptr, signal.data);
    }
  }
  assert(second->monitor_updates == updates + 1);
  late_reply({true, std::vector<std::string>{"/closed-owner.txt"}});
  assert(first_request.cancels == 1 && first_request.selections == 0 && first_request.refs == 1);
  second->channel_delegate_->reply({true, std::vector<std::string>{"/surviving-owner.txt"}});
  assert(peer_request.cancels == 0 && peer_request.selections == 1 && peer_request.refs == 1);

  // The remaining borrower's signal must still run on real host invalidation,
  // and that view can subsequently attach and service work on another host.
  emit_destroy(&shared_window);
  assert(second->gtk_window_ == nullptr && second->fl_view_ == nullptr);
  assert(shared_window.signals.empty() && shared_view.signals.empty());
  second->SetHostView(&replacement_window, &replacement_view);
  WebKitFileChooserRequest replacement_request;
  InAppWebView::OnRunFileChooser(nullptr, &replacement_request, second.get());
  const auto dialogs = native_file_chooser_count;
  second->channel_delegate_->reply({false, std::nullopt});
  assert(native_file_chooser_count == dialogs + 1 && observed_file_parent == &replacement_window);
  assert(replacement_request.cancels == 0 && replacement_request.refs == 1);
  second->SetHostView(nullptr, nullptr);
  assert(replacement_window.signals.empty() && replacement_view.signals.empty());
  assert(destroyed_accesses == 0);
}

int main() {
  FlPluginRegistrar registrar;
  GtkWindow main_window, secondary_window, third_window, fallback_control_window, dialog_window, reply_window;
  FlView main_view, secondary_view, third_view, fallback_control_view, dialog_view, reply_view;
  registrar_window = &main_window;
  registrar_view = &main_view;
  {
    PluginInstance plugin(&registrar);
    assert(plugin.gtkWindow() == &main_window && plugin.flView() == &main_view);
    InAppWebView view;
    view.plugin_ = &plugin;
    view.gtk_window_ = &main_window;
    view.fl_view_ = &main_view;
    view.ConnectHostWindowDestroyHandler();
    view.ConnectHostViewDestroyHandler();
    view.SetHostView(&secondary_window, &secondary_view);
    assert(view.gtk_window_ == &secondary_window && view.fl_view_ == &secondary_view);

    // Control: a secondary host falls back to the still-live registered host.
    emit_destroy(&secondary_window);
    assert(view.gtk_window_ == &main_window && view.fl_view_ == &main_view);
    // Move once more to an independent secondary for the main-dies scenario.
    view.SetHostView(&fallback_control_window, &fallback_control_view);
    emit_destroy(&main_window);
    assert(plugin.gtkWindow() == nullptr);
    emit_destroy(&fallback_control_window);
    assert(view.gtk_window_ == nullptr && view.fl_view_ == nullptr);
    assert(destroyed_accesses == 0);

    // An independently destroyed FlView clears the per-view borrowed pointer.
    view.SetHostView(&third_window, &third_view);
    emit_destroy(&third_view);
    assert(view.fl_view_ == nullptr);

    // Host transitions synchronously cancel each active dialog exactly once.
    GtkWidget color_dialog, date_dialog, file_dialog;
    WebKitFileChooserRequest popup_request;
    auto* popup_context = new FileChooserContext(&popup_request);
    popup_context->response_handler_id = g_signal_connect(&file_dialog, "response", nullptr, nullptr);
    view.file_chooser_context_ = popup_context;
    view.file_dialog_show_time_ = fake_now - 1;
    view.active_color_dialog_ = &color_dialog;
    view.active_date_dialog_ = &date_dialog;
    view.active_file_dialog_ = &file_dialog;
    dialog_owner = &view;
    const int cancels_before = dialog_cancel_count;
    view.HideFileChooser();  // The normal focus-close guard preserves a new dialog.
    assert(view.file_chooser_context_ == popup_context && popup_request.cancels == 0);
    view.SetHostView(&dialog_window, &dialog_view);
    assert(view.active_color_dialog_ == nullptr);
    assert(view.active_date_dialog_ == nullptr);
    assert(view.active_file_dialog_ == nullptr);
    assert(dialog_cancel_count == cancels_before + 2);
    assert(file_dialog.destroyed && view.file_chooser_context_ == nullptr);
    assert(popup_request.cancels == 1 && popup_request.refs == 1);

    // Deferred default handling uses the current parent after rehost.
    view.channel_delegate_ = std::make_unique<Delegate>();
    WebKitFileChooserRequest rehosted;
    InAppWebView::OnRunFileChooser(nullptr, &rehosted, &view);
    view.SetHostView(&reply_window, &reply_view);
    view.channel_delegate_->reply({false, std::nullopt});
    assert(observed_file_parent == &reply_window && native_file_chooser_count == 1);
    assert(rehosted.refs == 1 && rehosted.cancels == 0);

    // If the host is gone by reply time, cancel instead of opening unparented.
    WebKitFileChooserRequest no_host;
    InAppWebView::OnRunFileChooser(nullptr, &no_host, &view);
    emit_destroy(&reply_window);
    assert(view.gtk_window_ == nullptr);
    view.channel_delegate_->reply({false, std::nullopt});
    assert(no_host.refs == 1 && no_host.cancels == 1);

    // The synchronous fallback is also safe while detached.
    view.channel_delegate_.reset();
    WebKitFileChooserRequest direct_no_host;
    InAppWebView::OnRunFileChooser(nullptr, &direct_no_host, &view);
    assert(direct_no_host.refs == 1 && direct_no_host.cancels == 1);
    view.channel_delegate_ = std::make_unique<Delegate>();

    // A reply after disposal cancels and releases the request without touching
    // the captured InAppWebView pointer.
    WebKitFileChooserRequest disposed;
    InAppWebView::OnRunFileChooser(nullptr, &disposed, &view);
    view.lifetime_token_.reset();
    view.channel_delegate_->reply({false, std::nullopt});
    assert(disposed.refs == 1 && disposed.cancels == 1);
    assert(native_file_chooser_count == 1);
  }
  assert(main_window.signals.empty());
  assert(main_view.signals.empty());
  assert(destroyed_accesses == 0);
  CheckSharedHostSignalsAndIndependentReplies();
  std::cout << "Compiled Linux native host lifetime, chooser and two-view isolation tests passed\n";
}
