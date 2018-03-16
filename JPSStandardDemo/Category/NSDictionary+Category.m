//
//  NSDictionary+Category.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)



// 字典转json字符串
+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}



//json字符串转字典
+ (NSDictionary *)jsonToDictionary:(NSString *)jsonStr
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    return dic;
}

- (NSDictionary *)dictioanryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        DLog(@"解析失败");
        return nil;
    }
    return dic;
}


////json字符串转字典或数组
//- (NSDictionary *) getDicString:(NSString *)string{
//    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
//    NSDictionary *dict = [jsonParser objectWithString:string];
//    return dict;
//}

#pragma mark - ------------- print -------------

//- (NSString *)descriptionWithLocale:(id)locale  //这个不知道什么时候调用
//{
//    return @"descriptionWithLocale";
//}
//
//- (NSString *)description{             //NSLog的时候调用
//    return @"description";
//}
//
//- (NSString *)debugDescription         //控制台po的时候调用
//{
//    return @"debugDescription";
//}

//1. NSLog的时候调用
- (NSString *)description{
    NSMutableString *string = [NSMutableString string];
    // 开头有个{
    [string appendString:@"{\n"];
    
    // 遍历所有的键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"\t%@", key];
        [string appendString:@" : "];
        [string appendFormat:@"%@,\n", obj];
    }];
    
    // 结尾有个}
    [string appendString:@"}"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}

//2. 控制台po的时候调用
- (NSString *)debugDescription
{
    NSMutableString *string = [NSMutableString string];
    // 开头有个{
    [string appendString:@"{\n"];
    
    // 遍历所有的键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"\t%@", key];
        [string appendString:@" : "];
        [string appendFormat:@"%@,\n", obj];
    }];
    
    // 结尾有个}
    [string appendString:@"}"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}


//另外一种打印字典汉字的方法
//http://www.jianshu.com/p/040293327e18


//
////在iOS中打印字典或者数组对象，系统会默认调用字典对象和数组对象的descriptionWithLocale:方法。所以解决方案就是增加在.m文件中重写了两个descriptionWithLocale:方法。以后用的时候直接将文件拖进项目。
////IOS中打印时，中文一般会被默认转换为Unicode字符的形式。
////针对字典和数组，可通过增加分类，并在分类中重写 descriptionWithLocale: 方法的形式，实现打印结果中直接显示中文。
//
//- (NSString *)descriptionWithLocale:(id)locale
//{
//    NSMutableString *string = [NSMutableString string];
//    // 开头有个{
//    [string appendString:@"{\n"];
//
//    // 遍历所有的键值对
//    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [string appendFormat:@"\t%@", key];
//        [string appendString:@" : "];
//        [string appendFormat:@"%@,\n", obj];
//    }];
//
//    // 结尾有个}
//    [string appendString:@"}"];
//
//    // 查找最后一个逗号
//    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
//    if (range.location != NSNotFound)
//        [string deleteCharactersInRange:range];
//
//    return string;
//}


@end
