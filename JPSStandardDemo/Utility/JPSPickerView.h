//
//  JPSPickerView.h
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/3/8.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ValueCallBack)(NSString *valueStr);

@interface JPSPickerView : UIView
{
    ValueCallBack _valueCallBack;
}

@property(nonatomic,strong)NSArray *dataSource;

@property(nonatomic,strong)UILabel *tipsLabel;


- (void)setValueCallBack:(ValueCallBack)callBack;



@end
