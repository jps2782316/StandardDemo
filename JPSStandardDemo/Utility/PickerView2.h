//
//  PickerView2.h
//  PickerView
//
//  Created by 金平生 on 2017/6/25.
//  Copyright © 2017年 金平生. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ValueCallBack)(NSString *valueStr);

@interface PickerView2 : UIView
{
    ValueCallBack _valueCallBack;
}

@property(nonatomic,strong)UILabel *tipsLabel;


//@property(nonatomic,strong)NSMutableArray *dataSource;


- (void)setValueCallBack:(ValueCallBack)callBack;


@end
