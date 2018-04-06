//
//  BANewApi.m
//  baytapps
//
//  Created by iMokhles on 25/06/2017.
//  Copyright © 2017 imokhles. All rights reserved.
//

#import "BANewApi.h"
#import "Definations.h"
#import "BAHelper.h"
#import "ITServerHelper.h"
#import "ITHelper.h"

NSString *const kNewApiUrl = @"https://api.baytapps.net/api/v1/mobile";
@implementation BANewApi

+(BANewApi *)sharedInstance
{
    static BANewApi *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(instance ==nil){
            instance = [[BANewApi alloc] init];
        }
    });
    
    return instance;
}

- (void)downloadIPAFileForApp:(ITAppObject *)app
                      appIcon:(NSString *)appIconPath
                      appName:(NSString *)appNameString
                      appLink:(NSString *)appLink
                   appVersion:(NSString *)appVersion
                     hostName:(NSString *)host
                    duplicate:(NSInteger )dupliNumber
              completionBlock:(URLConnectionCompletionBlock)completionBlock
                   errorBlock:(URLConnectioErrorBlock)errorBlock
          uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
        downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock {
    
    NSString *provisioningPath1 = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath1]) {
        return;
    }
    
    NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = provisioningPath1;
        if (!provisioningPath) {
            mobileProvision = @{};
            return;
        }
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSISOLatin1StringEncoding error:NULL];
        if (!binaryString) {
            return;
        }
        NSScanner *scanner = [NSScanner scannerWithString:binaryString];
        BOOL ok = [scanner scanUpToString:@"<plist" intoString:nil];
        if (!ok) { // // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return;
        }
    }
    
    NSDictionary *profile = mobileProvision;
    //NSString *teamID = profile[@"UUID"];
    NSString *teamID2 = [profile[@"TeamIdentifier"] objectAtIndex:0];
    NSString *accountType;
    accountType = @"other";
    if (teamID2.length > 0) {
        if ([teamID2 isEqualToString:@"USM32L424X"]) accountType = @"ipa";
        if ([teamID2 isEqualToString:@"2R5JB2FB9E"]) accountType = @"ipa1";
        if ([teamID2 isEqualToString:@"J6D5BK3T6D"]) accountType = @"ipa2";
    } else {
        accountType = @"other";
    }
    
    
    NSString *pushToken = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEVICE_TOKEN]];
    NSString *verifyServer = @"baytapps";
    NSString *signature = @"ABzYP0WoORFAoTxS8ZOlBnUFocwfDQXs42jqsWEeunnqLR3WCepAtIwUKIRhXfx1xT2CKcqQXBltT3UcgOjI7C8LqdHvwNmGxRe2dkpVYuIhdHD7cih3VwHcPonKZeUclmp4LQbdy8D1Nk1j4aglKQXvxKjxGtmLglecLHTqOG09ZKDZ3gdBCbki646fkbeMPFH96IyvIoURiEcoJQCYETq6jrpOuFNLv5yuDFL2AoeItLfq1SsMMMP8ppnpPXlKBPEOcpPxCRUvQNSIZhflpT2Gxem1TQ33APTiEg";
    
    
    NSString *customURLString = [NSString stringWithFormat:
                                 @"usertoken=%@"
                                 @"&downloadLink=%@"
                                 @"&deviceId=%@"
                                 @"&appID=%@"
                                 @"&appVer=%@"
                                 @"&linkType=%@"
                                 @"&accType=%@"
                                 @"&dupliNumber=%@"
                                 @"&appName=%@"
                                 @"&appTrackID=%@"
                                 @"&devicetoken=%@"
                                 @"&signature=%@"
                                 @"&ordernumber=%@"
                                 @"&site=%@"
                                 @"&user_devicetoken=%@"
                                 @"&user_deviceauth=%@",
                                 
                                 
                                 EncryptText(@"", [PFUser currentUser].sessionToken),
                                 EncryptText(@"", appLink),
                                 EncryptText(@"",
                                             [PFUser currentUser][USER_DEVICE_PLAYER_ID]),
                                 EncryptText(@"", app.appID),
                                 EncryptText(@"", appVersion),
                                 EncryptText(@"", host),
                                 EncryptText(@"",
                                             accountType),
                                 EncryptText(@"", [NSString stringWithFormat:@"%li",(long)dupliNumber]),
                                 EncryptText(@"", [ITHelper replaceSpaceToUnderscoreIfNeed:appNameString]),
                                 EncryptText(@"", app.appTrackID),
                                 EncryptText(@"", pushToken),
                                 EncryptText(@"", signature),
                                 EncryptText(@"", [NSString stringWithFormat:@"%d", 2200]),
                                 EncryptText(@"", verifyServer),
                                 EncryptText(@"", pushToken),
                                 EncryptText(@"", pushToken)];
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/request_app", kNewApiUrl];
     NSLog(@"posting:::\n %@?%@",apiURL, customURLString);
    
    [self newPostMethodWithURL:apiURL postString:customURLString
               completionBlock:^(NSData *data, NSURLResponse *response) {
                   completionBlock(data, response);
               } errorBlock:^(NSError *error) {
                   errorBlock(error);
               } uploadPorgressBlock:^(float progress) {
                   uploadBlock(progress);
               } downloadProgressBlock:^(float progress, NSData *data) {
                   downloadBlock(progress, data);
               }];
}

- (void)newPostMethodWithURL:(NSString *)urlString
                  postString:(NSString *)postString
             completionBlock:(URLConnectionCompletionBlock)completionBlock
                  errorBlock:(URLConnectioErrorBlock)errorBlock
         uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
       downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock {
    
    NSString *post = postString;
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [request setValue:@"application/vnd.baytapps.v1+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"8pdKmOhm8CI2ve1YknrsBRErcOD8O7hS" forHTTPHeaderField:@"X_BAYTAPPS_MOBILE_Application_Id"];
    [request setValue:@"S6gSo2PwNxN9g4SDynrSpdJawblaNO62" forHTTPHeaderField:@"X_BAYTAPPS_MOBILE_Master_Id"];

    [request setHTTPBody:postData];
    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response) {
        completionBlock(data, response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    } uploadPorgressBlock:^(float progress) {
        uploadBlock(progress);
    } downloadProgressBlock:^(float progress, NSData *data) {
        downloadBlock(progress, data);
    }];
}
@end
