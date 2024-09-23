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
          String value, Function nativeValue) =>
      WebResourceErrorType._internal(value, nativeValue());

  ///App Transport Security disallowed a connection because there is no secure network connection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.appTransportSecurityRequiresSecureConnection](https://developer.apple.com/documentation/foundation/urlerror/code/2882980-apptransportsecurityrequiressecu))
  ///- MacOS ([Official API - URLError.appTransportSecurityRequiresSecureConnection](https://developer.apple.com/documentation/foundation/urlerror/code/2882980-apptransportsecurityrequiressecu))
  static final APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION =
      WebResourceErrorType._internalMultiPlatform(
          'APP_TRANSPORT_SECURITY_REQUIRES_SECURE_CONNECTION', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1022;
      case TargetPlatform.macOS:
        return -1022;
      default:
        break;
    }
    return null;
  });

  ///An app or app extension attempted to connect to a background session that is already connected to a process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.backgroundSessionInUseByAnotherProcess](https://developer.apple.com/documentation/foundation/urlerror/code/2882923-backgroundsessioninusebyanotherp))
  ///- MacOS ([Official API - URLError.backgroundSessionInUseByAnotherProcess](https://developer.apple.com/documentation/foundation/urlerror/code/2882923-backgroundsessioninusebyanotherp))
  static final BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS =
      WebResourceErrorType._internalMultiPlatform(
          'BACKGROUND_SESSION_IN_USE_BY_ANOTHER_PROCESS', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -996;
      case TargetPlatform.macOS:
        return -996;
      default:
        break;
    }
    return null;
  });

  ///The shared container identifier of the URL session configuration is needed but has not been set.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.backgroundSessionRequiresSharedContainer](https://developer.apple.com/documentation/foundation/urlerror/code/2883169-backgroundsessionrequiressharedc))
  ///- MacOS ([Official API - URLError.backgroundSessionRequiresSharedContainer](https://developer.apple.com/documentation/foundation/urlerror/code/2883169-backgroundsessionrequiressharedc))
  static final BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER =
      WebResourceErrorType._internalMultiPlatform(
          'BACKGROUND_SESSION_REQUIRES_SHARED_CONTAINER', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -995;
      case TargetPlatform.macOS:
        return -995;
      default:
        break;
    }
    return null;
  });

  ///The app is suspended or exits while a background data task is processing.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.backgroundSessionWasDisconnected](https://developer.apple.com/documentation/foundation/urlerror/code/2883075-backgroundsessionwasdisconnected))
  ///- MacOS ([Official API - URLError.backgroundSessionWasDisconnected](https://developer.apple.com/documentation/foundation/urlerror/code/2883075-backgroundsessionwasdisconnected))
  static final BACKGROUND_SESSION_WAS_DISCONNECTED =
      WebResourceErrorType._internalMultiPlatform(
          'BACKGROUND_SESSION_WAS_DISCONNECTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -997;
      case TargetPlatform.macOS:
        return -997;
      default:
        break;
    }
    return null;
  });

  ///The URL Loading System received bad data from the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.badServerResponse](https://developer.apple.com/documentation/foundation/urlerror/2293606-badserverresponse))
  ///- MacOS ([Official API - URLError.badServerResponse](https://developer.apple.com/documentation/foundation/urlerror/2293606-badserverresponse))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_ERROR_HTTP_INVALID_SERVER_RESPONSE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
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
  ///- Android native WebView ([Official API - WebViewClient.ERROR_BAD_URL](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_BAD_URL))
  ///- iOS ([Official API - URLError.badURL](https://developer.apple.com/documentation/foundation/urlerror/2293516-badurl))
  ///- MacOS ([Official API - URLError.badURL](https://developer.apple.com/documentation/foundation/urlerror/2293516-badurl))
  static final BAD_URL =
      WebResourceErrorType._internalMultiPlatform('BAD_URL', () {
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
  });

  ///A connection was attempted while a phone call is active on a network that does not support simultaneous phone and data communication (EDGE or GPRS).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.callIsActive](https://developer.apple.com/documentation/foundation/urlerror/code/2883170-callisactive))
  ///- MacOS ([Official API - URLError.callIsActive](https://developer.apple.com/documentation/foundation/urlerror/code/2883170-callisactive))
  static final CALL_IS_ACTIVE =
      WebResourceErrorType._internalMultiPlatform('CALL_IS_ACTIVE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1019;
      case TargetPlatform.macOS:
        return -1019;
      default:
        break;
    }
    return null;
  });

  ///An asynchronous load has been canceled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cancelled](https://developer.apple.com/documentation/foundation/urlerror/code/2883178-cancelled))
  ///- MacOS ([Official API - URLError.cancelled](https://developer.apple.com/documentation/foundation/urlerror/code/2883178-cancelled))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_OPERATION_CANCELED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final CANCELLED =
      WebResourceErrorType._internalMultiPlatform('CANCELLED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -999;
      case TargetPlatform.macOS:
        return -999;
      case TargetPlatform.windows:
        return 14;
      default:
        break;
    }
    return null;
  });

  ///A download task couldn’t close the downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotCloseFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883215-cannotclosefile))
  ///- MacOS ([Official API - URLError.cannotCloseFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883215-cannotclosefile))
  static final CANNOT_CLOSE_FILE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_CLOSE_FILE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3002;
      case TargetPlatform.macOS:
        return -3002;
      default:
        break;
    }
    return null;
  });

  ///Failed to connect to the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_CONNECT](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_CONNECT))
  ///- iOS ([Official API - URLError.cannotConnectToHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883001-cannotconnecttohost))
  ///- MacOS ([Official API - URLError.cannotConnectToHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883001-cannotconnecttohost))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_CANNOT_CONNECT](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
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
      default:
        break;
    }
    return null;
  });

  ///A download task couldn’t create the downloaded file on disk because of an I/O failure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotCreateFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883204-cannotcreatefile))
  ///- MacOS ([Official API - URLError.cannotCreateFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883204-cannotcreatefile))
  static final CANNOT_CREATE_FILE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_CREATE_FILE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3000;
      case TargetPlatform.macOS:
        return -3000;
      default:
        break;
    }
    return null;
  });

  ///Content data received during a connection request couldn’t be decoded for a known content encoding.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotDecodeContentData](https://developer.apple.com/documentation/foundation/urlerror/2292983-cannotdecodecontentdata))
  ///- MacOS ([Official API - URLError.cannotDecodeContentData](https://developer.apple.com/documentation/foundation/urlerror/2292983-cannotdecodecontentdata))
  static final CANNOT_DECODE_CONTENT_DATA =
      WebResourceErrorType._internalMultiPlatform('CANNOT_DECODE_CONTENT_DATA',
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
  });

  ///Content data received during a connection request couldn’t be decoded for a known content encoding.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotDecodeRawData](https://developer.apple.com/documentation/foundation/urlerror/2293573-cannotdecoderawdata))
  ///- MacOS ([Official API - URLError.cannotDecodeRawData](https://developer.apple.com/documentation/foundation/urlerror/2293573-cannotdecoderawdata))
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
  ///- iOS ([Official API - URLError.cannotLoadFromNetwork](https://developer.apple.com/documentation/foundation/urlerror/code/2882968-cannotloadfromnetwork))
  ///- MacOS ([Official API - URLError.cannotLoadFromNetwork](https://developer.apple.com/documentation/foundation/urlerror/code/2882968-cannotloadfromnetwork))
  static final CANNOT_LOAD_FROM_NETWORK =
      WebResourceErrorType._internalMultiPlatform('CANNOT_LOAD_FROM_NETWORK',
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
  });

  ///A download task was unable to move a downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotMoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883180-cannotmovefile))
  ///- MacOS ([Official API - URLError.cannotMoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883180-cannotmovefile))
  static final CANNOT_MOVE_FILE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_MOVE_FILE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3005;
      case TargetPlatform.macOS:
        return -3005;
      default:
        break;
    }
    return null;
  });

  ///A download task was unable to open the downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotOpenFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883034-cannotopenfile))
  ///- MacOS ([Official API - URLError.cannotOpenFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883034-cannotopenfile))
  static final CANNOT_OPEN_FILE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_OPEN_FILE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3001;
      case TargetPlatform.macOS:
        return -3001;
      default:
        break;
    }
    return null;
  });

  ///A task could not parse a response.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotParseResponse](https://developer.apple.com/documentation/foundation/urlerror/code/2882919-cannotparseresponse))
  ///- MacOS ([Official API - URLError.cannotParseResponse](https://developer.apple.com/documentation/foundation/urlerror/code/2882919-cannotparseresponse))
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
  ///- iOS ([Official API - URLError.cannotRemoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883202-cannotremovefile))
  ///- MacOS ([Official API - URLError.cannotRemoveFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883202-cannotremovefile))
  static final CANNOT_REMOVE_FILE =
      WebResourceErrorType._internalMultiPlatform('CANNOT_REMOVE_FILE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3004;
      case TargetPlatform.macOS:
        return -3004;
      default:
        break;
    }
    return null;
  });

  ///A download task was unable to write to the downloaded file on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.cannotWriteToFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883098-cannotwritetofile))
  ///- MacOS ([Official API - URLError.cannotWriteToFile](https://developer.apple.com/documentation/foundation/urlerror/code/2883098-cannotwritetofile))
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
  ///- iOS ([Official API - URLError.clientCertificateRejected](https://developer.apple.com/documentation/foundation/urlerror/code/2883091-clientcertificaterejected))
  ///- MacOS ([Official API - URLError.clientCertificateRejected](https://developer.apple.com/documentation/foundation/urlerror/code/2883091-clientcertificaterejected))
  static final CLIENT_CERTIFICATE_REJECTED =
      WebResourceErrorType._internalMultiPlatform('CLIENT_CERTIFICATE_REJECTED',
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
  });

  ///A client certificate was required to authenticate an SSL connection during a request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.clientCertificateRequired](https://developer.apple.com/documentation/foundation/urlerror/code/2883199-clientcertificaterequired))
  ///- MacOS ([Official API - URLError.clientCertificateRequired](https://developer.apple.com/documentation/foundation/urlerror/code/2883199-clientcertificaterequired))
  static final CLIENT_CERTIFICATE_REQUIRED =
      WebResourceErrorType._internalMultiPlatform('CLIENT_CERTIFICATE_REQUIRED',
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
  });

  ///Indicates that the connection was stopped.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_ABORTED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final CONNECTION_ABORTED =
      WebResourceErrorType._internalMultiPlatform('CONNECTION_ABORTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 9;
      default:
        break;
    }
    return null;
  });

  ///The length of the resource data exceeds the maximum allowed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.dataLengthExceedsMaximum](https://developer.apple.com/documentation/foundation/urlerror/code/2882930-datalengthexceedsmaximum))
  ///- MacOS ([Official API - URLError.dataLengthExceedsMaximum](https://developer.apple.com/documentation/foundation/urlerror/code/2882930-datalengthexceedsmaximum))
  static final DATA_LENGTH_EXCEEDS_MAXIMUM =
      WebResourceErrorType._internalMultiPlatform('DATA_LENGTH_EXCEEDS_MAXIMUM',
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
  });

  ///The cellular network disallowed a connection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.dataNotAllowed](https://developer.apple.com/documentation/foundation/urlerror/code/2883217-datanotallowed))
  ///- MacOS ([Official API - URLError.dataNotAllowed](https://developer.apple.com/documentation/foundation/urlerror/code/2883217-datanotallowed))
  static final DATA_NOT_ALLOWED =
      WebResourceErrorType._internalMultiPlatform('DATA_NOT_ALLOWED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1020;
      case TargetPlatform.macOS:
        return -1020;
      default:
        break;
    }
    return null;
  });

  ///A download task failed to decode an encoded file during the download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.downloadDecodingFailedMidStream](https://developer.apple.com/documentation/foundation/urlerror/code/2883224-downloaddecodingfailedmidstream))
  ///- MacOS ([Official API - URLError.downloadDecodingFailedMidStream](https://developer.apple.com/documentation/foundation/urlerror/code/2883224-downloaddecodingfailedmidstream))
  static final DOWNLOAD_DECODING_FAILED_MID_STREAM =
      WebResourceErrorType._internalMultiPlatform(
          'DOWNLOAD_DECODING_FAILED_MID_STREAM', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3006;
      case TargetPlatform.macOS:
        return -3006;
      default:
        break;
    }
    return null;
  });

  ///A download task failed to decode an encoded file after downloading.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.downloadDecodingFailedToComplete](https://developer.apple.com/documentation/foundation/urlerror/code/2882936-downloaddecodingfailedtocomplete))
  ///- MacOS ([Official API - URLError.downloadDecodingFailedToComplete](https://developer.apple.com/documentation/foundation/urlerror/code/2882936-downloaddecodingfailedtocomplete))
  static final DOWNLOAD_DECODING_FAILED_TO_COMPLETE =
      WebResourceErrorType._internalMultiPlatform(
          'DOWNLOAD_DECODING_FAILED_TO_COMPLETE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -3007;
      case TargetPlatform.macOS:
        return -3007;
      default:
        break;
    }
    return null;
  });

  ///Failed to perform SSL handshake.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_FAILED_SSL_HANDSHAKE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FAILED_SSL_HANDSHAKE))
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
  ///- iOS ([Official API - URLError.fileIsDirectory](https://developer.apple.com/documentation/foundation/urlerror/code/2883220-fileisdirectory))
  ///- MacOS ([Official API - URLError.fileIsDirectory](https://developer.apple.com/documentation/foundation/urlerror/code/2883220-fileisdirectory))
  static final FILE_IS_DIRECTORY =
      WebResourceErrorType._internalMultiPlatform('FILE_IS_DIRECTORY', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1101;
      case TargetPlatform.macOS:
        return -1101;
      default:
        break;
    }
    return null;
  });

  ///File not found.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_FILE_NOT_FOUND](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE_NOT_FOUND))
  ///- iOS ([Official API - URLError.fileDoesNotExist](https://developer.apple.com/documentation/foundation/urlerror/code/2883074-filedoesnotexist))
  ///- MacOS ([Official API - URLError.fileDoesNotExist](https://developer.apple.com/documentation/foundation/urlerror/code/2883074-filedoesnotexist))
  static final FILE_NOT_FOUND =
      WebResourceErrorType._internalMultiPlatform('FILE_NOT_FOUND', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -14;
      case TargetPlatform.iOS:
        return -1100;
      case TargetPlatform.macOS:
        return -1100;
      default:
        break;
    }
    return null;
  });

  ///Generic file error.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_FILE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE))
  static final GENERIC_FILE_ERROR =
      WebResourceErrorType._internalMultiPlatform('GENERIC_FILE_ERROR', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -13;
      default:
        break;
    }
    return null;
  });

  ///Server or proxy hostname lookup failed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_HOST_LOOKUP](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_HOST_LOOKUP))
  ///- iOS ([Official API - URLError.cannotFindHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883157-cannotfindhost))
  ///- MacOS ([Official API - URLError.cannotFindHost](https://developer.apple.com/documentation/foundation/urlerror/code/2883157-cannotfindhost))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_HOST_NAME_NOT_RESOLVED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final HOST_LOOKUP =
      WebResourceErrorType._internalMultiPlatform('HOST_LOOKUP', () {
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
  });

  ///The attempted connection required activating a data context while roaming, but international roaming is disabled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.internationalRoamingOff](https://developer.apple.com/documentation/foundation/urlerror/code/2883134-internationalroamingoff))
  ///- MacOS ([Official API - URLError.internationalRoamingOff](https://developer.apple.com/documentation/foundation/urlerror/code/2883134-internationalroamingoff))
  static final INTERNATIONAL_ROAMING_OFF =
      WebResourceErrorType._internalMultiPlatform('INTERNATIONAL_ROAMING_OFF',
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
  });

  ///Failed to read or write to the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_IO](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_IO))
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
  ///- iOS ([Official API - URLError.networkConnectionLost](https://developer.apple.com/documentation/foundation/urlerror/2293759-networkconnectionlost))
  ///- MacOS ([Official API - URLError.networkConnectionLost](https://developer.apple.com/documentation/foundation/urlerror/2293759-networkconnectionlost))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_DISCONNECTED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final NETWORK_CONNECTION_LOST =
      WebResourceErrorType._internalMultiPlatform('NETWORK_CONNECTION_LOST',
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
  });

  ///A network resource was requested, but an internet connection hasn’t been established and can’t be established automatically.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.notConnectedToInternet](https://developer.apple.com/documentation/foundation/urlerror/2293104-notconnectedtointernet))
  ///- MacOS ([Official API - URLError.notConnectedToInternet](https://developer.apple.com/documentation/foundation/urlerror/2293104-notconnectedtointernet))
  static final NOT_CONNECTED_TO_INTERNET =
      WebResourceErrorType._internalMultiPlatform('NOT_CONNECTED_TO_INTERNET',
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
  });

  ///A resource couldn’t be read because of insufficient permissions.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.noPermissionsToReadFile](https://developer.apple.com/documentation/foundation/urlerror/code/2882941-nopermissionstoreadfile))
  ///- MacOS ([Official API - URLError.noPermissionsToReadFile](https://developer.apple.com/documentation/foundation/urlerror/code/2882941-nopermissionstoreadfile))
  static final NO_PERMISSIONS_TO_READ_FILE =
      WebResourceErrorType._internalMultiPlatform('NO_PERMISSIONS_TO_READ_FILE',
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
  });

  ///User authentication failed on proxy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_PROXY_AUTHENTICATION](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_PROXY_AUTHENTICATION))
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
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_REDIRECT_FAILED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final REDIRECT_FAILED =
      WebResourceErrorType._internalMultiPlatform('REDIRECT_FAILED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 15;
      default:
        break;
    }
    return null;
  });

  ///A redirect was specified by way of server response code, but the server didn’t accompany this code with a redirect URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.redirectToNonExistentLocation](https://developer.apple.com/documentation/foundation/urlerror/2293066-redirecttononexistentlocation))
  ///- MacOS ([Official API - URLError.redirectToNonExistentLocation](https://developer.apple.com/documentation/foundation/urlerror/2293066-redirecttononexistentlocation))
  static final REDIRECT_TO_NON_EXISTENT_LOCATION =
      WebResourceErrorType._internalMultiPlatform(
          'REDIRECT_TO_NON_EXISTENT_LOCATION', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1010;
      case TargetPlatform.macOS:
        return -1010;
      default:
        break;
    }
    return null;
  });

  ///A body stream is needed but the client did not provide one.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.requestBodyStreamExhausted](https://developer.apple.com/documentation/foundation/urlerror/code/2883176-requestbodystreamexhausted))
  ///- MacOS ([Official API - URLError.requestBodyStreamExhausted](https://developer.apple.com/documentation/foundation/urlerror/code/2883176-requestbodystreamexhausted))
  static final REQUEST_BODY_STREAM_EXHAUSTED =
      WebResourceErrorType._internalMultiPlatform(
          'REQUEST_BODY_STREAM_EXHAUSTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1021;
      case TargetPlatform.macOS:
        return -1021;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the connection was reset.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_RESET](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
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
  ///- iOS ([Official API - URLError.resourceUnavailable](https://developer.apple.com/documentation/foundation/urlerror/2293555-resourceunavailable))
  ///- MacOS ([Official API - URLError.resourceUnavailable](https://developer.apple.com/documentation/foundation/urlerror/2293555-resourceunavailable))
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
  ///- iOS ([Official API - URLError.secureConnectionFailed](https://developer.apple.com/documentation/foundation/urlerror/code/2883122-secureconnectionfailed))
  ///- MacOS ([Official API - URLError.secureConnectionFailed](https://developer.apple.com/documentation/foundation/urlerror/code/2883122-secureconnectionfailed))
  static final SECURE_CONNECTION_FAILED =
      WebResourceErrorType._internalMultiPlatform('SECURE_CONNECTION_FAILED',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1200;
      case TargetPlatform.macOS:
        return -1200;
      default:
        break;
    }
    return null;
  });

  ///A server certificate had a date which indicates it has expired, or is not yet valid.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateHasBadDate](https://developer.apple.com/documentation/foundation/urlerror/code/2883088-servercertificatehasbaddate))
  ///- MacOS ([Official API - URLError.serverCertificateHasBadDate](https://developer.apple.com/documentation/foundation/urlerror/code/2883088-servercertificatehasbaddate))
  static final SERVER_CERTIFICATE_HAS_BAD_DATE =
      WebResourceErrorType._internalMultiPlatform(
          'SERVER_CERTIFICATE_HAS_BAD_DATE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1201;
      case TargetPlatform.macOS:
        return -1201;
      default:
        break;
    }
    return null;
  });

  ///A server certificate was not signed by any root server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateHasUnknownRoot](https://developer.apple.com/documentation/foundation/urlerror/code/2883085-servercertificatehasunknownroot))
  ///- MacOS ([Official API - URLError.serverCertificateHasUnknownRoot](https://developer.apple.com/documentation/foundation/urlerror/code/2883085-servercertificatehasunknownroot))
  static final SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT =
      WebResourceErrorType._internalMultiPlatform(
          'SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1203;
      case TargetPlatform.macOS:
        return -1203;
      default:
        break;
    }
    return null;
  });

  ///A server certificate is not yet valid.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateNotYetValid](https://developer.apple.com/documentation/foundation/urlerror/code/2882991-servercertificatenotyetvalid))
  ///- MacOS ([Official API - URLError.serverCertificateNotYetValid](https://developer.apple.com/documentation/foundation/urlerror/code/2882991-servercertificatenotyetvalid))
  static final SERVER_CERTIFICATE_NOT_YET_VALID =
      WebResourceErrorType._internalMultiPlatform(
          'SERVER_CERTIFICATE_NOT_YET_VALID', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1204;
      case TargetPlatform.macOS:
        return -1204;
      default:
        break;
    }
    return null;
  });

  ///A server certificate was signed by a root server that isn’t trusted.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.serverCertificateUntrusted](https://developer.apple.com/documentation/foundation/urlerror/code/2882976-servercertificateuntrusted))
  ///- MacOS ([Official API - URLError.serverCertificateUntrusted](https://developer.apple.com/documentation/foundation/urlerror/code/2882976-servercertificateuntrusted))
  static final SERVER_CERTIFICATE_UNTRUSTED =
      WebResourceErrorType._internalMultiPlatform(
          'SERVER_CERTIFICATE_UNTRUSTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1202;
      case TargetPlatform.macOS:
        return -1202;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the host is unreachable.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_SERVER_UNREACHABLE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final SERVER_UNREACHABLE =
      WebResourceErrorType._internalMultiPlatform('SERVER_UNREACHABLE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 6;
      default:
        break;
    }
    return null;
  });

  ///Connection timed out.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_TIMEOUT](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TIMEOUT))
  ///- iOS ([Official API - URLError.timedOut](https://developer.apple.com/documentation/foundation/urlerror/code/2883027-timedout))
  ///- MacOS ([Official API - URLError.timedOut](https://developer.apple.com/documentation/foundation/urlerror/code/2883027-timedout))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_TIMEOUT](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final TIMEOUT =
      WebResourceErrorType._internalMultiPlatform('TIMEOUT', () {
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
  });

  ///A redirect loop has been detected or the threshold for number of allowable redirects has been exceeded (currently `16` on iOS).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_REDIRECT_LOOP](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_REDIRECT_LOOP))
  ///- iOS ([Official API - URLError.httpTooManyRedirects](https://developer.apple.com/documentation/foundation/urlerror/code/2883099-httptoomanyredirects))
  ///- MacOS ([Official API - URLError.httpTooManyRedirects](https://developer.apple.com/documentation/foundation/urlerror/code/2883099-httptoomanyredirects))
  static final TOO_MANY_REDIRECTS =
      WebResourceErrorType._internalMultiPlatform('TOO_MANY_REDIRECTS', () {
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
  });

  ///Too many requests during this load.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_TOO_MANY_REQUESTS](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TOO_MANY_REQUESTS))
  static final TOO_MANY_REQUESTS =
      WebResourceErrorType._internalMultiPlatform('TOO_MANY_REQUESTS', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -15;
      default:
        break;
    }
    return null;
  });

  ///Indicates that an unexpected error occurred.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_UNEXPECTED_ERROR](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final UNEXPECTED_ERROR =
      WebResourceErrorType._internalMultiPlatform('UNEXPECTED_ERROR', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 16;
      default:
        break;
    }
    return null;
  });

  ///The URL Loading System encountered an error that it can’t interpret.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNKNOWN](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNKNOWN))
  ///- iOS ([Official API - URLError.unknown](https://developer.apple.com/documentation/foundation/urlerror/2293357-unknown))
  ///- MacOS ([Official API - URLError.unknown](https://developer.apple.com/documentation/foundation/urlerror/2293357-unknown))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_UNKNOWN](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final UNKNOWN =
      WebResourceErrorType._internalMultiPlatform('UNKNOWN', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -1;
      case TargetPlatform.iOS:
        return -1;
      case TargetPlatform.macOS:
        return -1;
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Resource load was canceled by Safe Browsing.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNSAFE_RESOURCE](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSAFE_RESOURCE))
  static final UNSAFE_RESOURCE =
      WebResourceErrorType._internalMultiPlatform('UNSAFE_RESOURCE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -16;
      default:
        break;
    }
    return null;
  });

  ///Unsupported authentication scheme (not basic or digest).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNSUPPORTED_AUTH_SCHEME](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_AUTH_SCHEME))
  static final UNSUPPORTED_AUTH_SCHEME =
      WebResourceErrorType._internalMultiPlatform('UNSUPPORTED_AUTH_SCHEME',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -3;
      default:
        break;
    }
    return null;
  });

  ///Unsupported URI scheme.
  ///Typically this occurs when there is no available protocol handler for the URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_UNSUPPORTED_SCHEME](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_SCHEME))
  ///- iOS ([Official API - URLError.unsupportedURL](https://developer.apple.com/documentation/foundation/urlerror/code/2883043-unsupportedurl))
  ///- MacOS ([Official API - URLError.unsupportedURL](https://developer.apple.com/documentation/foundation/urlerror/code/2883043-unsupportedurl))
  static final UNSUPPORTED_SCHEME =
      WebResourceErrorType._internalMultiPlatform('UNSUPPORTED_SCHEME', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -10;
      case TargetPlatform.iOS:
        return -1002;
      case TargetPlatform.macOS:
        return -1002;
      default:
        break;
    }
    return null;
  });

  ///User authentication failed on server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewClient.ERROR_AUTHENTICATION](https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_AUTHENTICATION))
  static final USER_AUTHENTICATION_FAILED =
      WebResourceErrorType._internalMultiPlatform('USER_AUTHENTICATION_FAILED',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -4;
      default:
        break;
    }
    return null;
  });

  ///Authentication is required to access a resource.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.userAuthenticationRequired](https://developer.apple.com/documentation/foundation/urlerror/2293560-userauthenticationrequired))
  ///- MacOS ([Official API - URLError.userAuthenticationRequired](https://developer.apple.com/documentation/foundation/urlerror/2293560-userauthenticationrequired))
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_VALID_AUTHENTICATION_CREDENTIALS_REQUIRED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final USER_AUTHENTICATION_REQUIRED =
      WebResourceErrorType._internalMultiPlatform(
          'USER_AUTHENTICATION_REQUIRED', () {
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
  });

  ///An asynchronous request for authentication has been canceled by the user.
  ///This error typically occurs when a user clicks a "Cancel" button in a username/password dialog, rather than attempting to authenticate.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.userCancelledAuthentication](https://developer.apple.com/documentation/foundation/urlerror/2293330-usercancelledauthentication))
  ///- MacOS ([Official API - URLError.userCancelledAuthentication](https://developer.apple.com/documentation/foundation/urlerror/2293330-usercancelledauthentication))
  static final USER_CANCELLED_AUTHENTICATION =
      WebResourceErrorType._internalMultiPlatform(
          'USER_CANCELLED_AUTHENTICATION', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1012;
      case TargetPlatform.macOS:
        return -1012;
      default:
        break;
    }
    return null;
  });

  ///Indicates that user lacks proper authentication credentials for a proxy server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_WEB_ERROR_STATUS_VALID_PROXY_AUTHENTICATION_REQUIRED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_web_error_status))
  static final VALID_PROXY_AUTHENTICATION_REQUIRED =
      WebResourceErrorType._internalMultiPlatform(
          'VALID_PROXY_AUTHENTICATION_REQUIRED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 18;
      default:
        break;
    }
    return null;
  });

  ///A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLError.zeroByteResource](https://developer.apple.com/documentation/foundation/urlerror/2293773-zerobyteresource))
  ///- MacOS ([Official API - URLError.zeroByteResource](https://developer.apple.com/documentation/foundation/urlerror/2293773-zerobyteresource))
  static final ZERO_BYTE_RESOURCE =
      WebResourceErrorType._internalMultiPlatform('ZERO_BYTE_RESOURCE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1014;
      case TargetPlatform.macOS:
        return -1014;
      default:
        break;
    }
    return null;
  });

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
    WebResourceErrorType.CANNOT_WRITE_TO_FILE,
    WebResourceErrorType.CLIENT_CERTIFICATE_REJECTED,
    WebResourceErrorType.CLIENT_CERTIFICATE_REQUIRED,
    WebResourceErrorType.CONNECTION_ABORTED,
    WebResourceErrorType.DATA_LENGTH_EXCEEDS_MAXIMUM,
    WebResourceErrorType.DATA_NOT_ALLOWED,
    WebResourceErrorType.DOWNLOAD_DECODING_FAILED_MID_STREAM,
    WebResourceErrorType.DOWNLOAD_DECODING_FAILED_TO_COMPLETE,
    WebResourceErrorType.FAILED_SSL_HANDSHAKE,
    WebResourceErrorType.FILE_IS_DIRECTORY,
    WebResourceErrorType.FILE_NOT_FOUND,
    WebResourceErrorType.GENERIC_FILE_ERROR,
    WebResourceErrorType.HOST_LOOKUP,
    WebResourceErrorType.INTERNATIONAL_ROAMING_OFF,
    WebResourceErrorType.IO,
    WebResourceErrorType.NETWORK_CONNECTION_LOST,
    WebResourceErrorType.NOT_CONNECTED_TO_INTERNET,
    WebResourceErrorType.NO_PERMISSIONS_TO_READ_FILE,
    WebResourceErrorType.PROXY_AUTHENTICATION,
    WebResourceErrorType.REDIRECT_FAILED,
    WebResourceErrorType.REDIRECT_TO_NON_EXISTENT_LOCATION,
    WebResourceErrorType.REQUEST_BODY_STREAM_EXHAUSTED,
    WebResourceErrorType.RESET,
    WebResourceErrorType.RESOURCE_UNAVAILABLE,
    WebResourceErrorType.SECURE_CONNECTION_FAILED,
    WebResourceErrorType.SERVER_CERTIFICATE_HAS_BAD_DATE,
    WebResourceErrorType.SERVER_CERTIFICATE_HAS_UNKNOWN_ROOT,
    WebResourceErrorType.SERVER_CERTIFICATE_NOT_YET_VALID,
    WebResourceErrorType.SERVER_CERTIFICATE_UNTRUSTED,
    WebResourceErrorType.SERVER_UNREACHABLE,
    WebResourceErrorType.TIMEOUT,
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
        return WebResourceErrorType.values
            .firstWhere((element) => element.toValue() == value);
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

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
