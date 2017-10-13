//
//  MainDetailCell.m
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MainDetailCell.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
@interface MainDetailCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *repalyBtn;
//@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (nonatomic,strong)AVAudioPlayer * audioPlayer;
@property (nonatomic,strong)AVPlayer * avPlayer;

@end

@implementation MainDetailCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _headerImg.layer.cornerRadius = 25;
    _headerImg.layer.masksToBounds = YES;
}


//回复
- (IBAction)replay:(id)sender {
 
}

-(void)setModel:(AbjcModel *)model{
    if (model) {
        _model = model;
        //医生的回答
        if ([model.z_time isEqualToString:@""] || [model.z_time isEqual:[NSNull null]] || !model.z_time) {
            NSString * url = [NSString stringWithFormat:@"http://yxtest.xgyuanda.com/Public/upload/fzml/%@",model.d_images];
            [_headerImg sd_setImageWithURL:[NSURL URLWithString:url]];
            _nameLab.text = model.d_doctor;
            _timeLab.text = model.d_time;
            _contentLab.text = model.d_content;
            _repalyBtn.hidden = YES;
            if ([model.doc_statu isEqualToString:@"1"]) {
                _audioBg.hidden = NO;
            }else{
                 _audioBg.hidden = YES;
            }
        }else{
             [_headerImg sd_setImageWithURL:[NSURL URLWithString:model.u_image]];
            _nameLab.text = model.weixin_name;
            _timeLab.text = model.z_time;
            
//            NSString * str = @"比较开始大把附近宽度设备空间分布当升科技发布到数据库部分接口打撒发布的撒部分接口大撒把你放假看电视发迪桑娜复健科打谁那就开发那段时间看风景看电视 范德萨控江路弄发动机昆士兰 发士大夫打扫哪了开发考虑的撒法第三开了房三大";
            _contentLab.text =  model.content;
        }
       
        
    }
}
- (IBAction)play:(id)sender {
    if (!!_model) {
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        //设置为播放和录音状态，以便可以在录制完之后播放录音
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [audioSession setActive:YES error:nil];
        NSString * urlStr = [NSString stringWithFormat:@"http://yxtest.xgyuanda.com/Public/upload/re_yuyin/%@",_model.d_content];
        NSLog(@"%@",urlStr);
        NSURL *url = [NSURL URLWithString:urlStr];
        
        //创建播放器
        _avPlayer = [[AVPlayer alloc] initWithURL:url];
        
        [_avPlayer play];
        
        //创建音乐播放器
//        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//
//        //根据URL地址来读取音乐文件（写在ViewDidLoad中会自动播放）
//        [_audioPlayer prepareToPlay];
//        [_audioPlayer play];
    }
}

-(void)setModela:(AbjaModel *)modela{
    if (modela) {
        _modela = modela;
        _repalyBtn.hidden = YES;
        [_headerImg sd_setImageWithURL:[NSURL URLWithString:modela.u_image]];
        _nameLab.text = modela.weixin_name;
        _timeLab.text = modela.z_time;
     
//        _contentLab.text = str;//model.content;
        _contentLab.text = modela.content;
    }
}

-(void)setModelb:(AbjbModel *)modelb{
    if (modelb) {
        _modelb = modelb;
        NSString * url = [NSString stringWithFormat:@"http://yxtest.xgyuanda.com/Public/upload/fzml/%@",modelb.d_images];
        [_headerImg sd_setImageWithURL:[NSURL URLWithString:url]];
        _nameLab.text = modelb.d_doctor;
        _timeLab.text = modelb.d_time;
        _contentLab.text = modelb.d_content;
        _repalyBtn.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
