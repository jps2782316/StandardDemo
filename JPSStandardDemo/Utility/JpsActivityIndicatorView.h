//
//  JpsActivityIndicatorView.h
//  JPSStandardDemo
//
//  Created by jps on 2017/3/31.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JpsActivityIndicatorView : UIView

+ (void)startAnimation;
+ (void)stopAnimation;


- (instancetype)startActivityOnSuperView:(UIView *)superView;
- (void)stopAnimation;

@end
