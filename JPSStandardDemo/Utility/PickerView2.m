//
//  PickerView2.m
//  PickerView
//
//  Created by 金平生 on 2017/6/25.
//  Copyright © 2017年 金平生. All rights reserved.
//

#import "PickerView2.h"

#define W [UIScreen mainScreen].bounds.size.width

//#define ThemeColor [UIColor redColor]
//#define ThemeColor2 [UIColor greenColor]


@interface PickerView2 ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,weak)UIPickerView *pickerView;
@property(nonatomic,strong)UIButton *confirmBtn;
@property(nonatomic,copy)NSString *valueStr;       //!<传回去的值



@property(nonatomic,strong)NSArray *provinceArray;  //省的数组
@property(nonatomic,strong)NSArray *cityArray;  //市的数组
@property(nonatomic,strong)NSArray *districtArray;  //区的数组

@property(nonatomic,copy)NSString *provinceName;  //省名
@property(nonatomic,copy)NSString *provinceId;
@property(nonatomic,copy)NSString *cityName;  //城市名
@property(nonatomic,copy)NSString *districtName;  //区名


@property(nonatomic,strong)NSMutableDictionary *cityDic;   //省名 = 城市数组（有几个省，就有几个键值对）
@property(nonatomic,strong)NSMutableDictionary *districtDic;   //城市名 = 区域数组



@end




@implementation PickerView2

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initDataSource];
        [self initComponents];
        //NSLog(@"%@",self.dataSource);
    }
    return self;
}


#pragma mark - ---------- 初始化UI -----------
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
    self.tipsLabel.text = @"请选择地市";
    [v addSubview:self.tipsLabel];
    
    //选择器
    [v addSubview:self.pickerView];
    // 显示选中框
    self.pickerView.showsSelectionIndicator = NO;
    [self.pickerView selectRow:0 inComponent:0 animated:0];
    [self.pickerView reloadAllComponents];
    NSInteger provinceRow = [self.pickerView selectedRowInComponent:0];
    NSString *provinceName = _provinceArray[provinceRow][@"name"];
    _cityArray = _cityDic[provinceName];
    NSInteger cityRow = [self.pickerView selectedRowInComponent:1];
    NSString *cityName = _cityArray[cityRow][@"name"];
    _districtArray = _districtDic[cityName];
    
    //确定按钮
    self.confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pickerView.frame), v.frame.size.width, 40)];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundColor:ThemeColor];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:self.confirmBtn];
}

#pragma mark - ---------- 读取文件路径 -----------

- (void)initDataSource
{
    //从xml获取数组和字典
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"xml"];
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //json转字典
    NSDictionary *listDic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSDictionary *dictionary = [listDic objectForKey:@"list"];
    _provinceArray = [dictionary objectForKey:@"province"]; //得到省的数组，每个元素都是一个字典（有几个省就有几个字典）
    
    _cityDic = [[NSMutableDictionary alloc]init];
    _districtDic = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < _provinceArray.count; i++) {
        //1. 取出第i个省的数据
       // NSDictionary *provinceDic = [_provinceArray objectAtIndex:1];
        NSDictionary *provinceDic = _provinceArray[i];
        self.provinceName = provinceDic[@"name"];
        self.provinceId = provinceDic[@"id"];
        //self.cityArray = provinceDic[@"city"];
        
        //因为xml文件中存在直辖市等的city类型是字典 而正常的省会是数组 所以加以区分
        if ([provinceDic[@"city"] isKindOfClass:[NSArray class]]) {
            //2. 第i个省的所有城市信息
            _cityArray = provinceDic[@"city"];
            for (int j = 0; j < _cityArray.count; j++) {
                NSDictionary *cityDic = _cityArray[j];
                self.cityName = cityDic[@"name"];
                //一个城市下面的区域数据
                _districtArray = cityDic[@"region"];
                if (_districtArray.count != 0) {
                    //城市名 = 区域数组
                    [_districtDic setObject:_districtArray forKey:self.cityName];
                }
            }
            //省名 = 城市数组
            [_cityDic setObject:_cityArray forKey:self.provinceName];
        }
        else if ([provinceDic[@"city"] isKindOfClass:[NSDictionary class]]){
            NSMutableArray *cityarray = [[NSMutableArray alloc]init];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:_provinceName forKey:@"name"];
            [dic setObject:_provinceId forKey:@"id"];
            [cityarray addObject:dic];
            [_cityDic setObject:cityarray forKey:_provinceName];
            NSDictionary *cityArray1 = [provinceDic objectForKey:@"city"];
            _districtArray = [cityArray1 objectForKey:@"region"];
            if (_districtArray.count > 0) {
                [_districtDic setObject:_districtArray forKey:_provinceName];
            }
        }
    }
    NSLog(@"%@",_cityDic);
    
}




#pragma mark - ------------- EventsHandel -------------

