#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static inline UIColor *CXBackground(void) { return [UIColor colorWithRed:0.91 green:0.915 blue:0.925 alpha:1]; }
static inline UIColor *CXSurface(void) { return [UIColor colorWithWhite:0.965 alpha:1]; }
static inline UIColor *CXInk(void) { return [UIColor colorWithWhite:0.16 alpha:1]; }
static inline UIColor *CXSecondary(void) { return [UIColor colorWithWhite:0.43 alpha:1]; }
static inline UIColor *CXLine(void) { return [UIColor colorWithWhite:0.82 alpha:1]; }

// One vector is used for the home emblem, activity screen, and app icon.
static inline void CXDrawEye(CGRect rect) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextScaleCTM(context, rect.size.width / 160.0, rect.size.height / 100.0);
    [CXInk() setFill];
    UIBezierPath *eye = [UIBezierPath bezierPath];
    [eye moveToPoint:CGPointMake(7, 74)];
    [eye addCurveToPoint:CGPointMake(151, 31) controlPoint1:CGPointMake(49, 27) controlPoint2:CGPointMake(95, 20)];
    [eye addCurveToPoint:CGPointMake(7, 74) controlPoint1:CGPointMake(107, 95) controlPoint2:CGPointMake(56, 96)];
    [eye closePath];
    [eye fill];
    [CXBackground() setFill];
    UIBezierPath *opening = [UIBezierPath bezierPath];
    [opening moveToPoint:CGPointMake(27, 69)];
    [opening addCurveToPoint:CGPointMake(132, 43) controlPoint1:CGPointMake(65, 43) controlPoint2:CGPointMake(100, 34)];
    [opening addCurveToPoint:CGPointMake(27, 69) controlPoint1:CGPointMake(100, 80) controlPoint2:CGPointMake(66, 87)];
    [opening fill];
    [CXInk() setFill];
    UIBezierPath *pupil = [UIBezierPath bezierPath];
    [pupil moveToPoint:CGPointMake(83, 40)];
    [pupil addCurveToPoint:CGPointMake(81, 79) controlPoint1:CGPointMake(94, 50) controlPoint2:CGPointMake(90, 67)];
    [pupil addCurveToPoint:CGPointMake(83, 40) controlPoint1:CGPointMake(73, 64) controlPoint2:CGPointMake(74, 51)];
    [pupil fill];
    UIBezierPath *brow = [UIBezierPath bezierPath];
    [brow moveToPoint:CGPointMake(10, 62)];
    [brow addLineToPoint:CGPointMake(48, 20)];
    [brow addLineToPoint:CGPointMake(43, 34)];
    [brow addLineToPoint:CGPointMake(85, 9)];
    [brow addLineToPoint:CGPointMake(76, 23)];
    [brow addLineToPoint:CGPointMake(129, 5)];
    [brow addLineToPoint:CGPointMake(115, 21)];
    [brow addLineToPoint:CGPointMake(153, 17)];
    [brow addCurveToPoint:CGPointMake(10, 62) controlPoint1:CGPointMake(116, 34) controlPoint2:CGPointMake(64, 25)];
    [brow fill];
    CGContextRestoreGState(context);
}
