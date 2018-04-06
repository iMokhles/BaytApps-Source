//
//  ITServerHelper.m
//  ioteam
//
//  Created by iMokhles on 29/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITServerHelper.h"
#import "CACheckConnection.h"
#import "RNCryptor.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "AESCrypt.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "Base64.h"
#import "ITHelper.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wconstant-conversion"

__attribute__((always_inline, visibility("hidden")))
static NSString *PARSE_APP_KEY() {
    char s_New[] = {0x42, 0x79, 0x4b, 0x4a, 0x3c, 0x57, 0x55, 0x37, 0x6a, 0x52, 0x7d, 0x63, 0x41, 0x3f, 0x67, 0x71, 0x58, 0x4a, 0x7f, 0x5d, 0x5d, 0x68, 0xffffff91, 0x43, 0x5d, 0xffffff8f, 0xffffff8a, 0x68, 0xffffff85, 0xffffff8f, 0xffffff8a, 0x79, 0x79, 0xffffff97, 0x70, 0x7d, 0x55, 0xffffff80, 0x6c, 0x60, 0x78, 0x61, 0x6d, 0xffffffa0, 0x5d, 0x5e, 0x64, 0xffffff93, 0xffffff8a, 0xffffff88, 0xffffffab, 0x79, 0xffffff87, 0xffffffae, 0x7f, 0xffffff9c, 0x64, 0x72, 0xffffffa1, 0x7e, 0xffffff94, 0x6e, 0xffffffb0, 0xffffffa6, 0xffffff9b, 0xffffff85, 0xffffff8b, 0xffffff98, 0xffffff97, 0xffffff9b, 0xffffff8e, 0xffffffb9, 0xffffff8b, 0xffffffc1, 0xffffffc4, 0xffffffc6, 0xffffffc1, 0xffffff83, 0xffffff81, 0xffffffbd, 0xffffffa0, 0xffffff9d, 0xffffff85, 0xffffffbc, 0xffffffb6, 0xffffffa4, 0xffffffd0, 0xffffffa6, 0xffffffab, 0xffffffc3, 0xffffffbe, 0xffffff8b, 0xffffffc1, 0xffffffc3, 0xffffffd7, 0xffffffd5, 0xffffffa9, 0xffffffb0, 0xffffffd7, 0xffffffcc, 0xffffffb0, 0xffffffab, 0xffffff99, 0xffffffcb, 0xffffffc1, 0xffffffd2, 0xffffffcf, 0xffffffb6, 0xffffffb5, 0xffffffd6, 0xffffffe0, 0xffffffea, 0xffffffa7, 0xffffffb9, 0xffffffa8, 0xffffffec, 0xffffffa9, 0xffffffb8, 0xffffffe6, 0xffffffe8, 0xffffffe5, 0xffffffd1, 0xffffffe1, 0xffffffc2, 0xffffffb3, 0xffffffd8, 0xffffffe9, 0xffffffb7, 0xfffffff8, 0xffffffe7, 0xffffffc4, 0xfffffffd, 0xffffffb4, 0xfffffff3, 0xfffffffc, 0xfffffff8, 0xffffffcf, 0xffffffdc, 0xffffffcd, 0xffffffcd, 0xffffffd8, 0xfffffff6, 0xffffffe5, 0xffffffff, 0xffffffdf, 0x02, 0x04, 0xffffffe3, 0xfffffff8, 0xffffffcc, 0xffffffc7, 0xffffffce, 0xffffffd0, 0xffffffef, 0x09, 0x10, 0xfffffff2, 0x09, 0xffffffd0, 0x0c, 0x1b, 0x03, 0xffffffce, 0x18, 0x12, 0x0f, 0xffffffed, 0x19, 0x19, 0xffffffff, 0x05, 0xfffffff0, 0x20, 0x25, 0xffffffec, 0xffffffed, 0x00};
    for (int i = 0; i < ((sizeof(s_New) / sizeof(char)) - 1); i++)
    {
        s_New[i] = s_New[i] - (0x01 * (i + 1));
    }
    NSString *new_PATH = [NSString stringWithFormat:@"%s", s_New];
    
    return new_PATH;
}

