#include "cookie_manager.h"

#include <atomic>
#include <cstring>
#include <ctime>

#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}

// Parse SameSite attribute from string
SoupSameSitePolicy parseSameSite(const std::string& sameSite) {
  if (sameSite == "Strict") {
    return SOUP_SAME_SITE_POLICY_STRICT;
  } else if (sameSite == "Lax") {
    return SOUP_SAME_SITE_POLICY_LAX;
  }
  return SOUP_SAME_SITE_POLICY_NONE;
}

// Convert SameSite policy to string
std::string sameSiteToString(SoupSameSitePolicy policy) {
  switch (policy) {
    case SOUP_SAME_SITE_POLICY_STRICT:
      return "Strict";
    case SOUP_SAME_SITE_POLICY_LAX:
      return "Lax";
    case SOUP_SAME_SITE_POLICY_NONE:
    default:
      return "None";
  }
}
}  // namespace

// === Cookie ===

Cookie::Cookie() : isSecure(false), isHttpOnly(false) {}

Cookie::Cookie(const std::string& name, const std::string& value)
    : name(name), value(value), isSecure(false), isHttpOnly(false) {}

Cookie::Cookie(SoupCookie* soupCookie) : isSecure(false), isHttpOnly(false) {
  if (soupCookie == nullptr) {
    return;
  }

  const char* n = soup_cookie_get_name(soupCookie);
  const char* v = soup_cookie_get_value(soupCookie);
  const char* d = soup_cookie_get_domain(soupCookie);
  const char* p = soup_cookie_get_path(soupCookie);

  if (n != nullptr)
    name = std::string(n);
  if (v != nullptr)
    value = std::string(v);
  if (d != nullptr)
    domain = std::string(d);
  if (p != nullptr)
    path = std::string(p);

  GDateTime* expires = soup_cookie_get_expires(soupCookie);
  if (expires != nullptr) {
    gint64 unix_time = g_date_time_to_unix(expires);
    expiresDate = unix_time * 1000;  // Convert to milliseconds
  }

  isSecure = soup_cookie_get_secure(soupCookie);
  isHttpOnly = soup_cookie_get_http_only(soupCookie);
  sameSite = sameSiteToString(soup_cookie_get_same_site_policy(soupCookie));
}

Cookie::Cookie(FlValue* map) : isSecure(false), isHttpOnly(false) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  name = get_fl_map_value<std::string>(map, "name", "");
  value = get_fl_map_value<std::string>(map, "value", "");
  domain = get_optional_fl_map_value<std::string>(map, "domain");
  path = get_optional_fl_map_value<std::string>(map, "path");

  FlValue* expiresValue = fl_value_lookup_string(map, "expiresDate");
  if (expiresValue != nullptr && fl_value_get_type(expiresValue) == FL_VALUE_TYPE_INT) {
    expiresDate = fl_value_get_int(expiresValue);
  }

  isSecure = get_fl_map_value(map, "isSecure", false);
  isHttpOnly = get_fl_map_value(map, "isHttpOnly", false);
  sameSite = get_optional_fl_map_value<std::string>(map, "sameSite");
}

SoupCookie* Cookie::toSoupCookie(const std::string& url) const {
  // Parse URL to get domain if not provided
  GUri* guri = g_uri_parse(url.c_str(), G_URI_FLAGS_NONE, nullptr);
  const char* host = nullptr;
  if (guri != nullptr) {
    host = g_uri_get_host(guri);
  }

  std::string cookieDomain = domain.value_or(host ? std::string(host) : "");
  std::string cookiePath = path.value_or("/");

  SoupCookie* cookie =
      soup_cookie_new(name.c_str(), value.c_str(), cookieDomain.c_str(), cookiePath.c_str(),
                      -1  // maxAge (-1 = session cookie)
      );

  if (cookie != nullptr) {
    if (expiresDate.has_value()) {
      gint64 unix_time = expiresDate.value() / 1000;  // Convert from milliseconds
      GDateTime* expires = g_date_time_new_from_unix_utc(unix_time);
      if (expires != nullptr) {
        soup_cookie_set_expires(cookie, expires);
        g_date_time_unref(expires);
      }
    }

    soup_cookie_set_secure(cookie, isSecure);
    soup_cookie_set_http_only(cookie, isHttpOnly);

    if (sameSite.has_value()) {
      soup_cookie_set_same_site_policy(cookie, parseSameSite(sameSite.value()));
    }
  }

  if (guri != nullptr) {
    g_uri_unref(guri);
  }

  return cookie;
}

