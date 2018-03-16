//
//  JpsPlayerView.m
//  JPSStandardDemo
//
//  Created by jps on 2017/5/17.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "JpsPlayerMaskView.h"

//消失时间
#define DisappearTime  10

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height


//方向枚举
typedef NS_ENUM(NSInteger,Direction){
    Letf = 0,
    Right,
};

// 播放器的几种状态
typedef NS_ENUM(NSInteger, JPSPlayerState) {
    JPSPlayerStateFailed,     // 播放失败
    JPSPlayerStateBuffering,  // 缓冲中
    JPSPlayerStatePlaying,    // 播放中
    JPSPlayerStateStopped,    // 停止播放
    JPSPlayerStatePause       // 暂停播放
};


@interface JpsPlayerView ()<JpsPlayerMaskViewProtocol>

@property(nonatomic,strong)AVPlayer *player;  //!<播放器

@property(nonatomic,strong)AVPlayerLayer *playerLayer;  //!<播放界面

@property(nonatomic,strong)AVPlayerItem *playerItem;  //!<播放单元，播放项目

@property(nonatomic,strong)NSURL *url;    //!<视频url

@property(nonatomic,copy)NSString *videoGravity; //!<视频拉伸模式

/** 播发器的几种状态 */
@property (nonatomic,assign) JPSPlayerState state;


/**是否支持横屏，默认No*/
@property (nonatomic,assign) BOOL isLandscape;
/**控件原始Farme*/
@property (nonatomic,assign) CGRect        customFrame;
/**父类控件*/
@property (nonatomic,strong) UIView        *fatherView;
/**全屏标记*/
@property (nonatomic,assign) BOOL   isFullScreen;

@property(nonatomic,strong)UIView *statuBar;    //!<状态栏


//@property(nonatomic,assign)BOOL toolBarIsHidden;   //!<工具栏是否被隐藏


/**遮罩*/
@property (nonatomic,strong) JpsPlayerMaskView *maskView;
/**轻拍定时器 显示隐藏工具栏*/
@property (nonatomic,strong) NSTimer          *timer;
/**slider定时器 实时更新进度条*/
@property (nonatomic,strong) NSTimer          *sliderTimer;
/**工具条隐藏标记*/
@property (nonatomic,assign) BOOL   isDisappear;




//http://www.jianshu.com/p/5566077bb25f   iOS视频播放器之ZFPlayer剖析
//http://www.jianshu.com/p/5396866e3256    iOS流媒体开发之二：滑动手势控制音量、亮度和进度

@end



@implementation JpsPlayerView


#pragma mark - ------------- 懒加载 -------------
//遮罩
- (JpsPlayerMaskView *) maskView
{
    if (_maskView == nil){
        _maskView          = [[JpsPlayerMaskView alloc] init];
        //设置代理
        _maskView.delegate = self;
        //点击屏幕让没消失的工具栏马上消失
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disappearTap:)];
        [_maskView addGestureRecognizer:tap];
        //计时器，循环执行
        _sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(timeStack)
                                                      userInfo:nil
                                                       repeats:YES];
        //定时器，工具条消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                                  target:self
                                                selector:@selector(disappear)
                                                userInfo:nil
                                                 repeats:NO];
        [self addSubview:_maskView];
    }
    return _maskView;
}



#pragma mark - ------------- 初始化 -------------
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置视频默认填充样式
        _videoGravity = AVLayerVideoGravityResizeAspect;
        
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
        
        //取出当前控制器的导航条
        self.statuBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        [self addSubview:self.statuBar];
        [self bringSubviewToFront:self.statuBar];
    }
    return self;
}



#pragma mark - ------------- 转屏的时候自动调整视频显示层的frame和view相匹配 -------------
//视频显示层的frame一定要在这里给，不然其frame是固定的，就算屏幕在怎么转动其尺寸都是固定的
//视频播放器的playerlayer的frame一定要在layoutSubview里面赋值，控制器要放到viewDidLayoutSubviews里面，其他什么都不用处理，横屏的时候播放器自然会跟着旋转，无论左横屏还是右横屏。
- (void)layoutSubviews
{
    [super layoutSubviews];
    //设置视屏呈现层frame，不然只有声音，没有图像
    self.playerLayer.frame        = self.bounds;
    
    self.maskView.frame = self.bounds;
}


