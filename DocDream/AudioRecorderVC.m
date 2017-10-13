//
//  AudioRecorderVC.m
//  DocDream
//
//  Created by YDWY on 2017/10/12.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "AudioRecorderVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking.h>
#import "lame.h"
#import <UIView+Toast.h>
#define kRecordAudioFile @"myRecord.caf"


@interface AudioRecorderVC ()<AVAudioRecorderDelegate>
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (weak, nonatomic) IBOutlet UIButton *record;//开始录音
@property (weak, nonatomic) IBOutlet UIButton *pause;//暂停录音
@property (weak, nonatomic) IBOutlet UIButton *resume;//恢复录音
@property (weak, nonatomic) IBOutlet UIButton *stop;//停止录音
@property (weak, nonatomic) IBOutlet UIProgressView *audioPower;//音频波动
@property (nonatomic,strong) NSString * mp3FilePath;
@property (nonatomic,strong) NSString * cafFilePath;
@property (nonatomic,assign) BOOL status;


@end

@implementation AudioRecorderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setAudioBtn];

     [self setAudioSession];
}
//语音按钮
-(void)setAudioBtn{
    // 开始
    [_audioBtn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    // 取消
    [_audioBtn addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchUpOutside];
    //完成
    [_audioBtn addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 私有方法
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    _cafFilePath = urlStr;
   
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
//    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
//    //设置录音格式
//    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
//    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
//    [dicM setObject:@(8000) forKey:AVSampleRateKey];
//    //设置通道,这里采用单声道
//    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
//    //每个采样点位数,分为8、16、24、32
//    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
//    //是否使用浮点数采样
//    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
//    //....其他设置等
//    return dicM;
    NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey, [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                             [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                             [NSNumber numberWithFloat:44100.0], AVSampleRateKey, nil];
    return setting;
    

}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
//        NSURL *url=[self getSavePath];
        NSURL * url = [NSURL URLWithString:_mp3FilePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.audioPower setProgress:progress];
}
#pragma mark - UI事件
/**
 *  点击录音按钮
 *
 *  @param sender 录音按钮
 */
- (IBAction)recordClick:(UIButton *)sender {
//
//    [self.audioRecorder deleteRecording];
        NSFileManager *fileManager = [NSFileManager defaultManager];
    if(!!_cafFilePath){
        if ([NSTemporaryDirectory() stringByAppendingString:@"myRecord.caf"]) {
            [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingString:@"myRecord.caf"] error:nil];
        }
    }
    if(!!_mp3FilePath){
        if ([NSTemporaryDirectory() stringByAppendingString:@"myRecord.mp3"]) {
            [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingString:@"myRecord.mp3"] error:nil];
        }
    }
        
    
    if (![self.audioRecorder isRecording]) {


        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }
}

/**
 *  点击暂定按钮
 *
 *  @param sender 暂停按钮
 */
- (IBAction)pauseClick:(UIButton *)sender {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
}

/**
 *  点击恢复按钮
 *  恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 *
 *  @param sender 恢复按钮
 */
- (IBAction)resumeClick:(UIButton *)sender {
    [self recordClick:sender];
}

/**
 *  点击停止按钮
 *
 *  @param sender 停止按钮
 */
- (IBAction)stopClick:(UIButton *)sender {
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
    self.audioPower.progress=0.0;
}
- (IBAction)play:(id)sender {
    if (_mp3FilePath) {
        if (![self.audioPlayer isPlaying]) {
            [self.audioPlayer play];
        }
    }
    
  
    
    
    
}
- (IBAction)uploadAudio:(id)sender {
     NSURL *mp3Url=[self getSavePath];
//    NSURL *mp3Url =  [NSURL URLWithString:@"自己随便写个音频文件地址"];//本例子是将本地的 .caf 文件上传到服务器上面去
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg", nil];
    NSMutableDictionary *para = @{@"iid":[NSNumber numberWithInt:_qustion_id],@"did":[NSNumber numberWithInt:_doc_id],@"doc_statu":@"1"}.mutableCopy;
    [manager POST:@"http://yxtest.xgyuanda.com/Api/index/doctor_hui" parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //              application/octer-stream   audio/mpeg video/mp4   application/octet-stream
        
        /* url      :  本地文件路径
         * name     :  与服务端约定的参数
         * fileName :  自己随便命名的
         * mimeType :  文件格式类型 [mp3 : application/octer-stream application/octet-stream] [mp4 : video/mp4]
         */
        [formData appendPartWithFileURL:mp3Url name:@"img" fileName:@"yuyin.mp3" mimeType:@"multipart/form-data" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"上传进度-----   %f",progress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"上传成功 %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败 %@",error);
    }];
}

