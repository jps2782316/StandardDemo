//
//  AdvertisementView2.m
//  AdvertisementView
//
//  Created by 金平生 on 2017/6/24.
//  Copyright © 2017年 金平生. All rights reserved.
//

#import "AdvertisementView2.h"

#define COUNT 3    //广告栏有几张图片

@interface AdvertisementView2 ()

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIPageControl *pageControl;

@property(nonatomic,assign)NSInteger currentIndex;

@property(nonatomic,strong)NSArray *images;  //!<广告轮播的图片数据

@end



@implementation AdvertisementView2

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images
{
    self = [super initWithFrame:frame];
    if (self) {
        self.images = images;
        
        [self initComponents];
        [self pageControl];
    }
    return self;
}




#pragma mark - 初始化控件、手势

- (void)initComponents
{
    _currentIndex = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.frame.size.height)];
    _imageView.image = [UIImage imageNamed:self.images[0]];
    _imageView.userInteractionEnabled = YES;
    //1. 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_imageView addGestureRecognizer:tap];
    //2. 滑动手势
    UISwipeGestureRecognizer *swipe_Right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandle:)];
    swipe_Right.direction = UISwipeGestureRecognizerDirectionRight;
    [_imageView addGestureRecognizer:swipe_Right];
    
    UISwipeGestureRecognizer *swipe_Left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandle:)];
    swipe_Left.direction = UISwipeGestureRecognizerDirectionLeft;
    [_imageView addGestureRecognizer:swipe_Left];
    
    [self addSubview:_imageView];
    
}


//1     fade = 1,                   //淡入淡出
//2     push,                       //推挤
//3     reveal,                     //揭开
//4     moveIn,                     //覆盖
//5     cube,                       //立方体
//6     suckEffect,                 //吮吸
//7     oglFlip,                    //翻转
//8     rippleEffect,               //波纹
//9     pageCurl,                   //翻页
//10     pageUnCurl,                 //反翻页
//11     cameraIrisHollowOpen,       //开镜头
//12     cameraIrisHollowClose,      //关镜头


#pragma mark - 定时器方法
//揭开、覆盖都可用作广告栏的封装
- (void)timer:(NSTimer *)timer
{
    _currentIndex++;
    if (_currentIndex >= COUNT) {
        _currentIndex = 0;
    }
    
    [self showImageWithSubtype:kCATransitionFromRight];
    
}

- (void)showImageWithSubtype:(NSString *)subtype
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    //动画方向
    animation.subtype = subtype;
    animation.type = @"reveal";
    [_imageView.layer addAnimation:animation forKey:nil];
    
    //NSString *pictureName = [NSString stringWithFormat:@"%ld.jpg",_currentIndex];
    _imageView.image = [UIImage imageNamed:self.images[_currentIndex]];
    _pageControl.currentPage = _currentIndex;
}


#pragma mark - 手势处理

- (void)tap:(UITapGestureRecognizer *)tap
{
    NSLog(@"点击了第%ld张图片",_currentIndex);
}


- (void)swipeHandle:(UISwipeGestureRecognizer *)swipe
{
    [_timer invalidate];
    _timer = nil;
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        _currentIndex++;
        if (_currentIndex >= COUNT) {
            _currentIndex = 0;
        }
        [self showImageWithSubtype:kCATransitionFromRight];
        
        //重新开启定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        _currentIndex--;
        if (_currentIndex < 0) {
            _currentIndex = COUNT - 1;
        }
        [self showImageWithSubtype:kCATransitionFromLeft];
        
        //重新开启定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    }
}


#pragma mark - lazy

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height-40, self.bounds.size.width, 30)];
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:156/255.0 alpha:1];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.numberOfPages = 3;
        
        [self addSubview:_pageControl];
    }
    return _pageControl;
}


@end
