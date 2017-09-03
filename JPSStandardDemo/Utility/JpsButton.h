//
//  JpsButton.h
//  JPSStandardDemo
//
//  Created by jps on 2017/3/31.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, JPSButtonType){
    JPSButtonTypeRight = 0,  //图左字右
    JPSButtonTypeTop,      //图上字下
    JPSButtonTypeBottom    //图下子上
};


@interface JpsButton : UIButton


- (instancetype)initWithFrame:(CGRect)frame type:(JPSButtonType)type;


@end
