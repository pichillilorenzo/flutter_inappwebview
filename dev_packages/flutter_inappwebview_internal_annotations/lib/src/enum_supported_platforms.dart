import 'constants.dart';
import 'supported_platforms.dart';

abstract class EnumPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = '',
    this.targetPlatformName = '',
    this.value,
  });
}

class EnumAndroidPlatform implements EnumPlatform, AndroidPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumAndroidPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameAndroid,
    this.targetPlatformName = kTargetPlatformNameAndroid,
    this.value,
  });
}

class EnumIOSPlatform implements EnumPlatform, IOSPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumIOSPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameIOS,
    this.targetPlatformName = kTargetPlatformNameIOS,
    this.value,
  });
}

class EnumMacOSPlatform implements EnumPlatform, MacOSPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumMacOSPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameMacOS,
    this.targetPlatformName = kTargetPlatformNameMacOS,
    this.value,
  });
}

class EnumWindowsPlatform implements EnumPlatform, WindowsPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumWindowsPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameWindows,
    this.targetPlatformName = kTargetPlatformNameWindows,
    this.value,
  });
}

class EnumLinuxPlatform implements EnumPlatform, LinuxPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumLinuxPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameLinux,
    this.targetPlatformName = kTargetPlatformNameLinux,
    this.value,
  });
}

class EnumWebPlatform implements EnumPlatform, WebPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;
  final bool requiresSameOrigin;

  const EnumWebPlatform(
      {this.available,
      this.apiName,
      this.apiUrl,
      this.note,
      this.value,
      this.name = kPlatformNameWeb,
      this.targetPlatformName = kTargetPlatformNameWeb,
      this.requiresSameOrigin = true});
}

class EnumSupportedPlatforms {
  final List<EnumPlatform> platforms;
  final dynamic defaultValue;

  const EnumSupportedPlatforms({
    required this.platforms,
    this.defaultValue,
  });
}
