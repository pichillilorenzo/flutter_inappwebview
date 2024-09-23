// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_resource_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a type of resource used to ask user's permission.
class PermissionResourceType {
  final String _value;
  final dynamic _nativeValue;
  const PermissionResourceType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PermissionResourceType._internalMultiPlatform(
          String value, Function nativeValue) =>
      PermissionResourceType._internal(value, nativeValue());

  ///Resource belongs to video capture device, like camera.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_VIDEO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE))
  ///- iOS 15.0+ ([Official API - WKMediaCaptureType.camera](https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera))
  ///- MacOS 12.0+ ([Official API - WKMediaCaptureType.camera](https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera))
  static final CAMERA =
      PermissionResourceType._internalMultiPlatform('CAMERA', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.VIDEO_CAPTURE';
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///A media device or devices that can capture audio and video.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 15.0+ ([Official API - WKMediaCaptureType.cameraAndMicrophone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone))
  ///- MacOS 12.0+ ([Official API - WKMediaCaptureType.cameraAndMicrophone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone))
  static final CAMERA_AND_MICROPHONE =
      PermissionResourceType._internalMultiPlatform('CAMERA_AND_MICROPHONE',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 2;
      case TargetPlatform.macOS:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Resource belongs to the device’s orientation and motion.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 15.0+
  ///- MacOS 12.0+
  static final DEVICE_ORIENTATION_AND_MOTION =
      PermissionResourceType._internalMultiPlatform(
          'DEVICE_ORIENTATION_AND_MOTION', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'deviceOrientationAndMotion';
      case TargetPlatform.macOS:
        return 'deviceOrientationAndMotion';
      default:
        break;
    }
    return null;
  });

  ///Resource belongs to audio capture device, like microphone.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_AUDIO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_AUDIO_CAPTURE))
  ///- iOS 15.0+ ([Official API - WKMediaCaptureType.microphone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone))
  ///- MacOS 12.0+ ([Official API - WKMediaCaptureType.microphone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone))
  static final MICROPHONE =
      PermissionResourceType._internalMultiPlatform('MICROPHONE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.AUDIO_CAPTURE';
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Resource will allow sysex messages to be sent to or received from MIDI devices.
  ///These messages are privileged operations, e.g. modifying sound libraries and sampling data, or even updating the MIDI device's firmware.
  ///Permission may be requested for this resource in API levels 21 and above, if the Android device has been updated to WebView 45 or above.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_MIDI_SYSEX](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_MIDI_SYSEX))
  static final MIDI_SYSEX =
      PermissionResourceType._internalMultiPlatform('MIDI_SYSEX', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.MIDI_SYSEX';
      default:
        break;
    }
    return null;
  });

  ///Resource belongs to protected media identifier. After the user grants this resource, the origin can use EME APIs to generate the license requests.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_PROTECTED_MEDIA_ID))
  static final PROTECTED_MEDIA_ID =
      PermissionResourceType._internalMultiPlatform('PROTECTED_MEDIA_ID', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.PROTECTED_MEDIA_ID';
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PermissionResourceType].
  static final Set<PermissionResourceType> values = [
    PermissionResourceType.CAMERA,
    PermissionResourceType.CAMERA_AND_MICROPHONE,
    PermissionResourceType.DEVICE_ORIENTATION_AND_MOTION,
    PermissionResourceType.MICROPHONE,
    PermissionResourceType.MIDI_SYSEX,
    PermissionResourceType.PROTECTED_MEDIA_ID,
  ].toSet();

  ///Gets a possible [PermissionResourceType] instance from [String] value.
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

  ///Gets [dynamic] native value.
  dynamic toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
