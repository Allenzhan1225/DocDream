//
//  MainModel.m
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MainModel.h"
@interface MainModel()

@end


@implementation MainModel
+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"ID": @"id" }];
}


@end
