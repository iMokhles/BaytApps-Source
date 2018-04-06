//
//  BATweaksViewController.m
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 imokhles. All rights reserved.
//

#import "BATweaksViewController.h"
#import "BAHelper.h"
#import "ITHelper.h"
#import "BAColorsHelper.h"
#import "ITServerHelper.h"
#import "Definations.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "BAAppCell.h"
#import "AppDescriptionViewController.h"
#import "UICKeyChainStore.h"
#import "ITConstants.h"
#import "SBJson.h"

@interface BATweaksViewController () <UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate> {
    NSMutableArray *appsArray;
    NSMutableArray *filteredObjects;
    BOOL isFiltered;
    
    BOOL isSearchBarVisible;
    DGActivityIndicatorView *activityIndicator;
    
    BOOL isPushedVC;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation BATweaksViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
//    UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
//    
//    NSString *paidStatus = [keyWrapper stringForKey:@"it_6"];
//    NSString *paymentMethodString = [keyWrapper stringForKey:@"it_5"];
//    NSString *orderStatusString = [keyWrapper stringForKey:@"it_8"];
//    NSString *orderDateString =  [keyWrapper stringForKey:@"it_67"];
//    
//    if (paidStatus.length == 0) {
//        // NSLog(@"******* !!!");
//        return;
//    }
//    
////    if (paymentMethodString.length == 0) {
////        // NSLog(@"******* !!! 2");
////        return;
////    }
//    
//    if (orderStatusString.length == 0) {
//        // NSLog(@"******* !!! 3");
//        return;
//    }
//    
//    if (orderDateString.length == 0) {
//        // NSLog(@"******* !!! 4");
//        return;
//    }
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    if ([self isMovingToParentViewController]) {
        isPushedVC = YES;
        [_menuButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        
    } else {
        isPushedVC = NO;
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
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
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
}

- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTableView];
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    self.currentPage = 1;
    [self loadApps];
    [self setup_SearchBar];
    [self.mainTableView reloadData];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    _refreshView = [LGRefreshView refreshViewWithScrollView:self.mainTableView delegate:self];
    [_refreshView setTintColor:[BAColorsHelper ba_whiteColor]];
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
        [self.mainTableView setContentOffset:CGPointMake(0, 44) animated:YES];
    });
    isSearchBarVisible = NO;
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

