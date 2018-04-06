//
//  BASideMenuViewController.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BASideMenuViewController.h"
#import "BAHelper.h"
#import "BAColorsHelper.h"
#import "BASideMenuCell.h"
#import "ITHelper.h"
#import "ITServerHelper.h"
#import "Definations.h"
#import "AppConstant.h"
#import "AppDelegate.h"

//#import "UICKeyChainStore.h"

@interface BASideMenuViewController () <UITableViewDataSource, UITableViewDelegate> {
 //   UICKeyChainStore *key;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UILabel *userFullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

// menu items
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *menuItemsIcons;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTrailConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineTrailConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewTrailConstraint;
@end

@implementation BASideMenuViewController{
    int updateNoti;
    int messageNoti;

}

- (void)viewDidLoad {
    updateNoti = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    if ([BAHelper isIPHONE4] || [BAHelper isIPHONE5] || [BAHelper isIPHONE6]) {
        self.tableTrailConstraint.constant  = 100.0;
        self.lineTrailConstraint.constant  = 100.0;
        self.topViewTrailConstraint.constant  = 100.0;
    } else {
        if ([BAHelper isIPHONE6PLUS]) {
            self.tableTrailConstraint.constant  = 150.0;
            self.lineTrailConstraint.constant  = 150.0;
            self.topViewTrailConstraint.constant  = 150.0;
        } else {
            self.tableTrailConstraint.constant  = 350.0;
            self.lineTrailConstraint.constant  = 350.0;
            self.topViewTrailConstraint.constant  = 350.0;
        }
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
    
    

    
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = 25;
    [self setupUserInfo];
    [self setupTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *app =(AppDelegate*) [[UIApplication sharedApplication] delegate];
        if (app.isUpdateExist) {
            updateNoti = 1;
        }
    if(app.isSupportMessageExist){
            messageNoti = 1;
        }
}
- (void)setupUserInfo {
    if ([PFUser currentUser] != nil) {
        
//        UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
//        
//        NSString *passAUTH = DecryptText(@"", [keyWrapper stringForKey:@"it_1"]);
//        NSString *passUDID = DecryptText(@"", [keyWrapper stringForKey:@"it_3"]);
//        
//        NSString *passAUTH1 = DecryptText(@"", [PFUser currentUser][USER_DEVICE_TYPE]);
//        NSString *passUDID1 = DecryptText(@"", [PFUser currentUser][USER_DEVICE_ID]);
//        
//        if (![[DecryptText(@"", [keyWrapper stringForKey:@"it_3"]) lowercaseString] isEqualToString:[passUDID1 lowercaseString]]) {
//            // // NSLog(@"********* 1))) %@ = %@", passUDID, passUDID1);
//            return;
//        }
//        
//        if (![[DecryptText(@"", [keyWrapper stringForKey:@"it_1"]) lowercaseString] isEqualToString:[passAUTH1 lowercaseString]]) {
//            // // NSLog(@"********* 2))) %@ = %@", passAUTH1, passAUTH);
//            return;
//        }
//        
//        if (passAUTH.length == 0) {
//            return;
//        }
//        
//        if (passUDID.length == 0) {
//            return;
//        }
        
        NSString *fullNameString = [PFUser currentUser][USER_FULLNAME];
        NSString *userNameString = [PFUser currentUser][USER_USERNAME];
        
        [self.userFullNameLabel setText:fullNameString];
        [self.userNameLabel setText:[NSString stringWithFormat:@"@%@", userNameString]];
        
        PFFile *userAvatar = [PFUser currentUser][USER_AVATAR];
        [userAvatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error == nil) {
                if (data != nil) {
                    if (data.length > 510) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.userImageView setImage:[UIImage imageWithData:data]];
                        });
                    } else if (data.length <= 510) {
                        [self.userImageView setImageWithString:[PFUser currentUser][USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.userImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                    }
                }
            }
        }];
        
        
    }
}

