//
//  JpsBrightnessView.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/3.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsBrightnessView.h"

@interface JpsBrightnessView()

@property (nonatomic, strong) UIImageView        *backImageView;  //!<小太阳图片
@property (nonatomic, strong) UILabel            *titleLabel;  //!<亮度标题
@property (nonatomic, strong) UIView            *longView;   //!<亮度进度条的baseView
@property (nonatomic, strong) NSMutableArray    *tipArray;   //!<每一个亮度小方块

@end

@implementation JpsBrightnessView

+ (instancetype)shareBrightnessView
{
    static JpsBrightnessView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JpsBrightnessView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake((Width-155) * 0.5, (Height-155) * 0.5, 155, 155);
        
        self.layer.cornerRadius  = 10;
        self.layer.masksToBounds = YES;
        
        // 使用UIToolbar实现毛玻璃效果，简单粗暴，支持iOS7+
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.alpha = 0.97;
        [self addSubview:toolbar];
        
        self.backImageView = [[UIImageView alloc] initWithFrame:CGRectMake((155-79)/2.0, (155-76)/2.0, 79, 76)];
        self.backImageView.image        = [UIImage imageNamed:@"ZFPlayer_brightness.png"];
        [self addSubview:self.backImageView];
        
        self.titleLabel      = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        self.titleLabel.font          = [UIFont boldSystemFontOfSize:16];
        self.titleLabel.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text          = @"亮度";
        [self addSubview:self.titleLabel];
        
        self.longView         = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        self.longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        [self addSubview:self.longView];
        
        [self createTips];  //亮度进度条
        
        [self addObserver]; //监听亮度
        
        self.alpha = 0;
    }
    return self;
}




// 创建亮度进度条
- (void)createTips {
    
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat tipW = (self.longView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateLongView:[UIScreen mainScreen].brightness];
}

//更新进度条
- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
    
    [self.superview bringSubviewToFront:self]; //带到最上层，不然横屏有可能显示不了
}

//监听亮度变化
- (void)addObserver
{
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}

//kvo代理方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    CGFloat brightness = [change[@"new"] floatValue];
    
    self.alpha = 1.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.alpha == 1.0) {
            [UIView animateWithDuration:0.8 animations:^{
                self.alpha = 0.0;
            }];
        }
    });
    
    [self updateLongView:brightness];
}


@end
