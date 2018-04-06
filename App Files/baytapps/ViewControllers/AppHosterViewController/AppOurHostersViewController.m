//
//  AppHostersViewController.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "AppOurHostersViewController.h"
#import "ITHostCell.h"
#import "AppDelegate.h"
#import "BAProgressViewController.h"
#import "BAAppEditorViewController.h"
#import "ITServerHelper.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "ITHelper.h"
//#import "UICKeyChainStore.h"

@interface AppOurHostersViewController () <UIWebViewDelegate, LGRefreshViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate> {
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

@implementation AppOurHostersViewController

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
    //    if ([self.sectionName isEqualToString:@"ios"]) {
    //        PFQuery *query2 = [PFQuery queryWithClassName:LAtest_APP_DB_VERSIONS_CLASSE_NAME];
    //        [query2 whereKey:USER_APP_MANAGER_APP_ID equalTo:self.app.appID];
    //        [query2 whereKey:USER_APP_MANAGER_APP_NAME equalTo:self.app.appName];
    //        NSMutableArray *ma_arr = [[NSMutableArray alloc] init];
    //        NSMutableArray *ma_arr_app = [[NSMutableArray alloc] init];
    //
    //        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    //         {
    //             if (error == nil) {
    //                 if (objects.count > 0) {
    //                     for (PFObject *appDict in objects) {
    //                         [ma_arr addObject:appDict[@"appVersion"]];
    //                         [ma_arr_app addObject:appDict];
    //                     }
    //                   hostsDicts =  [NSMutableDictionary dictionaryWithObjects:ma_arr_app forKeys:ma_arr];
    //
    //                     NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self"
    //                                                                                 ascending:NO];
    //                     hostSectionsArray = [hostSectionsArray sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    //
    //                     NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    //
    //                     hostSectionsArray = [hostSectionsArray sortedArrayUsingComparator:^(id obj1, id obj2) {
    //                         if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
    //                             NSArray *obj1Components = [(NSString *)obj1 componentsSeparatedByString:@"."];
    //                             NSArray *obj2Components = [(NSString *)obj2 componentsSeparatedByString:@"."];
    //
    //                             NSUInteger highestCount = obj1Components.count;
    //                             if (obj2Components.count > highestCount) {
    //                                 highestCount = obj2Components.count;
    //                             }
    //
    //                             for (int i = 0; i < highestCount; i++) {
    //
    //                                 // If the component does not exist, just make it 0
    //                                 NSNumber *num1 = [NSNumber numberWithInt:0];
    //                                 if (i < obj1Components.count) {
    //                                     num1 = [nf numberFromString:[obj1Components objectAtIndex:i]];
    //                                 }
    //
    //                                 NSNumber *num2 = [NSNumber numberWithInt:0];
    //                                 if (i < obj2Components.count) {
    //                                     num2 = [nf numberFromString:[obj2Components objectAtIndex:i]];
    //                                 }
    //
    //                                 int int1 = [num1 intValue];
    //                                 int int2 = [num2 intValue];
    //
    //                                 if (int1 > int2) {
    //                                     return NSOrderedAscending;
    //                                 } else if (int2 > int1) {
    //                                     return NSOrderedDescending;
    //                                 }
    //                             }
    //
    //                             // If we reach here, they're the same.
    //                             return NSOrderedSame;
    //
    //                         } else {
    //                             // They're not strings, so just say they're the same
    //                             return NSOrderedSame;
    //                         }
    //                     }];
    //
    //                     hostSectionsArray = [NSArray arrayWithArray:ma_arr];
    //
    //
    //                     [self.mainTableView reloadData];
    //
    //                 } else {
    //                 }
    //             }
    //         }];
    //
    //
    //    }else
    if(  [self.sectionName isEqualToString:@"cydia"]){
        PFQuery *query2 = [PFQuery queryWithClassName:TWEAK_APP_DB_VERSIONS_CLASSE_NAME];
        [query2 whereKey:USER_APP_MANAGER_APP_ID equalTo:self.app.appID];
        [query2 whereKey:USER_APP_MANAGER_APP_NAME equalTo:self.app.appName];
        NSMutableArray *ma_arr = [[NSMutableArray alloc] init];
        NSMutableArray *ma_arr_app = [[NSMutableArray alloc] init];
        
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil) {
                 if (objects.count > 0) {
                     for (PFObject *appDict in objects) {
                         [ma_arr addObject:appDict[@"appVersion"]];
                         [ma_arr_app addObject:appDict];
                     }
                     
                     NSMutableArray *arr_origin = [[NSMutableArray alloc] init];
                     NSMutableArray *arr_changed = [[NSMutableArray alloc] init];
                     
                     for (NSString* version in ma_arr){
                         NSString *changedV = [version stringByReplacingOccurrencesOfString:@"v" withString:@""];
                         changedV = [changedV stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                         [arr_origin addObject:version];
                         [arr_changed addObject:changedV];
                     }
                     NSDictionary *didid = [NSDictionary dictionaryWithObjects:arr_origin forKeys:arr_changed];
                     NSLog(@"%@", didid);

                     NSArray *sorted = [arr_changed sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
                         return [s1 localizedStandardCompare:s2];
                     }];
                     sorted =  [NSArray arrayWithArray:sorted];
                     arr_origin = [[NSMutableArray alloc] init];
                     for (NSString *version in sorted) {
                         NSString *str = [didid objectForKey:version];
                         NSLog(@"%@", str);

                         [arr_origin addObject:str];
                     }
                     hostSectionsArray = [NSArray arrayWithArray:arr_origin];
                     hostSectionsArray = [[hostSectionsArray reverseObjectEnumerator] allObjects];
                     hostsDicts =  [NSMutableDictionary dictionaryWithObjects:ma_arr_app forKeys:ma_arr];
                     
                     
                     //                     NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self"
                     //                                                                                 ascending:NO];
                     //                     hostSectionsArray = [hostSectionsArray sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
                     
                     //                     NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                     //                     hostSectionsArray = [hostSectionsArray sortedArrayUsingComparator:^(id obj1, id obj2) {
                     //                         if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
                     //                             NSArray *obj1Components = [(NSString *)obj1 componentsSeparatedByString:@"."];
                     //                             NSArray *obj2Components = [(NSString *)obj2 componentsSeparatedByString:@"."];
                     //                             NSUInteger highestCount = obj1Components.count;
                     //                             if (obj2Components.count > highestCount) {
                     //                                 highestCount = obj2Components.count;
                     //                             }
                     //                             for (int i = 0; i < highestCount; i++) {
                     //                                 // If the component does not exist, just make it 0
                     //                                 NSNumber *num1 = [NSNumber numberWithInt:0];
                     //                                 if (i < obj1Components.count) {
                     //                                     num1 = [nf numberFromString:[obj1Components objectAtIndex:i]];
                     //                                 }
                     //                                 NSNumber *num2 = [NSNumber numberWithInt:0];
                     //                                 if (i < obj2Components.count) {
                     //                                     num2 = [nf numberFromString:[obj2Components objectAtIndex:i]];
                     //                                 }
                     //                                 int int1 = [num1 intValue];
                     //                                 int int2 = [num2 intValue];
                     //                                 if (int1 > int2) {
                     //                                     return NSOrderedAscending;
                     //                                 } else if (int2 > int1) {
                     //                                     return NSOrderedDescending;
                     //                                 }
                     //                             }
                     //                             // If we reach here, they're the same.
                     //                             return NSOrderedSame;
                     //                         } else {
                     //                             // They're not strings, so just say they're the same
                     //                             return NSOrderedSame;
                     //                         }
                     //                     }];
                     // NSLog(@"******** %@", hostSectionsArray);
                     [self.mainTableView reloadData];
                 } else {
                 }
             }
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
    return 1;
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
    
