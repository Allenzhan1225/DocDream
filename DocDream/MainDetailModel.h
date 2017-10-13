//
//  MainDetailModel.h
//  DocDream
//
//  Created by YDWY on 2017/10/11.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import <JSONModel/JSONModel.h>



@interface AbjaModel : JSONModel
@property (nonatomic,strong) NSString <Optional>* ID;
@property (nonatomic,strong) NSString <Optional>* uid;
@property (nonatomic,strong) NSString <Optional>* sid;

@property (nonatomic,strong) NSString <Optional>* content;
@property (nonatomic,strong) NSString <Optional>* z_time;
@property (nonatomic,strong) NSString <Optional>* u_image;

@property (nonatomic,strong) NSString <Optional>* weixin_name;
@end


@protocol AbjbModel
@end

@interface AbjbModel : JSONModel
@property (nonatomic,strong) NSString <Optional>* ID;
@property (nonatomic,strong) NSString <Optional>* rat;
@property (nonatomic,strong) NSString <Optional>* d_id;

@property (nonatomic,strong) NSString <Optional>* sid;
@property (nonatomic,strong) NSString <Optional>* d_content;
@property (nonatomic,strong) NSString <Optional>* d_time;

@property (nonatomic,strong) NSString <Optional>* d_images;
@property (nonatomic,strong) NSString <Optional>* d_doctor;


@end


@protocol AbjcModel
@end

@interface AbjcModel : JSONModel

@property (nonatomic,strong) NSString <Optional>* ID;
@property (nonatomic,strong) NSString <Optional>* uid;
@property (nonatomic,strong) NSString <Optional>* u_image;

@property (nonatomic,strong) NSString <Optional>* weixin_name;
@property (nonatomic,strong) NSString <Optional>* z_time;
@property (nonatomic,strong) NSString <Optional>* content;

@property (nonatomic,strong) NSString <Optional>* d_images;
@property (nonatomic,strong) NSString <Optional>* d_doctor;
@property (nonatomic,strong) NSString <Optional>* d_content;
@property (nonatomic,strong) NSString <Optional>* d_time;
@property (nonatomic,strong) NSString <Optional>* doc_statu;
@end


@interface MainDetailModel : JSONModel

@property (nonatomic,strong) AbjaModel * abja;
@property (nonatomic,strong)NSArray <AbjbModel>* abjb;
@property (nonatomic,strong)NSArray <AbjcModel>* abjc;

@end



