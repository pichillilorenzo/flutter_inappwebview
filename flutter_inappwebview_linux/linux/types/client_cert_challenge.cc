#include "client_cert_challenge.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

ClientCertChallenge::ClientCertChallenge(const URLProtectionSpace& protectionSpace, bool isProxy)
    : protectionSpace(protectionSpace), isProxy(isProxy) {}

FlValue* ClientCertChallenge::toFlValue() const {
  // Convert keyTypes to FlValue list
  g_autoptr(FlValue) keyTypesValue = fl_value_new_list();
  for (const auto& keyType : keyTypes) {
    fl_value_append_take(keyTypesValue, fl_value_new_string(keyType.c_str()));
  }
  
  // Convert principals to FlValue list
  g_autoptr(FlValue) principalsValue = fl_value_new_list();
  for (const auto& principal : principals) {
    fl_value_append_take(principalsValue, fl_value_new_string(principal.c_str()));
  }
  
  // Convert allowedCertificateAuthorities to FlValue list
  g_autoptr(FlValue) allowedCAsValue = fl_value_new_list();
  for (const auto& ca : allowedCertificateAuthorities) {
    fl_value_append_take(allowedCAsValue, fl_value_new_string(ca.c_str()));
  }
  
  // Convert mutuallyTrustedCertificates to FlValue list
  g_autoptr(FlValue) trustedCertsValue = fl_value_new_list();
  for (const auto& cert : mutuallyTrustedCertificates) {
    fl_value_append(trustedCertsValue, cert.toFlValue());
  }
  
  return to_fl_map({
      {"protectionSpace", protectionSpace.toFlValue()},
      {"isProxy", make_fl_value(isProxy)},
      {"keyTypes", fl_value_ref(keyTypesValue)},
      {"principals", fl_value_ref(principalsValue)},
      {"allowedCertificateAuthorities", fl_value_ref(allowedCAsValue)},
      {"mutuallyTrustedCertificates", fl_value_ref(trustedCertsValue)},
  });
}

}  // namespace flutter_inappwebview_plugin
