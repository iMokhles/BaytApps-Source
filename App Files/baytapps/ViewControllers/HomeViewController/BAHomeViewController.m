//
//  BAHomeViewController.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAHomeViewController.h"
#import "BAHelper.h"
#import "ITTableScrollAppsCell.h"
#import "CACheckConnection.h"
#import "ITHelper.h"
#import "ITServerHelper.h"
#import "DGActivityIndicatorView.h"
#import "BAColorsHelper.h"
#import "ARScrollAppsCell.h"
#import "AppDescriptionViewController.h"
#import "AppHostersViewController.h"
#import "BATweaksViewController.h"
//#import "UICKeyChainStore.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import "ITConstants.h"
#import "AppDelegate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
// views
#import "BAGridSearchViewController.h"
#import "BAListSearchViewController.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import "NDIntroView.h"
#import "JGProgressHUD.h"
#import <SSKeychain/SSKeychain.h>
#import <DTTJailbreakDetection/DTTJailbreakDetection.h>
#import "CustomBadge.h"

#define Width [UIScreen mainScreen].bounds.size.width
@interface BAHomeViewController () <NDIntroViewDelegate, NewPagedFlowViewDelegate, NewPagedFlowViewDataSource> {
    NSArray *latestApps;
    NSArray *mostPopulerApps;
    NSArray *tweaksApps;
    NSArray *betterApps;
    
    AppDescriptionViewController *appDescrip;
    // activtiyView
    DGActivityIndicatorView *activityIndicator;
    UITapGestureRecognizer *tapGesture;
    
    NewPagedFlowView *pageFlowView;
    
    JGProgressHUD *HUD;
    CustomBadge *badge5;
}
@property (strong, nonatomic) IBOutlet UIView *bannerTopView;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;

/**
 *  图片数组
 */
@property (nonatomic, strong) NSMutableArray *imageArray;

/**
 *  指示label
 */
@property (nonatomic, strong) UILabel *indicateLabel;

@property (strong, nonatomic) NDIntroView *introView;
@end

@implementation BAHomeViewController

- (void)toogleMenu {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController]) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

#pragma mark - NDIntroView methods

-(void)startIntro {
    NSArray *pageContentArray = @[@{kNDIntroPageTitle : @"Edit and Duplicate",
                                    kNDIntroPageDescription : @"Now you can easily edit app name or icon and duplicate it to unlimited copies",
                                    kNDIntroPageImageName : @"AppIcon60x60"
                                    },
                                  @{kNDIntroPageTitle : @"Timeline and profiles",
                                    kNDIntroPageDescription : @"A great community to share apps between our customers you can see other's customers favorites apps and use them",
                                    kNDIntroPageImageName : @"AppIcon60x60"
                                    },
                                  @{kNDIntroPageTitle : @"Live Support",
                                    kNDIntroPageDescription : @"A great way to contact our support team directly through the app itself",
                                    kNDIntroPageImageName : @"AppIcon60x60"
                                    },
                                  @{kNDIntroPageTitle : @"Tweaked Apps",
                                    kNDIntroPageDescription : @"Apps with jailbreak tweaks without jailbreak also apps aren't available on the AppStore",
                                    kNDIntroPageImageName : @"AppIcon60x60"
                                    },
                                  @{kNDIntroPageTitle : @"Settings",
                                    kNDIntroPageDescription : @"We offer new way to customize your app background with a simple images search engine built inside the settings page",
                                    kNDIntroPageImageName : @"AppIcon60x60"
                                    },
                                  @{kNDIntroPageTitle : @"Welcome",
                                    kNDIntroPageImageName : @"AppIcon60x60",
                                    kNDIntroPageTitleLabelHeightConstraintValue : @0,
                                    kNDIntroPageImageHorizontalConstraintValue : @-40
                                    }
                                  ];
    self.introView = [[NDIntroView alloc] initWithFrame:self.view.frame parallaxImage:[UIImage imageNamed:@"main_bg_6"] andData:pageContentArray];
    self.introView.delegate = self;
    [self.view addSubview:self.introView];
}