__attribute__((always_inline, visibility("hidden")))
static NSString *PARSE_CLIENT_KEY() {
    char s_New[] = {0x42, 0x79, 0x48, 0x75, 0x71, 0x36, 0x37, 0xffffff81, 0x38, 0x56, 0x5c, 0x64, 0x3c, 0x7b, 0xffffff86, 0x45, 0xffffff8b, 0x59, 0x45, 0x69, 0x65, 0x48, 0x4e, 0x48, 0x7b, 0x60, 0x71, 0x5d, 0x55, 0x50, 0x4e, 0xffffff91, 0xffffff85, 0x6c, 0x69, 0x7e, 0x5e, 0x74, 0x79, 0xffffff91, 0xffffff8f, 0xffffff9c, 0x6c, 0xffffff92, 0x58, 0xffffff88, 0xffffff99, 0x76, 0xffffff99, 0x73, 0x7e, 0xffffffa6, 0x7a, 0xffffff9c, 0xffffff89, 0x79, 0xffffff9b, 0xffffff83, 0x72, 0xffffff90, 0xffffffa1, 0xffffff8f, 0x77, 0xffffff88, 0xffffffb5, 0xffffffb8, 0xffffff99, 0xffffffa5, 0xffffffb8, 0xffffff8b, 0x7b, 0xffffff9a, 0xffffffbc, 0xffffffb4, 0xffffff9e, 0xffffffbe, 0xffffffc5, 0xffffff9a, 0xffffffc6, 0xffffff99, 0xffffff9c, 0xffffff84, 0xffffff99, 0xffffffb5, 0xffffffa9, 0xffffffaa, 0xffffff98, 0xffffff91, 0xffffff8d, 0xffffffa4, 0xffffffd5, 0xffffffa1, 0xffffffb7, 0xffffff8e, 0xffffffad, 0xffffff94, 0xffffffc9, 0xffffffb7, 0xffffffc5, 0xffffffca, 0xffffffdb, 0xffffffba, 0xffffffd4, 0xffffffcf, 0xffffffba, 0xffffffb3, 0xffffff9d, 0xffffffb2, 0xffffffdb, 0xffffffa3, 0xffffffa1, 0xffffffdb, 0xffffffe6, 0xffffffab, 0xffffffa2, 0xffffffd8, 0xffffffd9, 0xffffffe0, 0xffffffd9, 0xffffffc8, 0xffffffcc, 0xffffffe2, 0xffffffc2, 0xffffffe7, 0xfffffff6, 0xffffffe0, 0xffffffb5, 0xfffffff5, 0xfffffff6, 0xffffffb2, 0xffffffe5, 0xffffffcf, 0xffffffdd, 0xfffffffd, 0xffffffec, 0xffffffd1, 0xffffffde, 0xfffffff8, 0x01, 0xfffffff6, 0xffffffb8, 0xffffffbf, 0xffffffdd, 0xffffffd5, 0x02, 0xffffffca, 0xfffffff9, 0x07, 0xffffffc5, 0xffffffca, 0x0e, 0xffffffe9, 0xffffffed, 0x05, 0xffffffc6, 0xffffffe6, 0xffffffe6, 0xffffffd0, 0xffffffcf, 0x09, 0xffffffd3, 0xfffffff2, 0xfffffffc, 0x09, 0x12, 0x07, 0x1c, 0xfffffff8, 0xfffffffa, 0x11, 0xffffffda, 0xfffffff5, 0xffffffe1, 0x15, 0xffffffec, 0xffffffed, 0x00};
    for (int i = 0; i < ((sizeof(s_New) / sizeof(char)) - 1); i++)
    {
        s_New[i] = s_New[i] - (0x01 * (i + 1));
    }
    NSString *new_PATH = [NSString stringWithFormat:@"%s", s_New];
    
    return new_PATH;
}

__attribute__((always_inline, visibility("hidden")))
static NSString *URL_CLIENT_KEY() {
    char s_New[] = {0x69, 0x76, 0x77, 0x74, 0x3f, 0x35, 0x36, 0x71, 0x76, 0x79, 0x76, 0x74, 0x79, 0x73, 0xffffff82, 0x3e, 0x7f, 0x77, 0xffffff87, 0x4e, 0x46, 0x49, 0x4a, 0x4f, 0x48, 0xffffff8a, 0x7c, 0xffffff8e, 0xffffff90, 0xffffff83, 0x00};
    for (int i = 0; i < ((sizeof(s_New) / sizeof(char)) - 1); i++)
    {
        s_New[i] = s_New[i] - (0x01 * (i + 1));
    }
    NSString *new_PATH = [NSString stringWithFormat:@"%s", s_New];
    
    return new_PATH;
}

