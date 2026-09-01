#import <UIKit/UIKit.h>

// 1. 自定义悬浮窗类
@interface ClickWindow : UIWindow
@end
@implementation ClickWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES; // 允许整个悬浮窗区域响应触摸
}
@end

// 2. 全局UI组件变量
static ClickWindow *floatWindow = nil;
static UIButton *floatButton = nil;
static UIView *menuView = nil;
static BOOL isMenuExpanded = NO;

// 3. 菜单交互管理类
@interface MenuManager : NSObject
+ (instancetype)sharedManager;
- (void)toggleMenu;
@end

@implementation MenuManager
+ (instancetype)sharedManager {
    static MenuManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MenuManager alloc] init];
    });
    return instance;
}

- (void)toggleMenu {
    isMenuExpanded = !isMenuExpanded;
    
    if (isMenuExpanded) {
        floatWindow.frame = CGRectMake(20, 100, 200, 250);
        floatButton.frame = CGRectMake(0, 0, 200, 40);
        [floatButton setTitle:@"关闭面板" forState:UIControlStateNormal];
        
        if (!menuView) {
            menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 200, 210)];
            menuView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
            titleLabel.text = @"自动点击配置面板";
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [menuView addSubview:titleLabel];
            
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
@end

// 4. Tweak 注入入口
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 获取当前活跃的 UIWindowScene（iOS 15 必须绑定 Scene 才能渲染窗口）
        UIWindowScene *activeScene = nil;
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }
        
        if (activeScene) {
            floatWindow = [[ClickWindow alloc] initWithWindowScene:activeScene];
        } else {
            floatWindow = [[ClickWindow alloc] init];
        }
        
        floatWindow.frame = CGRectMake(20, 100, 60, 60);
        floatWindow.windowLevel = UIWindowLevelAlert + 1000;
        
        // 必须设置 rootViewController，否则现代 iOS 不会展示窗口内部的子视图
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        floatWindow.rootViewController = rootVC;
        
        // 初始化悬浮球按钮
        floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatButton.frame = CGRectMake(0, 0, 60, 60);
        floatButton.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:1.0 alpha:0.6];
        [floatButton setTitle:@"点" forState:UIControlStateNormal];
        [floatButton addTarget:[MenuManager sharedManager] action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [rootVC.view addSubview:floatButton];
        
        // 显示窗口（但不抢占 App 的 keyWindow 焦点，避免影响 App 正常交互）
        floatWindow.hidden = NO;
    });
}
