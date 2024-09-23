import 'dart:js_interop';
import 'package:web/web.dart';

extension type JSSize._(JSObject _) implements JSObject {
  external JSNumber? get height;
  external JSNumber? get width;
}

extension type JSWebView._(JSObject _) implements JSObject {
  external JSAny get viewId;
  external JSString get iframeId;
  external HTMLIFrameElement get iframe;
  external HTMLDivElement get iframeContainer;
  external void prepare(JSAny? settings);
  external void setSettings(JSAny? newSettings);
  external void reload();
  external void goBack();
  external void goForward();
  external void goBackOrForward(JSNumber steps);
  external JSString? evaluateJavascript(JSString source);
  external void stopLoading();
  external JSString? getUrl();
  external JSString? getTitle();
  external void injectJavascriptFileFromUrl(JSString urlFile, JSAny? scriptHtmlTagAttributes);
  external void injectCSSCode(JSString source);
  external void injectCSSFileFromUrl(JSString urlFile, JSAny? cssLinkHtmlTagAttributes);
  external void scrollTo(JSNumber x, JSNumber y, JSBoolean animated);
  external void scrollBy(JSNumber x, JSNumber y, JSBoolean animated);
  external void printCurrentPage();
  external JSNumber? getContentHeight();
  external JSNumber? getContentWidth();
  external JSPromise<JSString?>? getSelectedText();
  external JSNumber? getScrollX();
  external JSNumber? getScrollY();
  external JSBoolean isSecureContext();
  external JSBoolean canScrollVertically();
  external JSBoolean canScrollHorizontally();
  external JSSize getSize();
}

@JS('window.flutter_inappwebview')
external FlutterInAppWebViewBridge? get flutterInAppWebView;

extension type FlutterInAppWebViewBridge._(JSObject _) implements JSObject {
  external JSObject webViews;
  external JSWebView createFlutterInAppWebView(JSAny viewId, HTMLIFrameElement iframe, HTMLDivElement iframeContainer);
  external JSString getCookieExpirationDate(num timestamp);
  /// Allows assigning a function to be callable from `window.flutter_inappwebview.nativeCommunication()`
  external JSFunction nativeCommunication;
}
