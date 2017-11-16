//
//  JpsWelcomeView.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/2.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsWelcomeView.h"
#import "JpsLoginViewController.h"
#import "JpsViewController.h"

@interface JpsWelcomeView ()

@property(nonatomic,strong)UIImageView *foreImageView;
@property(nonatomic,strong)UIImageView *backgroundImageView;

@end

@implementation JpsWelcomeView


- (instancetype)initWithForeImage:(NSString *)foreImage backgroundImage:(NSString *)backgroundImage frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.masksToBounds = YES;  //让background图层超出的部分隐藏
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TransformMakeScale:) name:@"TransformMakeScale" object:nil];
        
        CGFloat W = self.bounds.size.width;
        CGFloat H = self.bounds.size.height;
        self.backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-W*0.25, -H*0.25, W*1.5, H*1.5)];
        self.backgroundImageView.image = [UIImage imageNamed:backgroundImage];
        [self addSubview:self.backgroundImageView];
        
        
        self.foreImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.foreImageView.contentMode = UIViewContentModeScaleToFill;
        self.foreImageView.image = [UIImage imageNamed:foreImage];
        [self addSubview:self.foreImageView];
        [self bringSubviewToFront:self.foreImageView];
        
        //最后一张图，加上按钮
        if (frame.origin.x == Width * 2) {
            UIButton *intoButton = [[UIButton alloc]initWithFrame:CGRectMake((W-300)/2.0, Height-200, 300, 40)];
            intoButton.layer.cornerRadius = 20;
            intoButton.layer.borderWidth = 1;
            intoButton.layer.borderColor = [UIColor whiteColor].CGColor;
            [intoButton setTitle:@"点击进入" forState:UIControlStateNormal];
            [intoButton addTarget:self action:@selector(enterIntoClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.foreImageView addSubview:intoButton];
            self.foreImageView.userInteractionEnabled = YES;
        }
        
        //第一次进入，第一张图
        if (frame.origin.x == 0) {
            [UIView animateWithDuration:3.0 animations:^{
                self.backgroundImageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }];
        }
    }
    return self;
}


#pragma mark - ---------- Action -----------

//缩放背景图
- (void)TransformMakeScale:(NSNotification *)noti
{
    NSNumber *x = (NSNumber *)noti.object;
    if ([x integerValue] == self.frame.origin.x) {
        //是当前视图，背景缩小
        [UIView animateWithDuration:3.0 animations:^{
            self.backgroundImageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        }];
        
    }else{
        //背景还原为初始大小
        self.backgroundImageView.transform = CGAffineTransformIdentity;
    }
}


- (void)enterIntoClick:(UIButton *)sender
{
//    //点击进入，把isFirst设为YES，下次进入就不再展示欢迎页
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirst"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //QQ登录界面
    JpsLoginViewController *loginVC = [[JpsLoginViewController alloc]init];
    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
    
//    //bilibili登录界面
//    JpsViewController *loginVC2 = [[JpsViewController alloc]init];
//    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC2;
}




@end
