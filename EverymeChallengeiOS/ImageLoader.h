//
//  ImageLoader.h
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

@protocol ImageLoaderDelegate <NSObject>
@required
- (void)image:(UIImage *)image didLoadForUrlString:(NSString *)urlString;
- (void)imageDidFailwithError:(NSError *)error forUrlString:(NSString *)urlString;
@end

@interface ImageLoader : NSObject<ASIHTTPRequestDelegate>

@property(nonatomic, assign) id <ImageLoaderDelegate> delegate;

- (id)initWithUrlString:(NSString *)urlString delegate:(id<ImageLoaderDelegate>)delegate;
- (void)startDownloading;
- (void)cancel;

@end
