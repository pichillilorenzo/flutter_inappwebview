/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

import 'dart:async';

import 'package:flutter/services.dart';

///Main class of the plugin.
class InAppBrowser {
  static const MethodChannel _channel = const MethodChannel('com.pichillilorenzo/flutter_inappbrowser');

  ///
  InAppBrowser () {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "loadstart":
        String url = call.arguments["url"];
        onLoadStart(url);
        break;
      case "loadstop":
        String url = call.arguments["url"];
        onLoadStop(url);
        break;
      case "loaderror":
        String url = call.arguments["url"];
        int code = call.arguments["code"];
        String message = call.arguments["message"];
        onLoadError(url, code, message);
        break;
      case "exit":
        onExit();
        break;
    }
    return new Future.value("");
  }

  ///Opens an [url] in a new [InAppBrowser] instance or the system browser.
  ///
  /// - [url]: The [url] to load __(String)__. Call [encodeUriComponent()] on this if the [url] contains Unicode characters.
  ///
  /// - [target]: The target in which to load the [url], an optional parameter that defaults to `_self`. __(String)__
  ///
  ///   - `_self`: Opens in the [InAppBrowser].
  ///   - `_blank`: Opens in the [InAppBrowser].
  ///   - `_system`: Opens in the system's web browser.
  ///
  ///   - [options]: Options for the `InAppBrowser`. Optional, defaulting to: `location=yes`. _(String)_
  ///
  ///   The [options] string must not contain any blank space, and each feature's name/value pairs must be separated by a comma. Feature names are case insensitive.
  ///
  ///   All platforms support:
  ///
  ///   - __location__: Set to `yes` or `no` to turn the [InAppBrowser]'s location bar on or off.
  ///
  ///   **Android** supports these additional options:
  ///
  ///   - __hidden__: set to `yes` to create the browser and load the page, but not show it. The loadstop event fires when loading is complete. Omit or set to `no` (default) to have the browser open and load normally.
  ///   - __clearcache__: set to `yes` to have the browser's cookie cache cleared before the new window is opened
  ///   - __clearsessioncache__: set to `yes` to have the session cookie cache cleared before the new window is opened
  ///   - __closebuttoncaption__: set to a string to use as the close button's caption instead of a X. Note that you need to localize this value yourself.
  ///   - __closebuttoncolor__: set to a valid hex color string, for example: `#00ff00`, and it will change the
  ///   close button color from default, regardless of being a text or default X. Only has effect if user has location set to `yes`.
  ///   - __footer__: set to `yes` to show a close button in the footer similar to the iOS __Done__ button.
  ///   The close button will appear the same as for the header hence use __closebuttoncaption__ and __closebuttoncolor__ to set its properties.
  ///   - __footercolor__: set to a valid hex color string, for example `#00ff00` or `#CC00ff00` (`#aarrggbb`) , and it will change the footer color from default.
  ///   Only has effect if user has __footer__ set to `yes`.
  ///   - __hardwareback__: set to `yes` to use the hardware back button to navigate backwards through the `InAppBrowser`'s history. If there is no previous page, the `InAppBrowser` will close.  The default value is `yes`, so you must set it to `no` if you want the back button to simply close the InAppBrowser.
  ///   - __hidenavigationbuttons__: set to `yes` to hide the navigation buttons on the location toolbar, only has effect if user has location set to `yes`. The default value is `no`.
  ///   - __hideurlbar__: set to `yes` to hide the url bar on the location toolbar, only has effect if user has location set to `yes`. The default value is `no`.
  ///   - __navigationbuttoncolor__: set to a valid hex color string, for example: `#00ff00`, and it will change the color of both navigation buttons from default. Only has effect if user has location set to `yes` and not hidenavigationbuttons set to `yes`.
  ///   - __toolbarcolor__: set to a valid hex color string, for example: `#00ff00`, and it will change the color the toolbar from default. Only has effect if user has location set to `yes`.
  ///   - __zoom__: set to `yes` to show Android browser's zoom controls, set to `no` to hide them.  Default value is `yes`.
  ///   - __mediaPlaybackRequiresUserAction__: Set to `yes` to prevent HTML5 audio or video from autoplaying (defaults to `no`).
  ///   - __shouldPauseOnSuspend__: Set to `yes` to make InAppBrowser WebView to pause/resume with the app to stop background audio (this may be required to avoid Google Play issues like described in [CB-11013](https://issues.apache.org/jira/browse/CB-11013)).
  ///   - __useWideViewPort__: Sets whether the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is `no`, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is `yes` and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. (defaults to `yes`).
  ///
  ///   **iOS** supports these additional options:
  ///
  ///   - __hidden__: set to `yes` to create the browser and load the page, but not show it. The loadstop event fires when loading is complete. Omit or set to `no` (default) to have the browser open and load normally.
  ///   - __clearcache__: set to `yes` to have the browser's cookie cache cleared before the new window is opened
  ///   - __clearsessioncache__: set to `yes` to have the session cookie cache cleared before the new window is opened
  ///   - __closebuttoncolor__: set as a valid hex color string, for example: `#00ff00`, to change from the default __Done__ button's color. Only applicable if toolbar is not disabled.
  ///   - __closebuttoncaption__: set to a string to use as the __Done__ button's caption. Note that you need to localize this value yourself.
  ///   - __disallowoverscroll__: Set to `yes` or `no` (default is `no`). Turns on/off the UIWebViewBounce property.
  ///   - __hidenavigationbuttons__:  set to `yes` or `no` to turn the toolbar navigation buttons on or off (defaults to `no`). Only applicable if toolbar is not disabled.
  ///   - __navigationbuttoncolor__:  set as a valid hex color string, for example: `#00ff00`, to change from the default color. Only applicable if navigation buttons are visible.
  ///   - __toolbar__:  set to `yes` or `no` to turn the toolbar on or off for the InAppBrowser (defaults to `yes`)
  ///   - __toolbarcolor__: set as a valid hex color string, for example: `#00ff00`, to change from the default color of the toolbar. Only applicable if toolbar is not disabled.
  ///   - __toolbartranslucent__:  set to `yes` or `no` to make the toolbar translucent(semi-transparent)  (defaults to `yes`). Only applicable if toolbar is not disabled.
  ///   - __enableViewportScale__:  Set to `yes` or `no` to prevent viewport scaling through a meta tag (defaults to `no`).
  ///   - __mediaPlaybackRequiresUserAction__: Set to `yes` to prevent HTML5 audio or video from autoplaying (defaults to `no`).
  ///   - __allowInlineMediaPlayback__: Set to `yes` or `no` to allow in-line HTML5 media playback, displaying within the browser window rather than a device-specific playback interface. The HTML's `video` element must also include the `webkit-playsinline` attribute (defaults to `no`)
  ///   - __keyboardDisplayRequiresUserAction__: Set to `yes` or `no` to open the keyboard when form elements receive focus via JavaScript's `focus()` call (defaults to `yes`).
  ///   - __suppressesIncrementalRendering__: Set to `yes` or `no` to wait until all new view content is received before being rendered (defaults to `no`).
  ///   - __presentationstyle__:  Set to `pagesheet`, `formsheet` or `fullscreen` to set the [presentation style](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/modalPresentationStyle) (defaults to `fullscreen`).
  ///   - __transitionstyle__: Set to `fliphorizontal`, `crossdissolve` or `coververtical` to set the [transition style](http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/modalTransitionStyle) (defaults to `coververtical`).
  ///   - __toolbarposition__: Set to `top` or `bottom` (default is `bottom`). Causes the toolbar to be at the top or bottom of the window.
  ///   - __hidespinner__: Set to `yes` or `no` to change the visibility of the loading indicator (defaults to `no`).
  Future<void> open(String url, {Map<String, String> headers = const {}, String target = "_self", Map<String, dynamic> options = const {}}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent('target', () => target);
    args.putIfAbsent('options', () => options);
    return await _channel.invokeMethod('open', args);
  }

  Future<void> loadUrl(String url, {Map<String, String> headers = const {}}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('headers', () => headers);
    return await _channel.invokeMethod('loadUrl', args);
  }

  ///Displays an [InAppBrowser] window that was opened hidden. Calling this has no effect if the [InAppBrowser] was already visible.
  Future<void> show() async {
    return await _channel.invokeMethod('show');
  }

  ///Hides the [InAppBrowser] window. Calling this has no effect if the [InAppBrowser] was already hidden.
  Future<void> hide() async {
    return await _channel.invokeMethod('hide');
  }

  ///Closes the [InAppBrowser] window.
  Future<void> close() async {
    return await _channel.invokeMethod('close');
  }

  ///Reloads the [InAppBrowser] window.
  Future<void> reload() async {
    return await _channel.invokeMethod('reload');
  }

  ///Goes back in the history of the [InAppBrowser] window.
  Future<void> goBack() async {
    return await _channel.invokeMethod('goBack');
  }

  ///Goes forward in the history of the [InAppBrowser] window.
  Future<void> goForward() async {
    return await _channel.invokeMethod('goForward');
  }

  ///Check if the Web View of the [InAppBrowser] instance is in a loading state.
  Future<bool> isLoading() async {
    return await _channel.invokeMethod('isLoading');
  }

  ///Stops the Web View of the [InAppBrowser] instance from loading.
  Future<void> stopLoading() async {
    return await _channel.invokeMethod('stopLoading');
  }

  ///Injects JavaScript code into the [InAppBrowser] window. (Only available when the target is set to `_blank` or to `_self`)
  Future<dynamic> injectScriptCode(String source) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    return await _channel.invokeMethod('injectScriptCode', args);
  }

  ///Injects a JavaScript file into the [InAppBrowser] window. (Only available when the target is set to `_blank` or to `_self`)
  Future<void> injectScriptFile(String urlFile) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile);
    return await _channel.invokeMethod('injectScriptFile', args);
  }

  ///Injects CSS into the [InAppBrowser] window. (Only available when the target is set to `_blank` or to `_self`)
  Future<void> injectStyleCode(String source) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('source', () => source);
    return await _channel.invokeMethod('injectStyleCode', args);
  }

  ///Injects a CSS file into the [InAppBrowser] window. (Only available when the target is set to `_blank` or to `_self`)
  Future<void> injectStyleFile(String urlFile) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlFile', () => urlFile);
    return await _channel.invokeMethod('injectStyleFile', args);
  }

  ///Event fires when the [InAppBrowser] starts to load an [url].
  void onLoadStart(String url) {

  }

  ///Event fires when the [InAppBrowser] finishes loading an [url].
  void onLoadStop(String url) {

  }

  ///Event fires when the [InAppBrowser] encounters an error loading an [url].
  void onLoadError(String url, int code, String message) {

  }

  ///Event fires when the [InAppBrowser] window is closed.
  void onExit() {

  }

}
