//
//  ITConstants.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>

@interface ITConstants : NSObject
FOUNDATION_EXPORT NSString *const kappdbAPIURL;
FOUNDATION_EXPORT NSString *const kCatForUs;

FOUNDATION_EXPORT NSString *const kCustomAppsServerURL;
FOUNDATION_EXPORT NSString *const kTotoaCustomAppsServerURL;

FOUNDATION_EXPORT NSString *const kConsumerKey;
FOUNDATION_EXPORT NSString *const kConsumerSecret;

FOUNDATION_EXPORT NSString *const kSHOPURL;
FOUNDATION_EXPORT NSString *const kAPIURL;

FOUNDATION_EXPORT NSString *const kTotoaConsumerKey;
FOUNDATION_EXPORT NSString *const kTotoaConsumerSecret;

FOUNDATION_EXPORT NSString *const kSHOPURLTotoa;
FOUNDATION_EXPORT NSString *const kAPIURLTotoa;

FOUNDATION_EXPORT NSString *const kCloudAPI;
FOUNDATION_EXPORT NSString *const kTotoaCloudAPI;

FOUNDATION_EXPORT NSString *const kCloudURL;
FOUNDATION_EXPORT NSString *const kTotoaCloudURL;

FOUNDATION_EXPORT NSString *const kSignatureMethod;

//Authentication Parameters

FOUNDATION_EXPORT NSString *const kOauthConsumerKey;
FOUNDATION_EXPORT NSString *const kOauthTimestamp;
FOUNDATION_EXPORT NSString *const kOauthNonce;
FOUNDATION_EXPORT NSString *const kOauthSignature;
FOUNDATION_EXPORT NSString *const kOauthSignatureMethod;

@end
