//
//  NXADatePickerView.m
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/3/10.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import "JpsDatePickerView.h"


#define W [UIScreen mainScreen].bounds.size.width

@interface JpsDatePickerView ()

@property(nonatomic,strong)UIDatePicker *datePicker;  //!<时间选择器 不能用weak类型，不然加不上

@property(nonatomic,strong)UIButton *confirmBtn;
@property(nonatomic,copy)NSString *valueStr;       //!<传回去的值


@end

@implementation JpsDatePickerView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    [v addSubview:self.datePicker];
    //确定按钮
    self.confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.datePicker.frame), v.frame.size.width, 40)];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundColor:ThemeColor];
    [self.confirmBtn addTarget:self action:@selector(valueCallBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:self.confirmBtn];
}




#pragma mark - ------------- EventsHandle -------------

-(void)dataChange:(UIDatePicker *)datePicker{
    
    NSDate *dateP = datePicker.date;
    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
    [dateFor setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [dateFor stringFromDate:dateP];
    
    self.valueStr = str;
    
    NSLog(@"%@",str);
}

//确定按钮点击事件
- (void)valueCallBackClick:(UIButton *)sender
{
    if (_valueCallBack) {
        _valueCallBack(self.valueStr);
    }
    [self removeFromSuperview];
}





#pragma mark - ------------- setter -------------

- (void)setValueCallBack:(ValueCallBack)callBack
{
    _valueCallBack = callBack;
}


#pragma mark - ------------- Others -------------

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}



#pragma mark - ------------- 懒加载 -------------

//时间选择器
- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width-80, 200)];
        _datePicker.backgroundColor = ThemColor2;
        _datePicker.datePickerMode = UIDatePickerModeDate;//时分秒、年月日
        //  dataPic.minuteInterval = 10;//默认1分钟
        //最大最小日期范围
        NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
        [dateFor setDateFormat:@"yyyy-MM-dd"];//格式化时间输出 +0800为北京时区
        _datePicker.minimumDate = [dateFor dateFromString:@"2010-01-01"];
        
        NSDate *d = [NSDate date];
        NSString *dateString = [dateFor stringFromDate:d];
        
        _datePicker.maximumDate = [dateFor dateFromString:dateString];
        _datePicker.date = [NSDate date];
        
        //设置ymdstr，让没划动picker也能选中默认值
        NSString *dateStr = [dateFor stringFromDate:[NSDate date]];
        self.valueStr = dateStr;
        
        [_datePicker addTarget:self action:@selector(dataChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}






@end
