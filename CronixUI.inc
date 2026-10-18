#import "CronixUI.h"

static UILabel *CXLabel(NSString *text, CGFloat size, UIFontWeight weight) {
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = CXInk();
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 0;
    label.adjustsFontForContentSizeCategory = YES;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

static UIView *CXDivider(void) {
    UIView *line = [UIView new];
    line.backgroundColor = CXLine();
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [line.heightAnchor constraintEqualToConstant:0.5].active = YES;
    return line;
}

@implementation CXEyeView
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = UIColor.clearColor;
        self.isAccessibilityElement = NO;
    }
    return self;
}
- (void)drawRect:(CGRect)rect { CXDrawEye(self.bounds); }
@end

@implementation CXHomeView
- (instancetype)initWithModel:(NSString *)model system:(NSString *)system {
    if (!(self = [super initWithFrame:CGRectZero])) return nil;
    self.backgroundColor = CXBackground();

    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = NO;
    [self addSubview:scroll];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 22;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];

    UIStackView *identity = [UIStackView new];
    identity.axis = UILayoutConstraintAxisVertical;
    identity.alignment = UIStackViewAlignmentCenter;
    identity.spacing = 10;
    CXEyeView *eye = [CXEyeView new];
    eye.translatesAutoresizingMaskIntoConstraints = NO;
    [identity addArrangedSubview:eye];
    [NSLayoutConstraint activateConstraints:@[
        [eye.widthAnchor constraintEqualToConstant:106],
        [eye.heightAnchor constraintEqualToConstant:66]
    ]];
    UILabel *name = CXLabel(@"Cronix", 30, UIFontWeightBold);
    [identity addArrangedSubview:name];
    UILabel *byline = CXLabel(@"Made by: Zenyical (creds also: oppa334)", 12, UIFontWeightRegular);
    byline.textColor = CXSecondary();
    byline.textAlignment = NSTextAlignmentCenter;
    [identity addArrangedSubview:byline];
    [byline.widthAnchor constraintLessThanOrEqualToAnchor:stack.widthAnchor].active = YES;
    [stack addArrangedSubview:identity];

    UIStackView *details = [UIStackView new];
    details.axis = UILayoutConstraintAxisVertical;
    details.backgroundColor = CXSurface();
    details.layer.cornerRadius = 12;
    details.layer.masksToBounds = YES;
    NSArray *titles = @[@"Device", @"iOS Version", @"Status"];
    NSArray *values = @[model, system, @"Not Jailbroken"];
    for (NSUInteger i = 0; i < titles.count; i++) {
        UIView *row = [UIView new];
        UILabel *title = CXLabel(titles[i], 16, UIFontWeightRegular);
        UILabel *value = CXLabel(values[i], 15, UIFontWeightRegular);
        value.textColor = CXSecondary();
        value.textAlignment = NSTextAlignmentRight;
        [title setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [row addSubview:title]; [row addSubview:value];
        [NSLayoutConstraint activateConstraints:@[
            [row.heightAnchor constraintGreaterThanOrEqualToConstant:49],
            [title.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:16],
            [title.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
            [value.leadingAnchor constraintGreaterThanOrEqualToAnchor:title.trailingAnchor constant:12],
            [value.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-16],
            [value.topAnchor constraintGreaterThanOrEqualToAnchor:row.topAnchor constant:12],
            [value.bottomAnchor constraintLessThanOrEqualToAnchor:row.bottomAnchor constant:-12],
            [value.centerYAnchor constraintEqualToAnchor:row.centerYAnchor]
        ]];
        if (i == 2) self.statusLabel = value;
        [details addArrangedSubview:row];
        if (i < 2) [details addArrangedSubview:CXDivider()];
    }
    [stack addArrangedSubview:details];

    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
    config.title = @"Jailbreak";
    config.image = [UIImage systemImageNamed:@"chevron.right"];
    config.imagePlacement = NSDirectionalRectEdgeTrailing;
    config.imagePadding = 18;
    config.baseBackgroundColor = CXInk();
    config.baseForegroundColor = CXSurface();
    config.cornerStyle = UIButtonConfigurationCornerStyleMedium;
    config.contentInsets = NSDirectionalEdgeInsetsMake(14, 20, 14, 20);
    self.jailbreakButton.configuration = config;
    [self.jailbreakButton.heightAnchor constraintGreaterThanOrEqualToConstant:52].active = YES;
    [stack addArrangedSubview:self.jailbreakButton];

    UIStackView *toolbar = [UIStackView new];
    toolbar.axis = UILayoutConstraintAxisHorizontal;
    toolbar.distribution = UIStackViewDistributionFillEqually;
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *labels = @[@"Settings", @"Logs"];
    NSArray *symbols = @[@"gearshape", @"doc.text"];
    for (NSUInteger i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
        configuration.title = labels[i];
        configuration.image = [UIImage systemImageNamed:symbols[i]];
        configuration.imagePadding = 12;
        configuration.baseForegroundColor = CXInk();
        button.configuration = configuration;
        __weak typeof(self) weakSelf = self;
        [button addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
            if (i == 0 && weakSelf.onSettings) weakSelf.onSettings();
            if (i == 1 && weakSelf.onLogs) weakSelf.onLogs();
        }] forControlEvents:UIControlEventTouchUpInside];
        [toolbar addArrangedSubview:button];
    }
    [self addSubview:toolbar];
    UIView *topLine = CXDivider(); [self addSubview:topLine];
    UIView *split = [UIView new];
    split.backgroundColor = CXLine(); split.translatesAutoresizingMaskIntoConstraints = NO;
    [toolbar addSubview:split];
    [NSLayoutConstraint activateConstraints:@[
        [toolbar.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:20],
        [toolbar.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [toolbar.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:-8],
        [toolbar.heightAnchor constraintEqualToConstant:52],
        [topLine.leadingAnchor constraintEqualToAnchor:toolbar.leadingAnchor],
        [topLine.trailingAnchor constraintEqualToAnchor:toolbar.trailingAnchor],
        [topLine.bottomAnchor constraintEqualToAnchor:toolbar.topAnchor],
        [split.centerXAnchor constraintEqualToAnchor:toolbar.centerXAnchor],
        [split.centerYAnchor constraintEqualToAnchor:toolbar.centerYAnchor],
        [split.widthAnchor constraintEqualToConstant:0.5],
        [split.heightAnchor constraintEqualToConstant:22],
        [scroll.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:toolbar.topAnchor constant:-16],
        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:22],
        [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-12],
        [stack.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor constant:-20],
        [stack.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-40]
    ]];
    return self;
}
@end

