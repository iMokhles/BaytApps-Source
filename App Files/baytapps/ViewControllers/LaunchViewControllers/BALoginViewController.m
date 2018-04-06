//
//  BALoginViewController.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BALoginViewController.h"
#import "BAHelper.h"
#import "Definations.h"
#import "ITServerHelper.h"
#import "ITHelper.h"
//#import "UICKeyChainStore.h"
#import "JGActionSheet.h"
#import "UIImagePickerController+BlocksKit.h"
#import "RSKImageCropper.h"
#import "converter.h"

#import "BAColorsHelper.h"

@interface BALoginViewController () <UITextFieldDelegate> {
    NSString *usernameString;
    NSString *passwordString;
    UIImage *avatarImage;

    //UICKeyChainStore *key;
}
@property (strong, nonatomic) IBOutlet UIView *mainCenterView;

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;


@property (strong, nonatomic) IBOutlet UIView *logoMainView;
@property (strong, nonatomic) IBOutlet UIButton *siginButton;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerViewBottomConstraint;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@end

@implementation BALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* --------- */
    //key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
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
        [_logoMainView setHidden:YES];
        [self.view layoutIfNeeded];
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        _centerViewBottomConstraint.constant = 0;
        [_logoMainView setHidden:NO];
        [self.view layoutIfNeeded];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_USERNAME];
        usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_USERNAME];
        [self.passwordField becomeFirstResponder];
        
    } else if ([textField isEqual:self.passwordField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_PASS_WORD];
        passwordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASS_WORD];
        [self.passwordField resignFirstResponder];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_USERNAME];
        usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_USERNAME];
        [self.passwordField becomeFirstResponder];
        
    } else if ([textField isEqual:self.passwordField]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:USER_PASS_WORD];
        passwordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASS_WORD];
        [self.passwordField resignFirstResponder];
    }
}
#pragma mark - Buttons Actions

- (IBAction)signinTapped:(UIButton *)sender {
    NSString *provisioningPath1 = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath1]) {
        
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error == nil) {
                //[key removeAllItems];
                [ITHelper showLaunchOrMainView:NO];
            } else {
                [ITHelper showErrorMessageFrom:self withError:error];
            }
        }];
        
        return;
    }
    
    NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = provisioningPath1;
        if (!provisioningPath) {
            mobileProvision = @{};
            
            [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                if (error == nil) {
                    //[key removeAllItems];
                    [ITHelper showLaunchOrMainView:NO];
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
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
            [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                if (error == nil) {
                    //[key removeAllItems];
                    [ITHelper showLaunchOrMainView:NO];
                } else {
                    [ITHelper showErrorMessageFrom:self withError:error];
                }
            }];
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
    if (self.passwordField.isFirstResponder) {
        [self textFieldDidEndEditing:self.passwordField];
    }
    
    [ITHelper showHudWithText:@"Logging in" inView:self.view];
    
    
    if (usernameString != nil) {
        
    }else{
        [self error_alert:@"User name or Email Address is required."];
        return;
    }
    if (passwordString != nil) {
        
    }else{
        [self error_alert:@"Order number is required."];

        return;
    }
    
    
    if ([ITHelper validateEmailAddress:[usernameString lowercaseString]]) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:[usernameString lowercaseString] ];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [ITHelper dismissHUD];
            
            if (objects.count > 0) {
                
                PFObject *object = [objects objectAtIndex:0];
                NSString *username = [object objectForKey:@"username"];
                [PFUser logInWithUsernameInBackground:username.lowercaseString password:passwordString block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                    if (!error) {
                        if (user != nil) {
                            
                            if (avatarImage == nil) {
                                [self.avatarImageView setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.avatarImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                                avatarImage = self.avatarImageView.image;
                                
                                UIImage *picture = [ITHelper ResizeImage:avatarImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
                                NSData *imageAvatarData = UIImagePNGRepresentation(picture);
                                PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
                                
                                [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if (error == nil) {
                                        if (succeeded) {
                                            
                                            user[USER_AVATAR] = imageAvatarFile;
                                            user[USER_THUMBNAIL] = imageAvatarFile;
                                            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                if (error == nil) {
                                                    //[user saveInBackground];
                                                    [ITHelper showLaunchOrMainView:YES];
                                                    [ITHelper dismissHUD];
                                                }
                                            }];
                                        }
                                    }
                                }];
                                
                            } else {
                                UIImage *picture = [ITHelper ResizeImage:avatarImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
                                NSData *imageAvatarData = UIImagePNGRepresentation(picture);
                                PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
                                
                                [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if (error == nil) {
                                        if (succeeded) {
                                            
                                            user[USER_AVATAR] = imageAvatarFile;
                                            user[USER_THUMBNAIL] = imageAvatarFile;
                                            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                if (error == nil) {
                                                    //[user saveInBackground];
                                                    [ITHelper showLaunchOrMainView:YES];
                                                    [ITHelper dismissHUD];
                                                }
                                            }];
                                        }
                                    }
                                }];
                            }
                            
                        }
                    }
                    else{
                        [self error_alert:error.localizedDescription];
                        [ITHelper dismissHUD];
                        
                    }
                }];
            }
            
        }];
    } else {
        [PFUser logInWithUsernameInBackground:usernameString.lowercaseString password:passwordString block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                if (user != nil) {
                    
                    if (avatarImage == nil) {
                        [self.avatarImageView setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.avatarImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                        avatarImage = self.avatarImageView.image;
                        
                        UIImage *picture = [ITHelper ResizeImage:avatarImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
                        NSData *imageAvatarData = UIImagePNGRepresentation(picture);
                        PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
                        
                        [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (error == nil) {
                                if (succeeded) {

                                    user[USER_AVATAR] = imageAvatarFile;
                                    user[USER_THUMBNAIL] = imageAvatarFile;
                                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                        if (error == nil) {
                                            //[user saveInBackground];
                                            [ITHelper showLaunchOrMainView:YES];
                                            [ITHelper dismissHUD];
                                        }
                                    }];
                                }
                            }
                        }];
                        
                    } else {
                        UIImage *picture = [ITHelper ResizeImage:avatarImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
                        NSData *imageAvatarData = UIImagePNGRepresentation(picture);
                        PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
                        
                        [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (error == nil) {
                                if (succeeded) {
                                    
                                    user[USER_AVATAR] = imageAvatarFile;
                                    user[USER_THUMBNAIL] = imageAvatarFile;
                                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                        if (error == nil) {
                                            //[user saveInBackground];
                                            [ITHelper showLaunchOrMainView:YES];
                                            [ITHelper dismissHUD];
                                        }
                                    }];
                                }
                            }
                        }];
                    }
                    
                    
                }
            }
            else{
                [self error_alert:error.localizedDescription];
                [ITHelper dismissHUD];
                
            }
            
        }];
    }
    
