//
//  MainDetailModel.m
//  DocDream
//
//  Created by YDWY on 2017/10/11.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MainDetailModel.h"

@implementation MainDetailModel
+(JSONKeyMapper*)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"ID": @"id" }];
    return  [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"ID": @"id" }];
}
@end

@implementation AbjaModel
+(JSONKeyMapper*)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"ID": @"id" }];
    return  [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"ID": @"id" }];
    
}
@end
@implementation AbjbModel
+(JSONKeyMapper*)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"ID": @"id" }];
    return  [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"ID": @"id" }];
}
@end
@implementation AbjcModel
+(JSONKeyMapper*)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"ID": @"id" }];
    return  [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"ID": @"id" }];
}
@end
