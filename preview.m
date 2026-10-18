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
            @[@{@"title":@"Remove Jailbreak", @"value":@"Off", @"destructive":@YES, @"action":[^{} copy]}],
            @[@{@"title":@"Cronix", @"value":@"1.0"}, @{@"title":@"Dopamine Engine", @"value":@"3.0.11"}, @{@"title":@"Licences", @"action":[^{} copy]}]
        ];
        settings.headings = @[@"General", @"Recovery", @"About"];
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.window layoutIfNeeded];
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.window.bounds.size];
        UIImage *render = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [self.window drawViewHierarchyInRect:self.window.bounds afterScreenUpdates:YES];
        }];
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/render-%@.png", mode]];
        [UIImagePNGRepresentation(render) writeToFile:path atomically:YES];
        NSLog(@"CRONIX_PREVIEW_RENDERED %@", mode);
    });
    return YES;
}
@end
int main(int argc, char **argv) {
    @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass(PreviewDelegate.class)); }
}
