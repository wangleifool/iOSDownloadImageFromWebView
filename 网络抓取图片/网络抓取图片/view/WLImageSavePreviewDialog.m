//
//  WLImageSavePreviewDialog.m
//  网络抓取图片
//
//  Created by lei wang on 2017/8/24.
//  Copyright © 2017年 王雷. All rights reserved.
//

#import "WLImageSavePreviewDialog.h"

#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)


@implementation WLImageSavePreviewDialog

- (IBAction)saveButtonPressed:(id)sender {
    [_delegate agreeSave:YES Image:self.imageView.image];
}

- (IBAction)ignoreButtonPressed:(id)sender {
    [_delegate agreeSave:NO Image:self.imageView.image];
}



+ (instancetype)sharedImageSavePreviewDialog
{
    WLImageSavePreviewDialog *view = [[NSBundle mainBundle] loadNibNamed:@"WLImageSavePreviewDialog" owner:nil options:nil].firstObject;
    
    CGRect frame = view.frame;    
    frame.origin.x = (ScreenWidth - frame.size.width)/2;
    frame.origin.y = (ScreenHeight - frame.size.height)/2;
    view.frame = frame;
    
    return view;
}

@end
