//
//  BAListSearchViewController.m
//  baytapps
//
//  Created by iMokhles on 25/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BATweaksViewController.h"
#import "BAAppCell.h"
#import "KSToastView.h"
#import "BAHelper.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "BAColorsHelper.h"
#import "KSToastView.h"
#import "ITHelper.h"
#import "BAAppCell.h"
#import "AppDescriptionViewController.h"
#import "AppHostersViewController.h"

@interface BATweaksViewController () <UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate> {
    NSMutableArray *codesArray;
    NSMutableArray *filteredObjects;
    NSMutableArray *filteredObjectsSearch;
    BOOL isFiltered;
    
    BOOL isSearchBarVisible;
    DGActivityIndicatorView *activityIndicator;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation BATweaksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    _isCydiaApps = YES;
    [self setupTableView];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
    self.currentPageSearch = 0;
    self.currentPage = 0;
    [self loadApps];
    [self setup_SearchBar];
    [self.mainTableView reloadData];
    
    _refreshView = [LGRefreshView refreshViewWithScrollView:self.mainTableView delegate:self];
    [_refreshView setTintColor:[BAColorsHelper ba_whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
}
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (isSearchBarVisible) {
        [self searchButtonTapped:nil];
    }
    [self.navigationController.navigationBar setOpaque:NO];
}

- (void)setup_SearchBar {
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.backgroundColor = [UIColor clearColor];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[BAColorsHelper ba_whiteColor]];
    NSDictionary *placeholderAttributes = @{
                                            NSForegroundColorAttributeName: [BAColorsHelper ba_whiteColor],
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
                                            };
    
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.searchBar.placeholder
                                                                                attributes:placeholderAttributes];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAttributedPlaceholder:attributedPlaceholder];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor clearColor]];
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    // To change background color
    searchField.backgroundColor = [UIColor clearColor];
    searchField.textColor = [BAColorsHelper ba_whiteColor];
    //    UIImage *searchIcon = [self.searchBar imageForSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    //    searchIcon = [searchIcon imageTintedWithColor:[UIColor whiteColor]];
    
    UIImageView *leftImageView = (UIImageView *)searchField.leftView;
    leftImageView.image = [leftImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    leftImageView.tintColor = [BAColorsHelper ba_whiteColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar setShowsCancelButton:NO animated:YES];
        [self.searchBar resignFirstResponder];
        [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    isSearchBarVisible = YES;
}


- (void)setupTableView {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
    [self.searchBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    dispatch_async(dispatch_get_main_queue(), ^{
        // The search bar is hidden when the view becomes visible the first time
        [self.mainTableView setContentOffset:CGPointMake(0, 44)];
        self.mainTableView.tableHeaderView = self.searchBar;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadApps {
    
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    self.isRefreshing = YES;
    [KSToastView ks_showToast:NSLocalizedString(@"Loading....", @"")];
    [[ITHelper sharedInstance] getAllAppsForCydiaCat:@"cydia" page:self.currentPage withCompletion:^(NSArray *allApps, NSError *error) {
        if (allApps && !error)
        {
            if (codesArray.count < 1)
            {
                
                
                codesArray = [allApps mutableCopy];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appID == appID", codesArray];
                NSArray *resultsArray = [allApps filteredArrayUsingPredicate:predicate];
                
                
                [self.mainTableView reloadData];
            }
            else if (![self addNewPostsCydiaFromArray:allApps])
            {
                // If we had no new items, move back one page
                if (self.currentPage > 0) self.currentPage--;
            }
        } else
        {
            NSLog(@"Error: %@", error);
        }
        self.isRefreshing = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KSToastView dismissToastView];
    }];
}

- (BOOL)addNewPostsCydiaFromArray:(NSArray*)posts
{
    // Only add new posts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appID == appID", codesArray];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    for (ITAppObject *newPost in resultsArray)
    {
        NSLog(@"****** %@", newPost.appName);

        [codesArray insertObject:newPost atIndex:codesArray.count];
        
        [self.mainTableView reloadData];
    }
    
    return YES;
}

- (BOOL)addNewPostsFromArray:(NSArray*)posts
{
    // Only add new posts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appID == appID", codesArray];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    for (ITAppObject *newPost in resultsArray)
    {
        
        NSLog(@"****** %@", newPost.appName);
        [codesArray insertObject:newPost atIndex:codesArray.count];
        
        [self.mainTableView reloadData];
    }
    
    return YES;
}

- (BOOL)addNewPostsFromFliterArray:(NSArray*)posts
{
    // Only add new posts
    
//    NSLog(@"ARRAY: %@", filteredObjectsSearch);
    
    
//    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"NONE %@.appID == appID", filteredObjects], [NSPredicate predicateWithFormat:@"NONE %@.appVersion == appVersion", filteredObjects]]];
//    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.appID == appID", filteredObjects];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    for (ITAppObject *newPost in resultsArray)
    {
        [filteredObjects insertObject:newPost atIndex:filteredObjects.count];
        
        [self.mainTableView reloadData];
        [KSToastView dismissToastView];
    }
    
    return YES;
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
//    self.currentPage = self.currentPage++;
//    self.currentPageSearch = self.currentPageSearch++;
    [self loadApps];
    [refreshView endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    unsigned long CellsNumbers;
    if (isFiltered) {
        CellsNumbers = filteredObjects.count;
    } else {
        CellsNumbers = [codesArray count];
    }
    if (CellsNumbers == 0) {
        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:activityIndicator];
        [activityIndicator startAnimating];
    } else {
        [activityIndicator stopAnimating];
        [self.mainTableView setBackgroundView:nil];
        [self.mainTableView setBackgroundColor:[UIColor clearColor]];
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return CellsNumbers;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BAAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAAppCell"];
    
    ITAppObject *app;
    if (!self.isCydiaApps) {
        [cell.appAvailableView setHidden:YES];
        cell.isTweakCell = NO;
    } else if (self.isCydiaApps) {
        [cell.appAvailableView setHidden:NO];
        cell.isTweakCell = YES;
    }
    if (isFiltered) {
        app = filteredObjects[indexPath.section];
    } else {
        app = codesArray[indexPath.section];
    }
    [cell configureWithApp:app];
    
    if (isFiltered) {
        if (filteredObjects.count > 0 && indexPath.section == (filteredObjects.count - 1))
        {
            if (!self.isRefreshing)
            {
                NSLog(@"Refreshing..");
                
                self.currentPageSearch++;
                [KSToastView ks_showToast:NSLocalizedString(@"Loading....", @"")];
                [self searchBarSearchButtonClicked:self.searchBar];
            }
            else NSLog(@"Already refreshing!");
        }
    } else {
        if (codesArray.count > 0 && indexPath.section == (codesArray.count - 1))
        {
            if (!self.isRefreshing)
            {
                NSLog(@"Refreshing..");
                
                self.currentPage++;
                
                [self loadApps];
            }
            else NSLog(@"Already refreshing!");
        }
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ITAppObject *app;
    if (isFiltered) {
        app = filteredObjects[indexPath.section];
        AppDescriptionViewController *appDescrip = [self.storyboard instantiateViewControllerWithIdentifier:@"appDescrip"];
        [[ITHelper sharedInstance] getAppInfoFromItunes:app.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
            appDescrip.object = app;
            appDescrip.isCydiaApp = YES;
            @try {
                if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                    [self.navigationController pushViewController:appDescrip animated:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            } @catch (NSException * e) {
                // NSLog(@"Exception: %@", e);
                [self.navigationController popToViewController:appDescrip animated:YES];
            } @finally {
                // NSLog(@"finally");
            }

//            if (allApps.count > 0) {
//                if (![app.appInfo[@"id"] isEqualToString:@"0"]) {
//                    appDescrip.object = app;
//                    [self.navigationController pushViewController:appDescrip animated:YES];
//                }
//            } else {
//                AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
//                appHosters.app = app;
//                if (!self.isCydiaApps) {
//                    appHosters.sectionName = @"ios";
//                } else {
//                    appHosters.sectionName = @"cydia";
//                }
//                
//                [self.navigationController pushViewController:appHosters animated:YES];
//            }
            
        }];
    } else {
        app = codesArray[indexPath.section];
        AppDescriptionViewController *appDescrip = [self.storyboard instantiateViewControllerWithIdentifier:@"appDescrip"];
        [[ITHelper sharedInstance] getAppInfoFromItunes:app.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
            appDescrip.object = app;
            appDescrip.isCydiaApp = YES;
            @try {
                if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                    [self.navigationController pushViewController:appDescrip animated:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            } @catch (NSException * e) {
                // NSLog(@"Exception: %@", e);
                [self.navigationController popToViewController:appDescrip animated:YES];
            } @finally {
                // NSLog(@"finally");
            }

//            if (allApps.count > 0) {
//                if (![app.appInfo[@"id"] isEqualToString:@"0"]) {
//                    appDescrip.object = app;
//                    [self.navigationController pushViewController:appDescrip animated:YES];
//                }
//            } else {
//                AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
//                appHosters.app = app;
//                if (!self.isCydiaApps) {
//                    appHosters.sectionName = @"ios";
//                } else {
//                    appHosters.sectionName = @"cydia";
//                }
//                [self.navigationController pushViewController:appHosters animated:YES];
//            }
            
        }];
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(BAAppCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [cell setSelectedBackgroundView:bgColorView];
}
#pragma mark - SeachBar delegate

-(void)searchBar:(UISearchBar*)searchBar_ textDidChange:(NSString*)text {
//    [self searchApp:text];
    
    if (text.length == 0) {
        isFiltered = NO;
        filteredObjects = nil;
        
        self.currentPageSearch = 0;
        self.currentPage = 0;
        [self loadApps];
        [self setup_SearchBar];
        [self.mainTableView reloadData];
        
    } else {
        isFiltered = YES;
        if (_isCydiaApps) {
            isFiltered = YES;
            self.isRefreshing = YES;
            
            [[ITHelper sharedInstance] searchTweakedAppsWithKeyword:self.searchBar.text page:self.currentPageSearch withCompletion:^(NSArray *allApps, NSError *error) {
                if (error == nil) {
                    if (allApps.count > 0) {
                        filteredObjectsSearch = [[NSMutableArray alloc] init];
                        for (int i =0; i < [allApps count]; i++) {
                            ITAppObject *app = [allApps objectAtIndex:i];
                            if ([app.appName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                            {
                                if (![filteredObjectsSearch containsObject:[allApps objectAtIndex:i]]) {
                                    [filteredObjectsSearch addObject:[allApps objectAtIndex:i]];
                                }
                            }
                        }
                        //                        if (self.currentPageSearch == 1)
                        //                        {
                        filteredObjects = filteredObjectsSearch;
                        [self.mainTableView reloadData];
                        //                        }
                        //                        else if (![self addNewPostsFromFliterArray:allApps])
                        //                        {
                        //                            // If we had no new items, move back one page
                        //                            if (self.currentPageSearch > 0) self.currentPageSearch--;
                        //                        }
                        //                        self.isRefreshing = NO;
                        
                    }
                }
            }];
        }
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
    searchBar_.text = @"";
    if (searchBar_.text.length == 0 || [searchBar_.text isEqualToString:@""]) {
        isFiltered = NO;
        filteredObjects = nil;
        
        self.currentPageSearch = 0;
        self.currentPage = 0;
        [self loadApps];
        [self setup_SearchBar];
        [self.mainTableView reloadData];
    } else {
        isFiltered = YES;
        
    }
    [self.mainTableView reloadData];
    
    [searchBar_ setShowsCancelButton:NO animated:YES];
    [searchBar_ resignFirstResponder];
    
    [self searchButtonTapped:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    if (self.searchBar.text.length == 0) {
        isFiltered = NO;
    } else {
        if (_isCydiaApps) {
            isFiltered = YES;
            self.isRefreshing = YES;
            
            [[ITHelper sharedInstance] searchTweakedAppsWithKeyword:self.searchBar.text page:self.currentPageSearch withCompletion:^(NSArray *allApps, NSError *error) {
                
                if (allApps && !error)
                {
                    if (filteredObjects.count < 1)
                    {
                        filteredObjects = [allApps mutableCopy];
                        [self.mainTableView reloadData];
                    }
                    else if (![self addNewPostsFromFliterArray:allApps])
                    {
                        // If we had no new items, move back one page
                        if (self.currentPageSearch > 0) self.currentPageSearch--;
                    }
                } else
                {
                    NSLog(@"Error: %@", error);
                }
                self.isRefreshing = NO;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [KSToastView dismissToastView];
                
                //                if (error == nil) {
                //
                //
                //                    if (allApps.count > 0) {
                //                        filteredObjects = [[NSMutableArray alloc] init];
                //                        for (int i =0; i < [allApps count]; i++) {
                //                            ITAppObject *app = [allApps objectAtIndex:i];
                //
                //
                //
                //                            if ([app.appName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                //                            {
                //
                //                                if (![filteredObjects containsObject:[allApps objectAtIndex:i]]) {
                //
                //                                    [filteredObjects addObject:[allApps objectAtIndex:i]];
                //                                }
                //                            }
                //                        }
                //
                //                        NSLog(@"***** %@", filteredObjectsSearch);
                //
                //                        if (filteredObjects.count < 1)
                //                        {
                ////                            filteredObjects = filteredObjectsSearch;
                //                            [self.mainTableView reloadData];
                //                        }
                //                        else if (![self addNewPostsFromFliterArray:allApps])
                //                        {
                //                            // If we had no new items, move back one page
                //                            if (self.currentPageSearch > 0) self.currentPageSearch--;
                //                        }
                //                        
                //                        
                //                        self.isRefreshing = NO;
                //                        
                //                    }
                //                }
            }];
        }
    }
    [self.mainTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelled {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    filteredObjects = nil;
    [self.mainTableView reloadData];
}
- (IBAction)searchButtonTapped:(UIButton *)sender {
    if (CGPointEqualToPoint(self.mainTableView.contentOffset, CGPointMake(0, 0)) || [_searchBar isFirstResponder]) {
        isSearchBarVisible = YES;
    }
    if (!isSearchBarVisible) {
        isSearchBarVisible = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar setShowsCancelButton:YES animated:YES];
            [self.searchBar becomeFirstResponder];
            [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        });
    } else {
        isSearchBarVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar setShowsCancelButton:NO animated:YES];
            [self.searchBar resignFirstResponder];
            [self.mainTableView setContentOffset:CGPointMake(0, 44) animated:YES];
        });
    }
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
