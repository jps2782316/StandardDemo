//
//  JPSPlayerViewController.m
//  JPSStandardDemo
//
//  Created by jps on 2017/12/6.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JPSPlayerViewController.h"
#import "JPSPlayerView2.h"

@interface JPSPlayerViewController ()

@property(nonatomic,strong)JPSPlayerView2 *playerView;  //!<播放器

@end

@implementation JPSPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    
    self.playerView = [[JPSPlayerView2 alloc]initWithFrame:CGRectMake(0, 100, Width, 300)];
    [self.view addSubview:self.playerView];
    
}




#pragma mark - ------------- UI -------------

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










@end
