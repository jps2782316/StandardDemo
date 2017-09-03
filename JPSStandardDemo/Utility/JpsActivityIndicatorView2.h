//
//  JpsActivityIndicatorView2.h
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/7/8.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JpsActivityIndicatorView2 : UIView


/**
 显示菊花，转圈时父视图上的东西能点击，默认显示在window上
 @param title 加载状态的描述
 */
+ (void)showWithTitile:(NSString *)title;


/**
 显示菊花，菊花显示在父视图上，转圈时父视图无法响应事件
 */
+ (void)showInSuperView:(UIView *)superView title:(NSString *)title;



/**
 移除菊花
 */
+ (void)dismiss;



@end
