## 0.1.0-beta.2

- Fixed `onReceivedHttpAuthRequest` never reaching the app: the challenge's `previousFailureCount` was `null`. It is now `0` for a first challenge and `1` for a retry, as WPE WebKit only reports whether a request is a retry
- Fixed HTTP auth responses always cancelling the request: `HttpAuthResponseAction` had no Linux values, so `PROCEED` and `USE_SAVED_HTTP_AUTH_CREDENTIALS` were sent as `null` (fixed in flutter_inappwebview_platform_interface)
- Fixed `onReceivedServerTrustAuthRequest` never reaching the app: `SslError.code` was sent as a string. It is now the `GTlsCertificateFlags` value that `SslErrorType` maps on Linux
- Fixed `ServerTrustAuthResponseAction.PROCEED` not retrying the load that failed the server trust check, and a use-after-free of its URL

## 0.1.0-beta.1

- Initial release.
