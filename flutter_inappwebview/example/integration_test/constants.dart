import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final TEST_URL_ABOUT_BLANK = WebUri('about:blank');
final TEST_CROSS_PLATFORM_URL_1 = WebUri('https://flutter.dev/');
final TEST_CROSS_PLATFORM_URL_2 = WebUri('https://www.bing.com/');
final TEST_URL_1 = WebUri('https://github.com/flutter');
final TEST_URL_2 = WebUri('https://www.google.com/');
final TEST_URL_3 = WebUri(
  'https://github.com/pichillilorenzo/flutter_inappwebview',
);
final TEST_URL_4 = WebUri('https://www.youtube.com/');
final TEST_URL_EXAMPLE = WebUri('https://www.example.com/');
final TEST_URL_HTTP_EXAMPLE = WebUri('http://www.example.com/');
final TEST_URL_404 = WebUri('https://google.com/404');
final TEST_WEB_PLATFORM_BASE_URL = WebUri(
  Uri.base.toString().replaceFirst("/#/", "/"),
);
final TEST_WEB_PLATFORM_URL_1 = WebUri(
  TEST_WEB_PLATFORM_BASE_URL.toString() + 'page.html',
);
final TEST_WEB_PLATFORM_URL_2 = WebUri(
  TEST_WEB_PLATFORM_BASE_URL.toString() + 'page-2.html',
);
final TEST_WEB_PLATFORM_URL_3 = WebUri(
  TEST_WEB_PLATFORM_BASE_URL.toString() + 'heavy-page.html',
);
final TEST_NOT_A_WEBSITE_URL = WebUri('https://www.notawebsite..com/');
final TEST_CHROME_SAFE_BROWSING_MALWARE = WebUri(
  'chrome://safe-browsing/match?type=malware',
);
final TEST_PERMISSION_SITE = WebUri('https://permission.site/');
final TEST_SERVICE_WORKER_URL = WebUri(
  'https://mdn.github.io/dom-examples/service-worker/simple-service-worker/',
);
final TEST_WEBVIEW_ASSET_LOADER_DOMAIN = 'my.custom.domain.com';
final TEST_WEBVIEW_ASSET_LOADER_URL = WebUri(
  'https://$TEST_WEBVIEW_ASSET_LOADER_DOMAIN/assets/flutter_assets/test_assets/website/index.html',
);
final TEST_TWA_URL = WebUri(
  'https://inappwebview.dev/test-twa-postmessage.html',
);
final TEST_CUSTOM_TABS_POST_MESSAGE_URL = WebUri(
  'https://inappwebview.dev/test-twa-postmessage.html',
);
