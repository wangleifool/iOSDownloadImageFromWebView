//
//  WLGrabUrlImage.h
//  网络抓取图片
//
//  Created by 王雷 on 16/8/5.
//  Copyright © 2016年 王雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLGrabUrlImage : NSObject

+(NSString*) urlstring:(NSString*)strurl;

- (NSMutableArray *)substringByRegular:(NSString *)regular;
@end
