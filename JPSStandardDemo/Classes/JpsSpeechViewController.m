//
//  JpsSpeechViewController.m
//  JPSStandardDemo
//
//  Created by 金平生 on 2017/8/19.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "JpsSpeechViewController.h"
//语音识别
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

//文本转语音
#import<AVFoundation/AVSpeechSynthesis.h>

@interface JpsSpeechViewController ()<SFSpeechRecognizerDelegate,AVSpeechSynthesizerDelegate>
{
    
    AVSpeechSynthesizer *_av;  //语音合成器  （文本转语音对象）
    
}

@property (weak, nonatomic) IBOutlet UIButton *recognizeBtn; //识别时的录制按钮
@property (weak, nonatomic) IBOutlet UITextView *recognizeResultTextView; //识别结果展示
@property(nonatomic,strong)SFSpeechRecognitionTask *recognitionTask; //!<语音识别任务
@property(nonatomic,strong)SFSpeechRecognizer *speechRecgnizer;  //!<语音识别器
@property(nonatomic,strong)SFSpeechAudioBufferRecognitionRequest *recognitionRequest;  //!<识别请求
@property(nonatomic,strong)AVAudioEngine *audioEngine;  //!<录音引擎



@property (weak, nonatomic) IBOutlet UITextField *speekTextField;
@property (weak, nonatomic) IBOutlet UIButton *speekBtn;

@end

@implementation JpsSpeechViewController

#pragma mark - ---------- ios可配置权限 -----------

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
    
    [self recognition];
    
}



#pragma mark - ---------- Action -----------

- (IBAction)recgnizeClick:(id)sender {  //microphoneClick
    
    if ([self.audioEngine isRunning]) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.recognizeBtn.enabled = YES;
        [self.recognizeBtn setTitle:@"开始录制" forState:UIControlStateNormal];
    }else{
        [self startRecording];
        [self.recognizeBtn setTitle:@"停止录制" forState:UIControlStateNormal];
    }
    
}


- (IBAction)speeckClick:(id)sender {
    
    
    [self start:sender];
}



#pragma mark - ---------- 语音转文本 -----------
#pragma mark - ---------- 初始化语音识别器 -----------

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
    self.recognizeBtn.enabled = false;
    
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
        
        self.recognizeBtn.enabled = btnEnable;
    }];
    
    //创建录音引擎
    self.audioEngine = [[AVAudioEngine alloc] init];
}


#pragma mark - ---------- SFSpeechRecognizerDelegate -----------

//SFSpeechRecognizerDelegate协议中只约定了一个方法，如下:
//当语音识别操作可用性发生改变时会被调用
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available
{
    if (available) {
        self.recognizeBtn.enabled = YES;
    }else{
        self.recognizeBtn.enabled = NO;
    }
}



#pragma mark - ---------- 开始录制语音，并将语音转为文本 -----------

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
            self.recognizeResultTextView.text = [[result bestTranscription] formattedString];  //语音转文本
            isFinal = [result isFinal];
        }
        if (error || isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            self.recognizeBtn.enabled = YES;
        }
    }];
    // 监听一个标识位并拼接流文件
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    
    [inputNode removeTapOnBus:0];  //不清除这个第二次点击会崩， ..tap is nil
    
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    // 准备并启动引擎
    [self.audioEngine prepare];
    NSError *error = nil;
    if (![self.audioEngine startAndReturnError:&error]) {
        NSLog(@"%@",error.userInfo);
    };
    self.recognizeResultTextView.text = @"等待命令中.....";
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





#pragma mark - ---------- 文本转语音 -----------

//http://www.jianshu.com/p/d9515ceecf91
//http://blog.csdn.net/andanlan/article/details/52347595
//http://blog.csdn.net/zclengendary/article/details/52536171

//http://www.jianshu.com/p/006eb4c06b85

//文本转语音http://www.jianshu.com/p/9cd581e53256。
-(void)start:(UIButton*)sender{
    
    if(sender.selected==NO) {
        
        if([_av isPaused] && self.speekTextField.text.length == 0) {
            
            //如果暂停则恢复，会从暂停的地方继续
            
            [_av continueSpeaking];
            
            sender.selected=!sender.selected;
            
        }else{
            
            //初始化对象
            
            _av= [[AVSpeechSynthesizer alloc]init];  //语音合成器, 可以假想成一个可以说话的人
            
            _av.delegate=self;//挂上代理
            
            NSString *string = @"锦瑟无端五十弦，一弦一柱思华年。庄生晓梦迷蝴蝶，望帝春心托杜鹃。沧海月明珠有泪，蓝田日暖玉生烟。此情可待成追忆，只是当时已惘然。"; //标点符号会产生朗读时的停顿, 这样就有节奏了
            if (self.speekTextField.text.length > 0) {
                string = self.speekTextField.text;
            }
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:string];//需要转换的文字
            
            utterance.pitchMultiplier = 1; // [0.5 - 2] Default = 1，声调，不怕逗死你就设成2
            utterance.volume = 1; // [0-1] Default = 1，音量
            utterance.rate=0.5; // 设置语速，范围0-1，注意0最慢，1最快；AVSpeechUtteranceMinimumSpeechRate最慢，AVSpeechUtteranceMaximumSpeechRate最快
            
            
            AVSpeechSynthesisVoice*voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置发音，这是中文普通话
            
            utterance.voice= voice;
            
            //发音
            [_av speakUtterance:utterance];//开始
            
            sender.selected=!sender.selected;
            
        }
        
    }else{
        
        //[av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
        
        [_av pauseSpeakingAtBoundary:AVSpeechBoundaryWord];//暂停 //暂停播放，将会保存进度
        
        sender.selected=!sender.selected;
        
    }
    
    //[utterance release];//需要关闭ARC
    
    //[av release];
    
}



#pragma mark - ---------- 下面是代理 -----------


- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didStartSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---开始播放");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---完成播放");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---播放中止");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---恢复播放");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---播放取消");
    
}



#pragma mark - ---------- LifeCircle -----------

- (void)viewWillDisappear:(BOOL)animated
{
    
    
    //[_av pauseSpeakingAtBoundary:AVSpeechBoundaryWord];    //暂停:这个方法不回走dealloc
    
    [_av stopSpeakingAtBoundary:AVSpeechBoundaryWord];   //停止:调用这个方法，才会走dealloc
    //_av = nil;
}


//要等语音输出结束了，才会走这个方法，如果暂停的话，输出就不会结束，这个控制器就一直不回销毁
- (void)dealloc
{
    DLog(@"dealloc");
}





@end
