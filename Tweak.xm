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

// 3. 菜单交互管理类 (解决按钮点击无法绑定的问题)
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

// 处理悬浮球展开/收起逻辑
- (void)toggleMenu {
    isMenuExpanded = !isMenuExpanded;
    
    if (isMenuExpanded) {
        // 展开面板
        floatWindow.frame = CGRectMake(20, 100, 200, 250);
        floatButton.frame = CGRectMake(0, 0, 200, 40);
        [floatButton setTitle:@"关闭面板" forState:UIControlStateNormal];
        
        // 懒加载创建菜单视图
        if (!menuView) {
            menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 200, 210)];
            menuView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
            titleLabel.text = @"自动点击配置面板";
            titleLabel.textColor = [UIColor whiteColor]; // 修复之前的颜色报错
            titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [menuView addSubview:titleLabel];
            
            [floatWindow addSubview:menuView];
        }
        menuView.hidden = NO;
        
    } else {
        // 收起面板，恢复悬浮球大小
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
    // 延迟 3 秒加载，确保 App 的主视图已经初始化完毕
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 初始化悬浮窗
        floatWindow = [[ClickWindow alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
        floatWindow.windowLevel = UIWindowLevelAlert + 1000;
        floatWindow.hidden = NO;
        
        // 初始化悬浮球按钮
        floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatButton.frame = floatWindow.bounds;
        floatButton.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:1.0 alpha:0.6];
        [floatButton setTitle:@"点" forState:UIControlStateNormal];
        
        // 正确绑定点击事件：将事件发送给 MenuManager 单例
        [floatButton addTarget:[MenuManager sharedManager] action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [floatWindow addSubview:floatButton];
    });
}