__attribute__((always_inline, visibility("hidden")))
NSString *ENCRYPT_TEXT_KEY() {
    char s_New[] = {0x42, 0x79, 0x49, 0x54, 0x77, 0x4f, 0x3c, 0x5f, 0x56, 0x35, 0x5d, 0x3f, 0x5c, 0x77, 0x63, 0x52, 0x60, 0x41, 0xffffff88, 0x48, 0xffffff80, 0xffffff81, 0x69, 0x59, 0x4e, 0x7f, 0x67, 0x50, 0x65, 0x55, 0xffffff8d, 0xffffff95, 0xffffff85, 0x5b, 0x65, 0x77, 0xffffff96, 0x5d, 0x5f, 0xffffff81, 0xffffff9f, 0xffffff80, 0xffffff9e, 0xffffff86, 0xffffffa0, 0x74, 0xffffff87, 0x7a, 0x67, 0xffffffa1, 0x74, 0x7c, 0xffffffaf, 0xffffff87, 0xffffff9b, 0xffffffa1, 0x7f, 0x6f, 0xffffffa9, 0xffffffb3, 0xffffffac, 0xffffffb0, 0xffffffb1, 0xffffffac, 0xffffffaa, 0xffffff94, 0x7b, 0x7d, 0xffffffae, 0xffffff92, 0xffffffbf, 0xffffff9a, 0xffffffbc, 0xffffffad, 0xffffff9f, 0x7d, 0xffffff80, 0xffffffb2, 0xffffffbd, 0xffffffc4, 0xffffffaa, 0xffffff96, 0xffffff9f, 0xffffff83, 0xffffffca, 0xffffffa2, 0xffffffc8, 0xffffff88, 0xffffffc4, 0xffffff8c, 0xffffffb1, 0xffffffc1, 0xffffffac, 0xffffffb0, 0xffffffc8, 0xffffffa2, 0xffffffd5, 0xffffffa8, 0xffffffc8, 0xffffffaf, 0xffffffd3, 0xffffffcd, 0xffffffcf, 0xffffffdc, 0xffffffdc, 0xffffff9f, 0xffffffe4, 0xffffffbe, 0xffffffaf, 0xffffffbf, 0xffffff9e, 0xffffffd6, 0xffffffdb, 0xffffffbe, 0xffffffd4, 0xffffff9f, 0xffffffe9, 0xffffffea, 0xffffffe3, 0xffffffaa, 0xffffffb1, 0xffffffc5, 0xffffffd5, 0xffffffe4, 0xffffffc1, 0xffffffea, 0xffffffc4, 0xffffffce, 0xffffffe9, 0xfffffff2, 0xffffffe6, 0xffffffc7, 0xfffffffa, 0xffffffea, 0x01, 0xffffffc1, 0xffffffc0, 0xffffffcb, 0xffffffdb, 0xffffffd1, 0xfffffff4, 0x01, 0xffffffc4, 0xffffffdd, 0xfffffff2, 0xffffffd7, 0xffffffc4, 0xffffffca, 0xffffffef, 0xfffffff0, 0xffffffc7, 0x03, 0xffffffee, 0x03, 0xfffffffe, 0x10, 0x06, 0xffffffe3, 0xffffffe1, 0x04, 0xffffffd4, 0xfffffffc, 0xffffffec, 0x09, 0x18, 0xfffffff4, 0x20, 0x19, 0xffffffe0, 0xfffffffe, 0xffffffda, 0xffffffdf, 0x06, 0xfffffff2, 0x1f, 0x24, 0xfffffffa, 0xffffffe3, 0x06, 0x23, 0x0a, 0x18, 0x1b, 0x05, 0x02, 0xffffffec, 0xffffffea, 0x0c, 0x2a, 0xffffffe9, 0x0d, 0x14, 0x2d, 0xfffffff6, 0xfffffff6, 0x0a, 0x14, 0x35, 0xfffffff7, 0x2c, 0x3c, 0x37, 0x32, 0x46, 0x20, 0x26, 0x3a, 0x1b, 0x28, 0x21, 0x2b, 0x46, 0x42, 0x1a, 0x43, 0x25, 0x4d, 0x29, 0x32, 0x46, 0x15, 0x48, 0x31, 0x15, 0x2a, 0x25, 0x2e, 0x30, 0x48, 0x3f, 0x35, 0x49, 0x4a, 0x19, 0x41, 0x22, 0x42, 0x36, 0x27, 0x37, 0x35, 0x5a, 0x6c, 0x5a, 0x62, 0x65, 0x3b, 0x70, 0x2f, 0x60, 0x6e, 0x5e, 0x74, 0x6b, 0x36, 0x45, 0x4e, 0x37, 0x32, 0x53, 0x4f, 0x60, 0x57, 0x6d, 0x5e, 0x7f, 0x3f, 0x7c, 0x73, 0x6f, 0xffffff84, 0x76, 0x60, 0x75, 0x62, 0x5e, 0xffffff87, 0x41, 0x60, 0x64, 0x4d, 0x7c, 0x54, 0x6a, 0x4e, 0x77, 0x6c, 0xffffff81, 0x51, 0x59, 0x52, 0x55, 0xffffff98, 0x7f, 0x5a, 0x5d, 0x7a, 0xffffff9d, 0x76, 0x7a, 0x74, 0xffffffa2, 0x7e, 0xffffffa9, 0x79, 0x67, 0xffffffa4, 0x68, 0xffffff85, 0xffffffae, 0xffffff99, 0x6c, 0xffffffa1, 0x6d, 0xffffff81, 0x70, 0xffffff9e, 0xffffff80, 0xffffff81, 0xffffff98, 0xffffffad, 0x75, 0xffffff85, 0xffffffa8, 0x7b, 0xffffff9f, 0xffffff9c, 0xffffffba, 0xffffffc0, 0x75, 0xffffff83, 0xffffff94, 0xffffffbb, 0xffffff8f, 0x7a, 0xffffff9a, 0xffffffbc, 0xffffff9c, 0xffffffcd, 0xffffffbc, 0xffffffb6, 0xffffffc7, 0xffffffce, 0xffffffac, 0xffffffc8, 0xffffffa7, 0xffffffa2, 0xffffffc0, 0xffffffd6, 0xffffffc8, 0xffffff8a, 0xffffffad, 0xffffff9a, 0xffffffcf, 0xffffffba, 0xffffffbe, 0xffffffdf, 0xffffff9c, 0xffffffb1, 0xffffffd3, 0xffffffaf, 0xffffffe0, 0xffffffe5, 0xffffffce, 0xffffffd5, 0xffffffd2, 0xffffffc2, 0xffffffa7, 0xffffffe7, 0xffffffa4, 0xffffffea, 0xffffffbb, 0xffffffa0, 0xffffffa1, 0xffffffe7, 0xffffffc5, 0xffffffde, 0xfffffff1, 0xffffffbf, 0xffffffd0, 0xffffffc2, 0xffffffef, 0xffffffc9, 0xffffffec, 0xffffffd2, 0xffffffc9, 0xffffffe5, 0xffffffcc, 0xfffffff9, 0xffffffe8, 0xfffffffa, 0xffffffeb, 0x02, 0xffffffd5, 0xffffffd8, 0xffffffd6, 0xfffffff9, 0xffffffc6, 0xfffffff2, 0xffffffea, 0xffffffe7, 0xffffffd7, 0xffffffd7, 0x0e, 0xfffffff9, 0x01, 0x05, 0xfffffff1, 0xffffffdb, 0xffffffe3, 0xffffffd1, 0xffffffcf, 0xfffffff4, 0x0b, 0xfffffff8, 0xffffffe5, 0xffffffeb, 0xffffffd3, 0xffffffed, 0xffffffe9, 0xffffffdd, 0x11, 0x08, 0xfffffffe, 0xffffffe2, 0x12, 0xffffffed, 0x05, 0x17, 0xfffffff0, 0x26, 0xfffffff6, 0x23, 0x24, 0x20, 0x29, 0xfffffffe, 0xfffffff7, 0x0f, 0xffffffe3, 0x30, 0x31, 0x31, 0x03, 0x03, 0x0e, 0x17, 0x31, 0xfffffff2, 0x39, 0x31, 0x3b, 0x15, 0x09, 0xfffffffc, 0x2e, 0x2f, 0x18, 0x1e, 0xfffffffc, 0x00, 0x17, 0x10, 0x09, 0x22, 0xfffffffd, 0x4c, 0x37, 0x2a, 0x1c, 0x21, 0x03, 0x2a, 0x21, 0x43, 0x45, 0x22, 0x24, 0x12, 0x2f, 0x4f, 0x4d, 0x44, 0x29, 0x18, 0x48, 0x34, 0x36, 0x3e, 0x2c, 0x2c, 0x4f, 0x47, 0x3f, 0x2c, 0x2d, 0x00};
    for (int i = 0; i < ((sizeof(s_New) / sizeof(char)) - 1); i++)
    {
        s_New[i] = s_New[i] - (0x01 * (i + 1));
    }
    NSString *new_PATH = [NSString stringWithFormat:@"%s", s_New];
    
    return new_PATH;
}

