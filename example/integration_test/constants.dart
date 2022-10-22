final TEST_URL_ABOUT_BLANK = Uri.parse('about:blank');
final TEST_CROSS_PLATFORM_URL_1 = Uri.parse('https://flutter.dev/');
final TEST_CROSS_PLATFORM_URL_2 = Uri.parse('https://www.bing.com/');
final TEST_URL_1 = Uri.parse('https://github.com/flutter');
final TEST_URL_2 = Uri.parse('https://www.google.com/');
final TEST_URL_3 =
    Uri.parse('https://github.com/pichillilorenzo/flutter_inappwebview');
final TEST_URL_4 = Uri.parse('https://www.youtube.com/');
final TEST_URL_EXAMPLE = Uri.parse('https://www.example.com/');
final TEST_URL_HTTP_EXAMPLE = Uri.parse('http://www.example.com/');
final TEST_URL_404 = Uri.parse('https://google.com/404');
final TEST_WEB_PLATFORM_BASE_URL =
    Uri.parse(Uri.base.toString().replaceFirst("/#/", "/"));
final TEST_WEB_PLATFORM_URL_1 =
    Uri.parse(TEST_WEB_PLATFORM_BASE_URL.toString() + 'page.html');
final TEST_WEB_PLATFORM_URL_2 =
    Uri.parse(TEST_WEB_PLATFORM_BASE_URL.toString() + 'page-2.html');
final TEST_WEB_PLATFORM_URL_3 =
    Uri.parse(TEST_WEB_PLATFORM_BASE_URL.toString() + 'heavy-page.html');
final TEST_NOT_A_WEBSITE_URL = Uri.parse('https://www.notawebsite..com/');
final TEST_CHROME_SAFE_BROWSING_MALWARE =
    Uri.parse('chrome://safe-browsing/match?type=malware');
final TEST_PERMISSION_SITE = Uri.parse('https://permission.site/');
final TEST_SERVICE_WORKER_URL = Uri.parse(
    'https://mdn.github.io/dom-examples/service-worker/simple-service-worker/');
final TEST_WEBVIEW_ASSET_LOADER_DOMAIN = 'my.custom.domain.com';
final TEST_WEBVIEW_ASSET_LOADER_URL = Uri.parse(
    'https://$TEST_WEBVIEW_ASSET_LOADER_DOMAIN/assets/flutter_assets/assets/website/index.html');
