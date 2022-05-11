import 'package:flutter/foundation.dart';

///Class that represents the error types returned by URL loading APIs.
class WebResourceErrorType {
  final String _value;
  final int _nativeValue;

  const WebResourceErrorType._internal(this._value, this._nativeValue);

  ///Set of all values of [WebResourceErrorType].
  static final Set<WebResourceErrorType> values = [
    WebResourceErrorType.USER_AUTHENTICATION_FAILED,
    WebResourceErrorType.BAD_URL,
    WebResourceErrorType.CANNOT_CONNECT_TO_HOST,
    WebResourceErrorType.FAILED_SSL_HANDSHAKE,
    WebResourceErrorType.GENERIC_FILE_ERROR,
    WebResourceErrorType.FILE_NOT_FOUND,
    WebResourceErrorType.HOST_LOOKUP,
    WebResourceErrorType.IO,
    WebResourceErrorType.PROXY_AUTHENTICATION,
    WebResourceErrorType.TOO_MANY_REDIRECTS,
    WebResourceErrorType.TIMEOUT,
    WebResourceErrorType.TOO_MANY_REQUESTS,
    WebResourceErrorType.UNKNOWN,
    WebResourceErrorType.UNSAFE_RESOURCE,
    WebResourceErrorType.UNSUPPORTED_AUTH_SCHEME,
    WebResourceErrorType.UNSUPPORTED_SCHEME,
    WebResourceErrorType.CANCELLED,
    WebResourceErrorType.NETWORK_CONNECTION_LOST,
    WebResourceErrorType.RESOURCE_UNAVAILABLE,
    WebResourceErrorType.NOT_CONNECTED_TO_INTERNET,
    WebResourceErrorType.REDIRECT_TO_NON_EXISTENT_LOCATION,
    WebResourceErrorType.BAD_SERVER_RESPONSE,
    WebResourceErrorType.USER_CANCELLED_AUTHENTICATION,
    WebResourceErrorType.USER_AUTHENTICATION_REQUIRED,
    WebResourceErrorType.ZERO_BYTE_RESOURCE,
    WebResourceErrorType.CANNOT_DECODE_RAW_DATA,
    WebResourceErrorType.CANNOT_DECODE_CONTENT_DATA,
    WebResourceErrorType.CANNOT_PARSE_RESPONSE,
    WebResourceErrorType.APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION,
    WebResourceErrorType.FILE_IS_DIRECTORY,
    WebResourceErrorType.NO_PERMISSIONS_TO_READ_FILE,
    WebResourceErrorType.DATA_LENGTH_EXCEEDS_MAXIMUM,
    WebResourceErrorType.SECURE_CONNECTION_FAILED,
    WebResourceErrorType.SERVER_CERTIFICATE_HAS_BAD_DATE,
    WebResourceErrorType.SERVER_CERTIFICATE_UNTRUSTED,
    WebResourceErrorType.SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT,
    WebResourceErrorType.SERVER_CERTIFICATE_NOT_YET_VALID,
    WebResourceErrorType.CLIENT_CERTIFICATE_REJECTED,
    WebResourceErrorType.CLIENT_CERTIFICATE_REQUIRED,
    WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK,
    WebResourceErrorType.CANNOT_CREATE_FILE,
    WebResourceErrorType.CANNOT_OPEN_FILE,
    WebResourceErrorType.CANNOT_CLOSE_FILE,
    WebResourceErrorType.CANNOT_WRITE_TO_FILE,
    WebResourceErrorType.CANNOT_REMOVE_FILE,
    WebResourceErrorType.CANNOT_MOVE_FILE,
    WebResourceErrorType.DOWNLOAD_DECODING_FAILED_MID_STREAM,
    WebResourceErrorType.DOWNLOAD_DECODING_FAILED_TO_COMPLETE,
    WebResourceErrorType.INTERNATIONAL_ROAMING_OFF,
    WebResourceErrorType.CALL_IS_ACTIVE,
    WebResourceErrorType.DATA_NOT_ALLOWED,
    WebResourceErrorType.REQUEST_BODY_STREAM_EXHAUSTED,
    WebResourceErrorType.BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER,
    WebResourceErrorType.BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS,
    WebResourceErrorType.BACKGROUND_SESSION_WAS_DISCONNECTED
  ].toSet();

