//
//  CACheckConnection.m
//  ContrAlert
//
//  Created by iMokhles on 08/05/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "CACheckConnection.h"

@interface CACheckConnection ()

@end

@implementation CACheckConnection

+ (CACheckConnection *)sharedManager
{
    static CACheckConnection *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Initialize Reachability
        self.reachability = [CANetworkChecker CANetworkCheckerWithHostname:@"www.google.com"];
        
        // Start Monitoring
        [self.reachability startNotifier];
    }
    
    return self;
}

- (void)dealloc
{
    // Stop Notifier
    if (_reachability)
    {
        [_reachability stopNotifier];
    }
}

- (BOOL)isReachable
{
    return [[[CACheckConnection sharedManager] reachability] isReachable];
}

- (BOOL)isUnreachable
{
    return ![[[CACheckConnection sharedManager] reachability] isReachable];
}

- (BOOL)isReachableViaWWAN
{
    return [[[CACheckConnection sharedManager] reachability] isReachableViaWWAN];
}

- (BOOL)isReachableViaWiFi
{
    return [[[CACheckConnection sharedManager] reachability] isReachableViaWiFi];
}

@end
