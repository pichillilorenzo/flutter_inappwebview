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

  final name = "Android native WebView";
  final targetPlatformName = "android";
}

class IOSPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const IOSPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = "iOS";
  final targetPlatformName = "iOS";
}

class MacOSPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const MacOSPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = "MacOS";
  final targetPlatformName = "macOS";
}

class WindowsPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const WindowsPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = "Windows";
  final targetPlatformName = "windows";
}

class LinuxPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;

  const LinuxPlatform({this.available, this.apiName, this.apiUrl, this.note});

  final name = "Linux";
  final targetPlatformName = "linux";
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

  final name = "Web";
  final targetPlatformName = "web";
}

class SupportedPlatforms {
  final List<Platform> platforms;

  const SupportedPlatforms({required this.platforms});
}
