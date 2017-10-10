//
//  MainCell.m
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MainCell.h"
#import "MainModel.h"
#import <UIImageView+WebCache.h>
@interface MainCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerimg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIImageView *docImg;
@property (weak, nonatomic) IBOutlet UILabel *answerStatus;

@end

@implementation MainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _headerimg.layer.cornerRadius = 30;
    _headerimg.layer.masksToBounds = YES;
    _docImg.layer.cornerRadius = 15;
    _docImg.layer.masksToBounds = YES;
}

-(void)setModel:(MainModel *)model{
    if (model) {
        _model = model;
        [_headerimg sd_setImageWithURL:[NSURL URLWithString:_model.u_image]];
        _nameLab.text = _model.weixin_name;
        _contentLab.text = _model.content;
        _timeLab.text = _model.z_time;
        
        [_docImg sd_setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://yxtest.xgyuanda.com/Public/upload/fzml/%@",_model.d_images ] ]];
        _answerStatus.text = _model.d_id == 0 ? @"未回答":@"已回答";
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
