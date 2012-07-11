//
//  ViewController.m
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ViewController.h"
#import "ImageDisplayViewController.h"

#define SCROLL_VIEW_PORTAIT_WIDTH 768
#define SCROLL_VIEW_PORTAIT_HEIGHT 960
#define SCROLL_VIEW_LANDSCAPE_WIDTH 1024
#define SCROLL_VIEW_LANDSCAPE_HEIGHT 704

#define PORTRAIT_ROW_COUNT 4
#define PORTRAIT_COLUMN_COUNT 3
#define LANDSCAPE_ROW_COUNT 4
#define LANDSCAPE_COLUMN_COUNT 6
#define IMAGE_SPACING 10

@interface ViewController ()
{
    int pageCnt;
}
@property(nonatomic, retain) UILabel *pageLabel;

@property(nonatomic, retain) ImageSearchController *imageSearchController;

@property(nonatomic, retain) NSMutableArray *imageUrls;
@property(nonatomic, retain) NSMutableArray *imageViews;

@property(nonatomic, readonly) NSInteger imagesPerPage;

@property(nonatomic, assign) BOOL hasSearchedImage;

- (ImageView *)imageViewAtIndex:(NSInteger)index;

- (void)loadImages;

- (CGRect)frameForImageAtIndex:(NSInteger)index;
@end

@implementation ViewController

@synthesize searchBar = _searchBar;
@synthesize scrollView = scrollView_;
@synthesize bottomBar = _bottomBar;

@synthesize imageSearchController = _imageSearchController;

@synthesize imageUrls = imageUrls_;
@synthesize imageViews = imageViews_;

@synthesize pageLabel = _pageLabel;

@synthesize hasSearchedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.imageSearchController = [[[ImageSearchController alloc] init] autorelease];
        self.imageSearchController.delegate = self;

        self.imageUrls = [NSMutableArray arrayWithCapacity:8];
        self.imageViews = [NSMutableArray arrayWithCapacity:10];

        pageCnt = 1;
    }
    return self;
}

- (void)dealloc
{
    [_pageLabel release];
    [_bottomBar release];
    [_searchBar release];
    [scrollView_ release];

    [_imageSearchController release];
    [imageUrls_ release];
    [imageViews_ release];

    [super dealloc];
}

-(void)viewDidLoad
{
    [super viewDidLoad];


    self.bottomBar.alpha = 0.75;
    
    // add label to bar
    self.pageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10,(44 - 21 ) / 2, self.view.frame.size.width - 20.0, 21.0)] autorelease];
    self.pageLabel.textColor = [UIColor whiteColor];
    self.pageLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    self.pageLabel.shadowColor = [UIColor blackColor];
    self.pageLabel.font = [UIFont boldSystemFontOfSize:19.0];
    self.pageLabel.backgroundColor = [UIColor clearColor];
    self.pageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.pageLabel.textAlignment = UITextAlignmentCenter;
    [self.bottomBar addSubview:_pageLabel];

    [self updatePageLabel];


    self.searchBar.text= @"surfing wave";
    [self searchBarSearchButtonClicked:self.searchBar];

    self.scrollView.delegate = self;

}

#pragma mark - Private methods

- (NSInteger)imagesPerPage
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait  || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {

        return (NSInteger) (PORTRAIT_COLUMN_COUNT * PORTRAIT_ROW_COUNT);
    }
    else
    {

        return (NSInteger) (LANDSCAPE_COLUMN_COUNT * LANDSCAPE_ROW_COUNT);
    }
}

- (ImageView *)imageViewAtIndex:(NSInteger)index
{
    // Null fill any indexes skipped
    while (index >= [self.imageViews count])
    {
        [self.imageViews addObject:[NSNull null]];
    }

    // Lazy instantiate imageView
    id imageView = [self.imageViews objectAtIndex:index];
    if (![imageView isKindOfClass:[ImageView class]])
    {

        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ImageView"
                                                          owner:self
                                                        options:nil];
        imageView = [nibViews objectAtIndex:0];
        ((ImageView *) imageView).frame = CGRectZero;
        [self.imageViews replaceObjectAtIndex:index withObject:imageView];
    }

    return imageView;
}

