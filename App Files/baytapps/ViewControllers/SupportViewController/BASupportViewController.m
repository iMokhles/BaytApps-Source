//
//  BASupportViewController.m
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BASupportViewController.h"
#import "JGActionSheet.h"


// support classes

//#import "SelectSingleView.h"
//#import "SelectMultipleView.h"

#import "ProgressHUD.h"

#import "utilities.h"

#import "RecentView.h"
#import "RecentCell.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "NavigationController.h"

#import "LGRefreshView.h"
#import "DGActivityIndicatorView.h"
#import "BAChooserViewController.h"
#import "AppDelegate.h"

//#import "UICKeyChainStore.h"

@interface BASupportViewController () <SelectSingleDelegate, UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate, UISearchBarDelegate> {
    NSMutableArray *recents;
    NSMutableArray *filteredObjects;
    BOOL isFiltered;
    
    BOOL isSearchBarVisible;
    DGActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) IBOutlet UIButton *startChatButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

BOOL isRecentViewAppear;

@implementation BASupportViewController


- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.isSupportMessageExist = NO;
    [app changeBadge];
    [super viewWillAppear:animated];
    if ([PFUser currentUser] == nil) {
        return;
    }
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents:) name:NOTIFICATION_TO_LOAD_RECENTS object:nil];
    
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
    if ([PFUser currentUser] != nil)
    {
        if (self.isNotificationAction) {
            [self actionChat:self.chatId forUser:self.chatWithUser];
        }
    }
}

- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (isSearchBarVisible) {
        [self searchButtonTapped:nil];
    }
    [self.navigationController.navigationBar setOpaque:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    recents = [[NSMutableArray alloc] init];
    [self setupTableView];
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
    [self setup_SearchBar];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([PFUser currentUser] != nil)
    {
        [self loadRecents];
        
        isRecentViewAppear = YES;
    }
    else LoginUser(self);
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

- (void)loadRecents:(NSNotification *)notification {
    
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }

    
    
    
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_RECENT_LASTUSER];
    [query orderByDescending:PF_RECENT_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             int number = 0;
             for (int i = 0; i < objects.count; i++) {
                 if (i == [objects count]-1) {
                     int newNumber = number++;
//                     // // NSLog(@"NUMBER: *** %i", newNumber);
                 }
                 number++;
             }
             if (objects.count == 0) {
                 NSDictionary *userDict = notification.userInfo;
                 NSString *userObjectID = userDict[@"userObjectID"];
                 
                 PFQuery *contacts = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
                 [contacts whereKey:@"objectId" equalTo:userObjectID];
                 [contacts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objectsUsers, NSError * _Nullable error) {
                     PFUser *user2 = [objectsUsers objectAtIndex:0];
                     if (![user2.objectId isEqual:[PFUser currentUser].objectId]) {
                         PFUser *user1 = [PFUser currentUser];
                         StartPrivateChat(user1, user2);
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self loadRecents];
                         });
                     }
                     
                 }];
             } else if (objects.count > 0) {
                 NSDictionary *userDict = notification.userInfo;
                 NSString *userObjectID = userDict[@"userObjectID"];
                 
                 PFQuery *contacts = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
                 [contacts whereKey:@"objectId" equalTo:userObjectID];
                 [contacts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objectsUsers, NSError * _Nullable error) {
                     PFUser *user2 = [objectsUsers objectAtIndex:0];
                     for (PFObject *recent in objects) {
                         if (![user2[PF_RECENT_DESCRIPTION] isEqualToString:recent[PF_RECENT_DESCRIPTION]]) {
                             
                             if (![user2.objectId isEqual:[PFUser currentUser].objectId]) {
                                 PFUser *user1 = [PFUser currentUser];
                                 StartPrivateChat(user1, user2);
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [self loadRecents];
                                 });
                             }
                             
                         }
                         
                     }
                 }];
             }
             
         }
         else [ProgressHUD showError:NSLocalizedString(@"Network error.", @"")];
     }];
    
}
- (void)loadRecents {
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_RECENT_LASTUSER];
    [query orderByDescending:PF_RECENT_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             if (objects.count == 0) {
                 [recents removeAllObjects];
                 [recents addObjectsFromArray:objects];
                 [self.mainTableView reloadData];
                 [self updateTabCounter];
                 [self initchat];
                 
                } else if (objects.count > 0) {
                 [recents removeAllObjects];
                 [recents addObjectsFromArray:objects];
                 [self.mainTableView reloadData];
                 [self updateTabCounter];
             }
             
         }
         else [ITHelper showErrorMessageFrom:self withError:error];
     }];
}
-(void)initchat{
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:@"support@baytapps.net" ];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        PFUser *user2 = [objects objectAtIndex:0];
        PFUser *user1 = [PFUser currentUser];
        NSString *groupId = StartPrivateChat(user1, user2);
        [self actionChat:groupId forUser:user2];
        
        PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
        object[PF_MESSAGE_USER] = user2;
        object[PF_MESSAGE_GROUPID] = groupId;
        object[PF_MESSAGE_TEXT] = @"Welcome to Baytapps support. How may I help you?";

        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             
             if (error == nil)
             {
                 UpdateRecentCounter(groupId, 1, @"Welcome to Baytapps support. How may I help you?");

                 [JSQSystemSoundPlayer jsq_playMessageSentSound];
             }
             else [ITHelper showErrorMessageFrom:self withError:error];
         }];
        //---------------------------------------------------------------------------------------------------------------------------------------------
        //SendPushNotification(groupId, text, self.chatUser);
       
    }];
}


