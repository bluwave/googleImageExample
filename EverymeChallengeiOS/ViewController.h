//
//  ViewController.h
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSearchController.h"
#import "ImageLoader.h"
#import "ImageView.h"

@interface ViewController : UIViewController <UISearchBarDelegate, ImageSearchControllerDelegate, UIScrollViewDelegate>

@property(nonatomic, retain)IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain)IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain)IBOutlet UIView * bottomBar;

@end
