//
//  JpsDatePickerView.h
//  JPSStandardDemo
//
//  Created by jps on 2017/4/1.
//  Copyright © 2017年 jps. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ValueCallBack)(NSString *valueStr);

@interface JpsDatePickerView : UIView
{
    ValueCallBack _valueCallBack;
}


@property(nonatomic,strong)UILabel *tipsLabel;    //!<提示标题


- (void)setValueCallBack:(ValueCallBack)callBack;

@end
