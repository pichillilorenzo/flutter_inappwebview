---
applyTo: "flutter_inappwebview/lib/**,flutter_inappwebview/example/**"
---

# App-Facing Package Instructions

This is the **public API** package that developers depend on. It wraps all platform implementations.

## Key Rules

1. **No Platform Logic Here**: This package only wraps platform implementations. Never add platform-specific code.

2. **Delegate to Platform Interface**: All functionality must delegate to `flutter_inappwebview_platform_interface` types.

3. **Avoid Breaking Changes**: Public API changes affect all users. Maintain backward compatibility.

## Directory Structure

- `lib/flutter_inappwebview.dart` - Main export file
- `lib/src/` - Public API wrappers
- `example/` - Example app and integration tests
- `example/integration_test/` - Integration test suite

## Adding Public API Classes

1. Create wrapper class in `lib/src/`
2. Use constructor helpers: `fromPlatformCreationParams`, `fromPlatform`
3. Delegate all methods to the platform implementation
4. Add support check helpers: `isClassSupported`, `isPropertySupported`, `isMethodSupported`

## Example Pattern

```dart
class MyFeature {
  MyFeature.fromPlatformCreationParams(
    PlatformMyFeatureCreationParams params,
  ) : this.fromPlatform(platform: PlatformMyFeature(params));
  
  MyFeature.fromPlatform({required this.platform});
  
  final PlatformMyFeature platform;
  
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformMyFeature.static().isClassSupported(platform: platform);
}
```

## Integration Tests

Located in `example/integration_test/`:
```bash
# Run with device/emulator
cd flutter_inappwebview/example
NODE_SERVER_IP=<ip> flutter driver --driver=test_driver/integration_test.dart \
  --target=integration_test/webview_flutter_test.dart
```

Requires `test_node_server/` to be running for full test coverage.
