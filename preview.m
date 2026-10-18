#import <UIKit/UIKit.h>
#import "CronixUI.inc"

@interface PreviewDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@end
@implementation PreviewDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
    NSArray *args = NSProcessInfo.processInfo.arguments;
    NSString *mode = args.lastObject;
    UIViewController *root;
    if ([mode isEqualToString:@"activity"]) {
        CXActivityController *activity = [CXActivityController new];
        [activity loadViewIfNeeded];
        [activity appendEvent:@"Checking compatibility" replacing:NO];
        [activity appendEvent:@"Preparing environment" replacing:NO];
        root = activity;
    } else if ([mode isEqualToString:@"settings"]) {
        CXSettingsController *settings = [CXSettingsController new];
        settings.groups = @[
            @[@{@"title":@"Appearance", @"value":@"Light"}, @{@"title":@"Tweak Injection", @"toggle":[^(BOOL value) {} copy], @"on":@YES}, @{@"title":@"Verbose Logs", @"toggle":[^(BOOL value) {} copy], @"on":@NO}, @{@"title":@"View Logs", @"action":[^{} copy]}],
            @[@{@"title":@"Sileo", @"toggle":[^(BOOL value) {} copy], @"on":@YES}, @{@"title":@"Zebra", @"toggle":[^(BOOL value) {} copy], @"on":@NO}],
            @[@{@"title":@"Remove Jailbreak", @"value":@"Off", @"destructive":@YES, @"action":[^{} copy]}],
            @[@{@"title":@"Cronix", @"value":@"1.0"}, @{@"title":@"Dopamine Engine", @"value":@"3.0.11"}, @{@"title":@"Licences", @"action":[^{} copy]}]
        ];
        settings.headings = @[@"General", @"Package Managers", @"Recovery", @"About"];
        root = settings;
    } else if ([mode isEqualToString:@"logs"]) {
        CXLogsController *logs = [CXLogsController new];
        root = logs;
    } else {
        root = [UIViewController new];
        root.title = @"Cronix";
        root.view = [[CXHomeView alloc] initWithModel:@"iPhone 6s" system:@"15.7.7"];
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    nav.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    nav.navigationBar.tintColor = CXInk();
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = CXBackground();
    appearance.shadowColor = UIColor.clearColor;
    nav.navigationBar.standardAppearance = appearance;
    nav.navigationBar.scrollEdgeAppearance = appearance;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(1024, 1024) format:({ UIGraphicsImageRendererFormat *f = [UIGraphicsImageRendererFormat new]; f.scale = 1; f.opaque = YES; f; })];
    UIImage *icon = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [CXBackground() setFill]; UIRectFill(CGRectMake(0, 0, 1024, 1024));
        CXDrawEye(CGRectMake(150, 275, 724, 453));
    }];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CronixIcon.png"];
    [UIImagePNGRepresentation(icon) writeToFile:path atomically:YES];
    return YES;
}
@end
int main(int argc, char **argv) {
    @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass(PreviewDelegate.class)); }
}
