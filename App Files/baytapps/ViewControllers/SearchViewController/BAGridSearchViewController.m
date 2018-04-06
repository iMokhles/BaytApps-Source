//
//  BAGridSearchViewController.m
//  baytapps
//
//  Created by iMokhles on 25/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAGridSearchViewController.h"
#import "BAHelper.h"
#import "ITHelper.h"

@interface BAGridSearchViewController () {
    BOOL isFiltered;
    
    NSMutableArray *appsArray;
    NSMutableArray *filteredObjects;
    NSMutableArray *filteredObjectsSearch;
}
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar_;
@property (strong, nonatomic) IBOutlet MMGridView *gridView;
@property (nonatomic) BOOL isRefreshing;
@end

@implementation BAGridSearchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _gridView.numberOfRows = 4;
    if ([BAHelper isIPHONE4] || [BAHelper isIPHONE5]) {
        _gridView.numberOfColumns = 4;
    } else {
        _gridView.numberOfColumns = 5;
    }
    
    
    self.currentPageSearch = 1;
    self.currentPage = 1;
    [self loadApps];
    [self.gridView reloadData];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)loadApps {
    self.isRefreshing = YES;
    [KSToastView ks_showToast:NSLocalizedString(@"Loading....", @"")];
    
    if (self.isLatestApps == NO && self.isRandomApps == NO && self.isMostPopularApps == NO && self.isCydiaApps == NO) {
        [[ITHelper sharedInstance] getAllAppsForCat:@"ios" page:self.currentPage withCompletion:^(NSArray *allApps, NSError *error) {
            
            if (allApps && !error)
            {
                if (appsArray.count < 1)
                {
                    appsArray = [allApps mutableCopy];
                    [_gridView reloadData];
                    
                }
                else if (![self addNewPostsFromArray:allApps])
                {
                    // If we had no new items, move back one page
                    if (self.currentPage > 0) self.currentPage--;
                }
            } else
            {
                // // NSLog(@"Error: %@", error);
            }
            self.isRefreshing = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [KSToastView dismissToastView];
        }];
    } else if (self.isLatestApps == YES && self.isRandomApps == NO && self.isMostPopularApps == NO && self.isCydiaApps == NO) {
        [[ITHelper sharedInstance] getAllAppsForCat:@"ios" page:self.currentPage withCompletion:^(NSArray *allApps, NSError *error) {
            
            if (allApps && !error)
            {
                if (appsArray.count < 1)
                {
                    appsArray = [allApps mutableCopy];
                    [_gridView reloadData];
                }
                else if (![self addNewPostsFromArray:allApps])
                {
                    // If we had no new items, move back one page
                    if (self.currentPage > 0) self.currentPage--;
                }
            } else
            {
                // // NSLog(@"Error: %@", error);
            }
            self.isRefreshing = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [KSToastView dismissToastView];
        }];
    } else if (self.isLatestApps == NO && self.isRandomApps == YES && self.isMostPopularApps == NO && self.isCydiaApps == NO) {
        [[ITHelper sharedInstance] getAllAppsForOrder:@"clicks_year" page:self.currentPage andCat:@"ios" withCompletion:^(NSArray *allApps, NSError *error) {
            if (allApps && !error)
            {
                if (appsArray.count < 1)
                {
                    appsArray = [allApps mutableCopy];
                    [_gridView reloadData];
                }
                else if (![self addNewPostsFromArray:allApps])
                {
                    // If we had no new items, move back one page
                    if (self.currentPage > 0) self.currentPage--;
                }
            } else
            {
                // // NSLog(@"Error: %@", error);
            }
            self.isRefreshing = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [KSToastView dismissToastView];
        }];
    } else if (self.isLatestApps == NO && self.isRandomApps == NO && self.isMostPopularApps == YES && self.isCydiaApps == NO) {
        [[ITHelper sharedInstance] getAllAppsForOrder:@"clicks_week" page:self.currentPage andCat:@"ios" withCompletion:^(NSArray *allApps, NSError *error) {
            if (allApps && !error)
            {
                if (appsArray.count < 1)
                {
                    appsArray = [allApps mutableCopy];
                    [_gridView reloadData];
                }
                else if (![self addNewPostsFromArray:allApps])
                {
                    // If we had no new items, move back one page
                    if (self.currentPage > 0) self.currentPage--;
                }
            } else
            {
                // // NSLog(@"Error: %@", error);
            }
            self.isRefreshing = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [KSToastView dismissToastView];
        }];
    } else if (self.isLatestApps == NO && self.isRandomApps == NO && self.isMostPopularApps == NO && self.isCydiaApps == YES) {
        [[ITHelper sharedInstance] getAllAppsForCydiaCat:@"cydia" page:self.currentPage withCompletion:^(NSArray *allApps, NSError *error) {
            if (allApps && !error)
            {
                if (appsArray.count < 1)
                {
                    appsArray = [allApps mutableCopy];
                    [_gridView reloadData];
                }
                else if (![self addNewPostsCydiaFromArray:allApps])
                {
                    // If we had no new items, move back one page
                    if (self.currentPage > 0) self.currentPage--;
                }
            } else
            {
                // // NSLog(@"Error: %@", error);
            }
            self.isRefreshing = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [KSToastView dismissToastView];
        }];
    }
    
}

