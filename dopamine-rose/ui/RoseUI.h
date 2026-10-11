#import <UIKit/UIKit.h>

static inline UIColor *RoseInk(void) { return [UIColor colorWithRed:0.025 green:0.025 blue:0.029 alpha:1]; }
static inline UIColor *RosePink(void) { return [UIColor colorWithRed:0.89 green:0.65 blue:0.71 alpha:1]; }
static inline UIColor *RoseGold(void) { return [UIColor colorWithRed:0.76 green:0.64 blue:0.49 alpha:1]; }
static inline UIColor *RoseMuted(void) { return [UIColor colorWithWhite:0.66 alpha:1]; }
static inline UILabel *RoseLabel(NSString *text, CGFloat size, UIFontWeight weight, UIColor *color) {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = color;
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.adjustsFontForContentSizeCategory = YES;
    label.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:label.font];
    return label;
}

