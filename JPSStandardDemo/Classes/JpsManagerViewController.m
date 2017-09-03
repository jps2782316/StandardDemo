//
//  JpsManagerViewController.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/2.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsManagerViewController.h"
#import "JpsLeftViewController.h"
#import "TabbarController.h"

@interface JpsManagerViewController ()

@property(nonatomic,strong)TabbarController *rightVC;
@property(nonatomic,strong)JpsLeftViewController *leftVC;

@end

@implementation JpsManagerViewController



- (instancetype)initWithLeftVC:(id)leftVC rightVC:(id)rightVC
{
    self = [super init];
    if (self) {
        
        self.rightVC = rightVC;
        self.leftVC = leftVC;
        
        //设置左右控制器frame
        self.rightVC.view.frame = [UIScreen mainScreen].bounds;
        self.leftVC.view.frame = [UIScreen mainScreen].bounds;
        
        //父控制器添加子控制器
        [self addChildViewController:self.leftVC];
        //父控制器view添加子控制器view
        [self.view addSubview:self.leftVC.view];
        //子控制器确认添加到付控制器
        [self.leftVC didMoveToParentViewController:self];
        
        [self addChildViewController:self.rightVC];
        [self.view addSubview:self.rightVC.view];
        [self.rightVC didMoveToParentViewController:self];
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
}


#pragma mark - ---------- 手势 -----------

- (void)rightSwipe:(UIGestureRecognizer *)swipe
{
    //    if (self.rightVC.view.frame.origin.x > 0) {
    //        return;
    //    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform transform0 = CGAffineTransformMakeScale(0.7, 0.7); //缩放变换
        CGAffineTransform transform1 = CGAffineTransformMakeTranslation(220, 0); //位移变换
        self.rightVC.view.transform = CGAffineTransformConcat(transform0, transform1);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform transform0 = CGAffineTransformMakeScale(0.75, 0.75); //缩放变换
            CGAffineTransform transform1 = CGAffineTransformMakeTranslation(200, 0); //位移变换
            self.rightVC.view.transform = CGAffineTransformConcat(transform0, transform1);
        }];
    }];
    
    //        CGAffineTransform transform2 = CGAffineTransformMakeRotation(M_PI);  //旋转变换
    //        CGAffineTransform transform3 = CGAffineTransformScale(transform1, 0.5, 0.5);  //组合变换
}


- (void)leftSwipe:(UISwipeGestureRecognizer *)swipe
{
    [UIView animateWithDuration:0.3 animations:^{
        //CGAffineTransform transform0 = CGAffineTransformMakeScale(1.0, 1.0); //缩放变换
        CGAffineTransform transform0 = CGAffineTransformIdentity;
        CGAffineTransform transform1 = CGAffineTransformMakeTranslation(-10, -5); //位移变换
        self.rightVC.view.transform = CGAffineTransformConcat(transform1, transform0);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.rightVC.view.transform = CGAffineTransformIdentity;  //单位矩阵变换，一般用于仿射变换的初始化或者还原。
            self.leftVC.view.transform = CGAffineTransformIdentity;
        }];
        
    }];
    
}






@end
