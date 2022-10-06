import 'supported_platforms.dart';

abstract class EnumPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;

  const EnumPlatform(
      {this.available, this.apiName, this.apiUrl, this.note, this.value});

  final name = "";
  final targetPlatformName = "";
}

class EnumAndroidPlatform implements EnumPlatform, AndroidPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;

  const EnumAndroidPlatform(
      {this.available, this.apiName, this.apiUrl, this.note, this.value});

  final name = "Android native WebView";
  final targetPlatformName = "android";
}

class EnumIOSPlatform implements EnumPlatform, IOSPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;

  const EnumIOSPlatform(
      {this.available, this.apiName, this.apiUrl, this.note, this.value});

  final name = "iOS";
  final targetPlatformName = "iOS";
}

class EnumMacOSPlatform implements EnumPlatform, MacOSPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;

  const EnumMacOSPlatform(
      {this.available, this.apiName, this.apiUrl, this.note, this.value});

  final name = "MacOS";
  final targetPlatformName = "macOS";
}

class EnumWindowsPlatform implements EnumPlatform, WindowsPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;

  const EnumWindowsPlatform(
      {this.available, this.apiName, this.apiUrl, this.note, this.value});

  final name = "Windows";
  final targetPlatformName = "windows";
}

class EnumLinuxPlatform implements EnumPlatform, LinuxPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;

  const EnumLinuxPlatform(
      {this.available, this.apiName, this.apiUrl, this.note, this.value});

  final name = "Linux";
  final targetPlatformName = "linux";
}

class EnumWebPlatform implements EnumPlatform, WebPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final dynamic value;
  final bool requiresSameOrigin;

  const EnumWebPlatform(
      {this.available,
        this.apiName,
        this.apiUrl,
        this.note,
        this.value,
        this.requiresSameOrigin = true});

  final name = "Web";
  final targetPlatformName = "web";
}

class EnumSupportedPlatforms {
  final List<EnumPlatform> platforms;
  final dynamic defaultValue;

  const EnumSupportedPlatforms({
    required this.platforms,
    this.defaultValue,
  });
}