//
//  AppDescriptionViewController.m
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "AppDescriptionViewController.h"
#import "ITAppScreenshotsCell.h"
#import "ITAppScreenshotView.h"
#import "HCSStarRatingView.h"
#import "ITAppDescriptionCell.h"
#import "AppHostersViewController.h"
#import "ITServerHelper.h"
#import "ITHelper.h"
#import "BAColorsHelper.h"
//#import "UICKeyChainStore.h"
#import "BAAppEditorViewController.h"
#import "AppOurHostersViewController.h"

@interface AppDescriptionViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate> {
    NSArray *screenhotsArray;
    ITAppDescrip *currentApp;
    CGFloat infoCellHeight;
    CGFloat descriptionCellHeight;
    
    BOOL isAlreadyLiked;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (strong, nonatomic) IBOutlet UILabel *appNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *appArtistLabel;
@property (strong, nonatomic) IBOutlet UILabel *appAdviRatingLabel;
@property (strong, nonatomic) IBOutlet UIView *appWatchView;
@property (strong, nonatomic) IBOutlet UIImageView *watchIconView;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;
@property (strong, nonatomic) IBOutlet HCSStarRatingView *startsView;
@property (strong, nonatomic) IBOutlet PKBorderedButton *downloadButton;
- (IBAction)downloadButtonTapped:(PKBorderedButton *)sender;
@property (strong, nonatomic) IBOutlet PKBorderedButton *favoriteButton;
- (IBAction)favoriteButton:(PKBorderedButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *topBackBtn;
@property (strong, nonatomic) IBOutlet UIButton *topRightButton;
@property (strong, nonatomic) IBOutlet UIImageView *topTitleImageView;
- (IBAction)backBtnTapped:(id)sender;
- (IBAction)topRightTapped:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation AppDescriptionViewController

- (void)configureAppHeaderInfoFromApp:(ITAppDescrip *)app {

    [_downloadButton configureDefaultAppearance];
    [_favoriteButton configureDefaultAppearance];
    
    _startsView.value = app.averageUserRating;
    _startsView.tintColor = [UIColor orangeColor];
    
    [_appWatchView setHidden:YES];
    
    _appAdviRatingLabel.backgroundColor = [UIColor clearColor];
    _appAdviRatingLabel.layer.masksToBounds = YES;
    _appAdviRatingLabel.layer.cornerRadius = 0;
    _appAdviRatingLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _appAdviRatingLabel.layer.borderWidth = 0.5;
    
    self.title = app.appName;
    
    _appAdviRatingLabel.text = app.advisoryRating;
    _appNameLabel.text = app.appName;
    _appArtistLabel.text = app.artistName;
    [_artworkImageView sd_setImageWithURL:[NSURL URLWithString:app.artwork512URL] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
    
    
    CALayer *roundCorner = [_artworkImageView layer];
    [roundCorner setMasksToBounds:YES];
    [roundCorner setCornerRadius:18.0];
    roundCorner.borderColor = [UIColor lightGrayColor].CGColor;
    roundCorner.borderWidth = 0.5;
    
}

- (void)configureAppHeaderInfoFromCydiaApp:(ITAppObject *)app {
    
    [_downloadButton configureDefaultAppearance];
    [_favoriteButton configureDefaultAppearance];
    
    [_startsView setHidden:YES];
    
    [_appWatchView setHidden:YES];
    
    _appAdviRatingLabel.backgroundColor = [UIColor clearColor];
    _appAdviRatingLabel.layer.masksToBounds = YES;
    _appAdviRatingLabel.layer.cornerRadius = 0;
    _appAdviRatingLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _appAdviRatingLabel.layer.borderWidth = 0.5;
    
    self.title = app.appName;
    
    if (self.isCydiaApp) {
        _appAdviRatingLabel.text = @"";
        _appNameLabel.text = app.appInfo[@"name"];
        _appArtistLabel.text = app.appInfo[@"pname"];
        [_artworkImageView sd_setImageWithURL:[NSURL URLWithString:app.appInfo[@"image"]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
    }
    
    
    CALayer *roundCorner = [_artworkImageView layer];
    [roundCorner setMasksToBounds:YES];
    [roundCorner setCornerRadius:18.0];
    roundCorner.borderColor = [UIColor lightGrayColor].CGColor;
    roundCorner.borderWidth = 0.5;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
    
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
    
    
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    //    UIImage *imageLike = [[UIImage imageNamed:@"likeIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [_topRightButton setImage:imageLike forState:UIControlStateNormal];
    //    [_topRightButton setTintColor:[BAColorsHelper ba_whiteColor]];
    //
    //    UIImage *imageLiked = [[UIImage imageNamed:@"HeartIconSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [_topRightButton setImage:imageLiked forState:UIControlStateHighlighted];
    //
    //    UIImage *imageHome = [[UIImage imageNamed:@"info_alt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [_topTitleImageView setImage:imageHome];
    //    [_topTitleImageView setTintColor:[UIColor hex:GRN_COLOR]];
    //
    //    UIImage *imageMenu = [[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [_topBackBtn setImage:imageMenu forState:UIControlStateNormal];
    //    [_topBackBtn setTintColor:[UIColor hex:GRN_COLOR]];
    
    if (self.isCydiaApp) {
        if (![self.object.appInfo[@"screenshots"] isKindOfClass:[NSNull class]]) {
            NSData *screnShotsData = [self.object.appInfo[@"screenshots"] dataUsingEncoding:NSUTF8StringEncoding];
            if (screnShotsData ) {
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:screnShotsData
                                                                           options:0 error:NULL];
                NSDictionary *screenshots = jsonObject;
                NSArray *iphoneShots = screenshots[@"iphone"];
                NSMutableArray *latestArray = [NSMutableArray new];
                for (NSDictionary *url in iphoneShots) {
                    ITAppScreenshotView *item = [[ITAppScreenshotView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:url[@"src"]] andCydiaApp:self.object];
                    [latestArray addObject:item];
                }
                
                [self configureAppHeaderInfoFromCydiaApp:self.object];
                screenhotsArray = [latestArray copy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                });
            }
        } else {
            [self configureAppHeaderInfoFromCydiaApp:self.object];
            screenhotsArray = [NSArray new];
            [self.mainTableView reloadData];
        }
        
        
        
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[ITHelper sharedInstance] getAppInfoFromItunes:self.object.appInfo[@"id"] withCompletion:^(NSArray *allApps, NSError *error) {
                NSMutableArray *latestArray = [NSMutableArray new];
                if (allApps.count > 0) {
                    currentApp = allApps[0];
                    for (ITAppDescrip *app in allApps) {
                        NSArray *screenshots = app.screenshotUrls;
                        for (NSString *url in screenshots) {
                            ITAppScreenshotView *item = [[ITAppScreenshotView alloc] initWithFrame:CGRectZero image:[NSURL URLWithString:url] andApp:app];
                            [latestArray addObject:item];
                        }
                        
                        [self configureAppHeaderInfoFromApp:app];
                    }
                    screenhotsArray = [latestArray copy];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    });
                }
            }];
        });
        
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            isAlreadyLiked = NO;
            [self.topRightButton setImage:[UIImage imageNamed:@"Like_not_filled2"] forState:UIControlStateNormal];
        });
        // NSLog(@"******** %@", self.object.appID);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [ITServerHelper isAppSharedByCurrentUser:self.object.appID withBlock:^(BOOL succeeded) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isAlreadyLiked = YES;
                        [self.topRightButton setImage:[UIImage imageNamed:@"Like_filled"] forState:UIControlStateNormal];
                    });
                }
            }];
            
        });
    });
    
    
    self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mainTableView.frame.size.width, 1)];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mainTableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ITAppScreenshotsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ITAppScreenshotsCell"];
        [cell configureWithItems:screenhotsArray];
        [cell setScreenShotTappedBlock:^(ITAppScreenshotsCell *currentCell, ITAppScreenshotView *currentScreenShot) {
            [EXPhotoViewer showImageFrom:currentScreenShot.currentImageView];
        }];
        return cell;
    } if (indexPath.section == 1) {
        ITAppDescriptionCell *cellDescription = [tableView dequeueReusableCellWithIdentifier:@"ITAppDescriptionCell"];
        cellDescription.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cellDescription.clipsToBounds = YES;
        cellDescription.isMoreButton = YES;
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", currentApp.descriptionString] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        if (self.isCydiaApp) {
            
            NSString *descLog = [NSString stringWithFormat:
                                 @"<html><body>"
                                 @"<font size=\"4\" face=\"arial\" color=\"white\">%@</font><br>"
                                 , [NSString stringWithFormat:@"%@", self.object.appInfo[@"description"]]
                                 ];
            
            attString = [[[NSAttributedString alloc] initWithData:[descLog dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSForegroundColorAttributeName: [UIColor whiteColor] } documentAttributes:nil error:nil] mutableCopy];
        }
        [cellDescription configureWithAppDescription:attString andTitle:NSLocalizedString(@"Description", @"")];
        [cellDescription setMoreButtonTappedBlock:^(ITAppDescriptionCell *cell, UIButton *button) {
            
            if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"more", @"")]) {
                [cell.appDescriptionLabel setScrollEnabled:NO];
                [button setTitle:NSLocalizedString(@"less", @"") forState:UIControlStateNormal];
                CGFloat desciptionHeight = [ITHelper getHeightForTextView:cell.appDescriptionLabel];
                CGFloat titleDescription = 39;
                descriptionCellHeight = desciptionHeight+titleDescription;
                [self.mainTableView reloadData];
            } else {
                [cell.appDescriptionLabel setScrollEnabled:YES];
                [button setTitle:NSLocalizedString(@"more", @"") forState:UIControlStateNormal];
                descriptionCellHeight = 0;
                [self.mainTableView reloadData];
            }
        }];
        return cellDescription;
    } else if (indexPath.section == 2) {
        ITAppDescriptionCell *cellDescription = [tableView dequeueReusableCellWithIdentifier:@"ITAppDescriptionCell"];
        cellDescription.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cellDescription.clipsToBounds = YES;
        cellDescription.isMoreButton = YES;
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", currentApp.changelogString] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        if (self.isCydiaApp) {
//            attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.object.appInfo[@"whatsnew"]]];
            
            NSString *chngLog = [NSString stringWithFormat:
             @"<html><body>"
             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong></strong></font><font size=\"3\" face=\"arial\" color=\"white\">%@</font><br>"
            , [NSString stringWithFormat:@"%@", self.object.appInfo[@"whatsnew"]]
             ];
            attString = [[[NSAttributedString alloc] initWithData:[chngLog dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSForegroundColorAttributeName: [UIColor whiteColor] } documentAttributes:nil error:nil] mutableCopy];

        }
        [cellDescription configureWithAppDescription:attString andTitle:[NSString stringWithFormat:NSLocalizedString(@"Whats's New in Version %@", @""), self.object.appInfo[@"version"]]];
        [cellDescription setMoreButtonTappedBlock:^(ITAppDescriptionCell *cell, UIButton *button) {
            
            if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"more", @"")]) {
                [cell.appDescriptionLabel setScrollEnabled:NO];
                [button setTitle:NSLocalizedString(@"less", @"") forState:UIControlStateNormal];
                CGFloat desciptionHeight = [ITHelper heightForText:cell.appDescriptionLabel.text];
                CGFloat titleDescription = 39;
                infoCellHeight = desciptionHeight+titleDescription;
//                // // NSLog(@"******* %f", infoCellHeight);
                [self.mainTableView reloadData];
            } else {
                [cell.appDescriptionLabel setScrollEnabled:YES];
                [button setTitle:NSLocalizedString(@"more", @"") forState:UIControlStateNormal];
                infoCellHeight = 0;
                [self.mainTableView reloadData];
            }
        }];
        return cellDescription;
    } else {
        ITAppDescriptionCell *cellDescription = [tableView dequeueReusableCellWithIdentifier:@"ITAppDescriptionCell"];
        cellDescription.isMoreButton = NO;
        cellDescription.isInformation = YES;

        if (self.isCydiaApp) {
            
            [self.downloadButton setTitle:@"Free" forState:UIControlStateNormal];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cellDescription configureWithTweakedAppDescription:@"Tweaked App" andTitle:[NSString stringWithFormat:NSLocalizedString(@"Information", @"")]];
            });
            
            return cellDescription;
        } else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *str = currentApp.appInfo[@"currentVersionReleaseDate"];
                // 2013-08-14T07:00:00Z
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
                [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];// this string must match given string @"2015-05-08T09:44:25.343"
                
                NSDate *date = [dateFormat dateFromString:str];
                
                [dateFormat setDateFormat:@"dd MMM, yyyy"];// this match the one you want to be
                NSString *dateString = [dateFormat stringFromDate:date];
                
                NSString *appPrice = NSLocalizedString(@"Download", @"");
                NSString *appSize = @"";
                NSString *supportedDevices = currentApp.devicesSupported;
                NSString *supportAppleWatch = @"No";
                if (![self.object.appInfo[@"last_parse_itunes"] isKindOfClass:[NSNull class]]) {
                    NSData *data = [self.object.appInfo[@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
                    id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    appPrice = dict[@"price"];
                    appSize = dict[@"size"];
                    supportedDevices = dict[@"requirements"];
                    if ([dict[@"apple_watch"] intValue] == 1) {
                        supportAppleWatch = @"Yes";
                    }
                } else {
                    supportedDevices = currentApp.devicesSupported;
                    supportAppleWatch = @"No";
                }
                
                [self.downloadButton setTitle:appPrice forState:UIControlStateNormal];
                NSString *fullInformation = [NSString stringWithFormat:
                                             @"<html><body>"
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Developer</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Category</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Price</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Updated</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Version</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Size</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Rating</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">Rated %@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Compatibility</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Apple Watch</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             
                                             @"<font size=\"2\" face=\"arial\" color=\"white\"><strong>Languages</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"1\" face=\"arial\" color=\"white\">%@</font><br>"
                                             @"</body></html>"
                                             
                                             , currentApp.developerName
                                             , currentApp.primaryGenreName
                                             , appPrice
                                             , dateString
                                             , currentApp.appVersion
                                             , appSize
                                             , currentApp.advisoryRating
                                             , supportedDevices
                                             , supportAppleWatch
                                             , currentApp.languagesSupported];
                
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[fullInformation dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSForegroundColorAttributeName: [UIColor whiteColor] } documentAttributes:nil error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cellDescription configureWithAppDescription:attrStr andTitle:[NSString stringWithFormat:NSLocalizedString(@"Information", @"")]];
                });
                
            });
            
            return cellDescription;
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (descriptionCellHeight < 0) {
            return 248;
        } else if (descriptionCellHeight == 0) {
            return 248;
        } else {
            return descriptionCellHeight + 30;
        }
