//
//  SingleDataManager.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "SingleDataManager.h"

@implementation SingleDataManager


+ (instancetype)shareManager
{
    static SingleDataManager *dataManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[SingleDataManager alloc]init];
    });
    return dataManager;
}






@end
