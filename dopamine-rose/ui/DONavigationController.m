#import "DONavigationController.h"
#import "RoseUI.h"

@implementation DONavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    self.view.backgroundColor = RoseInk();
    self.view.tintColor = RosePink();
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = RoseInk();
    appearance.shadowColor = [UIColor colorWithWhite:0.16 alpha:1];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationBar.compactAppearance = appearance;
    [self setViewControllers:@[[DOMainViewController new]] animated:NO];
    self.delegate = self;
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self setNavigationBarHidden:[viewController isKindOfClass:DOMainViewController.class] animated:animated];
    viewController.navigationItem.backButtonTitle = @"Rose";
}
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
@end