- (BOOL)addNewPostsCydiaFromArray:(NSArray*)posts
{
    // Only add new posts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appTrackID == appTrackID", appsArray];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    for (ITAppObject *newPost in resultsArray)
    {
        [appsArray insertObject:newPost atIndex:appsArray.count];
        
        [_gridView reloadData];
    }
    
    return YES;
}

- (BOOL)addNewPostsFromArray:(NSArray*)posts
{
    // Only add new posts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appID == appID", appsArray];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    for (ITAppObject *newPost in resultsArray)
    {
        [appsArray insertObject:newPost atIndex:appsArray.count];
        
        [_gridView reloadData];
    }
    
    return YES;
}

- (BOOL)addNewPostsFromFliterArray:(NSArray*)posts
{
    // Only add new posts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appID == appID", filteredObjects];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    for (ITAppObject *newPost in resultsArray)
    {
        [filteredObjects insertObject:newPost atIndex:filteredObjects.count];
        
        [_gridView reloadData];
        [KSToastView dismissToastView];
    }
    
    return YES;
}

#pragma mark - GridView delegate
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView
{
    unsigned long CellsNumbers;
    if (isFiltered) {
        CellsNumbers = filteredObjects.count;
    } else {
        CellsNumbers = [appsArray count];
    }
    return CellsNumbers;
}

- (MMGridViewCell *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index
{
    MMGridViewDefaultCell *cell = [[MMGridViewDefaultCell alloc] initWithFrame:CGRectNull];
    ITAppObject *app;
    if (isFiltered) {
        app = filteredObjects[index];
    } else {
        app = appsArray[index];
    }
//    if (![app.appInfo[@"last_parse_itunes"] isKindOfClass:[NSNull class]]) {
//        NSData *data = [app.appInfo[@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
//        id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        // // NSLog(@"******** %@", dict);
//        UIImage *image = [ITHelper makeImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"artworkUrl512"]]]] toThumbnailOfSize:CGSizeMake(35, 35)];
//        
//        cell.appImageView.image = image;
//        cell.textLabel.text = [NSString stringWithFormat:@"%@", app.appName];
//        cell.backgroundView.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_bg"]];
//        
//    } else {
        UIImage *image = [ITHelper makeImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:app.appIcon]]] toThumbnailOfSize:CGSizeMake(35, 35)];
        
        cell.appImageView.image = image;
        cell.textLabel.text = [NSString stringWithFormat:@"%@", app.appName];
        cell.backgroundView.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_bg"]];
//    }
    return cell;
}

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index {
    
}

- (void)gridView:(MMGridView *)gridView didDoubleTapCell:(MMGridViewDefaultCell *)cell atIndex:(NSUInteger)index
{
    
    
}

- (void)gridView:(MMGridView *)gridView changedPageToIndex:(NSUInteger)index {
    
}

-(BOOL)canLoadMoreForGrid
{
    return YES;
}

- (void)gridView:(MMGridView *)gridView editValueChanged:(MMGridViewDefaultCell *)cell atIndex:(NSUInteger)index {
    
}

-(void)loadMoreForGrid
{
    // // NSLog(@"******** Refresh");
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
