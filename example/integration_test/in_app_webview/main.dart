import 'package:flutter_test/flutter_test.dart';

import 'audio_playback_policy.dart';
import 'get_title.dart';
import 'initial_url_request.dart';
import 'intercept_ajax_request.dart';
import 'javascript_code_evaluation.dart';
import 'javascript_handler.dart';
import 'load_file_url.dart';
import 'load_url.dart';
import 'on_load_error.dart';
import 'programmatic_scroll.dart';
import 'resize_webview.dart';
import 'set_custom_useragent.dart';
import 'set_get_settings.dart';
import 'should_override_url_loading.dart';
import 'video_playback_policy.dart';
import 'webview_windows.dart';

void main() {
  group('InAppWebView', () {
    initialUrlRequest();
    setGetSettings();
    javascriptCodeEvaluation();
    loadUrl();
    loadFileUrl();
    javascriptHandler();
    resizeWebView();
    setCustomUserAgent();
    videoPlaybackPolicy();
    audioPlaybackPolicy();
    getTitle();
    programmaticScroll();
    shouldOverrideUrlLoading();
    onLoadError();
    webViewWindows();
    interceptAjaxRequest();
  });
}