- (void)setupTableView {
    [self.mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (NSArray *)menuItems {
    if (_menuItems) return _menuItems;
    
//    _menuItems = @[NSLocalizedString(@"Home", @"sidemenu apps cell"), NSLocalizedString(@"Timeline", @"sidemenu timeline cell"), NSLocalizedString(@"Tweaks", @"sidemenu tweaks cell"), NSLocalizedString(@"App Manager", @"sidemenu tweaks cell"), NSLocalizedString(@"Profile", @"sidemenu profile cell"), NSLocalizedString(@"Settings", @"sidemenu settings cell"), NSLocalizedString(@"Live Support", @"sidemenu live_support cell"), NSLocalizedString(@"Search Users", @"sidemenu search_users cell"), NSLocalizedString(@"Logout", @"sidemenu logout cell")];
//    
//    _menuItemsIcons = @[@"Home", @"Timeline", @"Tweaks", @"App Manager", @"Profile", @"Settings", @"Live Support", @"Search Users", @"Logout"];
//    _menuItems = @[NSLocalizedString(@"Home", @"sidemenu apps cell"), NSLocalizedString(@"Tweaks", @"sidemenu tweaks cell"), NSLocalizedString(@"App Manager", @"sidemenu tweaks cell"),NSLocalizedString(@"Browser", @"sidemenu Browser cell"), NSLocalizedString(@"Profile", @"sidemenu profile cell"), NSLocalizedString(@"Settings", @"sidemenu settings cell"), NSLocalizedString(@"Live Support", @"sidemenu live_support cell"), NSLocalizedString(@"Search Users", @"sidemenu search_users cell"), NSLocalizedString(@"Logout", @"sidemenu logout cell")];
//    
//    _menuItemsIcons = @[@"Home",  @"Tweaks",@"App Manager",@"Browser", @"Profile", @"Settings", @"Live Support", @"Search Users", @"Logout"];
//    
    _menuItems = @[NSLocalizedString(@"Home", @"sidemenu apps cell"), NSLocalizedString(@"Tweaks", @"sidemenu tweaks cell"), NSLocalizedString(@"App Manager", @"sidemenu tweaks cell"),NSLocalizedString(@"Browser", @"sidemenu Browser cell"), NSLocalizedString(@"Profile", @"sidemenu profile cell"),NSLocalizedString(@"Update App", @"sidemenu update cell"), NSLocalizedString(@"Settings", @"sidemenu settings cell"), NSLocalizedString(@"Live Support", @"sidemenu live_support cell"), NSLocalizedString(@"Search Users", @"sidemenu search_users cell"), NSLocalizedString(@"Logout", @"sidemenu logout cell")];
    
    _menuItemsIcons = @[@"Home",  @"Tweaks",@"App Manager",@"Browser", @"Profile", @"Update", @"Settings", @"Live Support", @"Search Users", @"Logout"];
    return _menuItems;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.menuItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BASideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BASideMenuCell" forIndexPath:indexPath];
    NSString *title = self.menuItems[indexPath.section];
    NSString *iconsNames = self.menuItemsIcons[indexPath.section];
    // NSLog(@"%@", [NSString stringWithFormat:@"%@2", [iconsNames lowercaseString]]);
    [cell configureWithIcon:[UIImage imageNamed:[NSString stringWithFormat:@"%@2", [iconsNames lowercaseString]]] andTitle:title];
    if (indexPath.section == 7) {
        if(messageNoti > 0){
            cell.enableBadgeView = YES;
            cell.cellBadgeLabel.text = [NSString stringWithFormat:@"%i", messageNoti];
        }else{
            cell.enableBadgeView = NO;
            cell.cellBadgeLabel.text = [NSString stringWithFormat:@"%i", messageNoti];
        }
            }
    if (indexPath.section == 5) {
        if(updateNoti > 0){
            cell.enableBadgeView = YES;
            cell.cellBadgeLabel.text = [NSString stringWithFormat:@"%i", updateNoti];
        }else{
            cell.enableBadgeView = NO;
            cell.cellBadgeLabel.text = [NSString stringWithFormat:@"%i", updateNoti];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
//    if (indexPath.section == 0) {
//        UINavigationController *homeNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"homeNavigationController"];
//        [ITHelper setMainRootViewController:homeNavigationController];
//    } else if (indexPath.section == 1) {
//        UINavigationController *timelineNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"timelineNavigationController"];
//        [ITHelper setMainRootViewController:timelineNavigationController];
//    } else if (indexPath.section == 2) {
//        UINavigationController *tweaksNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"tweaksNavigationController"];
//        [ITHelper setMainRootViewController:tweaksNavigationController];
//    } else if (indexPath.section == 3) {
//        UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"appManagerNavigationController"];
//        [ITHelper setMainRootViewController:profileNavigationController];
//    } else if (indexPath.section == 4) {
//        UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"profileNavigationController"];
//        [ITHelper setMainRootViewController:profileNavigationController];
//    } else if (indexPath.section == 5) {
//        UINavigationController *settingsNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"settingsNavigationController"];
//        [ITHelper setMainRootViewController:settingsNavigationController];
//    } else if (indexPath.section == 6) {
//        UINavigationController *supportNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"supportNavigationController"];
//        [ITHelper setMainRootViewController:supportNavigationController];
//    } else if (indexPath.section == 7) {
//        UINavigationController *supportNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"chooserNavigationController"];
//        [ITHelper setMainRootViewController:supportNavigationController];
//    } else if (indexPath.section == 8) {
//        
//        [PFUser currentUser][USER_ALREADY_LOGGED] = @"NO";
//        [PFUser currentUser][@"inUse"] = @"";
//        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            
//            if (error == nil) {
//                if (succeeded) {
//                    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
//                        if (error == nil) {
//                            [key removeAllItems];
//                            [ITHelper showLaunchOrMainView:NO];
//                        } else {
//                            [ITHelper showErrorMessageFrom:self withError:error];
//                        }
//                    }];
//                }
//            } else {
//                if ([error.localizedDescription containsString:@"session token"]) {
//                    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
//                        if (error == nil) {
//                            [key removeAllItems];
//                            [ITHelper showLaunchOrMainView:NO];
//                        } else {
//                            [key removeAllItems];
//                            [ITHelper showLaunchOrMainView:NO];
//                            [ITHelper showErrorMessageFrom:self withError:error];
//                        }
//                    }];
//                } else {
//                    [ITHelper showErrorMessageFrom:self withError:error];
//                }
//                
//            }
//        }];
//        
//        
//    }
//    
    if (indexPath.section == 0) {
        UINavigationController *homeNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"homeNavigationController"];
        [ITHelper setMainRootViewController:homeNavigationController];
    }
//        else if (indexPath.section == 1) {
//        UINavigationController *timelineNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"timelineNavigationController"];
//        [ITHelper setMainRootViewController:timelineNavigationController];
//    }
    else if (indexPath.section == 1) {
        UINavigationController *tweaksNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"tweaksNavigationController"];
        [ITHelper setMainRootViewController:tweaksNavigationController];
    }
    else if (indexPath.section == 2) {
        UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"appManagerNavigationController"];
        [ITHelper setMainRootViewController:profileNavigationController];
    }
    else if (indexPath.section == 3) {
        UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"browserNavigationController"];
        [ITHelper setMainRootViewController:profileNavigationController];
    }
    else if (indexPath.section == 4) {
        UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"profileNavigationController"];
        [ITHelper setMainRootViewController:profileNavigationController];
    }
    else if (indexPath.section == 5) {
        UINavigationController *profileNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"updateNavigationController"];
        [ITHelper setMainRootViewController:profileNavigationController];
    }
    else if (indexPath.section == 6) {
        UINavigationController *settingsNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"settingsNavigationController"];
        [ITHelper setMainRootViewController:settingsNavigationController];
    } else if (indexPath.section == 7) {
        UINavigationController *supportNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"supportNavigationController"];
        [ITHelper setMainRootViewController:supportNavigationController];
    } else if (indexPath.section == 8) {
        UINavigationController *supportNavigationController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"chooserNavigationController"];
        [ITHelper setMainRootViewController:supportNavigationController];
    } else if (indexPath.section == 9) {
        
        [PFUser currentUser][USER_ALREADY_LOGGED] = @"NO";
        [PFUser currentUser][@"inUse"] = @"";
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (error == nil) {
                if (succeeded) {
                    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                        if (error == nil) {
                            //[key removeAllItems];
                            [ITHelper showLaunchOrMainView:NO];
                        } else {
                            [ITHelper showErrorMessageFrom:self withError:error];
                        }
                    }];
                }
            } else {
                if ([error.localizedDescription containsString:@"session token"]) {
                    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                        if (error == nil) {
                          //  [key removeAllItems];
                            [ITHelper showLaunchOrMainView:NO];
                        } else {
                            //[key removeAllItems];
                            [ITHelper showLaunchOrMainView:NO];
                            [ITHelper showErrorMessageFrom:self withError:error];
                        }
                    }];
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
                
            }
        }];
        
        
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
