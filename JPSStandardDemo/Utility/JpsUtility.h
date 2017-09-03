//
//  JpsUtility.h
//  JPSStandardDemo
//
//  Created by jps on 2017/4/6.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JpsUtility : NSObject


/**
 黑色label提示
 @param message 提示内容
 */
+ (void)showMessage:(NSString *)message;


/**
 计算文字所占label的高度
 @param label 承载文字的label
 @return 文字所需要label能达到的高度
 */
+ (CGFloat)heightForLabelWithLabel:(UILabel *)label;

/**
 获得特殊属性字体
 */
+ (NSAttributedString *)attributedStringFromString:(NSString *)string;




/**
 改变图片大小
 @param image 图片
 @param reSize 需要的大小
 @return 尺寸重构后的图片
 */
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;


/**
 获取当前时间
 @param formatStr 格式化字符串（@"yyyy-MM-dd HH:mm:ss"）
 @return 日期
 */
+ (NSString *)getCurrentTimeWithFormatString:(NSString *)formatStr;


/**
 两个时间的时间差
 @param startTime 开始时间
 @param endTime 结束时间
 @return 两个时间差
 */
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;


/**
 获取某一个具体日期的前一天、一年
 @return 得到的日期
 */
+ (NSString *)dateStrWithYear:(NSInteger)year month:(NSInteger)month week:(NSInteger)week day:(NSInteger)day date:(NSDate *)date;


/**
 时间转字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date dateFromat:(NSString *)format;


/**
 字符串转时间
 */
+ (NSDate *)dateFromString:(NSString *)dateString dateFormat:(NSString *)format;



/**
 正则判断手机号码地址格式
 @param mobileNum 手机号码
 @return 是否为手机号（YES：是合法手机号）
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;


/**
 判断身份证号是否正确（不包含15位数身份证）
 @param identityCard 身份证
 @return 是否为合法身份证号（YES：是合法身份证号）
 */
+ (BOOL)isIdcardNumber:(NSString *)identityCard;


/**
 颜色转换为背景图片
 @param color 颜色
 @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


/**
 颜色转换
 @param color 颜色字符串（@"#141414"）
 @return 得到的颜色
 */
+ (UIColor *) colorWithHexString: (NSString *)color;








/**
 base64字符串转为图片
 */
+ (UIImage *)imageFromBase64Str:(NSString *)base64Str;




/**
 图片转为base64字符串
 */
+ (NSString *)base64StringFromImage:(UIImage *)image;



















//设置文字行间距
+ (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space;

//改变字间距
+ (void)changeWordSpaceForLabel:(UILabel *)label WithSpace:(float)space;

//改变行间距和字间距
+ (void)changeSpaceForLabel:(UILabel *)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;


@end
