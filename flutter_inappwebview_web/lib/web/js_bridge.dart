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
  external void injectJavascriptFileFromUrl(
      JSString urlFile, JSAny? scriptHtmlTagAttributes);
  external void injectCSSCode(JSString source);
  external void injectCSSFileFromUrl(
      JSString urlFile, JSAny? cssLinkHtmlTagAttributes);
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

@JS('window.flutter_inappwebview_plugin')
external FlutterInAppWebViewBridge? get flutterInAppWebView;

extension type FlutterInAppWebViewBridge._(JSObject _) implements JSObject {
  external JSWebView createFlutterInAppWebView(
      JSAny viewId,
      HTMLIFrameElement iframe,
      HTMLDivElement iframeContainer,
      String bridgeSecret);
  external JSString getCookieExpirationDate(num timestamp);

  external JSFunction nativeAsyncCommunication;
  external JSFunction nativeSyncCommunication;
}

@JS('Object.freeze')
external JSObject Object_freeze(JSObject obj);

@JS('Object.isFrozen')
external JSBoolean Object_isFrozen(JSObject obj);