//    if (avatarImage == nil) {
//
//
//
//        //        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Missing Photo" message:@"Please add the photo." preferredStyle:UIAlertControllerStyleAlert];
//        //        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        //            [self dismissViewControllerAnimated:YES completion:nil];
//        //        }]];
//        //        [self presentViewController:alertController animated:YES completion:nil];
//        //
//        //        return;
//        
//        
//    }else{
//        UIImage *picture = [ITHelper ResizeImage:avatarImage withSize:CGSizeMake(140, 140) andScale:1];//ResizeImage(image, 140, 140, 1);
//        NSData *imageAvatarData = UIImagePNGRepresentation(picture);
//        PFFile *imageAvatarFile = [PFFile fileWithData:imageAvatarData];
//        
//        [imageAvatarFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            if (error == nil) {
//                if (succeeded) {
//                    PFQuery *query = [PFUser query];
//                    [query whereKey:@"email" equalTo:[usernameString lowercaseString]];
//                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//                        [ITHelper dismissHUD];
//                        
//                        if (objects.count > 0) {
//                            
//                            PFObject *object = [objects objectAtIndex:0];
//                            NSString *username = [object objectForKey:@"username"];
//                            [PFUser logInWithUsernameInBackground:username.lowercaseString password:passwordString block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//                                if (!error) {
//                                    if (user != nil) {
//                                        user[USER_AVATAR] = imageAvatarFile;
//                                        user[USER_THUMBNAIL] = imageAvatarFile;
//                                        [user saveInBackground];
//                                        [ITHelper showLaunchOrMainView:YES];
//                                        [ITHelper dismissHUD];
//                                        
//                                    }
//                                }
//                                else{
//                                    [self error_alert:error.localizedDescription];
//                                    [ITHelper dismissHUD];
//                                    
//                                }
//                            }];
//                        }else{
//                            [PFUser logInWithUsernameInBackground:usernameString.lowercaseString password:passwordString block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//                                if (!error) {
//                                    if (user != nil) {
//                                        user[USER_AVATAR] = imageAvatarFile;
//                                        user[USER_THUMBNAIL] = imageAvatarFile;
//                                        [user saveInBackground];
//                                        [ITHelper showLaunchOrMainView:YES];
//                                        [ITHelper dismissHUD];
//                                        
//                                    }
//                                }
//                                else{
//                                    [self error_alert:error.localizedDescription];
//                                    [ITHelper dismissHUD];
//                                    
//                                }
//                                
//                            }];
//                            
//                        }
//                        
//                        
//                    }];
//                    
//                }else{
//                    [ITHelper dismissHUD];
//                    
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"There are somw wrong. please contact provider" preferredStyle:UIAlertControllerStyleAlert];
//                    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                        [self dismissViewControllerAnimated:YES completion:nil];
//                    }]];
//                    [self presentViewController:alertController animated:YES completion:nil];
//                }
//            }else{
//                [ITHelper dismissHUD];
//                
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"There are somw wrong. please contact provider" preferredStyle:UIAlertControllerStyleAlert];
//                [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                }]];
//                [self presentViewController:alertController animated:YES completion:nil];
//            }
//        }];
//        
//    }

}

-(void)error_alert:(NSString*)string{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:string preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
        - (IBAction)signupTapped:(UIButton *)sender {
         
     }
     - (IBAction)forgotPasswordTapped:(UIButton *)sender {
         [self forgetClicked];
     }
     
- (IBAction)addImage:(id)sender {
    
    [self addImageClicked];

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
#pragma mark - custom methods
     
     - (void)forgetClicked {
         [ITServerHelper requestResetPasswordForUser:nil fromTarget:self];
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