- (void)loadApps {
    
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
        if (!ok) { // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // NSLog(@"error parsing extracted plist — %@",error);
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
    if (teamID.length > 0) {
        if ([teamID isEqualToString:@"dd7dc237-6c96-4b70-b671-f06b7682c847"] && [teamID2 isEqualToString:@"KH5MPTCV98"]) accountType = @"ipa";
        
        
        if ([teamID2 isEqualToString:@"FC4F38T32K"]) accountType = @"ipa2";
        if ([teamID2 isEqualToString:@"2EPK7SEG45"]) accountType = @"ipa3";
        if ([teamID2 isEqualToString:@"EAST223S7M"]) accountType = @"ipa4";
        if ([teamID2 isEqualToString:@"6SH9WE2ENU"]) accountType = @"ipa5";
        if ([teamID2 isEqualToString:@"3QZW2N7S46"]) accountType = @"ipa6";
        if (![teamID isEqualToString:@"dd7dc237-6c96-4b70-b671-f06b7682c847"] && [teamID2 isEqualToString:@"KH5MPTCV98"]) accountType = @"ipa7";
    } else {
        accountType = @"ipa";
        return;
    }
   
    
    if ([PFUser currentUser] == nil) {
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
//        // NSLog(@"********* 1))) %@ = %@", passUDID, passUDID1);
//        return;
//    }
//    
//    if (![[DecryptText(@"", [keyWrapper stringForKey:@"it_1"]) lowercaseString] isEqualToString:[passAUTH1 lowercaseString]]) {
//        // NSLog(@"********* 2))) %@ = %@", passAUTH1, passAUTH);
//        return;
//    }
//    
    
    
    [[ITHelper sharedInstance] getAllAppsForCydiaCat:@"cydia" page:self.currentPage withCompletion:^(NSArray *allApps, NSError *error) {
        if (allApps && !error)
        {
            if (appsArray.count < 1)
            {
                appsArray = [allApps mutableCopy];
                [self.mainTableView reloadData];
            }
            else if (![self addNewPostsCydiaFromArray:allApps])
            {
                // If we had no new items, move back one page
                if (self.currentPage > 0) self.currentPage--;
            }
        } else
        {
            // NSLog(@"Error: %@", error);
        }
        self.isRefreshing = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [KSToastView dismissToastView];
    }];

    
//    [ITServerHelper getAllCustomAppsForCat:accountType withBlock:^(BOOL succeeded, NSArray *objects, NSError *error) {
//        if (error == nil) {
//            if (succeeded) {
//                if (objects.count > 0) {
//                    appsArray = [objects mutableCopy];
//                    [self.mainTableView reloadData];
//                    self.isRefreshing = NO;
//                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                }
//            }
//        } else {
//            // NSLog(@"ERROR: %@", error.localizedDescription);
//        }
//    }];
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
        
        [self.mainTableView reloadData];
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    unsigned long CellsNumbers;
    if (isFiltered) {
        CellsNumbers = filteredObjects.count;
    } else {
        CellsNumbers = [appsArray count];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BAAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAAppCell"];
    [cell.appAvailableView setHidden:NO];
    if (!isFiltered) {
//        ITAppObject *app = appsArray[indexPath.section];
//        cell.isTweakCell = YES;
//        [cell configureWithApp:app];
//        
//        if (appsArray.count > 0 && indexPath.section == (appsArray.count - 1))
//        {
//            if (!self.isRefreshing)
//            {
//                // NSLog(@"Refreshing..");
//                
//                self.currentPage++;
//                [KSToastView ks_showToast:@"Loading...."];
//                [self loadApps];
//            }
//            else // NSLog(@"Already refreshing!");
//        }

        
        PFObject *app = appsArray[indexPath.section];
        [cell configureWithPFObject:app];
        cell.isTweakCell = YES;
        return cell;
    } else {
        
//        ITAppObject *app = appsArray[indexPath.section];
//        cell.isTweakCell = YES;
//        [cell configureWithApp:app];
////
//        if (appsArray.count > 0 && indexPath.section == (appsArray.count - 1))
//        {
//            if (!self.isRefreshing)
//            {
//                // NSLog(@"Refreshing..");
//                
//                self.currentPage++;
//                [KSToastView ks_showToast:@"Loading...."];
//                [self loadApps];
//            }
//            else // NSLog(@"Already refreshing!");
//        }

        PFObject *app = filteredObjects[indexPath.section];
        [cell configureWithPFObject:app];
        cell.isTweakCell = YES;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [KVNProgress show];
    UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    
    NSString *paidStatus = [keyWrapper stringForKey:@"it_6"];
    NSString *paymentMethodString = [keyWrapper stringForKey:@"it_5"];
    NSString *orderStatusString = [keyWrapper stringForKey:@"it_8"];
    NSString *orderDateString =  [keyWrapper stringForKey:@"it_67"];
    
    if (paidStatus.length == 0) {
        return;
    }
//    if (paymentMethodString.length == 0) {
//        return;
//    }
    
    if (orderStatusString.length == 0) {
        return;
    }
    
    if (orderDateString.length == 0) {
        return;
    }
//    ITAppObject *app = appsArray[indexPath.section];
//    AppDescriptionViewController *appDescrip = [self.storyboard instantiateViewControllerWithIdentifier:@"appDescrip"];
//    appDescrip.object = app;
//    appDescrip.isCydiaApp = YES;
//    [self.navigationController pushViewController:appDescrip animated:YES];
    
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
        if (!ok) { // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return;
        }
    }
    NSDictionary *profile = mobileProvision;
    NSString *teamID = profile[@"UUID"];
    
    if (teamID.length > 0) {
        
        NSString *teamID2 = [profile[@"TeamIdentifier"] objectAtIndex:0];
        NSString *accountType;
        if (teamID.length > 0) {
            if ([teamID isEqualToString:@"dd7dc237-6c96-4b70-b671-f06b7682c847"] && [teamID2 isEqualToString:@"KH5MPTCV98"]) accountType = @"ipa";
            
            
            if ([teamID2 isEqualToString:@"FC4F38T32K"]) accountType = @"ipa2";
            if ([teamID2 isEqualToString:@"2EPK7SEG45"]) accountType = @"ipa3";
            if ([teamID2 isEqualToString:@"EAST223S7M"]) accountType = @"ipa4";
            if ([teamID2 isEqualToString:@"6SH9WE2ENU"]) accountType = @"ipa5";
            if ([teamID2 isEqualToString:@"3QZW2N7S46"]) accountType = @"ipa6";
            if (![teamID isEqualToString:@"dd7dc237-6c96-4b70-b671-f06b7682c847"] && [teamID2 isEqualToString:@"KH5MPTCV98"]) accountType = @"ipa7";
        } else {
            accountType = @"ipa";
            return;
        }
        
        NSString *apiURL = [NSString stringWithFormat:@"%@/index.php", kCloudAPI];
        
        //            // NSLog(@"******* %@", apiURL);
        PFObject *app;
        if (!isFiltered) {
            app = appsArray[indexPath.section];
        } else {
            app = filteredObjects[indexPath.section];
        }
        NSString *pushToken = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_TOKEN]];
        NSString *signature = @"ABzYP0WoORFAoTxS8ZOlBnUFocwfDQXs42jqsWEeunnqLR3WCepAtIwUKIRhXfx1xT2CKcqQXBltT3UcgOjI7C8LqdHvwNmGxRe2dkpVYuIhdHD7cih3VwHcPonKZeUclmp4LQbdy8D1Nk1j4aglKQXvxKjxGtmLglecLHTqOG09ZKDZ3gdBCbki646fkbeMPFH96IyvIoURiEcoJQCYETq6jrpOuFNLv5yuDFL2AoeItLfq1SsMMMP8ppnpPXlKBPEOcpPxCRUvQNSIZhflpT2Gxem1TQ33APTiEg";

        NSString *customURLString = [NSString stringWithFormat:
                                     @"usertoken=%@"
                                     @"&appID=%@"
                                     @"&accType=%@"
                                     @"&devicetoken=%@"
                                     @"&signature=%@"
                                     @"&ordernumber=%@"
                                     @"&user_devicetoken=%@"
                                     @"&user_deviceauth=%@&customApp=yes",
                                     
                                     
                                     EncryptText(@"", [PFUser currentUser].sessionToken),
                                     EncryptText(@"", app[CUSTOM_APP_ID]),
                                     EncryptText(@"",
                                                 accountType),
                                     EncryptText(@"", pushToken),
                                     EncryptText(@"", signature),
                                     EncryptText(@"", [NSString stringWithFormat:@"%d", 2200]),
                                     EncryptText(@"", pushToken),
                                     EncryptText(@"", pushToken)];
        
        [[ITHelper sharedInstance] newPostMethodWithURL:apiURL postString:customURLString completionBlock:^(NSData *data, NSURLResponse *response) {
            //
            
            NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *userInfo = [strr JSONValue];
            //                // NSLog(@"******* %@", userInfo);
            if (userInfo) {
                NSNumber *statusNU = userInfo[@"status"];
                if ([statusNU boolValue] == YES) {
                    [KVNProgress showSuccess];
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", userInfo[@"message"][@"installUrl"]]]];
                } else {
                    [KVNProgress showError];
                }
            }
        } errorBlock:^(NSError *error) {
            //
            //                // NSLog(@"******* %@", error.localizedDescription);
            [KVNProgress showError];
        } uploadPorgressBlock:^(float progress) {
            //
        } downloadProgressBlock:^(float progress, NSData *data) {
            //
        }];
    } else {
        return;
    }
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
#pragma mark - LGRefreshViewDelegate
- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    [self loadApps];
    [refreshView endRefreshing];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    isFiltered = NO;
    [self.mainTableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!isFiltered) {
        isFiltered = YES;
        [self.mainTableView reloadData];
    }
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSInteger textLength = searchText.length;
    if (textLength == 0) {
        isFiltered = NO;
        [self.searchBar resignFirstResponder];
    } else {
        isFiltered = YES;
        
        NSPredicate *searchPreidcate = [NSPredicate predicateWithBlock:^BOOL(PFObject *evaluatedObject, NSDictionary *bindings) {
            BOOL matches = NO;
            if ([evaluatedObject[CUSTOM_APP_NAME_STRING] rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
                matches = YES;
            }
            return matches;
        }];
        filteredObjects = [[[appsArray copy] filteredArrayUsingPredicate:searchPreidcate] mutableCopy];
    }
    [self.mainTableView reloadData];
}
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if (isPushedVC) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
            [self.slidingViewController resetTopViewAnimated:YES];
        } else {
            [self.slidingViewController anchorTopViewToRightAnimated:YES];
        }
    }
    
}
- (IBAction)rightButtonTapped:(UIButton *)sender {
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
