//
//  NXAPhoneModelClass.m
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/5/22.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import "NXAPhoneInfoClass.h"
#import <sys/utsname.h>

@implementation NXAPhoneInfoClass



//获取手机型号
+ (NSString*)getPhoneModel
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    //iphone 7 是第9代iphone
    //iphone9,1   1是iphone的类型
    
    return deviceString;
}



//// 状态栏(statusbar)
//
//CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
//
////标题栏
//
//CGRect NavRect = self.navigationController.navigationBar.frame;
//然后将高度相加，便可以动态计算顶部高度。




+ (NSNumber *)getMarker
{
    //  *1000 是精确到毫秒，不乘就是精确到秒
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *str = [NSString stringWithFormat:@"%.0f",interval];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [numberFormatter numberFromString:str];
    return number;
}



+ (CGFloat)getHeight
{
    //CGSize deviceSize = [UIScreen mainScreen].bounds.size;
    
    CGRect  statuBarRec = [[UIApplication sharedApplication] statusBarFrame];
    //iPhone X
    if (statuBarRec.size.height > 20) {
        return 44 + 44 + 34;   //状态栏  导航栏   底部虚拟区
    }
    //其他
    else{
        return 64;
    }
}







@end
