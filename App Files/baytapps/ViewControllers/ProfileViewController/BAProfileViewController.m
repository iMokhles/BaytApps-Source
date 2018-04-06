//
//  BAProfileViewController.m
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAProfileViewController.h"
#import "ITServerHelper.h"
#import "ITHelper.h"
#import "Definations.h"
#import "PFUser+Util.h"
#import "DGActivityIndicatorView.h"
#import "BAAppCell.h"
#import "BAColorsHelper.h"
#import "AppDescriptionViewController.h"
#import "AppHostersViewController.h"
#import "push.h"

#import "JGActionSheet.h"
#import "UIImagePickerController+BlocksKit.h"
#import "RSKImageCropper.h"
#import "converter.h"
//#import "UICKeyChainStore.h"

@interface BAProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, RSKImageCropViewControllerDelegate> {
    NSMutableArray *appsArray;
//    NSArray *appsCopyArray;
    UIImage *userImage;
    
    NSMutableArray *followArray;
    DGActivityIndicatorView *activityIndicator;
    
    BOOL isPushedVC;
    PFUser *pointerUser;
}

@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

// user info
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userFullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet UILabel *appsLabel;

@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *verifieALogoImage;
@end

@implementation BAProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    
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
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    [self.userImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *changeImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImageTapped:)];
    changeImageTap.numberOfTapsRequired = 1;
    [self.userImageView addGestureRecognizer:changeImageTap];
    
    [self.userFullNameLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *changeNameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeNameTapped:)];
    changeNameTap.numberOfTapsRequired = 1;
    [self.userFullNameLabel addGestureRecognizer:changeNameTap];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
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
    
    appsArray = [NSMutableArray new];
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[BAColorsHelper ba_whiteColor] size:70.0f];
    
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
    
    if (self.mainUser == nil) {
        self.mainUser = [PFUser currentUser];
    }
    
    // setup UI
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = 40;
    
    self.verifieALogoImage.layer.masksToBounds = YES;
    self.verifieALogoImage.layer.cornerRadius = self.verifieALogoImage.frame.size.width/2.0f;
    
    self.followButton.layer.masksToBounds = YES;
    self.followButton.layer.cornerRadius = 12;
    [self queryFollow];
    [self setupUserInfo];
    [self queryUserAppsCount];
    [self queryFollowersAndFollowing];
    [self loadApps];
    
}

- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)setupUserInfo {
    
   
    
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
    
    
    if (self.mainUser == nil) {
        if ([PFUser currentUser] != nil) {
            self.mainUser = [PFUser currentUser];
            
            [ITServerHelper isTeamUSER:self.mainUser withBlock:^(BOOL succeeded) {
                if (succeeded) {
                    [self.verifieALogoImage setHidden:NO];
                } else {
                    [self.verifieALogoImage setHidden:YES];
                }
            }];
            NSString *fullNameString = self.mainUser[USER_FULLNAME];
            [self.userFullNameLabel setText:fullNameString];
            PFFile *userAvatar = self.mainUser[USER_AVATAR];
            // // NSLog(@"********** 1 %@", userAvatar.url);
            [userAvatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error == nil) {
                    if (data != nil) {
                        UIImage *userAvatarImage = [UIImage imageWithData:data];
                        [self.userImageView setImage:userAvatarImage];
                    }
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
        }
    } else {
        
        [ITServerHelper isTeamUSER:self.mainUser withBlock:^(BOOL succeeded) {
            if (succeeded) {
                [self.verifieALogoImage setHidden:NO];
            } else {
                [self.verifieALogoImage setHidden:YES];
            }
        }];
        
        if ([self.mainUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
            self.mainUser = [PFUser currentUser];
            NSString *fullNameString = self.mainUser[USER_FULLNAME];
            [self.userFullNameLabel setText:fullNameString];
            PFFile *userAvatar = self.mainUser[USER_AVATAR];
            // // NSLog(@"********** 2 %@", userAvatar.url);
            [userAvatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error == nil) {
                    if (data != nil) {
                        if (data.length > 510) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.userImageView setImage:[UIImage imageWithData:data]];
                            });
                        } else if (data.length <= 510) {
                            [self.userImageView setImageWithString:self.mainUser[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.userImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                        }
                    }
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
        } else {
            NSString *fullNameString = self.mainUser[USER_FULLNAME];
            [self.userFullNameLabel setText:fullNameString];
            PFFile *userAvatar = self.mainUser[USER_AVATAR];
            // // NSLog(@"********** 3 %@", userAvatar.url);
            [userAvatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error == nil) {
                    if (data != nil) {
                        if (data.length > 510) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.userImageView setImage:[UIImage imageWithData:data]];
                            });
                        } else if (data.length <= 510) {
                            [self.userImageView setImageWithString:self.mainUser[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.userImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                        }
                    }
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
        }
    }
    
}