__attribute__((always_inline, visibility("hidden")))
NSData *SECRET_DATA_KEY() {
    return [ENCRYPT_TEXT_KEY() dataUsingEncoding:NSUTF8StringEncoding];
}
//static NSString *const PARSE_APP_KEY = main_App_Key();
//static NSString *const PARSE_CLIENT_KEY = main_App_Client();

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptText(NSString *userName, NSString *string)
{
    NSError *error = nil;

    NSData *plain = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [RNEncryptor encryptData:plain withSettings:kRNCryptorAES256Settings password:ENCRYPT_TEXT_KEY() error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:[cipherData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    
    return cipherString;
}

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptText2(NSString *userName, NSString *string)
{
    NSError *error = nil;
    
    NSData *plain = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [RNEncryptor encryptData:plain withSettings:kRNCryptorAES256Settings password:EncryptText(@"", ENCRYPT_TEXT_KEY()) error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:[cipherData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    
    return cipherString;
}

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptDeviceToken(NSString *userName, NSString *string)
{
    NSError *error = nil;
    
    NSData *plain = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [RNEncryptor encryptData:plain withSettings:kRNCryptorAES256Settings password:ENCRYPT_TEXT_KEY() error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:[cipherData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    
    return cipherString;
}

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptUserToken(NSString *userName, NSString *string)
{
    NSError *error = nil;
    
    NSData *plain = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [RNEncryptor encryptData:plain withSettings:kRNCryptorAES256Settings password:ENCRYPT_TEXT_KEY() error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:[cipherData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    
    return cipherString;
}

__attribute__((always_inline, visibility("hidden")))
NSString* DecryptText(NSString *userName, NSString *string)
{
    
    NSError *error = nil;
    NSData *plain = [string base64DecodedData];
    NSData *cipherDecryptedData = [RNDecryptor decryptData:plain withPassword:ENCRYPT_TEXT_KEY() error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:cipherDecryptedData encoding:NSUTF8StringEncoding];
    return cipherString;
}

__attribute__((always_inline, visibility("hidden")))
NSString* DecryptDeviceToken(NSString *userName, NSString *string)
{
    NSError *error = nil;
    NSData *plain = [string base64DecodedData];
    NSData *cipherDecryptedData = [RNDecryptor decryptData:plain withPassword:ENCRYPT_TEXT_KEY() error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:cipherDecryptedData encoding:NSUTF8StringEncoding];
    return cipherString;
}

__attribute__((always_inline, visibility("hidden")))
NSString* DecryptUserToken(NSString *userName, NSString *string)
{
    NSError *error = nil;
    NSData *plain = [string base64DecodedData];
    NSData *cipherDecryptedData = [RNDecryptor decryptData:plain withPassword:ENCRYPT_TEXT_KEY() error:&error];
    NSString *cipherString = [[NSString alloc] initWithData:cipherDecryptedData encoding:NSUTF8StringEncoding];
    return cipherString;
}

@implementation ITServerHelper

+ (void)setup_Server {
    
    [Parse setLogLevel:PFLogLevelDebug];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
//        configuration.applicationId = @"baytapps_appid_2017";
//        configuration.clientKey = @"baytapps_masterkey_2017";
//        configuration.server = @"http://baytapps.herokuapp.com/parse";
        configuration.applicationId = @"qKBaE5oEzTdzfz7IdwvMSNhCfCd6W0wu1VmTdzfz7IdwvMSNhhCfCd6W";
        configuration.clientKey = @"TxyqcaSbcB6zOdTdzfz7IdwvMSNhCfCd1Vm34598vsB6zOdTdzfz7IdwvMSN";
        configuration.server = @"https://parse.baytapps.net/parse";
        configuration.localDatastoreEnabled = YES;
    }]];
//    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
//        
//        configuration.applicationId = PARSE_APP_KEY();
//        configuration.clientKey = PARSE_CLIENT_KEY();
//        configuration.server = URL_CLIENT_KEY();
//        configuration.localDatastoreEnabled = YES;
//    }]];
}

+ (void)twitterInit {
    [PFTwitterUtils initializeWithConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
    
}

+ (void)facebookInitWithOptions:(NSDictionary *)options {
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:options];
}


+ (void)test_server_Connection {

}

+ (void)signupUserWithInfo:(NSDictionary *)userInfo andAvatarImage:(UIImage *)userImage fromtarget:(id)target completion:(iMBooleanResultBlock)completion {

}

+ (void)likePost:(PFObject *)post byUser:(PFUser *)user withBlock:(iMBooleanResultBlock)compeltion {
    
    PFQuery *query = [PFQuery queryWithClassName:LIKES_CLASS_NAME];
    [query whereKey:LIKES_LIKED_BY equalTo:user];
    [query whereKey:LIKES_APP_LIKED equalTo:post];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            PFObject *likesClass = [PFObject objectWithClassName:LIKES_CLASS_NAME];
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    
                } else {
                    if (succeeded) {
                        
                    }
                    
                }
            }];
            if (objects.count == 0) {
                // Like post
                [post incrementKey:APP_LIKES byAmount:[NSNumber numberWithInt:1]];
                [post saveInBackground];
                
                likesClass[LIKES_LIKED_BY] = user;
                likesClass[LIKES_APP_LIKED] = post;
                [likesClass saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    compeltion(succeeded, error);
                }];
            }
        } else {
            compeltion(NO, error);
        }
    }];
}

