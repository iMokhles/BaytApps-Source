//
//  ITAppHoster.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>

@interface ITAppHoster : NSObject
@property NSString *hosterCracker;
@property NSString *hosterName;
@property NSString *hosterID;
@property NSString *hosterLink;
@property NSString *hosterAppVersion;
@property BOOL isProtected;
@property BOOL isVerified;
@end
