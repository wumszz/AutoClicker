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
static CGPoint targetPoint = {0, 0};

void simulateClick(CGPoint pt) {
    // 适配 iOS 15+ 现代多场景窗口获取方式，消除弃用警告
    UIWindow *targetWindow = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    targetWindow = window;
                    break;
                }
            }
        }
        if (targetWindow) break;
    }
    if (!targetWindow) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                targetWindow = windowScene.windows.firstObject;
                if (targetWindow) break;
            }
        }
    }
    
    if (targetWindow) {
        UIView *hitView = [targetWindow hitTest:pt withEvent:nil];
        if (hitView) {
            // 后续可在此处完善触控事件分发
        }
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
