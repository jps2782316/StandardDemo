//
//  JpsManagerViewController.h
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/2.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JpsManagerViewController : UIViewController

@property(nonatomic,assign)BOOL leftIsShow;  //!<是否正处于测滑的状态

- (instancetype)initWithLeftVC:(id)leftVC rightVC:(id)rightVC;

- (void)showLeft;

- (void)showRight;

@end
