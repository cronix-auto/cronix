// Cronix native frontend built on opa334/Dopamine.
#import "DOMainViewController.h"
#import "DOUIManager.h"
#import "DOEnvironmentManager.h"
#import "DOJailbreaker.h"
#import "DOLogCrashViewController.h"
#import "DOLicenseViewController.h"
#import "CronixUI.inc"
#import <pthread.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <libjailbreak/libjailbreak.h>

@interface DOMainViewController ()
@property(nonatomic, strong) DOJailbreakButton *jailbreakBtn;
@property(nonatomic, strong) CXHomeView *home;
@property(nonatomic) BOOL hideStatusBar;
@property(nonatomic) BOOL hideHomeIndicator;
@property(nonatomic) BOOL started;
@end

@implementation DOMainViewController
- (void)loadView {
    struct utsname info; uname(&info);
    NSString *identifier = [NSString stringWithUTF8String:info.machine];
    NSString *model = [identifier isEqualToString:@"iPhone8,1"] ? @"iPhone 6s" : identifier;
    self.home = [[CXHomeView alloc] initWithModel:model system:UIDevice.currentDevice.systemVersion];
    self.view = self.home;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Cronix";
    __weak typeof(self) weakSelf = self;
    self.home.onSettings = ^{ [weakSelf openSettings]; };
    self.home.onLogs = ^{ [weakSelf openLogs]; };
    self.jailbreakBtn = [[DOJailbreakButton alloc] initWithAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {}]];
    [self.home.jailbreakButton addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
        [weakSelf requestJailbreak];
    }] forControlEvents:UIControlEventTouchUpInside];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.started) return;
    DOEnvironmentManager *environment = [DOEnvironmentManager sharedManager];
    BOOL jailbroken = environment.isJailbroken || environment.isJailbrokenWithOtherJailbreak;
    self.home.statusLabel.text = jailbroken ? @"Jailbroken" : (environment.isSupported ? @"Not Jailbroken" : @"Unsupported");
    BOOL remove = [[DOPreferenceManager sharedManager] boolPreferenceValueForKey:@"removeJailbreakEnabled" fallback:NO];
    UIButtonConfiguration *config = self.home.jailbreakButton.configuration;
    config.title = jailbroken ? @"Jailbroken" : (!environment.isSupported ? @"Unsupported" : (remove ? @"Remove Jailbreak" : @"Jailbreak"));
    self.home.jailbreakButton.configuration = config;
    self.home.jailbreakButton.enabled = !jailbroken && environment.isSupported;
    self.jailbreakBtn.enabled = self.home.jailbreakButton.enabled;
}
- (void)openLogs {
    CXLogsController *logs = [CXLogsController new];
    logs.readLogs = ^{ return [[[DOUIManager sharedInstance] cronixLogSnapshot] componentsJoinedByString:@"\n"]; };
    [self.navigationController pushViewController:logs animated:YES];
}
- (void)requestJailbreak {
    if (self.started || !self.home.jailbreakButton.enabled) return;
    [self beginJailbreak];
}
- (void)beginJailbreak {
    if (self.started) return;
    self.started = YES;
    self.home.jailbreakButton.enabled = NO;
    // The bootstrap is still required. Installing a package-manager app is not.
    [[DOUIManager sharedInstance] resetPackageManagers];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [self.jailbreakBtn expandButton:@[]];
    [self startJailbreak];
}
- (void)confirmOperation:(NSString *)title message:(NSString *)message action:(void (^)(void))operation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { operation(); }]];
    [self.navigationController.topViewController presentViewController:alert animated:YES completion:nil];
}
- (void)openSettings {
    CXSettingsController *settings = [CXSettingsController new];
    DOPreferenceManager *prefs = [DOPreferenceManager sharedManager];
    __weak typeof(self) weakSelf = self;
    NSDictionary *(^toggle)(NSString *, NSString *, BOOL) = ^NSDictionary *(NSString *title, NSString *key, BOOL fallback) {
        return @{@"title":title, @"on":@([prefs boolPreferenceValueForKey:key fallback:fallback]), @"toggle":[^(BOOL on) {
            [prefs setPreferenceValue:@(on) forKey:key];
            if ([key isEqualToString:@"tweakInjectionEnabled"] && [DOEnvironmentManager sharedManager].isJailbroken) {
                [[DOEnvironmentManager sharedManager] setTweakInjectionEnabled:on];
            }
        } copy]};
    };
    NSMutableArray *recovery = [NSMutableArray new];
    if ([DOEnvironmentManager sharedManager].isJailbroken) {
        [recovery addObject:@{@"title":@"Restart SpringBoard", @"action":[^{
            [weakSelf confirmOperation:@"Restart SpringBoard?" message:@"The Home Screen will reload. Your current jailbreak stays active." action:^{ [[DOEnvironmentManager sharedManager] respring]; }];
        } copy]}];
        [recovery addObject:@{@"title":@"Reboot Userspace", @"action":[^{
            [weakSelf confirmOperation:@"Reboot Userspace?" message:@"Running apps will close while the jailbreak environment restarts." action:^{ [[DOEnvironmentManager sharedManager] rebootUserspace]; }];
        } copy]}];
    }
    [recovery addObject:@{@"title":@"Remove Jailbreak", @"value":[prefs boolPreferenceValueForKey:@"removeJailbreakEnabled" fallback:NO] ? @"Armed" : @"Off", @"destructive":@YES, @"action":[^{
        [weakSelf confirmOperation:@"Remove Jailbreak" message:@"This arms Dopamine’s removal option for the next jailbreak run. It removes the bootstrap and installed tweaks. It does not run immediately." action:^{
            BOOL armed = [prefs boolPreferenceValueForKey:@"removeJailbreakEnabled" fallback:NO];
            [prefs setPreferenceValue:@(!armed) forKey:@"removeJailbreakEnabled"];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }];
    } copy]}];
    settings.headings = @[@"General", @"Recovery", @"About"];
    settings.groups = @[
        @[@{@"title":@"Appearance", @"value":@"Light"}, toggle(@"Tweak Injection", @"tweakInjectionEnabled", YES), toggle(@"Verbose Logs", @"verboseLogsEnabled", NO), @{@"title":@"View Logs", @"action":[^{ [weakSelf openLogs]; } copy]}],
        recovery,
        @[@{@"title":@"Cronix", @"value":@"1.0"}, @{@"title":@"Dopamine Engine", @"value":@"3.0.11"}, @{@"title":@"Licences", @"action":[^{
            CXLogsController *licences = [CXLogsController new];
            licences.title = @"Licences";
            licences.readLogs = ^{
                NSMutableString *text = [NSMutableString stringWithString:@"Cronix frontend: Zenyical\nDopamine: Lars Fröder (opa334) and contributors\n\n"];
                NSArray *paths = [NSBundle.mainBundle pathsForResourcesOfType:@"md" inDirectory:nil];
                for (NSString *path in [paths sortedArrayUsingSelector:@selector(compare:)]) {
                    if (![path.lastPathComponent hasPrefix:@"LICENSE"]) continue;
                    [text appendFormat:@"%@\n%@\n\n", path.lastPathComponent, [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] ?: @""];
                }
                return text;
            };
            [weakSelf.navigationController pushViewController:licences animated:YES];
        } copy]}]
    ];
    [self.navigationController pushViewController:settings animated:YES];
}
