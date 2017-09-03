//
//  TabbarController.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/28.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "TabbarController.h"

@interface TabbarController ()

@property(nonatomic,assign)BOOL shouldAutorotate;  //!<标记要不要让旋转

@end

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //初始化子控制器
    [self initChildrenViewController];
    
    
    //初始化字段，让其支持任意方向旋转，只有受到特殊通知，才不支持旋转
    self.shouldAutorotate = YES;
    //接收是否支持屏幕旋转的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AutorotateInterface:) name:@"InterfaceOrientation" object:nil];
}


/**
 *  初始化子控制器
 */
- (void)initChildrenViewController
{
    //控制器名字
    NSArray *viewControllers = @[@"MainViewController",
                                 @"NearViewController",
                                 @"ChoseViewController",
                                 @"MyViewController"];
    
    NSArray *titles = @[@"首页",
                        @"附近",
                        @"精选",
                        @"我的"];
    
    NSArray *normalImages = @[@"icon_tab_shouye_normal",
                              @"icon_tab_fujin_normal",
                              @"tab_icon_selection_normal",
                              @"icon_tab_wode_normal"];
    
    NSArray *selectImages = @[@"icon_tab_shouye_highlight",
                              @"icon_tab_fujin_highlight",
                              @"tab_icon_selection_highlight",
                              @"icon_tab_wode_highlight"];

    [viewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //初始化对象
        UIViewController *viewController = [[NSClassFromString(obj) alloc]init];
        //设置title
        viewController.title = titles[idx];
        //设置图片
        viewController.tabBarItem.image = [UIImage imageNamed:normalImages[idx]];
        viewController.tabBarItem.selectedImage = [UIImage imageNamed:selectImages[idx]];
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
        nav.navigationBar.translucent = YES;
        
        [self addChildViewController:nav];
    }];
    
}




#pragma mark - ------------- 旋转相关控制 -------------

-(void)AutorotateInterface:(NSNotification *)notifition
{
    _shouldAutorotate = [notifition.object boolValue];
}


//是否支持旋转
- (BOOL)shouldAutorotate
{
    if (!_shouldAutorotate) {
        return NO;
    }else{
        return YES;
    }
}


//适配旋转的类型
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (!_shouldAutorotate) {
        return UIInterfaceOrientationMaskPortrait;;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}




#if  0
反射机制

NSStringFromClass(<#Class  _Nonnull __unsafe_unretained aClass#>);
NSClassFromString(<#NSString * _Nonnull aClassName#>);
NSStringFromSelector(<#SEL  _Nonnull aSelector#>)
NSSelectorFromString(<#NSString * _Nonnull aSelectorName#>)
#endif







@end
