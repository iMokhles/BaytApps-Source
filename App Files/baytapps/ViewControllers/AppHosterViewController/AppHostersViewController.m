//
//  AppHostersViewController.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "AppHostersViewController.h"
#import "ITHostCell.h"
#import "AppDelegate.h"
#import "BAProgressViewController.h"
#import "BAAppEditorViewController.h"
#import "ITServerHelper.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "ITHelper.h"
//#import "UICKeyChainStore.h"

@interface AppHostersViewController () <UIWebViewDelegate, LGRefreshViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate> {
    NSArray *hostArray;
    NSMutableDictionary *hostsDicts;
    NSArray *hostSectionsArray;
    UIWebView *webView1;
    
    NSString *tappedHost;
    NSString *tappedVersion;
    NSInteger dupliNumber;
    
    NSString *appName;
    UIImage *appImage;
    
    DGActivityIndicatorView *activityIndicator;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIImageView *topTitleImageView;
@property (strong, nonatomic) IBOutlet UIButton *topBackBtn;
- (IBAction)topBackBtnTapped:(UIButton *)sender;

@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation AppHostersViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    if ([PFUser currentUser] == nil) {
        // // NSLog(@"******* !!! OPS 1");
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        // // NSLog(@"******* !!! OPS");
        return;
    }
    
    //UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    //
    //    NSString *paidStatus = [keyWrapper stringForKey:@"it_6"];
    //    NSString *paymentMethodString = [keyWrapper stringForKey:@"it_5"];
    //    NSString *orderStatusString = [keyWrapper stringForKey:@"it_8"];
    //    NSString *orderDateString =  [keyWrapper stringForKey:@"it_67"];
    //
    //    if (paidStatus.length == 0) {
    //        // // NSLog(@"******* !!!");
    //        return;
    //    }
    //
    ////    if (paymentMethodString.length == 0) {
    ////        // // NSLog(@"******* !!! 2");
    ////        return;
    ////    }
    //
    //    if (orderStatusString.length == 0) {
    //        // // NSLog(@"******* !!! 3");
    //        return;
    //    }
    //
    //    if (orderDateString.length == 0) {
    //        // // NSLog(@"******* !!! 4");
    //        return;
    //    }
    
    [self loadAllHosts];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    webView1 = [[UIWebView alloc] initWithFrame:CGRectZero];
    [webView1 setDelegate:self];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Hosters", @"Hosters page title");
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[UIColor whiteColor] size:70.0f];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    [self loadAllHosts];
    [refreshView endRefreshing];
}

- (void)loadAllHosts {
    
    
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    //
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
    //
    
    
    if ([self.sectionName isEqualToString:@"ios"]) {
        // // NSLog(@"********* iOS");
        [[ITHelper sharedInstance] getAllDownloadLinksForApp:self.app.appInfo[@"id"] andSection:self.sectionName withCompletion:^(NSDictionary *allHosts, NSError *error) {
            
            hostsDicts = [allHosts mutableCopy];
            hostSectionsArray = [hostsDicts allKeys];
            NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                        ascending:NO];
            hostSectionsArray = [hostSectionsArray sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            
            hostSectionsArray = [hostSectionsArray sortedArrayUsingComparator:^(id obj1, id obj2) {
                if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
                    NSArray *obj1Components = [(NSString *)obj1 componentsSeparatedByString:@"."];
                    NSArray *obj2Components = [(NSString *)obj2 componentsSeparatedByString:@"."];
                    
                    NSUInteger highestCount = obj1Components.count;
                    if (obj2Components.count > highestCount) {
                        highestCount = obj2Components.count;
                    }
                    
                    for (int i = 0; i < highestCount; i++) {
                        
                        // If the component does not exist, just make it 0
                        NSNumber *num1 = [NSNumber numberWithInt:0];
                        if (i < obj1Components.count) {
                            num1 = [nf numberFromString:[obj1Components objectAtIndex:i]];
                        }
                        
                        NSNumber *num2 = [NSNumber numberWithInt:0];
                        if (i < obj2Components.count) {
                            num2 = [nf numberFromString:[obj2Components objectAtIndex:i]];
                        }
                        
                        int int1 = [num1 intValue];
                        int int2 = [num2 intValue];
                        
                        if (int1 > int2) {
                            return NSOrderedAscending;
                        } else if (int2 > int1) {
                            return NSOrderedDescending;
                        }
                    }
                    
                    // If we reach here, they're the same.
                    return NSOrderedSame;
                    
                } else {
                    // They're not strings, so just say they're the same
                    return NSOrderedSame;
                }
            }];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView reloadData];
            });
        }];
    } else {
        [[ITHelper sharedInstance] getAllDownloadLinksForApp:self.app.appTrackID andSection:self.sectionName withCompletion:^(NSDictionary *allHosts, NSError *error) {
            
            hostsDicts = [allHosts mutableCopy];
            hostSectionsArray = [hostsDicts allKeys];
            NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                        ascending:NO];
            hostSectionsArray = [hostSectionsArray sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            
            hostSectionsArray = [hostSectionsArray sortedArrayUsingComparator:^(id obj1, id obj2) {
                if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
                    NSArray *obj1Components = [(NSString *)obj1 componentsSeparatedByString:@"."];
                    NSArray *obj2Components = [(NSString *)obj2 componentsSeparatedByString:@"."];
                    
                    int highestCount = obj1Components.count;
                    if (obj2Components.count > highestCount) {
                        highestCount = obj2Components.count;
                    }
                    
                    for (int i = 0; i < highestCount; i++) {
                        
                        // If the component does not exist, just make it 0
                        NSNumber *num1 = [NSNumber numberWithInt:0];
                        if (i < obj1Components.count) {
                            num1 = [nf numberFromString:[obj1Components objectAtIndex:i]];
                        }
                        
                        NSNumber *num2 = [NSNumber numberWithInt:0];
                        if (i < obj2Components.count) {
                            num2 = [nf numberFromString:[obj2Components objectAtIndex:i]];
                        }
                        
                        int int1 = [num1 intValue];
                        int int2 = [num2 intValue];
                        
                        if (int1 > int2) {
                            return NSOrderedAscending;
                        } else if (int2 > int1) {
                            return NSOrderedDescending;
                        }
                    }
                    
                    // If we reach here, they're the same.
                    return NSOrderedSame;
                    
                } else {
                    // They're not strings, so just say they're the same
                    return NSOrderedSame;
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView reloadData];
            });
            
        }];
    }
    
}