- (void)confirmBtnClick:(UIButton *)sender
{
    NSString *addressStr = [NSString stringWithFormat:@"%@%@%@", self.provinceName, self.cityName, self.districtName];
    self.valueStr = addressStr;
    
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





#pragma mark - ------------- UIPickerViewDataSorce -------------

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component) {
        return _provinceArray.count;
    }else if (1 == component){
        return _cityArray.count;
    }else{
        return _districtArray.count;
    }
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if (component == 0) {
//        self.provinceName = _provinceArray[row][@"name"];
//        return self.provinceName;
//    }
//    else if (1 == component){
//        self.cityName = _cityArray[row][@"name"];
//        NSLog(@"%@",self.cityName);
//        return self.cityName;
//    }
//    else{
//        if ([self.districtArray isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *dic = (NSDictionary *)_districtArray;
//            self.districtName = dic[@"name"];
//        }else{
//            self.districtName = self.districtArray[row][@"name"];
//        }
//        return self.districtName;
//    }
//}


//选择器的代理方法didselectRow 只有在停止后才会调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    
    if (component == 0) {
        NSInteger provinceRow = [_pickerView selectedRowInComponent:0];  ////返回某一列的选中行，-1表示没有选中行
        NSString *provinceName = _provinceArray[provinceRow][@"name"];
        _cityArray = _cityDic[provinceName];
        [pickerView selectRow:0 inComponent:1 animated:YES]; ////动画效果跳到选中某一列的某一行
        [pickerView reloadAllComponents];
        //        [pickerView selectRow:0 inComponent:1 animated:YES];//1⃣️
        //        NSInteger rowCity = [picker selectedRowInComponent:1];//2⃣️
        NSInteger cityRow = 0;
        
        //前一个省（12个城市）：A省    滑动到B之前，选中的第11行
        //当前选中的省（4个城市）：B省
        //当省列和城市列同时滑动时，当第一列停下来出发此方法（从A省切换为B省），并设置选中城市列的第0行，但因为城市列还在手拖住滑动中，有可能这句代码不生效，第二列刷新不了数据，城市列还是A省的数据，城市列选中的行还是A省上次选中的第11行。而城市数组已经用省名取出来更新了（含有4个元素），如果这是用rowCity取cityArr，就会造成崩溃。  此时虽然选中了省，但城市列和地区列是没有更新的，正常情况下时会更新的。所以当城市列停下来的时候，选中的row也有可能大于cityArray下标的（这时城市列停下来也不会刷新城市列和地区列，简单说就是城市列地区列都还是A省的数据）。当小于时，就算选中的事A省的第二个城市，单用下标取B省的第二个城市，就把数据更正回来了。
        
        //防止pickerView某列还在滑动中  而选择另一行时 引起崩溃
        if (cityRow > _cityArray.count-1) {
            
        }else{
            NSString *cityName = _cityArray[cityRow][@"name"];
            _districtArray = _districtDic[cityName];
            [pickerView reloadAllComponents];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }
    else if (component == 1){
        NSInteger provinceRow = [_pickerView selectedRowInComponent:0];
        NSString *provinceName = _provinceArray[provinceRow][@"name"];
        _cityArray = _cityDic[provinceName];
        NSInteger cityRow = [pickerView selectedRowInComponent:1];
        if (cityRow <= _cityArray.count-1) {
            NSString *cityName = _cityArray[cityRow][@"name"];
            _districtArray = _districtDic[cityName];
            [pickerView reloadAllComponents];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }else{
        [pickerView reloadAllComponents];
    }
    
}

//// 反回pickerView的宽度
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    if (component == 2) {
//        return 20;
//    }
//    else{
//        return 50;
//    }
//}

// 返回pickerView的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        self.provinceName = _provinceArray[row][@"name"];
        return [self attributedStringFromString:self.provinceName];
       // return self.provinceName;
    }
    else if (1 == component){
        self.cityName = _cityArray[row][@"name"];
        NSLog(@"%@",self.cityName);
        return [self attributedStringFromString:self.cityName];
       // return self.cityName;
    }
    else{
        if ([self.districtArray isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)_districtArray;
            self.districtName = dic[@"name"];
        }else{
            self.districtName = self.districtArray[row][@"name"];
        }
        return [self attributedStringFromString:self.districtName];
       // return self.districtName;
    }
}

// 返回pickerView 每行的view 
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    label.attributedText = [self pickerView:pickerView attributedTitleForRow:row forComponent:component];
    //label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}


#pragma mark - ---------- 设置字体属性 -----------
//获得属性字体
- (NSAttributedString *)attributedStringFromString:(NSString *)string
{
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:string];
    //设置个别字体变色
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, 2)];
    //改变字体大小，必须要重写viewForRow才有效果
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(1, 1)];
    return attributeStr;
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


//- (NSMutableArray *)dataSource
//{
//    if (!_dataSource) {
//        _dataSource = [[NSMutableArray alloc]init];
//        
//        
//        for (int i = 0; i < 10; i++) {
//            NSMutableDictionary *dicc = [[NSMutableDictionary alloc]init];
//            NSMutableArray *array = [[NSMutableArray alloc]init];
//            for (int j = 0; j < 10; j++) {
//                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//                NSMutableArray *arr = [[NSMutableArray alloc]init];
//                for (int k = 0; k < 5; k++) {
//                    NSString *str = [NSString stringWithFormat:@"%d%d%d",i,j,k];
//                    [arr addObject:str];
//                }
//                [dic setObject:arr forKey:[NSString stringWithFormat:@"%d%d",i,j]];
//                [array addObject:dic];
//            }
//            [dicc setObject:array forKey:[NSString stringWithFormat:@"%d",i]];
//            [_dataSource addObject:dicc];
//        }
//    }
//    return _dataSource;
//}






@end