#pragma mark - ------------- setter -------------
//远程视频
- (void)setVedioUrl:(NSString *)vedioUrl
{
    _vedioUrl = vedioUrl;
    self.url = [NSURL URLWithString:vedioUrl];
    [self initPlayer];
}
//本地视频
- (void)setLocalVedioUrl:(NSString *)localVedioUrl
{
    _localVedioUrl = localVedioUrl;
    self.url = [NSURL fileURLWithPath:localVedioUrl];
    [self initPlayer];
}
//视频名
- (void)setVedioName:(NSString *)vedioName
{
    _vedioName = vedioName;
    [self.maskView.backButton setTitle:vedioName forState:UIControlStateNormal];
}
//填充模式
-(void)setFillMode:(VideoFillMode)fillMode{
    switch (fillMode){
        case ResizeAspectFill:
            //原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分会被剪切
            _videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case ResizeAspect:
            //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
            _videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case Resize:
            //拉伸视频内容达到边框占满，但不按原比例拉伸
            _videoGravity = AVLayerVideoGravityResize;
            break;
    }
    //重新设置视频填充样式
    self.playerLayer.videoGravity = _videoGravity;
}



#pragma mark - ------------- 初始化播放器 -------------
- (void)initPlayer
{
    /*
     视频播放需要AVPlayer、AVPlayerItem、AVPlayerLayer
     三者的关系及作用：
     AVPlayer（视频播放器） 去播放 -> AVPlayerItem（视频播放的元素） -> AVPlayerLayer（展示播放的视图）
     */
    
    //本地
    //self.playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:self.localVedioUrl]];
    
//    
//    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:self.url];
//    // 初始化playerItem
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    //添加防盗链
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://nxa-jiayitong.oss-cn-shenzhen.aliyuncs.com*" forKey:@"Referer"];
    AVAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.url options:@{@"AVURLAssetHTTPHeaderFieldsKey":headers}];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    
    //远程
    //self.playerItem = [[AVPlayerItem alloc]initWithURL:self.url];
    
    //1. 构建播放器
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    //2. 构建播放显示层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //3. iOS视频播放AVPlayer的视频内容拉伸设置
    self.playerLayer.videoGravity = _videoGravity;
    
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    //4. 视频显示出加到view的layer层上
    //[self.layer addSublayer:self.playerLayer];
    //放到最下面，防止遮挡
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
    //    [self setNeedsLayout];
    //    [self layoutIfNeeded];
    
    //通过KVO来观察status属性的变化，来获得播放之前的错误信息
    //只要可以获得到当前视频元素准备好的状态 就可以得到总时长
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听缓冲进度
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络缓冲状态
    // 缓冲区空了，需要等待数据
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区有足够数据可以播放了
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    
    //获得播放结束的状态 -> 通过发送通知的形式获得 ->AVPlayerItemDidPlayToEndTimeNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    //开始播放
    //[self startPlay];
}



#pragma mark - ------------- 通知响应方法 -------------
//屏幕旋转通知  判断屏幕方向，执行全屏或者恢复大小操作
- (void)orientChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft){
        NSLog(@"左转");
        [self fullScreenWithDirection:Letf];
        
    }
    else if (orientation == UIDeviceOrientationLandscapeRight){
        NSLog(@"右转");
        [self fullScreenWithDirection:Right];
        
    }
    else if (orientation == UIDeviceOrientationPortrait){
        NSLog(@"竖屏");
        if (_isFullScreen == YES){
            [self originalscreen];
        }
    }
}

//播放结束
-(void)itemDidPlayToEndTime:(NSNotification *)not{
    NSLog(@"播放结束");
    [self.player seekToTime:kCMTimeZero];
    
    //滑杆滑倒最前，全屏时先退出全屏
    if (_isFullScreen) {
        [self originalscreen];
    }
    self.maskView.slider.value = 0;
    [self pausePlay];
}



