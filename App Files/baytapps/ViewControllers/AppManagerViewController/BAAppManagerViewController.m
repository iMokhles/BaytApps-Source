//
//  BAAppManagerViewController.m
//  baytapps
//
//  Created by iMokhles on 03/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAAppManagerViewController.h"
#import "LGRefreshView.h"
#import "DGActivityIndicatorView.h"
#import "ITServerHelper.h"
#import "BAColorsHelper.h"

#import "DAProgressOverlayView.h"
#import "ITServerHelper.h"
#import "Definations.h"
#import "AppConstant.h"
//#import "UICKeyChainStore.h"
#import "BAAppCell.h"
#import "ITConstants.h"
#import "JGActionSheet.h"

#import "BANewApi.h"

#import <PINCache.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINRemoteImage/PINRemoteImageManager.h>

BOOL isDownloading;
@interface BAAppManagerViewController () <UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate> {
    NSMutableArray *appsArray;
    DGActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) IBOutlet UIButton *startChatButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;

@property (strong, nonatomic) IBOutlet DAProgressOverlayView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *appIconView;
@property (strong, nonatomic) IBOutlet UIView *topManagerView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainTableTopConstraint;
@end

@implementation BAAppManagerViewController

- (void)viewWillAppear:(BOOL)animated {
    
    
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
    
    //    UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    //
    //    NSString *passAUTH = DecryptText(@"", [keyWrapper stringForKey:@"it_1"]);
    //    NSString *passUDID = DecryptText(@"", [keyWrapper stringForKey:@"it_3"]);
    //
    //    NSString *passAUTH1 = DecryptText(@"", [PFUser currentUser][USER_DEVICE_TYPE]);
    //    NSString *passUDID1 = DecryptText(@"", [PFUser currentUser][USER_DEVICE_ID]);
    //
    //    if (![[DecryptText(@"", [keyWrapper stringForKey:@"it_3"]) lowercaseString] isEqualToString:[passUDID1 lowercaseString]]) {
    //        // // NSLog(@"********* 1))) %@ = %@", passUDID, passUDID1);
    //        return;
    //    }
    //
    //    if (![[DecryptText(@"", [keyWrapper stringForKey:@"it_1"]) lowercaseString] isEqualToString:[passAUTH1 lowercaseString]]) {
    //        // // NSLog(@"********* 2))) %@ = %@", passAUTH1, passAUTH);
    //        return;
    //    }
    
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentApp"];
    ITAppObject *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    
    
    
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
    
    [self.appIconView sd_setImageWithURL:[NSURL URLWithString:self.appIconLink] placeholderImage:[UIImage imageNamed:@""]];
    
    if (self.requestedApp == nil) {
        
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownloading"] boolValue] == NO || object) {
            [_topManagerView setHidden:YES];
            _mainTableTopConstraint.constant = 8;
            [self.view updateConstraints];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewUI:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)updateNewUI:(NSNotification *)notification {
    
    NSString *message = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_message"];
    NSString *progressString = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_progress"];
    
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
                [self loadUserAppsManager];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownloading"];
                [self.statusLabel setText:[NSString stringWithFormat:@"%@ Ready To Install", self.appNameString]]; // NSLocalizedString(@"Done App...", @"")
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
                NSArray *failedMessageArray = [message componentsSeparatedByString:@"Failed "];
                [self.statusLabel setText:[NSString stringWithFormat:@"Failed %@", failedMessageArray[1]]];
            });
            
            PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
            [queryAppsDB whereKey:APP_DB_VERSIONS_APP_ID equalTo:[self.requestedApp.appID lowercaseString]];
            [queryAppsDB whereKey:APP_DB_VERSIONS_VERSION_STRING equalTo:[self.appVersion lowercaseString]];
            [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil) {
                    if (objects.count > 0) {
                        PFObject *currentApp = [objects objectAtIndex:0];
                        [currentApp deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (error == nil) {
                                if (succeeded) {
                                    [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Choose another link", @"")];
                                }
                            } else {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }];
                    }
                }
            }];
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
    }
    

    
}
- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self downloadAggain];
    
}