@interface CXLogsController ()
@property(nonatomic, strong) UITextView *textView;
@end
@implementation CXLogsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.title ?: (self.failure ? @"Jailbreak Failed" : @"Logs");
    self.view.backgroundColor = CXBackground();
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.textView = [UITextView new];
    self.textView.backgroundColor = CXSurface();
    self.textView.textColor = CXInk();
    self.textView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.textView.editable = NO;
    self.textView.textContainerInset = UIEdgeInsetsMake(16, 12, 16, 12);
    self.textView.layer.cornerRadius = 12;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.textView];
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:16],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-16],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16]
    ]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"CronixLogChanged" object:nil];
    [self refresh];
}
- (void)refresh {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self refresh]; }); return;
    }
    BOOL atBottom = self.textView.contentOffset.y + self.textView.bounds.size.height >= self.textView.contentSize.height - 40;
    NSString *logs = self.readLogs ? self.readLogs() : @"";
    NSString *text = logs.length ? logs : @"No logs yet. Logs appear here when you start the jailbreak.";
    if (self.failure) text = [NSString stringWithFormat:@"%@\n\n%@", self.failure, text];
    if (![self.textView.text isEqualToString:text]) self.textView.text = text;
    if (atBottom && self.textView.text.length) [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 1, 1)];
}
- (void)share:(UIBarButtonItem *)sender {
    NSString *text = self.readLogs ? self.readLogs() : @"";
    if (!text.length) return;
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    share.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:share animated:YES completion:nil];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
@end

