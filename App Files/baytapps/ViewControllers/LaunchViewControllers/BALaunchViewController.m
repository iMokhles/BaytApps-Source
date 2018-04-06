//
//  BALaunchViewController.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BALaunchViewController.h"

#import "ITHelper.h"
#import "ITServerHelper.h"
#import "BAHelper.h"
//#import "UICKeyChainStore.h"
#import "JGActionSheet.h"
#import "ITConstants.h"
#import "CACheckConnection.h"
#import "BANoInternetViewController.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

#import "NDIntroView.h"

@interface BALaunchViewController () <NDIntroViewDelegate> {
   // UICKeyChainStore *keyWrapper;
}
@property (strong, nonatomic) IBOutlet UIView *circleView;
@property (strong, nonatomic) IBOutlet UITextField *orderField;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;
@property (strong, nonatomic) IBOutlet UIView *mainCenterView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerViewBottomConstraint;

@property (strong, nonatomic) NDIntroView *introView;

@end

@implementation BALaunchViewController


#pragma mark - NDIntroView methods

-(void)startIntro {
    NSArray *pageContentArray = @[@{kNDIntroPageTitle : @"Edit and Duplicate",
                                    kNDIntroPageDescription : @"Now you can easily edit app name or icon and duplicate it to unlimited copies",
                                    kNDIntroPageImageName : @"parallax"
                                    },
                                  @{kNDIntroPageTitle : @"Timeline and profiles",
                                    kNDIntroPageDescription : @"A great community to share apps between our customers you can see other's customers favorites apps and use them",
                                    kNDIntroPageImageName : @"workitout"
                                    },
                                  @{kNDIntroPageTitle : @"Live Support",
                                    kNDIntroPageDescription : @"A great way to contact our support team directly through the app itself",
                                    kNDIntroPageImageName : @"colorskill"
                                    },
                                  @{kNDIntroPageTitle : @"Tweaked Apps",
                                    kNDIntroPageDescription : @"Apps with jailbreak tweaks without jailbreak also apps aren't available on the AppStore",
                                    kNDIntroPageImageName : @"appreciate"
                                    },
                                  @{kNDIntroPageTitle : @"Settings",
                                    kNDIntroPageDescription : @"We offer new way to customize your app background with a simple images search engine built inside the settings page",
                                    kNDIntroPageImageName : @"appreciate"
                                    },
                                  @{kNDIntroPageTitle : @"Settings",
                                    kNDIntroPageImageName : @"firstImage",
                                    kNDIntroPageTitleLabelHeightConstraintValue : @0,
                                    kNDIntroPageImageHorizontalConstraintValue : @-40
                                    }
                                  ];
    self.introView = [[NDIntroView alloc] initWithFrame:self.view.frame parallaxImage:[UIImage imageNamed:@"main_bg_6"] andData:pageContentArray];
    self.introView.delegate = self;
    [self.view addSubview:self.introView];
}

-(void)launchAppButtonPressed {
    [UIView animateWithDuration:0.7f animations:^{
        self.introView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introView removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isIntroDone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isIntroDone"] boolValue] == NO) {
        [self startIntro];
    }
    
    if ([PFUser currentUser] != nil) {
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error == nil) {
               // [keyWrapper removeAllItems];
//                [ITHelper showLaunchOrMainView:NO];
            } else {
               // [keyWrapper removeAllItems];
//                [ITHelper showLaunchOrMainView:NO];
                [ITHelper showErrorMessageFrom:self withError:error];
            }
        }];
    }
