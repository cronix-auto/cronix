#import "DONavigationController.h"
#import "CronixStyle.h"

@implementation DONavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    self.view.backgroundColor = CXBackground();
    self.navigationBar.tintColor = CXInk();
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = CXBackground();
    appearance.titleTextAttributes = @{ NSForegroundColorAttributeName:CXInk(), NSFontAttributeName:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold] };
    appearance.shadowColor = UIColor.clearColor;
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationBar.compactAppearance = appearance;
    [self setViewControllers:@[[DOMainViewController new]] animated:NO];
}
- (UIViewController *)childViewControllerForStatusBarStyle { return self.topViewController; }
- (UIViewController *)childViewControllerForStatusBarHidden { return self.topViewController; }
@end
