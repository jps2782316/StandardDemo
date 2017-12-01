//
//  JpsDeprecatedClass.h
//  JPSStandardDemo
//
//  Created by jps on 2017/11/23.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 这个宏中有两个版本号。前面一个表明了这个方法被引入时的iOS版本，后面一个表明它被废弃时的iOS版本。
 */

//测试弃用方法提示语
NS_CLASS_DEPRECATED_IOS(2_0, 9_0, "UIAlertView is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleAlert instead") __TVOS_PROHIBITED

@interface JpsDeprecatedClass : NSObject

@property(nonatomic,strong)UIColor *color NS_DEPRECATED_IOS(8_0, 9_2);

- (void)deprecated_function NS_DEPRECATED_IOS(7_0, 10_0, "这个方法已弃用，使用新方法代替");  //注意不要打@符号


@end
