//
//  BAAppEditorViewController.m
//  baytapps
//
//  Created by iMokhles on 31/10/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAAppEditorViewController.h"
#import "BAColorsHelper.h"
#import "DAProgressOverlayView.h"
#import "KNPercentLabel.h"
#import "ITServerHelper.h"
#import "Definations.h"
#import "AppConstant.h"
//#import "UICKeyChainStore.h"
#import "CLImageEditor.h"
#import "JGActionSheet.h"
#import "RSKImageCropViewController.h"
#import "UIImagePickerController+BlocksKit.h"
#import "DGActivityIndicatorView.h"
#import "FISegmentSlider.h"
#import "ArabicConverter.h"
#import "BAAppManagerViewController.h"


@interface BAAppEditorViewController ()<CLImageEditorDelegate, RSKImageCropViewControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    NSString *appleLogoString;
    UIImage *currentImageEdited;
    NSInteger currentDuplicatesNumbers;
    NSString *currentAppSize;
    NSString *oldChar;
    
    NSDictionary *requestedAppInfo;
}
@property (strong, nonatomic) IBOutlet UIImageView *appIconView;
@property (strong, nonatomic) IBOutlet UIImageView *appIconViewNew;
@property (strong, nonatomic) IBOutlet UITextField *appNameField;
@property (strong, nonatomic) IBOutlet UISwitch *logoSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *duplicateSwitch;
@property (strong, nonatomic) IBOutlet UIButton *photoEditorButton;
@property (strong, nonatomic) IBOutlet UIButton *requestAppButton;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;

@property (strong, nonatomic) IBOutlet DGActivityIndicatorView *iconActivityView;

@property (strong, nonatomic) IBOutlet UILabel *originalAppNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *nwAppNameLabel;
@property (strong, nonatomic) IBOutlet FISegmentSlider *duplicatesNumbers;


@end

