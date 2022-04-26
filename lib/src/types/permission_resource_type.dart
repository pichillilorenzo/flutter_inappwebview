import 'package:flutter/foundation.dart';

///Class that represents a type of resource used to ask user's permission.
class PermissionResourceType {
  final dynamic _value;

  const PermissionResourceType._internal(this._value);

  ///Set of all values of [PermissionResourceType].
  static final Set<PermissionResourceType> values = [
    PermissionResourceType.RESOURCE_AUDIO_CAPTURE,
    PermissionResourceType.RESOURCE_MIDI_SYSEX,
    PermissionResourceType.RESOURCE_PROTECTED_MEDIA_ID,
    PermissionResourceType.RESOURCE_VIDEO_CAPTURE,
    PermissionResourceType.CAMERA,
    PermissionResourceType.MICROPHONE,
    PermissionResourceType.CAMERA_AND_MICROPHONE,
    PermissionResourceType.DEVICE_ORIENTATION_AND_MOTION,
  ].toSet();

  static final Set<PermissionResourceType> _androidValues = [
    PermissionResourceType.RESOURCE_AUDIO_CAPTURE,
    PermissionResourceType.RESOURCE_MIDI_SYSEX,
    PermissionResourceType.RESOURCE_PROTECTED_MEDIA_ID,
    PermissionResourceType.RESOURCE_VIDEO_CAPTURE,
  ].toSet();

  static final Set<PermissionResourceType> _appleValues =
  <PermissionResourceType>[
    PermissionResourceType.CAMERA,
    PermissionResourceType.MICROPHONE,
    PermissionResourceType.CAMERA_AND_MICROPHONE,
    PermissionResourceType.DEVICE_ORIENTATION_AND_MOTION,
  ].toSet();

  ///Gets a possible [PermissionResourceType] instance from a value.
  static PermissionResourceType? fromValue(dynamic value) {
    if (value != null) {
      try {
        Set<PermissionResourceType> valueList =
        <PermissionResourceType>[].toSet();
        if (defaultTargetPlatform == TargetPlatform.android) {
          valueList = PermissionResourceType._androidValues;
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          valueList = PermissionResourceType._appleValues;
        }
        return valueList.firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets the value.
  dynamic toValue() => _value;

  @override
  String toString() {
    if (_value is String) {
      return _value;
    }
    switch (_value) {
      case 0:
        return "CAMERA";
      case 1:
        return "MICROPHONE";
      case 2:
        return "CAMERA_AND_MICROPHONE";
      default:
        return "";
    }
  }

  ///Resource belongs to audio capture device, like microphone.
  ///
  ///**NOTE**: available only on Android.
  static const RESOURCE_AUDIO_CAPTURE = const PermissionResourceType._internal(
      'android.webkit.resource.AUDIO_CAPTURE');

  ///Resource will allow sysex messages to be sent to or received from MIDI devices.
  ///These messages are privileged operations, e.g. modifying sound libraries and sampling data, or even updating the MIDI device's firmware.
  ///Permission may be requested for this resource in API levels 21 and above, if the Android device has been updated to WebView 45 or above.
  ///
  ///**NOTE**: available only on Android.
  static const RESOURCE_MIDI_SYSEX = const PermissionResourceType._internal(
      'android.webkit.resource.MIDI_SYSEX');

  ///Resource belongs to protected media identifier. After the user grants this resource, the origin can use EME APIs to generate the license requests.
  ///
  ///**NOTE**: available only on Android.
  static const RESOURCE_PROTECTED_MEDIA_ID =
  const PermissionResourceType._internal(
      'android.webkit.resource.PROTECTED_MEDIA_ID');

  ///Resource belongs to video capture device, like camera.
  ///
  ///**NOTE**: available only on Android.
  static const RESOURCE_VIDEO_CAPTURE = const PermissionResourceType._internal(
      'android.webkit.resource.VIDEO_CAPTURE');

  ///A media device that can capture video.
  ///
  ///**NOTE**: available only on iOS.
  static const CAMERA = const PermissionResourceType._internal(0);

  ///A media device that can capture audio.
  ///
  ///**NOTE**: available only on iOS.
  static const MICROPHONE = const PermissionResourceType._internal(1);

  ///A media device or devices that can capture audio and video.
  ///
  ///**NOTE**: available only on iOS.
  static const CAMERA_AND_MICROPHONE =
  const PermissionResourceType._internal(2);

  ///Resource belongs to the device’s orientation and motion.
  ///
  ///**NOTE**: available only on iOS.
  static const DEVICE_ORIENTATION_AND_MOTION =
  const PermissionResourceType._internal('deviceOrientationAndMotion');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}