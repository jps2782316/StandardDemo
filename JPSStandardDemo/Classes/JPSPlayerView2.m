//
//  JPSPlayerView2.m
//  JPSStandardDemo
//
//  Created by jps on 2017/12/6.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JPSPlayerView2.h"
#import <AVFoundation/AVFoundation.h>

@interface JPSPlayerView2 ()

@property(nonatomic,strong)AVPlayer *player;  //!<播放器

@property(nonatomic,strong)AVPlayerLayer *playerLayer;  //!<播放界面

@property(nonatomic,strong)AVPlayerItem *playerItem;  //!<播放单元，播放项目

@property(nonatomic,strong)NSString *vedioUrl;       //!<视频地址




@end


@implementation JPSPlayerView2

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //本地视频
        //NSString *str1 = [[NSBundle mainBundle] pathForResource:@"haha" ofType:@"mp4"];
        //mp4
        NSString *str2 = @"http://baobab.cdn.wandoujia.com/14468618701471.mp4";
        NSString *str3 = @"http://nesec.oss-cn-shenzhen.aliyuncs.com/nxa_app_jxjy/aqjy_25.mp4";
        
        //[NSURL fileURLWithPath:str1];//本地路径
        //[NSURL URLWithString:str2];
        
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        //初始化播放器
        [self initPlayerWithURL:str2];
    }
    return self;
}


- (void)initPlayerWithURL:(NSString *)url
{
    /*
     视频播放需要AVPlayer、AVPlayerItem、AVPlayerLayer
     三者的关系及作用：
     AVPlayer（视频播放器） 去播放 -> AVPlayerItem（视频播放的元素） -> AVPlayerLayer（展示播放的视图）
     */
    
    
    //添加防盗链 ======================
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://nxa-jiayitong.oss-cn-shenzhen.aliyuncs.com*" forKey:@"Referer"];
    AVAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:@{@"AVURLAssetHTTPHeaderFieldsKey":headers}];
    
    
    //远程
    //self.playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:URL]];
    self.playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    //1. 构建播放器
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    //2. 构建播放显示层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //3. iOS视频播放AVPlayer的视频内容拉伸设置
    //AVLayerVideoGravityResizeAspect   按原视频比例显示，两边留黑
    //AVLayerVideoGravityResizeAspectFill   以原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分就被切割了
    //AVLayerVideoGravityResize   是拉伸视频内容达到边框占满，但不按原比例拉伸，这里明显可以看出宽度被拉伸了
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    self.layer.backgroundColor = [UIColor yellowColor].CGColor;
    
    //4. 视频显示出加到view的layer层上
    [self.layer addSublayer:self.playerLayer];
    //放到最下面，防止遮挡
    //    [self.layer insertSublayer:_playerLayer atIndex:0];
    //    [self setNeedsLayout];
    //    [self layoutIfNeeded];
    
    //获得播放结束的状态 -> 通过发送通知的形式获得 ->AVPlayerItemDidPlayToEndTimeNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //通过KVO来观察status属性的变化，来获得播放之前的错误信息
    //只要可以获得到当前视频元素准备好的状态 就可以得到总时长 (如果url为nil，是不会周观察者方法的)
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player play];
}

#pragma mark - ------------- LifeCircle -------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    
}

#pragma mark - ------------- KVO -------------

//当status的值改变的时候会调用这个方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        
        switch (status) {
            case AVPlayerItemStatusUnknown: {
                NSLog(@"未知状态");
                break;
            }
            case AVPlayerItemStatusReadyToPlay: {
                NSLog(@"可以播放");
                NSLog(@"视频的总时长%f", CMTimeGetSeconds(self.player.currentItem.duration));
                //播放
                [self.player play];
                break;
            }
            case AVPlayerItemStatusFailed: {
                NSLog(@"加载失败");
                break;
            }
        }
    }
}


#pragma mark - ------------- noti -------------

//播放结束
-(void)itemDidPlayToEndTime:(NSNotification *)not{
    NSLog(@"播放结束");
    [self.player seekToTime:kCMTimeZero];
    
}





@end