-(void)launchAppButtonPressed {
    [UIView animateWithDuration:0.7f animations:^{
        self.introView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introView removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isIntroDone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [PFUser currentUser][USER_DEVICE_ID] = [self getUniqueDeviceIdentifierAsString];
    if ([PFUser currentUser] != nil) {
        [PFUser currentUser][USER_DEVICE_TOKEN] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
        [PFUser currentUser][USER_APP_VERSION] = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        [PFUser currentUser][USER_DEVICE_PLAYER_ID] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_PLAYER_ID]];
        NSString* passwordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASS_WORD];
        
        [PFUser currentUser][USER_Vio] = EncryptText(@"", passwordString);
        [[PFUser currentUser] saveInBackground];
    }
    [[PFUser currentUser] saveInBackground];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isIntroDone"] boolValue] == NO) {
        [self startIntro];
    }
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
//    if ([PFUser currentUser] != nil) {
//        [CrashlyticsKit setObjectValue:[PFUser currentUser][USER_TEAM_ID] forKey:USER_TEAM_ID];
//        [CrashlyticsKit setObjectValue:[PFUser currentUser][USER_DEVICE_TYPE] forKey:USER_DEVICE_TYPE];
//        [CrashlyticsKit setObjectValue:[PFUser currentUser][USER_EXPIRY_DATE] forKey:USER_EXPIRY_DATE];
//        [CrashlyticsKit setUserIdentifier:[PFUser currentUser][USER_DEVICE_ID]];
//        [CrashlyticsKit setUserEmail:[PFUser currentUser].email];
//        [CrashlyticsKit setUserName:[PFUser currentUser].username];
//    }
//    
//    
//    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
//    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
//        [ITHelper showErrorAlert:@"Something wrong with your Device verifications"];
//        return;
//    }
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toogleMenu)];
    [self.view addGestureRecognizer:tapGesture];
    
    //    [self setupUI];
    
    //    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
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
    
    NSString* dateAvaiable =  [[NSUserDefaults standardUserDefaults]  objectForKey:@"RegisteredDate"];
    // convert to date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // ignore +11 and use timezone name instead of seconds from gmt
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *dte = [dateFormat dateFromString:dateAvaiable];
    // NSLog(@"Date: %@", dte);
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 366;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    // NSLog(@"nextDate: %@ ...", nextDate);
    
    
    long dif = [[NSDate date] timeIntervalSinceDate:nextDate];
    
    if (dif > 0) {
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        app.isAvailableDuration = YES;
    }else{
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        app.isAvailableDuration = NO;
    }

    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
//
//    if ([[CACheckConnection sharedManager] isUnreachable]) {
//        [ITHelper showAlertViewForExtFromViewController:self WithTitle:APP_NAME msg:NSLocalizedString(@"Network error", @"") withActions:@[] andTextField:NO];
//    } else {
    
        [self loadApps];
   // }
}

- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDescrip = [self.storyboard instantiateViewControllerWithIdentifier:@"appDescrip"];
    // Do any additional setup after loading the view.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    [self.mainTableView setAllowsSelection:NO];
    
   badge5 = [CustomBadge customBadgeWithString:@"1"];
    CGPoint point = CGPointMake(self.menu_btrn.frame.size.width -badge5.frame.size.width/2, 0);
    CGSize size = CGSizeMake(badge5.frame.size.width, badge5.frame.size.height);
    CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
    [badge5 setFrame:rect];
    badge5.hidden = YES;
    [self.menu_btrn addSubview:badge5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.badge = badge5;
    [self setupUI];
}
- (void)setupUI {
    //    // // NSLog(@"******** opened home");
//    for (int index = 7150; index < 7155; index++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"IMG_%d",index]];
//        [self.imageArray addObject:image];
//    }
//    
//    [self setupUI_sliding];
}

