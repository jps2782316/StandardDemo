//
//  ViewController.m
//  指纹登录
//
//  Created by 金平生 on 2017/7/2.
//  Copyright © 2017年 金平生. All rights reserved.
//

#import "SpeechViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>//指纹登录

//siri
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

@interface SpeechViewController ()<SFSpeechRecognizerDelegate>

@property(nonatomic,strong)UIButton *recordButton;  //!<siri按钮
@property(nonatomic,strong)UITextView *siriTextView; //!<显示语音转化成的文本

@property(nonatomic,strong)SFSpeechRecognitionTask *recognitionTask; //!<语音识别任务
@property(nonatomic,strong)SFSpeechRecognizer *speechRecgnizer;  //!<语音识别器
@property(nonatomic,strong)SFSpeechAudioBufferRecognitionRequest *recognitionRequest;  //!<识别请求

@property(nonatomic,strong)AVAudioEngine *audioEngine;  //!<录音引擎




@end

@implementation SpeechViewController



//麦克风权限：Privacy - Microphone Usage Description 是否允许此App使用你的麦克风？
//相机权限： Privacy - Camera Usage Description 是否允许此App使用你的相机？
//相册权限： Privacy - Photo Library Usage Description 是否允许此App访问你的媒体资料库？通讯录权限： Privacy - Contacts Usage Description 是否允许此App访问你的通讯录？
//蓝牙权限：Privacy - Bluetooth Peripheral Usage Description 是否许允此App使用蓝牙？
//
//语音转文字权限：Privacy - Speech Recognition Usage Description 是否允许此App使用语音识别？
//日历权限：Privacy - Calendars Usage Description 是否允许此App使用日历？
//
//定位权限：Privacy - Location When In Use Usage Description 我们需要通过您的地理位置信息获取您周边的相关数据
//定位权限: Privacy - Location Always Usage Description 我们需要通过您的地理位置信息获取您周边的相关数据


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 90, 40)];
    [self.recordButton setTitle:@"点击开始录音" forState:UIControlStateNormal];
    [self.recordButton setBackgroundColor:[UIColor blueColor]];
    [self.recordButton addTarget:self action:@selector(microphoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
    
    self.siriTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 200, 300, 350)];
    self.siriTextView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.siriTextView];
    
    
    
    
    [self recognition];
    
    
    
    
}





//https://stackoverflow.com/questions/26728250/avaudioengine-crashes-when-plug-headphones-in-or-out

//http://www.jianshu.com/p/a9c64ac2c586





#pragma mark - ---------- siri -----------

//http://www.open-open.com/lib/view/open1486532671472.html
//http://www.cnblogs.com/XYQ-208910/p/6001495.html
//语音识别技术
//首先需要在plist文件中申请语音识别和麦克风使用权限：
//注意    iOS语音识别Api只支持iOS10SDK以及以后的版本，开发工具至少要Xcode8.0。
//它是使用Siri里面的一个语音识别框架Speech framework来处理siri的. iOS语音识别SDK的用法

//语音识别
- (void)recognition
{
    //设备识别语言为中文
    NSLocale *cale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    self.speechRecgnizer = [[SFSpeechRecognizer alloc] initWithLocale:cale];
    self.recordButton.enabled = false;
    
    //设置代理
    self.speechRecgnizer.delegate = self;
    
    //发送语音认证请求（首先要判断设备是否支持语音识别功能）
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL btnEnable = NO;
        
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
            {
                btnEnable = YES;
                NSLog(@"可以语音识别");
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
            {
                btnEnable = NO;
                NSLog(@"被用户拒绝访问语音识别");
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
            {
                btnEnable = NO;
                NSLog(@"不能在该设备上进行语音识别");
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            {
                btnEnable = NO;
                NSLog(@"没有授权语音识别");
            }
                break;
                
            default:
                break;
        }
        
        self.recordButton.enabled = btnEnable;
    }];
   
    //创建录音引擎
    self.audioEngine = [[AVAudioEngine alloc] init];
}


- (void)microphoneClick:(UIButton *)sender
{
    if ([self.audioEngine isRunning]) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.recordButton.enabled = YES;
        [self.recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    }else{
        [self startRecording];
        [self.recordButton setTitle:@"停止录制" forState:UIControlStateNormal];
    }
}



/**
 开始录制语音，并将语音转为文本
 */
- (void)startRecording
{
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL b1 = [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    BOOL b2 = [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    BOOL b3 = [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (b1 || b2 || b3) {
        NSLog(@"可以使用");
    }else{
         NSLog(@"这里说明有的功能不支持");
    }
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    //开始识别任务
    self.recognitionTask = [self.speechRecgnizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            self.siriTextView.text = [[result bestTranscription] formattedString];  //语音转文本
            isFinal = [result isFinal];
        }
        if (error || isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            self.recordButton.enabled = YES;
        }
    }];
    
    
    // 监听一个标识位并拼接流文件
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode removeTapOnBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    
    // 准备并启动引擎
    [self.audioEngine prepare];
    NSError *error = nil;
    if (![self.audioEngine startAndReturnError:&error]) {
        NSLog(@"%@",error.userInfo);
    };
    self.siriTextView.text = @"等待命令中.....";
    
//    // 准备并启动引擎
//    [self.audioEngine prepare];
//    BOOL audioEngineBool = [self.audioEngine startAndReturnError:nil];
//    NSLog(@"%d",audioEngineBool);
//    self.siriTextView.text = @"等待命令中.....";
}



//SFSpeechRecognizerDelegate协议中只约定了一个方法，如下:
//当语音识别操作可用性发生改变时会被调用
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available
{
    if (available) {
        self.recordButton.enabled = YES;
    }else{
        self.recordButton.enabled = NO;
    }
}


//http://www.jb51.net/article/93599.htm
 //通过Block回调的方式进行语音识别请求十分简单，如果使用代理回调的方式，开发者需要实现SFSpeechRecognitionTaskDelegate协议中的相关方法，如下：
//当开始检测音频源中的语音时首先调用此方法
//- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task;
////当识别出一条可用的信息后 会调用
///*
// 需要注意，apple的语音识别服务会根据提供的音频源识别出多个可能的结果 每有一条结果可用 都会调用此方法
// */
//- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription;
////当识别完成所有可用的结果后调用
//- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult;
////当不再接受音频输入时调用 即开始处理语音识别任务时调用
//- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task;
////当语音识别任务被取消时调用
//- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task;
////语音识别任务完成时被调用
//- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully;








#pragma mark - ---------- 本地音频识别 -----------

- (void)recognizeLocal
{
    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    SFSpeechRecognizer *localRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
    NSURL *url =[[NSBundle mainBundle] URLForResource:@"录音.m4a" withExtension:nil];
    if (!url) return;
    SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
    [localRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"语音识别解析失败,%@",error);
        }
        else
        {
           // self.resultStringLable.text = result.bestTranscription.formattedString;
            NSLog(@"%@",result.bestTranscription.formattedString);
        }
    }];
}







- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
  //  [self touchIDAuthentication];
    
    
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
                NSLog(@"验证成功");
            }
            else{//点取消会走这里
                NSLog(@"验证失败:%@",error.description);
                // 判断错误类型是否是主动自行输入密码
                if (error.code == LAErrorUserFallback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //密码验证方法
                        
                    });
                }
            }
        }];
    }else{
        NSLog(@"设备不支持");
    }
}






@end
