import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types.dart';
import 'channel_manager.dart';
import 'in_app_browser.dart';

///ChromeSafariBrowser class.
///
///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///[browserFallback] represents the [InAppBrowser] instance fallback in case `Chrome Custom Tabs`/`SFSafariViewController` is not available.
class ChromeSafariBrowser {
  String uuid;
  InAppBrowser browserFallback;
  bool _isOpened = false;

  ///Initialize the [ChromeSafariBrowser] instance with an [InAppBrowser] fallback instance or `null`.
  ChromeSafariBrowser({bFallback}) {
    uuid = uuidGenerator.v4();
    browserFallback = bFallback;
    ChannelManager.addListener(uuid, handleMethod);
    _isOpened = false;
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onChromeSafariBrowserOpened":
        onOpened();
        break;
      case "onChromeSafariBrowserLoaded":
        onLoaded();
        break;
      case "onChromeSafariBrowserClosed":
        onClosed();
        this._isOpened = false;
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Opens an [url] in a new [ChromeSafariBrowser] instance.
  ///
  ///[url]: The [url] to load. Call [encodeUriComponent()] on this if the [url] contains Unicode characters.
  ///
  ///[options]: Options for the [ChromeSafariBrowser].
  ///
  ///[headersFallback]: The additional header of the [InAppBrowser] instance fallback to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///[optionsFallback]: Options used by the [InAppBrowser] instance fallback.
  Future<void> open(
      {@required String url,
      ChromeSafariBrowserClassOptions options,
      Map<String, String> headersFallback = const {},
      InAppBrowserClassOptions optionsFallback}) async {
    assert(url != null && url.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');

    Map<String, dynamic> optionsMap = {};
    if (Platform.isAndroid)
      optionsMap.addAll(options.androidChromeCustomTabsOptions?.toMap() ?? {});
    else if (Platform.isIOS)
      optionsMap.addAll(options.iosSafariOptions?.toMap() ?? {});

    Map<String, dynamic> optionsFallbackMap = {};
    if (optionsFallback != null) {
      optionsFallbackMap
          .addAll(optionsFallback.inAppBrowserOptions?.toMap() ?? {});
      optionsFallbackMap.addAll(optionsFallback
              .inAppWebViewWidgetOptions?.inAppWebViewOptions
              ?.toMap() ??
          {});
      if (Platform.isAndroid) {
        optionsFallbackMap
            .addAll(optionsFallback.androidInAppBrowserOptions?.toMap() ?? {});
        optionsFallbackMap.addAll(optionsFallback
                .inAppWebViewWidgetOptions?.androidInAppWebViewOptions
                ?.toMap() ??
            {});
      } else if (Platform.isIOS) {
        optionsFallbackMap
            .addAll(optionsFallback.iosInAppBrowserOptions?.toMap() ?? {});
        optionsFallbackMap.addAll(optionsFallback
                .inAppWebViewWidgetOptions?.iosInAppWebViewOptions
                ?.toMap() ??
            {});
      }
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('uuidFallback',
        () => (browserFallback != null) ? browserFallback.uuid : '');
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headersFallback);
    args.putIfAbsent('options', () => optionsMap);
    args.putIfAbsent('optionsFallback', () => optionsFallbackMap);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => true);
    await ChannelManager.channel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///Event fires when the [ChromeSafariBrowser] is opened.
  void onOpened() {}

  ///Event fires when the [ChromeSafariBrowser] is loaded.
  void onLoaded() {}

  ///Event fires when the [ChromeSafariBrowser] is closed.
  void onClosed() {}

  ///Returns `true` if the [ChromeSafariBrowser] instance is opened, otherwise `false`.
  bool isOpened() {
    return this._isOpened;
  }

  void throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is already opened.'
      ]);
    }
  }

  void throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception([
        'Error: ${(message.isEmpty) ? '' : message + ' '}The browser is not opened.'
      ]);
    }
  }
}
