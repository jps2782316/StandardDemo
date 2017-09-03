//
//  MianDetailViewController.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/31.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "MianDetailViewController.h"
#import "JpsActivityIndicatorView.h"
#import "JPSPickerView.h"
#import "PickerView2.h"
#import "JpsDatePickerView.h"
#import "JpsPlaceholderView.h"
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>
#import "JpsActivityIndicatorView2.h"


@interface MianDetailViewController ()

@property(nonatomic,strong)JpsPlaceholderView *placeholderView;  //!<占位图

@end

@implementation MianDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"自封装";
    
    //UIImage *image = [self createImageWithColor:[[UIColor blueColor]colorWithAlphaComponent:0.1]];
    
    
    
}



//MARK: - 占位图
- (JpsPlaceholderView *)placeholderView
{
    if (_placeholderView == nil) {
        _placeholderView = [[JpsPlaceholderView alloc]initWithFrame:self.view.bounds image:[UIImage imageNamed:@"common_emptyIndexResult_bg"] tips:@"暂无数据"];
        [self.view addSubview:_placeholderView];
    }
    return _placeholderView;
}


//MARK: - 0.自定义菊花
- (void)customerActivityIndicator
{
//    JpsActivityIndicatorView *activityV = [[JpsActivityIndicatorView alloc] startActivityOnSuperView:self.view];
//    [self.view addSubview:activityV];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [activityV stopAnimation];
//        [self placeholderView];
//    });
    
//    [JpsActivityIndicatorView2 showInSuperView:self.view title:@"加载中..."];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [JpsActivityIndicatorView2 dismiss];
//        [self placeholderView];
//    });
    
    [JpsActivityIndicatorView2 showWithTitile:@"加载中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JpsActivityIndicatorView2 dismiss];
        [self placeholderView];
    });
}

//MARK: - 1.选择器
- (void)pickerView
{
//    JPSPickerView *pickerView = [[JPSPickerView alloc]initWithFrame:self.view.bounds];
//    [pickerView setValueCallBack:^(NSString *valueStr) {
//        self.navigationItem.title = valueStr;
//    }];
//    pickerView.dataSource = @[@"大", @"鱼", @"海", @"棠"];
//    pickerView.tipsLabel.text = @"凝望你沉睡的轮廓";
//    [self.view addSubview:pickerView];
    
    
    PickerView2 *pickerView = [[PickerView2 alloc]initWithFrame:self.view.bounds];
    [pickerView setValueCallBack:^(NSString *valueStr) {
        NSLog(@"%@",valueStr);
    }];
    [self.view addSubview:pickerView];
}

//MARK: - 2.时间选择器
- (void)datePickerView
{
    JpsDatePickerView *datePickerView = [[JpsDatePickerView alloc]initWithFrame:self.view.bounds];
    [datePickerView setValueCallBack:^(NSString *valueStr) {
        self.navigationItem.title = valueStr;
    }];
    datePickerView.tipsLabel.text = @"请选择时间";
    [self.view addSubview:datePickerView];
}

//MARK: - 3.模糊效果
//1)CoreImage->边上会有一道白边无法渲染完成
//2)vImage->能完全将整张图片渲染为模糊,效率高
//3)GPUImage->第三方开源的库

// 添加通用模糊效果 使用  vImage实现模糊效果
// image是图片，blur是模糊度
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (image==nil)
    {
        NSLog(@"error:为图片添加模糊效果时，未能获取原始图片");
        return nil;
    }
    //模糊度,
    if (blur < 0.025f) {
        blur = 0.025f;
    } else if (blur > 1.0f) {
        blur = 1.0f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    NSLog(@"boxSize:%i",boxSize);
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    //CGColorSpaceRelease(colorSpace);   //多余的释放
    CGImageRelease(imageRef);
    return returnImage;
}



#pragma mark - ---------- 其他 -----------


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DLog(@"toucheBegan");
}


- (void)setItem:(NSInteger)item
{
    _item = item;
    
    switch (item) {
        case 0:
        {
            [self customerActivityIndicator];
        }
            break;
        case 1:
        {
            [self pickerView];
        }
            break;
        case 2:
        {
            [self datePickerView];
        }
            break;
        case 3:
        {
            UIImage *image = [self blurryImage:[UIImage imageNamed:@"beaty"] withBlurLevel:0.3];
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:self.view.bounds];
            imageV.image = image;
            [self.view addSubview:imageV];
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
        case 7:
        {
            
        }
            break;
        case 8:
        {
            
        }
            break;
        case 9:
        {
            
        }
            break;
        case 10:
        {
            
        }
            break;
        case 11:
        {
            
        }
            break;
        case 12:
        {
            
        }
            break;
            
        default:
            break;
    }
}







@end
