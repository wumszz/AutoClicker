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
static UITextField *timeField = nil;
static UITextField *coordField = nil;
static BOOL isPicking = NO;
static CGPoint targetPoint = CGPointZero;

// 模拟点击函数
void simulateClick(CGPoint pt) {
    mach_port_t port = MACH_PORT_NULL;
    // 使用 IOHIDEvent 或 sendEvent 注入触摸
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *hitView = [keyWindow hitTest:pt withEvent:nil];
    if (hitView) {
        // 构造事件并触发
        UITouch *touch = [[UITouch alloc] init];
        UIEvent *event = [[UIEvent alloc] init];
        // 实际开发中可精细构造 UITouch 序列
    }
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        floatWindow = [[ClickWindow alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
        floatWindow.windowLevel = UIWindowLevelAlert + 1000;
        floatWindow.hidden = NO;
        
        floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatButton.frame = floatWindow.bounds;
        floatButton.backgroundColor = [UIColor colorWithRed:0 green:0.4. blue:1.0 alpha:0.6];
        [floatButton setTitle:@"点" forState:UIControlStateNormal];
        [floatWindow addSubview:floatButton];
        
        // 点击悬浮球展开半透明菜单的代码逻辑...
    });
}
