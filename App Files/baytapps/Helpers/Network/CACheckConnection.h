//
//  CACheckConnection.h
//  ContrAlert
//
//  Created by iMokhles on 08/05/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>
#import "CANetworkChecker.h"

@interface CACheckConnection : NSObject

@property (strong, nonatomic) CANetworkChecker *reachability;

+ (CACheckConnection *)sharedManager;
- (BOOL)isReachable;
- (BOOL)isUnreachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

@end