#pragma mark - UITableView Delegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([hostSectionsArray count] == 0) {
        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:activityIndicator];
        [activityIndicator startAnimating];
        return 0;
    } else {
        [activityIndicator stopAnimating];
        [self.mainTableView setBackgroundView:nil];
        [self.mainTableView setBackgroundColor:[UIColor clearColor]];
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return [hostSectionsArray count];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *schedArray = [hostsDicts objectForKey:[hostSectionsArray objectAtIndex:section]];
    return [schedArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 25)];
    [bgImageView setImage:[UIImage imageNamed:@"cell_bg"]];
    
    bgImageView.layer.masksToBounds = YES;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bgImageView.bounds byRoundingCorners:(UIRectCornerTopRight) cornerRadii:CGSizeMake(45, 45)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    bgImageView.layer.mask = maskLayer;
    
    [bgImageView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 120, 20)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:[hostSectionsArray objectAtIndex:section]];
    
    [headerView addSubview:bgImageView];
    [headerView addSubview:titleLabel];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ITHostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ITHostCell"];
    NSArray *currentArray = [hostsDicts valueForKey:[hostSectionsArray objectAtIndex:indexPath.section]];
    NSDictionary *hostDict = [currentArray objectAtIndex:indexPath.row];
    
    ITAppHoster *host = [ITAppHoster new];
    host.hosterCracker = [hostDict objectForKey:@"cracker"];
    host.hosterName = [hostDict objectForKey:@"host"];
    host.hosterLink = [hostDict objectForKey:@"link"];
    host.isProtected = [[NSNumber numberWithInt:[[hostDict objectForKey:@"protected"] intValue]] boolValue];
    
    //    if ([[hostDict objectForKey:@"host"] containsString:@"filepup"] || [[hostDict objectForKey:@"host"] containsString:@"appd.be"]) {
    if ([[hostDict objectForKey:@"host"] containsString:@"filepup"] ||
        [[hostDict objectForKey:@"host"] containsString:@"sendspace"] ||
        [[hostDict objectForKey:@"host"] containsString:@"mega"] ||
        [[hostDict objectForKey:@"host"] containsString:@"mediafree"] ||
         [[hostDict objectForKey:@"host"] containsString:@"openload"] ||
        [[hostDict objectForKey:@"host"] containsString:@"turbobit"] ||
        [[hostDict objectForKey:@"host"] containsString:@"dailyuploads"] ||
        [[hostDict objectForKey:@"host"] containsString:@"userscloud"]
        ) {
        host.isVerified = YES;
    } else {
        host.isVerified = NO;
    }
    [cell configureWithHoster:host];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *currentArray = [hostsDicts valueForKey:[hostSectionsArray objectAtIndex:indexPath.section]];
    NSDictionary *hostDict = [currentArray objectAtIndex:indexPath.row];
    
    tappedHost = [hostDict objectForKey:@"host"];
    tappedVersion = [hostSectionsArray objectAtIndex:indexPath.section];
    
    //    if ([[hostDict objectForKey:@"host"] containsString:@"filepup"] || [[hostDict objectForKey:@"host"] containsString:@"appd.be"]  || [[hostDict objectForKey:@"host"] containsString:@"dailyuploads"]) {
    if ([[hostDict objectForKey:@"host"] containsString:@"filepup"] ||
        [[hostDict objectForKey:@"host"] containsString:@"sendspace"] ||
        [[hostDict objectForKey:@"host"] containsString:@"mega.co"] ||
        [[hostDict objectForKey:@"host"] containsString:@"mediafree"] ||
        [[hostDict objectForKey:@"host"] containsString:@"turbobit"] ||
        [[hostDict objectForKey:@"host"] containsString:@"dailyuploads"] ||
        [[hostDict objectForKey:@"host"] containsString:@"mega.nz"] ||
        [[hostDict objectForKey:@"host"] containsString:@"openload"] ||
        [[hostDict objectForKey:@"host"] containsString:@"userscloud"]
        ) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [hostDict objectForKey:@"link"]]];
