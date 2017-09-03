//
//  JpsPlayerMaskView.m
//  JPSStandardDemo
//
//  Created by jps on 2017/5/18.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsPlayerMaskView.h"
#import "Masonry.h"
#import <MediaPlayer/MediaPlayer.h>  //音量控制要用
#import "JpsBrightnessView.h"

//间隙
#define Padding        10
//顶部底部工具条高度
#define ToolBarHeight     64      //40
//进度条颜色
#define ProgressColor     [UIColor colorWithRed:0.54118 green:0.51373 blue:0.50980 alpha:1.00000]
//缓冲颜色
#define ProgressTintColor [UIColor orangeColor]
//播放完成颜色
#define PlayFinishColor   [UIColor whiteColor]


//用户滑动方向
typedef NS_ENUM(NSInteger, Direction) {
    DirectionNone,
    DirectionLeftOrRight,
    DirectionUpOrDown
};



@interface JpsPlayerMaskView ()

@property(nonatomic,assign)CGPoint startP;  //!<开始触摸的点
@property(nonatomic,assign)CGFloat startVolume;      //!<开始触摸时的音量
@property(nonatomic,assign)CGFloat startBrightness;  //!<开始触摸时的亮度


//借助MPVolumeView类来获取到其音量进度条，进而进行音量获取与控制
//为了获取当前音量要首先定义MPVolumeView、 UISlider
@property (strong, nonatomic) MPVolumeView *volumeView;//控制音量的view
@property (strong, nonatomic) UISlider* volumeViewSlider;//控制音量

@property(nonatomic, assign)Direction direction;  //!<用户滑动的方向


@property(nonatomic,assign)CGFloat startVideoRate;
@property(nonatomic,strong)AVPlayer *player;


@end




@implementation JpsPlayerMaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
        
        [JpsBrightnessView shareBrightnessView];
    }
    return self;
}
- (void)initViews{
    [self addSubview:self.topToolBar];
    [self addSubview:self.bottomToolBar];
    [self addSubview:self.activity];
    [self.topToolBar addSubview:self.backButton];
    [self.bottomToolBar addSubview:self.playButton];
    [self.bottomToolBar addSubview:self.fullButton];
    [self.bottomToolBar addSubview:self.currentTimeLabel];
    [self.bottomToolBar addSubview:self.totalTimeLabel];
    [self.bottomToolBar addSubview:self.progress];
    [self.bottomToolBar addSubview:self.slider];
    [self addSubview:self.failButton];
    [self makeConstraints];
    
    self.topToolBar.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    self.bottomToolBar.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
}




#pragma mark - ------------- 滑动调节音量、亮度、播放进度 -------------

// 其中通过AVAudioPlayer对象实例的volume属性可以调节该APP的音量大小。但不会影响到iOS系统音量
//MPVolumeView 是MediaPlayer框架中的一个组件，包含了对系统音量和AirPlay设备的音频镜像路由的控制功能。MPVolumeView有三个subview，其中私有类（无法手动创建，也无法使用isKindOfClass方法）MPVolumeSlider用来控制音量大小，继承自UISlider。
//另外还有UILabel和MPButton两个subview，暂时没有使用到。
//将MPVolumeView对象实例当做一个subview，添加到父view中即可使用，但其UI可定制性很低。使用前要import MediaPlayer。



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    self.startP = [touch locationInView:self];
    //开始时的亮度
    self.startBrightness = [UIScreen mainScreen].brightness;
    
    //开始时的声音
    [self volumeView];
    self.startVolume = self.volumeViewSlider.value;
    
    //开始时的进度
    if (_delegate && [_delegate respondsToSelector:@selector(backButtonAction:)]) {
        self.player = [_delegate getPlayer];
        CMTime currentTime = self.player.currentTime;
        
        AVPlayerItem *playerItem = self.player.currentItem;
        CGFloat total = playerItem.duration.value / playerItem.duration.timescale;
        
        self.startVideoRate = currentTime.value / currentTime.timescale / total;
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
    
    
    
}


//http://www.jianshu.com/p/5396866e3256    iOS流媒体开发之二：滑动手势控制音量、亮度和进度


