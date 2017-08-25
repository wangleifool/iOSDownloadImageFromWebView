//
//  ImageDetailViewController.m
//  ImageGrabber
//
//  Created by Ray Wenderlich on 7/3/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "ImageInfo.h"

@implementation ImageDetailViewController
@synthesize info;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [info release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStylePlain target:self action:@selector(downloadImage:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)downloadImage:(UIBarButtonItem *)barButttonItem
{    
    [self saveImageToAlbum:self.imageView.image];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([[info.imageName pathExtension] isEqualToString:@"gif"] ||
        [[info.imageName pathExtension] isEqualToString:@"GIF"]) {
        imageView.hidden = YES;
        _imageWebView.hidden = NO;
        _imageWebView.userInteractionEnabled = NO;
        [_imageWebView loadData:info.imageData MIMEType:@"image/gif" textEncodingName:@"UTF-8" baseURL:nil];
    }else{
        imageView.hidden = NO;
        _imageWebView.hidden = YES;
        _imageWebView.userInteractionEnabled = NO;
        imageView.image = info.image;
    }
    
    self.title = info.imageName;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
