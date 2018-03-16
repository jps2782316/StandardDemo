//
//  NetworkingManager.h
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  请求成功回调json数据
 *
 *  @param json json串
 */
typedef void(^Success)(id json);

/**
 *  请求失败回调错误信息
 *
 *  @param error error错误信息
 */
typedef void(^Failure)(NSError *error);



@interface NetworkingManager : NSObject



+(NetworkingManager *) shareManager;




/**
 获取网络类型
 */
+ (NSString *)networkingStatus;


- (void)getDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure;


- (void)postDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure;






@end
