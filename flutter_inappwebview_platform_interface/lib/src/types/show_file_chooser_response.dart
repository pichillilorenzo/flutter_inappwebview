import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'enum_method.dart';

part 'show_file_chooser_response.g.dart';

///Class used in the [PlatformWebViewCreationParams.onShowFileChooser] method.
@ExchangeableObject()
class ShowFileChooserResponse_ {
  ///Whether the file chooser request was handled by the client.
  final bool handledByClient;

  ///The file paths of the selected files or `null` to cancel the request.
  ///Each file path must be a valid file URI using the "file:" scheme.
  final List<String>? filePaths;

  ShowFileChooserResponse_({required this.handledByClient, this.filePaths});
}
