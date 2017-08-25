//
//  WLGrabUrlImage.m
//  网络抓取图片
//
//  Created by 王雷 on 16/8/5.
//  Copyright © 2016年 王雷. All rights reserved.
//

#import "WLGrabUrlImage.h"

@implementation WLGrabUrlImage

//对于一些网页，不需要提交Post提交数据时，我们可以简单的利用NSURL类来获取我们所需要的html，交将其转换中kCFStringEncodingGB_18030_2000格式，解决中文乱码问题。
+(NSString*) urlstring:(NSString*)strurl{
    
    NSURL *url = [NSURL URLWithString:strurl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
    
    NSLog(@" html = %@",retStr);
    
    return retStr;
}

//对于需要Post提交数据的网页，我们可以利用强大的ASIFormDataRequest类来实现
//+(void)getPostResult:(NSString*)startqi{
//    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:URLPost]];
//    
//    [request setPostValue:startqi forKey:@"startqi"];
//    [request setPostValue:@"20990101001" forKey:@"endqi"];
//    [request setPostValue:@"qihao" forKey:@"searchType"];//网页的中的搜索方式
//    [request startSynchronous];
//    
//    NSData* data = [request responseData];
//    
//    if (data==nil) {
//        FCLOG(@"has not data");
//    }
//    else{
//        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
//        FCLOG(@"html = %@",retStr); 
//    }
//}

//根据传入的正则表达式，返回所有匹配的数组。
- (NSMutableArray *)substringByRegular:(NSString *)regular{
    
    NSString * reg=regular;
    
    
    NSRange r= [regular rangeOfString:reg options:NSRegularExpressionSearch];
    
    NSMutableArray *arr=[NSMutableArray array];
    
    if (r.length != NSNotFound &&r.length != 0) {
        
        int i=0;
        
        while (r.length != NSNotFound &&r.length != 0) {
            
            NSLog(@"index = %i regIndex = %d loc = %d",(++i),r.length,r.location);
            
            NSString* substr = [regular substringWithRange:r];
            
            NSLog(@"substr = %@",substr);
            
            [arr addObject:substr];
            
            NSRange startr=NSMakeRange(r.location+r.length, [regular length]-r.location-r.length);
            
            r=[regular rangeOfString:reg options:NSRegularExpressionSearch range:startr];
        }
    }
    return arr;
}
@end