+ (void)disLikePost:(PFObject *)post byUser:(PFUser *)user withBlock:(iMBooleanResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:LIKES_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:LIKES_LIKED_BY equalTo:user];
    [query whereKey:LIKES_APP_LIKED equalTo:post];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count > 0) {
                PFObject *likesClass = objects[0];
                // dislike post
                [post incrementKey:APP_LIKES byAmount:[NSNumber numberWithInt:-1]];
                [post saveInBackground];
                
                [likesClass deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    compeltion(succeeded, error);
                }];
            }
        } else {
            compeltion(NO, error);
        }
    }];
}

+ (void)isPostLikedByCurrentUser:(PFObject *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:LIKES_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:LIKES_LIKED_BY equalTo:[PFUser currentUser]];
    [query whereKey:LIKES_APP_LIKED equalTo:object];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count == 0) {
                compeltion(NO);
            } else if (objects.count > 0) {
                compeltion(YES);
            }
        }
    }];
}

+ (void)getFollowersForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:FOLLOW_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:FOLLOW_IS_FOLLOWING equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            compeltion((int)objects.count);
        }
    }];
}

+ (void)getAllFollowersForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:FOLLOW_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:FOLLOW_IS_FOLLOWING equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            compeltion(YES, objects, error);
        }
    }];
}

+ (void)getFollowingForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:FOLLOW_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:FOLLOW_A_USER equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            compeltion((int)objects.count);
        }
    }];
}

+ (void)getAllFollowingForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:FOLLOW_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:FOLLOW_A_USER equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            NSMutableArray *followingUsers = [NSMutableArray new];
            for (PFObject *followObject in objects) {
                
                [followingUsers addObject:followObject[FOLLOW_IS_FOLLOWING]];
            }
            compeltion(YES, followingUsers, error);
        }
    }];
}

+ (void)getInstallationsForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:INSTALLATIONS_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:INSTALLATIONS_INSTALLED_BY equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            compeltion((int)objects.count);
        }
    }];
}

+ (void)getFavoritesForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:FAVORITES_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:FAVORITES_FAVORITED_BY equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            compeltion((int)objects.count);
        }
    }];
}

+ (void)getAppsForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion {
    PFQuery *followersQuery = [PFQuery queryWithClassName:APP_CLASSE_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followersQuery fromLocalDatastore];
    }
    [followersQuery whereKey:APP_USER_POINTER equalTo:user];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            compeltion((int)objects.count);
        }
    }];
}

+ (void)isAppInstalledByCurrentUser:(PFObject *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:INSTALLATIONS_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:INSTALLATIONS_INSTALLED_BY equalTo:[PFUser currentUser]];
    [query whereKey:INSTALLATIONS_APP_INSTALLED equalTo:object];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count == 0) {
                compeltion(NO);
            } else if (objects.count > 0) {
                compeltion(YES);
            }
        }
    }];
}

+ (void)isAppFavoritedByCurrentUser:(PFObject *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:FAVORITES_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:FAVORITES_FAVORITED_BY equalTo:[PFUser currentUser]];
    [query whereKey:FAVORITES_APP_FAVORITED equalTo:object];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count == 0) {
                compeltion(NO);
            } else if (objects.count > 0) {
                compeltion(YES);
            }
        }
    }];
}

+ (void)isAppSharedByCurrentUser:(NSString *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:APP_CLASSE_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:APP_USER_POINTER equalTo:[PFUser currentUser]];
    [query whereKey:APP_ID equalTo:object];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count == 0) {
                compeltion(NO);
            } else if (objects.count > 0) {
                compeltion(YES);
            }
        }
    }];
}
+ (void)isAppExisteOnServer:(ITAppObject *)app withBlock:(iMBooleanWithoutErrorResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:CLOUD_APPS_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:CLOUD_APP_ID equalTo:app.appID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count == 0) {
                compeltion(NO);
            } else if (objects.count > 0) {
                compeltion(YES);
            }
        }
    }];
}

