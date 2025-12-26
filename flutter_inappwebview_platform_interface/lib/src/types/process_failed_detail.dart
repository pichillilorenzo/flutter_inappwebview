import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'frame_info.dart';
import 'process_failed_kind.dart';
import 'process_failed_reason.dart';
import 'enum_method.dart';

part 'process_failed_detail.g.dart';

///An object that contains information about a frame on a webpage.
@ExchangeableObject()
class ProcessFailedDetail_ {
  ///The kind of process failure that has occurred.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  ProcessFailedKind_ kind;

  ///The exit code of the failing process, for telemetry purposes.
  ///
  ///The exit code is always STILL_ACTIVE (259) when [ProcessFailedKind.RENDER_PROCESS_UNRESPONSIVE].
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  int? exitCode;

  ///Description of the process assigned by the WebView2 Runtime.
  ///
  ///This is a technical English term appropriate for logging or development purposes, and not localized for the end user.
  ///It applies to utility processes (for example, "Audio Service", "Video Capture") and plugin processes (for example, "Flash").
  ///The returned [processDescription] is empty if the WebView2 Runtime did not assign a description to the process.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  String? processDescription;

  ///The reason for the process failure.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  ProcessFailedReason_? reason;

  ///This property is the full path of the module that caused the crash in cases of Windows Code Integrity failures.
  ///
  ///Windows Code Integrity is a feature that verifies the integrity and authenticity of dynamic-link libraries (DLLs) on Windows systems.
  ///It ensures that only trusted code can run on the system and prevents unauthorized or malicious modifications.
  ///When ProcessFailed occurred due to a failed Code Integrity check, this property returns the full path of the file that was prevented from loading on the system.
  ///The webview2 process which tried to load the DLL will fail with exit code STATUS_INVALID_IMAGE_HASH(-1073740760).
  ///A file can fail integrity check for various reasons, such as:
  ///- It has an invalid or missing signature that does not match the publisher or signer of the file.
  ///- It has been tampered with or corrupted by malware or other software.
  ///- It has been blocked by an administrator or a security policy. This property always will be the empty string if failure is not caused by STATUS_INVALID_IMAGE_HASH.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  String? failureSourceModulePath;

  ///The collection of [FrameInfo]s for frames in the WebView that were being rendered by the failed process.
  ///
  ///The content in these frames is replaced with an error page.
  ///This is only available when [ProcessFailedKind] is [ProcessFailedKind.FRAME_RENDER_PROCESS_EXITED];
  ///frames is null for all other process failure kinds, including the case in which the failed process was the renderer
  ///for the main frame and subframes within it, for which the failure kind is [ProcessFailedKind.RENDER_PROCESS_EXITED].
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  List<FrameInfo_>? frameInfos;

  ProcessFailedDetail_({
    required this.kind,
    this.exitCode,
    this.processDescription,
    this.reason,
    this.failureSourceModulePath,
    this.frameInfos,
  });
}
