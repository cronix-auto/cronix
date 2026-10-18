#import "DOLogCrashViewController.h"
#import "DOUIManager.h"
#import "CronixUI.h"

@interface DOLogCrashViewController ()
@property(nonatomic, copy) NSString *failure;
@property(nonatomic, strong) CXLogsController *logs;
@end
@implementation DOLogCrashViewController
- (instancetype)initWithTitle:(NSString *)title {
    if ((self = [super init])) self.failure = title;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Jailbreak Failed";
    self.navigationItem.hidesBackButton = YES;
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    self.logs = [CXLogsController new];
    self.logs.failure = self.failure;
    self.logs.readLogs = ^{ return [[[DOUIManager sharedInstance] cronixLogSnapshot] componentsJoinedByString:@"\n"]; };
    [self addChildViewController:self.logs];
    self.logs.view.frame = self.view.bounds;
    self.logs.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.logs.view];
    [self.logs didMoveToParentViewController:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
}
- (void)share:(UIBarButtonItem *)sender {
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[self.logs.readLogs()] applicationActivities:nil];
    share.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:share animated:YES completion:nil];
}
- (void)close { exit(0); }
@end