//
//    int ret ;
//    Dl_info dylib_info;
//    int (*func_stat)(const char *, struct stat *) = stat;
//    if ((ret = dladdr(func_stat, &dylib_info))) {
//        // // NSLog(@"lib :%s", dylib_info.dli_fname);
//    }
//    
//    uint32_t count = _dyld_image_count();
//    for (uint32_t i = 0 ; i < count; ++i) {
//        NSString *name = [[NSString alloc]initWithUTF8String:_dyld_get_image_name(i)];
//        if ([[name lowercaseString] containsString:[@"MobileSubstrate/DynamicLibraries/" lowercaseString]]) {
//            // // NSLog(@" [[[ _dyld_get_image_name ]]]--> %@", name);
//        }
//        
//    }
//    
//    char *env = getenv("DYLD_INSERT_LIBRARIES");
//    // // NSLog(@"DYLD_INSERT_LIBRARIES: %s", env);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)verifyButtonTapped:(UIButton *)sender {
    [self.orderField resignFirstResponder];
    [KVNProgress showWithStatus:NSLocalizedString(@"Loading...", @"")];

    if ([[CACheckConnection sharedManager] isUnreachable]) {
//        BANoInternetViewController *launchVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"noConnectionVC"];
//        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//        
//        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionNone
//                        animations:nil
//                        completion:nil];
//        return;
        [KVNProgress showWithStatus:NSLocalizedString(@"No Internet Connection...", @"")];

    }
    
    NSString *orderNumber;
    if ([self.orderField.text containsString:@"#"]) {
        orderNumber = [self.orderField.text stringByReplacingOccurrencesOfString:@"#" withString:@""];
    } else {
        orderNumber = self.orderField.text;
    }
    
    NSInteger orderNUM = [orderNumber integerValue];
    if (orderNUM > 2100) {
#pragma mark - BaytApps Verify
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([orderNumber rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
            if (orderNumber.length > 0) {
                NSString *verifyServer = @"verifyServer";
                //[keyWrapper setString:EncryptText(@"", orderNumber) forKey:@"it_4"];
                
                [[ITHelper sharedInstance] getCustomerOrderWithNumber:orderNumber isTotoaShop:NO withCompletion:^(NSDictionary *dict, NSError *error) {
                    if (error == nil) {
                        [KVNProgress showSuccessWithCompletion:^{
                            NSString *apiURL = [NSString stringWithFormat:@"%@/license/index.php?getprofile=yes&ordernumber=%@&devicetoken=%@&signature=%@&site=%@", kCloudURL, orderNumber, EncryptText(@"", [ITHelper hardwareString]), EncryptText(ENCRYPT_TEXT_KEY(), ENCRYPT_TEXT_KEY()), verifyServer];
                            
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:apiURL]];
                        }];
                    } else {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    }
                }];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Enter your order number", @"")];
            }
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Order number should be (numeric)", @"")];
        }
        
    } else {
        // totoateam
#pragma mark - TotoaTEAM Verify
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([orderNumber rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
            if (orderNumber.length > 0) {
                NSString *verifyServer = @"verifyServer";
               // [keyWrapper setString:EncryptText(@"", orderNumber) forKey:@"it_4"];
                
                [[ITHelper sharedInstance] getCustomerOrderWithNumber:orderNumber isTotoaShop:YES withCompletion:^(NSDictionary *dict, NSError *error) {
                    if (error == nil) {
                        
                        [KVNProgress showSuccessWithCompletion:^{
                            NSString *apiURL = [NSString stringWithFormat:@"%@/license/index.php?getprofile=yes&ordernumber=%@&devicetoken=%@&signature=%@&site=%@", kCloudURL, orderNumber, EncryptText(@"", [ITHelper hardwareString]), EncryptText(ENCRYPT_TEXT_KEY(), ENCRYPT_TEXT_KEY()), verifyServer];
                            
                            //                        // // NSLog(@"**** \n %@", apiURL);
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:apiURL]];
                        }];
                    } else {
                        [KVNProgress showError];
                        [ITHelper showErrorMessageFrom:self withError:error];
                    }
                }];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Enter your order number", @"")];
            }
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Order number should be (numeric)", @"")];
        }
    }
    
    
//    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:NSLocalizedString(@"Verify Device", @"") message:NSLocalizedString(@"Verify your license for", @"") buttonTitles:@[@"BaytApps", @"Totoateam"] buttonStyle:JGActionSheetButtonStyleDefault];
//    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];
//    
//    NSArray *sections = @[section1, cancelSection];
//    
//    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
//    
//    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
//        if (indexPath.section == 0) {
//            if (indexPath.row == 0) {
//                [keyWrapper setString:@"baytapps" forKey:@"verifyServer"];
//                [self verifyBaytApps];
//            } else {
//                [keyWrapper setString:@"totoashop" forKey:@"verifyServer"];
//                [self verifyTotoaShop];
//            }
//            [sheet dismissAnimated:YES];
//        } else {
//            [sheet dismissAnimated:YES];
//        }
//    }];
//    if ([BAHelper isIPAD]) {
//        [sheet showFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0) inView:self.view animated:YES];
//    } else {
//        [sheet showInView:self.view animated:YES];
//    }
}