@interface CXActivityController ()
@property(nonatomic, strong) NSMutableArray<UILabel *> *events;
@property(nonatomic) BOOL finished;
@end
@implementation CXActivityController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Activity";
    self.view.backgroundColor = CXBackground();
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logs" style:UIBarButtonItemStylePlain target:self action:@selector(openLogs)];
    self.events = [NSMutableArray new];
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UIStackView *stack = [UIStackView new];
    stack.axis = UILayoutConstraintAxisVertical; stack.spacing = 24;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];
    UIStackView *header = [UIStackView new];
    header.axis = UILayoutConstraintAxisVertical; header.alignment = UIStackViewAlignmentCenter; header.spacing = 20;
    CXEyeView *eye = [CXEyeView new]; eye.translatesAutoresizingMaskIntoConstraints = NO;
    [header addArrangedSubview:eye];
    [eye.widthAnchor constraintEqualToConstant:96].active = YES;
    [eye.heightAnchor constraintEqualToConstant:60].active = YES;
    self.statusLabel = CXLabel(@"Preparing to start", 19, UIFontWeightMedium);
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [header addArrangedSubview:self.statusLabel];
    [self.statusLabel.widthAnchor constraintLessThanOrEqualToAnchor:stack.widthAnchor].active = YES;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.color = CXInk(); [self.spinner startAnimating];
    [header addArrangedSubview:self.spinner];
    [stack addArrangedSubview:header];
    self.eventStack = [UIStackView new];
    self.eventStack.axis = UILayoutConstraintAxisVertical; self.eventStack.spacing = 0;
    self.eventStack.backgroundColor = CXSurface();
    self.eventStack.layer.cornerRadius = 12;
    self.eventStack.layoutMargins = UIEdgeInsetsMake(8, 16, 8, 16);
    self.eventStack.layoutMarginsRelativeArrangement = YES;
    [stack addArrangedSubview:self.eventStack];
    UILabel *note = CXLabel(@"Keep Cronix open while this runs.", 13, UIFontWeightRegular);
    note.textColor = CXSecondary(); [stack addArrangedSubview:note];
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:28],
        [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-24],
        [stack.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor constant:-20],
        [stack.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-40]
    ]];
}
- (void)openLogs { if (self.onLogs) self.onLogs(); }
- (void)appendEvent:(NSString *)event replacing:(BOOL)replacing {
    NSAssert(NSThread.isMainThread, @"Activity updates belong on the main thread");
    [self loadViewIfNeeded];
    self.statusLabel.text = event;
    if (replacing && self.events.count) {
        self.events.lastObject.text = [@"•  " stringByAppendingString:event];
        return;
    }
    // Completed means a later engine event arrived, never an estimated percentage.
    UILabel *previous = self.events.lastObject;
    if (previous) {
        previous.text = [previous.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"✓"];
        previous.textColor = CXSecondary();
    }
    UILabel *label = CXLabel([@"•  " stringByAppendingString:event], 14, UIFontWeightRegular);
    [label.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [self.eventStack addArrangedSubview:label]; [self.events addObject:label];
    if (self.events.count > 7) {
        UILabel *first = self.events.firstObject;
        [self.eventStack removeArrangedSubview:first]; [first removeFromSuperview];
        [self.events removeObjectAtIndex:0];
    }
}
- (void)finish {
    self.finished = YES;
    [self appendEvent:@"Finalizing jailbreak" replacing:NO];
    [self.spinner stopAnimating];
}
@end

@implementation CXSettingsController
- (instancetype)init { return [super initWithStyle:UITableViewStyleInsetGrouped]; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.title ?: @"Settings";
    self.tableView.backgroundColor = CXBackground();
    self.tableView.separatorColor = CXLine();
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 49;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.groups.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.groups[section].count; }
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section < self.headings.count ? self.headings[section] : nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = self.groups[indexPath.section][indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.backgroundColor = CXSurface();
    cell.textLabel.text = row[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [row[@"destructive"] boolValue] ? UIColor.systemRedColor : CXInk();
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = row[@"value"];
    cell.detailTextLabel.textColor = CXSecondary();
    cell.selectionStyle = row[@"action"] ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    if (row[@"action"]) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (row[@"toggle"]) {
        UISwitch *toggle = [UISwitch new];
        toggle.on = [row[@"on"] boolValue];
        toggle.onTintColor = CXInk();
        void (^change)(BOOL) = row[@"toggle"];
        __weak UISwitch *weakToggle = toggle;
        [toggle addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) { change(weakToggle.isOn); }] forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    void (^action)(void) = self.groups[indexPath.section][indexPath.row][@"action"];
    if (action) action();
}
@end
