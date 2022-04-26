import 'trusted_web_activity_display_mode.dart';

///Class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
class TrustedWebActivityDefaultDisplayMode
    implements TrustedWebActivityDisplayMode {
  String _type = "DEFAULT_MODE";

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"type": _type};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}