#pragma mark - ------------- 全屏 -------------
//不管是旋转屏幕自动全屏还是点击全屏按钮手动全屏都走这个方法
- (void)fullScreenWithDirection:(Direction)direction
{
    if (_isFullScreen == NO) {
        //记录播放器父类
        _fatherView = self.superview;
        //记录原始大小
        _customFrame = self.frame;
    }
    
    _isFullScreen = YES;
    [self setStatusBarHidden:NO];
    
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (_isLandscape == YES){
        //指出横屏的时候，转的时候方向会自动跟着变，无需手动旋转 M_PI/2，只要给frame就行
        self.frame = CGRectMake(0, 0, Width, Height);
    }else{
        //界面上没有工具栏的时候，要隐藏状态栏，有工具栏时，工具栏消失时会自己隐藏
        if (_isDisappear) {
            self.statuBar.hidden = YES;
        }
        //不支持横屏的时候，要手动转，并给出frame
        if (direction == Letf){
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }];
        }
        else{
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }];
        }
        self.frame = CGRectMake(0, 0, Width, Height);
    }
    self.maskView.fullButton.selected = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}




#pragma mark - ------------- 竖屏时恢复原始大小 -------------
//不管是点全屏按钮恢复还是自动转屏恢复都走这个方法
- (void)originalscreen
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    _isFullScreen = NO;
    [self setStatusBarHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        //还原
        self.transform = CGAffineTransformMakeRotation(0);
    }];
    self.frame = _customFrame;
    //竖屏时状态栏要现实出来
    self.statuBar.alpha = 1.0;
    //还原到原有父类上
    [_fatherView addSubview:self];
     self.maskView.fullButton.selected = NO;
}


#pragma mark - ------------- 播放、暂停 -------------
//播放
- (void)startPlay
{
    self.maskView.playButton.selected = YES;
    [_player play];
}

//暂停
- (void)pausePlay
{
    self.maskView.playButton.selected = NO;
    [_player pause];
}


#pragma mark - ------------- 隐藏或者显示状态栏方法 -------------
- (void)setStatusBarHidden:(BOOL)hidden{
    //取出当前控制器的导航条
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    //设置是否隐藏
    statusBar.hidden  = hidden;
}



#pragma mark - ------------- KVO方法 -------------
//当status的值改变的时候会调用这个方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"] && object == self.player.currentItem) {
        //取出status的新值
        //AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            self.state = JPSPlayerStatePlaying;
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            self.state = JPSPlayerStateFailed;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.playerItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.maskView.progress setProgress:timeInterval / totalDuration animated:NO];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
        // 当缓冲是空的时候
        if (self.playerItem.playbackBufferEmpty) {
            self.state = JPSPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        // 当缓冲好的时候
        if (self.playerItem.playbackLikelyToKeepUp && self.state == JPSPlayerStateBuffering){
            self.state = JPSPlayerStatePlaying;
        }
    }
}


#pragma mark - ------------- 耳机插入、拔出事件 -------------
/**
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            DLog(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
            DLog(@"耳机拔掉");
            [self startPlay];
        }
            
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}



#pragma mark - setter

- (void)setState:(JPSPlayerState)state
{
    _state = state;
    if (state == JPSPlayerStateBuffering) {
        [self.maskView.activity startAnimating];
    }else if (state == JPSPlayerStateFailed){
        [self.maskView.activity stopAnimating];
        NSLog(@"加载失败");
        self.maskView.failButton.hidden = NO;
    }else{
        [self.maskView.activity stopAnimating];
        [self startPlay];
    }
}

#pragma mark - 缓冲较差时候
//卡顿时会走这里
- (void)bufferingSomeSecond{
    self.state = JPSPlayerStateBuffering;
    
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self pausePlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startPlay];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
        
    });
}
//计算缓冲进度
- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}



#pragma mark - ------------- 事件处理 -------------
/**
 工具条没消失的时候，点击屏幕马上要工具条消失
 */