- (void)loadApps {
    
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    
    [[ITHelper sharedInstance] getAllAppsForOrder:@"clicks_week" page:1 andCat:@"ios" withCompletion:^(NSArray *allApps, NSError *error) {
        NSMutableArray *mostPopulerArray = [NSMutableArray new];
        for (ITAppObject *app in allApps) {
            ITAppView *item = [[ITAppView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:app.appIcon] title:app.appName subTitle:app.appVersion andApp:app];
            if (![mostPopulerArray containsObject:item]) {
                [mostPopulerArray addObject:item];
            }
        }
        if (mostPopulerApps.count == 0) {
            mostPopulerApps = [mostPopulerArray copy];
        }
        
        [self.mainTableView reloadData];
        
       [self CheckingAbility];
    }];

    
    [[ITHelper sharedInstance] getAllLatestAppsWithCat:@"ios" withCompletion:^(NSArray *allApps, NSError *error) {
        NSMutableArray *latestArray = [NSMutableArray new];
        for (ITAppObject *app in allApps) {
            ITAppView *item = [[ITAppView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:app.appIcon] title:app.appName subTitle:app.appVersion andApp:app];
            if (![latestArray containsObject:item]) {
                [latestArray addObject:item];
            }
        }
        if (latestApps.count == 0) {
            latestApps = [latestArray copy];
        }
        
        [self.mainTableView reloadData];
    }];

    [[ITHelper sharedInstance] getAllAppsForOrder:@"clicks_year" page:1 andCat:@"ios" withCompletion:^(NSArray *allApps, NSError *error) {
        NSMutableArray *betterArray = [NSMutableArray new];
        for (ITAppObject *app in allApps) {
            ITAppView *item = [[ITAppView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:app.appIcon] title:app.appName subTitle:app.appVersion andApp:app];
            if (![betterArray containsObject:item]) {
                [betterArray addObject:item];
            }
        }
        if (betterApps.count == 0) {
            betterApps = [betterArray copy];
        }
    [self.mainTableView reloadData];
    }];
    
    [[ITHelper sharedInstance] getAllAppsForCydiaCat:@"cydia" page:0 withCompletion:^(NSArray *allApps, NSError *error) {
        if (error == nil) {
            if (allApps.count > 0) {
                NSMutableArray *tweakArray = [NSMutableArray new];
                for (ITAppObject *app in allApps) {
                    ITAppView *item = [[ITAppView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:app.appIcon] title:app.appName subTitle:app.appVersion andApp:app];
                    if (![tweakArray containsObject:item]) {
                        [tweakArray addObject:item];
                    }
                }
                
                if (tweaksApps.count == 0) {
                    tweaksApps = [tweakArray copy];
                }
                [self.mainTableView reloadData];
            }
        }
        
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)menuButtonTapped:(UIButton *)sender {
    //[self disabledUser];
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}
- (IBAction)searchTapped:(UIButton *)sender {
    //[self disabledUser];
    BAListSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchList"];
    searchVC.currentPage = 1;
    searchVC.previousPage = 1;
    searchVC.isMostPopularApps = NO;
    searchVC.isRandomApps = NO;
    searchVC.isLatestApps = YES;
    searchVC.isCydiaApps = NO;
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - UITableView Delegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // NSLog(@"----------------------------------------");
    // NSLog(@"latestApps.count : %lu",(unsigned long)latestApps.count);
    // NSLog(@"mostPopulerApps.count : %lu",(unsigned long)mostPopulerApps.count);
    // NSLog(@"tweaksApps.count : %lu",(unsigned long)tweaksApps.count);
    // NSLog(@"betterApps.count : %lu",(unsigned long)betterApps.count);
    
    //    if (latestApps.count == 0 || mostPopulerApps.count == 0 || betterApps.count == 0) {
    //        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
    //        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //        [self.mainTableView setBackgroundView:activityIndicator];
    //        [activityIndicator startAnimating];
    //        return 0;
    //    } else {
    //        [activityIndicator stopAnimating];
    //        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //        [self.mainTableView setBackgroundView:nil];
    //        return 3;
    //    }
    
//    if (latestApps.count == 0 && mostPopulerApps.count == 0 && tweaksApps.count == 0 && betterApps.count == 0) {
//        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
//        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//        [self.mainTableView setBackgroundView:activityIndicator];
//        [activityIndicator startAnimating];
//        return 0;
//    } else {
//        [activityIndicator stopAnimating];
//        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//        [self.mainTableView setBackgroundView:nil];
//        pageFlowView.hidden = YES;
//        return 4;
//    }
    return 4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        
        return 1;
    } else if (section == 1) {
        
        return 1;
    } else if (section == 2) {
        
        return 1;
    } else if (section == 3) {
        
        return 1;
    } else {
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *generalCellID = [NSString stringWithFormat:@"generalCellID_S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
    ARScrollAppsCell *cell = [tableView dequeueReusableCellWithIdentifier:generalCellID];
    if (cell==nil) {
        cell = [[ARScrollAppsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:generalCellID];
    }
    if (indexPath.section == 0) {
        [cell configureWithTitle:NSLocalizedString(@"Latest Apps", @"Latest Apps title") items:latestApps.mutableCopy];
        
        [cell setItemTappedBlock:^(ARScrollAppsCell *appCell, ITAppView *appView) {
           // [self disabledUser];
            
            [[ITHelper sharedInstance] getAppInfoFromItunes:appView.currentApp.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
                if (allApps.count > 0) {
                    if (![appView.currentApp.appInfo[@"id"] isEqualToString:@"0"]) {
                        appDescrip.object = appView.currentApp;
                        appDescrip.isCydiaApp = NO;
                        @try {
                            if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                                [self.navigationController pushViewController:appDescrip animated:YES];
                            } else {
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        } @catch (NSException * e) {
                            // // NSLog(@"Exception: %@", e);
                            [self.navigationController popToViewController:appDescrip animated:YES];
                        } @finally {
                            // // NSLog(@"finally");
                        }
                    }
                } else {
                    AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
                    appHosters.app = appView.currentApp;
                    appHosters.sectionName = @"ios";
                    [self.navigationController pushViewController:appHosters animated:YES];
                }
                
            }];
        }];
        [cell setShowAllTappedBlock:^(ARScrollAppsCell *appCell, UIButton *showButton) {
            //[self disabledUser];
            BAListSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchList"];
            searchVC.currentPage = 1;
            searchVC.previousPage = 1;
            searchVC.isMostPopularApps = NO;
            searchVC.isRandomApps = NO;
            searchVC.isLatestApps = YES;
            searchVC.isCydiaApps = NO;
            [self.navigationController pushViewController:searchVC animated:YES];
        }];
    } else if (indexPath.section == 1) {
        [cell configureWithTitle:NSLocalizedString(@"Most Popular", @"Popular Apps title") items:mostPopulerApps.mutableCopy];
        [cell setItemTappedBlock:^(ARScrollAppsCell *appCell, ITAppView *appView) {
            //[self disabledUser];
            [[ITHelper sharedInstance] getAppInfoFromItunes:appView.currentApp.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
                if (allApps.count > 0) {
                    if (![appView.currentApp.appInfo[@"id"] isEqualToString:@"0"]) {
                        appDescrip.object = appView.currentApp;
                        appDescrip.isCydiaApp = NO;
                        @try {
                            if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                                [self.navigationController pushViewController:appDescrip animated:YES];
                            } else {
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            
                        } @catch (NSException * e) {
                            // // NSLog(@"Exception: %@", e);
                            [self.navigationController popToViewController:appDescrip animated:YES];
                        } @finally {
                            // // NSLog(@"finally");
                        }
                    }
                } else {
                    AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
                    appHosters.app = appView.currentApp;
                    appHosters.sectionName = @"ios";
                    [self.navigationController pushViewController:appHosters animated:YES];
                }
            }];
        }];
        [cell setShowAllTappedBlock:^(ARScrollAppsCell *appCell, UIButton *showButton) {
            //[self disabledUser];
            BAListSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchList"];
            searchVC.currentPage = 1;
            searchVC.previousPage = 1;
            searchVC.isMostPopularApps = YES;
            searchVC.isRandomApps = NO;
            searchVC.isLatestApps = NO;
            searchVC.isCydiaApps = NO;
            [self.navigationController pushViewController:searchVC animated:YES];
        }];
    } else if (indexPath.section == 2) {
        [cell configureWithTitle:NSLocalizedString(@"Tweaks Apps", @"Tweaks Apps title") items:tweaksApps.mutableCopy];
        
        [cell setItemTappedBlock:^(ARScrollAppsCell *appCell, ITAppView *appView) {
            //[self disabledUser];
            appDescrip.object = appView.currentApp;
            appDescrip.isCydiaApp = YES;

            @try {
                if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                    [self.navigationController pushViewController:appDescrip animated:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            } @catch (NSException * e) {
                // // NSLog(@"Exception: %@", e);
                [self.navigationController popToViewController:appDescrip animated:YES];
            } @finally {
                // // NSLog(@"finally");
            }
            
        }];
        [cell setShowAllTappedBlock:^(ARScrollAppsCell *appCell, UIButton *showButton) {
           // [self disabledUser];
            BAListSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchList"];
            searchVC.currentPage = 0;
            searchVC.previousPage = 0;
            searchVC.isMostPopularApps = NO;
            searchVC.isRandomApps = NO;
            searchVC.isLatestApps = NO;
            searchVC.isCydiaApps = YES;
            [self.navigationController pushViewController:searchVC animated:YES];
        }];
        
        
    } else if (indexPath.section == 3) {
        [cell configureWithTitle:NSLocalizedString(@"Random Apps", @"Random Apps title") items:betterApps.mutableCopy];
        [cell setItemTappedBlock:^(ARScrollAppsCell *appCell, ITAppView *appView) {
           // [self disabledUser];
            [[ITHelper sharedInstance] getAppInfoFromItunes:appView.currentApp.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
                if (allApps.count > 0) {
                    if (![appView.currentApp.appInfo[@"id"] isEqualToString:@"0"]) {
                        appDescrip.object = appView.currentApp;
                        appDescrip.isCydiaApp = NO;
                        @try {
                            if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                                [self.navigationController pushViewController:appDescrip animated:YES];
                            } else {
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        } @catch (NSException * e) {
                            // // NSLog(@"Exception: %@", e);
                            [self.navigationController popToViewController:appDescrip animated:YES];
                        } @finally {
                            // // NSLog(@"finally");
                        }
                    }
                } else {
                    AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
                    appHosters.app = appView.currentApp;
                    appHosters.sectionName = @"ios";
                    [self.navigationController pushViewController:appHosters animated:YES];
                }
            }];
            
            
        }];
        [cell setShowAllTappedBlock:^(ARScrollAppsCell *appCell, UIButton *showButton) {
            //[self disabledUser];
            BAListSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchList"];
            searchVC.currentPage = 1;
            searchVC.previousPage = 1;
            searchVC.isMostPopularApps = NO;
            searchVC.isRandomApps = YES;
            searchVC.isLatestApps = NO;
            searchVC.isCydiaApps = NO;
            [self.navigationController pushViewController:searchVC animated:YES];
        }];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}
-(void)disabledUser{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!app.isVerified) {
        // exit(0);
    }
    if (!app.isRegistered) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You are not Registered User, Please contact us" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            exit(0);
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        // exit(0);
    }
    if (!app.isUSingOther) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your device is not registered, Please contact us" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            exit(0);
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        // exit(0);
    }
    if (!app.isEnabled) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You are disabled to use Baytapps, Please contact us" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            exit(0);
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        // exit(0);
    }
    
    if (!app.isAvailableDuration) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your membership is expired, Please contact us" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            exit(0);
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        // exit(0);
    }
    
    
    
}