@implementation BAAppEditorViewController


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
    
    
    
    
    [self.iconActivityView setTintColor:[UIColor whiteColor]];
    [self.iconActivityView setSize:30];
    [self.iconActivityView setType:DGActivityIndicatorAnimationTypeLineScale];
    [self.iconActivityView startAnimating];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
   
    requestedAppInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestedAppInfo"];
    
    PFUser *user = [PFUser currentUser];
    user[@"requested_appIconFile"] = @"";
    user[@"requested_appNameString"] = @"";
    user[@"requested_appInfo"] = @{};
    
    user[@"requested_appDuplicates"] = @"";
    user[@"requested_appSize"] = @"";
    
    requestedAppInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestedAppInfo"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [ITHelper showErrorMessageFrom:self withError:error];
        }
    }];
    

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    appleLogoString = @"";
    
    _appIconView.layer.masksToBounds = YES;
    _appIconView.layer.cornerRadius = 15;
    
    _appIconViewNew.layer.masksToBounds = YES;
    _appIconViewNew.layer.cornerRadius = 20;
    
    _photoEditorButton.layer.masksToBounds = YES;
    _photoEditorButton.layer.cornerRadius = 15;
    
    _requestAppButton.layer.masksToBounds = YES;
    _requestAppButton.layer.cornerRadius = 15;
    
    if (self.appToEdit.appName.length < 12) {
        [_originalAppNameLabel setText:self.appToEdit.appName];
        [_nwAppNameLabel setText:self.appToEdit.appName];
        [_appNameField setText:self.appToEdit.appName];
    } else {
        [_originalAppNameLabel setText:[self.appToEdit.appName substringToIndex:12]];
        [_nwAppNameLabel setText:[self.appToEdit.appName substringToIndex:12]];
        [_appNameField setText:[self.appToEdit.appName substringToIndex:12]];
    }
    
    [_logoSwitch setOn:NO];
    [_duplicateSwitch setOn:NO];
    
    currentDuplicatesNumbers = 0;
    [_duplicatesNumbers setCurrentSelectedIndex:currentDuplicatesNumbers];
    [_duplicatesNumbers setHidden:!_duplicateSwitch.isOn];
    
    
    if (!self.isCydia) {
        
        
        
        if ((![self.appToEdit.appInfo[@"last_parse_itunes"] isKindOfClass:[NSNull class]]) || (![self.appToEdit.appInfo[@"last_parse_itunes"] isEqualToString:@""])) {
            NSData *data = [self.appToEdit.appInfo[@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
            id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *appSize = dict[@"size"];
            currentAppSize = appSize;
            if ([appSize containsString:@"MB"]) {
                NSArray *sizeStringArray =[appSize componentsSeparatedByString:@" MB"];
                NSString *sizeStringValue = [sizeStringArray objectAtIndex:0];
                CGFloat sizeFloat = [sizeStringValue floatValue];
                if (sizeFloat <= 500 && sizeFloat > 400) {
                    [_duplicatesNumbers setTitlesNumbers:2];
                } else if (sizeFloat <= 400 && sizeFloat > 300) {
                    [_duplicatesNumbers setTitlesNumbers:3];
                } else if (sizeFloat <= 300 && sizeFloat > 200) {
                    [_duplicatesNumbers setTitlesNumbers:4];
                } else if (sizeFloat <= 200 && sizeFloat > 100) {
                    [_duplicatesNumbers setTitlesNumbers:5];
                } else if (sizeFloat <= 100) {
                    [_duplicatesNumbers setTitlesNumbers:6];
                } else {
                    [_duplicatesNumbers setTitlesNumbers:1];
                }
            } else if ([appSize containsString:@"GB"]) {
                [_duplicatesNumbers setTitlesNumbers:1];
            } else{
                appSize = @"0";
            }
            [PFUser currentUser][@"requested_appSize"] = appSize;
        } else {
            
            //        [self.appToEdit.appInfo enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop){
            //            // // NSLog(@"key->%@, value-> %@",key,object);
            //        }];
        }
    }else{
        [PFUser currentUser][@"requested_appSize"] = @"0";
        
    }
    [_duplicatesNumbers setValueChangedHandler:^(FISegmentSlider *segment) {
        currentDuplicatesNumbers = segment.currentSelectedIndex;
    }];
    if (currentImageEdited == nil) {
        [_appIconView sd_setImageWithURL:[NSURL URLWithString:self.appToEdit.appIcon] placeholderImage:[UIImage imageNamed:@"AppIcon60x60"]];
        [_appIconViewNew sd_setImageWithURL:[NSURL URLWithString:self.appToEdit.appIcon] placeholderImage:[UIImage imageNamed:@"AppIcon60x60"]];
    } else {
        [_appIconViewNew setImage:currentImageEdited];
    }
    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions
- (IBAction)switchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        if (![_appNameField.text hasPrefix:appleLogoString]) {
            if (_appNameField.text.length < 12) {
                _appNameField.text = [NSString stringWithFormat:@"%@%@", appleLogoString,_appNameField.text];
                oldChar = @"";
            } else {
                [_appNameField.text enumerateSubstringsInRange:NSMakeRange(0, 12)
                                                       options:NSStringEnumerationByComposedCharacterSequences
                                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                        
                                                        NSRange range2 = NSMakeRange(11, 1);
                                                        BOOL equal = NSEqualRanges(enclosingRange, range2);
                                                        if (equal) {
                                                            oldChar = substring;
                                                            *stop = YES;
                                                        }
                                                    }];
                _appNameField.text = [NSString stringWithFormat:@"%@%@", appleLogoString, [_appNameField.text substringToIndex:11]];
            }
        }
    } else {
        if ([_appNameField.text hasPrefix:appleLogoString]) {
            if (_appNameField.text.length < 12) {
                _appNameField.text = [_appNameField.text stringByReplacingOccurrencesOfString:appleLogoString withString:@""];
            } else {
                _appNameField.text = [_appNameField.text stringByReplacingOccurrencesOfString:appleLogoString withString:@""];
                _appNameField.text = [_appNameField.text stringByAppendingString:oldChar];
            }
            
        }
    }
    [_nwAppNameLabel setText:_appNameField.text];
}
- (IBAction)duplicatedChanged:(UISwitch *)sender {
    [_duplicatesNumbers setHidden:!sender.isOn];
    currentDuplicatesNumbers = 0;
    [_duplicatesNumbers setCurrentSelectedIndex:currentDuplicatesNumbers];
}
- (IBAction)editorButtonTapped:(UIButton *)sender {
    [self editImageClicked];
}
- (IBAction)requestAppTapped:(UIButton *)sender {
    
    NSString *correctUUID = [PFUser currentUser][USER_DEVICE_PLAYER_ID];
    //correctUUID = nil;
    if (!correctUUID) {
        [ITHelper showErrorAlert:@"You didn't accept receiving notifications"];
        return;
    }
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:APP_NAME message:NSLocalizedString(@"Verify your settings", @"") buttonTitles:@[NSLocalizedString(@"Confirm download?", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
    
    [section1 setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:0];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [KVNProgress show];
                [ITServerHelper removeAllManagedAppsForUser:[PFUser currentUser]];
                PFFile *appIconFile = [PFFile fileWithName:@"appIconImage.png" data:UIImageJPEGRepresentation(_appIconViewNew.image, 0.5)];
                [appIconFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                        [ITHelper showErrorMessageFrom:self withError:error];
                    } else {
                        if (succeeded) {
                            [PFUser currentUser][@"requested_appIconFile"] = appIconFile.url ;//stringByReplacingOccurrencesOfString:@"net/" withString:@"net:1337/"];
                            [PFUser currentUser][@"requested_appNameString"] = _nwAppNameLabel.text;
                            [PFUser currentUser][@"requested_appInfo"] = self.appToEdit.appInfo;
                            
                            [PFUser currentUser][@"requested_appDuplicates"] = [NSString stringWithFormat:@"%li", (long)currentDuplicatesNumbers+1];
                            //[PFUser currentUser][@"requested_appSize"] = currentAppSize;
                            
                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if (error) {
                                    [KVNProgress showError];
                                    [ITHelper showErrorMessageFrom:self withError:error];
                                } else {
                                    if (succeeded) {
                                        [KVNProgress showSuccessWithCompletion:^{
                                            BAAppManagerViewController *appManager = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"appManagerVC"];
                                            UINavigationController *appManagerNavigationController = [[UINavigationController alloc] initWithRootViewController:appManager];
                                            [appManagerNavigationController setNavigationBarHidden:YES animated:YES];
                                            appManager.appIconLink = [PFUser currentUser][@"requested_appIconFile"];
                                            appManager.dupliNumber = [[PFUser currentUser][@"requested_appDuplicates"] integerValue];
                                            appManager.appNameString = _appNameField.text;
                                            appManager.hostName = [requestedAppInfo objectForKey:@"requestedHost"];
                                            appManager.appVersion = [requestedAppInfo objectForKey:@"requestedVersion"];
                                            appManager.requestedUrlString = [requestedAppInfo objectForKey:@"requestedAppURL"];
                                            appManager.requestedApp = self.appToEdit;
                                            appManager.isCydia = self.isCydia;
                                            
                                            [ITHelper setMainRootViewController:appManagerNavigationController];
                                        }];
                                    }
                                }
                            }];
                        }
                    }
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

