//
//  JpsPlaceholderView.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/7/8.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsPlaceholderView.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height


@interface JpsPlaceholderView ()

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UILabel *label;


@end



@implementation JpsPlaceholderView






//- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image tips:(NSString *)tips
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image tips:(NSString *)tips
{
    CGFloat W = Width*0.6;
    CGFloat H = W+50;
    frame = CGRectMake(Width/2.0-W/2.0, Height/2.0-H/2.0, W, H);  //直接按屏幕比固定好尺寸
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initComponentsWithFrame:frame image:image tips:tips];
    }
    return self;
}









#pragma mark - ---------- 初始化控件 -----------

- (void)initComponentsWithFrame:(CGRect)frame image:(UIImage *)image tips:(NSString *)tips
{
    self.imageView = [[UIImageView alloc]init];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-50);
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    self.label = [UILabel new];
    self.label.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+10, frame.size.width, 30);
    self.label.text = tips;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor lightGrayColor];
    self.label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.label];
}




@end
