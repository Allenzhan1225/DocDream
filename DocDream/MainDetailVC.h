//
//  MainDetailVC.h
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainModel;
@interface MainDetailVC : UIViewController
@property  (nonatomic,strong) MainModel * model;
@property (nonatomic,assign) NSInteger doc_id;
@end
