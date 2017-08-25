//
//  WLImageSavePreviewDialog.h
//  网络抓取图片
//
//  Created by lei wang on 2017/8/24.
//  Copyright © 2017年 王雷. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLImageSavePreviewDialogDelegate <NSObject>

- (void)agreeSave:(BOOL)agree Image:(UIImage *)image;

@end

@interface WLImageSavePreviewDialog : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) id<WLImageSavePreviewDialogDelegate> delegate;

+ (instancetype)sharedImageSavePreviewDialog;

@end
