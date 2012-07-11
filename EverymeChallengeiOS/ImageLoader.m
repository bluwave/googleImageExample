//
//  ImageLoader.m
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import "ImageLoader.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@interface ImageLoader()
@property(nonatomic, retain)ASIHTTPRequest *request;
@property(nonatomic, retain)NSString *urlString;
@end

@implementation ImageLoader
@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize urlString = _urlString;

- (id)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

- (id)initWithUrlString:(NSString *)urlString delegate:(id<ImageLoaderDelegate>)delegate {
    self = [self init];
    if (self != nil) {
        self.urlString = urlString;
        self.delegate = delegate;
        
        NSURL *url = [NSURL URLWithString:urlString];
        self.request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
        [self.request setDownloadCache:[ASIDownloadCache sharedCache]];
        [self.request setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s ",__func__);
    [self.request clearDelegatesAndCancel];
    
    [_request release];
    [_urlString release];
    
    [super dealloc];
}

- (void)startDownloading {
//    NSLog(@"%s ",__func__);
    if (self.delegate && self.request.delegate) {
        [self.request startAsynchronous];
    }
}

- (void)cancel {
//    NSLog(@"%s ",__func__);
    [self.request clearDelegatesAndCancel];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request {

//    NSLog(@"%s ",__func__);

    // There was probably an error if an html page was returned instead of an image
    if ([[request responseString] rangeOfString:@"<html>"].location != NSNotFound) {
        NSLog(@"%s TODO - error in response: %@",__func__, [request responseString]);
        //TO DO: maybe some kind of error handling here
        return;
    }
    
    NSData *responseData = [request responseData];
    UIImage *image = [[[UIImage alloc] initWithData:responseData] autorelease];
    
    if (image.size.width == 0) {
        NSLog(@"%s TODO - bad image",__func__);
        //TO DO: bad image returned here, do something

    } else {
        [self.delegate image:image didLoadForUrlString:self.urlString];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {  
    [[[[UIAlertView  alloc] initWithTitle:@"ImageLoader Error" message:@"request failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]show];
    //TO DO: request failed here, maybe do something about it.
}

@end