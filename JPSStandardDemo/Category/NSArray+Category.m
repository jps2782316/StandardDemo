//
//  NSArray+Category.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/6/24.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "NSArray+Category.h"

@implementation NSArray (Category)












//在iOS中打印字典或者数组对象，系统会默认调用字典对象和数组对象的descriptionWithLocale:方法。所以解决方案就是增加在.m文件中重写了两个descriptionWithLocale:方法。以后用的时候直接将文件拖进项目。

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *string = [NSMutableString string];
    // 开头有个[
    [string appendString:@"[\n"];
    // 遍历所有的元素
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [string appendFormat:@"\t%@,\n", obj];
    }];
    // 结尾有个]
    [string appendString:@"]"];
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}




@end
