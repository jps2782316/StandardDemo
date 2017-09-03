//
//  AdvertisementView.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/30.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "AdvertisementView.h"

#define W self.frame.size.width
#define H self.frame.size.height

@interface AdvertisementView ()<UIScrollViewDelegate>


@property(nonatomic,weak)UIScrollView *scrollView;
@property(nonatomic,weak)UIPageControl *pageControl;

@property(nonatomic,weak)NSTimer *timer;   //!<广告轮播定时器
@property(nonatomic,strong)NSArray *advertisementArr;  //!<广告轮播的图片数据
@property(nonatomic,assign)NSInteger currentIndex;  //!<当前滑到第几个

@end


@implementation AdvertisementView



- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.advertisementArr = images;
        
        [self scrollView];
        //分页控制器
        [self pageControl];
        //定时器
        [self timer];
        
    }
    return self;
}



#pragma mark - ------------- Events -------------

//广告定时器处理方法
- (void)handleTimer:(NSTimer *)timer
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x+self.frame.size.width, 0) animated:YES];
    
}



#pragma mark - ------------- UIScrollViewDelegate -------------

//定时器改偏移时会触发此方法     手动拖不会触发此方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    self.currentIndex = self.scrollView.contentOffset.x/W;
    
    if (self.currentIndex == self.advertisementArr.count+1) {
        //最后一张，应该显示第一张 （正向滑动最后一张的时候触发）
        //不带动画，默默改偏移
        self.scrollView.contentOffset = CGPointMake(W, 0);
        self.pageControl.currentPage = 0;
        
    }else if (self.currentIndex == 0){
        //第一张，应该显示后一张（反向滑动第一张的时候触发）
        self.scrollView.contentOffset = CGPointMake((self.advertisementArr.count)*W, 0);
        self.pageControl.currentPage = self.advertisementArr.count-1;
        
    }else{
        
        self.pageControl.currentPage = self.currentIndex-1;
    }
    
}

//手动拖动会触发此方法    定时器改的偏移不会触发此方法，
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = scrollView.contentOffset.x/W;
    
    if (self.currentIndex == self.advertisementArr.count+1) {//currentIndex从0开始，所以数组元素个数要减1
        //滑到最后一张，因该显示第一张图片
        scrollView.contentOffset = CGPointMake(W, 0);
        self.pageControl.currentPage = 0;
        
        
    }else if (self.currentIndex == 0){
        scrollView.contentOffset = CGPointMake((self.advertisementArr.count)*W, 0);
        self.pageControl.currentPage = self.advertisementArr.count-1;
        
    }else{
        self.pageControl.currentPage = self.currentIndex - 1;
    }
    
    
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //拖动结束，开启定时器
    [self timer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //开始拖动，结束定时器
    [_timer invalidate];
    _timer = nil;
}



#pragma mark - ------------- 懒加载 -------------

// 广告栏
- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
        scrollView.delegate = self;
        scrollView.bounces = NO;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(w*(self.advertisementArr.count+2), 0);
        scrollView.contentOffset = CGPointMake(w, 0);
        
        [self addSubview:scrollView];
        
        for (int i = 0; i < self.advertisementArr.count+2; i++) {
            //NSInteger height = scrollView.frame.size.height;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(w*i, 0, w, h)];
            
            if (i == self.advertisementArr.count+1) {
                //放第一张
                imageView.image = [UIImage imageNamed:self.advertisementArr.firstObject];
            }else if (i == 0){
                //放最后一张
                imageView.image = [UIImage imageNamed:self.advertisementArr.lastObject];
            }else{
                //1-3正常顺序图片
                imageView.image = [UIImage imageNamed:self.advertisementArr[i-1]];
            }
            [scrollView addSubview:imageView];
        }
        
        _scrollView = scrollView;
    }
    return _scrollView;
}

//定时器
- (NSTimer *)timer
{
    if (_timer == nil) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        _timer = timer;
    }
    return _timer;
}

//分页控制
- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        NSInteger y = h - 30;
        UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, y, w, 30)];
        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:156/255.0 alpha:1];
        pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
        pageControl.numberOfPages = self.advertisementArr.count;
        [self addSubview:pageControl];
        
        _pageControl = pageControl;
        
    }
    return _pageControl;
}



@end
