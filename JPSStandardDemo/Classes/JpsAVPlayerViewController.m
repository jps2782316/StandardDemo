//
//  JpsAVPlayerViewController.m
//  JPSStandardDemo
//
//  Created by jps on 2017/5/17.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsAVPlayerViewController.h"
#import "JpsPlayerView.h"



@interface JpsAVPlayerViewController ()


@property(nonatomic,strong)JpsPlayerView *playerView;



@end

@implementation JpsAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavigationBar];
    
    self.playerView = [[JpsPlayerView alloc]initWithFrame:CGRectMake(0, 0, Width, 300)];
    
//    NSString *str1 = [[NSBundle mainBundle] pathForResource:@"haha" ofType:@"mp4"];
//    self.playerView.localVedioUrl = str1;
    
    NSString *str2 = @"http://baobab.cdn.wandoujia.com/14468618701471.mp4";
    //NSString *str2 = @"http://nesec.oss-cn-shenzhen.aliyuncs.com/nxa_app_jxjy/aqjy_25.mp4";
    self.playerView.vedioName = @"魔兽世界";
    self.playerView.vedioUrl = str2;
    self.playerView.fillMode = ResizeAspectFill;
    [self.view addSubview:self.playerView];
    
    
    
    //需要旋转的控制器不是根控制器，只简单的重写shouldAutorotate是没效果的，只能在需要旋转的页面把要不要旋转的参数传到根试图，让根视图来操作是否要旋转。
    
    //http://blog.csdn.net/lqq200912408/article/details/51088987   [iOS]关于iOS中界面视图横屏/竖屏切换的问题总结
    
    //发送转屏通知，只支持竖屏，不让自动旋转
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InterfaceOrientation" object:@"NO"];
    
}




#pragma mark - ------------- 导航栏参数配置 -------------
- (void)initNavigationBar
{
    //设置导航栏背景图片为一个空的image，这样就透明了
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑线
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    
    //设置导航栏title字体大小颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //self.navigationItem.title = @"自定义播放器";
    //不渲染
    UIImage *image = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backClick:)];
}

- (void)backClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)viewWillDisappear:(BOOL)animated
{
    //销毁定时器和播放器
    [self.playerView destroyPlayer];
    
    //设置导航栏title字体大小颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    
    
    //    如果不想让其他页面的导航栏变为透明 需要重置
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
    
    
    //发送转屏通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InterfaceOrientation" object:@"YES"];
    
}









//- (void)viewWillDisappear:(BOOL)animated{
//    
//    //    如果不想让其他页面的导航栏变为透明 需要重置
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:nil];
//}







// 1. 设置状态栏样式 白色
//不包导航控制器的情况下，设置着一句就有效果
//包裹导航控制器的情况下，要在plist里加东西   详细：http://www.jianshu.com/p/25e9c1a864be
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent; // 白色的
}


////允许横屏旋转 (带导航栏的时候，设置这一句没效果)
//- (BOOL)shouldAutorotate{
//    return NO;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    //viewController初始显示的方向
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}
//
////支持左右旋转
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}







#pragma mark - ------------- 如果把player放到控制器 在需要横屏的VC中重写下列方法即可 -------------

//// 2. 横屏时是否隐藏状态栏   默认隐藏(有导航栏是貌似没用)
//- (BOOL)prefersStatusBarHidden {
//    return NO; // 显示
//}
//- (void)setStatusBarHidden:(BOOL)hidden{
//    //取出当前控制器的导航条
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    //设置是否隐藏
//    statusBar.hidden  = hidden;
//}
//
//// 3. 设置状态栏隐藏动画
//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
//    return UIStatusBarAnimationFade;
//}




////允许横屏旋转
//- (BOOL)shouldAutorotate{
//    return YES;
//}
//
//
////支持左右旋转
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
//}
//
////默认为右旋转
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationLandscapeRight;
//}








#pragma mark - ------------- 扩展 -------------

//-setNeedsLayout方法： 标记为需要重新布局，异步调用layoutIfNeeded刷新布局，不立即刷新，但layoutSubviews一定会被调用
//-layoutIfNeeded方法：如果，有需要刷新的标记，立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）
//如果要立即刷新，要先调用[view setNeedsLayout]，把标记设为需要布局，然后马上调用[view layoutIfNeeded]，实现布局

//[self setNeedsLayout];
//[self layoutIfNeeded];


//layoutSubviews  此方法用来重新定义子元素的位置和大小。当子类重写此方法，用来实现UI元素的更精确布局。如果要让布局重新刷新，那么就调用setNeedsLayout，即setNeedsLayout方法会默认用layoutSubViews方法。

//setNeedsLayout 用于还未设置父子控件的frame时,调用该方法,会在其frame被设置后,即恰当的时刻,自动完成布局.  setNeedsLayout方法并不会立即刷新，立即刷新需要调用layoutIfNeeded方法

//与setNeedsLayOut方法相似的方法是setNeedsDisplay方法。该方法在调用时，会自动调用drawRect方法。drawRect方法主要用来画图。






@end
