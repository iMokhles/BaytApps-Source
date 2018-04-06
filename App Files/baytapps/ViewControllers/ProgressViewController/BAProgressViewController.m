//
//  BAProgressViewController.m
//  baytapps
//
//  Created by iMokhles on 29/10/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAProgressViewController.h"
#import "BAHelper.h"
#import "ITHelper.h"
#import "BAColorsHelper.h"
#import "DAProgressOverlayView.h"
#import "KNPercentLabel.h"
#import "ITServerHelper.h"
#import "Definations.h"
#import "AppConstant.h"
//#import "UICKeyChainStore.h"


@interface BAProgressViewController () {
    //UICKeyChainStore *key;
    BOOL isDuplicates;
}
@property (strong, nonatomic) IBOutlet UILabel *appNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet DAProgressOverlayView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;

@property (nonatomic, strong) ITAppObject *currentApp;
@property (strong, nonatomic) IBOutlet UIImageView *appIconView;
@end

@implementation BAProgressViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
    
    if ([PFUser currentUser] == nil) {
        return;
    }
    
    NSString *getIT_String = [PFUser currentUser][USER_DEVICE_ID];
    if ([getIT_String isEqualToString:@""] || getIT_String.length == 0 || !getIT_String) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMethod:) name:NOTIFICATION_TO_DOWNLOAD_APP object:nil];
    //key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    //isDuplicates = [[key stringForKey:@"duplicating"] isEqualToString:@"YES"];
    [self.progressLabel setText:[NSString stringWithFormat:@"..."]];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.appIconView.layer.masksToBounds = YES;
    self.appIconView.layer.cornerRadius = 35.0;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 35.0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.appIconView sd_setImageWithURL:[NSURL URLWithString:self.appIconLink] placeholderImage:[UIImage imageNamed:@""]];
    [self.appNameLabel setText:self.appNameString];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[ITHelper sharedInstance] downloadIPAFileForApp:self.requestedApp appIcon:self.appIconLink appName:self.appNameString appLink:self.requestedUrlString appVersion:self.appVersion hostName:self.hostName duplicate:self.dupliNumber completionBlock:^(NSData *data, NSURLResponse *response) {
        //
        NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
//        // // NSLog(@"******* COMP %@", strr);
    } errorBlock:^(NSError *error) {
        //
    } uploadPorgressBlock:^(float progress) {
        //
    } downloadProgressBlock:^(float progress, NSData *data) {
        //
        NSString *strr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
//        // // NSLog(@"****** PROG: %@", strr);
    }];
}
- (void)dismiss:(UITapGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)notificationMethod:(NSNotification *)notification {
    NSDictionary *userDict = notification.userInfo;
    NSString *message = userDict[@"message"];
    NSString *progressString = userDict[@"progress"];
    
    if ([message containsString:@"Ready To Install"]) {
        [self.progressView setProgress:[progressString floatValue]];
        if ([progressString floatValue] >= 1) {
            [self.progressView displayOperationDidFinishAnimation];
            double delayInSeconds = self.progressView.stateChangeAnimationDuration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.progressView.progress = 0.;
                self.progressView.hidden = YES;
            });
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:message]];
        [self.progressLabel setText:NSLocalizedString(@"Install App...", @"")];
    } else if ([message containsString:@"failed2"]) {
        [self.progressView setProgress:[progressString floatValue]];
        if ([progressString floatValue] >= 1) {
            [self.progressView displayOperationDidFinishAnimation];
            double delayInSeconds = self.progressView.stateChangeAnimationDuration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.progressView.progress = 0.;
                self.progressView.hidden = YES;
            });
        }
        [self.progressLabel setText:message];
        PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
        [queryAppsDB whereKey:APP_DB_VERSIONS_APP_ID equalTo:[self.requestedApp.appID lowercaseString]];
        [queryAppsDB whereKey:APP_DB_VERSIONS_VERSION_STRING equalTo:[self.appVersion lowercaseString]];
        [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil) {
                if (objects.count > 0) {
                    PFObject *currentApp = [objects objectAtIndex:0];
                    [currentApp deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error == nil) {
                            if (succeeded) {
                                [self dismiss:nil];
                            }
                        } else {
                            [ITHelper showErrorMessageFrom:self withError:error];
                        }
                    }];
                }
            }
        }];
    } else {
        [self.progressView setProgress:[progressString floatValue]];
        if ([progressString floatValue] >= 1) {
            [self.progressView displayOperationDidFinishAnimation];
            double delayInSeconds = self.progressView.stateChangeAnimationDuration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.progressView.progress = 0.;
                self.progressView.hidden = YES;
            });
        }
        [self.progressLabel setText:message];
    }
    
}

#pragma mark - Private Methods

- (void)startDownloadingAppFromLink:(NSString *)appLink appInfo:(ITAppObject *)appInfo {
    
//    [[ITHelper sharedInstance] downloadIPAFileForApp:appInfo appIcon:self.appIconLink appName:self.appNameString appLink:appLink appVersion:self.appVersion hostName:self.hostName duplicate:self.dupliNumber completionBlock:^(NSData *data, NSURLResponse *response) {
//        //
//    } errorBlock:^(NSError *error) {
//        //
//    } uploadPorgressBlock:^(float progress) {
//        //
//    } downloadProgressBlock:^(float progress, NSData *data) {
//        //
//    }];
    
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
