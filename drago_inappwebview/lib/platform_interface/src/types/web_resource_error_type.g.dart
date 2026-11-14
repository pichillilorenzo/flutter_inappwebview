// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_error_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the error types returned by URL loading APIs.
class WebResourceErrorType {
  final String _value;
  final int? _nativeValue;
  const WebResourceErrorType._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebResourceErrorType._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => WebResourceErrorType._internal(value, nativeValue());

  ///App Transport Security disallowed a connection because there is no secure network connection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.appTransportSecurityRequiresSecureConnection](https://developer.apple.com/documentation/foundation/urlerror/code/2882980-apptransportsecurityrequiressecu))
  ///- macOS WKWebView ([Official API - URLError.appTransportSecurityRequiresSecureConnection](https://developer.apple.com/documentation/foundation/urlerror/code/2882980-apptransportsecurityrequiressecu))
  static final APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION =
      WebResourceErrorType._internalMultiPlatform(
        'APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1022;
            case TargetPlatform.macOS:
              return -1022;
            default:
              break;
          }
          return null;
        },
      );

  ///An app or app extension attempted to connect to a background session that is already connected to a process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.backgroundSessionInUseByAnotherProcess](https://developer.apple.com/documentation/foundation/urlerror/code/2882923-backgroundsessioninusebyanotherp))
  ///- macOS WKWebView ([Official API - URLError.backgroundSessionInUseByAnotherProcess](https://developer.apple.com/documentation/foundation/urlerror/code/2882923-backgroundsessioninusebyanotherp))
  static final BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS =
      WebResourceErrorType._internalMultiPlatform(
        'BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -996;
            case TargetPlatform.macOS:
              return -996;
            default:
              break;
          }
          return null;
        },
      );

  ///The shared container identifier of the URL session configuration is needed but has not been set.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.backgroundSessionRequiresSharedContainer](https://developer.apple.com/documentation/foundation/urlerror/code/2883169-backgroundsessionrequiressharedc))
  ///- macOS WKWebView ([Official API - URLError.backgroundSessionRequiresSharedContainer](https://developer.apple.com/documentation/foundation/urlerror/code/2883169-backgroundsessionrequiressharedc))
  static final BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER =
      WebResourceErrorType._internalMultiPlatform(
        'BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -995;
            case TargetPlatform.macOS:
              return -995;
            default:
              break;
          }
          return null;
        },
      );

  ///The app is suspended or exits while a background data task is processing.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.backgroundSessionWasDisconnected](https://developer.apple.com/documentation/foundation/urlerror/code/2883075-backgroundsessionwasdisconnected))
  ///- macOS WKWebView ([Official API - URLError.backgroundSessionWasDisconnected](https://developer.apple.com/documentation/foundation/urlerror/code/2883075-backgroundsessionwasdisconnected))
  static final BACKGROUND_SESSION_WAS_DISCONNECTED =
      WebResourceErrorType._internalMultiPlatform(
        'BACKGROUND_SESSION_WAS_DISCONNECTED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -997;
            case TargetPlatform.macOS:
              return -997;
            default:
              break;
          }
          return null;
        },
      );

  ///The URL Loading System received bad data from the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.badServerResponse](https://developer.apple.com/documentation/foundation/urlerror/2293606-badserverresponse))
  ///- macOS WKWebView ([Official API - URLError.badServerResponse](https://developer.apple.com/documentation/foundation/urlerror/2293606-badserverresponse))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_ERROR_HTTP_INVALID_SERVER_RESPONSE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final BAD_SERVER_RESPONSE =
      WebResourceErrorType._internalMultiPlatform('BAD_SERVER_RESPONSE', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            return -1011;
          case TargetPlatform.macOS:
            return -1011;
          case TargetPlatform.windows:
            return 8;
          default:
            break;
        }
        return null;
      });

  ///A malformed URL prevented a URL request from being initiated.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_BAD_URL](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_BAD_URL))
  ///- iOS WKWebView ([Official API - URLError.badURL](https://developer.apple.com/documentation/foundation/urlerror/2293516-badurl))
  ///- macOS WKWebView ([Official API - URLError.badURL](https://developer.apple.com/documentation/foundation/urlerror/2293516-badurl))
  static final BAD_URL = WebResourceErrorType._internalMultiPlatform(
    'BAD_URL',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -12;
        case TargetPlatform.iOS:
          return -1000;
        case TargetPlatform.macOS:
          return -1000;
        default:
          break;
      }
      return null;
    },
  );

  ///A connection was attempted while a phone call is active on a network that does not support simultaneous phone and data communication (EDGE or GPRS).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.callIsActive](https://developer.apple.com/documentation/foundation/urlerror/code/2883170-callisactive))
  ///- macOS WKWebView ([Official API - URLError.callIsActive](https://developer.apple.com/documentation/foundation/urlerror/code/2883170-callisactive))
  static final CALL_IS_ACTIVE = WebResourceErrorType._internalMultiPlatform(
    'CALL_IS_ACTIVE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -1019;
        case TargetPlatform.macOS:
          return -1019;
        default:
          break;
      }
      return null;
    },
  );

  ///An asynchronous load has been canceled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cancelled](https://developer.apple.com/documentation/foundation/urlerror/code/2883178-cancelled))
  ///- macOS WKWebView ([Official API - URLError.cancelled](https://developer.apple.com/documentation/foundation/urlerror/code/2883178-cancelled))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_OPERATION_CANCELED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  ///- Linux WPE WebKit ([Official API - WEBKIT_NETWORK_ERROR_CANCELLED](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.NetworkError.html))
  static final CANCELLED = WebResourceErrorType._internalMultiPlatform(
    'CANCELLED',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -999;
        case TargetPlatform.macOS:
          return -999;
        case TargetPlatform.windows:
          return 14;
        case TargetPlatform.linux:
          return 302;
        default:
          break;
      }
      return null;
    },
  );

  ///A download task couldn’t close the downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotCloseFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883215-cannotclosefile))
  ///- macOS WKWebView ([Official API - URLError.cannotCloseFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883215-cannotclosefile))
  static final CANNOT_CLOSE_FILE = WebResourceErrorType._internalMultiPlatform(
    'CANNOT_CLOSE_FILE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -3002;
        case TargetPlatform.macOS:
          return -3002;
        default:
          break;
      }
      return null;
    },
  );

  ///Failed to connect to the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_CONNECT](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_CONNECT))
  ///- iOS WKWebView ([Official API - URLError.cannotConnectToHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883001-cannotconnecttohost))
  ///- macOS WKWebView ([Official API - URLError.cannotConnectToHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883001-cannotconnecttohost))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_CANNOT_CONNECT](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  ///- Linux WPE WebKit ([Official API - WEBKIT_NETWORK_ERROR_TRANSPORT](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.NetworkError.html))
  static final CANNOT_CONNECT_TO_HOST =
      WebResourceErrorType._internalMultiPlatform('CANNOT_CONNECT_TO_HOST', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return -6;
          case TargetPlatform.iOS:
            return -1004;
          case TargetPlatform.macOS:
            return -1004;
          case TargetPlatform.windows:
            return 12;
          case TargetPlatform.linux:
            return 300;
          default:
            break;
        }
        return null;
      });

  ///A download task couldn’t create the downloaded file on disk because of an I/O failure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotCreateFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883204-cannotcreatefile))
  ///- macOS WKWebView ([Official API - URLError.cannotCreateFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883204-cannotcreatefile))
  static final CANNOT_CREATE_FILE = WebResourceErrorType._internalMultiPlatform(
    'CANNOT_CREATE_FILE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -3000;
        case TargetPlatform.macOS:
          return -3000;
        default:
          break;
      }
      return null;
    },
  );

  ///Content data received during a connection request couldn’t be decoded for a known content encoding.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotDecodeContentData](https://developer.apple.com/documentation/foundation/urlerror/2292983-cannotdecodecontentdata))
  ///- macOS WKWebView ([Official API - URLError.cannotDecodeContentData](https://developer.apple.com/documentation/foundation/urlerror/2292983-cannotdecodecontentdata))
  static final CANNOT_DECODE_CONTENT_DATA =
      WebResourceErrorType._internalMultiPlatform(
        'CANNOT_DECODE_CONTENT_DATA',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1016;
            case TargetPlatform.macOS:
              return -1016;
            default:
              break;
          }
          return null;
        },
      );

  ///Content data received during a connection request couldn’t be decoded for a known content encoding.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotDecodeRawData](https://developer.apple.com/documentation/foundation/urlerror/2293573-cannotdecoderawdata))
  ///- macOS WKWebView ([Official API - URLError.cannotDecodeRawData](https://developer.apple.com/documentation/foundation/urlerror/2293573-cannotdecoderawdata))
  static final CANNOT_DECODE_RAW_DATA =
      WebResourceErrorType._internalMultiPlatform('CANNOT_DECODE_RAW_DATA', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            return -1015;
          case TargetPlatform.macOS:
            return -1015;
          default:
            break;
        }
        return null;
      });

  ///A request to load an item only from the cache could not be satisfied.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotLoadFromNetwork](https://developer.apple.com/documentation/foundation/urlerror/code/2882968-cannotloadfromnetwork))
  ///- macOS WKWebView ([Official API - URLError.cannotLoadFromNetwork](https://developer.apple.com/documentation/foundation/urlerror/code/2882968-cannotloadfromnetwork))
  static final CANNOT_LOAD_FROM_NETWORK =
      WebResourceErrorType._internalMultiPlatform(
        'CANNOT_LOAD_FROM_NETWORK',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -2000;
            case TargetPlatform.macOS:
              return -2000;
            default:
              break;
          }
          return null;
        },
      );

  ///A download task was unable to move a downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotMoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883180-cannotmovefile))
  ///- macOS WKWebView ([Official API - URLError.cannotMoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883180-cannotmovefile))
  static final CANNOT_MOVE_FILE = WebResourceErrorType._internalMultiPlatform(
    'CANNOT_MOVE_FILE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -3005;
        case TargetPlatform.macOS:
          return -3005;
        default:
          break;
      }
      return null;
    },
  );

  ///A download task was unable to open the downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotOpenFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883034-cannotopenfile))
  ///- macOS WKWebView ([Official API - URLError.cannotOpenFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883034-cannotopenfile))
  static final CANNOT_OPEN_FILE = WebResourceErrorType._internalMultiPlatform(
    'CANNOT_OPEN_FILE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -3001;
        case TargetPlatform.macOS:
          return -3001;
        default:
          break;
      }
      return null;
    },
  );

  ///A task could not parse a response.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotParseResponse](https://developer.apple.com/documentation/foundation/urlerror/code/2882919-cannotparseresponse))
  ///- macOS WKWebView ([Official API - URLError.cannotParseResponse](https://developer.apple.com/documentation/foundation/urlerror/code/2882919-cannotparseresponse))
  static final CANNOT_PARSE_RESPONSE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_PARSE_RESPONSE', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            return -1017;
          case TargetPlatform.macOS:
            return -1017;
          default:
            break;
        }
        return null;
      });

  ///A download task was unable to remove a downloaded file from disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotRemoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883202-cannotremovefile))
  ///- macOS WKWebView ([Official API - URLError.cannotRemoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883202-cannotremovefile))
  static final CANNOT_REMOVE_FILE = WebResourceErrorType._internalMultiPlatform(
    'CANNOT_REMOVE_FILE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -3004;
        case TargetPlatform.macOS:
          return -3004;
        default:
          break;
      }
      return null;
    },
  );

  ///The MIME type of the resource is not supported.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_POLICY_ERROR_CANNOT_SHOW_MIME_TYPE](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.PolicyError.html))
  static final CANNOT_SHOW_MIME_TYPE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_SHOW_MIME_TYPE', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.linux:
            return 100;
          default:
            break;
        }
        return null;
      });

  ///The URI cannot be shown.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_POLICY_ERROR_CANNOT_SHOW_URI](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.PolicyError.html))
  static final CANNOT_SHOW_URI = WebResourceErrorType._internalMultiPlatform(
    'CANNOT_SHOW_URI',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.linux:
          return 101;
        default:
          break;
      }
      return null;
    },
  );

  ///The port is restricted.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_POLICY_ERROR_CANNOT_USE_RESTRICTED_PORT](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.PolicyError.html))
  static final CANNOT_USE_RESTRICTED_PORT =
      WebResourceErrorType._internalMultiPlatform(
        'CANNOT_USE_RESTRICTED_PORT',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 103;
            default:
              break;
          }
          return null;
        },
      );

  ///A download task was unable to write to the downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.cannotWriteToFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883098-cannotwritetofile))
  ///- macOS WKWebView ([Official API - URLError.cannotWriteToFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883098-cannotwritetofile))
  static final CANNOT_WRITE_TO_FILE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_WRITE_TO_FILE', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            return -3003;
          case TargetPlatform.macOS:
            return -3003;
          default:
            break;
        }
        return null;
      });

  ///A server certificate was rejected.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.clientCertificateRejected](https://developer.apple.com/documentation/foundation/urlerror/code/2883091-clientcertificaterejected))
  ///- macOS WKWebView ([Official API - URLError.clientCertificateRejected](https://developer.apple.com/documentation/foundation/urlerror/code/2883091-clientcertificaterejected))
  static final CLIENT_CERTIFICATE_REJECTED =
      WebResourceErrorType._internalMultiPlatform(
        'CLIENT_CERTIFICATE_REJECTED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1205;
            case TargetPlatform.macOS:
              return -1205;
            default:
              break;
          }
          return null;
        },
      );

  ///A client certificate was required to authenticate an SSL connection during a request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.clientCertificateRequired](https://developer.apple.com/documentation/foundation/urlerror/code/2883199-clientcertificaterequired))
  ///- macOS WKWebView ([Official API - URLError.clientCertificateRequired](https://developer.apple.com/documentation/foundation/urlerror/code/2883199-clientcertificaterequired))
  static final CLIENT_CERTIFICATE_REQUIRED =
      WebResourceErrorType._internalMultiPlatform(
        'CLIENT_CERTIFICATE_REQUIRED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1206;
            case TargetPlatform.macOS:
              return -1206;
            default:
              break;
          }
          return null;
        },
      );

  ///Indicates that the connection was stopped.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_ABORTED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final CONNECTION_ABORTED = WebResourceErrorType._internalMultiPlatform(
    'CONNECTION_ABORTED',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 9;
        default:
          break;
      }
      return null;
    },
  );

  ///The length of the resource data exceeds the maximum allowed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.dataLengthExceedsMaximum](https://developer.apple.com/documentation/foundation/urlerror/code/2882930-datalengthexceedsmaximum))
  ///- macOS WKWebView ([Official API - URLError.dataLengthExceedsMaximum](https://developer.apple.com/documentation/foundation/urlerror/code/2882930-datalengthexceedsmaximum))
  static final DATA_LENGTH_EXCEEDS_MAXIMUM =
      WebResourceErrorType._internalMultiPlatform(
        'DATA_LENGTH_EXCEEDS_MAXIMUM',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1103;
            case TargetPlatform.macOS:
              return -1103;
            default:
              break;
          }
          return null;
        },
      );

  ///The cellular network disallowed a connection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.dataNotAllowed](https://developer.apple.com/documentation/foundation/urlerror/code/2883217-datanotallowed))
  ///- macOS WKWebView ([Official API - URLError.dataNotAllowed](https://developer.apple.com/documentation/foundation/urlerror/code/2883217-datanotallowed))
  static final DATA_NOT_ALLOWED = WebResourceErrorType._internalMultiPlatform(
    'DATA_NOT_ALLOWED',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -1020;
        case TargetPlatform.macOS:
          return -1020;
        default:
          break;
      }
      return null;
    },
  );

  ///Download was cancelled by user.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_DOWNLOAD_ERROR_CANCELLED_BY_USER](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.DownloadError.html))
  static final DOWNLOAD_CANCELLED_BY_USER =
      WebResourceErrorType._internalMultiPlatform(
        'DOWNLOAD_CANCELLED_BY_USER',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 400;
            default:
              break;
          }
          return null;
        },
      );

  ///A download task failed to decode an encoded file during the download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.downloadDecodingFailedMidStream](https://developer.apple.com/documentation/foundation/urlerror/code/2883224-downloaddecodingfailedmidstream))
  ///- macOS WKWebView ([Official API - URLError.downloadDecodingFailedMidStream](https://developer.apple.com/documentation/foundation/urlerror/code/2883224-downloaddecodingfailedmidstream))
  static final DOWNLOAD_DECODING_FAILED_MID_STREAM =
      WebResourceErrorType._internalMultiPlatform(
        'DOWNLOAD_DECODING_FAILED_MID_STREAM',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -3006;
            case TargetPlatform.macOS:
              return -3006;
            default:
              break;
          }
          return null;
        },
      );

  ///A download task failed to decode an encoded file after downloading.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.downloadDecodingFailedToComplete](https://developer.apple.com/documentation/foundation/urlerror/code/2882936-downloaddecodingfailedtocomplete))
  ///- macOS WKWebView ([Official API - URLError.downloadDecodingFailedToComplete](https://developer.apple.com/documentation/foundation/urlerror/code/2882936-downloaddecodingfailedtocomplete))
  static final DOWNLOAD_DECODING_FAILED_TO_COMPLETE =
      WebResourceErrorType._internalMultiPlatform(
        'DOWNLOAD_DECODING_FAILED_TO_COMPLETE',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -3007;
            case TargetPlatform.macOS:
              return -3007;
            default:
              break;
          }
          return null;
        },
      );

  ///Download failure due to destination error.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_DOWNLOAD_ERROR_DESTINATION](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.DownloadError.html))
  static final DOWNLOAD_DESTINATION_FAILED =
      WebResourceErrorType._internalMultiPlatform(
        'DOWNLOAD_DESTINATION_FAILED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 401;
            default:
              break;
          }
          return null;
        },
      );

  ///Download failure due to network error.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_DOWNLOAD_ERROR_NETWORK](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.DownloadError.html))
  static final DOWNLOAD_NETWORK_FAILED =
      WebResourceErrorType._internalMultiPlatform(
        'DOWNLOAD_NETWORK_FAILED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 499;
            default:
              break;
          }
          return null;
        },
      );

  ///Failed to perform SSL handshake.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_FAILED_SSL_HANDSHAKE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FAILED_SSL_HANDSHAKE))
  static final FAILED_SSL_HANDSHAKE =
      WebResourceErrorType._internalMultiPlatform('FAILED_SSL_HANDSHAKE', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return -11;
          default:
            break;
        }
        return null;
      });

  ///A request for an FTP file resulted in the server responding that the file is not a plain file, but a directory.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.fileIsDirectory](https://developer.apple.com/documentation/foundation/urlerror/code/2883220-fileisdirectory))
  ///- macOS WKWebView ([Official API - URLError.fileIsDirectory](https://developer.apple.com/documentation/foundation/urlerror/code/2883220-fileisdirectory))
  static final FILE_IS_DIRECTORY = WebResourceErrorType._internalMultiPlatform(
    'FILE_IS_DIRECTORY',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -1101;
        case TargetPlatform.macOS:
          return -1101;
        default:
          break;
      }
      return null;
    },
  );

  ///File not found.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_FILE_NOT_FOUND](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE_NOT_FOUND))
  ///- iOS WKWebView ([Official API - URLError.fileDoesNotExist](https://developer.apple.com/documentation/foundation/urlerror/code/2883074-filedoesnotexist))
  ///- macOS WKWebView ([Official API - URLError.fileDoesNotExist](https://developer.apple.com/documentation/foundation/urlerror/code/2883074-filedoesnotexist))
  ///- Linux WPE WebKit ([Official API - WEBKIT_NETWORK_ERROR_FILE_DOES_NOT_EXIST](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.NetworkError.html))
  static final FILE_NOT_FOUND = WebResourceErrorType._internalMultiPlatform(
    'FILE_NOT_FOUND',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -14;
        case TargetPlatform.iOS:
          return -1100;
        case TargetPlatform.macOS:
          return -1100;
        case TargetPlatform.linux:
          return 303;
        default:
          break;
      }
      return null;
    },
  );

  ///Frame load was interrupted by a policy change.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_POLICY_ERROR_FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.PolicyError.html))
  static final FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE =
      WebResourceErrorType._internalMultiPlatform(
        'FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 102;
            default:
              break;
          }
          return null;
        },
      );

  ///Generic file error.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_FILE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE))
  static final GENERIC_FILE_ERROR = WebResourceErrorType._internalMultiPlatform(
    'GENERIC_FILE_ERROR',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -13;
        default:
          break;
      }
      return null;
    },
  );

  ///Server or proxy hostname lookup failed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_HOST_LOOKUP](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_HOST_LOOKUP))
  ///- iOS WKWebView ([Official API - URLError.cannotFindHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883157-cannotfindhost))
  ///- macOS WKWebView ([Official API - URLError.cannotFindHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883157-cannotfindhost))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_HOST_NAME_NOT_RESOLVED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final HOST_LOOKUP = WebResourceErrorType._internalMultiPlatform(
    'HOST_LOOKUP',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -2;
        case TargetPlatform.iOS:
          return -1003;
        case TargetPlatform.macOS:
          return -1003;
        case TargetPlatform.windows:
          return 13;
        default:
          break;
      }
      return null;
    },
  );

  ///The attempted connection required activating a data context while roaming, but international roaming is disabled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.internationalRoamingOff](https://developer.apple.com/documentation/foundation/urlerror/code/2883134-internationalroamingoff))
  ///- macOS WKWebView ([Official API - URLError.internationalRoamingOff](https://developer.apple.com/documentation/foundation/urlerror/code/2883134-internationalroamingoff))
  static final INTERNATIONAL_ROAMING_OFF =
      WebResourceErrorType._internalMultiPlatform(
        'INTERNATIONAL_ROAMING_OFF',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1018;
            case TargetPlatform.macOS:
              return -1018;
            default:
              break;
          }
          return null;
        },
      );

  ///Failed to read or write to the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_IO](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_IO))
  static final IO = WebResourceErrorType._internalMultiPlatform('IO', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -7;
      default:
        break;
    }
    return null;
  });

  ///A client or server connection was severed in the middle of an in-progress load.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.networkConnectionLost](https://developer.apple.com/documentation/foundation/urlerror/2293759-networkconnectionlost))
  ///- macOS WKWebView ([Official API - URLError.networkConnectionLost](https://developer.apple.com/documentation/foundation/urlerror/2293759-networkconnectionlost))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_DISCONNECTED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final NETWORK_CONNECTION_LOST =
      WebResourceErrorType._internalMultiPlatform(
        'NETWORK_CONNECTION_LOST',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1005;
            case TargetPlatform.macOS:
              return -1005;
            case TargetPlatform.windows:
              return 11;
            default:
              break;
          }
          return null;
        },
      );

  ///A network resource was requested, but an internet connection hasn’t been established and can’t be established automatically.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.notConnectedToInternet](https://developer.apple.com/documentation/foundation/urlerror/2293104-notconnectedtointernet))
  ///- macOS WKWebView ([Official API - URLError.notConnectedToInternet](https://developer.apple.com/documentation/foundation/urlerror/2293104-notconnectedtointernet))
  static final NOT_CONNECTED_TO_INTERNET =
      WebResourceErrorType._internalMultiPlatform(
        'NOT_CONNECTED_TO_INTERNET',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1009;
            case TargetPlatform.macOS:
              return -1009;
            default:
              break;
          }
          return null;
        },
      );

  ///A resource couldn’t be read because of insufficient permissions.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.noPermissionsToReadFile](https://developer.apple.com/documentation/foundation/urlerror/code/2882941-nopermissionstoreadfile))
  ///- macOS WKWebView ([Official API - URLError.noPermissionsToReadFile](https://developer.apple.com/documentation/foundation/urlerror/code/2882941-nopermissionstoreadfile))
  static final NO_PERMISSIONS_TO_READ_FILE =
      WebResourceErrorType._internalMultiPlatform(
        'NO_PERMISSIONS_TO_READ_FILE',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1102;
            case TargetPlatform.macOS:
              return -1102;
            default:
              break;
          }
          return null;
        },
      );

  ///Generic policy error.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_POLICY_ERROR_FAILED](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.PolicyError.html))
  static final POLICY_FAILED = WebResourceErrorType._internalMultiPlatform(
    'POLICY_FAILED',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.linux:
          return 199;
        default:
          break;
      }
      return null;
    },
  );

  ///User authentication failed on proxy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_PROXY_AUTHENTICATION](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_PROXY_AUTHENTICATION))
  static final PROXY_AUTHENTICATION =
      WebResourceErrorType._internalMultiPlatform('PROXY_AUTHENTICATION', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return -5;
          default:
            break;
        }
        return null;
      });

  ///Indicates that the request redirect failed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_REDIRECT_FAILED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final REDIRECT_FAILED = WebResourceErrorType._internalMultiPlatform(
    'REDIRECT_FAILED',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 15;
        default:
          break;
      }
      return null;
    },
  );

  ///A redirect was specified by way of server response code, but the server didn’t accompany this code with a redirect URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.redirectToNonExistentLocation](https://developer.apple.com/documentation/foundation/urlerror/2293066-redirecttononexistentlocation))
  ///- macOS WKWebView ([Official API - URLError.redirectToNonExistentLocation](https://developer.apple.com/documentation/foundation/urlerror/2293066-redirecttononexistentlocation))
  static final REDIRECT_TO_NON_EXISTENT_LOCATION =
      WebResourceErrorType._internalMultiPlatform(
        'REDIRECT_TO_NON_EXISTENT_LOCATION',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1010;
            case TargetPlatform.macOS:
              return -1010;
            default:
              break;
          }
          return null;
        },
      );

  ///A body stream is needed but the client did not provide one.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.requestBodyStreamExhausted](https://developer.apple.com/documentation/foundation/urlerror/code/2883176-requestbodystreamexhausted))
  ///- macOS WKWebView ([Official API - URLError.requestBodyStreamExhausted](https://developer.apple.com/documentation/foundation/urlerror/code/2883176-requestbodystreamexhausted))
  static final REQUEST_BODY_STREAM_EXHAUSTED =
      WebResourceErrorType._internalMultiPlatform(
        'REQUEST_BODY_STREAM_EXHAUSTED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1021;
            case TargetPlatform.macOS:
              return -1021;
            default:
              break;
          }
          return null;
        },
      );

  ///Indicates that the connection was reset.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_RESET](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final RESET = WebResourceErrorType._internalMultiPlatform('RESET', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 10;
      default:
        break;
    }
    return null;
  });

  ///A requested resource couldn't be retrieved.
  ///This error can indicate a file-not-found situation, or decoding problems that prevent data from being processed correctly.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.resourceUnavailable](https://developer.apple.com/documentation/foundation/urlerror/2293555-resourceunavailable))
  ///- macOS WKWebView ([Official API - URLError.resourceUnavailable](https://developer.apple.com/documentation/foundation/urlerror/2293555-resourceunavailable))
  static final RESOURCE_UNAVAILABLE =
      WebResourceErrorType._internalMultiPlatform('RESOURCE_UNAVAILABLE', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            return -1008;
          case TargetPlatform.macOS:
            return -1008;
          default:
            break;
        }
        return null;
      });

  ///An attempt to establish a secure connection failed for reasons that can’t be expressed more specifically.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.secureConnectionFailed](https://developer.apple.com/documentation/foundation/urlerror/code/2883122-secureconnectionfailed))
  ///- macOS WKWebView ([Official API - URLError.secureConnectionFailed](https://developer.apple.com/documentation/foundation/urlerror/code/2883122-secureconnectionfailed))
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_INSECURE](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final SECURE_CONNECTION_FAILED =
      WebResourceErrorType._internalMultiPlatform(
        'SECURE_CONNECTION_FAILED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1200;
            case TargetPlatform.macOS:
              return -1200;
            case TargetPlatform.linux:
              return 32;
            default:
              break;
          }
          return null;
        },
      );

  ///The certificate does not match the expected identity of the site.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_BAD_IDENTITY](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final SERVER_CERTIFICATE_BAD_IDENTITY =
      WebResourceErrorType._internalMultiPlatform(
        'SERVER_CERTIFICATE_BAD_IDENTITY',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 2;
            default:
              break;
          }
          return null;
        },
      );

  ///A server certificate had a date which indicates it has expired, or is not yet valid.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.serverCertificateHasBadDate](https://developer.apple.com/documentation/foundation/urlerror/code/2883088-servercertificatehasbaddate))
  ///- macOS WKWebView ([Official API - URLError.serverCertificateHasBadDate](https://developer.apple.com/documentation/foundation/urlerror/code/2883088-servercertificatehasbaddate))
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_EXPIRED](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final SERVER_CERTIFICATE_HAS_BAD_DATE =
      WebResourceErrorType._internalMultiPlatform(
        'SERVER_CERTIFICATE_HAS_BAD_DATE',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1201;
            case TargetPlatform.macOS:
              return -1201;
            case TargetPlatform.linux:
              return 8;
            default:
              break;
          }
          return null;
        },
      );

  ///A server certificate was not signed by any root server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.serverCertificateHasUnknownRoot](https://developer.apple.com/documentation/foundation/urlerror/code/2883085-servercertificatehasunknownroot))
  ///- macOS WKWebView ([Official API - URLError.serverCertificateHasUnknownRoot](https://developer.apple.com/documentation/foundation/urlerror/code/2883085-servercertificatehasunknownroot))
  static final SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT =
      WebResourceErrorType._internalMultiPlatform(
        'SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1203;
            case TargetPlatform.macOS:
              return -1203;
            default:
              break;
          }
          return null;
        },
      );

  ///A server certificate is not yet valid.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.serverCertificateNotYetValid](https://developer.apple.com/documentation/foundation/urlerror/code/2882991-servercertificatenotyetvalid))
  ///- macOS WKWebView ([Official API - URLError.serverCertificateNotYetValid](https://developer.apple.com/documentation/foundation/urlerror/code/2882991-servercertificatenotyetvalid))
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_NOT_ACTIVATED](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final SERVER_CERTIFICATE_NOT_YET_VALID =
      WebResourceErrorType._internalMultiPlatform(
        'SERVER_CERTIFICATE_NOT_YET_VALID',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1204;
            case TargetPlatform.macOS:
              return -1204;
            case TargetPlatform.linux:
              return 4;
            default:
              break;
          }
          return null;
        },
      );

  ///The certificate has been revoked.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_REVOKED](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final SERVER_CERTIFICATE_REVOKED =
      WebResourceErrorType._internalMultiPlatform(
        'SERVER_CERTIFICATE_REVOKED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 16;
            default:
              break;
          }
          return null;
        },
      );

  ///A server certificate was signed by a root server that isn’t trusted.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.serverCertificateUntrusted](https://developer.apple.com/documentation/foundation/urlerror/code/2882976-servercertificateuntrusted))
  ///- macOS WKWebView ([Official API - URLError.serverCertificateUntrusted](https://developer.apple.com/documentation/foundation/urlerror/code/2882976-servercertificateuntrusted))
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_UNKNOWN_CA](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final SERVER_CERTIFICATE_UNTRUSTED =
      WebResourceErrorType._internalMultiPlatform(
        'SERVER_CERTIFICATE_UNTRUSTED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1202;
            case TargetPlatform.macOS:
              return -1202;
            case TargetPlatform.linux:
              return 1;
            default:
              break;
          }
          return null;
        },
      );

  ///Indicates that the host is unreachable.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_SERVER_UNREACHABLE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final SERVER_UNREACHABLE = WebResourceErrorType._internalMultiPlatform(
    'SERVER_UNREACHABLE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 6;
        default:
          break;
      }
      return null;
    },
  );

  ///Connection timed out.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_TIMEOUT](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TIMEOUT))
  ///- iOS WKWebView ([Official API - URLError.timedOut](https://developer.apple.com/documentation/foundation/urlerror/code/2883027-timedout))
  ///- macOS WKWebView ([Official API - URLError.timedOut](https://developer.apple.com/documentation/foundation/urlerror/code/2883027-timedout))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_TIMEOUT](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final TIMEOUT = WebResourceErrorType._internalMultiPlatform(
    'TIMEOUT',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -8;
        case TargetPlatform.iOS:
          return -1001;
        case TargetPlatform.macOS:
          return -1001;
        case TargetPlatform.windows:
          return 7;
        default:
          break;
      }
      return null;
    },
  );

  ///Some other error occurred validating the certificate.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - G_TLS_CERTIFICATE_GENERIC_ERROR](https://docs.gtk.org/gio/flags.TlsCertificateFlags.html))
  static final TLS_CERTIFICATE_GENERIC_ERROR =
      WebResourceErrorType._internalMultiPlatform(
        'TLS_CERTIFICATE_GENERIC_ERROR',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.linux:
              return 64;
            default:
              break;
          }
          return null;
        },
      );

  ///A redirect loop has been detected or the threshold for number of allowable redirects has been exceeded (currently `16` on iOS).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_REDIRECT_LOOP](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_REDIRECT_LOOP))
  ///- iOS WKWebView ([Official API - URLError.httpTooManyRedirects](https://developer.apple.com/documentation/foundation/urlerror/code/2883099-httptoomanyredirects))
  ///- macOS WKWebView ([Official API - URLError.httpTooManyRedirects](https://developer.apple.com/documentation/foundation/urlerror/code/2883099-httptoomanyredirects))
  static final TOO_MANY_REDIRECTS = WebResourceErrorType._internalMultiPlatform(
    'TOO_MANY_REDIRECTS',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -9;
        case TargetPlatform.iOS:
          return -1007;
        case TargetPlatform.macOS:
          return -1007;
        default:
          break;
      }
      return null;
    },
  );

  ///Too many requests during this load.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_TOO_MANY_REQUESTS](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TOO_MANY_REQUESTS))
  static final TOO_MANY_REQUESTS = WebResourceErrorType._internalMultiPlatform(
    'TOO_MANY_REQUESTS',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -15;
        default:
          break;
      }
      return null;
    },
  );

  ///Indicates that an unexpected error occurred.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_UNEXPECTED_ERROR](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final UNEXPECTED_ERROR = WebResourceErrorType._internalMultiPlatform(
    'UNEXPECTED_ERROR',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 16;
        default:
          break;
      }
      return null;
    },
  );

  ///The URL Loading System encountered an error that it can’t interpret.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_UNKNOWN](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNKNOWN))
  ///- iOS WKWebView ([Official API - URLError.unknown](https://developer.apple.com/documentation/foundation/urlerror/2293357-unknown))
  ///- macOS WKWebView ([Official API - URLError.unknown](https://developer.apple.com/documentation/foundation/urlerror/2293357-unknown))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_UNKNOWN](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  ///- Linux WPE WebKit ([Official API - WEBKIT_NETWORK_ERROR_FAILED](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.NetworkError.html))
  static final UNKNOWN = WebResourceErrorType._internalMultiPlatform(
    'UNKNOWN',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -1;
        case TargetPlatform.iOS:
          return -1;
        case TargetPlatform.macOS:
          return -1;
        case TargetPlatform.windows:
          return 0;
        case TargetPlatform.linux:
          return 399;
        default:
          break;
      }
      return null;
    },
  );

  ///Resource load was canceled by Safe Browsing.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_UNSAFE_RESOURCE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSAFE_RESOURCE))
  static final UNSAFE_RESOURCE = WebResourceErrorType._internalMultiPlatform(
    'UNSAFE_RESOURCE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -16;
        default:
          break;
      }
      return null;
    },
  );

  ///Unsupported authentication scheme (not basic or digest).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_UNSUPPORTED_AUTH_SCHEME](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_AUTH_SCHEME))
  static final UNSUPPORTED_AUTH_SCHEME =
      WebResourceErrorType._internalMultiPlatform(
        'UNSUPPORTED_AUTH_SCHEME',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.android:
              return -3;
            default:
              break;
          }
          return null;
        },
      );

  ///Unsupported URI scheme.
  ///Typically this occurs when there is no available protocol handler for the URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_UNSUPPORTED_SCHEME](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_SCHEME))
  ///- iOS WKWebView ([Official API - URLError.unsupportedURL](https://developer.apple.com/documentation/foundation/urlerror/code/2883043-unsupportedurl))
  ///- macOS WKWebView ([Official API - URLError.unsupportedURL](https://developer.apple.com/documentation/foundation/urlerror/code/2883043-unsupportedurl))
  ///- Linux WPE WebKit ([Official API - WEBKIT_NETWORK_ERROR_UNKNOWN_PROTOCOL](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/error.NetworkError.html))
  static final UNSUPPORTED_SCHEME = WebResourceErrorType._internalMultiPlatform(
    'UNSUPPORTED_SCHEME',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return -10;
        case TargetPlatform.iOS:
          return -1002;
        case TargetPlatform.macOS:
          return -1002;
        case TargetPlatform.linux:
          return 301;
        default:
          break;
      }
      return null;
    },
  );

  ///User authentication failed on server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewClient.ERROR_AUTHENTICATION](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_AUTHENTICATION))
  static final USER_AUTHENTICATION_FAILED =
      WebResourceErrorType._internalMultiPlatform(
        'USER_AUTHENTICATION_FAILED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.android:
              return -4;
            default:
              break;
          }
          return null;
        },
      );

  ///Authentication is required to access a resource.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.userAuthenticationRequired](https://developer.apple.com/documentation/foundation/urlerror/2293560-userauthenticationrequired))
  ///- macOS WKWebView ([Official API - URLError.userAuthenticationRequired](https://developer.apple.com/documentation/foundation/urlerror/2293560-userauthenticationrequired))
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_VALID_AUTHENTICATION_CREDENTIALS_REQUIRED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final USER_AUTHENTICATION_REQUIRED =
      WebResourceErrorType._internalMultiPlatform(
        'USER_AUTHENTICATION_REQUIRED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1013;
            case TargetPlatform.macOS:
              return -1013;
            case TargetPlatform.windows:
              return 17;
            default:
              break;
          }
          return null;
        },
      );

  ///An asynchronous request for authentication has been canceled by the user.
  ///This error typically occurs when a user clicks a "Cancel" button in a username/password dialog, rather than attempting to authenticate.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.userCancelledAuthentication](https://developer.apple.com/documentation/foundation/urlerror/2293330-usercancelledauthentication))
  ///- macOS WKWebView ([Official API - URLError.userCancelledAuthentication](https://developer.apple.com/documentation/foundation/urlerror/2293330-usercancelledauthentication))
  static final USER_CANCELLED_AUTHENTICATION =
      WebResourceErrorType._internalMultiPlatform(
        'USER_CANCELLED_AUTHENTICATION',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return -1012;
            case TargetPlatform.macOS:
              return -1012;
            default:
              break;
          }
          return null;
        },
      );

  ///Indicates that user lacks proper authentication credentials for a proxy server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_VALID_PROXY_AUTHENTICATION_REQUIRED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final VALID_PROXY_AUTHENTICATION_REQUIRED =
      WebResourceErrorType._internalMultiPlatform(
        'VALID_PROXY_AUTHENTICATION_REQUIRED',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.windows:
              return 18;
            default:
              break;
          }
          return null;
        },
      );

  ///A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - URLError.zeroByteResource](https://developer.apple.com/documentation/foundation/urlerror/2293773-zerobyteresource))
  ///- macOS WKWebView ([Official API - URLError.zeroByteResource](https://developer.apple.com/documentation/foundation/urlerror/2293773-zerobyteresource))
  static final ZERO_BYTE_RESOURCE = WebResourceErrorType._internalMultiPlatform(
    'ZERO_BYTE_RESOURCE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return -1014;
        case TargetPlatform.macOS:
          return -1014;
        default:
          break;
      }
      return null;
    },
  );

  ///Set of all values of [WebResourceErrorType].
  static final Set<WebResourceErrorType> values = [
    WebResourceErrorType.APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION,
    WebResourceErrorType.BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS,
    WebResourceErrorType.BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER,
    WebResourceErrorType.BACKGROUND_SESSION_WAS_DISCONNECTED,
    WebResourceErrorType.BAD_SERVER_RESPONSE,
    WebResourceErrorType.BAD_URL,
    WebResourceErrorType.CALL_IS_ACTIVE,
    WebResourceErrorType.CANCELLED,
    WebResourceErrorType.CANNOT_CLOSE_FILE,
    WebResourceErrorType.CANNOT_CONNECT_TO_HOST,
    WebResourceErrorType.CANNOT_CREATE_FILE,
    WebResourceErrorType.CANNOT_DECODE_CONTENT_DATA,
    WebResourceErrorType.CANNOT_DECODE_RAW_DATA,
    WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK,
    WebResourceErrorType.CANNOT_MOVE_FILE,
    WebResourceErrorType.CANNOT_OPEN_FILE,
    WebResourceErrorType.CANNOT_PARSE_RESPONSE,
    WebResourceErrorType.CANNOT_REMOVE_FILE,
    WebResourceErrorType.CANNOT_SHOW_MIME_TYPE,
    WebResourceErrorType.CANNOT_SHOW_URI,
    WebResourceErrorType.CANNOT_USE_RESTRICTED_PORT,
    WebResourceErrorType.CANNOT_WRITE_TO_FILE,
    WebResourceErrorType.CLIENT_CERTIFICATE_REJECTED,
    WebResourceErrorType.CLIENT_CERTIFICATE_REQUIRED,
    WebResourceErrorType.CONNECTION_ABORTED,
    WebResourceErrorType.DATA_LENGTH_EXCEEDS_MAXIMUM,
    WebResourceErrorType.DATA_NOT_ALLOWED,
    WebResourceErrorType.DOWNLOAD_CANCELLED_BY_USER,
    WebResourceErrorType.DOWNLOAD_DECODING_FAILED_MID_STREAM,
    WebResourceErrorType.DOWNLOAD_DECODING_FAILED_TO_COMPLETE,
    WebResourceErrorType.DOWNLOAD_DESTINATION_FAILED,
    WebResourceErrorType.DOWNLOAD_NETWORK_FAILED,
    WebResourceErrorType.FAILED_SSL_HANDSHAKE,
    WebResourceErrorType.FILE_IS_DIRECTORY,
    WebResourceErrorType.FILE_NOT_FOUND,
    WebResourceErrorType.FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE,
    WebResourceErrorType.GENERIC_FILE_ERROR,
    WebResourceErrorType.HOST_LOOKUP,
    WebResourceErrorType.INTERNATIONAL_ROAMING_OFF,
    WebResourceErrorType.IO,
    WebResourceErrorType.NETWORK_CONNECTION_LOST,
    WebResourceErrorType.NOT_CONNECTED_TO_INTERNET,
    WebResourceErrorType.NO_PERMISSIONS_TO_READ_FILE,
    WebResourceErrorType.POLICY_FAILED,
    WebResourceErrorType.PROXY_AUTHENTICATION,
    WebResourceErrorType.REDIRECT_FAILED,
    WebResourceErrorType.REDIRECT_TO_NON_EXISTENT_LOCATION,
    WebResourceErrorType.REQUEST_BODY_STREAM_EXHAUSTED,
    WebResourceErrorType.RESET,
    WebResourceErrorType.RESOURCE_UNAVAILABLE,
    WebResourceErrorType.SECURE_CONNECTION_FAILED,
    WebResourceErrorType.SERVER_CERTIFICATE_BAD_IDENTITY,
    WebResourceErrorType.SERVER_CERTIFICATE_HAS_BAD_DATE,
    WebResourceErrorType.SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT,
    WebResourceErrorType.SERVER_CERTIFICATE_NOT_YET_VALID,
    WebResourceErrorType.SERVER_CERTIFICATE_REVOKED,
    WebResourceErrorType.SERVER_CERTIFICATE_UNTRUSTED,
    WebResourceErrorType.SERVER_UNREACHABLE,
    WebResourceErrorType.TIMEOUT,
    WebResourceErrorType.TLS_CERTIFICATE_GENERIC_ERROR,
    WebResourceErrorType.TOO_MANY_REDIRECTS,
    WebResourceErrorType.TOO_MANY_REQUESTS,
    WebResourceErrorType.UNEXPECTED_ERROR,
    WebResourceErrorType.UNKNOWN,
    WebResourceErrorType.UNSAFE_RESOURCE,
    WebResourceErrorType.UNSUPPORTED_AUTH_SCHEME,
    WebResourceErrorType.UNSUPPORTED_SCHEME,
    WebResourceErrorType.USER_AUTHENTICATION_FAILED,
    WebResourceErrorType.USER_AUTHENTICATION_REQUIRED,
    WebResourceErrorType.USER_CANCELLED_AUTHENTICATION,
    WebResourceErrorType.VALID_PROXY_AUTHENTICATION_REQUIRED,
    WebResourceErrorType.ZERO_BYTE_RESOURCE,
  ].toSet();

  ///Gets a possible [WebResourceErrorType] instance from [String] value.
  static WebResourceErrorType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebResourceErrorType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebResourceErrorType] instance from a native value.
  static WebResourceErrorType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebResourceErrorType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebResourceErrorType] instance value with name [name].
  ///
  /// Goes through [WebResourceErrorType.values] looking for a value with
  /// name [name], as reported by [WebResourceErrorType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebResourceErrorType? byName(String? name) {
    if (name != null) {
      try {
        return WebResourceErrorType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebResourceErrorType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebResourceErrorType> asNameMap() =>
      <String, WebResourceErrorType>{
        for (final value in WebResourceErrorType.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION':
        return 'APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION';
      case 'BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS':
        return 'BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS';
      case 'BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER':
        return 'BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER';
      case 'BACKGROUND_SESSION_WAS_DISCONNECTED':
        return 'BACKGROUND_SESSION_WAS_DISCONNECTED';
      case 'BAD_SERVER_RESPONSE':
        return 'BAD_SERVER_RESPONSE';
      case 'BAD_URL':
        return 'BAD_URL';
      case 'CALL_IS_ACTIVE':
        return 'CALL_IS_ACTIVE';
      case 'CANCELLED':
        return 'CANCELLED';
      case 'CANNOT_CLOSE_FILE':
        return 'CANNOT_CLOSE_FILE';
      case 'CANNOT_CONNECT_TO_HOST':
        return 'CANNOT_CONNECT_TO_HOST';
      case 'CANNOT_CREATE_FILE':
        return 'CANNOT_CREATE_FILE';
      case 'CANNOT_DECODE_CONTENT_DATA':
        return 'CANNOT_DECODE_CONTENT_DATA';
      case 'CANNOT_DECODE_RAW_DATA':
        return 'CANNOT_DECODE_RAW_DATA';
      case 'CANNOT_LOAD_FROM_NETWORK':
        return 'CANNOT_LOAD_FROM_NETWORK';
      case 'CANNOT_MOVE_FILE':
        return 'CANNOT_MOVE_FILE';
      case 'CANNOT_OPEN_FILE':
        return 'CANNOT_OPEN_FILE';
      case 'CANNOT_PARSE_RESPONSE':
        return 'CANNOT_PARSE_RESPONSE';
      case 'CANNOT_REMOVE_FILE':
        return 'CANNOT_REMOVE_FILE';
      case 'CANNOT_SHOW_MIME_TYPE':
        return 'CANNOT_SHOW_MIME_TYPE';
      case 'CANNOT_SHOW_URI':
        return 'CANNOT_SHOW_URI';
      case 'CANNOT_USE_RESTRICTED_PORT':
        return 'CANNOT_USE_RESTRICTED_PORT';
      case 'CANNOT_WRITE_TO_FILE':
        return 'CANNOT_WRITE_TO_FILE';
      case 'CLIENT_CERTIFICATE_REJECTED':
        return 'CLIENT_CERTIFICATE_REJECTED';
      case 'CLIENT_CERTIFICATE_REQUIRED':
        return 'CLIENT_CERTIFICATE_REQUIRED';
      case 'CONNECTION_ABORTED':
        return 'CONNECTION_ABORTED';
      case 'DATA_LENGTH_EXCEEDS_MAXIMUM':
        return 'DATA_LENGTH_EXCEEDS_MAXIMUM';
      case 'DATA_NOT_ALLOWED':
        return 'DATA_NOT_ALLOWED';
      case 'DOWNLOAD_CANCELLED_BY_USER':
        return 'DOWNLOAD_CANCELLED_BY_USER';
      case 'DOWNLOAD_DECODING_FAILED_MID_STREAM':
        return 'DOWNLOAD_DECODING_FAILED_MID_STREAM';
      case 'DOWNLOAD_DECODING_FAILED_TO_COMPLETE':
        return 'DOWNLOAD_DECODING_FAILED_TO_COMPLETE';
      case 'DOWNLOAD_DESTINATION_FAILED':
        return 'DOWNLOAD_DESTINATION_FAILED';
      case 'DOWNLOAD_NETWORK_FAILED':
        return 'DOWNLOAD_NETWORK_FAILED';
      case 'FAILED_SSL_HANDSHAKE':
        return 'FAILED_SSL_HANDSHAKE';
      case 'FILE_IS_DIRECTORY':
        return 'FILE_IS_DIRECTORY';
      case 'FILE_NOT_FOUND':
        return 'FILE_NOT_FOUND';
      case 'FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE':
        return 'FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE';
      case 'GENERIC_FILE_ERROR':
        return 'GENERIC_FILE_ERROR';
      case 'HOST_LOOKUP':
        return 'HOST_LOOKUP';
      case 'INTERNATIONAL_ROAMING_OFF':
        return 'INTERNATIONAL_ROAMING_OFF';
      case 'IO':
        return 'IO';
      case 'NETWORK_CONNECTION_LOST':
        return 'NETWORK_CONNECTION_LOST';
      case 'NOT_CONNECTED_TO_INTERNET':
        return 'NOT_CONNECTED_TO_INTERNET';
      case 'NO_PERMISSIONS_TO_READ_FILE':
        return 'NO_PERMISSIONS_TO_READ_FILE';
      case 'POLICY_FAILED':
        return 'POLICY_FAILED';
      case 'PROXY_AUTHENTICATION':
        return 'PROXY_AUTHENTICATION';
      case 'REDIRECT_FAILED':
        return 'REDIRECT_FAILED';
      case 'REDIRECT_TO_NON_EXISTENT_LOCATION':
        return 'REDIRECT_TO_NON_EXISTENT_LOCATION';
      case 'REQUEST_BODY_STREAM_EXHAUSTED':
        return 'REQUEST_BODY_STREAM_EXHAUSTED';
      case 'RESET':
        return 'RESET';
      case 'RESOURCE_UNAVAILABLE':
        return 'RESOURCE_UNAVAILABLE';
      case 'SECURE_CONNECTION_FAILED':
        return 'SECURE_CONNECTION_FAILED';
      case 'SERVER_CERTIFICATE_BAD_IDENTITY':
        return 'SERVER_CERTIFICATE_BAD_IDENTITY';
      case 'SERVER_CERTIFICATE_HAS_BAD_DATE':
        return 'SERVER_CERTIFICATE_HAS_BAD_DATE';
      case 'SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT':
        return 'SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT';
      case 'SERVER_CERTIFICATE_NOT_YET_VALID':
        return 'SERVER_CERTIFICATE_NOT_YET_VALID';
      case 'SERVER_CERTIFICATE_REVOKED':
        return 'SERVER_CERTIFICATE_REVOKED';
      case 'SERVER_CERTIFICATE_UNTRUSTED':
        return 'SERVER_CERTIFICATE_UNTRUSTED';
      case 'SERVER_UNREACHABLE':
        return 'SERVER_UNREACHABLE';
      case 'TIMEOUT':
        return 'TIMEOUT';
      case 'TLS_CERTIFICATE_GENERIC_ERROR':
        return 'TLS_CERTIFICATE_GENERIC_ERROR';
      case 'TOO_MANY_REDIRECTS':
        return 'TOO_MANY_REDIRECTS';
      case 'TOO_MANY_REQUESTS':
        return 'TOO_MANY_REQUESTS';
      case 'UNEXPECTED_ERROR':
        return 'UNEXPECTED_ERROR';
      case 'UNKNOWN':
        return 'UNKNOWN';
      case 'UNSAFE_RESOURCE':
        return 'UNSAFE_RESOURCE';
      case 'UNSUPPORTED_AUTH_SCHEME':
        return 'UNSUPPORTED_AUTH_SCHEME';
      case 'UNSUPPORTED_SCHEME':
        return 'UNSUPPORTED_SCHEME';
      case 'USER_AUTHENTICATION_FAILED':
        return 'USER_AUTHENTICATION_FAILED';
      case 'USER_AUTHENTICATION_REQUIRED':
        return 'USER_AUTHENTICATION_REQUIRED';
      case 'USER_CANCELLED_AUTHENTICATION':
        return 'USER_CANCELLED_AUTHENTICATION';
      case 'VALID_PROXY_AUTHENTICATION_REQUIRED':
        return 'VALID_PROXY_AUTHENTICATION_REQUIRED';
      case 'ZERO_BYTE_RESOURCE':
        return 'ZERO_BYTE_RESOURCE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return _value;
  }
}
