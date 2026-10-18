- (void)fadeToBlack:(void (^)(void))completion {
    self.hideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    UIView *container = self.navigationController.view;
    [UIView animateWithDuration:0.35 animations:^{ container.alpha = 0; } completion:^(BOOL finished) { completion(); }];
}
- (BOOL)actionMenuShowsChevronForAction:(UIAction *)action { return YES; }
- (BOOL)actionMenuActionIsEnabled:(UIAction *)action { return !self.started; }
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleDarkContent; }
- (BOOL)prefersStatusBarHidden { return self.hideStatusBar; }
- (BOOL)prefersHomeIndicatorAutoHidden { return self.hideHomeIndicator; }
@end