-(void)setupUI_sliding {
    
    
    pageFlowView = [[NewPagedFlowView alloc] initWithFrame:CGRectMake(16, 73, Width - 32, 86)];
    pageFlowView.backgroundColor = [UIColor clearColor];
    pageFlowView.delegate = self;
    pageFlowView.dataSource = self;
    pageFlowView.minimumPageAlpha = 0.4;
    pageFlowView.minimumPageScale = 1.0;
    pageFlowView.isCarousel = NO;
    pageFlowView.orientation = NewPagedFlowViewOrientationHorizontal;
    
    pageFlowView.hidden = YES;
    
    
    //提前告诉有多少页
    //    pageFlowView.orginPageCount = self.imageArray.count;
    
    pageFlowView.isOpenAutoScroll = YES;
    
    //初始化pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, pageFlowView.frame.size.height - 24 - 8, Width, 8)];
    pageFlowView.pageControl = pageControl;
    [pageFlowView addSubview:pageControl];
    
    /****************************
     使用导航控制器(UINavigationController)
     如果控制器中不存在UIScrollView或者继承自UIScrollView的UI控件
     请使用UIScrollView作为NewPagedFlowView的容器View,才会显示正常,如下
     *****************************/
    
    //UIScrollView *bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, pageFlowView.frame.size.height - 24 - 8, Width, 8)];
    //[bottomScrollView addSubview:pageFlowView];
    
    [pageFlowView reloadData];
    [self.view addSubview:pageFlowView];
    //[self.view addSubview:bottomScrollView];
    
    
    //添加到主view上
    [self.view addSubview:self.indicateLabel];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark NewPagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView {
    return CGSizeMake(Width - 32, 86);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    
    // NSLog(@"点击了第%ld张图",(long)subIndex + 1);
    
    // self.indicateLabel.text = [NSString stringWithFormat:@"点击了第%ld张图",(long)subIndex + 1];
}

#pragma mark NewPagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    
    return self.imageArray.count;
    
}

- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, Width - 32, 86)];
        bannerView.tag = index;
        bannerView.layer.masksToBounds = YES;
        bannerView.layer.cornerRadius = 10;
        
        
        //    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:pageFlowView.bounds];
        //    pageFlowView.layer.masksToBounds = YES;
        //    pageFlowView.layer.shadowColor = [UIColor blackColor].CGColor;
        //    pageFlowView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        //    pageFlowView.layer.shadowOpacity = 0.5f;
        //    pageFlowView.layer.shadowPath = shadowPath.CGPath;
        
        
        
        
    }
    //在这里下载网络图片
    //  [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:hostUrlsImg,imageDict[@"img"]]] placeholderImage:[UIImage imageNamed:@""]];
    bannerView.mainImageView.image = self.imageArray[index];
    
    return bannerView;
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(NewPagedFlowView *)flowView {
    
    // NSLog(@"ViewController 滚动到了第%ld页",(long)pageNumber);
}

#pragma mark --懒加载
- (NSMutableArray *)imageArray {
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (UILabel *)indicateLabel {
    
    if (_indicateLabel == nil) {
        _indicateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 86, Width, 16)];
        _indicateLabel.textColor = [UIColor blueColor];
        _indicateLabel.font = [UIFont systemFontOfSize:16.0];
        _indicateLabel.textAlignment = NSTextAlignmentCenter;
        _indicateLabel.text = @"";
    }
    
    return _indicateLabel;
}

