"""Compile the production UI with isolated engine fixtures for simulator layout checks."""
from pathlib import Path
import plistlib, re, shutil
patch = Path(__file__).resolve().parent
out = Path('preview/RosePreview.app'); out.mkdir(parents=True, exist_ok=True)
preamble = r'''
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <pthread.h>
#import "RoseUI.h"
@protocol DOLogViewProtocol <NSObject>
- (void)showLog:(NSString *)log;
- (void)didComplete;
@end
@protocol DOActionMenuDelegate <NSObject>
@end
@interface DOEnvironmentManager : NSObject
+ (instancetype)sharedManager;
- (BOOL)isSupported;
- (BOOL)isJailbroken;
- (BOOL)isJailbrokenWithOtherJailbreak;
- (BOOL)isArm64e;
- (NSString *)appVersionDisplayString;
- (NSString *)jailbrokenVersion;
- (void)respring;
- (void)rebootUserspace;
@end
@interface DOPreferenceManager : NSObject
+ (instancetype)sharedManager;
- (BOOL)boolPreferenceValueForKey:(NSString *)key fallback:(BOOL)fallback;
@end
@interface DOUIManager : NSObject
@property NSObject<DOLogViewProtocol> *logView;
+ (instancetype)sharedInstance;
- (NSArray *)roseLogSnapshot;
- (void)shareLogRecordFromView:(UIView *)view;
- (NSArray *)enabledPackageManagerKeys;
- (BOOL)environmentUpdateAvailable;
- (NSString *)getLaunchedReleaseTag;
- (void)sendLog:(NSString *)log debug:(BOOL)debug;
@end
@interface DOSettingsController : UIViewController @end
@interface DOCreditsViewController : UIViewController @end
@interface DOUpdateViewController : UIViewController
- (instancetype)initFromTag:(NSString *)from toTag:(NSString *)to;
@end
@interface DOActionMenuButton : UIButton
+ (instancetype)buttonWithAction:(UIAction *)action chevron:(BOOL)chevron;
@end
@interface DOPkgManagerPickerView : UIView
- (instancetype)initWithCallback:(void (^)(BOOL))callback;
@end
@interface DOJailbreakButton : UIView
@property DOActionMenuButton *button;
@property UIView<DOLogViewProtocol> *logView;
@property DOPkgManagerPickerView *pkgManagerPickerView;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) BOOL didExpand;
@property (nonatomic, assign) pthread_mutex_t canStartJailbreak;
- (instancetype)initWithAction:(UIAction *)action;
- (void)expandButton:(NSArray<NSLayoutConstraint *> *)constraints;
- (void)lockMutex;
- (void)unlockMutex;
@end
@interface DOMainViewController : UIViewController <DOActionMenuDelegate> @end
@interface DONavigationController : UINavigationController <UINavigationControllerDelegate> @end
@implementation DOEnvironmentManager
+ (instancetype)sharedManager { static id value; if (!value) value = [self new]; return value; }
- (BOOL)isSupported { return ![NSProcessInfo.processInfo.arguments containsObject:@"unsupported"]; }
- (BOOL)isJailbroken { return [NSProcessInfo.processInfo.arguments containsObject:@"active"]; }
- (BOOL)isJailbrokenWithOtherJailbreak { return NO; }
- (BOOL)isArm64e { return NO; }
- (NSString *)appVersionDisplayString { return @"UI fixture, no engine"; }
- (NSString *)jailbrokenVersion { return nil; }
- (void)respring {}
- (void)rebootUserspace {}
@end
@implementation DOPreferenceManager
+ (instancetype)sharedManager { static id value; if (!value) value = [self new]; return value; }
- (BOOL)boolPreferenceValueForKey:(NSString *)key fallback:(BOOL)fallback { return [NSProcessInfo.processInfo.arguments containsObject:@"removal"]; }
@end
@implementation DOUIManager
+ (instancetype)sharedInstance { static id value; if (!value) value = [self new]; return value; }
- (NSArray *)roseLogSnapshot { return @[]; }
- (void)shareLogRecordFromView:(UIView *)view {}
- (NSArray *)enabledPackageManagerKeys { return @[@"preview"]; }
- (BOOL)environmentUpdateAvailable { return NO; }
- (NSString *)getLaunchedReleaseTag { return @"UI preview"; }
- (void)sendLog:(NSString *)log debug:(BOOL)debug { [self.logView showLog:log]; }
@end
@implementation DOActionMenuButton
+ (instancetype)buttonWithAction:(UIAction *)action chevron:(BOOL)chevron { return [self buttonWithConfiguration:[UIButtonConfiguration plainButtonConfiguration] primaryAction:action]; }
@end
@implementation DOPkgManagerPickerView
- (instancetype)initWithCallback:(void (^)(BOOL))callback { return [super init]; }
@end
@implementation DOSettingsController @end
@implementation DOCreditsViewController @end
@implementation DOUpdateViewController
- (instancetype)initFromTag:(NSString *)from toTag:(NSString *)to { return [super init]; }
@end
'''
source = preamble
for name in ['DOJailbreakButton.m','DOMainViewController.m','DONavigationController.m']:
    text = (patch / 'ui' / name).read_text()
    text = re.sub(r'^#import.*$', '', text, flags=re.M)
    text = text.replace('/* ROSE_PRESERVED_JAILBREAK_FLOW */', '- (void)startJailbreak { [[DOUIManager sharedInstance] sendLog:@"UI preview fixture: no engine is running" debug:NO]; }')
    source += text
source += r'''
@interface PreviewDelegate : UIResponder <UIApplicationDelegate>
@property UIWindow *window;
@end
@implementation PreviewDelegate
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    DONavigationController *nav = [DONavigationController new];
    self.window.rootViewController = nav; [self.window makeKeyAndVisible];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSString *screen = NSProcessInfo.processInfo.arguments.lastObject;
        if ([screen isEqualToString:@"device"]) [nav pushViewController:[[RoseLibraryController alloc] initWithPage:1] animated:NO];
        if ([screen isEqualToString:@"library"]) [nav pushViewController:[[RoseLibraryController alloc] initWithPage:0] animated:NO];
        if ([screen isEqualToString:@"recovery"]) [nav pushViewController:[[RoseLibraryController alloc] initWithPage:2] animated:NO];
        if ([screen isEqualToString:@"logs"]) [nav pushViewController:[RoseLogController new] animated:NO];
        if ([screen isEqualToString:@"progress"]) {
            DOMainViewController *home = (id)nav.topViewController;
            [home.jailbreakBtn.button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    });
    return YES;
}
@end
int main(int argc, char **argv) { @autoreleasepool { return UIApplicationMain(argc, argv, nil, @"PreviewDelegate"); } }
'''
Path('preview/main.m').write_text(source)
shutil.copy(patch / 'ui/RoseUI.h','preview/RoseUI.h')
from PIL import Image
Image.open(patch / 'assets/reference.jpg').crop((185,870,495,1280)).save(out / 'RosePortrait.png')
(out / 'Info.plist').write_bytes(plistlib.dumps({'CFBundleExecutable':'RosePreview','CFBundleIdentifier':'dev.rose.preview','CFBundleName':'RosePreview','CFBundlePackageType':'APPL','CFBundleVersion':'1','CFBundleShortVersionString':'1.0','MinimumOSVersion':'15.0','LSRequiresIPhoneOS':True,'UIDeviceFamily':[1],'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait']}))

