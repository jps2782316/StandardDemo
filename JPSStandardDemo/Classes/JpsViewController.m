//
//  JpsViewController.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/7/8.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>//指纹登录

@interface JpsViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation JpsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordField.secureTextEntry = YES;
    
    
    
}


#pragma mark - ---------- Action -----------

//普通登录
- (IBAction)loginClick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil userInfo:nil];
    
}

//指纹登录
- (IBAction)touchIDLoginClick:(id)sender {
    
    [self touchIDAuthentication];
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




#pragma mark - ---------- Others -----------

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.secureTextEntry) {
        self.imageView.image = [UIImage imageNamed:@"login_header_cover_eyes"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"login_header"];
    }
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



@end