    ITAppHoster *host = [ITAppHoster new];
    host.hosterCracker = @"";
    host.hosterName = @"Baytapps.net";
    host.hosterLink = @"Baytapps.net";
    host.isProtected = NO;
    host.isVerified = YES;
    
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
    tappedVersion = [hostSectionsArray objectAtIndex:indexPath.row];
    PFObject *currentArray = [hostsDicts valueForKey:tappedVersion];
    if (self.isCydia) {
        NSString *url_app = currentArray[@"installAppUrlLowercase"];
        
        NSLog(@"%@", url_app);
        //        return;
        [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url_app, @"requestedVersion":tappedVersion                                                           , @"requestedHost": @"macSERVER"} forKey:@"requestedAppInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSString *url_app = currentArray[@"installAppUrlLowercase"];
        [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":url_app, @"requestedVersion":tappedVersion, @"requestedHost": @"www.iMokhles.com"} forKey:@"requestedAppInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    //    NSArray *currentArray = [hostsDicts valueForKey:[hostSectionsArray objectAtIndex:indexPath.section]];
    //    NSDictionary *hostDict = [currentArray objectAtIndex:indexPath.row];
    //
    //    tappedHost = [hostDict objectForKey:@"host"];
    //    tappedVersion = [hostSectionsArray objectAtIndex:indexPath.section];
    //
    //    //    if ([[hostDict objectForKey:@"host"] containsString:@"filepup"] || [[hostDict objectForKey:@"host"] containsString:@"appd.be"]  || [[hostDict objectForKey:@"host"] containsString:@"dailyuploads"]) {
    //    if ([[hostDict objectForKey:@"host"] containsString:@"filepup"] ||  [[hostDict objectForKey:@"host"] containsString:@"sendspace"] || [[hostDict objectForKey:@"host"] containsString:@"appd.be"] || [[hostDict objectForKey:@"host"] containsString:@"mega.co"] ||  [[hostDict objectForKey:@"host"] containsString:@"mediafree"] || [[hostDict objectForKey:@"host"] containsString:@"cloudshares"] || [[hostDict objectForKey:@"host"] containsString:@"ul.to"] ) {
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
    //                NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [hostDict objectForKey:@"link"]]];
    //                // NSLog(@"URL :: %@", [NSString stringWithFormat:@"%@", [hostDict objectForKey:@"link"]]);
    //
    //                UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    //                [ITHelper showHudWithText:NSLocalizedString(@"Request App...", @"") inView:controller.view dismissAfterDelay:11];
    //
    //                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //                [webView1 loadRequest:request];
    //            }
    //        }];
    //
    //
    //    } else {
    //        [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Host not supported", @"")];
    //    }
    //
    //
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = request.URL.absoluteString;
    
    
    //
    //    if (([url containsString:@"filepup"] || [url containsString:@"dailyuploads"] || [url containsString:@"openload"] || [url containsString:@"turbobit"] || [url containsString:@"mediafree"] || [url containsString:@"cloudshares"] || [url containsString:@"ul.to"] || [url containsString:@"appd.be"] || [url containsString:@"fpdi_ticket"] || [url containsString:@"sendspace"] || [url containsString:@"mediafire"]) && (![url containsString:@"ads"] || ![url containsString:@"redirector"]))  {
    
    if (([url containsString:@"filepup"]   || [url containsString:@"mediafree"] || [url containsString:@"cloudshares"] || [url containsString:@"ul.to"] || [url containsString:@"appd.be"] || [url containsString:@"fpdi_ticket"] || [url containsString:@"sendspace"] || [url containsString:@"mediafire"]) && (![url containsString:@"ads"] || ![url containsString:@"redirector"]))  {
        
        // NSLog(@"webView -> URL :: %@", url);
        
        if ([url containsString:@"filepup"] && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
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
                            [webView stopLoading];
                        } else {
                            if (error != nil) {
                                [ITHelper showErrorMessageFrom:self withError:error];
                            }
                        }
                    }];
                } else {
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
        } else if (([url containsString:@"appd.be"] || [url containsString:@"appdb.cc"]) && (![url containsString:@"ads"] || ![url containsString:@"googleads"])) {
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
    
    // NSLog(@"******** %@", url);
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