+ (void)isThisUser:(PFUser *)firstUser followThisUser:(PFUser *)secondUser withBlock:(iMBooleanWithArrayResultBlock)compeltion {
    
    // query follow status
    PFQuery *followQuery = [PFQuery queryWithClassName:FOLLOW_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [followQuery fromLocalDatastore];
    }
    [followQuery whereKey:FOLLOW_A_USER equalTo:firstUser];
    [followQuery whereKey:FOLLOW_IS_FOLLOWING equalTo:secondUser];
    [followQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count > 0) {
                compeltion(YES, objects);
            } else if (objects.count == 0) {
                compeltion(NO, objects);
            }
        }
    }];
    
}

+ (void)isThisUserExiste:(NSString *)user withBlock:(iMBooleanWithArrayResultBlock)compeltion {
    
    PFQuery *query2 = [PFQuery queryWithClassName:USER_CLASS_NAME];
    [query2 whereKey:USER_DEVICE_ID equalTo:user];
    [query2 setLimit:1];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil) {
             [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                 if (error != nil) {
                 } else {
                     if (succeeded) {
                     }
                     
                 }
             }];
             if (objects.count > 0) {
                 compeltion(YES, objects);
             } else if (objects.count == 0) {
                 compeltion(NO, objects);
             }
         }
     }];
    
}
+ (void)getAllPostsForUser:(PFUser *)user limit:(NSNumber *)limit skip:(NSNumber *)skip withBlock:(iMBooleanWithArrayResultBlock)compeltion {
    
    PFQuery *query = [PFQuery queryWithClassName:APP_CLASSE_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:APP_USER_POINTER equalTo:user];
    if (limit != nil) {
        [query setLimit:[limit integerValue]];
    }
    
    if (skip != nil) {
        [query setSkip:[skip integerValue]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        // // NSLog(@"******** 1: ERROR: %@", error.localizedDescription);
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
//                // // NSLog(@"******** 2: ERROR: %@", error.localizedDescription);
                if (error != nil) {
                    
                } else {
                    if (succeeded) {
                        compeltion(YES, objects);
                    }
                    
                }
            }];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            compeltion(NO, nil);
        }
    }];
    
}

+ (void)getAllPostsForUser:(PFUser *)user withID:(NSString *)postID andSection:(NSString *)sectionName limit:(NSNumber *)limit skip:(NSNumber *)skip withBlock:(iMBooleanWithArrayResultBlock)compeltion {
    
    PFQuery *query = [PFQuery queryWithClassName:APP_CLASSE_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:APP_USER_POINTER equalTo:user];
    [query whereKey:APP_ID equalTo:postID];
    [query whereKey:APP_SECTION_ID equalTo:sectionName];
    if (limit != nil) {
        [query setLimit:[limit integerValue]];
    }
    
    if (skip != nil) {
        [query setSkip:[skip integerValue]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    
                } else {
                    if (succeeded) {
                        compeltion(YES, objects);
                    }
                    
                }
            }];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            compeltion(NO, nil);
        }
    }];
    
}

+ (void)getAllPostsForUserFollowers:(PFUser *)user limit:(NSNumber *)limit skip:(NSNumber *)skip withBlock:(iMBooleanWithArrayResultBlock)compeltion {
    
    PFQuery *query = [PFQuery queryWithClassName:FOLLOW_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:FOLLOW_A_USER equalTo:user];
    
    if (limit != nil) {
        [query setLimit:[limit integerValue]];
    }
    
    if (skip != nil) {
        [query setSkip:[skip integerValue]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            // check if you already following somone
            if (objects.count > 0) {
                for (int i = 0; i < objects.count; i++) {
                    PFObject *followClass = [PFObject objectWithClassName:FOLLOW_CLASS_NAME];
                    followClass = objects[i];
                    PFUser *userPointer = [followClass objectForKey:FOLLOW_IS_FOLLOWING];
                    do {
                        @try {
                            [userPointer fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                PFQuery *query = [PFQuery queryWithClassName:APP_CLASSE_NAME];
                                if ([[CACheckConnection sharedManager] isUnreachable]) {
                                    [query fromLocalDatastore];
                                }
                                [query whereKey:APP_USER_POINTER equalTo:userPointer];
                                [query orderByDescending:@"createdAt"];
                                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                    if (error == nil) {
                                        [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                                            if (error != nil) {
                                                
                                            } else {
                                                if (succeeded) {
                                                    
                                                    compeltion(YES, objects);
                                                }
                                                
                                            }
                                        }];
                                    } else {
                                        compeltion(NO, nil);
                                    }
                                }];
                            }];
                        } @catch (NSException *e) {}
                    } while (userPointer == nil);
                }
            } else {
                compeltion(NO, nil);
                // you don't follow anyone
            }
        } else {
            compeltion(NO, nil);
        }
    }];
    
}

+ (void)getActivitiesForUser:(PFUser *)user withBlock:(iMBooleanWithArrayResultBlock)compeltion {
    
    PFQuery *activitiesQuery = [PFQuery queryWithClassName:ACTIVITY_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [activitiesQuery fromLocalDatastore];
    }
    [activitiesQuery whereKey:ACTIVITY_CURRENT_USER equalTo:user];
    [activitiesQuery orderByDescending:@"createdAt"];
    [activitiesQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    
                } else {
                    if (succeeded) {
                        
                    }
                    
                }
            }];
            if (objects.count > 0) {
                compeltion(YES, objects);
            } else if (objects.count == 0){
                compeltion(NO, nil);
            }
        } else {
            compeltion(NO, nil);
        }
    }];
    
}

