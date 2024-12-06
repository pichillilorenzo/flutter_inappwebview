import 'constants.dart';

abstract class Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const Platform({this.available, this.apiName, this.apiUrl, this.note});

  final name = "";
  final targetPlatformName = "";
}

class AndroidPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const AndroidPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = kPlatformNameAndroid;
  final targetPlatformName = kTargetPlatformNameAndroid;
}

class IOSPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const IOSPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = kPlatformNameIOS;
  final targetPlatformName = kTargetPlatformNameIOS;
}

class MacOSPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const MacOSPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = kPlatformNameMacOS;
  final targetPlatformName = kTargetPlatformNameMacOS;
}

class WindowsPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const WindowsPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = kPlatformNameWindows;
  final targetPlatformName = kTargetPlatformNameWindows;
}

class LinuxPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const LinuxPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = kPlatformNameLinux;
  final targetPlatformName = kTargetPlatformNameLinux;
}

class WebPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final bool requiresSameOrigin;

  const WebPlatform(
      {this.available,
      this.apiName,
      this.apiUrl,
      this.note,
      this.requiresSameOrigin = true});

  final name = kPlatformNameWeb;
  final targetPlatformName = kTargetPlatformNameWeb;
}

class SupportedPlatforms {
  final List<Platform> platforms;
  final bool ignore;
  final List<String> ignorePropertyNames;
  final List<String> ignoreMethodNames;
  final List<String> ignoreParameterNames;

  /// Workaround for @SupportedPlatforms annotation not working
  /// on parameters of a class fields which type is a function.
  /// https://github.com/dart-lang/sdk/issues/59670
  final Map<String, List<Platform>> parameterPlatforms;

  const SupportedPlatforms({
    required this.platforms,
    this.ignore = false,
    this.ignorePropertyNames = const [],
    this.ignoreMethodNames = const [],
    this.ignoreParameterNames = const [],
    this.parameterPlatforms = const {},
  });
}