- (void)updateTabCounter {
    int total = 0;
    for (PFObject *recent in recents)
    {
        total += [recent[PF_RECENT_COUNTER] intValue];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:total] forKey:PF_RECENT_COUNTER];
}
- (void)actionCleanup
{
    [recents removeAllObjects];
    [self.mainTableView reloadData];
    [self updateTabCounter];
}
- (void)actionChat:(NSString *)groupId forUser:(PFUser *)toUser {
    
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.chatUser = toUser;
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    isRecentViewAppear = NO;
    self.isNotificationAction = NO;
    
}
- (void)actionCompose
{
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:NSLocalizedString(@"Live Support", @"") message:nil buttonTitles:@[NSLocalizedString(@"Select Team Member", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                
                BAChooserViewController *searchUsersVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"searchUsersVC"];
                [searchUsersVC setLoadSupportOnly:YES];
                [searchUsersVC setUserTappedBlock:^(BAChooserViewController *viewC, PFUser *user2) {
                    [viewC.navigationController popViewControllerAnimated:YES];
                    PFUser *user1 = [PFUser currentUser];
                    NSString *groupId = StartPrivateChat(user1, user2);
                    [self actionChat:groupId forUser:user2];
                }];
                [self.navigationController pushViewController:searchUsersVC animated:YES];
//                SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
//                selectSingleView.delegate = self;
//                NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
//                navController.modalPresentationStyle = UIModalPresentationFormSheet;
//                [self presentViewController:navController animated:YES completion:nil];
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

- (void)didSelectSingleUser:(PFUser *)user2 {
//    PFUser *user1 = [PFUser currentUser];
//    NSString *groupId = StartPrivateChat(user1, user2);
//    [self actionChat:groupId forUser:user2];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    unsigned long CellsNumbers;
    if (isFiltered) {
        CellsNumbers = filteredObjects.count;
    } else {
        CellsNumbers = [recents count];
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
    RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell"];
    [cell bindData:recents[indexPath.section]];
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *recent = recents[indexPath.section];
    [recents removeObject:recent];
    [self updateTabCounter];
    [recent deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:NSLocalizedString(@"Network error.", @"")];
     }];
//    [self.mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.mainTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFObject *recent = recents[indexPath.section];
    PFQuery *contacts = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [contacts whereKey:@"fullName" equalTo:recent[@"description"]];
    [contacts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        PFUser *user2 = [objects objectAtIndex:0];
        [self actionChat:recent[PF_RECENT_GROUPID] forUser:user2];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(RecentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [cell setSelectedBackgroundView:bgColorView];
}

#pragma mark - Buttons Actions
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}
- (IBAction)startChatTapped:(UIButton *)sender {
    if (recents.count > 0) {
        //[ITHelper showAlertViewForExtFromViewController:self WithTitle:NSLocalizedString(@"WARNING", @"") msg:NSLocalizedString(@"mark current chat SOLVED ( first )", @"")];
    } else {
        [self actionCompose];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    isFiltered = NO;
    [self.mainTableView reloadData];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [self searchButtonTapped:nil];
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
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
        
        [self searchButtonTapped:nil];
    } else {
        isFiltered = YES;
        
        NSPredicate *searchPreidcate = [NSPredicate predicateWithBlock:^BOOL(PFObject *evaluatedObject, NSDictionary *bindings) {
            BOOL matches = NO;
            if ([[evaluatedObject[PF_RECENT_DESCRIPTION] lowercaseString] rangeOfString:[searchText lowercaseString] options:NSCaseInsensitiveSearch].length > 0) {
                matches = YES;
            }
            return matches;
        }];
        filteredObjects = [[[recents copy] filteredArrayUsingPredicate:searchPreidcate] mutableCopy];
    }
    [self.mainTableView reloadData];
}

- (void)searchButtonTapped:(UIButton *)sender {
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

#pragma mark - LGRefreshViewDelegate
- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    [self loadRecents];
    [refreshView endRefreshing];
}
- (IBAction)moreButtonTapped:(UIButton *)sender {
    if (self.mainTableView.isEditing) {
        [self.mainTableView setEditing:NO animated:YES];
    } else {
        [self.mainTableView setEditing:YES animated:YES];
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
