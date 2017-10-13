//
//  MainDetailCell.h
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainDetailModel.h"
@interface MainDetailCell : UITableViewCell
@property (nonatomic,strong)AbjcModel * model;
@property (nonatomic,strong)AbjaModel * modela;
@property (nonatomic,strong)AbjbModel * modelb;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIView *audioBg;
@end
