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
static UIView *menuView = nil;
static BOOL isMenuExpanded = NO;

void simulateClick(CGPoint pt) {
    // 适配 iOS 15+ 现代多场景窗口获取方式
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

// 悬浮球点击事件：展开或收起半透明面板
static void floatButtonClicked(UIButton *sender) {
    isMenuExpanded = !isMenuExpanded;
    if (isMenuExpanded) {
        floatWindow.frame = CGRectMake(20, 100, 200, 250);
        floatButton.frame = CGRectMake(0, 0, 200, 40);
        [floatButton setTitle:@"关闭面板" forState:UIControlStateNormal];
        
        if (!menuView) {
            menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 200, 210)];
            menuView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8]; // 半透明背景
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
            label.text = @"自动点击配置面板";
            label.textColor = [UIColor whiteStatusBar ? [UIColor whiteColor] : [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:14];
            [menuView addSubview:label];
            
            [floatWindow addSubview:menuView];
        }
        menuView.hidden = NO;
    } else {
        floatWindow.frame = CGRectMake(20, 100, 60, 60);
        floatButton.frame = floatWindow.bounds;
        [floatButton setTitle:@"点" forState:UIControlStateNormal];
        if (menuView) {
            menuView.hidden = YES;
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
        [floatButton addTarget:nil action:@selector(floatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // 绑定点击方法
        [floatButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        // 简易 Objective-C Target 绑定
        [floatButton, cxx_destruct]; // 保持结构
    });
}
