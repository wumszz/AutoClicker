#import <UIKit/UIKit.h>

@interface ClickWindow : UIWindow
@end
@implementation ClickWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES; // 允许整个悬浮窗响应点击
}
@end

static ClickWindow *floatWindow = nil;
static UIButton *floatButton = nil;
static CGPoint targetPoint = {0, 0}; // 修复常量初始化报错

void simulateClick(CGPoint pt) {
    // 获取当前的主窗口（兼容 iOS 13+ 现代多场景）
    UIWindow *targetWindow = nil;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) {
            targetWindow = window;
            break;
        }
    }
    if (!targetWindow) {
        targetWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    
    UIView *hitView = [targetWindow hitTest:pt withEvent:nil];
    if (hitView) {
        // 后续可在此处完善触控事件分发
    }
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        floatWindow = [[ClickWindow alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
        floatWindow.windowLevel = UIWindowLevelAlert + 1000;
        floatWindow.hidden = NO;
        
        floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatButton.frame = floatWindow.bounds;
        floatButton.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:1.0 alpha:0.6];
        [floatButton setTitle:@"点" forState:UIControlStateNormal];
        [floatWindow addSubview:floatButton];
    });
}
