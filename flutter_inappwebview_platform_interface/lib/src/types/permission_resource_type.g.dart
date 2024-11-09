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

  ///Indicates permission to play audio and video automatically on sites.
  ///This permission affects the autoplay attribute and play method of the audio
  ///and video HTML elements, and the start method of the Web Audio API.
  ///See the [Autoplay guide for media and Web Audio APIs](https://developer.mozilla.org/docs/Web/Media/Autoplay_guide)
  ///for details.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_AUTOPLAY](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final AUTOPLAY =
      PermissionResourceType._internalMultiPlatform('AUTOPLAY', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 9;
      default:
        break;
    }
    return null;
  });

  ///Resource belongs to video capture device, like camera.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PermissionRequest.RESOURCE_VIDEO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE))
  ///- iOS 15.0+ ([Official API - WKMediaCaptureType.camera](https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera))
  ///- MacOS 12.0+ ([Official API - WKMediaCaptureType.camera](https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera))
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_CAMERA](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final CAMERA =
      PermissionResourceType._internalMultiPlatform('CAMERA', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.VIDEO_CAPTURE';
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 0;
      case TargetPlatform.windows:
        return 2;
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

  ///Indicates permission to read the system clipboard without a user gesture.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_CLIPBOARD_READ](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final CLIPBOARD_READ =
      PermissionResourceType._internalMultiPlatform('CLIPBOARD_READ', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 6;
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

  ///Indicates permission to read and write to files or folders on the device.
  ///Permission is requested when developers use the [File System Access API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API)
  ///to show the file or folder picker to the end user, and then request
  ///"readwrite" permission for the user's selection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_FILE_READ_WRITE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final FILE_READ_WRITE =
      PermissionResourceType._internalMultiPlatform('FILE_READ_WRITE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 8;
      default:
        break;
    }
    return null;
  });

  ///Indicates permission to access geolocation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_GEOLOCATION](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final GEOLOCATION =
      PermissionResourceType._internalMultiPlatform('GEOLOCATION', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Indicates permission to use fonts on the device.
  ///Permission is requested when developers use the [Local Font Access API](https://wicg.github.io/local-font-access/)
  ///to query the system fonts available for styling web content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_LOCAL_FONTS](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final LOCAL_FONTS =
      PermissionResourceType._internalMultiPlatform('LOCAL_FONTS', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 10;
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
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_MICROPHONE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final MICROPHONE =
      PermissionResourceType._internalMultiPlatform('MICROPHONE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.AUDIO_CAPTURE';
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      case TargetPlatform.windows:
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
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_MIDI_SYSTEM_EXCLUSIVE_MESSAGES](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final MIDI_SYSEX =
      PermissionResourceType._internalMultiPlatform('MIDI_SYSEX', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android.webkit.resource.MIDI_SYSEX';
      case TargetPlatform.windows:
        return 11;
      default:
        break;
    }
    return null;
  });

  ///Indicates permission to automatically download multiple files.
  ///Permission is requested when multiple downloads are triggered in quick succession.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_MULTIPLE_AUTOMATIC_DOWNLOADS](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final MULTIPLE_AUTOMATIC_DOWNLOADS =
      PermissionResourceType._internalMultiPlatform(
          'MULTIPLE_AUTOMATIC_DOWNLOADS', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 7;
      default:
        break;
    }
    return null;
  });

  ///Indicates permission to send web notifications.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_NOTIFICATIONS](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final NOTIFICATIONS =
      PermissionResourceType._internalMultiPlatform('NOTIFICATIONS', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///Indicates permission to access generic sensor. Generic Sensor covers ambient-light-sensor, accelerometer, gyroscope, and magnetometer.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_OTHER_SENSORS](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final OTHER_SENSORS =
      PermissionResourceType._internalMultiPlatform('OTHER_SENSORS', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 5;
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

  ///Indicates an unknown permission.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_UNKNOWN_PERMISSION](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final UNKNOWN =
      PermissionResourceType._internalMultiPlatform('UNKNOWN', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Indicates permission to open and place windows on the screen.
  ///Permission is requested when developers use the [Multi-Screen Window Placement API](https://www.w3.org/TR/window-placement/)
  ///to get screen details.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PERMISSION_KIND_WINDOW_MANAGEMENT](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind))
  static final WINDOW_MANAGEMENT =
      PermissionResourceType._internalMultiPlatform('WINDOW_MANAGEMENT', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 12;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PermissionResourceType].
  static final Set<PermissionResourceType> values = [
    PermissionResourceType.AUTOPLAY,
    PermissionResourceType.CAMERA,
    PermissionResourceType.CAMERA_AND_MICROPHONE,
    PermissionResourceType.CLIPBOARD_READ,
    PermissionResourceType.DEVICE_ORIENTATION_AND_MOTION,
    PermissionResourceType.FILE_READ_WRITE,
    PermissionResourceType.GEOLOCATION,
    PermissionResourceType.LOCAL_FONTS,
    PermissionResourceType.MICROPHONE,
    PermissionResourceType.MIDI_SYSEX,
    PermissionResourceType.MULTIPLE_AUTOMATIC_DOWNLOADS,
    PermissionResourceType.NOTIFICATIONS,
    PermissionResourceType.OTHER_SENSORS,
    PermissionResourceType.PROTECTED_MEDIA_ID,
    PermissionResourceType.UNKNOWN,
    PermissionResourceType.WINDOW_MANAGEMENT,
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

  /// Gets a possible [PermissionResourceType] instance value with name [name].
  ///
  /// Goes through [PermissionResourceType.values] looking for a value with
  /// name [name], as reported by [PermissionResourceType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PermissionResourceType? byName(String? name) {
    if (name != null) {
      try {
        return PermissionResourceType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PermissionResourceType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PermissionResourceType> asNameMap() =>
      <String, PermissionResourceType>{
        for (final value in PermissionResourceType.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [dynamic] native value.
  dynamic toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'AUTOPLAY':
        return 'AUTOPLAY';
      case 'CAMERA':
        return 'CAMERA';
      case 'CAMERA_AND_MICROPHONE':
        return 'CAMERA_AND_MICROPHONE';
      case 'CLIPBOARD_READ':
        return 'CLIPBOARD_READ';
      case 'DEVICE_ORIENTATION_AND_MOTION':
        return 'DEVICE_ORIENTATION_AND_MOTION';
      case 'FILE_READ_WRITE':
        return 'FILE_READ_WRITE';
      case 'GEOLOCATION':
        return 'GEOLOCATION';
      case 'LOCAL_FONTS':
        return 'LOCAL_FONTS';
      case 'MICROPHONE':
        return 'MICROPHONE';
      case 'MIDI_SYSEX':
        return 'MIDI_SYSEX';
      case 'MULTIPLE_AUTOMATIC_DOWNLOADS':
        return 'MULTIPLE_AUTOMATIC_DOWNLOADS';
      case 'NOTIFICATIONS':
        return 'NOTIFICATIONS';
      case 'OTHER_SENSORS':
        return 'OTHER_SENSORS';
      case 'PROTECTED_MEDIA_ID':
        return 'PROTECTED_MEDIA_ID';
      case 'UNKNOWN':
        return 'UNKNOWN';
      case 'WINDOW_MANAGEMENT':
        return 'WINDOW_MANAGEMENT';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