//        // NSLog(@"URL :: %@", [NSString stringWithFormat:@"%@", [hostDict objectForKey:@"link"]]);
        
        UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        [ITHelper showHudWithText:NSLocalizedString(@"Request App...", @"") inView:controller.view dismissAfterDelay:11];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [webView1 loadRequest:request];
        
//        [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
//            if (succeeded) {
//                
//                [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":object, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
//                appEditor.appToEdit = self.app;
//                
//                if ([self.sectionName isEqualToString:@"cydia"]) {
//                    appEditor.isCydia = YES;
//                }else{
//                    appEditor.isCydia = NO;
//                }
//                
//                [webView1 stopLoading];
//                [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
//                    
//                }];
//                [self.navigationController presentViewController:appEditor animated:YES completion:^{
//                    
//                }];
//                
//            } else {
//                
//            }
//        }];
        
        
    } else {
        [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Host not supported", @"")];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = request.URL.absoluteString;
    
    //
    //    if (([url containsString:@"filepup"] || [url containsString:@"dailyuploads"] || [url containsString:@"openload"] || [url containsString:@"turbobit"] || [url containsString:@"mediafree"] || [url containsString:@"cloudshares"] || [url containsString:@"ul.to"] || [url containsString:@"appd.be"] || [url containsString:@"fpdi_ticket"] || [url containsString:@"sendspace"] || [url containsString:@"mediafire"]) && (![url containsString:@"ads"] || ![url containsString:@"redirector"]))  {
    
    if (([url containsString:@"filepup"] ||
         [url containsString:@"sendspace"] ||
         [url containsString:@"mega.co"] ||
         [url containsString:@"mega.nz"] ||
         [url containsString:@"mediafree"] ||
         [url containsString:@"turbobit"] ||
         [url containsString:@"dailyuploads"] ||
         [url containsString:@"openload"] ||
         [url containsString:@"userscloud"]) &&
        (![url containsString:@"ads"] || ![url containsString:@"redirector"]))  {
        
        
        if (([url containsString:@"filepup"] ||
             [url containsString:@"sendspace"] ||
             [url containsString:@"mega.co"] ||
             [url containsString:@"mega.nz"] ||
             [url containsString:@"openload"] ||
             [url containsString:@"mediafree"] ||
             [url containsString:@"turbobit"] ||
             [url containsString:@"dailyuploads"] ||
             [url containsString:@"userscloud"]) && (![url containsString:@"ads"] || ![url containsString:@"googleads"]) && [url containsString:@"fpdi_ticket="]) {
            
            

            
            [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [webView1 stopLoading];
            
            // NSLog(@"webView -> URL :: %@", url);

            [ITServerHelper saveApp:self.app toDatabaseWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // NSLog(@"webView -> URL :: %@", url);
                    [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            // NSLog(@"webView -> URL :: %@", url);
                            BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                            appEditor.appToEdit = self.app;
                            if ([self.sectionName isEqualToString:@"cydia"]) {
                                appEditor.isCydia = YES;
                            }else{
                                appEditor.isCydia = NO;
                            }
                            [webView1 stopLoading];
                            
                            [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                
                                
                                
                            }];
                            [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                
                            }];
                            [webView stopLoading];
                            
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                        appEditor.appToEdit = self.app;
                        if ([self.sectionName isEqualToString:@"cydia"]) {
                            appEditor.isCydia = YES;
                        }else{
                            appEditor.isCydia = NO;
                        }
                        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                            
                            
                            
                        }];
                        [self.navigationController presentViewController:appEditor animated:YES completion:^{
                            
                        }];
                        return;
                    }
                    [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
                        
                        if (!succeeded) {
                            [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                                    appEditor.appToEdit = self.app;
                                    if ([self.sectionName isEqualToString:@"cydia"]) {
                                        appEditor.isCydia = YES;
                                    }else{
                                        appEditor.isCydia = NO;
                                    }
                                    [webView1 stopLoading];
                                    
                                    [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                        
                                        
                                        
                                    }];
                                    [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                        
                                    }];
                                } else {
                                    if (error != nil) {
                                        [ITHelper showErrorMessageFrom:self withError:error];
                                    }
                                }
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                    
                }
            }];
            
            
            
        } else if ([url containsString:@"turbobit"] && [url containsString:@"fpdi_ticket="] && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
            [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ITServerHelper saveApp:self.app toDatabaseWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                            appEditor.appToEdit = self.app;
                            if ([self.sectionName isEqualToString:@"cydia"]) {
                                appEditor.isCydia = YES;
                            }else{
                                appEditor.isCydia = NO;
                            }
                            [webView1 stopLoading];
                            
                            [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                
                                
                                
                            }];
                            [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                        appEditor.appToEdit = self.app;
                        if ([self.sectionName isEqualToString:@"cydia"]) {
                            appEditor.isCydia = YES;
                        }else{
                            appEditor.isCydia = NO;
                        }
                        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                            
                            
                            
                        }];
                        [self.navigationController presentViewController:appEditor animated:YES completion:^{
                            
                        }];
                        return;
                    }
                    [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
                        
                        if (!succeeded) {
                            [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                                    appEditor.appToEdit = self.app;
                                    if ([self.sectionName isEqualToString:@"cydia"]) {
                                        appEditor.isCydia = YES;
                                    }else{
                                        appEditor.isCydia = NO;
                                    }
                                    [webView1 stopLoading];
                                    
                                    [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                        
                                        
                                        
                                    }];
                                    [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                        
                                    }];
                                } else {
                                    if (error != nil) {
                                        [ITHelper showErrorMessageFrom:self withError:error];
                                    }
                                }
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                }
            }];
            
        } else if ([url containsString:@"openload"] && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
            [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [ITServerHelper saveApp:self.app toDatabaseWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            
                            BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                            appEditor.appToEdit = self.app;
                            if ([self.sectionName isEqualToString:@"cydia"]) {
                                appEditor.isCydia = YES;
                            }else{
                                appEditor.isCydia = NO;
                            }
                            [webView1 stopLoading];
                            
                            [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                
                                
                                
                            }];
                            [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                        appEditor.appToEdit = self.app;
                        if ([self.sectionName isEqualToString:@"cydia"]) {
                            appEditor.isCydia = YES;
                        }else{
                            appEditor.isCydia = NO;
                        }
                        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                            
                            
                            
                        }];
                        [self.navigationController presentViewController:appEditor animated:YES completion:^{
                            
                        }];
                        return;
                    }
                    [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
                        
                        if (!succeeded) {
                            [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [webView1 stopLoading];
                                    
                                    BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                                    appEditor.appToEdit = self.app;
                                    if ([self.sectionName isEqualToString:@"cydia"]) {
                                        appEditor.isCydia = YES;
                                    }else{
                                        appEditor.isCydia = NO;
                                    }
                                    [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                        
                                        
                                        
                                    }];
                                    [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                        
                                    }];
                                } else {
                                    if (error != nil) {
                                        [ITHelper showErrorMessageFrom:self withError:error];
                                    }
                                }
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                }
            }];
            
        } else if ([url containsString:@"sendspace"] && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
            [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [ITServerHelper saveApp:self.app toDatabaseWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [webView1 stopLoading];
                            
                            BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                            appEditor.appToEdit = self.app;
                            if ([self.sectionName isEqualToString:@"cydia"]) {
                                appEditor.isCydia = YES;
                            }else{
                                appEditor.isCydia = NO;
                            }
                            [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                
                                
                                
                            }];
                            [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                        appEditor.appToEdit = self.app;
                        if ([self.sectionName isEqualToString:@"cydia"]) {
                            appEditor.isCydia = YES;
                        }else{
                            appEditor.isCydia = NO;
                        }
                        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                            
                            
                            
                        }];
                        [self.navigationController presentViewController:appEditor animated:YES completion:^{
                            
                        }];
                        return;
                    }
                    [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
                        
                        if (!succeeded) {
                            [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [webView1 stopLoading];
                                    
                                    BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                                    appEditor.appToEdit = self.app;
                                    if ([self.sectionName isEqualToString:@"cydia"]) {
                                        appEditor.isCydia = YES;
                                    }else{
                                        appEditor.isCydia = NO;
                                    }
                                    [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                        
                                        
                                        
                                    }];
                                    [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                        
                                    }];
                                } else {
                                    if (error != nil) {
                                        [ITHelper showErrorMessageFrom:self withError:error];
                                    }
                                }
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                }
            }];
            
        } else if ([url containsString:@"mega.co"] && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
            [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [ITServerHelper saveApp:self.app toDatabaseWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [webView1 stopLoading];
                            
                            BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                            appEditor.appToEdit = self.app;
                            if ([self.sectionName isEqualToString:@"cydia"]) {
                                appEditor.isCydia = YES;
                            }else{
                                appEditor.isCydia = NO;
                            }
                            [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                
                                
                                
                            }];
                            [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                        appEditor.appToEdit = self.app;
                        if ([self.sectionName isEqualToString:@"cydia"]) {
                            appEditor.isCydia = YES;
                        }else{
                            appEditor.isCydia = NO;
                        }
                        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                            
                            
                            
                        }];
                        [self.navigationController presentViewController:appEditor animated:YES completion:^{
                            
                        }];
                        return;
                    }
                    [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
                        
                        if (!succeeded) {
                            [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [webView1 stopLoading];
                                    
                                    BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                                    appEditor.appToEdit = self.app;
                                    if ([self.sectionName isEqualToString:@"cydia"]) {
                                        appEditor.isCydia = YES;
                                    }else{
                                        appEditor.isCydia = NO;
                                    }
                                    [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                        
                                        
                                        
                                    }];
                                    [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                        
                                    }];
                                } else {
                                    if (error != nil) {
                                        [ITHelper showErrorMessageFrom:self withError:error];
                                    }
                                }
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                }
            }];
            
        } else if ([url containsString:@"mediafire"] && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
            [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url, @"requestedVersion":tappedVersion, @"requestedHost": tappedHost} forKey:@"requestedAppInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [ITServerHelper saveApp:self.app toDatabaseWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [webView1 stopLoading];
                            
                            BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                            appEditor.appToEdit = self.app;
                            if ([self.sectionName isEqualToString:@"cydia"]) {
                                appEditor.isCydia = YES;
                            }else{
                                appEditor.isCydia = NO;
                            }
                            [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                
                                
                                
                            }];
                            [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                        appEditor.appToEdit = self.app;
                        if ([self.sectionName isEqualToString:@"cydia"]) {
                            appEditor.isCydia = YES;
                        }else{
                            appEditor.isCydia = NO;
                        }
                        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                            
                            
                            
                        }];
                        [self.navigationController presentViewController:appEditor animated:YES completion:^{
                            
                        }];
                        return;
                    }
                    [ITServerHelper getLinkFromAppID:self.app.appID andVersion:tappedVersion withBlock:^(BOOL succeeded, NSError *error, id object) {
                        
                        if (!succeeded) {
                            [ITServerHelper saveAppVersion:tappedVersion forAppID:self.app.appID withURLString:[NSString stringWithFormat:@"%@", url] withBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [webView1 stopLoading];
                                    
                                    BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
                                    appEditor.appToEdit = self.app;
                                    if ([self.sectionName isEqualToString:@"cydia"]) {
                                        appEditor.isCydia = YES;
                                    }else{
                                        appEditor.isCydia = NO;
                                    }
                                    [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
                                        
                                        
                                        
                                    }];
                                    [self.navigationController presentViewController:appEditor animated:YES completion:^{
                                        
                                    }];
                                } else {
                                    if (error != nil) {
                                        [ITHelper showErrorMessageFrom:self withError:error];
                                    }
                                }
                            }];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                }
            }];
        }
        return YES;
    } else {
        
    }
    
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = webView1.request.URL.absoluteString;
    if ([url containsString:@"filepup"]) {
        // // NSLog(@"******** %@", url);
    } else if ([url containsString:@"dailyuploads.net"]) {
        // // NSLog(@"******** %@", url);
    }
    
//    // NSLog(@"******** %@", url);
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

- (IBAction)topBackBtnTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
