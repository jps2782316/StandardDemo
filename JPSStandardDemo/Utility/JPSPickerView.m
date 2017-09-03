//
//  JPSPickerView.m
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/3/8.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import "JPSPickerView.h"

#define W [UIScreen mainScreen].bounds.size.width


@interface JPSPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,weak)UIPickerView *pickerView;
@property(nonatomic,strong)UIButton *confirmBtn;
@property(nonatomic,copy)NSString *valueStr;       //!<传回去的值



@end


@implementation JPSPickerView



- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initComponents];
    }
    return self;
}




- (void)initComponents
{
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectZero];
    v.layer.cornerRadius = 8;
    v.layer.masksToBounds = YES;
    v.center = self.center;
    v.bounds = CGRectMake(0, 0, W-80, 280);
    v.backgroundColor = [UIColor whiteColor];
    [self addSubview:v];
    //提示label
    CGFloat w = v.frame.size.width/3;
    self.tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, w, 40)];
    self.tipsLabel.adjustsFontSizeToFitWidth = YES;
    self.tipsLabel.textColor = [UIColor lightGrayColor];
    //self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    [v addSubview:self.tipsLabel];
    //选择器
    [v addSubview:self.pickerView];
    //确定按钮
    self.confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pickerView.frame), v.frame.size.width, 40)];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundColor:ThemeColor];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:self.confirmBtn];
}


#pragma mark - ------------- EventsHandel -------------

- (void)confirmBtnClick:(UIButton *)sender
{
    if (_valueCallBack) {
        _valueCallBack(self.valueStr);
    }
    [self removeFromSuperview];
}


#pragma mark - ------------- setter -------------

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    
    self.valueStr = dataSource[0];
    [self.pickerView reloadAllComponents];
}

- (void)setValueCallBack:(ValueCallBack)callBack
{
    _valueCallBack = callBack;
}



#pragma mark - ------------- Others -------------

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}



#pragma mark - ------------- UIPickerViewDataSorce -------------

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.dataSource.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.dataSource[row];
}


//选择器的代理方法didselectRow 只有在停止后才会调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.valueStr = self.dataSource[row];
    
    
    // [pickerView selectRow:0 inComponent:0 animated:YES];   //加了这句，选到下一行又跳回来了
    
//    //防止pickerView某列还在滑动中  而选择另一行时 引起崩溃
//    if (cityArray.count-1<rowCity) {
//        
//    }else{
//        NSString *cityName =cityArray[rowCity][@"name"];
//        districtArray = districtDic[cityName];
//        [pickerView reloadAllComponents];
//        [pickerView selectRow:0 inComponent:2 animated:YES];
//        
//    }
    
}




#pragma mark - ------------- 懒加载 -------------

- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, self.bounds.size.width-80, 200)];
        pickerView.backgroundColor = ThemColor2;
        pickerView.delegate = self;
        pickerView.dataSource = self;
        [self addSubview:pickerView];
        
        _pickerView = pickerView;
    }
    return _pickerView;
}







@end
