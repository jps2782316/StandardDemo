//
//  JpsPlayerView.h
//  JPSStandardDemo
//
//  Created by jps on 2017/5/17.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,VideoFillMode){
    Resize = 0,          //拉伸占满整个播放器，不按原比例拉伸
    ResizeAspect,        //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
    ResizeAspectFill,    //按照原比例拉伸占满整个播放器，但视频内容超出部分会被剪切
};



@interface JpsPlayerView : UIView

@property(nonatomic,copy)NSString *vedioUrl;       //!<远程视频地址

@property(nonatomic,copy)NSString *localVedioUrl;    //!<本地视频地址

@property(nonatomic,copy)NSString *vedioName;       //!<视频名字，用于显示在topToolBar上

/**拉伸方式，默认按原视频比例显*/
@property (nonatomic,assign) VideoFillMode fillMode;

/**销毁播放器*/
- (void)destroyPlayer;






@end
