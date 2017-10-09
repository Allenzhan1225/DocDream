//
//  ViewController.m
//  DocDream
//
//  Created by YDWY on 2017/10/9.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
//录制音频按钮
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
//播放音频按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,strong) AVAudioRecorder * audioRecorder;
@property (nonatomic,strong)  AVAudioSession * session ;
@property (nonatomic,strong) AVAudioPlayer * audioPlayer;
@property (nonatomic,strong) AFHTTPSessionManager * httpMgr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _recordButton.backgroundColor = [UIColor redColor];
    // 开始
    [_recordButton addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    // 取消
    [_recordButton addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchUpOutside];
    //完成
    [_recordButton addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordButton];
    _recordButton.layer.cornerRadius = 50;  
}

- (void)recordStart:(UIButton *)button
{
    [self.indicator startAnimating];
    [button setTitle:@"录制中" forState:UIControlStateNormal];
    NSLog(@"UIControlEventTouchDown---recordStart");
    [self startRecord];
}

- (void)startRecord
{
    //删除上次生成的文件，保留最新文件
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([NSTemporaryDirectory() stringByAppendingString:@"myselfRecord.mp3"]) {
//        [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingString:@"myselfRecord.mp3"] error:nil];
//    }
//    if ([NSTemporaryDirectory() stringByAppendingString:@"selfRecord.wav"]) {
//        [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingString:@"selfRecord.wav"] error:nil];
//    }
//
//    //开始录音
//    //录音设置
//    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
//    //设置录音格式 AVFormatIDKey==kAudioFormatLinearPCM
//    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
//    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
//    //录音通道数 1 或 2 ，要转换成mp3格式必须为双通道
//    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//    //线性采样位数 8、16、24、32
//    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    //录音的质量
//    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
//
//    //存储录音文件
//    recordUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"selfRecord.wav"]];
//
//    //初始化
//    audioRecorder = [[AVAudioRecorder alloc] initWithURL:recordUrl settings:recordSetting error:nil];
//    //开启音量检测
//    audioRecorder.meteringEnabled = YES;
//    audioSession = [AVAudioSession sharedInstance];//得到AVAudioSession单例对象
//
//    if (![audioRecorder isRecording]) {
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音
//        [audioSession setActive:YES error:nil];//启动音频会话管理,此时会阻断后台音乐的播放.
//
//        [audioRecorder prepareToRecord];
//        [audioRecorder peakPowerForChannel:0.0];
//        [audioRecorder record];
//    }
    
   //音频设备
    self.session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    
    //控制当前录音播放的时候其他音频是关闭的状态。否则无法播放
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (sessionError) {
        NSLog(@"error : %@ ",sessionError.localizedDescription);
    }else{
        [_session setActive:YES error:nil];
    }
    
    //录音文件保存路径
    //获取一个沙盒的Document的路劲   lastObject 指的是Document文件夹 NSUserDomainMask指当前的APP的沙盒中去查找。
    
    NSString * str = NSHomeDirectory();
    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //给录音取个名字
    NSLog(@"%@,%@",str,url);
    NSURL * voiceUrl = [url URLByAppendingPathComponent:@"voice_corder.wav"];
    //配置 audioRecorder
    NSDictionary * recordSet = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,//录音质量
                                
                                [NSNumber numberWithInt:16],AVEncoderBitRateKey,//编码率
                                
                                [NSNumber numberWithInt:2],AVNumberOfChannelsKey,//
                                
                                [NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    NSError *error;
    
    self.audioRecorder=[[AVAudioRecorder alloc] initWithURL:voiceUrl settings:recordSet error:&error];
    
    if (error) {
        NSLog(@" audiorecorder error:%@",error.localizedDescription);
        
    } else {
        if ([self.audioRecorder prepareToRecord]) {
            NSLog(@"recorder is ready!");
        }
    }
}

- (void)recordCancel:(UIButton *)button
{
  
    [self.recordButton setTitle:@"重新录制" forState:UIControlStateNormal];
    NSLog(@"UIControlEventTouchDragExit 和 UIControlEventTouchUpOutside---recordCancel");
    
    [self endRecord];
}



- (void)endRecord
{
    [_audioRecorder stop];             //录音停止
    [self.session setActive:NO error:nil];     //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
}

- (void)recordFinish:(UIButton *)button
{
    NSLog(@"UIControlEventTouchUpInside---recordFinish");
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [self.indicator stopAnimating];
}
- (IBAction)playRecorder:(id)sender {
    if (self.audioPlayer.playing) {
        
        [self.audioPlayer stop];
        
    }else{
        NSError *error=nil;
        self.audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
        [_audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        NSLog(@"begin play!");
        
        NSLog(@"%@",self.audioRecorder.url);
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
