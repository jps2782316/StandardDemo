//
//  NXAPhoneModelClass.h
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/5/22.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXAPhoneInfoClass : NSObject


/**
 获取手机型号
 */
+ (NSString *)getPhoneModel;


/**
 获取时间戳
 */
+ (NSNumber *)getMarker;


+ (CGFloat)getHeight;


@end
