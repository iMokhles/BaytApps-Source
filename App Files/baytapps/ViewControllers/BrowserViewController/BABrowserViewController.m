//
//  BAListSearchViewController.m
//  baytapps
//
//  Created by iMokhles on 25/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BABrowserViewController.h"
#import "BABrowserAppCell.h"
#import "KSToastView.h"
#import "BAHelper.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "BAColorsHelper.h"
#import "KSToastView.h"
#import "ITHelper.h"
#import "AppDescriptionViewController.h"
#import "AppHostersViewController.h"
#import "DZNWebViewController.h"
#import "ITServerHelper.h"
#import "AppConstant.h"
#import "Definations.h"
#import "DAProgressOverlayView.h"
#import "JGActionSheet.h"
#import "ITConstants.h"
#import "BANewApi.h"

@interface BABrowserViewController ()<UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate> {
    NSMutableArray *codesArray;
    NSMutableArray *filteredObjects;
    NSMutableArray *filteredObjectsSearch;
    BOOL isFiltered;
    NSMutableArray *appsArray;

    BOOL isSearchBarVisible;
    DGActivityIndicatorView *activityIndicator;
    NSString *loadedLink;
    BOOL isDownloading;

}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet DAProgressOverlayView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *appIconView;

@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation BABrowserViewController
- (void)setupBrowserView {
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com/"];
    
    DZNWebViewController *WVC = [[DZNWebViewController alloc] initWithURL:URL];
    WVC.babrowserviewcontroller = self;
    
    UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:WVC];
    //    [NC.view setFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    
    WVC.supportedWebNavigationTools = DZNWebNavigationToolAll;
    WVC.supportedWebActions = DZNWebActionAll;
    WVC.webNavigationPrompt = DZNWebNavigationPromptAll;
    WVC.showLoadingProgress = YES;
    WVC.allowHistory = YES;
    WVC.hideBarsWithGestures = NO;
    //WVC.allowCancelButton = NO;
    
    //    [self.view addSubview:NC.view];
    [self presentViewController:NC animated:NO completion:NULL];
}
- (void) loadedLinkProcess: (NSString*)link{
    // NSLog(@"got link:%@", link);
    loadedLink = link;
    //[ITServerHelper removeAllRequestedAppsForUser:[PFUser currentUser]];
    
    NSString *appIcon = @"https://cloud.baytapps.net/app/bayt_icon.png";
    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    
    NSString *appUniqueId = [NSString stringWithFormat:@"ba_%ld",unixTime];
    
    ITAppObject *appObject = [[ITAppObject alloc] init];
    appObject.appID = [NSString stringWithFormat:@"net.baytapps.browser_%@", appUniqueId];
    appObject.appTrackID = appUniqueId;
    
    [PFUser currentUser][@"requested_appIconFile"] = appIcon ;//stringByReplacingOccurrencesOfString:@"net/" withString:@"net:1337/"];
    [PFUser currentUser][@"requested_appNameString"] = appUniqueId;
    [PFUser currentUser][@"requested_appInfo"] = @{
                                                   @"last_parse_itunes": [NSNull null]};
    
    [PFUser currentUser][@"requested_appDuplicates"] = [NSString stringWithFormat:@"%li", (long)1];
    //[PFUser currentUser][@"requested_appSize"] = currentAppSize;
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [KVNProgress showError];
            [ITHelper showErrorMessageFrom:self withError:error];
        } else {
            if (succeeded) {
                [[BANewApi sharedInstance] downloadIPAFileForApp:appObject appIcon:appIcon appName:appUniqueId appLink:loadedLink appVersion:@"1.0" hostName:loadedLink duplicate:2 completionBlock:^(NSData *data, NSURLResponse *response) {
                    //
                    
                    NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    // NSLog(@"******* COMP %@", strr);
                } errorBlock:^(NSError *error) {
                    // NSLog(@"****** error: %@", error);
                    //
                } uploadPorgressBlock:^(float progress) {
                    // NSLog(@"upload****** progress: %f", progress);
                    //
                } downloadProgressBlock:^(float progress, NSData *data) {
                    //
                    // NSLog(@"download****** progress: %f", progress);
                    NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    // NSLog(@"****** PROG: %@", strr);
                }];
            }
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.appIconView.layer.masksToBounds = YES;
    self.appIconView.layer.cornerRadius = 25.0;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 25.0;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
    self.currentPageSearch = 1;
    self.currentPage = 1;
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMethod:) name:NOTIFICATION_TO_DOWNLOAD_APP object:nil];
    [self.statusLabel setText:@"......"];
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    if ([BAHelper isIPHONE4] || [BAHelper isIPHONE5]) {
        self.slidingViewController.anchorRightPeekAmount  = 100.0;
    } else {
        if ([BAHelper isIPHONE6]) {
            self.slidingViewController.anchorRightPeekAmount  = 100.0;
        } else if ([BAHelper isIPHONE6PLUS]) {
            self.slidingViewController.anchorRightPeekAmount  = 150.0;
        } else if ([BAHelper isIPAD]) {
            self.slidingViewController.anchorRightPeekAmount  = 350.0;
        }
    }
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScale tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
    
    [self loadUserAppsManager];
    [self.mainTableView reloadData];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    _refreshView = [LGRefreshView refreshViewWithScrollView:self.mainTableView delegate:self];
    [_refreshView setTintColor:[BAColorsHelper ba_whiteColor]];

    if (loadedLink == nil) {
        [self setupBrowserView];
        
    }
   
}
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}
- (IBAction)searchButtonClick:(id)sender {
    [self setupBrowserView];

}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
  
    [self.navigationController.navigationBar setOpaque:NO];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)notificationMethod:(NSNotification *)notification {
    NSDictionary *userDict = notification.userInfo;
    NSString *message = userDict[@"message"];
    NSString *progressString = userDict[@"progress"];
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
    if (progressString.length > 0) {
        if ([message containsString:@"Ready To Install"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:[progressString floatValue]];
                if ([progressString floatValue] >= 1) {
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                }
                UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"appManagerNavigationController"];
                [ITHelper setMainRootViewController:profileNavigationController];

                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownloading"];
                [self.statusLabel setText:[NSString stringWithFormat:@"Ready To Install"]]; // NSLocalizedString(@"Done App...", @"")
            });
            
        } else if ([[message lowercaseString] containsString:@"failed"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:[progressString floatValue]];
                if ([progressString floatValue] >= 1) {
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                }
                [self.statusLabel setText:message];
            });
            [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Choose another link", @"")];
//            PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
//            [queryAppsDB whereKey:APP_DB_VERSIONS_APP_ID equalTo:[self.requestedApp.appID lowercaseString]];
//            [queryAppsDB whereKey:APP_DB_VERSIONS_VERSION_STRING equalTo:[self.appVersion lowercaseString]];
//            [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//                if (error == nil) {
//                    if (objects.count > 0) {
//                        PFObject *currentApp = [objects objectAtIndex:0];
//                        [currentApp deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                            if (error == nil) {
//                                if (succeeded) {
//                                    [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Choose another link", @"")];
//                                }
//                            } else {
//                                [ITHelper showErrorMessageFrom:self withError:error];
//                            }
//                        }];
//                    }
//                }
//            }];
        } else {
            isDownloading = NO;
            if ([message containsString:@"Downloading"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isDownloading"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:[progressString floatValue]];
                if ([progressString floatValue] >= 1) {
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                }
                [self.statusLabel setText:message];
            });
            
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:0.60f];
            [self.statusLabel setText:message];
        });
        
    }
    
    
}
- (void)loadUserAppsManager {
    [ITServerHelper getAllRequestedAppsForUser:[PFUser currentUser] withBlock:^(BOOL succeeded, NSArray *objects, NSError *error) {
        if (error == nil) {
            if (succeeded) {
                if (objects.count > 0) {
                    appsArray = [objects mutableCopy];
                    [self.mainTableView reloadData];
                    self.isRefreshing = NO;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                } else {
                    appsArray = [objects mutableCopy];
                    [self.mainTableView reloadData];
                    self.isRefreshing = NO;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (appsArray.count == 0) {
        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:activityIndicator];
        [activityIndicator startAnimating];
        return 0;
    } else {
        [activityIndicator stopAnimating];
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:nil];
        return appsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BABrowserAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BABrowserAppCell"];
    [cell.appAvailableView setHidden:NO];
    [cell.appNameLabel setFont:[UIFont systemFontOfSize:21]];
    PFObject *app = appsArray[indexPath.section];
    [cell configureWithObject:app];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *app = appsArray[indexPath.section];
    // NSLog(@"***** %@", app[USER_APP_MANAGER_APP_LINK]);
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:app[USER_APP_MANAGER_APP_LINK]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app[USER_APP_MANAGER_APP_LINK]]];
    }
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:app[USER_APP_MANAGER_APP_LINK]]];
    
    //    PFQuery *query = [PFQuery queryWithClassName:USER_APP_MANAGER_CLASS_NAME];
    //    PFUser *user = [PFUser currentUser];
    //
    //    [query whereKey:APP_USER_POINTER equalTo:user];
    //    [query whereKey:APP_ID equalTo:app[APP_ID]];
    //    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    //        //        // // NSLog(@"******** 1: ERROR: %@", error.localizedDescription);
    //        if (error == nil) {
    //
    //            PFObject *obj = [objects objectAtIndex:0];
    //            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    //                [self loadUserAppsManager];
    //
    //            }];
    //
    //        }
    //    }];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(BABrowserAppCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [cell setSelectedBackgroundView:bgColorView];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}
