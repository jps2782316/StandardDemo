//
//  NetworkingManager.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "NetworkingManager.h"
#import "SBJson.h"
#import "AFNetworking.h"

@implementation NetworkingManager

static NetworkingManager *manager = nil;

#pragma mark - ------------- 单例高级写法 -------------

+ (NetworkingManager *)shareManager
{
    //dispatch_once是线程安全的方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetworkingManager alloc]init];
    });
    return manager;
}

//当对一个对象发送alloc消息，就会触发allocWithZone:
//目的防止用户通过alloc创建一个新的对象。
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager)
        {
            manager = [super allocWithZone: zone];
        }
    });
    
    return manager;
}

//copy一个对象的时候会触发
- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

//mutableCopy一个对象的时候会触发
- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return self;
}



//+(AFHTTPSessionManager *)manager
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    // 超时时间
//    manager.requestSerializer.timeoutInterval = kTimeOutInterval;
//    
//    // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
//    //    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 上传JSON格式
//    
//    // 声明获取到的数据格式
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFN不会解析,数据是data，需要自己解析
//    //    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // AFN会JSON解析返回的数据
//    // 个人建议还是自己解析的比较好，有时接口返回的数据不合格会报3840错误，大致是AFN无法解析返回来的数据
//    return manager;
//}

//http://www.jianshu.com/p/ab246881efa9 iOS9之后AFNetWorking的使用(详细)



//NSURLSession与NSURLConnection区别
//http://www.jianshu.com/p/056b1817d25a
//http://www.cnblogs.com/kakaluote123/articles/5426923.html


#pragma mark - ------------- POST请求 -------------

- (void)postDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/plain", @"image/png",nil];
    //这时候 你必须告诉AFNetworking:别把这个网页当json来处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //Code=-1011 "Request failed: bad request (400) 不写报错
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //设置超时
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.0;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    
    [manager POST:url parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // DLog(@"%@",responseObject);
        //不写这个打出来的时data形式的数据
        NSString *resultString = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [self getDicString:resultString];
        success(dic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"%@",error.localizedDescription);
        
    }];
}



#pragma mark - ------------- GET请求 -------------

- (void)getDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/plain", @"image/png",nil];
    //这时候 你必须告诉AFNetworking:别把这个网页当json来处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //Code=-1011 "Request failed: bad request (400) 不写报错
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:url parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //DLog(@"%@",responseObject);
        //将data数据转为字符串 --> 处理字符串将其转成标准json格式
        NSString *resultString = [self handleResponseObject:responseObject];
        NSDictionary *dic = [self getDicString:resultString];
        success(dic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"%@", error);
    }];
}




#pragma mark - ------------- 处理字符串将其转成标准json格式 -------------

-(id)handleResponseObject:(NSData *)data {
    
    //将获取的二进制数据转成字符串
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //去掉字符串里的转义字符
    NSString *str1 = [str stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    //去掉头和尾的引号“”
    NSString *str2 = [str1 substringWithRange:NSMakeRange(1, str1.length-2)];
    //最终str2为json格式的字符串，将其转成需要的字典和数组
    //    id object = [str2 objectFromJSONString];
    return str2;
}


#pragma mark - ------------- 字符串转字典或数组 -------------

- (NSDictionary *) getDicString:(NSString *)string{
    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
    NSDictionary *dict = [jsonParser objectWithString:string];
    return dict;
}










@end
