//
//  BAChooserViewController.m
//  baytapps
//
//  Created by iMokhles on 08/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAChooserViewController.h"
#import "BAChooserCell.h"
#import "BAProfileViewController.h"
//#import "UICKeyChainStore.h"
#import "ITServerHelper.h"

@interface BAChooserViewController () <UITableViewDelegate, UITableViewDataSource, LGRefreshViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate> {
    NSMutableArray *users;
    NSMutableArray *filteredUsers;
    BOOL isFiltered;
    BOOL isSearchBarVisible;
    DGActivityIndicatorView *activityIndicator;
    
    BOOL isPushedVC;
}

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;

@end

@implementation BAChooserViewController

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
//        // // NSLog(@"******* !!!");
//        return;
//    }
    
//    if (paymentMethodString.length == 0) {
//        // // NSLog(@"******* !!! 2");
//        return;
//    }
    
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
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    if ([self isMovingToParentViewController]) {
        isPushedVC = YES;
        [_backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        
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
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    users = [[NSMutableArray alloc] init];
    
    
    
    [self setupTableView];
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
    [self setup_SearchBar];
    
    _refreshView = [LGRefreshView refreshViewWithScrollView:self.mainTableView delegate:self];
    [_refreshView setTintColor:[BAColorsHelper ba_whiteColor]];
    
    [self loadUsers];
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

- (void)loadUsers {
   
    
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
    
    
    
    if (self.loadSupportOnly == YES) {
//        PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//        [query1 whereKey:PF_BLOCKED_USER1 equalTo:[PFUser currentUser]];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query2 whereKey:PF_USER_OBJECTID notEqualTo:[PFUser currentId]];
//        [query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:nil];
        //[query2 whereKey:PF_USER_FULLNAME containsString:@"Support"];
        [query2 orderByAscending:PF_USER_FULLNAME_LOWER];
        [query2 setLimit:1000];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 [users removeAllObjects];
                 [users addObjectsFromArray:objects];
                 [self.mainTableView reloadData];
             }
             else [ITHelper showErrorMessageFrom:self withError:error];
         }];
    } else {
//        PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//        [query1 whereKey:PF_BLOCKED_USER1 equalTo:[PFUser currentUser]];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query2 whereKey:PF_USER_OBJECTID notEqualTo:[PFUser currentId]];
//        [query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:nil];
        [query2 orderByAscending:PF_USER_FULLNAME_LOWER];
        [query2 setLimit:1000];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 [users removeAllObjects];
                 [users addObjectsFromArray:objects];
                 [self.mainTableView reloadData];
             }
             else [ITHelper showErrorMessageFrom:self withError:error];
         }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    unsigned long CellsNumbers;
    if (isFiltered) {
        CellsNumbers = filteredUsers.count;
    } else {
        CellsNumbers = [users count];
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
    BAChooserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAChooserCell"];
    PFUser *user = users[indexPath.section];
    if (isFiltered == YES) {
        user = filteredUsers[indexPath.section];
    }
    cell.isSupportCell = self.loadSupportOnly;
    [cell configureWithUser:user];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUser *user = users[indexPath.section];
    
    if (isFiltered == YES) {
        user = filteredUsers[indexPath.section];
    }
    if (self.loadSupportOnly == YES) {
        self.userTappedBlock(self, user);
    } else {
        BAProfileViewController *profileVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"profileVC"];
        profileVC.mainUser = user;
        [self.navigationController pushViewController:profileVC animated:YES];
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
- (void)tableView:(UITableView *)tableView willDisplayCell:(BAChooserCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [cell setSelectedBackgroundView:bgColorView];
}
#pragma mark - LGRefreshViewDelegate
- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    [self loadUsers];
    [refreshView endRefreshing];
}

- (IBAction)topBackBtnTapped:(UIButton *)sender {
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
        
        NSPredicate *searchPreidcate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            BOOL matches = NO;
            if ([[evaluatedObject[PF_USER_FULLNAME] lowercaseString] rangeOfString:[searchText lowercaseString] options:NSCaseInsensitiveSearch].length > 0) {
                matches = YES;
            }
            return matches;
        }];
        filteredUsers = [[[users copy] filteredArrayUsingPredicate:searchPreidcate] mutableCopy];
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
