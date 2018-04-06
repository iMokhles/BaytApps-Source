//
//  BATimelineViewController.m
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BATimelineViewController.h"
#import "BAHelper.h"
#import "BAColorsHelper.h"
#import "BAUserAppCell.h"

#import "ITHelper.h"
#import "ITServerHelper.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "AppHostersViewController.h"
#import "AppDescriptionViewController.h"
#import "CACheckConnection.h"
//#import "UICKeyChainStore.h"

@interface BATimelineViewController () <UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate> {
    DGActivityIndicatorView *activityIndicator;
//    NSMutableArray *usersAppsArray;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) LGRefreshView *refreshView;

@property (nonatomic, strong) NSMutableDictionary *timelineDict;
@property (nonatomic, strong) NSMutableArray *followingArray;
@property (nonatomic, strong) NSArray *postsArray;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation BATimelineViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
    
    if ([PFUser currentUser] == nil) {
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
//    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
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
}

- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
    [self getFollowing];
    [self.mainTableView reloadData];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    _refreshView = [LGRefreshView refreshViewWithScrollView:self.mainTableView delegate:self];
    [_refreshView setTintColor:[BAColorsHelper ba_whiteColor]];
}

-(void)getFollowing
{
    [self getLatestPosts];
}
-(void)getLatestPosts
{
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
    NSDate *now = [NSDate date];
    unsigned int      intFlags   = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSCalendar       *calendar   = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:intFlags fromDate:now];
    
    NSDate *startOfDay = [[NSDate alloc] init];
    startOfDay = [calendar dateFromComponents:components];
    NSDate *priorDate = [[NSDate date] dateByAddingTimeInterval:-90000]; //twentyFiveHoursAgo
    
    [ITServerHelper getAllFollowingForUser:[PFUser currentUser] withBlock:^(BOOL succeeded, NSArray *objects, NSError *error) {
        if (error == nil) {
            PFQuery *query;
            
            NSArray *friends = objects;
            
            PFQuery *myPosts = [PFQuery queryWithClassName:APP_CLASSE_NAME];
            [myPosts whereKey:APP_USER_POINTER equalTo:[PFUser currentUser]];
//            [myPosts whereKey:@"createdAt" greaterThan:priorDate];
            
            PFQuery *friendsPosts = [PFQuery queryWithClassName:APP_CLASSE_NAME];
            [friendsPosts whereKey:APP_USER_POINTER containedIn:friends];
//            [friendsPosts whereKey:@"createdAt" greaterThan:priorDate];
            
            query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:myPosts, friendsPosts, nil]];
            if ([[CACheckConnection sharedManager] isUnreachable]) {
                [query fromLocalDatastore];
            }
            [query orderByDescending:@"createdAt"];
            
            [query includeKey:APP_USER_POINTER];
            
            query.limit = 99; // :)
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                [ITHelper showErrorMessageFrom:self withError:error.localizedDescription];
                if (error == nil)
                {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error != nil) {
                            
                        } else {
                            if (succeeded) {
                                
                            }
                            
                        }
                    }];
                    if (objects.count > 0)
                    {
                        self.postsArray = objects;
                        [self buildTimeline];
                        
                    }
                }
            }];
        }
    }];
    
}
-(void)buildTimeline
{
    [self.mainTableView reloadData];
    
}

#pragma mark - UITableView Delegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.postsArray.count == 0) {
        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:activityIndicator];
        [activityIndicator startAnimating];
        return 0;
    } else {
        [activityIndicator stopAnimating];
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:nil];
        return self.postsArray.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BAUserAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAUserAppCell"];
    
    PFObject *app1 = [PFObject objectWithClassName:APP_CLASSE_NAME];
    if (self.postsArray.count > 0) {
        app1 = self.postsArray[indexPath.section];
    }
//
    [cell configureWithObject:app1];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *app1 = [PFObject objectWithClassName:APP_CLASSE_NAME];
    if (self.postsArray.count > 0) {
        app1 = self.postsArray[indexPath.section];
    }
    NSDictionary *appDict = app1[APP_INFO_DICT];
    ITAppObject *app = [ITAppObject new];
    app.appName = [appDict objectForKey:@"name"];
    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
        app.appIcon = [appDict objectForKey:@"image"];
    } else {
        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
    }
    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
    app.appID = [appDict objectForKey:@"bundle_id"];
    app.appVersion = [appDict objectForKey:@"version"];
    app.appStore = [appDict objectForKey:@"store"];
    app.appPrice = [appDict objectForKey:@"price"];
    app.appTrackID = [appDict objectForKey:@"original_trackid"];
    app.appInfo = appDict;
    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
        app.appSection = @"cydia";
    } else {
        if ([[appDict objectForKey:@"original_section"] length] == 0) {
            app.appSection = @"ios";
        } else {
            app.appSection = [appDict objectForKey:@"original_section"];
        }
        
    }
    app.appScreenshots = [appDict objectForKey:@"screenshots"];
    AppDescriptionViewController *appDescrip = [self.storyboard instantiateViewControllerWithIdentifier:@"appDescrip"];
    [[ITHelper sharedInstance] getAppInfoFromItunes:app.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
        if (allApps.count > 0) {
            if (![app.appInfo[@"id"] isEqualToString:@"0"]) {
                appDescrip.object = app;
                [self.navigationController pushViewController:appDescrip animated:YES];
            }
        } else {
            AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
            appHosters.app = app;
            appHosters.sectionName = @"ios";
            [self.navigationController pushViewController:appHosters animated:YES];
        }
        
    }];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(BAUserAppCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [cell setSelectedBackgroundView:bgColorView];
}
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}
- (IBAction)rightButtonTapped:(UIButton *)sender {
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    [self getFollowing];
    [refreshView endRefreshing];
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