#pragma mark - verify BaytApps
//- (void)verifyBaytApps {
//    [KVNProgress showWithStatus:NSLocalizedString(@"Loading...", @"")];
//    NSString *orderNumber;
//    if ([self.orderField.text containsString:@"#"]) {
//        orderNumber = [self.orderField.text stringByReplacingOccurrencesOfString:@"#" withString:@""];
//    } else {
//        orderNumber = self.orderField.text;
//    }
//    
//    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
//    if ([orderNumber rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
//        if (orderNumber.length > 0) {
//            NSString *verifyServer = [keyWrapper stringForKey:@"verifyServer"];
//            [keyWrapper setString:EncryptText(@"", orderNumber) forKey:@"it_4"];
//            
//            [[ITHelper sharedInstance] getCustomerOrderWithNumber:orderNumber isTotoaShop:NO withCompletion:^(NSDictionary *dict, NSError *error) {
//                if (error == nil) {
//                    [KVNProgress showSuccessWithCompletion:^{
//                        NSString *apiURL = [NSString stringWithFormat:@"%@/license/index.php?getprofile=yes&ordernumber=%@&devicetoken=%@&signature=%@&site=%@", kCloudURL, orderNumber, EncryptText(@"", [ITHelper hardwareString]), EncryptText(ENCRYPT_TEXT_KEY(), ENCRYPT_TEXT_KEY()), verifyServer];
//                        
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:apiURL]];
//                    }];
//                } else {
//                    [ITHelper showErrorMessageFrom:self withError:error];
//                }
//            }];
//        } else {
//            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Enter your order number", @"")];
//        }
//    } else {
//        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Order number should be (numeric)", @"")];
//    }
//}
//
//- (void)verifyTotoaShop {
//    [KVNProgress showWithStatus:NSLocalizedString(@"Loading...", @"")];
//    NSString *orderNumber;
//    if ([self.orderField.text containsString:@"#"]) {
//        orderNumber = [self.orderField.text stringByReplacingOccurrencesOfString:@"#" withString:@""];
//    } else {
//        orderNumber = self.orderField.text;
//    }
//    
//    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
//    if ([orderNumber rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
//        if (orderNumber.length > 0) {
//            NSString *verifyServer = [keyWrapper stringForKey:@"verifyServer"];
//            [keyWrapper setString:EncryptText(@"", orderNumber) forKey:@"it_4"];
//            
//            [[ITHelper sharedInstance] getCustomerOrderWithNumber:orderNumber isTotoaShop:YES withCompletion:^(NSDictionary *dict, NSError *error) {
//                if (error == nil) {
//                    
//                    [KVNProgress showSuccessWithCompletion:^{
//                        NSString *apiURL = [NSString stringWithFormat:@"%@/license/index.php?getprofile=yes&ordernumber=%@&devicetoken=%@&signature=%@&site=%@", kCloudURL, orderNumber, EncryptText(@"", [ITHelper hardwareString]), EncryptText(ENCRYPT_TEXT_KEY(), ENCRYPT_TEXT_KEY()), verifyServer];
//                        
//                        //                        // // NSLog(@"**** \n %@", apiURL);
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:apiURL]];
//                    }];
//                } else {
//                    [KVNProgress showError];
//                    [ITHelper showErrorMessageFrom:self withError:error];
//                }
//            }];
//        } else {
//            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Enter your order number", @"")];
//        }
//    } else {
//        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Order number should be (numeric)", @"")];
//    }
//}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize keyboardSizeNew = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        _centerViewBottomConstraint.constant = keyboardSizeNew.height;
        [self.view layoutIfNeeded];
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        _centerViewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

@end
