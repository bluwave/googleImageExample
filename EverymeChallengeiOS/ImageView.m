//
//  ImageView.m
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import "ImageView.h"

@interface ImageView()
@property(nonatomic, retain)ImageLoader *imageLoader;
@property(nonatomic, retain)UIButton *button;
@property(nonatomic, readwrite, retain)NSString *imageUrl;
@end

@implementation ImageView
@synthesize imageLoader = _imageLoader;
@synthesize button = _button;
@synthesize imageView = _imageView;
@synthesize imageUrl = _imageUrl;

- (void)dealloc {
    [self.imageLoader cancel];
    self.imageLoader.delegate = nil;
    
    [_imageLoader release];
    [_button release];
    [_imageView release];
    [_imageUrl release];
    [super dealloc];
}

- (void)loadImageFromUrlString:(NSString *)urlString {
    if ([self.imageUrl isEqualToString:urlString]) {
        return;
    }

    self.imageUrl = urlString;
    self.backgroundColor = [UIColor grayColor];
    self.imageView.image = nil;
    
    // Cancel any old request
    [self.imageLoader cancel];
    self.imageLoader.delegate = nil;
        
    self.imageLoader = [[[ImageLoader alloc] initWithUrlString:urlString delegate:self] autorelease];
    [self.imageLoader startDownloading];
}

#pragma mark - ImageLoaderDelegate methods

- (void)image:(UIImage *)image didLoadForUrlString:(NSString *)urlString; {
    if (image != nil) {        
        //Got the image back, all is good.
        self.imageView.image = image;
        self.backgroundColor = [UIColor clearColor];
    }
//    NSLog(@"%s ",__func__);
}

- (void)imageDidFailwithError:(NSError *)error forUrlString:(NSString *)urlString {
        [[[[UIAlertView  alloc] initWithTitle:@"Error loading image" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]show];

        //TO DO: image did fail, do something here
}

@end