- (void)downloadAggain{
    if (self.requestedApp) {
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.requestedApp];
        [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"currentApp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.appNameString = [self.appNameString lowercaseString];
        // NSLog(@"self.requestedApp: %@ ",self.requestedApp);
        // NSLog(@"self.appIconLink: %@ ",self.appIconLink);
        // NSLog(@"self.appNameString: %@ ",self.appNameString);
        // NSLog(@"self.requestedUrlString: %@ ",self.requestedUrlString);
        // NSLog(@"self.hostName: %@ ",self.hostName);
        
        [[BANewApi sharedInstance] downloadIPAFileForApp:self.requestedApp appIcon:self.appIconLink appName:self.appNameString appLink:self.requestedUrlString appVersion:self.appVersion hostName:self.hostName duplicate:self.dupliNumber completionBlock:^(NSData *data, NSURLResponse *response) {
            //
            
            NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([strr containsString:@"Ready To Install"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:1.0];
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                    [self loadUserAppsManager];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownloading"];
                    [self.statusLabel setText:[NSString stringWithFormat:@"%@ Ready To Install", self.appNameString]]; // NSLocalizedString(@"Done App...", @"")
                });
                
                NSLog(@"******* Ready To Install %@", strr);
            } else if ([strr containsString:@"Failed"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:1.0];

                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                    [self.statusLabel setText:[NSString stringWithFormat:@"Failed Not Found"]];
                });
                NSLog(@"******* Failed %@", strr);
            }
            
        } errorBlock:^(NSError *error) {
             NSLog(@"****** error: %@", error);
            //
        } uploadPorgressBlock:^(float progress) {
             NSLog(@"upload****** progress: %f", progress);
            //
        } downloadProgressBlock:^(float progress, NSData *data) {
            //
             NSLog(@"download****** progress: %f", progress);
            NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([strr containsString:@"Preparing"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:0.30];
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                    [self.statusLabel setText:@"Preparing..."];
                });
                NSLog(@"******* downloadProgressBlock Preparing %@", strr);
            }
            if ([strr containsString:@"Downloading"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:0.50];
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                    [self.statusLabel setText:@"Downloading..."];
                });
                NSLog(@"******* downloadProgressBlock Downloading %@", strr);
            }
            if ([strr containsString:@"Building"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:0.70];
                    [self.progressView displayOperationDidFinishAnimation];
                    double delayInSeconds = self.progressView.stateChangeAnimationDuration;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.progressView.progress = 0.;
                        self.progressView.hidden = YES;
                    });
                    [self.statusLabel setText:@"Building..."];
                });
                NSLog(@"******* downloadProgressBlock BUILDING %@", strr);
            }
        }];
    }else{
        [self loadUserAppsManager];
    }
    
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
                [self loadUserAppsManager];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownloading"];
                [self.statusLabel setText:[NSString stringWithFormat:@"%@ Ready To Install", self.appNameString]]; // NSLocalizedString(@"Done App...", @"")
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
                NSArray *failedMessageArray = [message componentsSeparatedByString:@"Failed "];
                [self.statusLabel setText:[NSString stringWithFormat:@"Failed %@", failedMessageArray[1]]];
            });
            
            PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
            [queryAppsDB whereKey:APP_DB_VERSIONS_APP_ID equalTo:[self.requestedApp.appID lowercaseString]];
            [queryAppsDB whereKey:APP_DB_VERSIONS_VERSION_STRING equalTo:[self.appVersion lowercaseString]];
            [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil) {
                    if (objects.count > 0) {
                        PFObject *currentApp = [objects objectAtIndex:0];
                        [currentApp deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (error == nil) {
                                if (succeeded) {
                                    [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Choose another link", @"")];
                                }
                            } else {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }];
                    }
                }
            }];
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

- (void)createManagerListIfNeeded {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.appIconView.layer.masksToBounds = YES;
    self.appIconView.layer.cornerRadius = 25.0;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 25.0;
    
    
    
}

- (void)loadUserAppsManager {
    [[[PINRemoteImageManager sharedImageManager] cache] removeAllObjects];
    [ITServerHelper getAllManagedAppsForUser:[PFUser currentUser] withBlock:^(BOOL succeeded, NSArray *objects, NSError *error) {
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
    
    BAAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAAppCell"];
    [cell.appAvailableView setHidden:NO];
    [cell.appNameLabel setFont:[UIFont systemFontOfSize:21]];
    PFObject *app = appsArray[indexPath.section];
    cell.isTweakCell = self.isCydia;
    [cell configureWithObjectForNewManager:app];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *app = appsArray[indexPath.section];
      NSLog(@"***** %@", app[USER_APP_MANAGER_APP_LINK]);
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
- (void)tableView:(UITableView *)tableView willDisplayCell:(BAAppCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

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
    //NSString *teamID = profile[@"UUID"];
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
                                                 @"&removeApps=yes"
                                                 @"&accType=%@"
                                                 @"&devicetoken=%@",
                                                 EncryptText(@"", [PFUser currentUser].sessionToken),
                                                 EncryptText(@"", accountType),
                                                 EncryptText(@"", accountType)];
                    
                    [[ITHelper sharedInstance] newPostMethodWithURL:apiURL postString:customURLString completionBlock:^(NSData *data, NSURLResponse *response) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [ITServerHelper removeAllManagedAppsForUser:[PFUser currentUser]];
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
