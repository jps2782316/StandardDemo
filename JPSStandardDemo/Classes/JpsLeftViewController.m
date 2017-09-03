//
//  JpsLeftViewController.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/2.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsLeftViewController.h"

@interface JpsLeftViewController ()

@property(nonatomic,strong)UIImageView *backgroundImageView;

@end

@implementation JpsLeftViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置背景图片。（拖入Assets.xcassets文件夹中的图片最后会被打包成一个Assets.car文件）
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"62d817427b27f6ba951097b5b5e8d0c15638f741295cb-OxosYd_fw658" ofType:@"jpeg"];
    self.backgroundImageView.image = [UIImage imageWithContentsOfFile:filePath];
    
}





//http://blog.csdn.net/dqjyong/article/details/26969355
//因此imageNamed的优点是当加载时会缓存图片。所以当图片会频繁的使用时，那么用imageNamed的方法会比较好。
//imageWithContentsOfFile：仅加载图片，图像数据不会缓存。因此对于较大的图片以及使用情况较少时，那就可以用该方法，降低内存消耗







@end
