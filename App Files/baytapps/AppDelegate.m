//
//  AppDelegate.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "AppDelegate.h"
#import "ITHelper.h"
#import "AppConstant.h"
#import "Definations.h"
#import "ITServerHelper.h"
//#import "UICKeyChainStore.h"
#import "JFMinimalNotification.h"
#import "BASupportViewController.h"
#import "converter.h"
#import "Selene.h"
#import "BATaskManager.h"
//#import <Fabric/Fabric.h>
//#import <Answers/Answers.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "CACheckConnection.h"
#import "BANoInternetViewController.h"
#import <objc/runtime.h>

#import "AppDescriptionViewController.h"
#include <stdio.h>
#include <mach-o/dyld.h>
#import "PFUser+Util.h"
#import <AVFoundation/AVFoundation.h>
@interface PFDevice : NSObject

+ (instancetype)currentDevice;
- (NSString *)detailedModel;
- (NSString *)operatingSystemFullVersion;
- (NSString *)operatingSystemVersion;
- (NSString *)operatingSystemBuild;
@end


extern BOOL isChatViewAppear, isRecentViewAppear;

@interface AppDelegate () {
    //UICKeyChainStore *keyWrapper;
    NSTimer *timer;
    NSString *lastMessage;
    
}

@property (nonatomic, strong) JFMinimalNotification* minimalNotification;
@end



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ITHelper loadRootViewControllerForDevice];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [ITServerHelper setup_Server];
    //[ITServerHelper twitterInit];
    //[ITServerHelper facebookInitWithOptions:launchOptions];
    [BAHelper stayLTR];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUnreadCounter) name:@"NCCheckUnread" object:nil];
    id notificationReceiverBlock = ^(OSNotification *notification) {
        NSLog(@"Received Notification - %@", notification.payload.notificationID);
    };
    id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
        OSNotificationPayload* payload = result.notification.payload;
        
        NSString* messageTitle = @"OneSignal Example";
        NSString* fullMessage = [payload.body copy];
        
        if (payload.additionalData) {
            
            if(payload.title)
                messageTitle = payload.title;
            
            NSDictionary* additionalData = payload.additionalData;
            
            if (additionalData[@"actionSelected"])
                fullMessage = [fullMessage stringByAppendingString:[NSString stringWithFormat:@"\nPressed ButtonId:%@", additionalData[@"actionSelected"]]];
        }
    };
    
    id onesignalInitSettings = @{kOSSettingsKeyAutoPrompt : @YES, kOSSettingsKeyInAppAlerts:@NO};
    
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:[ITHelper push_accountID]
          handleNotificationReceived:notificationReceiverBlock
            handleNotificationAction:notificationOpenedBlock
                            settings:onesignalInitSettings];
    [OneSignal addSubscriptionObserver:self];
    [OneSignal setSubscription:true];
    [self setupMainPage];
    // NSLog(@"*********** 7 - 5");
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    return YES;
    
}
- (void)onOSSubscriptionChanged:(OSSubscriptionStateChanges*)stateChanges {
    
    // Example of detecting subscribing to OneSignal
    OSPermissionSubscriptionState* status = [OneSignal getPermissionSubscriptionState];
    NSLog(@"%@", status);
    if (!stateChanges.from.subscribed && stateChanges.to.subscribed) {
        NSLog(@"Subscribed for OneSignal push notifications!");
    }
    if ([PFUser currentUser] != nil ){
        // set user device push token
        if (stateChanges.to.pushToken != nil) {
            [PFUser currentUser][USER_DEVICE_TOKEN] = stateChanges.to.pushToken;
            [PFUser currentUser][USER_DEVICE_PLAYER_ID] = stateChanges.to.userId;
            [[PFUser currentUser] saveInBackground];
        }
        
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:stateChanges.to.pushToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] setObject:stateChanges.to.pushToken forKey:USER_DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:stateChanges.to.userId forKey:USER_DEVICE_PLAYER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // prints out all properties
    NSLog(@"SubscriptionStateChanges:\n%@", stateChanges);
}
- (void)onOSPermissionChanged:(OSPermissionStateChanges*)stateChanges {
    
    // Example of detecting anwsering the permission prompt
    if (stateChanges.from.status == OSNotificationPermissionNotDetermined) {
        if (stateChanges.to.status == OSNotificationPermissionAuthorized)
            NSLog(@"Thanks for accepting notifications!");
        else if (stateChanges.to.status == OSNotificationPermissionDenied)
            NSLog(@"Notifications not accepted. You can turn them on later under your iOS settings.");
    }
    
    
    // prints out all properties
    NSLog(@"PermissionStateChanges:\n%@", stateChanges);
}

