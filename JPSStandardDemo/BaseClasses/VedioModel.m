//
//  VedioModel.m
//  VedioDownLoader
//
//  Created by jps on 2017/3/14.
//  Copyright © 2017年 JPS. All rights reserved.
//

#import "VedioModel.h"
#import <objc/runtime.h>

@implementation VedioModel

#pragma mark - ------------- 模型初始化 -------------

//1. 字典转模型
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    VedioModel *model = [[self alloc]init];
    [model setValuesForKeysWithDictionary:dictionary];
    
    return model;
}

//2. 模型转字典 runtime
- (NSDictionary *)dictionaryWithModel:(VedioModel *)model
{
    NSDictionary *dictionary = [model dictionaryWithValuesForKeys:[self properties]];
    return dictionary;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"视频名:%@ 下载进度：%f 下载状态：%ld url:%@", self.unitDesc, self.progress, (long)self.vedioState, self.flashUrl];
}

//初始化属性
- (instancetype)init
{
    if (self = [super init]) {
        self.progress = 0.0;
        self.vedioState = VedioStateUnDownLoad;
    }
    return self;
}


#pragma mark - ------------- 解档、归档 -------------

//归档的时候调用  runtime
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    /*
     [aCoder encodeObject:self.name forKey:@"name"];
     [aCoder encodeObject:@(self.age) forKey:@"age"];
     [aCoder encodeObject:self.address forKey:@"address"];
     */
    
    NSArray *properties = [self properties];
    
    for (NSString *propertyName in properties) {
        //归档
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
}

//解归档会触发 runtime
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        /*
         self.name = [aDecoder decodeObjectForKey:@"name"];
         self.age = [[aDecoder decodeObjectForKey:@"age"] intValue];
         self.address = [aDecoder decodeObjectForKey:@"address"];
         */
        
        NSArray *properties = [self properties];
        
        for (NSString *propertyName in properties) {
            //解归档
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
    }
    return self;
}

//获取属性列表
- (NSArray *)properties
{
    NSMutableArray *propertyArr = [[NSMutableArray alloc]init];
    //属性个数
    unsigned int outCount;
    //动态获取属性列表
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        //属性
        objc_property_t property = properties[i];
        //属性名
        const char *name = property_getName(property);
        
        [propertyArr addObject:[NSString stringWithUTF8String:name]];
    }
    
    return propertyArr;
}






#pragma mark - ------------- KVC 赋值异常处理 -------------
//key value coding

//如果Key不存在，且没有KVC无法搜索到任何和Key有关的字段或者属性，则会调用这个方法，默认是抛出异常
- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

//和上一个方法一样，只不过是设值
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
//    //找到和属性不一致名字的key，然后赋值给self的属性
//    if ([key isEqualToString:@"description"]) {
//        
//        // self.descriptionStr = value; // 不推荐使用
//        [self setValue:value forKey:@"descriptionStr"]; // 推荐
//    }
}



//输入一组key,返回该组key对应的Value，再转成字典返回，用于将Model转到字典。
//- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;





















@end