- (void)loadImages
{
    [self adjustScrollViewSize];

//    NSInteger imagesPerPage = self.imagesPerPage;
    NSInteger imagesPerPage = [self.imageUrls count];
//    NSLog(@"%s imagesPerPage: %d",__func__, imagesPerPage);
    NSInteger baseIndex = 0;
    for(NSInteger i = 0; i < imagesPerPage; i++)
    {
        NSInteger imageIndex = baseIndex + i;
        if (imageIndex < [self.imageUrls count])
        {
            NSString *url = [self.imageUrls objectAtIndex:imageIndex];
            ImageView *imageView = [self imageViewAtIndex:imageIndex];
            CGRect newFrame = [self frameForImageAtIndex:imageIndex];

            CGFloat width = newFrame.size.width;
            CGFloat height = newFrame.size.height;

            if (imageView.frame.size.width == 0 && imageView.frame.size.height == 0)
            {
                imageView.center = CGPointMake(newFrame.origin.x + width / 2.0, newFrame.origin.y + height / 2.0);
                CGFloat bounceWidth = width * 1.1;
                CGFloat bounceHeight = height * 1.1;
                CGRect bounceRect = CGRectMake(imageView.center.x - bounceWidth / 2.0, imageView.center.y - bounceHeight / 2.0, bounceWidth, bounceHeight);
                CGFloat bounceWidth2 = width * 0.95;
                CGFloat bounceHeight2 = height * 0.95;
                CGRect bounceRect2 = CGRectMake(imageView.center.x - bounceWidth2 / 2.0, imageView.center.y - bounceHeight2 / 2.0, bounceWidth2, bounceHeight2);

//                NSLog(@"%s %d:) %@",__func__, i, NSStringFromCGRect(newFrame));
                imageView.frame = newFrame;
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^
                {
                    imageView.frame = bounceRect;
                }                completion:^(BOOL finished)
                {
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^
                    {
                        imageView.frame = bounceRect2;
                    }
                    completion:^(BOOL finished)
                    {
                        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^
                        {
                            imageView.frame = newFrame;
                        } completion:nil];
                    }];
                }];
            }
            else
            {

//                NSLog(@"%s ATTENTION ***",__func__);
//                NSLog(@"%s imageIndex: %d",__func__, imageIndex);

                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options:UIViewAnimationCurveEaseOut
                                 animations:^
                                 {
                                     imageView.center = CGPointMake(newFrame.origin.x + width / 2.0,
                                             newFrame.origin.y + height / 2.0);

                                 }
                                 completion:^(BOOL finished)
                                 {
                                     [UIView animateWithDuration:0.2
                                                           delay:0.0
                                                         options:UIViewAnimationCurveEaseIn
                                                      animations:^
                                                      {
                                                          imageView.frame = newFrame;
                                                      }
                                                      completion:nil];
                                 }];
            }
            [imageView loadImageFromUrlString:url];
            [self.scrollView addSubview:imageView];

        }
    }
    [self updatePageLabel];
}

- (CGRect)frameForImageAtIndex:(NSInteger)index
{
    NSInteger rowCount;
    NSInteger columnCount;

    CGFloat height;
    CGFloat width;
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        rowCount = PORTRAIT_ROW_COUNT;
        columnCount = PORTRAIT_COLUMN_COUNT;
        CGFloat viewWidth = SCROLL_VIEW_PORTAIT_WIDTH;
        CGFloat viewHeight = SCROLL_VIEW_PORTAIT_HEIGHT;
        width = (viewWidth - ((columnCount + 1) * IMAGE_SPACING)) / columnCount;
        height = (viewHeight - ((rowCount + 1) * IMAGE_SPACING)) / rowCount;
    }
    else
    {
        rowCount = LANDSCAPE_ROW_COUNT;
        columnCount = LANDSCAPE_COLUMN_COUNT;
        CGFloat viewWidth = SCROLL_VIEW_LANDSCAPE_WIDTH;
        CGFloat viewHeight = SCROLL_VIEW_LANDSCAPE_HEIGHT;
        width = (viewWidth - ((columnCount + 1) * IMAGE_SPACING)) / columnCount;
        height = (viewHeight - ((rowCount + 1) * IMAGE_SPACING)) / rowCount;
    }

    NSInteger imagesPerPage = rowCount * columnCount;
    NSInteger page = index / imagesPerPage;
    NSInteger pagePosition = index % imagesPerPage;

    NSInteger rowNumber = pagePosition % columnCount;
    NSInteger columnNumber = pagePosition / columnCount;

    return CGRectMake(IMAGE_SPACING + ((width + IMAGE_SPACING) * rowNumber),
            IMAGE_SPACING + ((height + IMAGE_SPACING) * columnNumber) + (self.scrollView.frame.size.height * page),
            width,
            height);
}

#pragma mark - UIScrollViewDelegate methods

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
        [self loadImages];
}

#pragma mark UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.hasSearchedImage = YES;
    [self.imageSearchController cancelSearch];

    // Remove all old images
    for(UIView *subview in self.scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.imageUrls removeAllObjects];
    [self.imageViews removeAllObjects];

    [searchBar resignFirstResponder];
    [self.imageSearchController performSearch:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark ImageSearchController Delegate Methods

- (void)imageSearchController:(id)searchController didFailWithError:(NSError *)error
{
    //TO DO: Need to handle error here
    [[[[UIAlertView  alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]show];
}

- (void)imageSearchController:(id)searchController gotResults:(NSArray *)results
{

    for(NSDictionary *imageInfo in results)
    {
        NSString *url = [imageInfo objectForKey:@"unescapedUrl"];
        if (url == nil)
        {
            continue;
        }
        [self.imageUrls addObject:url];
    }

    //Results are returned, let's display them!
    [self loadImages];


}

-(void) adjustScrollViewSize
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height * [self calculatePages]);
}

- (int)calculatePages
{
    int mod = [self.imageUrls count] % self.imagesPerPage;

    int pages = [self.imageUrls count] / self.imagesPerPage;

    if (mod > 0)
        pages++;
    return pages;
}

-(void) updatePageLabel
{

    CGFloat pageHeight = self.scrollView.frame.size.height;

    int page = (int) (self.scrollView.contentOffset.y / self.scrollView.frame.size.height);

//    int page = floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;

    int pages = [self calculatePages];

    NSLog(@"%s page: %d",__func__, page);

    self.pageLabel.text = [NSString stringWithFormat:@"Page %d / %d", page + 1, pages];

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePageLabel];
}
@end
