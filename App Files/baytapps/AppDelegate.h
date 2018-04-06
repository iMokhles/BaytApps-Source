//
//  AppDelegate.h
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "CustomBadge.h"

@interface UIDevice ()
- (id)buildVersion;
- (id)uniqueIdentifier;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver >

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) Boolean isVerified;
@property (nonatomic, readwrite) Boolean isRegistered;
@property (nonatomic, readwrite) Boolean isUSingOther;
@property (nonatomic, readwrite) Boolean isAvailableDuration;

@property (nonatomic, readwrite) Boolean isEnabled;

@property (strong, nonatomic) OneSignal *oneSignal;

@property (strong, nonatomic) CustomBadge *badge;


@property (nonatomic, readwrite) Boolean isSupportMessageExist;

@property (nonatomic, readwrite) Boolean isUpdateExist;
@property (nonatomic, readwrite) Boolean isInChatView;

-(void)changeBadge;


@end