- (NSString *)getTimestamp{ NSDate *nowDate = [NSDate date]; double timestamp = (double)[nowDate timeIntervalSince1970]*1000;
    long nowTimestamp = [[NSNumber numberWithDouble:timestamp] longValue];
    NSString *timestampStr = [NSString stringWithFormat:@"%ld",nowTimestamp];
    return timestampStr;
    
}

-(void)upload{
    NSURL *mp3Url=[self getSavePath];
    //    NSURL *mp3Url =  [NSURL URLWithString:@"自己随便写个音频文件地址"];//本例子是将本地的 .caf 文件上传到服务器上面去
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg", nil];
    NSMutableDictionary *para = @{@"iid":[NSNumber numberWithInt:_qustion_id],@"did":[NSNumber numberWithInt:_doc_id],@"doc_statu":@"1"}.mutableCopy;
    [manager POST:@"http://yxtest.xgyuanda.com/Api/index/doctor_hui" parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //              application/octer-stream   audio/mpeg video/mp4   application/octet-stream
        
        /* url      :  本地文件路径
         * name     :  与服务端约定的参数
         * fileName :  自己随便命名的
         * mimeType :  文件格式类型 [mp3 : application/octer-stream application/octet-stream] [mp4 : video/mp4]
         */
        [formData appendPartWithFileURL:mp3Url name:@"img" fileName:@"yuyin.mp3" mimeType:@"multipart/form-data" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"上传进度-----   %f",progress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"上传成功 %@",responseObject);
        if(![responseObject[@"msg"] isEqualToString:@""]){
            [self.view makeToast:@"回复成功"
                        duration:2.0
                        position:CSToastPositionCenter] ;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败 %@",error);
    }];
}
- (NSString *)audioCAFtoMP3:(NSString *)wavPath {
    NSData *mp3Data = [NSData dataWithContentsOfFile:_mp3FilePath];
    if(mp3Data)
        {
            //如果有使用文件管理移除上一次录音文件
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:_mp3FilePath error:nil];
            NSData *mp3Data1 = [NSData dataWithContentsOfFile:_mp3FilePath];
            NSLog(@"%@",mp3Data1);
    //        [fm removeItemAtURL:[NSURL fileURLWithPath:_mp3FilePath] error:nil];
    //        [fm removeItemAtURL:[NSURL URLWithString:_cafFilePath] error:nil];
        }
    NSString *cafFilePath = wavPath ;
    NSString *mp3FilePath = [NSString stringWithFormat:@"%@.mp3",[NSString stringWithFormat:@"%@%@",[cafFilePath substringToIndex:cafFilePath.length - 4],[self getTimestamp]]];
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");//source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);  //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        lame_t lame = lame_init();
        lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_set_brate(lame,8);
        lame_set_mode(lame,3);
        lame_set_quality(lame,2);
        lame_init_params(lame);
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
            
        }
            while (read != 0);
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        
    } @finally {
        return mp3FilePath;
        
    }
    
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    NSLog(@"录音完成!");
    //装成mp3 文件
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    if (_status) {
          _mp3FilePath =  [self audioCAFtoMP3:urlStr];
        [self upload];
        
    }
  
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma 录音
- (void)recordStart:(UIButton *)button
{
    [button setTitle:@"录制中" forState:UIControlStateNormal];
    NSLog(@"UIControlEventTouchDown---recordStart");
    [self startRecord];
}

- (void)startRecord
{
    if (![self.audioRecorder isRecording]) {
        
        
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }

}
- (void)recordCancel:(UIButton *)button
{
    
    [self.audioBtn setTitle:@"重新录制" forState:UIControlStateNormal];
    NSLog(@"UIControlEventTouchDragExit 和 UIControlEventTouchUpOutside---recordCancel");
    
    [self endRecord];
}



- (void)endRecord
{
  [_audioRecorder deleteRecording];
    [_audioRecorder stop];             //录音停止
    self.status = NO;
  
    
}

- (void)recordFinish:(UIButton *)button
{
    NSLog(@"UIControlEventTouchUpInside---recordFinish");
    [button setTitle:@"完成" forState:UIControlStateNormal];
//    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
//    _mp3FilePath =  [self audioCAFtoMP3:urlStr];
     [_audioRecorder stop];
     self.status = YES;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