FlValue* Cookie::toFlValue() const {
  return to_fl_map({
      {"name", make_fl_value(name)},
      {"value", make_fl_value(value)},
      {"domain", make_fl_value(domain)},
      {"path", make_fl_value(path)},
      {"expiresDate", make_fl_value(expiresDate)},
      {"isSecure", make_fl_value(isSecure)},
      {"isHttpOnly", make_fl_value(isHttpOnly)},
      {"sameSite", make_fl_value(sameSite)},
  });
}

// === CookieManager ===

CookieManager::CookieManager(PluginInstance* plugin)
    : ChannelDelegate(plugin->messenger(), METHOD_CHANNEL_NAME),
      plugin_(plugin),
      cookie_manager_(nullptr) {}

CookieManager::~CookieManager() {
  debugLog("dealloc CookieManager");
  plugin_ = nullptr;
}

WebKitCookieManager* CookieManager::getCookieManager() {
  if (cookie_manager_ == nullptr) {
    // WPE WebKit 2.x uses NetworkSession API instead of WebContext
    WebKitNetworkSession* session = webkit_network_session_get_default();
    if (session != nullptr) {
      cookie_manager_ = webkit_network_session_get_cookie_manager(session);
    }
  }
  return cookie_manager_;
}

void CookieManager::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(method, "setCookie")) {
    std::string url = get_fl_map_value<std::string>(args, "url", "");
    FlValue* cookieMap = fl_value_lookup_string(args, "cookie");

    if (url.empty() || cookieMap == nullptr) {
      fl_method_call_respond_success(method_call, fl_value_new_bool(FALSE), nullptr);
      return;
    }

    Cookie cookie(cookieMap);

    g_object_ref(method_call);
    setCookie(url, cookie, [method_call](bool success) {
      fl_method_call_respond_success(method_call, fl_value_new_bool(success), nullptr);
      g_object_unref(method_call);
    });
  } else if (string_equals(method, "getCookies")) {
    std::string url = get_fl_map_value<std::string>(args, "url", "");

    if (url.empty()) {
      fl_method_call_respond_success(method_call, fl_value_new_list(), nullptr);
      return;
    }

    g_object_ref(method_call);
    getCookies(url, [method_call](std::vector<Cookie> cookies) {
      g_autoptr(FlValue) result = fl_value_new_list();
      for (const auto& cookie : cookies) {
        fl_value_append_take(result, cookie.toFlValue());
      }
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
  } else if (string_equals(method, "getCookie")) {
    std::string url = get_fl_map_value<std::string>(args, "url", "");
    std::string name = get_fl_map_value<std::string>(args, "name", "");

    if (url.empty() || name.empty()) {
      fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
      return;
    }

    g_object_ref(method_call);
    getCookie(url, name, [method_call](std::optional<Cookie> cookie) {
      if (cookie.has_value()) {
        fl_method_call_respond_success(method_call, cookie.value().toFlValue(), nullptr);
      } else {
        fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
      }
      g_object_unref(method_call);
    });
  } else if (string_equals(method, "deleteCookie")) {
    std::string url = get_fl_map_value<std::string>(args, "url", "");
    std::string name = get_fl_map_value<std::string>(args, "name", "");
    std::string domain = get_fl_map_value<std::string>(args, "domain", "");
    std::string path = get_fl_map_value<std::string>(args, "path", "/");

    g_object_ref(method_call);
    deleteCookie(url, name, domain, path, [method_call](bool success) {
      fl_method_call_respond_success(method_call, fl_value_new_bool(success), nullptr);
      g_object_unref(method_call);
    });
  } else if (string_equals(method, "deleteCookies")) {
    std::string url = get_fl_map_value<std::string>(args, "url", "");
    std::string domain = get_fl_map_value<std::string>(args, "domain", "");
    std::string path = get_fl_map_value<std::string>(args, "path", "/");

    g_object_ref(method_call);
    deleteCookies(url, domain, path, [method_call](bool success) {
      fl_method_call_respond_success(method_call, fl_value_new_bool(success), nullptr);
      g_object_unref(method_call);
    });
  } else if (string_equals(method, "deleteAllCookies")) {
    g_object_ref(method_call);
    deleteAllCookies([method_call](bool success) {
      fl_method_call_respond_success(method_call, fl_value_new_bool(success), nullptr);
      g_object_unref(method_call);
    });
  } else if (string_equals(method, "getAllCookies")) {
    g_object_ref(method_call);
    getAllCookies([method_call](std::vector<Cookie> cookies) {
      g_autoptr(FlValue) result = fl_value_new_list();
      for (const auto& cookie : cookies) {
        fl_value_append_take(result, cookie.toFlValue());
      }
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void CookieManager::setCookie(const std::string& url, const Cookie& cookie,
                              std::function<void(bool)> callback) {
  WebKitCookieManager* manager = getCookieManager();
  if (manager == nullptr) {
    callback(false);
    return;
  }

  SoupCookie* soupCookie = cookie.toSoupCookie(url);
  if (soupCookie == nullptr) {
    callback(false);
    return;
  }

  // Store callback in a closure
  auto* callbackPtr = new std::function<void(bool)>(std::move(callback));

  webkit_cookie_manager_add_cookie(
      manager, soupCookie,
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<std::function<void(bool)>*>(user_data);

        GError* error = nullptr;
        gboolean success =
            webkit_cookie_manager_add_cookie_finish(WEBKIT_COOKIE_MANAGER(source), result, &error);

        if (error != nullptr) {
          errorLog(std::string("CookieManager: setCookie failed: ") + error->message);
          g_error_free(error);
        }

        (*cb)(success);
        delete cb;
      },
      callbackPtr);

  soup_cookie_free(soupCookie);
}

void CookieManager::getCookies(const std::string& url,
                               std::function<void(std::vector<Cookie>)> callback) {
  WebKitCookieManager* manager = getCookieManager();
  if (manager == nullptr) {
    callback({});
    return;
  }

  auto* callbackPtr = new std::function<void(std::vector<Cookie>)>(std::move(callback));

  webkit_cookie_manager_get_cookies(
      manager, url.c_str(),
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<std::function<void(std::vector<Cookie>)>*>(user_data);

        GError* error = nullptr;
        GList* cookies =
            webkit_cookie_manager_get_cookies_finish(WEBKIT_COOKIE_MANAGER(source), result, &error);

        std::vector<Cookie> cookieList;

        if (error != nullptr) {
          errorLog(std::string("CookieManager: getCookies failed: ") + error->message);
          g_error_free(error);
        } else if (cookies != nullptr) {
          for (GList* l = cookies; l != nullptr; l = l->next) {
            SoupCookie* soupCookie = static_cast<SoupCookie*>(l->data);
            cookieList.emplace_back(soupCookie);
          }
          g_list_free_full(cookies, reinterpret_cast<GDestroyNotify>(soup_cookie_free));
        }

        (*cb)(cookieList);
        delete cb;
      },
      callbackPtr);
}

void CookieManager::getCookie(const std::string& url, const std::string& name,
                              std::function<void(std::optional<Cookie>)> callback) {
  getCookies(url, [name, callback = std::move(callback)](std::vector<Cookie> cookies) {
    for (const auto& cookie : cookies) {
      if (cookie.name == name) {
        callback(cookie);
        return;
      }
    }
    callback(std::nullopt);
  });
}

void CookieManager::deleteCookie(const std::string& url, const std::string& name,
                                 const std::string& domain, const std::string& path,
                                 std::function<void(bool)> callback) {
  WebKitCookieManager* manager = getCookieManager();
  if (manager == nullptr) {
    callback(false);
    return;
  }

  // Determine the domain to use for fetching cookies
  std::string cookieDomain = domain;
  if (cookieDomain.empty() && !url.empty()) {
    GUri* guri = g_uri_parse(url.c_str(), G_URI_FLAGS_NONE, nullptr);
    if (guri != nullptr) {
      const char* host = g_uri_get_host(guri);
      if (host != nullptr) {
        cookieDomain = std::string(host);
      }
      g_uri_unref(guri);
    }
  }

  // WPE WebKit requires the EXACT SoupCookie object to delete, not a minimal one.
  // We must first fetch all cookies and find the matching one with all its attributes.
  auto* callbackPtr = new std::function<void(bool)>(std::move(callback));
  
  // Capture parameters for the callback
  struct DeleteContext {
    WebKitCookieManager* manager;
    std::string name;
    std::string domain;
    std::string path;
    std::function<void(bool)>* callback;
  };
  
  auto* ctx = new DeleteContext{manager, name, cookieDomain, path, callbackPtr};

  webkit_cookie_manager_get_all_cookies(
      manager,
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* ctx = static_cast<DeleteContext*>(user_data);
        
        GError* error = nullptr;
        GList* cookies = webkit_cookie_manager_get_all_cookies_finish(
            WEBKIT_COOKIE_MANAGER(source), result, &error);
        
        if (error != nullptr) {
          errorLog(std::string("CookieManager: deleteCookie fetch failed: ") + error->message);
          g_error_free(error);
          (*(ctx->callback))(false);
          delete ctx->callback;
          delete ctx;
          return;
        }
        
        // Find the matching cookie
        SoupCookie* matchingCookie = nullptr;
        for (GList* l = cookies; l != nullptr; l = l->next) {
          SoupCookie* soupCookie = static_cast<SoupCookie*>(l->data);
          const char* cookieName = soup_cookie_get_name(soupCookie);
          const char* cookieDomain = soup_cookie_get_domain(soupCookie);
          const char* cookiePath = soup_cookie_get_path(soupCookie);
          
          if (cookieName != nullptr && strcmp(cookieName, ctx->name.c_str()) == 0) {
            // Check domain match (if specified)
            bool domainMatch = ctx->domain.empty() ||
                               (cookieDomain != nullptr && 
                                (strcmp(cookieDomain, ctx->domain.c_str()) == 0 ||
                                 // Also match with leading dot (e.g., ".example.com" matches "example.com")
                                 (cookieDomain[0] == '.' && strcmp(cookieDomain + 1, ctx->domain.c_str()) == 0) ||
                                 (ctx->domain[0] == '.' && strcmp(cookieDomain, ctx->domain.c_str() + 1) == 0)));
            
            // Check path match (if not default)
            bool pathMatch = ctx->path == "/" || 
                             (cookiePath != nullptr && strcmp(cookiePath, ctx->path.c_str()) == 0);
            
            if (domainMatch && pathMatch) {
              matchingCookie = soup_cookie_copy(soupCookie);
              break;
            }
          }
        }
        
        g_list_free_full(cookies, reinterpret_cast<GDestroyNotify>(soup_cookie_free));
        
        if (matchingCookie == nullptr) {
          // Cookie not found - consider this a success (nothing to delete)
          (*(ctx->callback))(true);
          delete ctx->callback;
          delete ctx;
          return;
        }
        
        // Now delete the actual cookie with all its attributes
        webkit_cookie_manager_delete_cookie(
            ctx->manager, matchingCookie,
            nullptr,  // cancellable
            [](GObject* source, GAsyncResult* result, gpointer user_data) {
              auto* ctx = static_cast<DeleteContext*>(user_data);
              
              GError* error = nullptr;
              gboolean success = webkit_cookie_manager_delete_cookie_finish(
                  WEBKIT_COOKIE_MANAGER(source), result, &error);
              
              if (error != nullptr) {
                errorLog(std::string("CookieManager: deleteCookie failed: ") + error->message);
                g_error_free(error);
              }
              
              (*(ctx->callback))(success);
              delete ctx->callback;
              delete ctx;
            },
            ctx);
        
        soup_cookie_free(matchingCookie);
      },
      ctx);
}

void CookieManager::deleteCookies(const std::string& url, const std::string& domain,
                                  const std::string& path, std::function<void(bool)> callback) {
  // Get all cookies for the URL and delete them
  getCookies(url,
             [this, domain, path, callback = std::move(callback)](std::vector<Cookie> cookies) {
               if (cookies.empty()) {
                 callback(true);
                 return;
               }

               auto* remaining = new std::atomic<size_t>(cookies.size());
               auto* anyFailed = new std::atomic<bool>(false);
               auto* sharedCallback = new std::function<void(bool)>(callback);

               for (const auto& cookie : cookies) {
                 std::string cookieDomain = cookie.domain.value_or("");
                 std::string cookiePath = cookie.path.value_or("/");

                 // Filter by domain if specified
                 if (!domain.empty() && cookieDomain != domain) {
                   size_t prev = remaining->fetch_sub(1);
                   if (prev == 1) {
                     (*sharedCallback)(!(*anyFailed));
                     delete remaining;
                     delete anyFailed;
                     delete sharedCallback;
                   }
                   continue;
                 }

                 deleteCookie("", cookie.name, cookieDomain, cookiePath,
                              [remaining, anyFailed, sharedCallback](bool success) {
                                if (!success) {
                                  anyFailed->store(true);
                                }
                                size_t prev = remaining->fetch_sub(1);
                                if (prev == 1) {
                                  (*sharedCallback)(!(*anyFailed));
                                  delete remaining;
                                  delete anyFailed;
                                  delete sharedCallback;
                                }
                              });
               }
             });
}

void CookieManager::deleteAllCookies(std::function<void(bool)> callback) {
  // WPE WebKit 2.x uses NetworkSession API
  WebKitNetworkSession* session = webkit_network_session_get_default();
  WebKitWebsiteDataManager* manager =
      session != nullptr ? webkit_network_session_get_website_data_manager(session) : nullptr;

  if (manager == nullptr) {
    callback(false);
    return;
  }

  auto* callbackPtr = new std::function<void(bool)>(std::move(callback));

  webkit_website_data_manager_clear(
      manager, WEBKIT_WEBSITE_DATA_COOKIES,
      0,        // timespan (0 = all)
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<std::function<void(bool)>*>(user_data);

        GError* error = nullptr;
        gboolean success = webkit_website_data_manager_clear_finish(
            WEBKIT_WEBSITE_DATA_MANAGER(source), result, &error);

        if (error != nullptr) {
          errorLog(std::string("CookieManager: deleteAllCookies failed: ") + error->message);
          g_error_free(error);
        }

        (*cb)(success);
        delete cb;
      },
      callbackPtr);
}

void CookieManager::getAllCookies(std::function<void(std::vector<Cookie>)> callback) {
  WebKitCookieManager* manager = getCookieManager();
  if (manager == nullptr) {
    callback({});
    return;
  }

  auto* callbackPtr = new std::function<void(std::vector<Cookie>)>(std::move(callback));

  webkit_cookie_manager_get_all_cookies(
      manager,
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<std::function<void(std::vector<Cookie>)>*>(user_data);

        GError* error = nullptr;
        GList* cookies = webkit_cookie_manager_get_all_cookies_finish(
            WEBKIT_COOKIE_MANAGER(source), result, &error);

        std::vector<Cookie> cookieList;

        if (error != nullptr) {
          errorLog(std::string("CookieManager: getAllCookies failed: ") + error->message);
          g_error_free(error);
        } else if (cookies != nullptr) {
          for (GList* l = cookies; l != nullptr; l = l->next) {
            SoupCookie* soupCookie = static_cast<SoupCookie*>(l->data);
            cookieList.emplace_back(soupCookie);
          }
          g_list_free_full(cookies, reinterpret_cast<GDestroyNotify>(soup_cookie_free));
        }

        (*cb)(cookieList);
        delete cb;
      },
      callbackPtr);
}

}  // namespace flutter_inappwebview_plugin