+ (void)getAllCustomAppsForCat:(NSString *)cat withBlock:(iMBooleanWithArrayErrorResultBlock)compeltion {
    PFQuery *customAppsQuery = [PFQuery queryWithClassName:[NSString stringWithFormat:@"CustomApps_%@", cat]];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [customAppsQuery fromLocalDatastore];
    }
    [customAppsQuery orderByDescending:@"updatedAt"];
    [customAppsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    
                } else {
                    if (succeeded) {
                        
                    }
                    
                }
            }];
            if (objects.count > 0) {
                compeltion(YES, objects, error);
            } else if (objects.count == 0){
                compeltion(NO, nil, error);
            }
        } else {
            compeltion(NO, nil, error);
        }
    }];
}
+ (void)saveApp:(ITAppObject *)appObject toDatabaseWithBlock:(iMBooleanResultBlock)completion {
    PFObject *appInDb = [PFObject objectWithClassName:APP_DB_CLASSE_NAME];
    PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_CLASSE_NAME];
    [queryAppsDB whereKey:APP_DB_ID equalTo:[appObject.appID lowercaseString]];
    [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count == 0) {
                appInDb[APP_DB_ID] = [appObject.appID lowercaseString];
                appInDb[APP_DB_NAME_STRING] = appObject.appName;
                appInDb[APP_DB_ICON] = [NSString stringWithFormat:@"%@", appObject.appIcon];
                appInDb[APP_DB_INFO_DICT] = appObject.appInfo;
                
                PFACL *acl = [PFACL ACL];
                [acl setPublicReadAccess:YES];
                [acl setPublicWriteAccess:YES];
                
                [appInDb setACL:acl];
                [appInDb saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error == nil) {
                        completion(YES, error);
                    } else {
                        completion(NO, error);
                    }
                }];
            } else {
                completion(NO, error);
            }
        } else {
            completion(NO, error);
        }
    }];
}

+ (void)saveAppVersion:(NSString *)appVersion forAppID:(NSString *)appID withURLString:(NSString *)downloadUrlString withBlock:(iMBooleanResultBlock)completion {
    
    PFObject *appInDb = [PFObject objectWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
    PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
    [queryAppsDB whereKey:APP_DB_VERSIONS_APP_ID equalTo:[appID lowercaseString]];
//    [queryAppsDB whereKey:APP_DB_VERSIONS_VERSION_STRING equalTo:[appVersion lowercaseString]];
    [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count == 0) {
                appInDb[APP_DB_VERSIONS_APP_ID] = [NSString stringWithFormat:@"%@", [appID lowercaseString]];
                appInDb[APP_DB_VERSIONS_URL_LOWERCASE] = [NSString stringWithFormat:@"%@", [downloadUrlString lowercaseString]];
                appInDb[APP_DB_VERSIONS_VERSION_STRING] = [NSString stringWithFormat:@"%@", [appVersion lowercaseString]];
                
                PFACL *acl = [PFACL ACL];
                [acl setPublicReadAccess:YES];
                [acl setPublicWriteAccess:YES];
                
                [appInDb setACL:acl];
                [appInDb saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error == nil) {
                        completion(YES, error);
                    } else {
                        completion(NO, error);
                    }
                }];
            } else {
                completion(NO, nil);
            }
        } else {
            completion(NO, error);
        }
    }];
}

