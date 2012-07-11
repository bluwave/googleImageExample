//
//  ImageView.h
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"

@class ImageView;

@interface ImageView : UIView <ImageLoaderDelegate>

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, readonly, retain) NSString *imageUrl;

- (void)loadImageFromUrlString:(NSString *)urlString;

@end
