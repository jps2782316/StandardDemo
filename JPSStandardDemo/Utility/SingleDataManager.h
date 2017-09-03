//
//  SingleDataManager.h
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 单例：单个实例，在当前的应用程序的生命周期内，该对象只有实例。
 
 单例优点：解耦合,传值。注意：单例的生命周期和应用程序的生命周期是一样.
 单例缺点：单例对象占用一定的内存。
 */


@interface SingleDataManager : NSObject



+ (instancetype)shareManager;


@end