  ///Gets a possible [WebResourceErrorType] instance from a [String] value.
  static WebResourceErrorType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebResourceErrorType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebResourceErrorType] instance from an [int] native value.
  static WebResourceErrorType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebResourceErrorType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets native [int] value.
  int toNativeValue() => _nativeValue;

  @override
  String toString() => _value;

  ///User authentication failed on server.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_AUTHENTICATION](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_AUTHENTICATION))
  static final USER_AUTHENTICATION_FAILED = WebResourceErrorType._internal(
      "USER_AUTHENTICATION_FAILED",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -4
          : UNKNOWN._nativeValue);

  ///A malformed URL prevented a URL request from being initiated.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_BAD_URL](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_BAD_URL))
  ///- iOS ([Official API - URLError.badURL](https://developer.apple.com/documentation/foundation/urlerror/2293516-badurl))
  static final BAD_URL = WebResourceErrorType._internal(
      "BAD_URL",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -12
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1000
              : UNKNOWN._nativeValue));

  ///Failed to connect to the server.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_CONNECT](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_CONNECT))
  ///- iOS ([Official API - URLError.cannotConnectToHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883001-cannotconnecttohost))
  static final CANNOT_CONNECT_TO_HOST = WebResourceErrorType._internal(
      "CANNOT_CONNECT_TO_HOST",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -6
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1004
              : UNKNOWN._nativeValue));

  ///Failed to perform SSL handshake.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_FAILED_SSL_HANDSHAKE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FAILED_SSL_HANDSHAKE))
  static final FAILED_SSL_HANDSHAKE = WebResourceErrorType._internal(
      "FAILED_SSL_HANDSHAKE",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -11
          : UNKNOWN._nativeValue);

  ///Generic file error.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_FILE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE))
  static final GENERIC_FILE_ERROR = WebResourceErrorType._internal(
      "GENERIC_FILE_ERROR",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -13
          : UNKNOWN._nativeValue);

  ///File not found.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_FILE_NOT_FOUND](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE_NOT_FOUND))
  ///- iOS ([Official API - URLError.fileDoesNotExist](https://developer.apple.com/documentation/foundation/urlerror/code/2883074-filedoesnotexist))
  static final FILE_NOT_FOUND = WebResourceErrorType._internal(
      "FILE_NOT_FOUND",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -14
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1100
              : UNKNOWN._nativeValue));

  ///Server or proxy hostname lookup failed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_HOST_LOOKUP](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_HOST_LOOKUP))
  ///- iOS ([Official API - URLError.cannotFindHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883157-cannotfindhost))
  static final HOST_LOOKUP = WebResourceErrorType._internal(
      "HOST_LOOKUP",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -2
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1003
              : UNKNOWN._nativeValue));

  ///Failed to read or write to the server.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_IO](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_IO))
  static final IO = WebResourceErrorType._internal(
      "IO",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -7
          : UNKNOWN._nativeValue);

  ///User authentication failed on proxy.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_PROXY_AUTHENTICATION](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_PROXY_AUTHENTICATION))
  static final PROXY_AUTHENTICATION = WebResourceErrorType._internal(
      "PROXY_AUTHENTICATION",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -5
          : UNKNOWN._nativeValue);

  ///A redirect loop has been detected or the threshold for number of allowable redirects has been exceeded (currently `16` on iOS).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_REDIRECT_LOOP](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_REDIRECT_LOOP))
  ///- iOS ([Official API - URLError.cannotFindHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883157-cannotfindhost))
  static final TOO_MANY_REDIRECTS = WebResourceErrorType._internal(
      "TOO_MANY_REDIRECTS",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -9
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1007
              : UNKNOWN._nativeValue));

  ///Connection timed out.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_TIMEOUT](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TIMEOUT))
  ///- iOS ([Official API - URLError.timedOut](https://developer.apple.com/documentation/foundation/urlerror/code/2883027-timedout))
  static final TIMEOUT = WebResourceErrorType._internal(
      "TIMEOUT",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -8
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1001
              : UNKNOWN._nativeValue));

  ///Too many requests during this load.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_TOO_MANY_REQUESTS](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TOO_MANY_REQUESTS))
  static final TOO_MANY_REQUESTS = WebResourceErrorType._internal(
      "TOO_MANY_REQUESTS",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -15
          : UNKNOWN._nativeValue);

  ///The URL Loading System encountered an error that it can’t interpret.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNKNOWN](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNKNOWN))
  ///- iOS ([Official API - URLError.unknown](https://developer.apple.com/documentation/foundation/urlerror/2293357-unknown))
  static final UNKNOWN = WebResourceErrorType._internal("UNKNOWN", -1);

  ///Resource load was canceled by Safe Browsing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNSAFE_RESOURCE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSAFE_RESOURCE))
  static final UNSAFE_RESOURCE = WebResourceErrorType._internal(
      "UNSAFE_RESOURCE",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -16
          : UNKNOWN._nativeValue);

  ///Unsupported authentication scheme (not basic or digest).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNSUPPORTED_AUTH_SCHEME](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_AUTH_SCHEME))
  static final UNSUPPORTED_AUTH_SCHEME = WebResourceErrorType._internal(
      "UNSUPPORTED_AUTH_SCHEME",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -3
          : UNKNOWN._nativeValue);

  ///Unsupported URI scheme.
  ///Typically this occurs when there is no available protocol handler for the URL.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNSUPPORTED_SCHEME](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_SCHEME))
  ///- iOS ([Official API - URLError.unsupportedURL](https://developer.apple.com/documentation/foundation/urlerror/code/2883043-unsupportedurl))
  static final UNSUPPORTED_SCHEME = WebResourceErrorType._internal(
      "UNSUPPORTED_SCHEME",
      (defaultTargetPlatform == TargetPlatform.android)
          ? -10
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1002
              : UNKNOWN._nativeValue));

  ///An asynchronous load has been canceled.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cancelled](https://developer.apple.com/documentation/foundation/urlerror/code/2883178-cancelled))
  static final CANCELLED = WebResourceErrorType._internal(
      "CANCELLED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -999
          : UNKNOWN._nativeValue);

  ///A client or server connection was severed in the middle of an in-progress load.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.networkConnectionLost](https://developer.apple.com/documentation/foundation/urlerror/2293759-networkconnectionlost))
  static final NETWORK_CONNECTION_LOST = WebResourceErrorType._internal(
      "NETWORK_CONNECTION_LOST",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1005
          : UNKNOWN._nativeValue);

  ///A requested resource couldn't be retrieved.
  ///This error can indicate a file-not-found situation, or decoding problems that prevent data from being processed correctly.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.resourceUnavailable](https://developer.apple.com/documentation/foundation/urlerror/2293555-resourceunavailable))
  static final RESOURCE_UNAVAILABLE = WebResourceErrorType._internal(
      "RESOURCE_UNAVAILABLE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1008
          : UNKNOWN._nativeValue);

  ///A network resource was requested, but an internet connection hasn’t been established and can’t be established automatically.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.notConnectedToInternet](https://developer.apple.com/documentation/foundation/urlerror/2293104-notconnectedtointernet))
  static final NOT_CONNECTED_TO_INTERNET = WebResourceErrorType._internal(
      "NOT_CONNECTED_TO_INTERNET",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1009
          : UNKNOWN._nativeValue);

  ///A redirect was specified by way of server response code, but the server didn’t accompany this code with a redirect URL.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.redirectToNonExistentLocation](https://developer.apple.com/documentation/foundation/urlerror/2293066-redirecttononexistentlocation))
  static final REDIRECT_TO_NON_EXISTENT_LOCATION =
      WebResourceErrorType._internal(
          "REDIRECT_TO_NON_EXISTENT_LOCATION",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1010
              : UNKNOWN._nativeValue);

  ///The URL Loading System received bad data from the server.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.badServerResponse](https://developer.apple.com/documentation/foundation/urlerror/2293606-badserverresponse))
  static final BAD_SERVER_RESPONSE = WebResourceErrorType._internal(
      "BAD_SERVER_RESPONSE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1011
          : UNKNOWN._nativeValue);

  ///An asynchronous request for authentication has been canceled by the user.
  ///This error typically occurs when a user clicks a "Cancel" button in a username/password dialog, rather than attempting to authenticate.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.userCancelledAuthentication](https://developer.apple.com/documentation/foundation/urlerror/2293330-usercancelledauthentication))
  static final USER_CANCELLED_AUTHENTICATION = WebResourceErrorType._internal(
      "USER_CANCELLED_AUTHENTICATION",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1012
          : UNKNOWN._nativeValue);

  ///Authentication is required to access a resource.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.userAuthenticationRequired](https://developer.apple.com/documentation/foundation/urlerror/2293560-userauthenticationrequired))
  static final USER_AUTHENTICATION_REQUIRED = WebResourceErrorType._internal(
      "USER_AUTHENTICATION_REQUIRED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1013
          : UNKNOWN._nativeValue);

  ///A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.zeroByteResource](https://developer.apple.com/documentation/foundation/urlerror/2293773-zerobyteresource))
  static final ZERO_BYTE_RESOURCE = WebResourceErrorType._internal(
      "ZERO_BYTE_RESOURCE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1014
          : UNKNOWN._nativeValue);

  ///Content data received during a connection request couldn’t be decoded for a known content encoding.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotDecodeRawData](https://developer.apple.com/documentation/foundation/urlerror/2293573-cannotdecoderawdata))
  static final CANNOT_DECODE_RAW_DATA = WebResourceErrorType._internal(
      "CANNOT_DECODE_RAW_DATA",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1015
          : UNKNOWN._nativeValue);

  ///Content data received during a connection request couldn’t be decoded for a known content encoding.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotDecodeContentData](https://developer.apple.com/documentation/foundation/urlerror/2292983-cannotdecodecontentdata))
  static final CANNOT_DECODE_CONTENT_DATA = WebResourceErrorType._internal(
      "CANNOT_DECODE_CONTENT_DATA",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1016
          : UNKNOWN._nativeValue);

  ///A task could not parse a response.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotParseResponse](https://developer.apple.com/documentation/foundation/urlerror/code/2882919-cannotparseresponse))
  static final CANNOT_PARSE_RESPONSE = WebResourceErrorType._internal(
      "CANNOT_PARSE_RESPONSE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1017
          : UNKNOWN._nativeValue);

  ///App Transport Security disallowed a connection because there is no secure network connection.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.appTransportSecurityRequiresSecureConnection](https://developer.apple.com/documentation/foundation/urlerror/code/2882980-apptransportsecurityrequiressecu))
  static final APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION =
      WebResourceErrorType._internal(
          "APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1022
              : UNKNOWN._nativeValue);

  ///A request for an FTP file resulted in the server responding that the file is not a plain file, but a directory.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.fileIsDirectory](https://developer.apple.com/documentation/foundation/urlerror/code/2883220-fileisdirectory))
  static final FILE_IS_DIRECTORY = WebResourceErrorType._internal(
      "FILE_IS_DIRECTORY",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1101
          : UNKNOWN._nativeValue);

  ///A resource couldn’t be read because of insufficient permissions.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.noPermissionsToReadFile](https://developer.apple.com/documentation/foundation/urlerror/code/2882941-nopermissionstoreadfile))
  static final NO_PERMISSIONS_TO_READ_FILE = WebResourceErrorType._internal(
      "NO_PERMISSIONS_TO_READ_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1102
          : UNKNOWN._nativeValue);

  ///The length of the resource data exceeds the maximum allowed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.dataLengthExceedsMaximum](https://developer.apple.com/documentation/foundation/urlerror/code/2882930-datalengthexceedsmaximum))
  static final DATA_LENGTH_EXCEEDS_MAXIMUM = WebResourceErrorType._internal(
      "DATA_LENGTH_EXCEEDS_MAXIMUM",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1103
          : UNKNOWN._nativeValue);

  ///An attempt to establish a secure connection failed for reasons that can’t be expressed more specifically.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.secureConnectionFailed](https://developer.apple.com/documentation/foundation/urlerror/code/2883122-secureconnectionfailed))
  static final SECURE_CONNECTION_FAILED = WebResourceErrorType._internal(
      "SECURE_CONNECTION_FAILED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1200
          : UNKNOWN._nativeValue);

  ///A server certificate had a date which indicates it has expired, or is not yet valid.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateHasBadDate](https://developer.apple.com/documentation/foundation/urlerror/code/2883088-servercertificatehasbaddate))
  static final SERVER_CERTIFICATE_HAS_BAD_DATE = WebResourceErrorType._internal(
      "SERVER_CERTIFICATE_HAS_BAD_DATE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1201
          : UNKNOWN._nativeValue);

  ///A server certificate was signed by a root server that isn’t trusted.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateUntrusted](https://developer.apple.com/documentation/foundation/urlerror/code/2882976-servercertificateuntrusted))
  static final SERVER_CERTIFICATE_UNTRUSTED = WebResourceErrorType._internal(
      "SERVER_CERTIFICATE_UNTRUSTED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1202
          : UNKNOWN._nativeValue);

  ///A server certificate was not signed by any root server.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateHasUnknownRoot](https://developer.apple.com/documentation/foundation/urlerror/code/2883085-servercertificatehasunknownroot))
  static final SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT =
      WebResourceErrorType._internal(
          "SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1203
              : UNKNOWN._nativeValue);

  ///A server certificate is not yet valid.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateNotYetValid](https://developer.apple.com/documentation/foundation/urlerror/code/2882991-servercertificatenotyetvalid))
  static final SERVER_CERTIFICATE_NOT_YET_VALID =
      WebResourceErrorType._internal(
          "SERVER_CERTIFICATE_NOT_YET_VALID",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -1204
              : UNKNOWN._nativeValue);

  ///A server certificate was rejected.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.clientCertificateRejected](https://developer.apple.com/documentation/foundation/urlerror/code/2883091-clientcertificaterejected))
  static final CLIENT_CERTIFICATE_REJECTED = WebResourceErrorType._internal(
      "CLIENT_CERTIFICATE_REJECTED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1205
          : UNKNOWN._nativeValue);

  ///A client certificate was required to authenticate an SSL connection during a request.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.clientCertificateRequired](https://developer.apple.com/documentation/foundation/urlerror/code/2883199-clientcertificaterequired))
  static final CLIENT_CERTIFICATE_REQUIRED = WebResourceErrorType._internal(
      "CLIENT_CERTIFICATE_REQUIRED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1206
          : UNKNOWN._nativeValue);

  ///A request to load an item only from the cache could not be satisfied.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotLoadFromNetwork](https://developer.apple.com/documentation/foundation/urlerror/code/2882968-cannotloadfromnetwork))
  static final CANNOT_LOAD_FROM_NETWORK = WebResourceErrorType._internal(
      "CANNOT_LOAD_FROM_NETWORK",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -2000
          : UNKNOWN._nativeValue);

  ///A download task couldn’t create the downloaded file on disk because of an I/O failure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotCreateFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883204-cannotcreatefile))
  static final CANNOT_CREATE_FILE = WebResourceErrorType._internal(
      "CANNOT_CREATE_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -3000
          : UNKNOWN._nativeValue);

  ///A download task was unable to open the downloaded file on disk.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotOpenFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883034-cannotopenfile))
  static final CANNOT_OPEN_FILE = WebResourceErrorType._internal(
      "CANNOT_OPEN_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -3001
          : UNKNOWN._nativeValue);

  ///A download task couldn’t close the downloaded file on disk.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotCloseFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883215-cannotclosefile))
  static final CANNOT_CLOSE_FILE = WebResourceErrorType._internal(
      "CANNOT_CLOSE_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -3002
          : UNKNOWN._nativeValue);

  ///A download task was unable to write to the downloaded file on disk.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotWriteToFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883098-cannotwritetofile))
  static final CANNOT_WRITE_TO_FILE = WebResourceErrorType._internal(
      "CANNOT_WRITE_TO_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -3003
          : UNKNOWN._nativeValue);

  ///A download task was unable to remove a downloaded file from disk.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotRemoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883202-cannotremovefile))
  static final CANNOT_REMOVE_FILE = WebResourceErrorType._internal(
      "CANNOT_REMOVE_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -3004
          : UNKNOWN._nativeValue);

  ///A download task was unable to move a downloaded file on disk.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotMoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883180-cannotmovefile))
  static final CANNOT_MOVE_FILE = WebResourceErrorType._internal(
      "CANNOT_MOVE_FILE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -3005
          : UNKNOWN._nativeValue);

  ///A download task failed to decode an encoded file during the download.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.downloadDecodingFailedMidStream](https://developer.apple.com/documentation/foundation/urlerror/code/2883224-downloaddecodingfailedmidstream))
  static final DOWNLOAD_DECODING_FAILED_MID_STREAM =
      WebResourceErrorType._internal(
          "DOWNLOAD_DECODING_FAILED_MID_STREAM",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -3006
              : UNKNOWN._nativeValue);

  ///A download task failed to decode an encoded file after downloading.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.downloadDecodingFailedToComplete](https://developer.apple.com/documentation/foundation/urlerror/code/2882936-downloaddecodingfailedtocomplete))
  static final DOWNLOAD_DECODING_FAILED_TO_COMPLETE =
      WebResourceErrorType._internal(
          "DOWNLOAD_DECODING_FAILED_TO_COMPLETE",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -3007
              : UNKNOWN._nativeValue);

  ///The attempted connection required activating a data context while roaming, but international roaming is disabled.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.internationalRoamingOff](https://developer.apple.com/documentation/foundation/urlerror/code/2883134-internationalroamingoff))
  static final INTERNATIONAL_ROAMING_OFF = WebResourceErrorType._internal(
      "INTERNATIONAL_ROAMING_OFF",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1018
          : UNKNOWN._nativeValue);

  ///A connection was attempted while a phone call is active on a network that does not support simultaneous phone and data communication (EDGE or GPRS).
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.callIsActive](https://developer.apple.com/documentation/foundation/urlerror/code/2883170-callisactive))
  static final CALL_IS_ACTIVE = WebResourceErrorType._internal(
      "CALL_IS_ACTIVE",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1019
          : UNKNOWN._nativeValue);

  ///The cellular network disallowed a connection.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.dataNotAllowed](https://developer.apple.com/documentation/foundation/urlerror/code/2883217-datanotallowed))
  static final DATA_NOT_ALLOWED = WebResourceErrorType._internal(
      "DATA_NOT_ALLOWED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1020
          : UNKNOWN._nativeValue);

  ///A body stream is needed but the client did not provide one.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.requestBodyStreamExhausted](https://developer.apple.com/documentation/foundation/urlerror/code/2883176-requestbodystreamexhausted))
  static final REQUEST_BODY_STREAM_EXHAUSTED = WebResourceErrorType._internal(
      "REQUEST_BODY_STREAM_EXHAUSTED",
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? -1021
          : UNKNOWN._nativeValue);

  ///The shared container identifier of the URL session configuration is needed but has not been set.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.backgroundSessionRequiresSharedContainer](https://developer.apple.com/documentation/foundation/urlerror/code/2883169-backgroundsessionrequiressharedc))
  static final BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER =
      WebResourceErrorType._internal(
          "BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -995
              : UNKNOWN._nativeValue);

  ///An app or app extension attempted to connect to a background session that is already connected to a process.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.backgroundSessionInUseByAnotherProcess](https://developer.apple.com/documentation/foundation/urlerror/code/2882923-backgroundsessioninusebyanotherp))
  static final BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS =
      WebResourceErrorType._internal(
          "BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -996
              : UNKNOWN._nativeValue);

  ///The app is suspended or exits while a background data task is processing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.backgroundSessionWasDisconnected](https://developer.apple.com/documentation/foundation/urlerror/code/2883075-backgroundsessionwasdisconnected))
  static final BACKGROUND_SESSION_WAS_DISCONNECTED =
      WebResourceErrorType._internal(
          "BACKGROUND_SESSION_WAS_DISCONNECTED",
          (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? -997
              : UNKNOWN._nativeValue);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
