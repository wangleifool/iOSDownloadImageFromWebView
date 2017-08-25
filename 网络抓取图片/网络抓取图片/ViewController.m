//
//  ViewController.m
//  网络抓取图片
//
//  Created by 王雷 on 16/8/5.
//  Copyright © 2016年 王雷. All rights reserved.
//

#import "ViewController.h"
#import "WLGrabUrlImage.h"
#import "ImageListViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "LCProgressHUD.h"
#import "WLImageSavePreviewDialog.h"

@interface ViewController () <NJKWebViewProgressDelegate,UIGestureRecognizerDelegate,NSURLSessionDelegate,WLImageSavePreviewDialogDelegate,UITextFieldDelegate>
{
    NJKWebViewProgress *_progressProxy;
    
    //记录tabbar初始frame
    CGRect defaultTabbarFrame;
    CGRect defaultNavbarFrame;
}

@property (weak, nonatomic) IBOutlet NJKWebViewProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextField *textFileldURL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *grabButton;
@property (weak, nonatomic) IBOutlet UIToolbar *mainToolBar;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) WLImageSavePreviewDialog *imagePreviewDialog;

@end

@implementation ViewController

- (WLImageSavePreviewDialog *)imagePreviewDialog
{
    if (nil == _imagePreviewDialog) {
        _imagePreviewDialog = [WLImageSavePreviewDialog sharedImageSavePreviewDialog];
        _imagePreviewDialog.delegate = self;
    }
    return _imagePreviewDialog;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initWeb];
    [self initAction];
}

//为webView添加长按手势
- (void)initAction {
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(webViewLongPressAction:)];
    self.longPressGesture.delegate = self;
    [self.mainWebView addGestureRecognizer:self.longPressGesture];
    
    [self.mainWebView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)initUI {
    defaultNavbarFrame = self.navigationController.navigationBar.frame;
    defaultTabbarFrame = self.mainToolBar.frame;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.layer.cornerRadius = 4.0;
    keyWindow.layer.masksToBounds = YES;
    
    self.textFileldURL.delegate = self;
}

- (void)initWeb {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [_mainWebView loadRequest:request];
    
    
    //设置UIWebView progress bar
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _mainWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

//按下访问其他网址
- (IBAction)btOpenUrl:(id)sender {
    NSString *strUrl = nil;
    if (nil != _textFileldURL.text && ![@"" isEqualToString:_textFileldURL.text]) {
        strUrl = _textFileldURL.text;
    } else {
        strUrl = @"www.baidu.com";
    }
    
    
    if (![strUrl containsString:@"http://"]) {
        strUrl = [NSString stringWithFormat:@"http://%@",strUrl];
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [_mainWebView loadRequest:request];
}

//抓取
- (IBAction)btGrabImagePressed:(id)sender {
    // Get HTML from web view
    NSString *html = [_mainWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    // Hand HTML to list view for retrieval and display
    ImageListViewController* imageListViewController = [[ImageListViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    
    imageListViewController.html = html;
    [self.navigationController pushViewController:imageListViewController animated:YES];

}

- (IBAction)btPreviousPage:(id)sender {
    if ([_mainWebView canGoBack]) {
        [_mainWebView goBack];
    }
}

- (IBAction)btForwardPage:(id)sender {
    if ([_mainWebView canGoForward]) {
        [_mainWebView goForward];
    }
}

#pragma mark - web delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"加载网页出错 %@",error);
    
    [LCProgressHUD showFailure:@"网址解析失败！"];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"开始加载");
    numLoads++;
    _grabButton.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"加载结束");
    numLoads--;
    if (numLoads >= 0) {
        _grabButton.enabled = YES;
    }
    
    [self.textFileldURL setText:@""];
    [self.textFileldURL setPlaceholder:webView.request.URL.absoluteString];
}

#pragma mark - 监控textfiled
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self btOpenUrl:nil];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 长按web上的图片，下载图片
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)webViewLongPressAction:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self.mainWebView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.mainWebView stringByEvaluatingJavaScriptFromString:imgURL]; //执行jsp代码，获得图片的链接
    if (urlToSave.length == 0) {
        return;
    }
    
//    int scrollPositionY = [[self.mainWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
//    int scrollPositionX = [[self.mainWebView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
//    
//    int displayWidth = [[self.mainWebView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
//    CGFloat scale = self.mainWebView.frame.size.width / displayWidth;
//    
//    CGPoint pt = [recognizer locationInView:self.mainWebView];
//    pt.x *= scale;
//    pt.y *= scale;
//    pt.x += scrollPositionX;
//    pt.y += scrollPositionY;
//    
//    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
//    NSString * tagName = [self.mainWebView stringByEvaluatingJavaScriptFromString:js];
//    NSString *urlToSave = nil;
//    if ([tagName isEqualToString:@"img"]) {
//        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
//        urlToSave = [self.mainWebView stringByEvaluatingJavaScriptFromString:imgURL];
//        NSLog(@"image url=%@", urlToSave);
//    }
    
    if (nil == urlToSave) {
        return ;
    }
    
    UIAlertController *alertVC =  [UIAlertController alertControllerWithTitle:@"提示" message:@"你真的要保存图片到相册吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"真的啊" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveImageToDiskWithUrl:urlToSave];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"大哥，我点错了，不好意思" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)saveImageToDiskWithUrl:(NSString *)imageUrl{
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [UIImage imageWithData:imageData];
            [self showImagePreviewDialog:image];
        });
    }];
    [task resume];
}

- (void)showImagePreviewDialog:(UIImage *)image {
    [self.imagePreviewDialog.imageView setImage:image];

    [UIView animateWithDuration:1.0 animations:^{
        [self.view addSubview:self.imagePreviewDialog];
        [self.view bringSubviewToFront:self.imagePreviewDialog];
    }];
}

- (void)agreeSave:(BOOL)agree Image:(UIImage *)image
{
    if (agree) {
        [self saveImageToAlbum:image];
    }
        
    [UIView animateWithDuration:1.0 animations:^{
        [self.imagePreviewDialog removeFromSuperview];
    }];
    
}

#pragma mark - 监听webView的滑动事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        static CGFloat lastOriginY = 0;
        CGFloat y = self.mainWebView.scrollView.contentOffset.y;
        
        if ((y - lastOriginY) > 10) {  //上滑
            [self performSelectorOnMainThread:@selector(hideToolbar) withObject:nil waitUntilDone:NO];
        } else if (((y - lastOriginY) < -10)) {
            [self performSelectorOnMainThread:@selector(showToolbar) withObject:nil waitUntilDone:NO];
        }
        
        NSLog(@"last y:%.2f cur y:%.2f distance:%.2f",lastOriginY,y,y-lastOriginY);
        
        lastOriginY = y;
    }
}

#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)

- (void)showToolbar
{
    __block CGRect frame = self.mainToolBar.frame;
    if (frame.origin.y != defaultTabbarFrame.origin.y) {
        [UIView animateWithDuration:0.3 animations:^{
            frame.origin.y = ScreenHeight - frame.size.height;
            self.mainToolBar.frame = frame;
        }];
    }
}

- (void)hideToolbar
{
    __block CGRect frame = self.mainToolBar.frame;
    if (frame.origin.y == defaultTabbarFrame.origin.y) {
        [UIView animateWithDuration:0.3 animations:^{
            frame.origin.y = ScreenHeight;
            self.mainToolBar.frame = frame;
        }];
    }
}


#pragma mark - progress

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}


#pragma mark - system configuration
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
