//
//  JpsActivityIndicatorView2.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/7/8.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsActivityIndicatorView2.h"

@interface JpsActivityIndicatorView2 ()

@property(nonatomic,weak)UIActivityIndicatorView *act;  //!<菊花
@property(nonatomic,weak)UILabel *stateLabel;

@end



@implementation JpsActivityIndicatorView2


//- (instancetype)initWithTitle:(NSString *)title
//{
//    self = [super init];
//    if (self) {
//        [self act];
//        [self stateLabel];
//        self.stateLabel.text = title;
//    }
//    return self;
//}

+ (instancetype)share
{
    static JpsActivityIndicatorView2 *vi = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vi = [[self alloc]init];
    });
    return vi;
}


//菊花一
+ (void)showWithTitile:(NSString *)title
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    //JpsActivityIndicatorView2 *baseView = [[self alloc]init];
    JpsActivityIndicatorView2 *baseView = [self share];
    baseView.bounds = CGRectMake(0, 0, 50, 80);
    baseView.center = window.center;
    [window addSubview:baseView];
    
    [baseView act];
    //baseView.act.bounds = CGRectMake(0, 0, 500, 500); //这里随意给大小，虽然不会影响act的显示大小，但是CGRectGetMaxY(baseView.act.frame)会受到影响（变成250）
    
    //坐标系不同不能这样给坐标
   // baseView.act.center = CGPointMake(baseView.center.x, baseView.center.y-30);
    
    CGPoint center = CGPointMake(baseView.bounds.size.width/2, baseView.bounds.size.height/2-15);
    baseView.act.center = center;
    [baseView.act startAnimating];
    
    [baseView stateLabel];
    baseView.stateLabel.frame = CGRectMake(0, CGRectGetMaxY(baseView.act.frame), baseView.bounds.size.width, 30);
    baseView.stateLabel.text = title;
}


//菊花二
+ (void)showInSuperView:(UIView *)superView title:(NSString *)title
{
    JpsActivityIndicatorView2 *baseView = [self share];
    baseView.frame = superView.frame;
    baseView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    superView.userInteractionEnabled = NO;
    [superView addSubview:baseView];
    
    [baseView act];
    //改大小也没用
    //act.frame = CGRectMake(100, 200, 80, 80);
    CGPoint center = CGPointMake(baseView.center.x, baseView.center.y-30);
    baseView.act.center = center;
    [baseView.act startAnimating];
    
    [baseView stateLabel];
    baseView.stateLabel.text = title;
    baseView.stateLabel.frame = CGRectMake(0, CGRectGetMaxY(baseView.act.frame), baseView.bounds.size.width, 30);
    
}

//移除
+ (void)dismiss
{
    JpsActivityIndicatorView2 *baseV = [self share];
    [baseV.act stopAnimating];
    baseV.superview.userInteractionEnabled = YES;
    
    [baseV removeFromSuperview];
}




#pragma mark - ---------- lazy -----------

//样式；
//    UIActivityIndicatorViewStyleWhiteLarge, 大白色
//    UIActivityIndicatorViewStyleWhite,  小白色
//    UIActivityIndicatorViewStyleGray, 灰色
- (UIActivityIndicatorView *)act
{
    if (!_act) {
        //默认隐藏的；
        UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        //改大小也没用
//        //act.frame = CGRectMake(100, 200, 80, 80);
//        CGPoint center = CGPointMake(self.center.x, self.center.y-30);
//        act.center = center;
        //开启动画的时候才会显示
        [act startAnimating];
        //设置转圈的颜色；
        act.color = [UIColor redColor];
        //停止动画；
        //[act stopAnimating];
        //停止动画不隐藏；
        act.hidesWhenStopped = NO;
        
        //设置状态栏网络提示
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //获取转动状态；
        //act.isAnimating
        
        [self addSubview:act];
        
        _act = act;
    }
    return _act;
}




- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:label];
        _stateLabel = label;
    }
    return _stateLabel;
}


@end