- (void)queryFollowersAndFollowing {
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
//    

    [ITServerHelper getFollowersForUser:self.mainUser withBlock:^(int followersNUM) {
        int followers = followersNUM;
        [ITServerHelper getFollowingForUser:self.mainUser withBlock:^(int followingNUM) {
            int following = followingNUM;
            [_followersLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%i", @""), followers]];
            [_followingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%i", @""), following]];
        }];
    }];
}

- (void)queryUserAppsCount {
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
    
    

    [ITServerHelper getAppsForUser:self.mainUser withBlock:^(int number) {
        [_appsLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%i", @""), number]];
    }];
}

- (void)queryFollow {
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
    
    

    [followArray removeAllObjects];
    
    if (![self.mainUser.objectId isEqual:[PFUser currentUser].objectId]) {
        [self.moreButton setHidden:YES];
        [self.followButton setHidden:NO];
        [ITServerHelper isThisUser:[PFUser currentUser] followThisUser:self.mainUser withBlock:^(BOOL succeeded, NSArray *objects) {
            followArray = [objects mutableCopy];
            if (succeeded) {
                [self.followButton setTitle:NSLocalizedString(@"Unfollow", @"") forState:UIControlStateNormal];
            } else {
                [self.followButton setTitle:NSLocalizedString(@"Follow", @"") forState:UIControlStateNormal];
            }
        }];
    } else {
        [self.moreButton setHidden:NO];
        [self.followButton setHidden:YES];
    }
}

- (void)updateUIAfterTappingFollowButton {
    [self setupUserInfo];
    [self queryFollowersAndFollowing];
    [self queryFollow];
}

- (void)loadApps {
    
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
    

    
    if ([self.mainUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        self.mainUser = [PFUser currentUser];
        [ITServerHelper getAllPostsForUser:self.mainUser limit:nil skip:nil withBlock:^(BOOL succeeded, NSArray *objects) {
            if (succeeded) {
                for (PFObject *post in objects) {
                    
                    if (![appsArray containsObject:post]) {
                        [appsArray addObject:post];
                    }
                    
                }
                [appsArray sortUsingComparator:^NSComparisonResult(PFObject *post1, PFObject *post2) {
                    return [post2.createdAt compare:post1.createdAt];
                }];
                
//                appsCopyArray = [appsArray copy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mainTableView reloadData];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
            } else {
            }
        }];
    } else {
        [ITServerHelper getAllPostsForUser:self.mainUser limit:nil skip:nil withBlock:^(BOOL succeeded, NSArray *objects) {
            if (succeeded) {
                for (PFObject *post in objects) {
                    
                    if (![appsArray containsObject:post]) {
                        [appsArray addObject:post];
                    }
                    
                }
                [appsArray sortUsingComparator:^NSComparisonResult(PFObject *post1, PFObject *post2) {
                    return [post2.createdAt compare:post1.createdAt];
                }];
                
//                appsCopyArray = [appsArray copy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mainTableView reloadData];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
            } else {
            }
        }];
    }
    
}
#pragma mark - UITabelViewDelegate/UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([appsArray count] == 0) {
        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:activityIndicator];
        [activityIndicator startAnimating];
        
        return 0;
    } else {
        [activityIndicator stopAnimating];
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:nil];
    }
    return [appsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BAAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAAppCell"];
    [cell.appAvailableView setHidden:YES];
    PFObject *alertsClass = [PFObject objectWithClassName:APP_CLASSE_NAME];
    if (appsArray.count > 0) {
        alertsClass = appsArray[indexPath.section];
    }
    
    
    pointerUser = [alertsClass objectForKey:APP_USER_POINTER];
    NSLog(@" ***** 2");
    do {
        NSLog(@" ***** 3");
        @try {
            NSLog(@" ***** 4");
            [pointerUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                NSLog(@" ***** 5");
                if (error == nil) {
                    
                    NSLog(@" ***** 6");
                    NSDictionary *appDict = alertsClass[APP_INFO_DICT];
                    BOOL isTweak;
                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
                        isTweak = YES;
                    } else {
                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
                            isTweak = NO;
                        } else {
                            isTweak = ([[appDict objectForKey:@"original_section"] isEqualToString:@"cydia"]);
                        }
                        
                    }
                    
                    [cell setIsTweakCell:isTweak];
                    [cell configureWithObject:alertsClass];
                } else {
                    NSLog(@" ***** 7 %@", error.localizedDescription);
                }
            }];
        } @catch (NSException *e) {
            NSLog(@" ***** 4 %@", [e reason]);
        }
    } while (pointerUser == nil);
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BAAppCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [cell setSelectedBackgroundView:bgColorView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *app1 = [PFObject objectWithClassName:APP_CLASSE_NAME];
    if (appsArray.count > 0) {
        app1 = appsArray[indexPath.section];
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
    
    NSLog(@"****** App Section: %@", app.appSection);
    
    if (app != nil) {
        
        if (app.appInfo[@"id"] != nil) {
            AppDescriptionViewController *appDescrip = [self.storyboard instantiateViewControllerWithIdentifier:@"appDescrip"];
            [[ITHelper sharedInstance] getAppInfoFromItunes:app.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
                
                appDescrip.object = app;
                appDescrip.isCydiaApp = [app.appSection  isEqualToString: @"cydia"];
                @try {
                    if(![self.navigationController.topViewController isKindOfClass:[AppDescriptionViewController class]]) {
                        [self.navigationController pushViewController:appDescrip animated:YES];
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                } @catch (NSException * e) {
                    // NSLog(@"Exception: %@", e);
                    [self.navigationController popToViewController:appDescrip animated:YES];
                } @finally {
                    // NSLog(@"finally");
                }
                
                //        if (allApps.count > 0) {
                //            if (![app.appInfo[@"id"] isEqualToString:@"0"]) {
                //
                //            }
                //        } else {
                //            AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
                //            appHosters.app = app;
                //            appHosters.sectionName = @"ios";
                //            [self.navigationController pushViewController:appHosters animated:YES];
                //        }
                
            }];
        }
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *recent = appsArray[indexPath.section];
    [appsArray removeObject:recent];
    [self loadApps];
    [recent deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             [ITHelper showErrorMessageFrom:self withError:error];
         }
     }];
    [self.mainTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}
//-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *delButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Delete", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//                                    {
//
//                                    }];
//    delButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4]; //arbitrary color
//    
//    
//    return @[delButton];
//}
#pragma mark - Buttons Actions
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
- (IBAction)moreButtonTapped:(UIButton *)sender {
    if (self.mainTableView.isEditing) {
        [self.mainTableView setEditing:NO animated:YES];
    } else {
        [self.mainTableView setEditing:YES animated:YES];
    }
}

- (void)changeImageTapped:(UITapGestureRecognizer *)sender {
    if ([self.mainUser.objectId isEqual:[PFUser currentUser].objectId]) {
        JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:APP_NAME message:NSLocalizedString(@"Profile Picture", @"") buttonTitles:@[NSLocalizedString(@"Capture imagae", @""), NSLocalizedString(@"Choose from gallery?", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
        JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
        
        [section1 setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
        
        NSArray *sections = @[section1, cancelSection];
        
        JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
        
        [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
                    [cameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                    [cameraPicker setBk_didCancelBlock:^(UIImagePickerController * picker) {
                        [picker dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [cameraPicker setBk_didFinishPickingMediaBlock:^(UIImagePickerController * picker, NSDictionary * userInfo) {
                        UIImage* outputImage = [userInfo objectForKey:UIImagePickerControllerEditedImage];
                        if (outputImage == nil) {
                            outputImage = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
                        }
                        if (outputImage) {
                            [picker dismissViewControllerAnimated:YES completion:^{
                                RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:outputImage];
                                imageCropVC.delegate = self;
                                if ([BAHelper isIPAD]) {
                                    [imageCropVC setModalPresentationStyle:UIModalPresentationFormSheet];
                                }
                                [self presentViewController:imageCropVC animated:YES completion:^{
                                    
                                }];
                            }];
                        }
                    }];
                    
                    if ([BAHelper isIPAD]) {
                        [cameraPicker setModalPresentationStyle:UIModalPresentationFormSheet];
                    }
                    [self presentViewController:cameraPicker animated:YES completion:^{
                        
                    }];
                } else if (indexPath.row == 1) {
                    UIImagePickerController *imagesPicker = [[UIImagePickerController alloc] init];
                    [imagesPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                    [imagesPicker setBk_didCancelBlock:^(UIImagePickerController * picker) {
                        [picker dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [imagesPicker setBk_didFinishPickingMediaBlock:^(UIImagePickerController * picker, NSDictionary * userInfo) {
                        UIImage* outputImage = [userInfo objectForKey:UIImagePickerControllerEditedImage];
                        if (outputImage == nil) {
                            outputImage = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
                        }
                        if (outputImage) {
                            [picker dismissViewControllerAnimated:YES completion:^{
                                RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:outputImage];
                                imageCropVC.delegate = self;
                                if ([BAHelper isIPAD]) {
                                    [imageCropVC setModalPresentationStyle:UIModalPresentationFormSheet];
                                }
                                [self presentViewController:imageCropVC animated:YES completion:^{
                                    
                                }];
                            }];
                        }
                    }];
                    
                    if ([BAHelper isIPAD]) {
                        [imagesPicker setModalPresentationStyle:UIModalPresentationFormSheet];
                    }
                    [self presentViewController:imagesPicker animated:YES completion:^{
                        
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

- (void)changeNameTapped:(UITapGestureRecognizer *)sender {
    if ([self.mainUser.objectId isEqual:[PFUser currentUser].objectId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME message:NSLocalizedString(@"Change your Full Name ?", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *fullNameString = alert.textFields[0].text;
            if (fullNameString.length > 2) {
                [PFUser currentUser][USER_FULLNAME] = fullNameString;
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        if (succeeded) {
                            [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Name changed :)", @"")];
                        }
                    }
                }];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"your name incorrect !!", @"")];
            }
            
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"your full name", @"");
            textField.secureTextEntry = NO;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        });
    }
}
- (IBAction)followButtonTapped:(UIButton *)sender {
    
    if (![self.mainUser.objectId isEqual:[PFUser currentUser].objectId]) {
        PFObject *followClass = [PFObject objectWithClassName:FOLLOW_CLASS_NAME];
        
        // get current user
        PFUser *currentUser = [PFUser currentUser];
        
        if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"Unfollow", @"")]) {
            followClass = followArray[0];
            [followClass deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error == nil) {
                    if (succeeded) {
                        [self.followButton setTitle:NSLocalizedString(@"Follow", @"") forState:UIControlStateNormal];
                        // update
                        [self updateUIAfterTappingFollowButton];
                    }
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
        } else if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"Follow", @"")]) {
            followClass[FOLLOW_A_USER] = currentUser;
            followClass[FOLLOW_IS_FOLLOWING] = self.mainUser;
            
            [followClass saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error == nil) {
                    if (succeeded) {
                        [self.followButton setTitle:NSLocalizedString(@"Unfollow", @"") forState:UIControlStateNormal];
                        
                        // save activity
                        PFObject *activityObject = [PFObject objectWithClassName:ACTIVITY_CLASS_NAME];
                        activityObject[ACTIVITY_CURRENT_USER] = self.mainUser;
                        activityObject[ACTIVITY_TYPE] = @"follow";
                        activityObject[ACTIVITY_OTHER_USER] = currentUser;
                        activityObject[ACTIVITY_TEXT] = [NSString stringWithFormat:NSLocalizedString(@"%@ followed you", @""),currentUser[USER_FULLNAME]];
                        [activityObject saveInBackground];
                        
                        // update
                        [self updateUIAfterTappingFollowButton];
                        
                        // send notification
                        SendPushNotification_activity([NSString stringWithFormat:NSLocalizedString(@"%@ followed you", @""),currentUser[USER_FULLNAME]], self.mainUser);
                        
                        //                    CAPushHelper *pushObject = [CAPushHelper sharedInstance];
                        //                    [pushObject sendNotificationWithAlertString:[NSString stringWithFormat:@"%@ vous a suivi",currentUser[USER_FULLNAME]] andDeviceID:_user[USER_DEVICE_TOKEN] soundID:@"default" badgeNumber:@"+1" ExtraOprions:@{}];
                        
                    }
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
        }
    }
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    [controller dismissViewControllerAnimated:YES completion:^{
        // set user image
        UIImage *picture = [ITHelper ResizeImage:croppedImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
        NSData *imageAvatarData = UIImagePNGRepresentation(picture);
        PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
        
        [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error == nil) {
                if (succeeded) {
                    [PFUser currentUser][USER_AVATAR] = imageAvatarFile;
                    [PFUser currentUser][USER_THUMBNAIL] = imageAvatarFile;
                    
                    // start sign-up thread
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error == nil) {
                            if (succeeded) {
                                [self.userImageView setImage:croppedImage];
                                [ITHelper showSuccessAlert:NSLocalizedString(@"your image changed", @"")];
                            }
                        } else {
                            [ITHelper showErrorMessageFrom:self withError:error];
                        }
                    }];
                }
            }
        }];

    }];
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