- (void)CheckingAbility {
    
    // HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    // HUD.textLabel.text = @"Please wait...";
    // [HUD showInView:self.view];
    
  
    GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
    NSString *devicetyp = @"Normal";
    if ([DTTJailbreakDetection isJailbroken]) {
        devicetyp = @"Jailbroken";
        // NSLog(@"Jailbroken");
    }else{
        devicetyp = @"Normal";
        // NSLog(@"Normal");
    }
    // NSLog(@"%@", deviceInfo.modelString);
    // NSLog(@"%f", deviceInfo.displayInfo.pixelsPerInch);
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
    
    NSString *email = [PFUser currentUser][USER_EMAIL];
    
    PFQuery *query = [PFQuery queryWithClassName:@"RegisteredUser"];
    [query whereKey:@"email" equalTo:email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            if (objects.count == 0) {
                
                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                app.isRegistered = NO;
                
                //[HUD dismissAfterDelay:0.0];
                // NSLog(@"***************You Are Unkown User*******************");
                
                [self disabledUser];
                
            }else{
                
                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                app.isRegistered = YES;
                
                PFObject *obj = [objects objectAtIndex:0];
                if([obj[USER_PERMISSION] isEqualToString:@"Enabled"]){
                    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    app.isEnabled = YES;
                }else{
                    app.isEnabled = NO;
                    
                }
                // NSLog(@"***************current device info*******************");
                
                // NSLog(@"devicename : %@", deviceInfo.modelString);
                // NSLog(@"uuid : %@", [self getUniqueDeviceIdentifierAsString]);
                // NSLog(@"isJailbreak : %@", devicetyp);
                // NSLog(@"Resolution : %@", [NSString stringWithFormat:@"%f",deviceInfo.displayInfo.pixelsPerInch]);
                // NSLog(@"team : %@", accountType);
                
                [PFUser currentUser][USER_DeviceName] = deviceInfo.modelString;
                [PFUser currentUser][USER_isJailbreak] = devicetyp;
                [PFUser currentUser][USER_Resolution] = [NSString stringWithFormat:@"%f",deviceInfo.displayInfo.pixelsPerInch];
                [PFUser currentUser][USER_Deviceid] = [self getUniqueDeviceIdentifierAsString];
                [PFUser currentUser][USER_TEAM_ID] = accountType;
                [PFUser currentUser][USER_BUNDLE_ID] = [[NSBundle mainBundle] bundleIdentifier];

                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error == nil) {
                        if (succeeded) {
                            // NSLog(@"*********************registered device info**********************");
                            
                            // NSLog(@"devicename : %@", obj[USER_DeviceName]);
                            // NSLog(@"uuid : %@", obj[USER_Deviceid]);
                            // NSLog(@"isJailbreak : %@", obj[USER_isJailbreak]);
                            // NSLog(@"Resolution : %@", obj[USER_Resolution]);
                            // NSLog(@"team : %@",  obj[USER_TEAM_ID]);
                            
                            if((obj[USER_DeviceName] == nil) || [obj[USER_DeviceName] length] == 0){
                                
                                obj[USER_DeviceName] = deviceInfo.modelString;
                                
                                obj[USER_Deviceid] = [self getUniqueDeviceIdentifierAsString];
                                obj[USER_isJailbreak] = devicetyp;
                                obj[USER_TEAM_ID] = accountType;
                                obj[USER_Resolution] = [NSString stringWithFormat:@"%f",deviceInfo.displayInfo.pixelsPerInch];
                                app.isUSingOther = YES;
                                [obj saveInBackground];
                                
                            }else{
                                
                                //                    // NSLog(@"devicename : %@ => %@", obj[USER_DeviceName], deviceInfo.modelString);
                                //                    // NSLog(@"uuid : %@ => %@", obj[USER_Deviceid], [self getUniqueDeviceIdentifierAsString]);
                                //                    // NSLog(@"isJailbreak : %@ => %@", obj[USER_isJailbreak], devicetyp);
                                //                    // NSLog(@"Resolution : %@ => %@", obj[USER_Resolution], [NSString stringWithFormat:@"%f",deviceInfo.displayInfo.pixelsPerInch]);
                                
                                if ([obj[USER_DeviceName] isEqualToString:deviceInfo.modelString] && [obj[USER_isJailbreak] isEqualToString:devicetyp] && [obj[USER_Resolution] isEqualToString:[NSString stringWithFormat:@"%f",deviceInfo.displayInfo.pixelsPerInch]] && [obj[USER_Deviceid] isEqualToString:[self getUniqueDeviceIdentifierAsString]]) {
                                    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                    app.isUSingOther = YES;
                                }else{
                                    if (![obj[USER_Deviceid] isEqualToString:[self getUniqueDeviceIdentifierAsString]]) {
                                        
                                        obj[USER_DeviceName] = deviceInfo.modelString;
                                        
                                        obj[USER_Deviceid] = [self getUniqueDeviceIdentifierAsString];
                                        obj[USER_isJailbreak] = devicetyp;
                                        obj[USER_TEAM_ID] = accountType;
                                        obj[USER_Resolution] = [NSString stringWithFormat:@"%f",deviceInfo.displayInfo.pixelsPerInch];
                                        app.isUSingOther = YES;
                                        [obj saveInBackground];
                                        
                                    } else {
                                        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                        app.isUSingOther = NO;
                                    }
                                }
                                
                            }
                            
                            NSString *dateAvaiable = obj[@"RegisteredDate"];
                            [[NSUserDefaults standardUserDefaults] setObject:dateAvaiable forKey:@"RegisteredDate"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            NSString *paymentMethod = obj[@"PaymentMethod"];
                            [[NSUserDefaults standardUserDefaults] setObject:paymentMethod forKey:@"PaymentMethod"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            NSString *RegisteredTEAMID = obj[@"RegisteredTEAMID"];
                            [[NSUserDefaults standardUserDefaults] setObject:RegisteredTEAMID forKey:@"RegisteredTEAMID"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            
                            // convert to date
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                            // ignore +11 and use timezone name instead of seconds from gmt
                            [dateFormat setDateFormat:@"YYYY-MM-dd"];
                            NSDate *dte = [dateFormat dateFromString:dateAvaiable];
                            // NSLog(@"Date: %@", dte);
                            
                            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                            dayComponent.day = 366;
                            
                            NSCalendar *theCalendar = [NSCalendar currentCalendar];
                            NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:dte options:0];
                            
                            // NSLog(@"nextDate: %@ ...", nextDate);
                            
                            
                            long dif = [[NSDate date] timeIntervalSinceDate:nextDate];
                            
                            if (dif <  0) {
                                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                app.isAvailableDuration = YES;
                            }else{
                                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                app.isAvailableDuration = NO;
                            }
                            [self disabledUser];
                        }
                    }
                }];
                //[HUD dismissAfterDelay:0.0];
            }
        } else {
            // Log details of the failure
            [self disabledUser];

            // NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
    
}
-(NSString *)getUniqueDeviceIdentifierAsString
{
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}


//    [ITServerHelper getAllCustomAppsForCat:accountType withBlock:^(BOOL succeeded, NSArray *objects, NSError *error) {
//        if (error == nil) {
//            if (objects.count > 0) {
//                NSMutableArray *tweakArray = [NSMutableArray new];
//                for (PFObject *app in objects) {
//                    ITAppView *item = [[ITAppView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:app[CUSTOM_APP_ICON]] title:app[CUSTOM_APP_NAME_STRING] subTitle:app[CUSTOM_APP_VERSION] andCydiaApp:app];
//                    if (![tweakArray containsObject:item]) {
//                        [tweakArray addObject:item];
//                    }
//                }
//                if (tweaksApps.count == 0) {
//                    tweaksApps = [tweakArray copy];
//                }
//                [self.mainTableView reloadData];
//            }
//        }
//    }];
@end
