//
//  BaseModel.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel



+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"Id":@"id", @"headUrl":@"Url"}];
}




@end
