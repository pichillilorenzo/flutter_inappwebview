#include <flutter_linux/flutter_linux.h>
#include <gtest/gtest.h>

#include "../types/http_auth_response.h"
#include "../types/http_authentication_challenge.h"
#include "../types/server_trust_challenge.h"

// The maps built here are decoded on the Dart side by the platform interface's
// generated fromMap methods, which throw if a non-nullable field is null or has
// the wrong type. These tests pin the field types the Dart side expects.

namespace flutter_inappwebview_plugin {
namespace test {

namespace {

URLProtectionSpace MakeProtectionSpace() {
  return URLProtectionSpace("127.0.0.1", 8081, std::nullopt, std::string("Node"),
                            HttpAuthScheme::HTTP_BASIC, false);
}

int64_t GetInt(FlValue* map, const char* key) {
  FlValue* value = fl_value_lookup_string(map, key);
  EXPECT_NE(value, nullptr) << key;
  if (value == nullptr) {
    return -1;
  }
  EXPECT_EQ(fl_value_get_type(value), FL_VALUE_TYPE_INT) << key;
  if (fl_value_get_type(value) != FL_VALUE_TYPE_INT) {
    return -1;
  }
  return fl_value_get_int(value);
}

}  // namespace

TEST(HttpAuthenticationChallenge, FirstChallengeHasPreviousFailureCountZero) {
  HttpAuthenticationChallenge challenge(MakeProtectionSpace(), false);
  g_autoptr(FlValue) map = challenge.toFlValue();

  EXPECT_EQ(GetInt(map, "previousFailureCount"), 0);
}

TEST(HttpAuthenticationChallenge, RetryHasPreviousFailureCountOne) {
  HttpAuthenticationChallenge challenge(MakeProtectionSpace(), true);
  g_autoptr(FlValue) map = challenge.toFlValue();

  EXPECT_EQ(GetInt(map, "previousFailureCount"), 1);
}

TEST(HttpAuthenticationChallenge, ProtectionSpaceHasHostAndPort) {
  HttpAuthenticationChallenge challenge(MakeProtectionSpace(), false);
  g_autoptr(FlValue) map = challenge.toFlValue();

  FlValue* protectionSpace = fl_value_lookup_string(map, "protectionSpace");
  ASSERT_NE(protectionSpace, nullptr);
  ASSERT_EQ(fl_value_get_type(protectionSpace), FL_VALUE_TYPE_MAP);
  FlValue* host = fl_value_lookup_string(protectionSpace, "host");
  ASSERT_NE(host, nullptr);
  ASSERT_EQ(fl_value_get_type(host), FL_VALUE_TYPE_STRING);
  EXPECT_STREQ(fl_value_get_string(host), "127.0.0.1");
  EXPECT_EQ(GetInt(protectionSpace, "port"), 8081);
}

TEST(SslError, CodeIsTheGTlsCertificateFlag) {
  const struct {
    GTlsCertificateFlags errors;
    int64_t code;
  } cases[] = {
      {G_TLS_CERTIFICATE_UNKNOWN_CA, G_TLS_CERTIFICATE_UNKNOWN_CA},
      {G_TLS_CERTIFICATE_BAD_IDENTITY, G_TLS_CERTIFICATE_BAD_IDENTITY},
      {G_TLS_CERTIFICATE_NOT_ACTIVATED, G_TLS_CERTIFICATE_NOT_ACTIVATED},
      {G_TLS_CERTIFICATE_EXPIRED, G_TLS_CERTIFICATE_EXPIRED},
      {G_TLS_CERTIFICATE_REVOKED, G_TLS_CERTIFICATE_REVOKED},
      {G_TLS_CERTIFICATE_GENERIC_ERROR, G_TLS_CERTIFICATE_GENERIC_ERROR},
      // No Dart equivalent: reported as a generic error.
      {G_TLS_CERTIFICATE_INSECURE, G_TLS_CERTIFICATE_GENERIC_ERROR},
  };

  for (const auto& c : cases) {
    SslError error = SslError::fromGTlsCertificateFlags(c.errors);
    g_autoptr(FlValue) map = error.toFlValue();
    EXPECT_EQ(GetInt(map, "code"), c.code) << "errors=" << c.errors;
  }
}

TEST(ServerTrustChallenge, SslErrorCodeIsAnInt) {
  auto challenge = ServerTrustChallenge::fromTlsError("https://127.0.0.1:4433/", nullptr,
                                                      G_TLS_CERTIFICATE_UNKNOWN_CA);
  g_autoptr(FlValue) map = challenge->toFlValue();

  FlValue* protectionSpace = fl_value_lookup_string(map, "protectionSpace");
  ASSERT_NE(protectionSpace, nullptr);
  EXPECT_EQ(GetInt(protectionSpace, "port"), 4433);
  FlValue* sslError = fl_value_lookup_string(protectionSpace, "sslError");
  ASSERT_NE(sslError, nullptr);
  ASSERT_EQ(fl_value_get_type(sslError), FL_VALUE_TYPE_MAP);
  EXPECT_EQ(GetInt(sslError, "code"), G_TLS_CERTIFICATE_UNKNOWN_CA);
}

TEST(HttpAuthResponse, DecodesProceedWithCredentials) {
  g_autoptr(FlValue) map = fl_value_new_map();
  fl_value_set_string_take(map, "action", fl_value_new_int(1));
  fl_value_set_string_take(map, "username", fl_value_new_string("USERNAME"));
  fl_value_set_string_take(map, "password", fl_value_new_string("PASSWORD"));
  fl_value_set_string_take(map, "permanentPersistence", fl_value_new_bool(false));

  HttpAuthResponse response(map);

  EXPECT_EQ(response.action, HttpAuthResponseAction::PROCEED);
  EXPECT_EQ(response.username, std::optional<std::string>("USERNAME"));
  EXPECT_EQ(response.password, std::optional<std::string>("PASSWORD"));
  EXPECT_FALSE(response.permanentPersistence);
}

}  // namespace test
}  // namespace flutter_inappwebview_plugin
