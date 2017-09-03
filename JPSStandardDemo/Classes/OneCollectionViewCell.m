//
//  OneCollectionViewCell.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/31.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "OneCollectionViewCell.h"
#import "JpsButton.h"

@interface OneCollectionViewCell ()

@property(nonatomic,strong)UIImageView *imageV;
@property(nonatomic,strong)UILabel *label;

@end

@implementation OneCollectionViewCell


//这个方法方法只会走一次，复用cell的时候是不走的
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.bounds.size.width-40, self.bounds.size.height-30-40)];
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageV];
        
        self.label = [[UILabel alloc]init];
        self.label.adjustsFontSizeToFitWidth = YES;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.imageV.mas_bottom);
            make.left.mas_equalTo(self.mas_left).offset(0);
            make.right.mas_equalTo(self.mas_right).offset(0);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
    }
    return self;
}


//不写set方法，layout就只有第一次会走。第3个cell是最后放进去的，在最上面，第一个cell取最上面的复用，就去到了第3个，这就是为什么第0个会和第3个互换的原因。
- (void)layoutSubviews
{
//    self.imageV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.bounds.size.width-40, self.bounds.size.height-30-40)];
////    self.imageV.image = self.image;
//    self.imageV.contentMode = UIViewContentModeScaleAspectFit;
//    [self.contentView addSubview:self.imageV];
////
////    
//    self.label = [[UILabel alloc]init];
////    self.label.adjustsFontSizeToFitWidth = YES;
////    self.label.text = self.title;
//    self.label.textAlignment = NSTextAlignmentCenter;
//    [self.contentView addSubview:self.label];
////
//    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.imageV.mas_bottom);
//        make.left.mas_equalTo(self.mas_left).offset(0);
//        make.right.mas_equalTo(self.mas_right).offset(0);
//        make.bottom.mas_equalTo(self.mas_bottom);
//    }];
    
    DLog(@"...%@",self.title);
}






/*
 执行顺序，先走set方法，再走layoutSubviews
 先把set的12个值都赋完了（0->11）顺序，再走12次layoutSubview（11->0）逆序
 还有就是，走一个initWithFrame，然后走一个set，再走一个set，直到这两个走完了才最后一次性逆序走完layout
 */

//控件的赋值必须放倒set里，1）如果放到initframe里，则赋不上值。2）如果放到layout里，第一次正常，当向上滑动再松手，第一行在此复用的时候，第0个cell和第3个cell的图片和标题就会互换。原因如上，跟方法的执行顺序有关。

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageV.image = image;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.label.text = title;
}



@end
