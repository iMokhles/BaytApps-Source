//
//  ITAppDescrip.h
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface ITAppDescrip : NSObject
@property NSString *artistName;
@property NSString *artwork60URL;
@property NSString *artwork512URL;
@property NSString *advisoryRating;
@property NSString *descriptionString;
@property BOOL isSupportAppleWatch;
@property NSString *fileSizeBytes;
@property CGFloat averageUserRating;
@property NSString *primaryGenreName;
@property NSString *changelogString;
@property NSArray *screenshotUrls;
@property NSString *developerName;
@property NSString *appName;
@property NSString *appVersion;
@property NSDictionary *appInfo;
@property NSString *languagesSupported;
@property NSString *devicesSupported;
@end
