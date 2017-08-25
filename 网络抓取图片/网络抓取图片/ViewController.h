//
//  ViewController.h
//  网络抓取图片
//
//  Created by 王雷 on 16/8/5.
//  Copyright © 2016年 王雷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ViewController : BaseViewController <UIWebViewDelegate>
{
    int numLoads;
}
@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;
//@property (weak, nonatomic) IBOutlet UIView *webParentView;

@end

