//
//  ImageInfo.m
//  ImageGrabber
//
//  Created by Ray Wenderlich on 7/3/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "ImageInfo.h"
#import "ASIHTTPRequest.h"

@implementation ImageInfo

@synthesize sourceURL;
@synthesize imageName;
@synthesize image;
@synthesize imageData;

- (void)getImage {
    
    NSLog(@"Getting %@", sourceURL);
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:sourceURL];
    [request setCompletionBlock:^{
        NSLog(@"Image Downloaded");
        NSData *data = [request responseData];
        //add by wanglei
        if ([[imageName pathExtension] isEqualToString:@"gif"] ||
            [[imageName pathExtension] isEqualToString:@"GIF"]){
            imageData = data;
        }else{
            image = [[UIImage alloc] initWithData:data];
        }
        
        //notify after the image is updated
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.bipin.imageUpdated" object:self];
    }];
    
    [request setFailedBlock:^{
        NSError * error = [request error];
        NSLog(@"Errro downloading image: %@", error.localizedDescription);
    }];
   
    [request startAsynchronous];
}

- (id)initWithSourceURL:(NSURL *)URL {
    if ((self = [super init])) {
        sourceURL = URL;
        imageName = [URL lastPathComponent];
        [self getImage];
    }
    return self;
}

- (id)initWithSourceURL:(NSURL *)URL imageName:(NSString *)name image:(UIImage *)i {
    if ((self = [super init])) {
        sourceURL = URL ;
        imageName = name ;
        image = i;
    }
    return self;
}

- (void)dealloc {

}

@end
