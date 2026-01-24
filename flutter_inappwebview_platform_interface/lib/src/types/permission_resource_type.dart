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
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_AUDIO_CAPTURE',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_AUDIO_CAPTURE',
        value: 'android.webkit.resource.AUDIO_CAPTURE',
      ),
      EnumIOSPlatform(
        available: "15.0",
        apiName: 'WKMediaCaptureType.microphone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone',
        value: 1,
      ),
      EnumMacOSPlatform(
        available: "12.0",
        apiName: 'WKMediaCaptureType.microphone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone',
        value: 1,
      ),
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_MICROPHONE',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 1,
      ),
    ],
  )
  static const MICROPHONE = PermissionResourceType_._internal('MICROPHONE');

  ///Resource will allow sysex messages to be sent to or received from MIDI devices.
  ///These messages are privileged operations, e.g. modifying sound libraries and sampling data, or even updating the MIDI device's firmware.
  ///Permission may be requested for this resource in API levels 21 and above, if the Android device has been updated to WebView 45 or above.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_MIDI_SYSEX',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_MIDI_SYSEX',
        value: 'android.webkit.resource.MIDI_SYSEX',
      ),
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_MIDI_SYSTEM_EXCLUSIVE_MESSAGES',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 11,
      ),
    ],
  )
  static const MIDI_SYSEX = PermissionResourceType_._internal('MIDI_SYSEX');

  ///Resource belongs to protected media identifier. After the user grants this resource, the origin can use EME APIs to generate the license requests.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_PROTECTED_MEDIA_ID',
        value: 'android.webkit.resource.PROTECTED_MEDIA_ID',
      ),
      EnumLinuxPlatform(
        apiName: 'WebKitMediaKeySystemPermissionRequest',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.MediaKeySystemPermissionRequest.html',
      ),
    ],
  )
  static const PROTECTED_MEDIA_ID = PermissionResourceType_._internal(
    'PROTECTED_MEDIA_ID',
  );

  ///Resource belongs to video capture device, like camera.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PermissionRequest.RESOURCE_VIDEO_CAPTURE',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE',
        value: 'android.webkit.resource.VIDEO_CAPTURE',
      ),
      EnumIOSPlatform(
        available: "15.0",
        apiName: 'WKMediaCaptureType.camera',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera',
        value: 0,
      ),
      EnumMacOSPlatform(
        available: "12.0",
        apiName: 'WKMediaCaptureType.camera',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera',
        value: 0,
      ),
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_CAMERA',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 2,
      ),
    ],
  )
  static const CAMERA = PermissionResourceType_._internal('CAMERA');

  ///A media device or devices that can capture audio and video.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        available: "15.0",
        apiName: 'WKMediaCaptureType.cameraAndMicrophone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone',
        value: 2,
      ),
      EnumMacOSPlatform(
        available: "12.0",
        apiName: 'WKMediaCaptureType.cameraAndMicrophone',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone',
        value: 2,
      ),
    ],
  )
  static const CAMERA_AND_MICROPHONE = PermissionResourceType_._internal(
    'CAMERA_AND_MICROPHONE',
  );

  ///Resource belongs to the device’s orientation and motion.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(available: "15.0", value: 'deviceOrientationAndMotion'),
      EnumMacOSPlatform(available: "12.0", value: 'deviceOrientationAndMotion'),
    ],
  )
  static const DEVICE_ORIENTATION_AND_MOTION =
      PermissionResourceType_._internal('DEVICE_ORIENTATION_AND_MOTION');

  ///Indicates an unknown permission.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_UNKNOWN_PERMISSION',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 0,
      ),
    ],
  )
  static const UNKNOWN = PermissionResourceType_._internal('UNKNOWN');

  ///Indicates permission to access geolocation.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_GEOLOCATION',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 3,
      ),
    ],
  )
  static const GEOLOCATION = PermissionResourceType_._internal('GEOLOCATION');

  ///Indicates permission to send web notifications.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_NOTIFICATIONS',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 4,
      ),
    ],
  )
  static const NOTIFICATIONS = PermissionResourceType_._internal(
    'NOTIFICATIONS',
  );

  ///Indicates permission to access generic sensor. Generic Sensor covers ambient-light-sensor, accelerometer, gyroscope, and magnetometer.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_OTHER_SENSORS',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 5,
      ),
    ],
  )
  static const OTHER_SENSORS = PermissionResourceType_._internal(
    'OTHER_SENSORS',
  );

  ///Indicates permission to read the system clipboard without a user gesture.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_CLIPBOARD_READ',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 6,
      ),
    ],
  )
  static const CLIPBOARD_READ = PermissionResourceType_._internal(
    'CLIPBOARD_READ',
  );

  ///Indicates permission to automatically download multiple files.
  ///Permission is requested when multiple downloads are triggered in quick succession.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_MULTIPLE_AUTOMATIC_DOWNLOADS',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 7,
      ),
    ],
  )
  static const MULTIPLE_AUTOMATIC_DOWNLOADS = PermissionResourceType_._internal(
    'MULTIPLE_AUTOMATIC_DOWNLOADS',
  );

  ///Indicates permission to read and write to files or folders on the device.
  ///Permission is requested when developers use the [File System Access API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API)
  ///to show the file or folder picker to the end user, and then request
  ///"readwrite" permission for the user's selection.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_FILE_READ_WRITE',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 8,
      ),
    ],
  )
  static const FILE_READ_WRITE = PermissionResourceType_._internal(
    'FILE_READ_WRITE',
  );

  ///Indicates permission to play audio and video automatically on sites.
  ///This permission affects the autoplay attribute and play method of the audio
  ///and video HTML elements, and the start method of the Web Audio API.
  ///See the [Autoplay guide for media and Web Audio APIs](https://developer.mozilla.org/docs/Web/Media/Autoplay_guide)
  ///for details.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_AUTOPLAY',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 9,
      ),
    ],
  )
  static const AUTOPLAY = PermissionResourceType_._internal('AUTOPLAY');

  ///Indicates permission to use fonts on the device.
  ///Permission is requested when developers use the [Local Font Access API](https://wicg.github.io/local-font-access/)
  ///to query the system fonts available for styling web content.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_LOCAL_FONTS',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 10,
      ),
    ],
  )
  static const LOCAL_FONTS = PermissionResourceType_._internal('LOCAL_FONTS');

  ///Indicates permission to open and place windows on the screen.
  ///Permission is requested when developers use the [Multi-Screen Window Placement API](https://www.w3.org/TR/window-placement/)
  ///to get screen details.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PERMISSION_KIND_WINDOW_MANAGEMENT',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2792.45#corewebview2_permission_kind',
        value: 12,
      ),
    ],
  )
  static const WINDOW_MANAGEMENT = PermissionResourceType_._internal(
    'WINDOW_MANAGEMENT',
  );
}
