import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [LinuxContainerController].
@immutable
class LinuxContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates a new [LinuxContainerControllerCreationParams] instance.
  const LinuxContainerControllerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();

  /// Creates a [LinuxContainerControllerCreationParams] instance based on
  /// [PlatformContainerControllerCreationParams].
  factory LinuxContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
    PlatformContainerControllerCreationParams params,
  ) {
    return LinuxContainerControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformContainerController}
///
/// Linux implementation. Containers are filesystem-backed: data lives
/// under `<XDG_DATA_HOME>/flutter_inappwebview/containers/<id>/data` and
/// cache under `<XDG_CACHE_HOME>/flutter_inappwebview/containers/<id>/cache`.
class LinuxContainerController extends PlatformContainerController {
  static const MethodChannel _channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_containercontroller',
  );

  LinuxContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is LinuxContainerControllerCreationParams
            ? params
            : LinuxContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
                params,
              ),
      );

  static LinuxContainerController? _instance;

  static LinuxContainerController instance() {
    return _instance ??= LinuxContainerController(
      LinuxContainerControllerCreationParams(
        const PlatformContainerControllerCreationParams(),
      ),
    );
  }

  static final LinuxContainerController _staticValue = LinuxContainerController(
    LinuxContainerControllerCreationParams(
      const PlatformContainerControllerCreationParams(),
    ),
  );

  factory LinuxContainerController.static() => _staticValue;

  @override
  Future<List<String>> getAllContainerNames() async {
    final names = await _channel.invokeMethod<List>('getAllContainerNames');
    return names?.cast<String>() ?? const <String>[];
  }

  @override
  Future<bool> hasContainer(String containerId) async {
    final ok = await _channel.invokeMethod<bool>('hasContainer', {
      'containerId': containerId,
    });
    return ok ?? false;
  }

  @override
  Future<bool> deleteContainer(String containerId) async {
    final ok = await _channel.invokeMethod<bool>('deleteContainer', {
      'containerId': containerId,
    });
    return ok ?? false;
  }

  @override
  Future<bool> clearContainerData(String containerId) async {
    final ok = await _channel.invokeMethod<bool>('clearContainerData', {
      'containerId': containerId,
    });
    return ok ?? false;
  }
}