#pragma mark - LGRefreshViewDelegate
- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    [self loadUserAppsManager];
    //[self downloadAggain];
    [refreshView endRefreshing];
}

#pragma mark - Buttons Actions


- (IBAction)moreButtonTapped:(UIButton *)sender {
    
    NSString *provisioningPath1 = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath1]) {
        return;
    }
    
    NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = provisioningPath1;
        if (!provisioningPath) {
            mobileProvision = @{};
            return;
        }
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSISOLatin1StringEncoding error:NULL];
        if (!binaryString) {
            return;
        }
        NSScanner *scanner = [NSScanner scannerWithString:binaryString];
        BOOL ok = [scanner scanUpToString:@"<plist" intoString:nil];
        if (!ok) { // // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return;
        }
    }
    
    NSDictionary *profile = mobileProvision;
    NSString *teamID = profile[@"UUID"];
    NSString *teamID2 = [profile[@"TeamIdentifier"] objectAtIndex:0];
    NSString *accountType;
    accountType = @"other";
    if (teamID2.length > 0) {
        if ([teamID2 isEqualToString:@"USM32L424X"]) accountType = @"ipa";
        if ([teamID2 isEqualToString:@"2R5JB2FB9E"]) accountType = @"ipa1";
        if ([teamID2 isEqualToString:@"J6D5BK3T6D"]) accountType = @"ipa2";
    } else {
        accountType = @"other";
    }
    
    if (appsArray.count > 0) {
        JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:APP_NAME message:NSLocalizedString(@"Remove all apps?", @"") buttonTitles:@[NSLocalizedString(@"Yes?", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
        JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
        
        [section1 setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:0];
        
        NSArray *sections = @[section1, cancelSection];
        
        JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
        
        [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    //                    NSString *username = [PFUser currentUser].username;
                    //UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
                    //                    NSString *password = [key stringForKey:ENCRYPT_TEXT_KEY()];
                    
                    NSString *apiURL = [NSString stringWithFormat:@"%@/index.php", kCloudAPI];
                    NSString *customURLString = [NSString stringWithFormat:
                                                 @"usertoken=%@"
                                                 @"&removeRequestApps=yes"
                                                 @"&accType=%@"
                                                 @"&devicetoken=%@",
                                                 EncryptText(@"", [PFUser currentUser].sessionToken),
                                                 EncryptText(@"", accountType),
                                                 EncryptText(@"", accountType)];
                    
                    [[ITHelper sharedInstance] newPostMethodWithURL:apiURL postString:customURLString completionBlock:^(NSData *data, NSURLResponse *response) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [ITServerHelper removeAllRequestedAppsForUser:[PFUser currentUser]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self loadUserAppsManager];
                            });
                            
                        });
                        
                    } errorBlock:^(NSError *error) {
                        //
                    } uploadPorgressBlock:^(float progress) {
                        //
                    } downloadProgressBlock:^(float progress, NSData *data) {
                        //
                    }];
                }
                [sheet dismissAnimated:YES];
            } else {
                [sheet dismissAnimated:YES];
            }
        }];
        if ([BAHelper isIPAD]) {
            [sheet showFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0) inView:self.view animated:YES];
        } else {
            [sheet showInView:self.view animated:YES];
        }
    }
}

@end
