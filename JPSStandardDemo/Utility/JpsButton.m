//
//  JpsButton.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/31.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsButton.h"


@interface JpsButton ()
{
    JPSButtonType _type;
}


@end


@implementation JpsButton


- (instancetype)initWithFrame:(CGRect)frame type:(JPSButtonType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
}




//MARK: - 设置buton的文字位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
    
    if (_type == JPSButtonTypeRight) {
        //1. 图右
        x = contentRect.origin.x;
        y = contentRect.origin.y;
        width = contentRect.size.width-30;
        height = contentRect.size.height;
    }
    else if (_type == JPSButtonTypeTop)
    {
        //2. 图上
        x = contentRect.origin.x;
        y = contentRect.size.height-30;
        width = contentRect.size.width;
        height = 30;
    }
    else {
        //3. 图下
        x = contentRect.origin.x;
        y = contentRect.origin.y;
        width = contentRect.size.width;
        height = 30;
    }
    
    
    return CGRectMake(x, y, width, height);
}

//MARK: - 设置button的图片位置
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
    
    if (_type == JPSButtonTypeRight) {
        //1. 图右
        width = 17;
        height = 10;
        x = contentRect.size.width - 20;
        y = contentRect.size.height/2.0 - height/2.0;
    }
    else if (_type == JPSButtonTypeTop)
    {
        //2. 图上
        x = contentRect.origin.x;
        y = contentRect.origin.y;
        width = contentRect.size.width;
        height = contentRect.size.height-30;
    }
    else {
        //3. 图下
        x = contentRect.origin.x;
        y = 30;
        width = contentRect.size.width;
        height = contentRect.size.height-30;
    }
    
    return CGRectMake(x, y, width, height);
}




@end
