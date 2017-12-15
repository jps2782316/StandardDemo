//
//  MainViewController.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/28.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "MainViewController.h"
#import "AdvertisementView.h"
#import "AdvertisementView2.h"
#import "OneCollectionViewCell.h"
#import "MianDetailViewController.h"
#import "JpsAVPlayerViewController.h"
#import "NXABlueToothViewController.h"
#import "JpsSpeechViewController.h"
#import "SpeechViewController.h"
#import "JPSPlayerViewController.h"


#define kItemW Width/4.0


//UICollectionViewDelegateFlowLayout 为 UICollectionViewDelegate 子类，实现一个就够了

@interface MainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)AdvertisementView *advertisementV;  //!<广告栏
@property(nonatomic,strong)AdvertisementView2 *advertisementV2;

@property(nonatomic,strong)NSMutableArray *images;    //!<
@property(nonatomic,strong)NSMutableArray *titles;    //!<
@property(nonatomic,weak)UICollectionView *collectionView;    //!<




@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //广告栏
    //[self advertisement];
    [self advertisementV2];
    
    
    [self collectionView];
    
    
    
    
//    //设置大标题
//    if (@available(iOS 11.0, *)) {
//        self.navigationController.navigationBar.prefersLargeTitles = YES;
//    } else {
//        // Fallback on earlier versions
//    }
    
    //====================== Utility 方法测试验证 =================
    NSString *str1 = [JpsUtility dateStrWithYear:0 month:-1 week:0 day:1 date:[NSDate date]];
    DLog(@"str1= %@",str1);
    
    NSString *dateStr = [JpsUtility stringFromDate:[NSDate date] dateFromat:@"yyyy年MM月dd日 HH时mm分ss秒"];
    DLog(@"%@",dateStr);  //@"yyyy-MM-dd"

    NSDate *date = [JpsUtility dateFromString:@"20160707094106" dateFormat:@"yyyyMMddHHmmss"];
    DLog(@"date= %@",date);
}





//广告栏
- (void)advertisement
{
    //不加这句广告栏图片可能会一会高一会低
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSArray *images = @[@"1.jpg", @"2.jpg", @"3.jpg"];
    self.advertisementV = [[AdvertisementView alloc]initWithFrame:CGRectMake(0, 64, Width, Height/3.0) images:images];
    [self.view addSubview:self.advertisementV];
}

- (AdvertisementView2 *)advertisementV2
{
    if (_advertisementV2 == nil) {
        NSArray *images = @[@"yanlingji.jpg", @"wugengji.jpg", @"shaosiming.jpg"];
        _advertisementV2 = [[AdvertisementView2 alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, Height/3.0) images:images];
        [self.view addSubview:_advertisementV2];
    }
    return _advertisementV2;
}






#pragma mark - ------------- UICollectionViewDataSource -------------

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"%ld",indexPath.item);
    OneCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OneCollectionViewCell" forIndexPath:indexPath];
    
    cell.image = self.images[indexPath.item];
    if (indexPath.row < self.titles.count) {
        cell.title = self.titles[indexPath.item];
        
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {//视频播放
        JpsAVPlayerViewController *playerVC = [[JpsAVPlayerViewController alloc]init];
        [playerVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:playerVC animated:YES];
        return;
    }
    if (indexPath.row == 5) {//蓝牙
        NXABlueToothViewController *blueToothVC = [[NXABlueToothViewController alloc]init];
        [blueToothVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:blueToothVC animated:YES];
        return;
    }
    if (indexPath.row == 6) { //语音识别
        //SpeechViewController *speechVC = [[SpeechViewController alloc]init];
        JpsSpeechViewController *speechVC = [[JpsSpeechViewController alloc]init];
        [speechVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:speechVC animated:YES];
        return;
    }
    if (indexPath.row == 7) { //视频播放 (转屏时window方向也转了)
        JPSPlayerViewController *playerVC2 = [[JPSPlayerViewController alloc]init];
        [playerVC2 setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:playerVC2 animated:YES];
        return;
    }
    
    //其他一些小控件，统统放到此控制器展示
    MianDetailViewController *detailVC = [[MianDetailViewController alloc]init];
    detailVC.item = indexPath.item;
    //push隐藏tabbar
    [detailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
}



#pragma mark - ---------- Utility方法验证测试 -----------






#pragma mark - ------------- lazy -------------

//- (UICollectionViewFlowLayout *)flowLayout
//{
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//    //cell的大小
//    layout.itemSize = CGSizeMake(kItemW, kItemW+30);
//    //头视图大小
//    layout.headerReferenceSize = CGSizeMake(Width, Width*0.536);
//    CGFloat margin = (Width-3*(kItemW))/4.0; //减掉3个item后，还有四个间隙
//    //上左下右的距离
//    layout.sectionInset = UIEdgeInsetsMake(20, margin-10, 20, margin-10);  //(20, kItemW/2, 20, kItemW/2);
//    //cell间的最小距离
//    layout.minimumLineSpacing = 30;   //上下 20
//    layout.minimumInteritemSpacing = margin;  //左右 5
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    return layout;
//}

- (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    //cell大小
    layout.itemSize = CGSizeMake(kItemW, kItemW+30);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    return layout;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [self flowLayout];
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.advertisementV2.frame), Width, Height/3.0*2-64-44) collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.bounces = YES;
        collectionView.bouncesZoom = YES;
        [collectionView registerClass:[OneCollectionViewCell class] forCellWithReuseIdentifier:@"OneCollectionViewCell"];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}


- (NSMutableArray *)images
{
    if (_images == nil) {
        _images = [[NSMutableArray alloc]init];
        for (int i = 0; i < 12; i++) {
            NSString *name = [NSString stringWithFormat:@"%d",i];
            UIImage *image = [UIImage imageNamed:name];
            [_images addObject:image];
        }
    }
    return _images;
}

- (NSMutableArray *)titles
{
    if (!_titles) {
        
        NSArray *arr = @[@"0",
                         @"1",
                         @"2",
                         @"3",
                         @"4",
                         @"5",
                         @"6",
                         @"7",
                         @"8",
                         @"9",
                         @"10",
                         @"11"];
        _titles = [[NSMutableArray alloc]initWithArray:arr];
    }
    return _titles;
}


@end
