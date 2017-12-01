//
//  BaseViewController.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/29.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property(nonatomic,weak)UILabel *placeHolderLabel;  //!<占位label

@property(nonatomic,strong)SingleDataManager *dataManager;  //!<数据管理单例
@property(nonatomic,strong)NetworkingManager *netManager;    //!<网络请求单例

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    
}



#pragma mark - ------------- LifeCircle -------------



#pragma mark - ------------- UI -------------

- (void)initNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    //半透明
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"驾易通教练版";
    //导航栏按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //导航栏背景颜色
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    //设置导航栏title字体大小颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //不渲染
    //UIImage *image = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [UIImage imageNamed:@"back"];
    //左边返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backClick:)];
    //右边搜索按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(serachAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - ------------- Networking -------------


#pragma mark - ---------- Action -----------

- (void)backClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)serachAction:(UIBarButtonItem *)item
{
    
}

#pragma mark - ------------- Notification -------------


#pragma mark - ------------- setter -------------


#pragma mark - ------------- Others -------------



#pragma mark - ------------- Lazy -------------

//1. 网络请求单利
- (NetworkingManager *)netManager
{
    if (!_netManager) {
        _netManager = [NetworkingManager shareManager];
    }
    return _netManager;
}


//2. 数据管理单利
- (SingleDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [SingleDataManager shareManager];
    }
    return _dataManager;
}


//3. 占位（网络请求失败或没数据显示出来,有数据移除）
- (UILabel *)placeHolderLabel
{
    if (!_placeHolderLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.bounds = CGRectMake(0, 0, 120, 30);
        label.center = self.view.center;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:19];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"暂无投诉记录";
        [self.view addSubview:label];
        _placeHolderLabel = label;
    }
    return _placeHolderLabel;
}


@end
