#import "SiwaPlugin.h"
#if __has_include(<siwa/siwa-Swift.h>)
#import <siwa/siwa-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "siwa-Swift.h"
#endif

@implementation SiwaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//  [SwiftSiwaPlugin registerWithRegistrar:registrar];
    [registrar registerViewFactory: [[SignInWithAppleFactory alloc] initWithMessenger:[registrar messenger]] withId:@"plugins/siwa"];
}
@end
