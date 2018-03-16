//
//  NXAPhoneModelClass.h
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/5/22.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 这是获取手机相关信息的类
 */
@interface NXAPhoneInfoClass : NSObject


/**
 获取手机型号
 */
+ (NSString *)getPhoneModel;

/**
 获取电池电量
 */
+ (CGFloat)battertLevel;

/**
 获取总内存大小
 */
+ (long)totalMemorySize;


/**
 获取手机屏幕分辨率
 */
+ (NSString *)resolution;


/**
 获取当前设备的ip地址
 */
+ (NSString *)ipAddress;



/**
 当前手机连接的WIFI名称(SSID)
 */
+ (NSString *)wifiName;












@end
