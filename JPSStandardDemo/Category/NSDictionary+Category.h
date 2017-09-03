//
//  NSDictionary+Category.h
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Category)

// 字典转json字符串
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

//json字符串转字典
+ (NSDictionary *)jsonToDictionary:(NSString *)jsonStr;

//json转字典或数组（2）
- (NSDictionary *)dictioanryWithJsonString:(NSString *)jsonString;


@end
