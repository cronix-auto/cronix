#import "DOJailbreakButton.h"
#import "DOUIManager.h"
#import "RoseUI.h"

@interface RoseProgressView : UIView <DOLogViewProtocol>
@property UILabel *stage;
@property UITextView *transcript;
@property UIActivityIndicatorView *spinner;
@property UIButton *shareButton;
@end
@implementation RoseProgressView
- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = RoseInk();
        self.stage = RoseLabel(@"Preparing session", 20, UIFontWeightMedium, [UIColor whiteColor]);
        UILabel *note = RoseLabel(@"Live engine messages. Keep Rose open until the operation finishes.", 13, UIFontWeightRegular, RoseMuted());
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.spinner.color = RoseGold(); self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self.spinner startAnimating];
        self.transcript = [UITextView new]; self.transcript.translatesAutoresizingMaskIntoConstraints = NO;
        self.transcript.editable = NO; self.transcript.backgroundColor = RoseInk();
        self.transcript.textColor = RoseMuted();
        self.transcript.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
        self.transcript.textContainerInset = UIEdgeInsetsMake(12, 0, 12, 0);
        self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.shareButton setTitle:@"Export session log" forState:UIControlStateNormal];
        [self.shareButton setImage:[UIImage systemImageNamed:@"square.and.arrow.up"] forState:UIControlStateNormal];
        self.shareButton.tintColor = RosePink(); self.shareButton.enabled = NO;
        [self.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        for (UIView *view in @[self.stage, note, self.spinner, self.transcript, self.shareButton]) [self addSubview:view];
        [NSLayoutConstraint activateConstraints:@[
            [self.stage.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24],
            [self.stage.trailingAnchor constraintEqualToAnchor:self.spinner.leadingAnchor constant:-12],
            [self.stage.topAnchor constraintEqualToAnchor:self.topAnchor constant:20],
            [self.spinner.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24],
            [self.spinner.centerYAnchor constraintEqualToAnchor:self.stage.centerYAnchor],
            [note.leadingAnchor constraintEqualToAnchor:self.stage.leadingAnchor],
            [note.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24],
            [note.topAnchor constraintEqualToAnchor:self.stage.bottomAnchor constant:12],
            [self.transcript.leadingAnchor constraintEqualToAnchor:note.leadingAnchor],
            [self.transcript.trailingAnchor constraintEqualToAnchor:note.trailingAnchor],
            [self.transcript.topAnchor constraintEqualToAnchor:note.bottomAnchor constant:20],
            [self.transcript.bottomAnchor constraintEqualToAnchor:self.shareButton.topAnchor constant:-8],
            [self.shareButton.leadingAnchor constraintEqualToAnchor:note.leadingAnchor],
            [self.shareButton.trailingAnchor constraintEqualToAnchor:note.trailingAnchor],
            [self.shareButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12],
            [self.shareButton.heightAnchor constraintEqualToConstant:48]
        ]];
    }
    return self;
}
- (void)showLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stage.text = log;
        // Keep rendering bounded on A9. The complete record remains available for export.
        NSString *text = [self.transcript.text stringByAppendingFormat:@"%@%@", self.transcript.text.length ? @"\n" : @"", log];
        if (text.length > 24000) text = [text substringFromIndex:text.length - 24000];
        self.transcript.text = text;
        if (text.length) [self.transcript scrollRangeToVisible:NSMakeRange(text.length - 1, 1)];
        self.shareButton.enabled = YES;
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, log);
    });
}
- (void)updateLog:(NSString *)log { [self showLog:log]; }
- (void)didComplete {
    dispatch_async(dispatch_get_main_queue(), ^{ self.stage.text = @"Jailbreak complete"; [self.spinner stopAnimating]; });
}
- (void)share:(id)sender { [[DOUIManager sharedInstance] shareLogRecordFromView:self.shareButton]; }
@end

@implementation DOJailbreakButton
- (instancetype)initWithAction:(UIAction *)action {
    if ((self = [super init])) {
        pthread_mutex_init(&_canStartJailbreak, NULL);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = RosePink(); self.layer.cornerRadius = 4;
        self.button = [DOActionMenuButton buttonWithAction:action chevron:NO];
        UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
        config.title = action.title; config.image = action.image;
        config.baseForegroundColor = RoseInk(); config.imagePadding = 12;
        config.imagePlacement = NSDirectionalRectEdgeTrailing;
        config.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *attributes) {
            NSMutableDictionary *result = attributes.mutableCopy;
            result[NSFontAttributeName] = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
            return result;
        };
        self.button.configuration = config;
        self.button.translatesAutoresizingMaskIntoConstraints = NO;
        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:self.button];
        [NSLayoutConstraint activateConstraints:@[
            [self.button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.button.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
    }
    return self;
}
- (void)expandButton:(NSArray<NSLayoutConstraint *> *)constraints {
    if (self.didExpand) return;
    [self lockMutex]; self.didExpand = YES;
    self.button.hidden = YES;
    self.backgroundColor = RoseInk(); self.layer.cornerRadius = 0;
    [NSLayoutConstraint deactivateConstraints:constraints];
    UIView *parent = self.superview;
    [NSLayoutConstraint activateConstraints:@[
        [self.leadingAnchor constraintEqualToAnchor:parent.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:parent.trailingAnchor],
        [self.topAnchor constraintEqualToAnchor:parent.safeAreaLayoutGuide.topAnchor constant:96],
        [self.bottomAnchor constraintEqualToAnchor:parent.safeAreaLayoutGuide.bottomAnchor]
    ]];
    self.logView = [RoseProgressView new];
    self.logView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.logView];
    [NSLayoutConstraint activateConstraints:@[
        [self.logView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.logView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.logView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.logView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    [DOUIManager sharedInstance].logView = self.logView;
    if ([[DOUIManager sharedInstance] enabledPackageManagerKeys].count) {
        [self unlockMutex];
    } else {
        // Preserve the upstream package-manager gate before the engine is allowed to start.
        self.logView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        self.pkgManagerPickerView = [[DOPkgManagerPickerView alloc] initWithCallback:^(BOOL success) {
            typeof(self) self = weakSelf;
            if (!self || !success) return;
            [self.pkgManagerPickerView removeFromSuperview]; self.pkgManagerPickerView = nil;
            self.logView.hidden = NO; [self unlockMutex];
        }];
        self.pkgManagerPickerView.backgroundColor = RoseInk();
        self.pkgManagerPickerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.pkgManagerPickerView];
        [NSLayoutConstraint activateConstraints:@[
            [self.pkgManagerPickerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.pkgManagerPickerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.pkgManagerPickerView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.pkgManagerPickerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
    }
    [parent layoutIfNeeded];
}
- (void)setEnabled:(BOOL)enabled {
    self.button.userInteractionEnabled = enabled;
    self.button.accessibilityTraits = enabled ? UIAccessibilityTraitButton : UIAccessibilityTraitButton | UIAccessibilityTraitNotEnabled;
    self.alpha = enabled ? 1 : 0.65;
}
- (BOOL)isEnabled { return self.button.userInteractionEnabled; }
- (void)lockMutex { pthread_mutex_lock(&_canStartJailbreak); }
- (void)unlockMutex { pthread_mutex_unlock(&_canStartJailbreak); }
- (void)dealloc { pthread_mutex_destroy(&_canStartJailbreak); }
@end

