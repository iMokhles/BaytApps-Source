//
//  BASignupViewController.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BASignupViewController.h"
#import "BAHelper.h"
#import "Definations.h"
#import "ITServerHelper.h"
#import "ITHelper.h"
//#import "UICKeyChainStore.h"

#import "JGActionSheet.h"
#import "UIImagePickerController+BlocksKit.h"
#import "RSKImageCropper.h"
#import "converter.h"

@interface BASignupViewController () <RSKImageCropViewControllerDelegate> {
    NSString *fullnameString;
    NSString *usernameString;
    NSString *emailString;
    NSString *passwordString;
    NSString *confirmPasswordString;
    UIImage *avatarImage;
    
    //UICKeyChainStore *keyWrapper;
}
@property (strong, nonatomic) IBOutlet UIView *mainCenterView;
@property (strong, nonatomic) IBOutlet UIView *logoMainView;

@property (strong, nonatomic) IBOutlet UITextField *fullnameField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordField;

@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerViewBottomConstraint;
@property (strong, nonatomic) IBOutlet UILabel *accountNewLabel;

@end

@implementation BASignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize keyboardSizeNew = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        _centerViewBottomConstraint.constant = keyboardSizeNew.height;
        [_accountNewLabel setHidden:YES];
        [_logoMainView setHidden:YES];
        [self.view layoutIfNeeded];
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        _centerViewBottomConstraint.constant = 0;
        [_accountNewLabel setHidden:NO];
        [_logoMainView setHidden:NO];
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupTapped:(UIButton *)sender {
    [self signUpClicked];
}

- (IBAction)signinTapped:(UIButton *)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)imageButtonTapped:(UIButton *)sender {
    [self addImageClicked];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.fullnameField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_FULLNAME];
        fullnameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FULLNAME];
        [self.usernameField becomeFirstResponder];
        
    } else if ([textField isEqual:self.usernameField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_USERNAME];
        usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_USERNAME];
        [self.emailField becomeFirstResponder];
    } else if ([textField isEqual:self.emailField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_EMAIL];
        emailString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_EMAIL];
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_PASS_WORD];
        passwordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASS_WORD];
        [self.confirmPasswordField becomeFirstResponder];
    } else if ([textField isEqual:self.confirmPasswordField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_CONF_PASS_WORD];
        confirmPasswordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONF_PASS_WORD];
        [self.confirmPasswordField resignFirstResponder];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.fullnameField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_FULLNAME];
        fullnameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FULLNAME];
        [self.usernameField becomeFirstResponder];
        
    } else if ([textField isEqual:self.usernameField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_USERNAME];
        usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_USERNAME];
        [self.emailField becomeFirstResponder];
    } else if ([textField isEqual:self.emailField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_EMAIL];
        emailString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_EMAIL];
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_PASS_WORD];
        passwordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASS_WORD];
        [self.confirmPasswordField becomeFirstResponder];
    } else if ([textField isEqual:self.confirmPasswordField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_CONF_PASS_WORD];
        confirmPasswordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONF_PASS_WORD];
        [self.confirmPasswordField resignFirstResponder];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - custom methods

