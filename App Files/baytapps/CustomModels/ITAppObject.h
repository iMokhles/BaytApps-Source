//
//  ITAppObject.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>

@interface ITAppObject : NSObject
@property NSString *appSection;
@property NSString *appTrackID;
@property NSString *appName;
@property NSString *appID;
@property NSString *appVersion;
@property NSString *appIcon;
@property NSString *appPrice;
@property NSString *appStore;
@property NSString *appDescription;
@property NSArray *appScreenshots;
@property NSString *fileSizeBytes;
@property NSString *locallink;
@property NSDictionary *appInfo;
@end
