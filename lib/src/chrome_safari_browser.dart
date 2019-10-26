import 'dart:async';

import 'package:flutter/services.dart';

import 'types.dart';
import 'channel_manager.dart';
import 'in_app_browser.dart';

///ChromeSafariBrowser class.
///
///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///[browserFallback] represents the [InAppBrowser] instance fallback in case [Chrome Custom Tabs]/[SFSafariViewController] is not available.
class ChromeSafariBrowser {
  String uuid;
  InAppBrowser browserFallback;
  bool _isOpened = false;

  ///Initialize the [ChromeSafariBrowser] instance with an [InAppBrowser] fallback instance or `null`.
  ChromeSafariBrowser (bf) {
    uuid = uuidGenerator.v4();
    browserFallback = bf;
    ChannelManager.addListener(uuid, handleMethod);
    _isOpened = false;
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch(call.method) {
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
  ///- [url]: The [url] to load. Call [encodeUriComponent()] on this if the [url] contains Unicode characters.
  ///
  ///- [options]: Options for the [ChromeSafariBrowser].
  ///
  ///- [headersFallback]: The additional header of the [InAppBrowser] instance fallback to be used in the HTTP request for this URL, specified as a map from name to value.
  ///
  ///- [optionsFallback]: Options used by the [InAppBrowser] instance fallback.
  ///
  ///**Android** supports these options:
  ///
  ///- __addShareButton__: Set to `false` if you don't want the default share button. The default value is `true`.
  ///- __showTitle__: Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  ///- __toolbarBackgroundColor__: Set the custom background color of the toolbar.
  ///- __enableUrlBarHiding__: Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  ///- __instantAppsEnabled__: Set to `true` to enable Instant Apps. The default value is `false`.
  ///
  ///**iOS** supports these options:
  ///
  ///- __entersReaderIfAvailable__: Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  ///- __barCollapsingEnabled__: Set to `true` to enable bar collapsing. The default value is `false`.
  ///- __dismissButtonStyle__: Set the custom style for the dismiss button. The default value is `0 //done`. See [SFSafariViewController.DismissButtonStyle](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/dismissbuttonstyle) for all the available styles.
  ///- __preferredBarTintColor__: Set the custom background color of the navigation bar and the toolbar.
  ///- __preferredControlTintColor__: Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///- __presentationStyle__: Set the custom modal presentation style when presenting the WebView. The default value is `0 //fullscreen`. See [UIModalPresentationStyle](https://developer.apple.com/documentation/uikit/uimodalpresentationstyle) for all the available styles.
  ///- __transitionStyle__: Set to the custom transition style when presenting the WebView. The default value is `0 //crossDissolve`. See [UIModalTransitionStyle](https://developer.apple.com/documentation/uikit/uimodaltransitionStyle) for all the available styles.
  Future<void> open(String url, {Map<String, dynamic> options = const {}, Map<String, String> headersFallback = const {}, Map<String, dynamic> optionsFallback = const {}}) async {
    assert(url != null && url.isNotEmpty);
    this.throwIsAlreadyOpened(message: 'Cannot open $url!');
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('uuidFallback', () => (browserFallback != null) ? browserFallback.uuid : '');
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headersFallback);
    args.putIfAbsent('options', () => options);
    args.putIfAbsent('optionsFallback', () => optionsFallback);
    args.putIfAbsent('isData', () => false);
    args.putIfAbsent('useChromeSafariBrowser', () => true);
    await ChannelManager.channel.invokeMethod('open', args);
    this._isOpened = true;
  }

  ///Event fires when the [ChromeSafariBrowser] is opened.
  void onOpened() {

  }

  ///Event fires when the [ChromeSafariBrowser] is loaded.
  void onLoaded() {

  }

  ///Event fires when the [ChromeSafariBrowser] is closed.
  void onClosed() {

  }

  bool isOpened() {
    return this._isOpened;
  }

  void throwIsAlreadyOpened({String message = ''}) {
    if (this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is already opened.']);
    }
  }

  void throwIsNotOpened({String message = ''}) {
    if (!this.isOpened()) {
      throw Exception(['Error: ${ (message.isEmpty) ? '' : message + ' '}The browser is not opened.']);
    }
  }
}