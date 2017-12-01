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

@property(nonatomic,strong)UIView *maskView;  //!<右边控制器上面的遮罩

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
        
        
        //遮罩
        [self.rightVC.view addSubview:self.maskView];
        [self.rightVC.view bringSubviewToFront:self.maskView];
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showLeft)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.rightVC.view addGestureRecognizer:rightSwipe];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showRight)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.rightVC.view addGestureRecognizer:leftSwipe];
    
}


#pragma mark - ------------- Transform -------------

- (void)showLeft
{
    //    if (self.rightVC.view.frame.origin.x > 0) {
    //        return;
    //    }
    self.leftIsShow = YES;
    self.maskView.hidden = NO;
    
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


- (void)showRight
{
    self.leftIsShow = NO;
    self.maskView.hidden = YES;
    
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


#pragma mark - ------------- GestrueRecognizer -------------

- (void)showRightVC:(UITapGestureRecognizer *)tap
{
    if (self.leftIsShow) {
        [self showRight];
    }
}


#pragma mark - ------------- lazy -------------

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.hidden = YES;
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showRightVC:)];
        [self.view addGestureRecognizer:tap];
        [_maskView addGestureRecognizer:tap];
        
    }
    return _maskView;
}



@end
