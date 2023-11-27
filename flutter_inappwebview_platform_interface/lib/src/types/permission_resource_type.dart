import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'permission_resource_type.g.dart';

///Class that represents a type of resource used to ask user's permission.
@ExchangeableEnum()
class PermissionResourceType_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final dynamic _nativeValue = null;
  const PermissionResourceType_._internal(this._value);

  ///Resource belongs to audio capture device, like microphone.
  @EnumSupportedPlatforms(platforms: [
    EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_AUDIO_CAPTURE',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_AUDIO_CAPTURE',
        value: 'android.webkit.resource.AUDIO_CAPTURE'),
    EnumIOSPlatform(
        available: "15.0",
        apiName: 'WKMediaCaptureType.microphone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone',
        value: 1),
    EnumMacOSPlatform(
        available: "12.0",
        apiName: 'WKMediaCaptureType.microphone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone',
        value: 1)
  ])
  static const MICROPHONE = PermissionResourceType_._internal('MICROPHONE');

  ///Resource will allow sysex messages to be sent to or received from MIDI devices.
  ///These messages are privileged operations, e.g. modifying sound libraries and sampling data, or even updating the MIDI device's firmware.
  ///Permission may be requested for this resource in API levels 21 and above, if the Android device has been updated to WebView 45 or above.
  @EnumSupportedPlatforms(platforms: [
    EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_MIDI_SYSEX',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_MIDI_SYSEX',
        value: 'android.webkit.resource.MIDI_SYSEX'),
  ])
  static const MIDI_SYSEX = PermissionResourceType_._internal('MIDI_SYSEX');

  ///Resource belongs to protected media identifier. After the user grants this resource, the origin can use EME APIs to generate the license requests.
  @EnumSupportedPlatforms(platforms: [
    EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_PROTECTED_MEDIA_ID',
        value: 'android.webkit.resource.PROTECTED_MEDIA_ID'),
  ])
  static const PROTECTED_MEDIA_ID =
      PermissionResourceType_._internal('PROTECTED_MEDIA_ID');

  ///Resource belongs to video capture device, like camera.
  @EnumSupportedPlatforms(platforms: [
    EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_VIDEO_CAPTURE',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE',
        value: 'android.webkit.resource.VIDEO_CAPTURE'),
    EnumIOSPlatform(
        available: "15.0",
        apiName: 'WKMediaCaptureType.camera',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera',
        value: 0),
    EnumMacOSPlatform(
        available: "12.0",
        apiName: 'WKMediaCaptureType.camera',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera',
        value: 0)
  ])
  static const CAMERA = PermissionResourceType_._internal('CAMERA');

  ///A media device or devices that can capture audio and video.
  @EnumSupportedPlatforms(platforms: [
    EnumIOSPlatform(
        available: "15.0",
        apiName: 'WKMediaCaptureType.cameraAndMicrophone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone',
        value: 2),
    EnumMacOSPlatform(
        available: "12.0",
        apiName: 'WKMediaCaptureType.cameraAndMicrophone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone',
        value: 2)
  ])
  static const CAMERA_AND_MICROPHONE =
      PermissionResourceType_._internal('CAMERA_AND_MICROPHONE');

  ///Resource belongs to the device’s orientation and motion.
  @EnumSupportedPlatforms(platforms: [
    EnumIOSPlatform(available: "15.0", value: 'deviceOrientationAndMotion'),
    EnumMacOSPlatform(available: "12.0", value: 'deviceOrientationAndMotion')
  ])
  static const DEVICE_ORIENTATION_AND_MOTION =
      PermissionResourceType_._internal('DEVICE_ORIENTATION_AND_MOTION');
}
