//
//  JpsWelcomeViewController.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/2.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsWelcomeViewController.h"
#import "JpsWelcomeView.h"

//引导页

@interface JpsWelcomeViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;

@end

@implementation JpsWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self scrollView];
    
    NSArray *foreImages = @[@"bwa_guide_person_1_414x736_", @"bwa_guide_person_2_414x736_", @""];
    NSArray *backgroundImages = @[@"bwa_guide_bg_1_414x736_", @"bwa_guide_bg_2_414x736_", @"bwa_guide_bg_3_414x736_"];
    
    for (int i = 0; i < 3; i++) {
        CGRect frame = CGRectMake(Width*i, 0, Width, Height);
        JpsWelcomeView *welcomeV = [[JpsWelcomeView alloc]initWithForeImage:foreImages[i] backgroundImage:backgroundImages[i] frame:frame];
        [self.scrollView addSubview:welcomeV];
    }
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    DLog(@"即佛额外");
    
    //缩放背景视图
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TransformMakeScale" object:@(scrollView.contentOffset.x)];
}




#pragma mark - ---------- lazy -----------

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(3*Width, 0);
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

@end