#pragma mark - custom methods
- (void)editImageClicked {
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:APP_NAME message:NSLocalizedString(@"Edit/Chage App Icon ?", @"") buttonTitles:@[NSLocalizedString(@"Edit original image", @""), NSLocalizedString(@"Choose from gallery?", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
    
    [section1 setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
    [section1 setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:1];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:self.appIconView.image delegate:self];
                if ([BAHelper isIPAD]) {
                    [editor setModalPresentationStyle:UIModalPresentationFormSheet];
                }
                [self presentViewController:editor animated:YES completion:^{
                    
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
                            imageCropVC.cropMode = RSKImageCropModeSquare;
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
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:croppedImage delegate:self];
        if ([BAHelper isIPAD]) {
            [editor setModalPresentationStyle:UIModalPresentationFormSheet];
        }
        [self presentViewController:editor animated:YES completion:^{
            
        }];
    }];
}


#pragma mark - CLImageEditorDelegate

- (void)imageEditor:(CLImageEditor*)editor didFinishEdittingWithImage:(UIImage*)image {
    [editor dismissViewControllerAnimated:YES completion:^{
        currentImageEdited = image;
        [_appIconViewNew setImage:image];
    }];
}
- (void)imageEditorDidCancel:(CLImageEditor*)editor {
    [editor dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (IBAction)editIconTapped:(UITapGestureRecognizer *)sender {
    [self editImageClicked];
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [_nwAppNameLabel setText:textField.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 12;
}
- (IBAction)closeButtonTapped:(UIButton *)sender {
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:APP_NAME message:NSLocalizedString(@"Cancel?", @"") buttonTitles:@[NSLocalizedString(@"Cancel request?", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"No", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
    
    [section1 setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self dismissViewControllerAnimated:YES completion:^{
                    
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