//        if (descriptionCellHeight <= 100){
//            return descriptionCellHeight+80;
//        } else if (descriptionCellHeight < 150) {
//            return descriptionCellHeight+75;
//        } else if (descriptionCellHeight > 800) {
//            return descriptionCellHeight-275;
//        }
    } else if (indexPath.section == 2) {
        if (infoCellHeight < 0) {
            return 100;
        } else if (infoCellHeight == 0) {
            return 100;
        } else if (infoCellHeight <= 100){
            return infoCellHeight+80;
        } else if (descriptionCellHeight < 150) {
            return descriptionCellHeight+218;
        } else if (infoCellHeight < 250) {
            return infoCellHeight-75;
        } else if (infoCellHeight > 800) {
            return infoCellHeight-375;
        }
        
    }
    return 245;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (IBAction)downloadButtonTapped:(PKBorderedButton *)sender {
    AppHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_Hoster_Page_ID];
    appHosters.app = self.object;
    appHosters.sectionName = @"ios";
    if (self.isCydiaApp) {
        AppOurHostersViewController *appHosters = [self.storyboard instantiateViewControllerWithIdentifier:App_OurHoster_Page_ID];
        appHosters.sectionName = @"cydia";
        appHosters.isCydia = self.isCydiaApp;
        appHosters.app = self.object;

        [self.navigationController pushViewController:appHosters animated:YES];
//        [[NSUserDefaults standardUserDefaults] setObject:@{@"requestedAppURL":self.object.locallink, @"requestedVersion":self.object.appVersion                                                           , @"requestedHost": @"macSERVER"} forKey:@"requestedAppInfo"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        

//        BAAppEditorViewController *appEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"appEditor"];
//        appEditor.appToEdit = self.object;
//        appEditor.isCydia = YES;
//        [appEditor setRequestCellBlock:^(BAAppEditorViewController *editor, NSString *icon, NSString *appNameSr, NSString *duplicates) {
//            
//        }];
        
        //[self.navigationController presentViewController:appHosters animated:YES completion:^{}];
        
        return;
        
    }
    
    [self.navigationController pushViewController:appHosters animated:YES];
}
- (IBAction)favoriteButton:(PKBorderedButton *)sender {
    
    PFObject *alertsClass = [PFObject objectWithClassName:APP_CLASSE_NAME];
    PFUser *currentUser = [PFUser currentUser];
    
    [ITServerHelper getAllPostsForUser:currentUser limit:nil skip:nil withBlock:^(BOOL succeeded, NSArray *objects) {
        if (succeeded) {
            if (objects.count > 0) {
                BOOL isAlreadyExiste = NO;
                for (int i = 0; i < objects.count; i++) {
                    PFObject *object = [objects objectAtIndex:i];
                    if (i == [objects count]-1) {
                        if (!isAlreadyExiste) {
                            if (![object[APP_ID] isEqualToString:self.object.appID]) {
                                alertsClass[APP_USER_POINTER] = currentUser;
                                alertsClass[APP_URL_LOWERCASE] = @"";
                                alertsClass[APP_ICON] = [NSString stringWithFormat:@"%@", self.object.appIcon];
                                alertsClass[APP_ID] = [NSString stringWithFormat:@"%@", self.object.appID];
                                alertsClass[APP_TRACK_ID] = [NSString stringWithFormat:@"%@", self.object.appTrackID];
                                alertsClass[APP_NAME_STRING] =  [NSString stringWithFormat:@"%@", self.object.appName];
//                                alertsClass[APP_VERSION] = [NSString stringWithFormat:@"%@", self.object.appVersion];
                                alertsClass[APP_INFO_DICT] = self.object.appInfo;
                                alertsClass[APP_DATE] = [NSDate date];
                                
                                PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
                                [acl setPublicReadAccess:YES];
                                [alertsClass setACL:acl];
                                
                                [alertsClass saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if (error == nil) {
                                        [self.topRightButton setImage:[UIImage imageNamed:@"Like_filled"] forState:UIControlStateNormal];
                                    } else {
                                        [ITHelper showAlertViewForExtFromViewController:self WithTitle:APP_NAME msg:error.localizedDescription];
                                    }
                                }];
                            } else {
                                [ITHelper showAlertViewForExtFromViewController:self WithTitle:APP_NAME msg:NSLocalizedString(@"You shared this app already", @"")];
                            }
                            
                        } else {
                            [ITHelper showAlertViewForExtFromViewController:self WithTitle:APP_NAME msg:NSLocalizedString(@"You shared this app already", @"")];
                        }
                    }
                    if ([[object[APP_ID] lowercaseString] isEqualToString:[self.object.appID lowercaseString]]) {
                        isAlreadyExiste = YES;
                    }
                }
            } else {
//                // // NSLog(@"******** \n\n\n %@", [NSString stringWithFormat:@"%@", self.object.appVersion]);
                alertsClass[APP_USER_POINTER] = currentUser;
                alertsClass[APP_URL_LOWERCASE] = @"";
                alertsClass[APP_ICON] = [NSString stringWithFormat:@"%@", self.object.appIcon];
                alertsClass[APP_ID] = [NSString stringWithFormat:@"%@", self.object.appID];
                alertsClass[APP_TRACK_ID] = [NSString stringWithFormat:@"%@", self.object.appTrackID];
                alertsClass[APP_NAME_STRING] =  [NSString stringWithFormat:@"%@", self.object.appName];
//                alertsClass[APP_VERSION] = [NSString stringWithFormat:@"%@", self.object.appVersion];
                alertsClass[APP_INFO_DICT] = self.object.appInfo;
                alertsClass[APP_DATE] = [NSDate date];
                PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
                [acl setPublicReadAccess:YES];
                [alertsClass setACL:acl];
                
                [alertsClass saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error == nil) {
                        [self.topRightButton setImage:[UIImage imageNamed:@"Like_filled"] forState:UIControlStateNormal];
                    } else {
                        [ITHelper showAlertViewForExtFromViewController:self WithTitle:APP_NAME msg:error.localizedDescription];
                    }
                }];
            }
            
        }
    }];
}

- (IBAction)backBtnTapped:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)topRightTapped:(UIButton *)sender {
    if (isAlreadyLiked) {
        return;
    }
    [self.topRightButton setImage:[UIImage imageNamed:@"Like_filled"] forState:UIControlStateNormal];
    [self favoriteButton:nil];
}
@end
