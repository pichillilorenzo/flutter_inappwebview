///Class that represents display mode of a Trusted Web Activity.
abstract class TrustedWebActivityDisplayMode {
  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {};
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