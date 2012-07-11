//
//  ImageSearchController.h
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageSearchControllerDelegate
@required

- (void)imageSearchController:(id)searchController gotResults:(NSArray *)results;
- (void)imageSearchController:(id)searchController didFailWithError:(NSError *)error;

@end

@interface ImageSearchController : NSObject <NSURLConnectionDataDelegate>

- (void)performSearch:(NSString *)searchTerm;
- (void)cancelSearch;

@property (nonatomic, assign) id <ImageSearchControllerDelegate> delegate; 
@end
