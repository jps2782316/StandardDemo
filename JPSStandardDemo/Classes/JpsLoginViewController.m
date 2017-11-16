//
//  JpsLoginViewController.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/9/2.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsLoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>//指纹登录

@interface JpsLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation JpsLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@"QQ账号"];
    [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, 4)];
    self.userNameField.attributedPlaceholder = attributedString;
    [self.passwordField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
    //验证字典里的打印是否为unicode
    [self unicodeTest];
}



#pragma mark - ---------- Action -----------

- (IBAction)loginClick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil userInfo:nil];
}



#pragma mark - ---------- Others -----------

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchIDAuthentication];
}

//重写打印方法后，测试字典、数组里打印的是否还为unicode
- (void)unicodeTest
{
    NSArray *tempArr = @[@"中文", @"中文"];
    NSLog(@"%@", tempArr);
    
    NSDictionary *tempDic = @{@"啊":@"嗷嗷"};
    
    NSDictionary *dictionary = @{@"哈哈":@"秘密", @"咪咪":@"秘密", @"字典":tempDic, @"数组":tempArr};
    NSLog(@"%@", dictionary);
    
    NSArray *array = @[@"哈哈",@"哈哈",dictionary];
    NSLog(@"%@",array);
}


#pragma mark - ---------- 指纹登录 -----------

//http://www.jianshu.com/p/85689f7f183e
//http://www.tuicool.com/articles/7NRzYn
//判断手机是否支持指纹识别，我们要使用到一个LAContext类
- (void)touchIDAuthentication
{
    LAContext *context = [[LAContext alloc]init];
    NSError *error = nil;
    // 判断设备是否支持指纹识别
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // 输入指纹 - 回调是异步的
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"验证touchID" reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {  //不管是手动输密码还是按指纹，都会走这里
                NSLog(@"TouchID验证成功...");
                
                //block是子线程，更改根控制器属于UI操作，所以这个更改根控制器的通知必须放在主线程中，不然崩溃    http://www.jianshu.com/p/eb86f32bedd4
                dispatch_async(dispatch_get_main_queue(), ^{
                    //验证成功，可以登录，发送通知，更改根控制器
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil userInfo:nil];
                });
                
            }
            else{//点取消会走这里
                NSLog(@"TouchID验证失败:%@",error.description);
                // 判断错误类型是否是主动自行输入密码
                if (error.code == LAErrorUserFallback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //密码验证方法
                        
                    });
                }
            }
        }];
    }else{
        NSLog(@"设备不支持指纹识别...");
    }
}




@end
