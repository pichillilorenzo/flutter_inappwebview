#import "FlutterPlugin.h"
#import <flutter_plugin/flutter_plugin-Swift.h>

@implementation FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPlugin registerWithRegistrar:registrar];
}
@end