#pragma mark - setupMainPage

- (void) logUser {
    return;
}


- (void)setupMainPage {
    if ([PFUser currentUser] == nil) {
        // NSLog(@"*********** 7 - 6");
        [ITHelper showLaunchOrMainView:NO];
    } else {
        //        [[BAHelper sharedInstance] testServer];
        
        
        // NSLog(@"*********** 7 - 7");
        [ITHelper showLaunchOrMainView:YES];
    }
}

#pragma mark - custom methods
- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"=eq="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}
- (NSString *)getStringBetween:(NSString *)string1 andString:(NSString *)string2 fromString:(NSString *)fullString {
    
    NSRange r1 = [fullString rangeOfString:string1];
    NSRange r2 = [fullString rangeOfString:string2];
    NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    NSString *status = [fullString substringWithRange:rSub];
    return status;
}
- (void)checkUnreadCounter {
    
    if ([PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
        [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
        [query includeKey:PF_RECENT_LASTUSER];
        [query orderByDescending:PF_RECENT_UPDATEDACTION];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             for (int i = 0; i < objects.count; i++) {
                 PFObject *recent = [objects objectAtIndex:i];
                 int counter = [recent[PF_RECENT_COUNTER] intValue];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"hasUnread"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 if (counter > 0) {
                     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"hasUnread"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
             }
         }];
    }
    
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        // NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        // NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // This method will be called everytime you open the app
    
    // OneSignal
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    NSString *tokenDevice = [token copy];
    [[NSUserDefaults standardUserDefaults] setObject:tokenDevice forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] setObject:tokenDevice forKey:USER_DEVICE_TOKEN];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"deviceToken:%@", tokenDevice);
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //    [[UAirship push] appReceivedRemoteNotification:userInfo applicationState:application.applicationState];
    //    // NSLog(@"\n\n\n\n %@", userInfo);
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //    // Start asynchronous NSOperation, or some other check
    NSLog(@"\n %@", userInfo);
    NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if ([message containsString:@"BA_NOTI"]) {
        if ([message containsString:@"Preparing"] || [message containsString:@"Downloading"] || [message containsString:@"Building"]) {
            //                            // NSLog(@"BA_NOTI: message: %@ \nadditionalData: %@ \nisActive: %@", message, additionalData, isActive ? @"Yes" : @"No");
            
            
            
            NSArray *stringarray = [message componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"server_message" forKey:[stringarray objectAtIndex:1]];
            [[NSUserDefaults standardUserDefaults] setObject:@"server_progress" forKey:[[[userInfo objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"progress"]];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TO_DOWNLOAD_APP object:nil userInfo:@{@"message": [stringarray objectAtIndex:1], @"progress": [[[userInfo objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"progress"]}];
            
        }
    } else {
        if ([message containsString:@"BA_PRG"]) {
            NSArray *stringarray = [message componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TO_DOWNLOAD_APP object:nil userInfo:@{@"message": [stringarray objectAtIndex:1]}];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"server_message" forKey:[stringarray objectAtIndex:1]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            if ([message containsString:@"Ready To Install"]) {
                //                                // NSLog(@"Ready: message: %@ \nadditionalData: %@ \nisActive: %@", message, additionalData, isActive ? @"Yes" : @"No");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TO_DOWNLOAD_APP object:nil userInfo:@{@"message": message, @"progress": [[[userInfo objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"progress"]}];
                
                [[NSUserDefaults standardUserDefaults] setObject:@"server_message" forKey:message];
                [[NSUserDefaults standardUserDefaults] setObject:@"server_progress" forKey:[[[userInfo objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"progress"]];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    //
    //    // Ideally the NSOperation would notify when it has completed, but just for
    //    // illustrative purposes, call the completion block after 20 seconds.
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC),
    //                   dispatch_get_main_queue(), ^{
    //                       // Check result of your operation and call completion block with the result
    //                       completionHandler(UIBackgroundFetchResultNewData);
    //                   });
    //
    
    completionHandler(UIBackgroundFetchResultNewData);
    //    [[UAirship push] appReceivedRemoteNotification:userInfo
    //                                  applicationState:application.applicationState
    //                            fetchCompletionHandler:completionHandler];
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())handler {
    //    [[UAirship push] appReceivedActionWithIdentifier:identifier
    //                                        notification:userInfo
    //                                    applicationState:application.applicationState
    //                                   completionHandler:handler];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())handler {
    //    [[UAirship push] appReceivedActionWithIdentifier:identifier
    //                                        notification:userInfo
    //                                        responseInfo:responseInfo
    //                                    applicationState:application.applicationState
    //                                   completionHandler:handler];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //    [[UAirship push] appRegisteredUserNotificationSettings];
}

//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
////    [SLNScheduler startWithCompletion:completionHandler];
//}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

//- (NSDate *)logicalOneYearAgo:(NSDate *)from {
//
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
//
//    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init] ;
//    [offsetComponents setYear:+1];
//
//    return [gregorian dateByAddingComponents:offsetComponents toDate:from options:0];
//
//}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //    NSArray *tasks = @[[BATaskManager class]];
    //    // Run the scheduler every 5 minutes
    //    [SLNScheduler setMinimumBackgroundFetchInterval:5];
    //    // Add the tasks
    //    [SLNScheduler scheduleTasks:tasks];
    
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        //        BANoInternetViewController *launchVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"noConnectionVC"];
        //        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
        //
        //        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
        //                          duration:0.3
        //                           options:UIViewAnimationOptionTransitionNone
        //                        animations:nil
        //                        completion:nil];
        
        [KVNProgress showWithStatus:NSLocalizedString(@"No Internet Connection...", @"")];
        
    } else {
        //        if ([PFUser currentUser] != nil) {
        //
        //            [CrashlyticsKit setObjectValue:[PFUser currentUser][USER_TEAM_ID] forKey:USER_TEAM_ID];
        //            [CrashlyticsKit setObjectValue:[PFUser currentUser][USER_DEVICE_TYPE] forKey:USER_DEVICE_TYPE];
        //            [CrashlyticsKit setObjectValue:[PFUser currentUser][USER_EXPIRY_DATE] forKey:USER_EXPIRY_DATE];
        //            [CrashlyticsKit setUserIdentifier:[PFUser currentUser][USER_DEVICE_ID]];
        //            [CrashlyticsKit setUserEmail:[PFUser currentUser].email];
        //            [CrashlyticsKit setUserName:[PFUser currentUser].username];
        //
        //
        //
        //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ////
        ////
        ////
        ////                [[PFUser currentUser] saveInBackground];
        ////                [[PFUser currentUser] fetch];
        //            });
        //        }
    }
    
    //    [[FLEXManager sharedManager] showExplorer];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([PFUser currentUser] == nil) {
        return;
    }
    [BAHelper checkForUpdate];
    if (!self.isInChatView) {
        
        
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
        [query whereKey:PF_MESSAGE_GROUPID containsString:[PFUser currentUser].objectId];
        //  [query orderByDescending:PF_RECENT_UPDATEDACTION];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 if (objects.count == 0) {
                     
                     // [self initchat];
                     
                 } else if (objects.count > 0) {
                     
                     
                     
                     PFObject *obj = [objects firstObject];
                     PFUser *use = obj[@"user"];
                     
                     if (![use.objectId isEqualToString:[PFUser currentUser].objectId]) {
                         
                         NSString *str = obj[@"text"];
                         if ([str isEqualToString:lastMessage]) {
                             
                         }else{
                             if(lastMessage != nil){
                                 [ITHelper showSuccessAlert:[NSString stringWithFormat:@"Support sent message: %@",str]];
                                 lastMessage = str;
                                 _isSupportMessageExist = YES;
#define systemSoundID    1007
                                 AudioServicesPlaySystemSound (systemSoundID);
                                 [self changeBadge];
                             }else{
                                 lastMessage = str;
                                 
                             }
                         }
                     }
                     
                 }
             }
             
             // else [ITHelper showErrorMessageFrom:self withError:error];
         }];
    }
    
  //  NSLog(@"%@",@"loading..........");
    
    
}
//----------------------------------------------
-(void)changeBadge{
    if (self.isSupportMessageExist) {
        self.badge.hidden = NO;
        [self.badge autoBadgeSizeWithString:@"1"];
    }
    
    if (self.isUpdateExist) {
        self.badge.hidden = NO;
        [self.badge autoBadgeSizeWithString:@"1"];
    }
    
    if(self.isUpdateExist && self.isSupportMessageExist){
        self.badge.hidden = NO;
        [self.badge autoBadgeSizeWithString:@"2"];
    }
    
    if(!self.isUpdateExist){
        if(!self.isSupportMessageExist){
            self.badge.hidden = YES;
        }
    }
    
}
@end


