#import "CronixStyle.h"

@interface CXEyeView : UIView
@end

@interface CXHomeView : UIView
@property(nonatomic, strong) UIButton *jailbreakButton;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, copy) void (^onSettings)(void);
@property(nonatomic, copy) void (^onLogs)(void);
- (instancetype)initWithModel:(NSString *)model system:(NSString *)system;
@end

@interface CXLogsController : UIViewController
@property(nonatomic, copy) NSString *(^readLogs)(void);
@property(nonatomic, copy) NSString *failure;
@end

@interface CXActivityController : UIViewController
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) UIStackView *eventStack;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@property(nonatomic, copy) void (^onLogs)(void);
- (void)appendEvent:(NSString *)event replacing:(BOOL)replacing;
- (void)finish;
@end

@interface CXSettingsController : UITableViewController
@property(nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *groups;
@property(nonatomic, copy) NSArray<NSString *> *headings;
@end
