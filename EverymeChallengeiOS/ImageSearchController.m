//
//  ImageSearchController.m
//  EverymeChallengeiOS
//
//  Created by Shuo Liu on 7/8/12.
//  Copyright (c) 2012 Everyme. All rights reserved.
//

#import "ImageSearchController.h"

#define RESULT_SIZE 8

@interface ImageSearchController ()
{
    int currentPage;
}
@property (nonatomic, retain) NSMutableData *searchResultsData;
@property (nonatomic, retain) NSString *searchTerm;
@property (nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSURLRequest *request;
@property(nonatomic, copy) NSMutableArray *pages;


- (void)performSearch:(NSString *)searchTerm index:(NSUInteger)page;

@end

@implementation ImageSearchController

@synthesize delegate = _delegate;
@synthesize searchResultsData = _searchResultsData;
@synthesize searchTerm = _searchTerm;
@synthesize connection = _connection;
@synthesize request = _request;
@synthesize pages = _pages;

- (void)dealloc {
    [_pages release];
    [_request release];
    [_connection release];
    [_searchResultsData release];
    [super dealloc];
}

#pragma mark - Private methods

- (void)performSearch:(NSString *)searchTerm index:(NSUInteger)page {

    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&resultFormat=text&start=%D&rsz=%D", [searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], page, RESULT_SIZE];
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSLog(@"%s request url: %@",__func__, urlString);
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];

}

#pragma mark - Public methods

- (void)performSearch:(NSString *)searchTerm {
    self.searchTerm = searchTerm;

    self.pages = nil;
    currentPage = 0;

    //TO DO: we only currently search for the first page of the result, needs to support more
    [self performSearch:searchTerm index:currentPage++];
}

- (void)cancelSearch {
    [self.connection cancel];
}

#pragma mark NSURLConnnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.searchResultsData = [[[NSMutableData alloc] initWithCapacity:1024] autorelease];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[[UIAlertView  alloc] initWithTitle:@"Request Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]show];
    //TO DO: Add appropriate error handling here
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.searchResultsData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSError *error = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:self.searchResultsData options:NSJSONReadingAllowFragments error:&error];
    
    if (!JSONObject) {
        NSLog(@"There was an error: %@", error);
        [self.delegate imageSearchController:self didFailWithError:error];
    }

    id responseData = [JSONObject objectForKey:@"responseData"];
    if ([responseData isKindOfClass:[NSDictionary class]])
    {
        if (!self.pages)
        {
            id pagesDict = [responseData valueForKeyPath:@"cursor.pages"];
            if ([pagesDict isKindOfClass:[NSArray class]])
            {
                // get paging info
                self.pages = pagesDict;
                if ([self.pages count] > 0)
                {
                    int index = [self getStartIndexForCurrentPage];
                    currentPage++;
                    if (index > 0) // zero b/c we have already done the first query to page 0
                        [self performSearch:self.searchTerm index:index];
                }
            }
        }
        else
        {
            int index = [self getStartIndexForCurrentPage];
            currentPage++;
            if (index > 0) // zero b/c we have already done the first query to page 0
                [self performSearch:self.searchTerm index:index];
        }


        id results = [responseData objectForKey:@"results"];
        if ([results isKindOfClass:[NSArray class]])
        {
            if ([(NSArray *) results count] > 0)
            {
                [self.delegate imageSearchController:self gotResults:results];
            }
        }
        else if ([results isKindOfClass:[NSDictionary class]])
        {
            [self.delegate imageSearchController:self gotResults:[NSArray arrayWithObject:results]];
        }
    }
    else
    {
        id responseDetails = [JSONObject objectForKey:@"responseDetails"];
        if ( [responseDetails isKindOfClass:[NSString class]])
        {
            NSError * e = [self errorFromString:responseDetails];
            [self.delegate imageSearchController:self didFailWithError:e];
//            [[[[UIAlertView alloc] initWithTitle:@"API Error" message:responseDetails delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
        }
        
    }
}

-(int) getStartIndexForCurrentPage
{
    if (self.pages && currentPage < [self.pages count])
    {

        NSDictionary * page = [self.pages objectAtIndex:currentPage];
        if ([page isKindOfClass:[NSDictionary class]])
        {
            return [[page valueForKey:@"start"] intValue];
        }
    }
    return -1;

}

-(NSError *) errorFromString:(NSString *) errorMsg
{
    NSMutableDictionary *details = [NSMutableDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
    NSError *e = [NSError errorWithDomain:@"ImageSearchController" code:100 userInfo:details];
    return e;
}


@end