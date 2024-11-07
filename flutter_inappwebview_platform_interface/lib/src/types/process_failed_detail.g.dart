// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_failed_detail.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information about a frame on a webpage.
class ProcessFailedDetail {
  ///The exit code of the failing process, for telemetry purposes.
  ///
  ///The exit code is always STILL_ACTIVE (259) when [ProcessFailedKind.RENDER_PROCESS_UNRESPONSIVE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  int? exitCode;

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
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  String? failureSourceModulePath;

  ///The collection of [FrameInfo]s for frames in the WebView that were being rendered by the failed process.
  ///
  ///The content in these frames is replaced with an error page.
  ///This is only available when [ProcessFailedKind] is [ProcessFailedKind.FRAME_RENDER_PROCESS_EXITED];
  ///frames is null for all other process failure kinds, including the case in which the failed process was the renderer
  ///for the main frame and subframes within it, for which the failure kind is [ProcessFailedKind.RENDER_PROCESS_EXITED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  List<FrameInfo>? frameInfos;

  ///The kind of process failure that has occurred.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  ProcessFailedKind kind;

  ///Description of the process assigned by the WebView2 Runtime.
  ///
  ///This is a technical English term appropriate for logging or development purposes, and not localized for the end user.
  ///It applies to utility processes (for example, "Audio Service", "Video Capture") and plugin processes (for example, "Flash").
  ///The returned [processDescription] is empty if the WebView2 Runtime did not assign a description to the process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  String? processDescription;

  ///The reason for the process failure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  ProcessFailedReason? reason;
  ProcessFailedDetail(
      {this.exitCode,
      this.failureSourceModulePath,
      this.frameInfos,
      required this.kind,
      this.processDescription,
      this.reason});

  ///Gets a possible [ProcessFailedDetail] instance from a [Map] value.
  static ProcessFailedDetail? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ProcessFailedDetail(
      exitCode: map['exitCode'],
      failureSourceModulePath: map['failureSourceModulePath'],
      frameInfos: map['frameInfos'] != null
          ? List<FrameInfo>.from(map['frameInfos'].map((e) => FrameInfo.fromMap(
              e?.cast<String, dynamic>(),
              enumMethod: enumMethod)!))
          : null,
      kind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          ProcessFailedKind.fromNativeValue(map['kind']),
        EnumMethod.value => ProcessFailedKind.fromValue(map['kind']),
        EnumMethod.name => ProcessFailedKind.byName(map['kind'])
      }!,
      processDescription: map['processDescription'],
      reason: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          ProcessFailedReason.fromNativeValue(map['reason']),
        EnumMethod.value => ProcessFailedReason.fromValue(map['reason']),
        EnumMethod.name => ProcessFailedReason.byName(map['reason'])
      },
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "exitCode": exitCode,
      "failureSourceModulePath": failureSourceModulePath,
      "frameInfos":
          frameInfos?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "kind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => kind.toNativeValue(),
        EnumMethod.value => kind.toValue(),
        EnumMethod.name => kind.name()
      },
      "processDescription": processDescription,
      "reason": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => reason?.toNativeValue(),
        EnumMethod.value => reason?.toValue(),
        EnumMethod.name => reason?.name()
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ProcessFailedDetail{exitCode: $exitCode, failureSourceModulePath: $failureSourceModulePath, frameInfos: $frameInfos, kind: $kind, processDescription: $processDescription, reason: $reason}';
  }
}