//手指持续滑动，此方法会持续调用
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint currentP = [[touches anyObject] locationInView:self];
    
    //记下x和y与起始点的差
    CGPoint point = CGPointMake(currentP.x-self.startP.x, currentP.y-self.startP.y);
    
    
    //分析出用户滑动的方向
    if (point.x >= 30 || point.x <= -30) {
        //进度
        self.direction = DirectionLeftOrRight;
    } else if (point.y >= 30 || point.y <= -30) {
        //音量和亮度
        self.direction = DirectionUpOrDown;
    }
    
    
    if (self.direction == DirectionNone) {
        return;
    }
    //1. 进度
    else if (self.direction == DirectionLeftOrRight){
        DLog(@"进度调整");
        //当前进度比例
        CGFloat rate = self.startVideoRate + (point.x / 30.0 / 20.0);
        if (rate > 1) {
            rate = 1;
        } else if (rate < 0) {
            rate = 0;
        }
        //总长
        AVPlayerItem *playerItem = self.player.currentItem;
        CGFloat total = playerItem.duration.value / playerItem.duration.timescale;
        //计算出拖动的当前秒数(总长*当前百分比)
        NSInteger dragedSeconds = floorf(total * rate);
        
        //CMTimeMake(a,b)
        //a当前第几帧，b每秒钟多少帧。当前播放时间a/b
        
        CMTime newCMTime = CMTimeMake(dragedSeconds, 1);
        [self.player seekToTime:newCMTime];
    }
    //2. 音量和亮度
    else if (self.direction == DirectionUpOrDown){
        //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
        if (self.startP.x <= Width / 2.0) {
            //调节亮度
            if (currentP.y - self.startP.y < 0) {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:self.startBrightness + (-point.y/30/10)];
            }else{
                //减少亮度
                [[UIScreen mainScreen] setBrightness:self.startBrightness - (point.y/30/10)];
            }
        }
        else {
            //调节音量
            if (point.y < 0) {
                //增大音量
                [self.volumeViewSlider setValue:self.startVolume + (-point.y / 30.0 / 10) animated:YES];
                if (self.startVolume + (-point.y / 30 / 10) - self.volumeViewSlider.value >= 0.1) {
                    [self.volumeViewSlider setValue:0.1 animated:NO];
                    [self.volumeViewSlider setValue:self.startVolume + (-point.y / 30.0 / 10) animated:YES];
                }
            } else {
                //减少音量
                [self.volumeViewSlider setValue:self.startVolume - (point.y / 30.0 / 10) animated:YES];
            }
        }
    }
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.direction == DirectionLeftOrRight) {
        //在这里处理进度设置成功后的事情, 例如用新的CMTime开始播放，而不必在touchMove里开始播放
    }
}


- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
//        [_volumeView setHidden:YES];
//        [self addSubview:_volumeView];
//        _volumeView  = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 10)];
        _volumeView  = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}




#pragma mark - ------------- 约束 -------------
- (void)makeConstraints{
    //顶部工具条
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    //底部工具条
    [self .bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    //转子
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    //返回按钮
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(17);
        make.bottom.mas_equalTo(0);
        //make.width.equalTo(self.backButton.mas_height);
    }];
    //播放按钮
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(Padding);
        make.top.mas_equalTo(Padding+12);
        make.bottom.mas_equalTo(-Padding-12);
        make.width.equalTo(@23);
    }];
    //全屏按钮
    [self.fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-Padding);
        make.right.bottom.mas_equalTo(-Padding-12);
        make.top.mas_equalTo(Padding+12);
        make.width.equalTo(@23);
    }];
    //当前播放时间
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(Padding);
        make.width.mas_equalTo(35);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //总时间
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullButton.mas_left).offset(-Padding);
        make.width.mas_equalTo(35);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //缓冲条
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(Padding);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(-Padding);
        make.height.mas_equalTo(2);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //滑杆
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.progress);
    }];
    //失败按钮
    [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}





