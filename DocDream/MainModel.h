//
//  MainModel.h
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>
@interface MainModel : JSONModel

    @property (nonatomic,strong) NSString <Optional>* content;
    @property (nonatomic,assign) NSInteger   d_id;
    @property (nonatomic,strong) NSString <Optional>* d_images;
    @property (nonatomic,assign) NSInteger ID;
    @property (nonatomic,strong) NSString <Optional>* u_image;
    @property (nonatomic,strong) NSString <Optional>* weixin_name;
    @property (nonatomic,strong) NSString <Optional>* z_time;


@end
