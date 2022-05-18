import 'package:flutter/foundation.dart';

///Class that represents a type of resource used to ask user's permission.
class PermissionResourceType {
  final String _value;
  final dynamic _nativeValue;

  const PermissionResourceType._internal(this._value, this._nativeValue);

  ///Set of all values of [PermissionResourceType].
  static final Set<PermissionResourceType> values = [
    PermissionResourceType.MIDI_SYSEX,
    PermissionResourceType.PROTECTED_MEDIA_ID,
    PermissionResourceType.CAMERA,
    PermissionResourceType.MICROPHONE,
    PermissionResourceType.CAMERA_AND_MICROPHONE,
    PermissionResourceType.DEVICE_ORIENTATION_AND_MOTION,
  ].toSet();

  ///Gets a possible [PermissionResourceType] instance from a [String] value.
  static PermissionResourceType? fromValue(String? value) {
    if (value != null) {
      try {
        return PermissionResourceType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PermissionResourceType] instance from a native value.
  static PermissionResourceType? fromNativeValue(dynamic value) {
    if (value != null) {
      try {
        return PermissionResourceType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets native value.
  dynamic toNativeValue() => _nativeValue;

  @override
  String toString() => _value;

  ///Resource belongs to audio capture device, like microphone.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_AUDIO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_AUDIO_CAPTURE))
  ///- iOS ([Official API - WKMediaCaptureType.microphone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone))
  static final MICROPHONE = PermissionResourceType._internal(
      'MICROPHONE',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 'android.webkit.resource.AUDIO_CAPTURE'
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? 1
              : null));

  ///Resource will allow sysex messages to be sent to or received from MIDI devices.
  ///These messages are privileged operations, e.g. modifying sound libraries and sampling data, or even updating the MIDI device's firmware.
  ///Permission may be requested for this resource in API levels 21 and above, if the Android device has been updated to WebView 45 or above.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_MIDI_SYSEX](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_MIDI_SYSEX))
  static final MIDI_SYSEX = PermissionResourceType._internal(
      'MIDI_SYSEX',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 'android.webkit.resource.MIDI_SYSEX'
          : null);

  ///Resource belongs to protected media identifier. After the user grants this resource, the origin can use EME APIs to generate the license requests.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_PROTECTED_MEDIA_ID))
  static final PROTECTED_MEDIA_ID = PermissionResourceType._internal(
      'PROTECTED_MEDIA_ID',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 'android.webkit.resource.PROTECTED_MEDIA_ID'
          : null);

  ///Resource belongs to video capture device, like camera.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_VIDEO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE))
  ///- iOS ([Official API - WKMediaCaptureType.camera](https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera))
  static final CAMERA = PermissionResourceType._internal(
      'CAMERA',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 'android.webkit.resource.VIDEO_CAPTURE'
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? 0
              : null));

  ///A media device or devices that can capture audio and video.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKMediaCaptureType.cameraAndMicrophone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone))
  static final CAMERA_AND_MICROPHONE = PermissionResourceType._internal(
      'CAMERA_AND_MICROPHONE',
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? 2
          : null);

  ///Resource belongs to the device’s orientation and motion.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  static final DEVICE_ORIENTATION_AND_MOTION = PermissionResourceType._internal(
      'DEVICE_ORIENTATION_AND_MOTION',
      (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)
          ? 'deviceOrientationAndMotion'
          : null);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
