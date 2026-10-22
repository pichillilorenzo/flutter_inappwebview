import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

/// Object specifying creation parameters for creating a [MacOSFindInteractionController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformFindInteractionControllerCreationParams] for
/// more information.
@immutable
class MacOSFindInteractionControllerCreationParams
    extends PlatformFindInteractionControllerCreationParams {
  /// Creates a new [MacOSFindInteractionControllerCreationParams] instance.
  const MacOSFindInteractionControllerCreationParams({
    super.onFindResultReceived,
  });

  /// Creates a [MacOSFindInteractionControllerCreationParams] instance based on [PlatformFindInteractionControllerCreationParams].
  factory MacOSFindInteractionControllerCreationParams.fromPlatformFindInteractionControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return MacOSFindInteractionControllerCreationParams(
      onFindResultReceived: params.onFindResultReceived,
    );
  }
}

///{@macro drago_inappwebview.PlatformFindInteractionController}
class MacOSFindInteractionController extends PlatformFindInteractionController
    with ChannelController {
  /// Constructs a [MacOSFindInteractionController].
  MacOSFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) : super.implementation(
        params is MacOSFindInteractionControllerCreationParams
            ? params
            : MacOSFindInteractionControllerCreationParams.fromPlatformFindInteractionControllerCreationParams(
                params,
              ),
      );

  static final MacOSFindInteractionController _staticValue =
      MacOSFindInteractionController(
        MacOSFindInteractionControllerCreationParams(),
      );

  /// Provide static access.
  factory MacOSFindInteractionController.static() {
    return _staticValue;
  }

  void _debugLog(String method, dynamic args) {
    debugLog(
      className: runtimeType.toString(),
      debugLoggingSettings:
          PlatformFindInteractionController.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onFindResultReceived":
        if (onFindResultReceived != null) {
          int activeMatchOrdinal = call.arguments["activeMatchOrdinal"];
          int numberOfMatches = call.arguments["numberOfMatches"];
          bool isDoneCounting = call.arguments["isDoneCounting"];
          onFindResultReceived!(
            this,
            activeMatchOrdinal,
            numberOfMatches,
            isDoneCounting,
          );
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.findAll}
  @override
  Future<void> findAll({String? find}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('find', () => find);
    await channel?.invokeMethod('findAll', args);
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.findNext}
  @override
  Future<void> findNext({bool forward = true}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('forward', () => forward);
    await channel?.invokeMethod('findNext', args);
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.clearMatches}
  @override
  Future<void> clearMatches() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearMatches', args);
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.setSearchText}
  @override
  Future<void> setSearchText(String? searchText) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('searchText', () => searchText);
    await channel?.invokeMethod('setSearchText', args);
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.getSearchText}
  @override
  Future<String?> getSearchText() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String?>('getSearchText', args);
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.getActiveFindSession}
  @override
  Future<FindSession?> getActiveFindSession() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? result = (await channel?.invokeMethod(
      'getActiveFindSession',
      args,
    ))?.cast<String, dynamic>();
    return FindSession.fromMap(result);
  }

  ///{@macro drago_inappwebview.PlatformFindInteractionController.dispose}
  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
  }
}

extension InternalFindInteractionController on MacOSFindInteractionController {
  void init(dynamic id) {
    channel = MethodChannel(
      'com.pichillilorenzo/drago_inappwebview_find_interaction_$id',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }
}