#pragma mark - ------------- 懒加载 -------------
//顶部工具条
- (UIView *) topToolBar{
    if (_topToolBar == nil){
        _topToolBar = [[UIView alloc] init];
        _topToolBar.userInteractionEnabled = YES;
    }
    return _topToolBar;
}
//底部工具条
- (UIView *) bottomToolBar{
    if (_bottomToolBar == nil){
        _bottomToolBar = [[UIView alloc] init];
        _bottomToolBar.userInteractionEnabled = YES;
    }
    return _bottomToolBar;
}
//转子
- (UIActivityIndicatorView *) activity{
    if (_activity == nil){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activity startAnimating];
    }
    return _activity;
}
//返回按钮
- (UIButton *) backButton{
    if (_backButton == nil){
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton setImage:[self getPictureWithName:@"back"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
//播放按钮
- (UIButton *) playButton{
    if (_playButton == nil){
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
        [_playButton setImage:[self getPictureWithName:@"CLPauseBtn"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
//全屏按钮
- (UIButton *) fullButton{
    if (_fullButton == nil){
        _fullButton = [[UIButton alloc] init];
        [_fullButton setImage:[self getPictureWithName:@"CLMaxBtn"] forState:UIControlStateNormal];
        [_fullButton setImage:[self getPictureWithName:@"CLMinBtn"] forState:UIControlStateSelected];
        [_fullButton addTarget:self action:@selector(fullButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}
//当前播放时间
- (UILabel *) currentTimeLabel{
    if (_currentTimeLabel == nil){
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font      = [UIFont systemFontOfSize:12];
        _currentTimeLabel.text      = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}
//总时间
- (UILabel *) totalTimeLabel{
    if (_totalTimeLabel == nil){
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font      = [UIFont systemFontOfSize:12];
        _totalTimeLabel.text      = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}
//缓冲条
- (UIProgressView *) progress{
    if (_progress == nil){
        _progress = [[UIProgressView alloc] init];
        _progress.trackTintColor = ProgressColor;
        _progress.progressTintColor = ProgressTintColor;
    }
    return _progress;
}
//滑动条
- (UISlider *) slider{
    if (_slider == nil){
        _slider = [[UISlider alloc] init];
        UIImage *thumbImage = [self getPictureWithName:@"CLRound"];
        [_slider setThumbImage:thumbImage forState:UIControlStateNormal];
        //设置高亮时的图片，即收按到滑块上时的图片
        [_slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
        // slider开始滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        //左边颜色
        _slider.minimumTrackTintColor = PlayFinishColor;
        //右边颜色
        _slider.maximumTrackTintColor = [UIColor clearColor];
    }
    return _slider;
}
//加载失败按钮
- (UIButton *) failButton
{
    if (_failButton == nil) {
        _failButton = [[UIButton alloc] init];
        _failButton.hidden = YES;
        [_failButton setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failButton.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
        [_failButton addTarget:self action:@selector(failButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failButton;
}






#pragma mark - ------------- 按钮点击事件 -------------
//respondsToSelector 判断是否实现了某方法, 也就是判断代理能不能执行某方法.
//返回按钮
- (void)backButtonAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(backButtonAction:)]) {
        [_delegate backButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//播放按钮
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(playButtonAction:)]) {
        [_delegate playButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//全屏按钮
- (void)fullButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(fullButtonAction:)]) {
        [_delegate fullButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//失败按钮
- (void)failButtonAction:(UIButton *)button{
    self.failButton.hidden = YES;
    [self.activity startAnimating];
    if (_delegate && [_delegate respondsToSelector:@selector(failButtonAction:)]) {
        [_delegate failButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}




#pragma mark - ------------- 滑杆响应事件 -------------
//开始滑动
- (void)progressSliderTouchBegan:(UISlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(progressSliderTouchBegan:)]) {
        [_delegate progressSliderTouchBegan:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动中
- (void)progressSliderValueChanged:(UISlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(progressSliderValueChanged:)]) {
        [_delegate progressSliderValueChanged:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动结束
- (void)progressSliderTouchEnded:(UISlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(progressSliderTouchEnded:)]) {
        [_delegate progressSliderTouchEnded:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}






#pragma mark - ------------- 获取资源图片 -------------
- (UIImage *)getPictureWithName:(NSString *)name{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

@end