+ (void)getLinkFromAppID:(NSString *)appID andVersion:(NSString *)appVersion withBlock:(iMObjectBooleanResultBlock)completion {
    PFQuery *queryAppsDB = [PFQuery queryWithClassName:APP_DB_VERSIONS_CLASSE_NAME];
    [queryAppsDB whereKey:APP_DB_VERSIONS_APP_ID equalTo:[appID lowercaseString]];
    [queryAppsDB whereKey:APP_DB_VERSIONS_VERSION_STRING equalTo:[appVersion lowercaseString]];
    [queryAppsDB findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                PFObject *currentApp = [objects objectAtIndex:0];
                completion(YES, error, currentApp[APP_DB_VERSIONS_URL_LOWERCASE]);
            } else {
                completion(NO, error, nil);
            }
        } else {
            completion(NO, error, nil);
        }
    }];
}
+ (void)removeAllManagedAppsForUser:(PFUser *)user {
    PFQuery *appManagerQuery = [PFQuery queryWithClassName:USER_APP_MANAGER_CLASS_NAME];
    [appManagerQuery whereKey:USER_APP_MANAGER_USER_POINTER equalTo:user];
    [appManagerQuery orderByDescending:@"createdAt"];
    [appManagerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                for (PFObject *managedApp in objects) {
                    [managedApp deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                    }];
                }
            }
        } else {
            [ITHelper showErrorMessageFrom:nil withError:error];
        }
    }];
}
+ (void)removeAllRequestedAppsForUser:(PFUser *)user {
    PFQuery *appManagerQuery = [PFQuery queryWithClassName:USER_APP_MANAGER_CLASS_NAME];
    [appManagerQuery whereKey:USER_APP_MANAGER_USER_POINTER equalTo:user];
    [appManagerQuery orderByDescending:@"createdAt"];
    [appManagerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                for (PFObject *managedApp in objects) {
                    [managedApp deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                    }];
                }
            }
        } else {
            [ITHelper showErrorMessageFrom:nil withError:error];
        }
    }];
}
+ (void)getAllManagedAppsForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)completion {
    PFQuery *appManagerQuery = [PFQuery queryWithClassName:USER_APP_MANAGER_CLASS_NAME];
    [appManagerQuery whereKey:USER_APP_MANAGER_USER_POINTER equalTo:user];
    [appManagerQuery orderByAscending:USER_APP_MANAGER_APP_NAME];
    [appManagerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                completion(YES, objects, nil);
            } else if (objects.count == 0){
                completion(YES, objects, error);
            }
        } else {
            completion(NO, nil, error);
        }
    }];
}
+ (void)getAllRequestedAppsForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)completion {
    PFQuery *appManagerQuery = [PFQuery queryWithClassName:USER_APP_Reuqested_CLASS_NAME];
    [appManagerQuery whereKey:USER_APP_MANAGER_USER_POINTER equalTo:user];
    [appManagerQuery orderByAscending:USER_APP_MANAGER_APP_NAME];
    [appManagerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                completion(YES, objects, nil);
            } else if (objects.count == 0){
                completion(YES, objects, error);
            }
        } else {
            completion(NO, nil, error);
        }
    }];
}
+ (void)getAllTranslatorsWithBlock:(iMBooleanWithArrayErrorResultBlock)completion {
    PFQuery *appManagerQuery = [PFQuery queryWithClassName:TRANSLATORS_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [appManagerQuery fromLocalDatastore];
    }
    [appManagerQuery orderByAscending:TRANSLATORS_NAME];
    [appManagerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count > 0) {
                completion(YES, objects, nil);
            } else if (objects.count == 0){
                completion(YES, objects, error);
            }
        } else {
            completion(NO, nil, error);
        }
    }];
    
}

+ (void)isTeamUSER:(PFUser *)user withBlock:(iMBooleanWithoutErrorResultBlock)compeltion {
    PFQuery *query = [PFQuery queryWithClassName:TEAM_USERS_CLASS_NAME];
    if ([[CACheckConnection sharedManager] isUnreachable]) {
        [query fromLocalDatastore];
    }
    [query whereKey:TEAM_USERS_USER_POINTER equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                } else {
                    if (succeeded) {
                    }
                    
                }
            }];
            if (objects.count == 0) {
                compeltion(NO);
            } else if (objects.count > 0) {
                compeltion(YES);
            }
        }
    }];
}

+ (void)saveManagedApp:(ITAppObject *)app forUser:(PFUser *)user andAccountType:(NSString *)accountType withBlock:(iMBooleanWithArrayErrorResultBlock)completion {

}
+ (void)requestEmailConfirmationForUser:(PFUser *)user fromTarget:(id)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME message:NSLocalizedString(@"Confirm your email address ( to verify )", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *emailString = alert.textFields[0].text;
        if ([ITHelper validateEmailAddress:emailString]) {
            [user setEmail:emailString];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    [ITHelper showErrorMessageFrom:target withError:error];
                } else {
                    if (succeeded) {
                        [KVNProgress showSuccessWithStatus:NSLocalizedString(@"email sent :)", @"")];
                    }
                }
            }];
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"adresse email incorrect !!", @"")];
        }
        
    }];
    
    [alert addAction:confirmAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"email address", @"");
        textField.secureTextEntry = NO;
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [target presentViewController:alert animated:YES completion:^{
            
        }];
    });
}

+ (void)requestResetPasswordForUser:(PFUser *)user fromTarget:(id)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME message:NSLocalizedString(@"Forgot password?", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *emailString = alert.textFields[0].text;
        if ([ITHelper validateEmailAddress:emailString]) {
            
            [PFUser requestPasswordResetForEmailInBackground:emailString block:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    [ITHelper showErrorMessageFrom:target withError:error];
                } else {
                    if (succeeded) {
                        [KVNProgress showSuccessWithStatus:NSLocalizedString(@"email sent :)", @"")];
                    }
                }
            }];
            
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"adresse email incorrect !!", @"")];
        }
        
    }];
    
    [alert addAction:confirmAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"email address", @"");
        textField.secureTextEntry = NO;
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [target presentViewController:alert animated:YES completion:^{
            
        }];
    });
}

+ (BOOL) array:(NSArray *)array containsPFObjectById:(PFObject *)object
{
    //Check if the object's objectId matches the objectId of any member of the array.
    for (PFObject *arrayObject in array){
        if ([[arrayObject objectId] isEqual:[object objectId]] && [arrayObject[APP_ID] isEqual:object[APP_ID]]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)sha1:(NSString *)string {
    if (string != nil)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    }
    return nil;
}

+ (NSString *)md5:(NSString *)string {
    if (string != nil)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(data.bytes, (CC_LONG)data.length, digest);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    }
    return nil;
}

+ (NSData *)AES128EncryptData:(NSData *)data WithKey:(NSString *)key
{
    // ‘key’ should be 16 bytes for AES128
    char keyPtr[kCCKeySizeAES128 + 1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof( keyPtr ) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That’s why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt( kCCEncrypt, kCCAlgorithmAES128, kCCOptionECBMode | kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted );
    if( cryptStatus == kCCSuccess )
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free( buffer ); //free the buffer
    return nil;
}

@end

#pragma clang diagnostic pop
