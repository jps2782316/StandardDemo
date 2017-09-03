//
//  VedioModel.h
//  VedioDownLoader
//
//  Created by jps on 2017/3/14.
//  Copyright © 2017年 JPS. All rights reserved.
//

#import <Foundation/Foundation.h>
//导入UIKit，不然不识别CGFloat 在已用工程中不需要导入，是因为pch文件里面已经导入了某个包含UIKit框架的类
#import <UIKit/UIKit.h>


//自定义枚举
typedef NS_ENUM(NSInteger, VedioState)
{
    VedioStateUnDownLoad = 0,
    VedioStateDownLoading = 1,
    VedioStatePause = 2,
    VedioStateCompleted = 3
};



@interface VedioModel : NSObject<NSCoding>

@property(nonatomic,assign)CGFloat progress;  //!<下载进度
@property(nonatomic,assign)VedioState vedioState;  //!<下载状态   枚举类型

@property(nonatomic,copy)NSString *unitDesc;  //!<视频的标题
@property(nonatomic,copy)NSString *flashName;  //!<视频的名字   sy_wyc_6.4.mp4
@property(nonatomic,copy)NSString *flashUrl;  //!<视频的url地址
@property(nonatomic,copy)NSString *flashFileLength;  //!<视频长度


//1. 模型初始化方法  字典转模型
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

//2. 模型转字典
- (NSDictionary *)dictionaryWithModel:(VedioModel *)model;


@end