- (void)signUpClicked {
    
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
        if (!ok) { // // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // // NSLog(@"error parsing extracted plist — %@",error);
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
    accountType = @"other";
    if (teamID2.length > 0) {
        if ([teamID2 isEqualToString:@"USM32L424X"]) accountType = @"ipa";
        if ([teamID2 isEqualToString:@"2R5JB2FB9E"]) accountType = @"ipa1";
        if ([teamID2 isEqualToString:@"J6D5BK3T6D"]) accountType = @"ipa2";
    } else {
        accountType = @"other";
    }
    
    if (self.confirmPasswordField.isFirstResponder) {
        [self textFieldDidEndEditing:self.confirmPasswordField];
    }
    if (fullnameString.length > 0 && usernameString.length > 0 && emailString.length > 0 && passwordString.length > 0 && confirmPasswordString.length > 0) {
        
        if ([ITHelper validateEmailAddress:emailString] && [confirmPasswordString isEqualToString:passwordString]) {
            if (passwordString.length < 5){
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"password should be over 5 chars", @"")];
                return;
            }
            
            
            if (usernameString.length >= 5) {
               
                
                NSString *passAUTH = @"it_1";
                NSString *passUDID = @"it_3";
                NSString *orderID  =@"it_4";
                
                NSString *orderDateString =  @"it_67";
                NSDate *createdAtDate = Strings2Date(orderDateString);
                // created date after 1 year
                NSDate *dateAfterYear = [createdAtDate dateByAddingYears:1];
                NSString *dateAfterYearString = Date2Strings(dateAfterYear);
                passUDID = @"passUDID";
                passAUTH = @"passAUTH";
                orderID = @"orderID";
                dateAfterYearString = Date2Strings([NSDate date]);
                if (passUDID.length > 5) {
                }
                if(YES){
                     [ITHelper showHudWithText:NSLocalizedString(@"Creating account..", @"") inView:self.view];
                    [ITServerHelper isThisUserExiste:passUDID withBlock:^(BOOL succeeded, NSArray *objects) {
                        //f (objects.count > 0) {
                        if (NO) {
                            if (succeeded) {
                                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Failed to process your request :(", @"")];
                            }
                        } else {
                            PFUser *newUser = [[PFUser alloc] init];
                            
                            if (![usernameString.lowercaseString containsString:@"support"] || ![fullnameString.lowercaseString containsString:@"support"]) {
                                // set user fullname
                                newUser[USER_FULLNAME] = fullnameString;
                                newUser[USER_FULLNAMELOWER] = [fullnameString lowercaseString];
                                newUser[USER_FULLNAME] = fullnameString;
                              
                                // set user username
                                newUser.username = usernameString.lowercaseString;
                            } else {
                                
                                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Failed to create account with this name", @"")];
                                return;
                            }
                            
                            
                            // set user email
                            newUser.email = emailString.lowercaseString;
                            
                            // set user password
                            newUser.password = passwordString;
                            
                            // set user udid
                            newUser[USER_DEVICE_ID] = passUDID;
                            
                            // set user device type
                            newUser[USER_DEVICE_TYPE] = passAUTH;
                            
                            // set user device type
                            newUser[USER_TEAM_ID] = accountType;
                            
                            // set user end date
                            newUser[USER_EXPIRY_DATE] = dateAfterYearString;
                            
                            newUser[USER_ALREADY_LOGGED] = @"YES";
                            
                            newUser[@"inUse"] = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]];
                            
                            newUser[USER_APP_VERSION] = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
                            // set user device push token
                            if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_TOKEN] && [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_PLAYER_ID]) {
                                newUser[USER_DEVICE_TOKEN] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_TOKEN]];
                                newUser[USER_DEVICE_PLAYER_ID] = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_PLAYER_ID]];
                            }
                            
                            if (avatarImage == nil) {
                                
                            }
                            // set user image
                            UIImage *picture = [ITHelper ResizeImage:avatarImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
                            NSData *imageAvatarData = UIImagePNGRepresentation(picture);
                            PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
                            
                            [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if (error == nil) {
                                    if (succeeded) {

                                        newUser[USER_AVATAR] = imageAvatarFile;
                                        newUser[USER_THUMBNAIL] = imageAvatarFile;
                                        
                                        // start sign-up thread
                                        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                            if (error == nil) {
                                                if (succeeded) {
                                                    
                                                    PFQuery *orderQuery = [PFQuery queryWithClassName:USER_ORDER_CLASS_NAME];
//                                                    [orderQuery whereKey:USER_ORDER_DEVICE equalTo:passAUTH];
//                                                    [orderQuery whereKey:USER_ORDER_UDID equalTo:passUDID];
//                                                    [orderQuery whereKey:USER_ORDER_EMAIL equalTo:emailString.lowercaseString];
//                                                    [orderQuery whereKey:USER_ORDER_DATE equalTo:dateAfterYearString];
                                                    [orderQuery whereKey:USER_ORDER_USER equalTo:[PFUser currentUser]];
                                                    [orderQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                                        if (error == nil) {
                                                            if (objects.count == 0) {
                                                                PFObject *orderObject = [PFObject objectWithClassName:USER_ORDER_CLASS_NAME];
                                                                orderObject[USER_ORDER_DATE] = dateAfterYearString;
                                                                orderObject[USER_ORDER_UDID] = passUDID;
                                                                orderObject[USER_ORDER_EMAIL] = emailString.lowercaseString;
                                                                orderObject[USER_ORDER_USER] = [PFUser currentUser];
                                                                orderObject[USER_ORDER_DEVICE] = passAUTH;
                                                                orderObject[USER_ORDER_STATUS] = @"YES";
                                                                orderObject[USER_ORDER_ID] = orderID;
                                                                PFACL *orderACL = [PFACL ACLWithUser:[PFUser currentUser]];
                                                                [orderACL setPublicReadAccess:NO];
                                                                [orderACL setPublicWriteAccess:NO];
                                                                [orderObject setACL:orderACL];
                                                                
                                                                [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                                    if (error == nil) {
                                                                        if (succeeded) {
                                                                          //  [keyWrapper setString:EncryptText(@"", usernameString) forKey:@"username"];
//                                                                            [keyWrapper setString:EncryptText(@"", passwordString) forKey:ENCRYPT_TEXT_KEY()];
                                                                            
                                                                            // if user sign-up finished without errors start using app
                                                                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_USERNAME];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_FULLNAME];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_EMAIL];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PASS_WORD];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_CONF_PASS_WORD];
                                                                            [ITHelper showLaunchOrMainView:YES];
                                                                            [ITHelper dismissHUD];
                                                                        }
                                                                    } else {
                                                                        [ITHelper dismissHUD];
                                                                        // hide hud and apprear message if there are error
                                                                        [ITHelper showErrorMessageFrom:self withError:error];
                                                                    }
                                                                }];
                                                            } else {
                                                                PFObject *orderObject = [objects objectAtIndex:0];
                                                                if ([orderObject[USER_ORDER_STATUS] isEqualToString:@"YES"]) {
                                                                    orderObject[USER_ORDER_ID] = orderID;
                                                                    [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                                        if (error == nil) {
                                                                            [ITHelper showLaunchOrMainView:YES];
                                                                            [ITHelper dismissHUD];
                                                                        }
                                                                    }];
                                                                } else {
                                                                    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                                                                        if (error == nil) {
                                                                            [ITHelper dismissHUD];
                                                                            UIViewController *fuckedVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"fuckedVC"];
                                                                            [UIApplication sharedApplication].delegate.window.rootViewController = fuckedVC;
                                                                            
                                                                            [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                                                                                              duration:0.3
                                                                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                                                                            animations:nil
                                                                                            completion:nil];
                                                                        } else {
                                                                            [ITHelper dismissHUD];
                                                                            // hide hud and apprear message if there are error
                                                                            [ITHelper showErrorMessageFrom:self withError:error];
                                                                        }
                                                                    }];
                                                                }
                                                            }
                                                        } else {
                                                            [ITHelper dismissHUD];
                                                            // hide hud and apprear message if there are error
                                                            [ITHelper showErrorMessageFrom:self withError:error];
                                                        }
                                                    }];
                                                }
                                            } else {
                                                [ITHelper dismissHUD];
                                                // hide hud and apprear message if there are error
                                                [ITHelper showErrorMessageFrom:self withError:error];
                                            }
                                        }];
                                    }
                                }
                            }];
                        }
                    }];
                }
                
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"username should be over 5 chars", @"")];
            }
            
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"email or password is incorrect", @"")];
        }
        
    } else {
        [KVNProgress showErrorWithStatus:NSLocalizedString(@"forget something !", @"")];
    }
}

- (void)addImageClicked {
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

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    [controller dismissViewControllerAnimated:YES completion:^{
        avatarImage = croppedImage;
        [self.avatarImageView setImage:avatarImage];
        [self.imageButton setImage:[UIImage new] forState:UIControlStateNormal];
    }];
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
