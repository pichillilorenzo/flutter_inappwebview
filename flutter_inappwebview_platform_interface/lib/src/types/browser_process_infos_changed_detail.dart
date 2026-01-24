import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../webview_environment/platform_webview_environment.dart';
import 'browser_process_info.dart';
import 'enum_method.dart';

part 'browser_process_infos_changed_detail.g.dart';

///An object that contains information for the [PlatformWebViewEnvironment.onProcessInfosChanged] event.
@ExchangeableObject()
class BrowserProcessInfosChangedDetail_ {
  ///The kind of the process.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  List<BrowserProcessInfo_> infos;

  BrowserProcessInfosChangedDetail_({this.infos = const []});
}
