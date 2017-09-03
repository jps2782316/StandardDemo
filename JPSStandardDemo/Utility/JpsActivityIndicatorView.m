//
//  JpsActivityIndicatorView.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/31.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsActivityIndicatorView.h"


#define W [UIScreen mainScreen].bounds.size.width
#define H [UIScreen mainScreen].bounds.size.height

@interface JpsActivityIndicatorView ()

@property(nonatomic,strong)UIWindow *window;

@property(nonatomic,strong)NSMutableArray *images;
@property(nonatomic,strong)UIImageView *imageV;


@end


@implementation JpsActivityIndicatorView



+ (instancetype)shareIndicator
{
    static JpsActivityIndicatorView *vi = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vi = [[JpsActivityIndicatorView alloc]init];
    });
    return vi;
}


#pragma mark - ------------- 默认加载在window上 -------------
+ (void)startAnimation
{
    //JpsActivityIndicatorView *view = [[self alloc]init];
    JpsActivityIndicatorView *view = [self shareIndicator];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    view.bounds = CGRectMake(0, 0, 50, 50);
    view.center = window.center;
    [window addSubview:view];
    
    [[view imageV] startAnimating];
}

+ (void)stopAnimation
{
    JpsActivityIndicatorView *view = [[self alloc]init];
    
    [[view imageV] stopAnimating];
    [view removeFromSuperview];
}




//方式二

#pragma mark - ------------- 返回实例，自己addSubView -------------

- (instancetype)startActivityOnSuperView:(UIView *)superView
{
    JpsActivityIndicatorView *v = [[JpsActivityIndicatorView alloc]init];
    v.bounds = CGRectMake(0, 0, 50, 50);
    v.center = superView.center;
    [[v imageV] startAnimating];
    return v;
}

- (void)stopAnimation
{
    [self.imageV stopAnimating];
    [self removeFromSuperview];
}




#pragma mark - ------------- lazy -------------

- (UIImageView *)imageV
{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageV.animationImages = self.images;
        [self addSubview:_imageV];
    }
    return _imageV;
}


- (NSMutableArray *)images
{
    if (!_images) {
        _images = [[NSMutableArray alloc]init];
        for (int i = 0; i <= 59; i++) {
            NSString *imageName = [NSString stringWithFormat:@"XQLoading%05d_80x80_",i];
            [_images addObject:[UIImage imageNamed:imageName]];
        }
    }
     return _images;
}


- (UIWindow *)window
{
    if (_window == nil) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}




@end
