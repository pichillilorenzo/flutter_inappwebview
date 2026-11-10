// Exercise the production reply function without requiring a running WebView.
#include <cassert>
#include <iostream>
#include <string>

#ifdef __APPLE__
// macOS has JavaScriptCore's C API instead of the GLib wrapper. Adapt only the
// wrapper so local tests still use a real JSON parser, not a fake parser.
#include <JavaScriptCore/JavaScriptCore.h>
struct JSCContext { JSGlobalContextRef vm; bool exception = false; };
struct JSCValue { JSCContext* context; JSValueRef value; };
int live_contexts = 0;
int live_values = 0;
JSCContext* jsc_context_new() {
  ++live_contexts;
  return new JSCContext{JSGlobalContextCreate(nullptr)};
}
JSCValue* jsc_value_new_from_json(JSCContext* context, const char* text) {
  auto string = JSStringCreateWithUTF8CString(text);
  auto value = JSValueMakeFromJSONString(context->vm, string);
  JSStringRelease(string);
  if (value == nullptr) {
    context->exception = true;
    return nullptr;
  }
  ++live_values;
  return new JSCValue{context, value};
}
void* jsc_context_get_exception(JSCContext* context) {
  return context->exception ? context : nullptr;
}
void g_object_unref(JSCValue* value) { --live_values; delete value; }
void g_object_unref(JSCContext* context) {
  --live_contexts;
  JSGlobalContextRelease(context->vm);
  delete context;
}
std::string json_string(JSCValue* value) {
  auto string = JSValueCreateJSONString(value->context->vm, value->value, 0, nullptr);
  assert(string != nullptr);
  std::string json(JSStringGetMaximumUTF8CStringSize(string), '\0');
  json.resize(JSStringGetUTF8CString(string, json.data(), json.size()) - 1);
  JSStringRelease(string);
  return json;
}
#else
#include <jsc/jsc.h>
std::string json_string(JSCValue* value) {
  auto text = jsc_value_to_json(value, 0);
  assert(text != nullptr);
  std::string json(text);
  g_free(text);
  return json;
}
#endif

struct WebKitScriptMessageReply {
  int references = 1;
  int settlements = 0;
  bool rejected = false;
  std::string json;
};
void webkit_script_message_reply_unref(WebKitScriptMessageReply* reply) {
  --reply->references;
}
void webkit_script_message_reply_return_error_message(WebKitScriptMessageReply* reply, const char*) {
  ++reply->settlements;
  reply->rejected = true;
}
void webkit_script_message_reply_return_value(WebKitScriptMessageReply* reply, JSCValue* value) {
  ++reply->settlements;
  reply->json = json_string(value);
}
void debugLog(const char*) {}
class InAppWebView {
 public:
  void ResolveInternalHandlerWithReply(WebKitScriptMessageReply*, const std::string&);
};
#include "javascript_handler_reply_under_test.inc"

int main(int argc, char** argv) {
  assert(argc == 2);
  WebKitScriptMessageReply reply;
  InAppWebView webview;
  webview.ResolveInternalHandlerWithReply(&reply, argv[1]);
  assert(reply.references == 0);
  assert(reply.settlements == 1);
#ifdef __APPLE__
  assert(live_contexts == 0 && live_values == 0);
#endif
  std::cout << (reply.rejected ? "error" : reply.json);
}
