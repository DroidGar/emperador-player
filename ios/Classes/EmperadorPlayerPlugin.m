#import "EmperadorPlayerPlugin.h"
#if __has_include(<emperador_player/emperador_player-Swift.h>)
#import <emperador_player/emperador_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "emperador_player-Swift.h"
#endif

@implementation EmperadorPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEmperadorPlayerPlugin registerWithRegistrar:registrar];
}
@end