- (void)disappearTap:(UITapGestureRecognizer *)tap
{
    //取消定时消失
    [self destroyTimer];
    if (_isDisappear == NO){
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 0;
            self.maskView.bottomToolBar.alpha = 0;
            if (_isFullScreen) {
                self.statuBar.alpha = 0;
            }
        }];
    }
    else{
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                                  target:self
                                                selector:@selector(disappear)
                                                userInfo:nil
                                                 repeats:NO];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 1.0;
            self.maskView.bottomToolBar.alpha = 1.0;
            if (_isFullScreen) {
                self.statuBar.alpha = 1.0;
            }
        }];
    }
    _isDisappear = !_isDisappear;
}




#pragma mark - ------------- 定时器响应方法 -------------
/**
 实时更新播放进度时间
 */
- (void)timeStack
{
    if (_playerItem.duration.timescale != 0){
        //总共时长
        self.maskView.slider.maximumValue = 1;
        
        //当前进度
        //totalTime = player.currentItem.duration;
        //            totalTime.value : 总的帧数
        //            totalTime.timescale 帧率;  (每秒播放多少帧)
        // 总的帧数 / 帧率 == 多少秒时间:
        // 当前时间 / 总的时间 == 进度条比例:
        self.maskView.slider.value        = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        
        //当前时长进度progress
        NSInteger proMin     = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec     = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        
        //duration 总时长
        NSInteger durMin     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总分钟
        NSInteger durSec     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总秒
        self.maskView.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
}

/**
 上下两个工具栏定时消失
 */
- (void)disappear
{
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topToolBar.alpha    = 0;
        self.maskView.bottomToolBar.alpha = 0;
        if (_isFullScreen) {
            self.statuBar.alpha = 0;
        }
    }];
}


#pragma mark - ------------- 销毁定时器 -------------
//销毁所有定时器
- (void)destroyAllTimer{
    [_sliderTimer invalidate];
    [_timer invalidate];
    _sliderTimer = nil;
    _timer       = nil;
}
//销毁定时消失定时器
- (void)destroyTimer{
    [_timer invalidate];
    _timer = nil;
}


#pragma mark - ------------- 销毁播放器 -------------
//销毁播放器
- (void)destroyPlayer
{
    //销毁所有定时器
    [self destroyAllTimer];
    //暂停
    [_player pause];
    //清除
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    //移除
    [self removeFromSuperview];
    
}



#pragma mark - ------------- 移除通知、观察者 -------------

- (void)dealloc
{
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    NSLog(@"播放器被销毁了");
}




#pragma mark - ------------- 代理方法 -------------
//返回按钮响应事件
-(void)backButtonAction:(UIButton *)button
{
    if (_isFullScreen) {
        [self originalscreen];
    }
}

//全屏按钮响应事件
-(void)fullButtonAction:(UIButton *)button
{
    if (_isFullScreen == NO){
        [self fullScreenWithDirection:Letf];
    }
    else{
        [self originalscreen];
    }
}
//播放暂停按钮方法
-(void)playButtonAction:(UIButton *)button
{
    if (button.selected == NO){
        [self pausePlay];
    }
    else{
        [self startPlay];
    }
}
//播放失败按钮点击事件
-(void)failButtonAction:(UIButton *)button
{
    //播放失败，重新用url初始化播放器，重新请求视频资源
    [self initPlayer];
    
    //[self setNeedsLayout];
    //[self layoutIfNeeded];
}

#pragma mark - 拖动进度条
//开始
-(void)progressSliderTouchBegan:(UISlider *)slider
{
    //暂停
    [self pausePlay];
    [self destroyTimer];
}
//拖拽中
-(void)progressSliderValueChanged:(UISlider *)slider
{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    
    //CMTimeMake(a,b)
    //a当前第几帧，b每秒钟多少帧。当前播放时间a/b
    
    [_player seekToTime:dragedCMTime];
}
//结束
-(void)progressSliderTouchEnded:(UISlider *)slider{
    //继续播放
    [self startPlay];
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
}



- (AVPlayer *)getPlayer
{
    return _player;
}




@end
