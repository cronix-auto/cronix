#import "DOMainViewController.h"
#import "DOUIManager.h"
#import "DOEnvironmentManager.h"
#import "DOJailbreaker.h"
#import "DOLogCrashViewController.h"
#import "DOUpdateViewController.h"
#import "RoseUI.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <libjailbreak/libjailbreak.h>

@interface RoseLogController : UIViewController
@end
@implementation RoseLogController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Session log";
    self.view.backgroundColor = RoseInk();
    UITextView *text = [UITextView new];
    text.translatesAutoresizingMaskIntoConstraints = NO;
    text.editable = NO;
    text.backgroundColor = RoseInk();
    text.textColor = RoseMuted();
    text.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    NSArray *record = [[DOUIManager sharedInstance] roseLogSnapshot];
    text.text = record.count ? [record componentsJoinedByString:@"\n"] : @"No session has been recorded yet.\n\nJailbreak messages and diagnostics will appear here after you begin. Enable verbose output in Settings to display additional messages during the operation.";
    text.textContainerInset = UIEdgeInsetsMake(24, 20, 24, 20);
    [self.view addSubview:text];
    [NSLayoutConstraint activateConstraints:@[
        [text.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [text.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [text.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [text.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStylePlain target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItem.enabled = record.count > 0;
}
- (void)share:(id)sender { [[DOUIManager sharedInstance] shareLogRecordFromView:self.view]; }
@end

@interface RoseLibraryController : UITableViewController
@property NSInteger page;
@end
@implementation RoseLibraryController
- (instancetype)initWithPage:(NSInteger)page {
    if ((self = [super initWithStyle:UITableViewStyleInsetGrouped])) self.page = page;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.page == 1 ? @"Device" : self.page == 2 ? @"Recovery" : @"Library";
    self.view.backgroundColor = RoseInk();
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 66;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.18 alpha:1];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.page == 1 ? 6 : 4; }
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.page == 1 ? @"Read from this device" : self.page == 2 ? @"System operations" : @"Tools & provenance";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.page == 2) return @"Restart operations require an active Dopamine jailbreak. Bootstrap maintenance and removal retain Dopamine's original checks and confirmation steps in Settings.";
    if (self.page == 1) return @"Compatibility is evaluated by Dopamine's exploit manager. A supported device does not guarantee that a jailbreak attempt will succeed.";
    return @"Rose v2 · Native UIKit\nPowered by Dopamine by opa334 and its contributors. Contributor credits and component licenses are preserved in Credits. Character artwork supplied by the user; Majin Buu belongs to its respective rights holders.";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.backgroundColor = [UIColor colorWithWhite:0.065 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = RoseMuted();
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.numberOfLines = 0;
    cell.accessoryType = self.page == 1 ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    DOEnvironmentManager *env = [DOEnvironmentManager sharedManager];
    NSInteger row = indexPath.row;
    if (self.page == 1) {
        struct utsname device; uname(&device);
        NSString *machine = [NSString stringWithUTF8String:device.machine];
        NSString *model = [machine isEqualToString:@"iPhone8,1"] ? @"iPhone 6s · Apple A9" : machine;
        NSArray *names = @[@"Model", @"iOS", @"Architecture", @"Compatibility", @"Jailbreak state", @"Engine"];
        NSArray *values = @[model, UIDevice.currentDevice.systemVersion, env.isArm64e ? @"ARM64e" : @"ARM64", env.isSupported ? @"Supported" : @"Unsupported", env.isJailbroken ? @"Dopamine active" : env.isJailbrokenWithOtherJailbreak ? @"Another jailbreak is active" : @"Not jailbroken", env.appVersionDisplayString ?: @"Dopamine"];
        cell.textLabel.text = names[row]; cell.detailTextLabel.text = values[row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (self.page == 2) {
        NSArray *names = @[@"Restart SpringBoard", @"Restart userspace", @"Bootstrap maintenance", @"Session log"];
        NSArray *details = @[@"Reload the home screen", @"Restart the user environment", @"Apps, package managers, hiding & removal", @"Review and export diagnostics"];
        cell.textLabel.text = names[row]; cell.detailTextLabel.text = details[row];
        if (row < 2 && !env.isJailbroken) {
            cell.detailTextLabel.text = @"Unavailable until Dopamine is active";
            cell.textLabel.textColor = RoseMuted();
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        NSArray *names = @[@"Device", @"Recovery", @"Session log", @"Credits & licenses"];
        NSArray *details = @[@"Hardware, system & compatibility", @"Supported maintenance operations", @"Actual diagnostics, with export", @"Dopamine, ElleKit & contributors"];
        NSArray *icons = @[@"iphone", @"arrow.counterclockwise", @"text.alignleft", @"info.circle"];
        cell.textLabel.text = names[row]; cell.detailTextLabel.text = details[row];
        cell.imageView.image = [UIImage systemImageNamed:icons[row]]; cell.imageView.tintColor = RoseGold();
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    UIViewController *next = nil;
    if (self.page == 1) return;
    if (self.page == 0) {
        if (row < 2) next = [[RoseLibraryController alloc] initWithPage:row + 1];
        if (row == 2) next = [RoseLogController new];
        if (row == 3) { next = [DOCreditsViewController new]; next.title = @"Credits"; }
    } else {
        if (row == 2) { next = [DOSettingsController new]; next.title = @"Maintenance & settings"; }
        if (row == 3) next = [RoseLogController new];
        if (row < 2) {
            if (![DOEnvironmentManager sharedManager].isJailbroken) return;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:row == 0 ? @"Restart SpringBoard?" : @"Restart userspace?" message:@"This interrupts the current device session." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (![DOEnvironmentManager sharedManager].isJailbroken) return;
                if (row == 0) [[DOEnvironmentManager sharedManager] respring];
                else [[DOEnvironmentManager sharedManager] rebootUserspace];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    if (next) [self.navigationController pushViewController:next animated:YES];
}
@end

@interface DOMainViewController ()
@property DOJailbreakButton *jailbreakBtn;
@property NSArray<NSLayoutConstraint *> *jailbreakButtonConstraints;
@property UILabel *stateLabel;
@property UILabel *detailLabel;
@property UIStackView *homeStack;
@property UIStackView *footer;
@property UILabel *operationTitle;
@property UIButton *updateButton;
@property BOOL operationStarted;
@property(nonatomic) BOOL hideStatusBar;
@property(nonatomic) BOOL hideHomeIndicator;
@end

@implementation DOMainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RoseInk();
    self.view.tintColor = RosePink();
    self.navigationItem.backButtonTitle = @"Rose";
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scroll];
    self.footer = [[UIStackView alloc] init];
    self.footer.translatesAutoresizingMaskIntoConstraints = NO;
    self.footer.distribution = UIStackViewDistributionFillEqually;
    [self.view addSubview:self.footer];
    NSArray *titles = @[@"Device", @"Settings", @"Library"];
    NSArray *icons = @[@"iphone", @"slider.horizontal.3", @"square.grid.2x2"];
    for (NSInteger i = 0; i < 3; i++) {
        UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
        config.title = titles[i]; config.image = [UIImage systemImageNamed:icons[i]];
        config.imagePadding = 7; config.baseForegroundColor = i == 1 ? RosePink() : RoseMuted();
        UIButton *button = [UIButton buttonWithConfiguration:config primaryAction:nil];
        button.tag = i; [button addTarget:self action:@selector(openPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.footer addArrangedSubview:button];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.footer.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:16],
        [self.footer.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-16],
        [self.footer.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8],
        [self.footer.heightAnchor constraintEqualToConstant:52],
        [scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.footer.topAnchor constant:-8],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    self.homeStack = [UIStackView new];
    self.homeStack.axis = UILayoutConstraintAxisVertical;
    self.homeStack.spacing = 12; self.homeStack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:self.homeStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.homeStack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:18],
        [self.homeStack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-12],
        [self.homeStack.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor constant:28],
        [self.homeStack.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor constant:-28],
        [self.homeStack.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-56]
    ]];
    UILabel *eyebrow = RoseLabel(@"D O P A M I N E   /   R O S E  V 2", 10, UIFontWeightSemibold, RoseGold());
    [self.homeStack addArrangedSubview:eyebrow];
    UILabel *wordmark = RoseLabel(@"Quiet power.", 43, UIFontWeightRegular, [UIColor colorWithWhite:0.94 alpha:1]);
    UIFontDescriptor *serif = [[UIFont systemFontOfSize:43].fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignSerif];
    wordmark.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleLargeTitle] scaledFontForFont:[UIFont fontWithDescriptor:serif size:43]];
    [self.homeStack addArrangedSubview:wordmark];
    UIImageView *art = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RosePortrait"]];
    art.contentMode = UIViewContentModeScaleAspectFit;
    art.accessibilityLabel = @"Kid Buu, seated in contemplation";
    art.isAccessibilityElement = YES;
    [self.homeStack addArrangedSubview:art];
    CGFloat height = MIN(240, MAX(155, UIScreen.mainScreen.bounds.size.height - 465));
    [art.heightAnchor constraintEqualToConstant:height].active = YES;
    [self.homeStack setCustomSpacing:18 afterView:art];
    self.stateLabel = RoseLabel(@"", 22, UIFontWeightMedium, RosePink());
    self.detailLabel = RoseLabel(@"", 13, UIFontWeightRegular, RoseMuted());
    [self.homeStack addArrangedSubview:self.stateLabel];
    [self.homeStack setCustomSpacing:5 afterView:self.stateLabel];
    [self.homeStack addArrangedSubview:self.detailLabel];
    [self.homeStack setCustomSpacing:20 afterView:self.detailLabel];
    UIView *placeholder = [UIView new];
    [self.homeStack addArrangedSubview:placeholder];
    [placeholder.heightAnchor constraintEqualToConstant:56].active = YES;
    __weak typeof(self) weakSelf = self;
    self.jailbreakBtn = [[DOJailbreakButton alloc] initWithAction:[UIAction actionWithTitle:@"Begin jailbreak" image:[UIImage systemImageNamed:@"arrow.right"] identifier:@"jailbreak" handler:^(UIAction *action) {
        typeof(self) self = weakSelf;
        if (!self || self.operationStarted || !self.jailbreakBtn.enabled) return;
        self.operationStarted = YES;
        self.footer.hidden = YES; self.homeStack.hidden = YES;
        self.updateButton.hidden = YES;
        self.operationTitle = RoseLabel(@"Jailbreak session", 30, UIFontWeightMedium, RosePink());
        self.operationTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.operationTitle];
        [NSLayoutConstraint activateConstraints:@[
            [self.operationTitle.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
            [self.operationTitle.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
            [self.operationTitle.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24]
        ]];
        [self.jailbreakBtn expandButton:self.jailbreakButtonConstraints];
        [self startJailbreak];
    }]];
    [self.view addSubview:self.jailbreakBtn];
    self.jailbreakButtonConstraints = @[
        [self.jailbreakBtn.leadingAnchor constraintEqualToAnchor:placeholder.leadingAnchor],
        [self.jailbreakBtn.trailingAnchor constraintEqualToAnchor:placeholder.trailingAnchor],
        [self.jailbreakBtn.topAnchor constraintEqualToAnchor:placeholder.topAnchor],
        [self.jailbreakBtn.heightAnchor constraintEqualToAnchor:placeholder.heightAnchor]
    ];
    [NSLayoutConstraint activateConstraints:self.jailbreakButtonConstraints];
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.updateButton setTitle:@"Environment update available" forState:UIControlStateNormal];
    self.updateButton.hidden = YES;
    [self.updateButton addTarget:self action:@selector(openEnvironmentUpdate) forControlEvents:UIControlEventTouchUpInside];
    [self.homeStack addArrangedSubview:self.updateButton];
    // Keep environment updates available without replacing this fork with an upstream app update.
    self.updateButton.hidden = ![[DOUIManager sharedInstance] environmentUpdateAvailable];
    [self refreshState];
}
- (void)openEnvironmentUpdate {
    DOUIManager *ui = [DOUIManager sharedInstance];
    [self.navigationController pushViewController:[[DOUpdateViewController alloc] initFromTag:[DOEnvironmentManager sharedManager].jailbrokenVersion toTag:ui.getLaunchedReleaseTag] animated:YES];
}
- (void)openPage:(UIButton *)sender {
    UIViewController *next = sender.tag == 1 ? [DOSettingsController new] : [[RoseLibraryController alloc] initWithPage:sender.tag == 0 ? 1 : 0];
    if (sender.tag == 1) next.title = @"Settings";
    [[[UISelectionFeedbackGenerator alloc] init] selectionChanged];
    [self.navigationController pushViewController:next animated:YES];
}
- (void)refreshState {
    DOEnvironmentManager *env = [DOEnvironmentManager sharedManager];
    BOOL other = env.isJailbrokenWithOtherJailbreak;
    BOOL remove = [[DOPreferenceManager sharedManager] boolPreferenceValueForKey:@"removeJailbreakEnabled" fallback:NO];
    self.stateLabel.text = env.isJailbroken ? @"You're already free." : other ? @"Another jailbreak is active." : !env.isSupported ? @"Outside compatibility." : remove ? @"Removal is selected." : @"Ready when you are.";
    self.detailLabel.text = [NSString stringWithFormat:@"iOS %@ · %@\n%@", UIDevice.currentDevice.systemVersion, env.isArm64e ? @"ARM64e" : @"ARM64", remove ? @"The next operation removes the jailbreak." : env.isJailbroken ? @"Dopamine is active on this device." : env.isSupported && !other ? @"Your device passes Dopamine's compatibility checks." : @"Open Device for the current system state."];
    [self.jailbreakBtn.button setTitle:remove ? @"Remove jailbreak" : env.isJailbroken ? @"Jailbreak active" : !env.isSupported || other ? @"Jailbreak unavailable" : @"Begin jailbreak" forState:UIControlStateNormal];
    self.jailbreakBtn.enabled = env.isSupported && !env.isJailbroken && !other && !self.operationStarted;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.operationStarted) [self refreshState];
}

/* ROSE_PRESERVED_JAILBREAK_FLOW */

- (void)fadeToBlack:(void (^)(void))completion {
    self.hideStatusBar = YES;
    [UIView animateWithDuration:UIAccessibilityIsReduceMotionEnabled() ? 0 : 0.3 animations:^{ self.navigationController.view.alpha = 0; } completion:^(BOOL finished) { completion(); }];
}
- (BOOL)actionMenuShowsChevronForAction:(UIAction *)action { return NO; }
- (BOOL)actionMenuActionIsEnabled:(UIAction *)action { return YES; }
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (BOOL)prefersStatusBarHidden { return self.hideStatusBar; }
- (BOOL)prefersHomeIndicatorAutoHidden { return self.hideHomeIndicator; }
- (void)setHideStatusBar:(BOOL)value { _hideStatusBar = value; [self setNeedsStatusBarAppearanceUpdate]; }
- (void)setHideHomeIndicator:(BOOL)value { _hideHomeIndicator = value; [self setNeedsUpdateOfHomeIndicatorAutoHidden]; }
@end

