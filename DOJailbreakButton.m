// Cronix frontend. The upstream jailbreak engine remains unchanged.
#import "DOJailbreakButton.h"
#import "DOUIManager.h"
#import "CronixUI.h"

@interface CXLogBridge : UIView <DOLogViewProtocol>
@property(nonatomic, weak) CXActivityController *activity;
@end
@implementation CXLogBridge
- (void)showLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{ [self.activity appendEvent:log replacing:NO]; });
}
- (void)updateLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{ [self.activity appendEvent:log replacing:YES]; });
}
- (void)didComplete {
    dispatch_async(dispatch_get_main_queue(), ^{ [self.activity finish]; });
}
@end

@implementation DOJailbreakButton
- (instancetype)initWithAction:(UIAction *)action {
    if ((self = [super initWithFrame:CGRectZero])) {
        pthread_mutex_init(&_canStartJailbreak, NULL);
        self.button = [DOActionMenuButton buttonWithAction:action chevron:NO];
        self.logView = [CXLogBridge new];
        [DOUIManager sharedInstance].logView = self.logView;
    }
    return self;
}
- (void)expandButton:(NSArray<NSLayoutConstraint *> *)constraints {
    if (self.didExpand) return;
    self.didExpand = YES;
    CXActivityController *activity = [CXActivityController new];
    ((CXLogBridge *)self.logView).activity = activity;
    UINavigationController *navigation = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    __weak UINavigationController *weakNavigation = navigation;
    activity.onLogs = ^{
        CXLogsController *logs = [CXLogsController new];
        logs.readLogs = ^{ return [[[DOUIManager sharedInstance] cronixLogSnapshot] componentsJoinedByString:@"\n"]; };
        [weakNavigation pushViewController:logs animated:YES];
    };
    navigation.interactivePopGestureRecognizer.enabled = NO;
    [navigation pushViewController:activity animated:YES];
}
- (void)setEnabled:(BOOL)enabled { self.button.enabled = enabled; }
- (BOOL)isEnabled { return self.button.enabled; }
- (void)lockMutex { pthread_mutex_lock(&_canStartJailbreak); }
- (void)unlockMutex { pthread_mutex_unlock(&_canStartJailbreak); }
- (void)dealloc { pthread_mutex_destroy(&_canStartJailbreak); }
@end
