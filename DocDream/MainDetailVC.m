//
//  MainDetailVC.m
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MainDetailVC.h"
#import "MainDetailCell.h"
#import <AFNetworking.h>
#import <JSONModel.h>
#import "MainModel.h"
#import "MainDetailModel.h"
#import "ReplyVC.h"
#import "AudioRecorderVC.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"
@interface MainDetailVC ()<UITableViewDelegate,UITableViewDataSource,AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray * dataSource;
@property (nonatomic,strong) MainDetailModel * myModel;
@property (nonatomic,strong) AFHTTPSessionManager * httpMgr;


@property (nonatomic,strong) AVAudioRecorder * audioRecorder;
@property (nonatomic,strong)  AVAudioSession * session ;
@property (nonatomic,strong) AVAudioPlayer * audioPlayer;


@property (weak, nonatomic) IBOutlet UIButton *audioBtn;

@end

@implementation MainDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"问答详情";
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerNib:[UINib nibWithNibName:@"MainDetailCell" bundle:nil] forCellReuseIdentifier:@"MainDetailCell"];
    [self loadData];
    [self creatFooterView];
    
    [self setAudioBtn];

    [self setAudioSession];
    
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
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
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
        NSURL *url=[self getSavePath];
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

//语音按钮
-(void)setAudioBtn{
    // 开始
    [_audioBtn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    // 取消
    [_audioBtn addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchUpOutside];
    //完成
    [_audioBtn addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
   
}

//创建底部视图
-(void)creatFooterView{
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, 44)];
    
    UIButton * reply = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, 44)];
    reply.center = footerView.center;
    reply.layer.cornerRadius = 8;
    reply.layer.masksToBounds = YES;
    [reply setTitle:@"回复" forState:UIControlStateNormal];
    reply.backgroundColor = [UIColor blueColor];
    [reply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [reply addTarget:self action:@selector(reply:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:reply];
//    self.myTableView.tableFooterView = footerView;
}

//回复
-(void)reply:(UIButton *)sender{
    
}
//文本回复
- (IBAction)textReply:(id)sender {
    ReplyVC * replyVc =[[ReplyVC alloc] init];
    replyVc.doc_id = self.doc_id;
    replyVc.qustion_id = [self.myModel.abja.ID integerValue];
    [self.navigationController pushViewController:replyVc animated:YES];
    
}
//语音回复
- (IBAction)audioReply:(id)sender {
}

//创建头部UI
-(void)createTableHeaderUI{
    MainDetailCell * header = [[[NSBundle mainBundle] loadNibNamed:@"MainDetailCell" owner:self options:nil] lastObject];
   CGFloat height =  [self.myModel.abja.content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 18, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} context:nil].size.height + 74;
    
    header.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height);
    header.modela = self.myModel.abja;
    self.myTableView.tableHeaderView = header;
    
}

