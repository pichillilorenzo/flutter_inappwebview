# Flutter InAppBrowser Plugin

[![Pub](https://img.shields.io/pub/v/flutter_inappbrowser.svg)](https://pub.dartlang.org/packages/flutter_inappbrowser)

A Flutter plugin that allows you to open an in-app browser window.
This plugin is a porting of the popular [cordova-plugin-inappbrowser](https://github.com/apache/cordova-plugin-inappbrowser)!

The Java/Swift code has been reshaped to work with the Flutter API.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

## Installation
First, add `flutter_inappbrowser` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Usage
Create a Class that extends the `InAppBrowser` Class in order to override the callbacks to manage the browser events.
Example:
```dart
import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {

  @override
  void onLoadStart(String url) {
    super.onLoadStart(url);
    print("\n\nStarted $url\n\n");
  }

  @override
  void onLoadStop(String url) {
    super.onLoadStop(url);
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    super.onLoadError(url, code, message);
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    super.onExit();
    print("\n\nBrowser closed!\n\n");
  }

}

MyInAppBrowser inAppBrowser = new MyInAppBrowser();

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter InAppBrowser Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: () {
            inAppBrowser.open("https://flutter.io/");
          },
          child: Text("Open InAppBrowser")
          ),
        ),
      ),
    );
  }
}
```

### InAppBrowser.open

Opens a URL in a new InAppBrowser instance or the system browser.

```dart
inAppBrowser.open(url, target, options);
```

Opens an `url` in a new `InAppBrowser` instance or the system browser.

- `url`: The `url` to load __(String)__. Call [encodeUriComponent()] on this if the `url` contains Unicode characters.

- `target`: The target in which to load the `url`, an optional parameter that defaults to `_self`. __(String)__

  - `_self`: Opens in the `InAppBrowser`.
  - `_blank`: Opens in the `InAppBrowser`.
  - `_system`: Opens in the system's web browser.

- `options`: Options for the `InAppBrowser`. Optional, defaulting to: `location=yes`. _(String)_

  The `options` string must not contain any blank space, and each feature's name/value pairs must be separated by a comma. Feature names are case insensitive.

  All platforms support:
 
  - __location__: Set to `yes` or `no` to turn the `InAppBrowser`'s location bar on or off.
 
  **Android** supports these additional options:
 
  - __hidden__: set to `yes` to create the browser and load the page, but not show it. The loadstop event fires when loading is complete. Omit or set to `no` (default) to have the browser open and load normally.
  - __clearcache__: set to `yes` to have the browser's cookie cache cleared before the new window is opened
  - __clearsessioncache__: set to `yes` to have the session cookie cache cleared before the new window is opened
  - __closebuttoncaption__: set to a string to use as the close button's caption instead of a X. Note that you need to localize this value yourself.
  - __closebuttoncolor__: set to a valid hex color string, for example: `#00ff00`, and it will change the
  close button color from default, regardless of being a text or default X. Only has effect if user has location set to `yes`.
  - __footer__: set to `yes` to show a close button in the footer similar to the iOS __Done__ button.
  The close button will appear the same as for the header hence use __closebuttoncaption__ and __closebuttoncolor__ to set its properties.
  - __footercolor__: set to a valid hex color string, for example `#00ff00` or `#CC00ff00` (`#aarrggbb`) , and it will change the footer color from default.
  Only has effect if user has __footer__ set to `yes`.
  - __hardwareback__: set to `yes` to use the hardware back button to navigate backwards through the `InAppBrowser`'s history. If there is no previous page, the `InAppBrowser` will close.  The default value is `yes`, so you must set it to `no` if you want the back button to simply close the InAppBrowser.
  - __hidenavigationbuttons__: set to `yes` to hide the navigation buttons on the location toolbar, only has effect if user has location set to `yes`. The default value is `no`.
  - __hideurlbar__: set to `yes` to hide the url bar on the location toolbar, only has effect if user has location set to `yes`. The default value is `no`.
  - __navigationbuttoncolor__: set to a valid hex color string, for example: `#00ff00`, and it will change the color of both navigation buttons from default. Only has effect if user has location set to `yes` and not hidenavigationbuttons set to `yes`.
  - __toolbarcolor__: set to a valid hex color string, for example: `#00ff00`, and it will change the color the toolbar from default. Only has effect if user has location set to `yes`.
  - __zoom__: set to `yes` to show Android browser's zoom controls, set to `no` to hide them.  Default value is `yes`.
  - __mediaPlaybackRequiresUserAction__: Set to `yes` to prevent HTML5 audio or video from autoplaying (defaults to `no`).
  - __shouldPauseOnSuspend__: Set to `yes` to make InAppBrowser WebView to pause/resume with the app to stop background audio (this may be required to avoid Google Play issues like described in [CB-11013](https://issues.apache.org/jira/browse/CB-11013)).
  - __useWideViewPort__: Sets whether the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. When the value of the setting is `no`, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels. When the value is `yes` and the page contains the viewport meta tag, the value of the width specified in the tag is used. If the page does not contain the tag or does not provide a width, then a wide viewport will be used. (defaults to `yes`).
 
  **iOS** supports these additional options:
 
  - __hidden__: set to `yes` to create the browser and load the page, but not show it. The loadstop event fires when loading is complete. Omit or set to `no` (default) to have the browser open and load normally.
  - __clearcache__: set to `yes` to have the browser's cookie cache cleared before the new window is opened
  - __clearsessioncache__: set to `yes` to have the session cookie cache cleared before the new window is opened
  - __closebuttoncolor__: set as a valid hex color string, for example: `#00ff00`, to change from the default __Done__ button's color. Only applicable if toolbar is not disabled.
  - __closebuttoncaption__: set to a string to use as the __Done__ button's caption. Note that you need to localize this value yourself.
  - __disallowoverscroll__: Set to `yes` or `no` (default is `no`). Turns on/off the UIWebViewBounce property.
  - __hidenavigationbuttons__:  set to `yes` or `no` to turn the toolbar navigation buttons on or off (defaults to `no`). Only applicable if toolbar is not disabled.
  - __navigationbuttoncolor__:  set as a valid hex color string, for example: `#00ff00`, to change from the default color. Only applicable if navigation buttons are visible.
  - __toolbar__:  set to `yes` or `no` to turn the toolbar on or off for the InAppBrowser (defaults to `yes`)
  - __toolbarcolor__: set as a valid hex color string, for example: `#00ff00`, to change from the default color of the toolbar. Only applicable if toolbar is not disabled.
  - __toolbartranslucent__:  set to `yes` or `no` to make the toolbar translucent(semi-transparent)  (defaults to `yes`). Only applicable if toolbar is not disabled.
  - __enableViewportScale__:  Set to `yes` or `no` to prevent viewport scaling through a meta tag (defaults to `no`).
  - __mediaPlaybackRequiresUserAction__: Set to `yes` to prevent HTML5 audio or video from autoplaying (defaults to `no`).
  - __allowInlineMediaPlayback__: Set to `yes` or `no` to allow in-line HTML5 media playback, displaying within the browser window rather than a device-specific playback interface. The HTML's `video` element must also include the `webkit-playsinline` attribute (defaults to `no`)
  - __keyboardDisplayRequiresUserAction__: Set to `yes` or `no` to open the keyboard when form elements receive focus via JavaScript's `focus()` call (defaults to `yes`).
  - __suppressesIncrementalRendering__: Set to `yes` or `no` to wait until all new view content is received before being rendered (defaults to `no`).
  - __presentationstyle__:  Set to `pagesheet`, `formsheet` or `fullscreen` to set the [presentation style](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/modalPresentationStyle) (defaults to `fullscreen`).
  - __transitionstyle__: Set to `fliphorizontal`, `crossdissolve` or `coververtical` to set the [transition style](http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/modalTransitionStyle) (defaults to `coververtical`).
  - __toolbarposition__: Set to `top` or `bottom` (default is `bottom`). Causes the toolbar to be at the top or bottom of the window.
  - __hidespinner__: Set to `yes` or `no` to change the visibility of the loading indicator (defaults to `no`).
  
Example:
```dart
inAppBrowser.open('https://flutter.io/', '_blank', 'location=yes,hideurlbar=yes');
inAppBrowser.open('https://www.google.com/', '_blank', 'location=yes,toolbarposition=top,disallowoverscroll=yes');
``` 

### Events

Event fires when the `InAppBrowser` starts to load an `url`.
```dart
  @override
  void onLoadStart(String url) {
    super.onLoadStart(url);
  }
```

Event fires when the `InAppBrowser` finishes loading an `url`.
```dart
  @override
  void onLoadStop(String url) {
    super.onLoadStop(url);
  }
```

Event fires when the `InAppBrowser` encounters an error loading an `url`.
```dart
  @override
  void onLoadError(String url, String code, String message) {
    super.onLoadStop(url);
  }
```

Event fires when the `InAppBrowser` window is closed.
```dart
  @override
  void onExit() {
    super.onExit();
  }
```

### InAppBrowser.show

Displays an `InAppBrowser` window that was opened hidden. Calling this has no effect if the `InAppBrowser` was already visible.

Example:
```dart
inAppBrowser.show();
``` 

### InAppBrowser.hide

Hides the `InAppBrowser` window. Calling this has no effect if the `InAppBrowser` was already hidden.

Example:
```dart
inAppBrowser.hide();
``` 

### InAppBrowser.close

Closes the`InAppBrowser` window.

Example:
```dart
inAppBrowser.close();
``` 

### InAppBrowser.injectScriptCode

Injects JavaScript code into the `InAppBrowser` window. (Only available when the target is set to `_blank` or to `_self`)

Example:
```dart
inAppBrowser.injectScriptCode("""
  alert("JavaScript injected");
""");
``` 

### InAppBrowser.injectScriptFile

Injects a JavaScript file into the `InAppBrowser` window. (Only available when the target is set to `_blank` or to `_self`)

Example:
```dart
inAppBrowser.injectScriptFile("https://code.jquery.com/jquery-3.3.1.min.js");
inAppBrowser.injectScriptCode("""
  \$( "body" ).html( "Next Step..." )
""");
``` 

### InAppBrowser.injectStyleCode

Injects CSS into the `InAppBrowser` window. (Only available when the target is set to `_blank` or to `_self`)

Example:
```dart
inAppBrowser.injectStyleCode("""
    body {
      background-color: #3c3c3c;
    }
""");
``` 

### InAppBrowser.injectStyleFile

Injects a CSS file into the `InAppBrowser` window. (Only available when the target is set to `_blank` or to `_self`)

Example:
```dart
inAppBrowser.injectStyleFile("https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css");
``` 

## Screenshots:

iOS:

![ios](https://user-images.githubusercontent.com/5956938/45523056-52c7c980-b7c7-11e8-8bf1-488c9c8033bf.gif)

Android:

![android](https://user-images.githubusercontent.com/5956938/45523058-55c2ba00-b7c7-11e8-869c-c1738711933f.gif)