-(void)loadData{
    _httpMgr = [AFHTTPSessionManager manager];
    _httpMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString * url = [NSString stringWithFormat:@"http://yxtest.xgyuanda.com/Api/index/wenda_xq?id=%ld",_model.ID];
    [_httpMgr GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        self.myModel = [[MainDetailModel alloc] initWithDictionary:dict error:nil];
        NSLog(@"dataSource = %@",self.myModel);
        [self createTableHeaderUI];
        [self.myTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView 代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_myModel.abjb.count > 0) {
            return 1;
        }else{
            return 0;
        }
    }else{
         return _myModel.abjc.count;
    }
   
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  MainDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainDetailCell"];
    if (indexPath.section == 0) {
        AbjbModel * model = self.myModel.abjb[indexPath.row];
        
        cell.modelb = model;
    }else{
        AbjcModel * model = self.myModel.abjc[indexPath.row];
//            CGRect oldFream = cell.contentView.frame;
//            oldFream.size.width -= 100;
//            oldFream.origin.x = 100;
//
//            cell.contentView.frame = oldFream;
        cell.contentView.layoutMargins = UIEdgeInsetsMake(8, 70, 8, 0);
       
//        cell.contentLab.layoutMargins = UIEdgeInsetsMake(0, 70, 8, 0);
        cell.model = model;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
    }
    

   
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma 懒加载
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


#pragma  语音部分
- (void)recordStart:(UIButton *)button
{
    [button setTitle:@"录制中" forState:UIControlStateNormal];
    NSLog(@"UIControlEventTouchDown---recordStart");
    [self startRecord];
}

- (void)startRecord
{
    
    AudioRecorderVC * vc = [[AudioRecorderVC alloc] init];
    vc.doc_id = self.doc_id;
    vc.qustion_id = [self.myModel.abja.ID integerValue];
    [self.navigationController pushViewController:vc animated:YES];
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
//    self.session = [AVAudioSession sharedInstance];
//    NSError * sessionError;
//
//    //控制当前录音播放的时候其他音频是关闭的状态。否则无法播放
//    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
//    if (sessionError) {
//        NSLog(@"error : %@ ",sessionError.localizedDescription);
//    }else{
//        [_session setActive:YES error:nil];
//    }
//
//    //录音文件保存路径
//    //获取一个沙盒的Document的路劲   lastObject 指的是Document文件夹 NSUserDomainMask指当前的APP的沙盒中去查找。
//    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    urlStr=[urlStr stringByAppendingPathComponent:@"voice_corder.caf"];
//    NSLog(@"file path:%@",urlStr);
////    NSURL *url=[NSURL fileURLWithPath:urlStr];
////    NSString * str = NSHomeDirectory();
////    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
////    //给录音取个名字
////    NSLog(@"%@,%@",str,url);
//    NSURL * voiceUrl = [NSURL fileURLWithPath:urlStr];
//    //配置 audioRecorder
//    NSDictionary * recordSet = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,//录音质量
//
//                                [NSNumber numberWithInt:16],AVEncoderBitRateKey,//编码率
//
//                                [NSNumber numberWithInt:2],AVNumberOfChannelsKey,//
//
//                                [NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
//    NSError *error;
//
//    self.audioRecorder=[[AVAudioRecorder alloc] initWithURL:voiceUrl settings:recordSet error:&error];
//    //开启音量检测
//
//    self.audioRecorder.delegate = self;
//
////        if (![ self.audioRecorder isRecording]) {
////            [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音
////            [_session setActive:YES error:nil];//启动音频会话管理,此时会阻断后台音乐的播放.
////
////            [ self.audioRecorder prepareToRecord];
////            [ self.audioRecorder peakPowerForChannel:0.0];
////            [ self.audioRecorder record];
////        }
//    if (error) {
//        NSLog(@" audiorecorder error:%@",error.localizedDescription);
//
//    } else {
//        if ([self.audioRecorder prepareToRecord]) {
//            NSLog(@"recorder is ready!");
//             self.audioRecorder.meteringEnabled = YES;
//             [self.audioRecorder record];
//        }else{
//             NSLog(@"FlyElephant--初始化录音失败");
//        }
//    }
//    if (![self.audioRecorder isRecording]) {
//        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
//
//    }
}

- (void)recordCancel:(UIButton *)button
{
    
    [self.audioBtn setTitle:@"重新录制" forState:UIControlStateNormal];
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
   
}

- (IBAction)playRecorder:(id)sender {
//   _session = [AVAudioSession sharedInstance];
//    [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    if (self.audioPlayer.playing) {
//
//        [self.audioPlayer stop];
//
//    }else{
//        NSError *error=nil;
////
//
//        self.audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url  error:&error];
//        [_audioPlayer prepareToPlay];
//
//        NSData * audioData = [NSData dataWithContentsOfURL:self.audioRecorder.url];
//        NSLog(@"audioData = %@",audioData);
//        [self.audioPlayer play];
//
//        NSLog(@"begin play!");
//
//        NSLog(@"%@",self.audioRecorder.url);
//
//    }
//    if (!_audioPlayer) {
//        NSURL *url=[self getSavePath];
//        NSError *error=nil;
//        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
//        _audioPlayer.numberOfLoops=0;
//        [_audioPlayer prepareToPlay];
//        if (error) {
//            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
//            return nil;
//        }
//    }
//    return _audioPlayer;
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    if (![self.audioPlayer isPlaying]) {
//        [self.audioPlayer play];
//    }
    NSLog(@"录音完成!");
}


@end
