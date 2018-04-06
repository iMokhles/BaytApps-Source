//
//  ITHelper.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITHelper.h"
#import "ITConstants.h"
#import "ITAppObject.h"
#import "TransNSString.h"
#import "BAHelper.h"
#import "ITAppHoster.h"
#import "ITAppPromoted.h"
#import "ITAppDescrip.h"
#import "ECSlidingViewController.h"
//#import "LUKeychainAccess.h"
//#import "UICKeyChainStore.h"

#import "ITServerHelper.h"
#import "NavigationController.h"
//#import "ProgressViewController.h"
#import "RecentView.h"
//#import "JBWebViewController.h"
//#import "HYScrollTabBarController.h"
#import "BALoginViewController.h"
//#import "SettingsViewController.h"
#import "BALaunchViewController.h"
//#import "RSA.h"
#import "CACheckConnection.h"
#import "BALaunchViewController.h"
#import "JGActionSheet.h"
#import "BAColorsHelper.h"
#import "JGProgressHUD.h"
#import "Alert.h"
#import "UIColor+BFKit.h"
#import "BANoInternetViewController.h"
#import "converter.h"
#import "BARenewViewController.h"


#define NONCELENGHT 32
#define kXLength 299
#define MB (1024*1024)
#define GB (MB*1024)

NSString* const RESPONSE_TIMEOUT = @"responseTimeout";
static UIView *hudView;
static UIActivityIndicatorView *indicatorView;
static UIToolbar* bgToolbar;
static UIVisualEffectView *visualEffectView;
NSMutableArray *itDownloads;

static unsigned long long profileSize = 12322;
static unsigned long long profileSize2 = 12322;
static unsigned long long profileSize3 = 12322;
static unsigned long long profileSize4 = 12322;
static unsigned long long profileSize5 = 12322;
static unsigned long long profileSize6 = 12322;

@implementation UIColor (GridMessages)

+ (CGFloat)gm_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    
    return hexComponent / 255.0;
}

+ (UIColor *)gm_hex:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch([colorString length])
    {
        case 3: // #RGB
            alpha = 1.0f;
            red = [self gm_colorComponentFrom:colorString start:0 length:1];
            green = [self gm_colorComponentFrom:colorString start:1 length:1];
            blue = [self gm_colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self gm_colorComponentFrom:colorString start:0 length:1];
            red = [self gm_colorComponentFrom:colorString start:1 length:1];
            green = [self gm_colorComponentFrom:colorString start:2 length:1];
            blue = [self gm_colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [self gm_colorComponentFrom:colorString start:0 length:2];
            green = [self gm_colorComponentFrom:colorString start:2 length:2];
            blue = [self gm_colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self gm_colorComponentFrom:colorString start:0 length:2];
            red = [self gm_colorComponentFrom:colorString start:2 length:2];
            green = [self gm_colorComponentFrom:colorString start:4 length:2];
            blue = [self gm_colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            return nil;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end

@implementation UIImage (GridMessages)
- (UIImage *)gm_imageTintedWithColor:(UIColor *)color{
    // This method is designed for use with template images, i.e. solid-coloured mask-like images.
    return [self gm_imageTintedWithColor:color fraction:0.0]; // default to a fully tinted mask of the image.
}
- (UIImage *)gm_imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction
{
    if (color) {
        // Construct new image the same size as this one.
        UIImage *image;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
            UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f); // 0.f for scale means "scale for device's main screen".
        } else {
            UIGraphicsBeginImageContext([self size]);
        }
#else
        UIGraphicsBeginImageContext([self size]);
#endif
        CGRect rect = CGRectZero;
        rect.size = [self size];
        
        // c.o.mposite tint color at its own opacity.
        [color set];
        UIRectFill(rect);
        
        // Mask tint color-swatch to this image's opaque mask.
        // We want behaviour like NSc.o.mpositeDestinationIn on Mac OS X.
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
        
        // Finally, c.o.mposite this image over the tinted mask at desired opacity.
        if (fraction > 0.0) {
            // We want behaviour like NSc.o.mpositeSourceOver on Mac OS X.
            [self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return self;
}
@end

@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (float)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)searchSet { return NSMakeRange(0, 0); }
@end

@implementation ITHelper

+(ITHelper *)sharedInstance
{
    static ITHelper *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(instance ==nil){
            instance = [[ITHelper alloc] init];
        }
    });
    
    return instance;
}

- (void)getMethodWithURL:(NSString *)urlString withCompletion:(void (^)(NSData *data, NSError *error))completion {
    
    NSString *methodURL = [NSString stringWithFormat:@"%@",urlString];
    NSString *urlEscaped = [methodURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlEscaped];
    NSString *method = @"GET";
    NSMutableURLRequest * request = nil;
    
    // initialize request
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    [request setTimeoutInterval:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
    NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
    [headersDictionary setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [request setAllHTTPHeaderFields:headersDictionary];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        completion(data, connectionError);
    }];
}


- (void)newGetMethodWithURL:(NSString *)urlString
            completionBlock:(URLConnectionCompletionBlock)completionBlock
                 errorBlock:(URLConnectioErrorBlock)errorBlock
        uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
      downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock {
    NSString *methodURL = [NSString stringWithFormat:@"%@",urlString];
    NSString *urlEscaped = [methodURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlEscaped];
    NSString *method = @"GET";
    NSMutableURLRequest * request = nil;
    
    // initialize request
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    [request setTimeoutInterval:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
    NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
    [headersDictionary setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [request setAllHTTPHeaderFields:headersDictionary];
    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response) {
        completionBlock(data, response);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
//        // NSLog(@"**** errorBlock **** %@", error.localizedDescription);
    } uploadPorgressBlock:^(float progress) {
        uploadBlock(progress);
//        // NSLog(@"**** uploadPorgressBlock **** %f", progress);
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

- (void)linkNewDeviceWithEmail:(NSString *)email andScheme:(NSString *)scheme {
    NSString *customURLString = [NSString stringWithFormat:@"%@?action=link&type=new&scheme=%@&email=%@&redirect=0", kappdbAPIURL, scheme, email];
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSDictionary *itemsArray = [userInfo objectForKey:@"data"];
                [[NSUserDefaults standardUserDefaults] setObject:itemsArray[@"link_token"] forKey:@"link_token"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@baytapps", itemsArray[@"profile_service"]]]];
            }
        }
    }];
}

- (void)getAppInfoFromItunes:(NSString *)appTrackID withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
    [self getMethodWithURL:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", appTrackID] withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                //                // NSLog(@"***** %@", appTrackID);
                NSArray *itemsArray = [userInfo objectForKey:@"results"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    //                    // NSLog(@"***** %@", appDict);
                    ITAppDescrip *app = [ITAppDescrip new];
                    
                    NSMutableArray *langArray = [NSMutableArray new];
                    for (NSString *lang in appDict[@"languageCodesISO2A"]) {
                        NSString *langString = [[ITHelper currentLocalInEn] displayNameForKey:NSLocaleIdentifier value:lang.lowercaseString];
                        [langArray addObject:langString];
                    }
                    NSString *allLanguages = [langArray componentsJoinedByString:@", "];
                    app.languagesSupported = allLanguages;
                    NSString *allDevices = [appDict[@"supportedDevices"] componentsJoinedByString:@", "];
                    app.devicesSupported = allDevices;
                    app.appInfo = appDict;
                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
                    app.averageUserRating = [appDict[@"averageUserRating"] floatValue];
                    app.artistName = appDict[@"artistName"];
                    app.artwork512URL = appDict[@"artworkUrl512"];
                    app.artwork60URL = appDict[@"artworkUrl60"];
                    app.advisoryRating = appDict[@"contentAdvisoryRating"];
                    app.descriptionString = appDict[@"description"];
                    app.isSupportAppleWatch = [appDict[@"isVppDeviceBasedLicensingEnabled"] boolValue];
                    app.primaryGenreName = appDict[@"primaryGenreName"];
                    app.changelogString = appDict[@"releaseNotes"];
                    
//                    // NSLog(@"****** \n\n\n\n %@", appDict);
                    
                    if ([BAHelper isIPAD]) {
                        if ([(NSArray *)appDict[@"ipadScreenshotUrls"] count] > 0 ) {
                            app.screenshotUrls = appDict[@"ipadScreenshotUrls"];
                        } else {
                            app.screenshotUrls = appDict[@"screenshotUrls"];
                        }
                    } else {
                        if ([(NSArray *)appDict[@"screenshotUrls"] count] > 0 ) {
                            app.screenshotUrls = appDict[@"screenshotUrls"];
                        } else {
                            app.screenshotUrls = appDict[@"ipadScreenshotUrls"];
                        }
                    }
                    
                    app.developerName = appDict[@"sellerName"];
                    app.appName = appDict[@"trackName"];
                    app.appVersion = appDict[@"version"];
                    [appsArray addObject:app];
                }
                completion([appsArray copy], nil);
            } else {
                completion(nil, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}
- (void)postMethodWithURL:(NSString *)urlString postString:(NSString *)postString withCompletion:(void (^)(NSData *data, NSError *error))completion {
    NSString *post = postString;
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        completion(data, connectionError);
    }];
    
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
        if (!ok) { // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return;
        }
    }
    
    NSDictionary *profile = mobileProvision;
    NSString *teamID = profile[@"UUID"];
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
    
   //    NSString *username = [PFUser currentUser].username;
    //UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    //NSString *password = [key stringForKey:ENCRYPT_TEXT_KEY()];
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
    
    NSString *customURLString_1 = [NSString stringWithFormat:
                                 @"usertoken  : %@  "
                                 @"&downloadLink  : %@  "
                                 @"&deviceId  : %@  "
                                 @"&appID  : %@  "
                                 @"&appVer  : %@  "
                                 @"&linkType  : %@  "
                                 @"&accType  : %@  "
                                 @"&dupliNumber  : %@  "
                                 @"&appName  : %@  "
                                 @"&appTrackID  : %@  "
                                 @"&devicetoken  : %@  "
                                 @"&signature  : %@  "
                                 @"&ordernumber  : %@  "
                                 @"&site  : %@"
                                 @"&user_devicetoken  : %@  "
                                 @"&user_deviceauth  : %@  ",
                                 
                                 
                                  [PFUser currentUser].sessionToken,
                                  appLink,
                                 
                                             [PFUser currentUser][USER_DEVICE_PLAYER_ID],
                                  app.appID,
                                  appVersion,
                                  host,
                                 
                                             accountType,
                                  [NSString stringWithFormat:@"%li",(long)dupliNumber],
                                  [ITHelper replaceSpaceToUnderscoreIfNeed:appNameString],
                                  app.appTrackID,
                                  pushToken,
                                  signature,
                                  [NSString stringWithFormat:@"%d", 2200],
                                  verifyServer,
                                  pushToken,
                                  pushToken];
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/index.php", kCloudAPI];
    [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@?%@",apiURL,customURLString]];
    NSLog(@"-----------------------------");
    NSLog(@"apiURL:::%@", apiURL);
    NSLog(@"-----------------------------");
    NSLog(@"posting:::%@ %@",apiURL, customURLString_1);
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
    
//    if ([DecryptText(@"", [key stringForKey:@"user_devicetoken"]) isEqualToString:[NSString stringWithFormat:@"%@/%@_%@", DecryptText(@"", [key stringForKey:@"it_3"]), DecryptText(@"", [key stringForKey:@"it_1"]), DecryptText(@"", [key stringForKey:@"it_4"])]]) {
//        
//        NSString *apiURL = [NSString stringWithFormat:@"%@/index.php", kCloudAPI];
//        [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@?%@",apiURL,customURLString]];
//        
//        [self newPostMethodWithURL:apiURL postString:customURLString
//                   completionBlock:^(NSData *data, NSURLResponse *response) {
//                       completionBlock(data, response);
//                   } errorBlock:^(NSError *error) {
//                       errorBlock(error);
//                   } uploadPorgressBlock:^(float progress) {
//                       uploadBlock(progress);
//                   } downloadProgressBlock:^(float progress, NSData *data) {
//                       downloadBlock(progress, data);
//                   }];
//    } else {
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isFirstRun"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [key removeAllItems];
//        [ITHelper showLaunchOrMainView:NO];
//    }
    
}
- (void)downloadIPAFileForRequestApp:(NSString *)app
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
        if (!ok) { // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return;
        }
    }
    
    NSDictionary *profile = mobileProvision;
    NSString *teamID = profile[@"UUID"];
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
    
    //    NSString *username = [PFUser currentUser].username;
    //UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    //NSString *password = [key stringForKey:ENCRYPT_TEXT_KEY()];
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
                                 EncryptText(@"", @"xx.xx.xx"),
                                 EncryptText(@"", appVersion),
                                 EncryptText(@"", host),
                                 EncryptText(@"",
                                             accountType),
                                 EncryptText(@"", [NSString stringWithFormat:@"%li",(long)dupliNumber]),
                                 EncryptText(@"",  @"xx.xx.xx"),
                                 EncryptText(@"",  @"xx.xx.xx"),
                                 EncryptText(@"", pushToken),
                                 EncryptText(@"", signature),
                                 EncryptText(@"", [NSString stringWithFormat:@"%d", 2200]),
                                 EncryptText(@"", verifyServer),
                                 EncryptText(@"", pushToken),
                                 EncryptText(@"", pushToken)];
    
    NSString *customURLString_1 = [NSString stringWithFormat:
                                   @"usertoken  : %@  "
                                   @"&downloadLink  : %@  "
                                   @"&deviceId  : %@  "
                                   @"&appID  : %@  "
                                   @"&appVer  : %@  "
                                   @"&linkType  : %@  "
                                   @"&accType  : %@  "
                                   @"&dupliNumber  : %@  "
                                   @"&appName  : %@  "
                                   @"&appTrackID  : %@  "
                                   @"&devicetoken  : %@  "
                                   @"&signature  : %@  "
                                   @"&ordernumber  : %@  "
                                   @"&site  : %@"
                                   @"&user_devicetoken  : %@  "
                                   @"&user_deviceauth  : %@  ",
                                   
                                   
                                   [PFUser currentUser].sessionToken,
                                   appLink,
                                   
                                   [PFUser currentUser][USER_DEVICE_PLAYER_ID],
                                   @"xx.xx.xx",
                                   appVersion,
                                   host,
                                   accountType,
                                   [NSString stringWithFormat:@"%li",(long)dupliNumber],
                                   @"xx.xx.xx",
                                   @"xx.xx.xx",
                                   pushToken,
                                   signature,
                                   [NSString stringWithFormat:@"%d", 2200],
                                   verifyServer,
                                   pushToken,
                                   pushToken];
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/index.php", kCloudAPI];
    [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@?%@",apiURL,customURLString]];
    NSLog(@"-----------------------------");
    NSLog(@"apiURL:::%@", apiURL);
    NSLog(@"-----------------------------");
    NSLog(@"posting:::%@ %@",apiURL, customURLString_1);
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
    
    //    if ([DecryptText(@"", [key stringForKey:@"user_devicetoken"]) isEqualToString:[NSString stringWithFormat:@"%@/%@_%@", DecryptText(@"", [key stringForKey:@"it_3"]), DecryptText(@"", [key stringForKey:@"it_1"]), DecryptText(@"", [key stringForKey:@"it_4"])]]) {
    //
    //        NSString *apiURL = [NSString stringWithFormat:@"%@/index.php", kCloudAPI];
    //        [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@?%@",apiURL,customURLString]];
    //
    //        [self newPostMethodWithURL:apiURL postString:customURLString
    //                   completionBlock:^(NSData *data, NSURLResponse *response) {
    //                       completionBlock(data, response);
    //                   } errorBlock:^(NSError *error) {
    //                       errorBlock(error);
    //                   } uploadPorgressBlock:^(float progress) {
    //                       uploadBlock(progress);
    //                   } downloadProgressBlock:^(float progress, NSData *data) {
    //                       downloadBlock(progress, data);
    //                   }];
    //    } else {
    //        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isFirstRun"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //        [key removeAllItems];
    //        [ITHelper showLaunchOrMainView:NO];
    //    }
    
}

//- (NSMutableArray *)allDownloadsAvailableForState:(NSString *)state {
//    NSMutableArray *downloads = [@[] mutableCopy];
//    for (NSDictionary *download in itDownloads) {
//        if ([download[@"state"] isEqualToString:state]) {
//            [downloads addObject:download];
//        }
//    }
//    return downloads;
//}

- (void)openAppURLToInstall:(NSString *)appURL {
    
}

- (void)getAllAppsForCat:(NSString *)category withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
       NSString *customURLString = [NSString stringWithFormat:@"%@?action=search&type=%@", kappdbAPIURL, category];
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSArray *itemsArray = [userInfo objectForKey:@"data"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    ITAppObject *app = [ITAppObject new];
                    app.appName = [appDict objectForKey:@"name"];
                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                        app.appIcon = [appDict objectForKey:@"image"];
                    } else {
                        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                    }
                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
                    app.appID = [appDict objectForKey:@"bundle_id"];
                    app.appVersion = [appDict objectForKey:@"version"];
                    app.appStore = [appDict objectForKey:@"store"];
                    app.appPrice = [appDict objectForKey:@"price"];
                    app.appTrackID = [appDict objectForKey:@"original_trackid"];
                    app.appInfo = appDict;
//                    // NSLog(@"******* %@", appDict);
                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
                        app.appSection = @"cydia";
                    } else {
                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
                            app.appSection = @"ios";
                        } else {
                            app.appSection = [appDict objectForKey:@"original_section"];
                        }
                        
                    }
                    
                    app.appScreenshots = [appDict objectForKey:@"screenshots"];
                    if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
                        [appsArray addObject:app];
                    }
                    
                }
                completion([appsArray copy], nil);
            } else {
                completion(nil, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}

- (void)getAllAppsForOrder:(NSString *)order page:(NSUInteger)pageNumber andCat:(NSString *)category withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
    NSString *customURLString = [NSString stringWithFormat:@"%@?action=search&type=%@&order=%@&page=%lu", kappdbAPIURL, category, order, (unsigned long)pageNumber];
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSArray *itemsArray = [userInfo objectForKey:@"data"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    ITAppObject *app = [ITAppObject new];
                    app.appName = [appDict objectForKey:@"name"];
                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                        app.appIcon = [appDict objectForKey:@"image"];
                    } else {
                        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                    }
                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
                    app.appID = [appDict objectForKey:@"bundle_id"];
                    app.appVersion = [appDict objectForKey:@"version"];
                    app.appStore = [appDict objectForKey:@"store"];
                    app.appPrice = [appDict objectForKey:@"price"];
                    app.appTrackID = [appDict objectForKey:@"original_trackid"];
                    app.appInfo = appDict;
                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
                        app.appSection = @"cydia";
                    } else {
                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
                            app.appSection = @"ios";
                        } else {
                            app.appSection = [appDict objectForKey:@"original_section"];
                        }
                        
                    }
                    
                    app.appScreenshots = [appDict objectForKey:@"screenshots"];
                    if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
                        [appsArray addObject:app];
                    }
                }
                completion([appsArray copy], nil);
            } else {
                completion(nil, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}

- (void)getAllAppsForCat:(NSString *)category page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
       NSString *customURLString = [NSString stringWithFormat:@"%@?action=search&type=%@&page=%lu", kappdbAPIURL, category, (unsigned long)pageNumber];
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSArray *itemsArray = [userInfo objectForKey:@"data"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    ITAppObject *app = [ITAppObject new];
                    app.appName = [appDict objectForKey:@"name"];
                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                        app.appIcon = [appDict objectForKey:@"image"];
                    } else {
                        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                    }
                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
                    app.appID = [appDict objectForKey:@"bundle_id"];
                    app.appVersion = [appDict objectForKey:@"version"];
                    app.appStore = [appDict objectForKey:@"store"];
                    app.appPrice = [appDict objectForKey:@"price"];
                    app.appTrackID = [appDict objectForKey:@"original_trackid"];
                    app.appInfo = appDict;
                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
                        app.appSection = @"cydia";
                    } else {
                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
                            app.appSection = @"ios";
                        } else {
                            app.appSection = [appDict objectForKey:@"original_section"];
                        }
                        
                    }
                    
                    app.appScreenshots = [appDict objectForKey:@"screenshots"];
                    if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
                        [appsArray addObject:app];
                    }
                }
                completion([appsArray copy], nil);
            } else {
                completion(nil, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}


- (void)getAllAppsForCydiaCat:(NSString *)category page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
    PFQuery *query2 = [PFQuery queryWithClassName:TWEAK_APP_DB_CLASSE_NAME];
    [query2 setLimit:25];
    [query2 setSkip:pageNumber * 25];
    [query2 addDescendingOrder:@"updatedAt"];

    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil) {
             if (objects.count > 0) {

                 NSMutableArray *appsArray = [NSMutableArray new];
                 
//                 PFQuery *queryApps = [PFQuery queryWithClassName:TWEAK_APP_DB_VERSIONS_CLASSE_NAME];
//                 [queryApps whereKey:@"appID" notEqualTo:appDict[@"appID"]];
                 NSMutableArray *IdsArray = [NSMutableArray new];
                 for (PFObject *appDict in objects) {
                     
                     
                     
                     ITAppObject *app = [ITAppObject new];
                     app.appName = appDict[@"appName"];
                     if (![appDict[@"appIcon"] isKindOfClass:[NSNull class]]) {
                         app.appIcon = appDict[@"appIcon"];
                     } else {
                         app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                     }
                     app.fileSizeBytes = appDict[@"fileSizeBytes"];
                     app.appID = appDict[@"appID"];
                     app.appVersion = appDict[@"appVersion"];
                     app.appStore = appDict[@"appStore"];
                     app.appPrice = appDict[@"appPrice"];
                     app.appTrackID = appDict[@"appTrackID"];
                     app.appInfo = appDict[@"appInfo"];
                     app.appSection = appDict[@"appSection"];
                     app.appScreenshots = appDict[@"screenshots"];
                     app.appDescription= appDict[@"appDescription"];
                     app.locallink = appDict[@"installAppUrlLowercase"];

                     
                     
                     if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
                         
                         if (![IdsArray containsObject:app.appInfo[@"id"]]) {
                             [appsArray addObject:app];
                         }
                         
                     }
                     [IdsArray addObject:appDict[@"appInfo"][@"id"]];
                 }
                 completion([appsArray copy], nil);
             } else {
                 completion(nil, nil);
             }
         } else {
             completion(nil, error);
         }
     }];
    

    
}
//- (void)getAllAppsForCydiaCat:(NSString *)category page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
//    if ([[CACheckConnection sharedManager] isUnreachable]) {
//        BANoInternetViewController *launchVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"noConnectionVC"];
//        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//        
//        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionNone
//                        animations:nil
//                        completion:nil];
//        return;
//    }
//    NSString *customURLString = [NSString stringWithFormat:@"%@?action=search&type=%@&page=%lu", kappdbAPIURL, category, (unsigned long)pageNumber];
//    NSLog(@"%@", customURLString);
//    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
//        NSError *errr = nil;
//        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
//        if (errr == nil) {
//            if (userInfo) {
//                NSArray *itemsArray = [userInfo objectForKey:@"data"];
//                NSMutableArray *appsArray = [NSMutableArray new];
//                for (NSDictionary *appDict in itemsArray) {
//                    ITAppObject *app = [ITAppObject new];
//                    app.appName = [appDict objectForKey:@"name"];
//                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
//                        app.appIcon = [appDict objectForKey:@"image"];
//                    } else {
//                        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
//                    }
//                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
//                    app.appID = [appDict objectForKey:@"bundle_id"];
//                    app.appVersion = [appDict objectForKey:@"version"];
//                    app.appStore = [appDict objectForKey:@"store"];
//                    app.appPrice = [appDict objectForKey:@"price"];
//                    app.appTrackID = [appDict objectForKey:@"id"];
//                    app.appInfo = appDict;
//                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
//                        app.appSection = @"cydia";
//                    } else {
//                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
//                            app.appSection = @"ios";
//                        } else {
//                            app.appSection = [appDict objectForKey:@"original_section"];
//                        }
//                        
//                    }
//                    
//                    app.appScreenshots = [appDict objectForKey:@"screenshots"];
//                    if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
//                        [appsArray addObject:app];
//                    }
//                }
//                completion([appsArray copy], nil);
//            } else {
//                completion(nil, nil);
//            }
//        } else {
//            completion(nil, errr);
//        }
//    }];
//}

- (void)getAllLatestAppsWithCat:(NSString *)category withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
       NSString *customURLString = [NSString stringWithFormat:@"%@?action=search&type=%@", kappdbAPIURL, category];
    
    NSLog(@"%@", customURLString);
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSArray *itemsArray = [userInfo objectForKey:@"data"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    ITAppObject *app = [ITAppObject new];
                    app.appName = [appDict objectForKey:@"name"];
                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                        app.appIcon = [appDict objectForKey:@"image"];
                    } else {
                        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                    }
                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
                    app.appID = [appDict objectForKey:@"bundle_id"];
                    app.appVersion = [appDict objectForKey:@"version"];
                    app.appStore = [appDict objectForKey:@"store"];
                    app.appPrice = [appDict objectForKey:@"price"];
                    app.appTrackID = [appDict objectForKey:@"original_trackid"];
                    app.appInfo = appDict;
                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
                        app.appSection = @"cydia";
                    } else {
                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
                            app.appSection = @"ios";
                        } else {
                            app.appSection = [appDict objectForKey:@"original_section"];
                        }
                        
                    }
                    
                    app.appScreenshots = [appDict objectForKey:@"screenshots"];
                    if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
                        [appsArray addObject:app];
                    }
                }
                completion([appsArray copy], nil);
            } else {
                completion(nil, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}

- (void)searchTweakedAppsWithKeyword:(NSString *)keyword page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
    
    PFQuery *query2 = [PFQuery queryWithClassName:TWEAK_APP_DB_CLASSE_NAME];
    
    [query2 whereKeyExists:@"appName"];
    [query2 whereKey:@"appName" matchesRegex:keyword modifiers:@"i"];
//    [query2 whereKey:@"appName" containsString:keyword];
//    [query2 setLimit:25];
//    [query2 setSkip:pageNumber * 25];
    [query2 addDescendingOrder:@"createdAt"];
    
//    NSLog(@"******* getAllAppsForCydiaCat: %li", pageNumber);
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil) {
             if (objects.count > 0) {
                 
                 NSMutableArray *appsArray = [NSMutableArray new];
                 NSMutableArray *IdsArray = [NSMutableArray new];
                 for (PFObject *appDict in objects) {
                     ITAppObject *app = [ITAppObject new];
                     app.appName = appDict[@"appName"];
                     if (![appDict[@"appIcon"] isKindOfClass:[NSNull class]]) {
                         app.appIcon = appDict[@"appIcon"];
                     } else {
                         app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                     }
                     app.fileSizeBytes = appDict[@"fileSizeBytes"];
                     app.appID = appDict[@"appID"];
                     app.appVersion = appDict[@"appVersion"];
                     app.appStore = appDict[@"appStore"];
                     app.appPrice = appDict[@"appPrice"];
                     app.appTrackID = appDict[@"appTrackID"];
                     app.appInfo = appDict[@"appInfo"];
                     app.appSection = appDict[@"appSection"];
                     app.appScreenshots = appDict[@"screenshots"];
                     app.appDescription= appDict[@"appDescription"];
                     app.locallink = appDict[@"installAppUrlLowercase"];
                     
                     
                     
                     if (![app.appName containsString:@"appdb"] /* && [app.appPrice isEqualToString:@"Free"] */) {
                         
                         if (![IdsArray containsObject:app.appInfo[@"id"]]) {
                             [appsArray addObject:app];
                         }
                         
                     }
                     [IdsArray addObject:appDict[@"appInfo"][@"id"]];
                 }
                 completion([appsArray copy], nil);
             } else {
                 completion(nil, nil);
             }
         } else {
             completion(nil, error);
         }
     }];
}
- (void)searchWithKeyword:(NSString *)keyword page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion {
    
    
       NSString *customURLString = [NSString stringWithFormat:@"%@?action=search&type=ios&q=%@&page=%lu", kappdbAPIURL, keyword, (unsigned long)pageNumber];
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSArray *itemsArray = [userInfo objectForKey:@"data"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    ITAppObject *app = [ITAppObject new];
                    app.appName = [appDict objectForKey:@"name"];
                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                        app.appIcon = [appDict objectForKey:@"image"];
                    } else {
                        app.appIcon = @"http://www.imokhles.com/Icon_Template.png";
                    }
                    app.fileSizeBytes = [NSString stringWithFormat:@"%@", appDict[@"fileSizeBytes"]];
                    app.appID = [appDict objectForKey:@"bundle_id"];
                    app.appVersion = [appDict objectForKey:@"version"];
                    app.appStore = [appDict objectForKey:@"store"];
                    app.appPrice = [appDict objectForKey:@"price"];
                    app.appTrackID = [appDict objectForKey:@"original_trackid"];
                    app.appInfo = appDict;
                    if ([[appDict objectForKey:@"original_section"] isKindOfClass:[NSNull class]]) {
                        app.appSection = @"cydia";
                    } else {
                        if ([[appDict objectForKey:@"original_section"] length] == 0) {
                            app.appSection = @"ios";
                        } else {
                            app.appSection = [appDict objectForKey:@"original_section"];
                        }
                        
                    }
                    
                    app.appScreenshots = [appDict objectForKey:@"screenshots"];
                    if (![app.appName containsString:@"appdb"]) {
                        [appsArray addObject:app];
                    }
                }
                completion([appsArray copy], nil);
            } else {
                completion(nil, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}

- (void)getAllPromotedContentsWithCompletion:(void (^)(NSArray *allApps, NSError *error))completion  {
       NSString *customURLString = [NSString stringWithFormat:@"%@?action=promotions", kappdbAPIURL];
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSArray *itemsArray = [userInfo objectForKey:@"data"];
                NSMutableArray *appsArray = [NSMutableArray new];
                for (NSDictionary *appDict in itemsArray) {
                    ITAppPromoted *app = [ITAppPromoted new];
                    app.name = [appDict objectForKey:@"name"];
                    if (![[appDict objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                        app.imageUrl = [appDict objectForKey:@"image"];
                    } else {
                        app.imageUrl = @"http://www.imokhles.com/Icon_Template.png";
                    }
                    app.lead = [appDict objectForKey:@"lead"];
                    app.type = [appDict objectForKey:@"type"];
                    app.trackID = [appDict objectForKey:@"1900000042"];
                    app.mainID = [appDict objectForKey:@"id"];
                    app.store = [appDict objectForKey:@"store"];
                    if (![app.name containsString:@"appdb"]) {
                        [appsArray addObject:app];
                    }
                }
                completion([appsArray copy], nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}

- (void)getAllDownloadLinksForApp:(NSString *)appTrackingID andSection:(NSString *)appSection withCompletion:(void (^)(NSDictionary *allHosts, NSError *error))completion {
       NSString *customURLString = [NSString stringWithFormat:@"%@?action=get_links&type=%@&trackids=%@", kappdbAPIURL, appSection, appTrackingID];
    NSLog(@"hosting url::%@",customURLString);
    
    [self getMethodWithURL:customURLString withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                //                // NSLog(@"***** %@", userInfo);
                NSDictionary *dataDict = [userInfo objectForKey:@"data"];
                NSDictionary *appDict = [dataDict objectForKey:appTrackingID];
                
                completion(appDict, nil);
            }
        } else {
            completion(nil, errr);
        }
    }];
}

- (void)getCustomerInfoWithEmail:(NSString *)emailString isTotoaShop:(BOOL)totoashop withCompletion:(void (^)(NSDictionary *dict, NSError *error))completion {
       NSString *wcURL = [NSString stringWithFormat:@"%@/customers/email/%@?consumer_key=%@&consumer_secret=%@&oauth_consumer_key=%@",kAPIURL, emailString, kConsumerKey, kConsumerSecret, kConsumerKey];
    if (totoashop) {
        wcURL = [NSString stringWithFormat:@"%@/customers/email/%@?consumer_key=%@&consumer_secret=%@&oauth_consumer_key=%@",kAPIURLTotoa, emailString, kConsumerKey, kConsumerSecret, kConsumerKey];
    }
    [self getMethodWithURL:wcURL withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                completion(userInfo, error);
            }
        }
    }];
}

- (void)getCustomerOrderWithNumber:(NSString *)ordersNumber isTotoaShop:(BOOL)totoashop withCompletion:(void (^)(NSDictionary *dict, NSError *error))completion {
       NSString *wcURL = [NSString stringWithFormat:@"%@/orders/%@?consumer_key=%@&consumer_secret=%@&oauth_consumer_key=%@&filter[meta]=true",kAPIURL, ordersNumber, kConsumerKey, kConsumerSecret, kConsumerKey];
    if (totoashop) {
        wcURL = [NSString stringWithFormat:@"%@/orders/%@?consumer_key=%@&consumer_secret=%@&oauth_consumer_key=%@&filter[meta]=true",kAPIURLTotoa, ordersNumber, kTotoaConsumerKey, kTotoaConsumerSecret, kTotoaConsumerKey];
    }
    [self getMethodWithURL:wcURL withCompletion:^(NSData *data, NSError *error) {
        NSError *errr = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&errr];
        if (errr == nil) {
            if (userInfo) {
                NSDictionary *orderDict = userInfo[@"order"];
//                // NSLog(@"***** %@", userInfo);
                NSDictionary *paymentDict = orderDict[@"payment_details"];
                NSString *orderStatus = orderDict[@"status"];
                NSNumber *paidNU = paymentDict[@"paid"];
                if ([orderStatus isEqualToString:@"completed"]) {
                    BOOL isPaidStatus = [paidNU boolValue];
                    if (isPaidStatus == YES) {
                        completion(userInfo, error);
                    } else {
//                        completion(nil, error);
//                        "https://baytapps.net/orderstatus/?order=$orderStatus";
                        NSString *statusPage = [NSString stringWithFormat:@"https://baytapps.net/orderstatus/?order=%@", orderStatus];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:statusPage]];
                        
                    }
                    
                } else {
//                    completion(nil, error);
                    NSString *statusPage = [NSString stringWithFormat:@"https://baytapps.net/orderstatus/?order=%@", orderStatus];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:statusPage]];
                }
            }
        } else {
            completion(nil, error);
        }
    }];
}

+ (NSString *)translatedStringAr:(NSString *)arabic andEnglish:(NSString *)english {
    return [NSString translateToAR:arabic toCA:nil toCS:nil toDA:nil toDE:nil toEL:nil toEN:english toEN_AU:english toEN_GB:english toES:nil toES_MX:nil toFI:nil toFR:nil toFR_CA:nil toHE:nil toHI:nil toHR:nil toHU:nil toID:nil toIT:nil toJA:nil toKO:nil toMS:nil toNL:nil toNO:nil toPL:nil toPT:nil toPT_PT:nil toRO:nil toRU:nil toSK:nil toSV:nil toTH:nil toTR:nil toUK:nil toVI:nil toZH_CN:nil toZH_HK:nil toZH_TW:nil];
}

+ (void)showActivityViewControllerFromSourceView:(UIView *)sourceView andViewController:(UIViewController *)vc withArray:(NSArray *)array {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    
    // In iPads case, we need to show the share sheet from the share buttons view, but only on iOS 8+
    if ([BAHelper isIPAD] && [BAHelper systemVersionGreaterThanOrEqual:@"8.0"]) {
        activityVC.popoverPresentationController.sourceView = sourceView;
    }
    
    // Show the activity view controller
    [vc presentViewController:activityVC animated:YES completion:nil];
}

+ (UIImage *) makeImage:(UIImage *)thisImage toThumbnailOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    // draw scaled image into thumbnail context
    [thisImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}

+ (UIImage *)gridButtonImage {
    UIImage *menuimg = [UIImage imageNamed:@"MenuBtn"];
    return [menuimg gm_imageTintedWithColor:[UIColor gm_hex:@"#007AFF"]];//[UIColor blueColor]];
}

+ (UIImage *)gridButtonImageOff {
    UIImage *menuimg = [UIImage imageNamed:@"MenuBtn"];
    return [menuimg gm_imageTintedWithColor:[UIColor gm_hex:@"#007AFF"]];//[UIColor blueColor]];
}
+ (UIImage *)listButtonImage {
    UIImage *menuimg = [UIImage imageNamed:@"List"];
    
    return [menuimg gm_imageTintedWithColor:[UIColor gm_hex:@"#007AFF"]];//[UIColor blueColor]];
}
+ (UIImage *)listButtonImageOff {
    UIImage *menuimg = [UIImage imageNamed:@"List"];
    return [menuimg gm_imageTintedWithColor:[UIColor gm_hex:@"#007AFF"]];//[UIColor blueColor]];
}


+ (UIBarButtonItem *)gridButtonForTarget:(id)target {
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [menuButton setImage:[self gridButtonImageOff] forState:UIControlStateNormal];
    [menuButton setImage:[self gridButtonImage] forState:UIControlStateHighlighted];
    [menuButton addTarget:target action:@selector(openSideMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [buttonView addSubview:menuButton];
    
    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    return menuBtn;
}

+ (UIBarButtonItem *)listButtonForTarget:(id)target {
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [menuButton setImage:[self listButtonImageOff] forState:UIControlStateNormal];
    [menuButton setImage:[self listButtonImage] forState:UIControlStateHighlighted];
    [menuButton addTarget:target action:@selector(openSideMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [buttonView addSubview:menuButton];
    
    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    return menuBtn;
}

+ (void)showHudFromView:(UIView *)view {
    hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    hudView.center = view.center;
    hudView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    hudView.backgroundColor = [UIColor whiteColor];
    hudView.alpha = 0.9;
    hudView.layer.cornerRadius = hudView.bounds.size.width/2;
    hudView.layer.borderColor = [UIColor whiteColor].CGColor;
    hudView.layer.borderWidth = 3;
    
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    bgImage.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2);
    bgImage.image = [UIImage new];
    bgImage.backgroundColor = [BAColorsHelper sideMenuCellSelectedColors];
    bgImage.layer.cornerRadius = bgImage.bounds.size.width/2;
    bgImage.layer.masksToBounds = YES;
    
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    indicatorView.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2);
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    indicatorView.color = [UIColor whiteColor];
    
    [hudView addSubview:bgImage];
    [hudView addSubview:indicatorView];
    
    indicatorView.hidden = NO;
    indicatorView.hidesWhenStopped = YES;
    [indicatorView startAnimating];
    
    bgToolbar = [[UIToolbar alloc] initWithFrame:view.frame];
    bgToolbar.alpha = 0.8;
    bgToolbar.barStyle = UIBarStyleDefault;
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = view.frame;
    visualEffectView.alpha = 0.9;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [view addSubview:visualEffectView];
    [view addSubview:hudView];
}
+ (void)hideHUD {
    [indicatorView stopAnimating];
    [hudView removeFromSuperview];
    [visualEffectView removeFromSuperview];
}

+ (void)showHudWithText:(NSString *)text inView:(UIView *)view dismissAfterDelay:(NSInteger)delay {
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = text;
    [HUD showInView:view];
    [HUD dismissAfterDelay:delay];
    
}

+ (CGFloat)getHeightForTextView:(UITextView *)textView {
    CGSize sizeThatFitsTextView = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    
//    CGSize textSize = [textView.text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(textView.frame.size.width, MAXFLOAT) lineBreakMode: UILineBreakModeWordWrap];
    
    return sizeThatFitsTextView.height;
}
+ (CGFloat)heightForText:(NSString*)bodyText
{
    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:14];
    CGSize constraintSize = CGSizeMake(300, MAXFLOAT);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:bodyText];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:cellFont} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize labelSize = [attributedString boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    
    CGFloat height = labelSize.height - 65;
    return height;
}

+ (CGRect)getFrameForText:(NSString*)text withY:(float)Y
{
    float width = text.length * 8;
    return CGRectMake(kXLength - width, Y, width, 20);
}


+ (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

+ (NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return (float) (contentLength / (float)pow(1024, 3));
    else if(contentLength >= pow(1024, 2))
        return (float) (contentLength / (float)pow(1024, 2));
    else if(contentLength >= 1024)
        return (float) (contentLength / (float)1024);
    else
        return (float) (contentLength);
}
+ (NSString *)calculateUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return @"GB";
    else if(contentLength >= pow(1024, 2))
        return @"MB";
    else if(contentLength >= 1024)
        return @"KB";
    else
        return @"Bytes";
}

+ (void)ensurePathAt:(NSString *)path
{
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ( [fm fileExistsAtPath:path] == false ) {
        [fm createDirectoryAtPath:path
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error];
        if (error) {
            // NSLog(@"Ensure Error: %@", error);
        }
        // NSLog(@"Creating the missed path");
    }
}

+ (void)ensureFileAt:(NSURL *)path
{
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ( [fm fileExistsAtPath:path.absoluteString] == false ) {
        [fm createDirectoryAtURL:[path URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:NULL error:&error];
        if (error) {
            // NSLog(@"Ensure ensureFileAt Error : %@", error);
        }
        // NSLog(@"Creating the missed path");
    }
}

+ (void)createFileAtPath:(NSString *)path withData:(NSData *)data
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ( [fm fileExistsAtPath:path] == false ) {
        [fm createFileAtPath:path contents:data attributes:NULL];
    }
}

+ (BOOL)deleteFileAtPath:(NSString *)filePath {
    BOOL deleted = NO;
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
        deleted = NO;
        // NSLog(@"Error while deleting file : %@", error.localizedDescription);
    } else {
        deleted = YES;
    }
    return deleted;
}

+ (NSString*)getCachesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return cachesDirectory;
}

+ (NSString*)getLibraryPath {
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return libraryPath;
}

+ (NSString*)getDocumentsPath {
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex: 0];
    return documentPath;
}

+ (NSLocale *)currentLocalInEn {
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    return locale;
}
+ (NSString*)getFileFromCachesWithName:(NSString*)fileName andExt:(NSString*)ext {
    return [[self getCachesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName, ext]];
}

+ (NSString*)getDownloadsPath
{
    NSString *downsPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"Downloads"];
    [self ensurePathAt:downsPath];
    
    return downsPath;
}

+ (NSString*)getInboxPath
{
    NSString *downsPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"Inbox"];
    [self ensurePathAt:downsPath];
    
    return downsPath;
}

+ (NSString*)getReceivedFilesPath
{
    NSString *downsPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"Receiveds"];
    [self ensurePathAt:downsPath];
    
    return downsPath;
}

+ (NSString*)getVideosPath
{
    NSString *videosPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"Videos"];
    [self ensurePathAt:videosPath];
    
    return videosPath;
}

+ (NSString*)getThumbsPath
{
    NSString *thumbsPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"Thumbs"];
    [self ensurePathAt:thumbsPath];
    
    return thumbsPath;
}

+ (NSString*)getUnzipPath {
    NSString *unzipPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"UnZip"];
    [self ensurePathAt:unzipPath];
    
    return unzipPath;
}

+ (UIImage*)getThumbForVideoName:(NSString *)videoName
{
    NSString *thumbName = [videoName stringByAppendingString:@".png"];
    UIImage *image = [UIImage imageWithContentsOfFile:[[self getThumbsPath] stringByAppendingPathComponent: thumbName]];
    return image;
}

+ (NSArray*)getContentsOfDir:(NSString*)directory withExtension:(NSString*)extention
{
    NSString *path = directory;
    NSArray *contentsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    contentsDirectory = [contentsDirectory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                        @"pathExtension ==[c] %@", extention]];
    
    return contentsDirectory;
}

+ (NSArray*)getContentsOfDir:(NSString*)directory
{
    NSString *path = directory;
    NSArray *contentsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    return contentsDirectory;
}

+ (BOOL)fileIsDirectory:(NSString *)file {
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory];
    if (isDirectory == YES) {
        return YES;
    }
    return NO;
}

+ (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

+ (void)showAlertViewForExtFromViewController:(UIViewController*)vc WithTitle:(NSString *)titl msg:(NSString *)msg {
    
    Alert *alert = [[Alert alloc] initWithTitle:msg duration:(float)3 completion:^{
        //
    }];
    [alert setDelegate:nil];
    [alert setShowStatusBar:NO];
    [alert setAlertType:AlertTypeError];
    [alert setIncomingTransition:AlertIncomingTransitionTypeSlideFromTop];
    [alert setOutgoingTransition:AlertOutgoingTransitionTypeSlideToTop];
    [alert setBounces:YES];
    [alert showAlert];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titl message:msg preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //
//    }]];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [vc presentViewController:alert animated:YES completion:^{
//            //
//        }];
//    });
    
}



+ (void)showErrorMessageFrom:(UIViewController*)vc withError:(NSError *)error {
    
    if ([error.localizedDescription.lowercaseString containsString:@"Cannot modify user"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME message:NSLocalizedString(@"ERROR: you should log-out and log-in again", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"LogOut", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [vc presentViewController:alert animated:YES completion:^{
                
            }];
        });
    }
    Alert *alert = [[Alert alloc] initWithTitle:error.localizedDescription duration:(float)3 completion:^{
        //
    }];
    [alert setDelegate:nil];
    [alert setShowStatusBar:NO];
    [alert setAlertType:AlertTypeError];
    [alert setIncomingTransition:AlertIncomingTransitionTypeSlideFromTop];
    [alert setOutgoingTransition:AlertOutgoingTransitionTypeSlideToTop];
    [alert setBounces:YES];
    [alert showAlert];
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //
//    }]];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [vc presentViewController:alert animated:YES completion:^{
//            //
//        }];
//    });
}

+ (void)showErrorAlert:(NSString *)alertString {
    Alert *alert = [[Alert alloc] initWithTitle:alertString duration:(float)3 completion:^{
        //
    }];
    [alert setDelegate:nil];
    [alert setShowStatusBar:NO];
    [alert setAlertType:AlertTypeError];
    [alert setIncomingTransition:AlertIncomingTransitionTypeSlideFromTop];
    [alert setOutgoingTransition:AlertOutgoingTransitionTypeSlideToTop];
    [alert setBounces:YES];
    [alert showAlert];
}

+ (void)showSuccessAlert:(NSString *)alertString {
    Alert *alert = [[Alert alloc] initWithTitle:alertString duration:(float)3 completion:^{
        //
    }];
    [alert setDelegate:nil];
    [alert setShowStatusBar:NO];
    [alert setAlertType:AlertTypeSuccess];
    [alert setIncomingTransition:AlertIncomingTransitionTypeSlideFromTop];
    [alert setOutgoingTransition:AlertOutgoingTransitionTypeSlideToTop];
    [alert setBounces:YES];
    [alert showAlert];
}
+ (UIAlertController *)showAlertViewForExtFromViewController:(UIViewController*)vc WithTitle:(NSString *)titl msg:(NSString *)msg withActions:(NSArray *)actions andTextField:(BOOL)addTextField {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titl message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *action in actions) {
        [alert addAction:action];
    }
    if (addTextField == YES) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"";
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [vc presentViewController:alert animated:YES completion:^{
            //
        }];
    });
    return alert;
}

+ (BOOL)validateEmailAddress:(NSString*)emailAddress
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

+ (void)setMainRootViewController:(id)target {
       if ([PFUser currentUser] != nil) {
       // UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
        // order created date
//        NSError *orderDateError = nil;
//        NSString *orderDateString =  [PFUser currentUser][USER_EXPIRY_DATE];//[key stringForKey:@"it_67" error:&orderDateError];
//        NSDate *createdAtDate = Strings2Date(orderDateString);
//        
//        // current date
//        NSString *currentDateString = Date2Strings([NSDate date]);
//        NSDate *currentDate = Strings2Date(currentDateString);
//        
//        // created date after 1 year
//        NSDate *dateAfterYear = [createdAtDate dateByAddingYears:1];
//        
//        if (orderDateString.length < 1) {
//            [ITHelper showErrorAlert:@"Order date not configured"];
//            BALaunchViewController *launchVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//            [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//            
//            [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                              duration:0.3
//                               options:UIViewAnimationOptionTransitionNone
//                            animations:nil
//                            completion:nil];
//            return;
//        }
//        if ([currentDate isLaterThan:dateAfterYear]) {
//            
//            PFQuery *orderQuery = [PFQuery queryWithClassName:USER_ORDER_CLASS_NAME];
//            [orderQuery whereKey:USER_ORDER_USER equalTo:[PFUser currentUser]];
//            
//            [orderQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//                if (error == nil) {
//                    if (objects.count == 1) {
//                        PFObject *orderObject = [objects objectAtIndex:0];
//                        orderObject[USER_ORDER_STATUS] = @"NO";
//                        PFACL *orderACL = [PFACL ACL];
//                        [orderACL setPublicReadAccess:NO];
//                        [orderACL setPublicWriteAccess:NO];
//                        [orderObject setACL:orderACL];
//                        
//                        [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                            if (error == nil) {
//                                if (succeeded) {
//                                   // [key removeAllItems];
//                                    BARenewViewController *renewVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"renewVC"];
//                                    [UIApplication sharedApplication].delegate.window.rootViewController = renewVC;
//                                    
//                                    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                      duration:0.3
//                                                       options:UIViewAnimationOptionTransitionCrossDissolve
//                                                    animations:nil
//                                                    completion:nil];
//                                }
//                            }
//                        }];
//                    }
//                }
//            }];
//            
//            return;
//        }
        ECSlidingViewController *mainViewController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"slidingVC"];
        mainViewController.topViewController = target;
        [UIApplication sharedApplication].delegate.window.rootViewController = mainViewController;
        
        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
    } else {
        [ITHelper showErrorAlert:@"You should login"];
        BALaunchViewController *launchVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
        
        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionNone
                        animations:nil
                        completion:nil];
        return;
    }
    
}

+ (void)showLaunchOrMainView:(BOOL)isMain {
    
    if ([[CACheckConnection sharedManager] isUnreachable]) {
//        [ITHelper showErrorAlert:@"No internet connection"];
//        
//        BANoInternetViewController *launchVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"noConnectionVC"];
//        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//        
//        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionNone
//                        animations:nil
//                        completion:nil];
//        return;
        
        [KVNProgress showWithStatus:NSLocalizedString(@"No Internet Connection...", @"")];

    }
    
    UIStoryboard *storyboard = [ITHelper mainStoryboard];
    //UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    
    //NSError *orderStatusError = nil;
    //NSError *orderPaidError = nil;
    //NSError *orderDateError = nil;
    //NSString *orderStatus =  [key stringForKey:@"it_8" error:&orderStatusError];
    //NSString *orderPaid =  [key stringForKey:@"it_6" error:&orderPaidError];
    
    // order created date
    //NSString *orderDateString =  [key stringForKey:@"it_67" error:&orderDateError];
    //NSDate *createdAtDate = Strings2Date(orderDateString);
    
    // current date
    //NSString *currentDateString = Date2Strings([NSDate date]);
    //NSDate *currentDate = Strings2Date(currentDateString);
    
    // created date after 1 year
    //NSDate *dateAfterYear = [createdAtDate dateByAddingYears:1];
    //NSString *dateAfterYearString = Date2Strings(dateAfterYear);
    if (isMain) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"leftMenuSelectedRow"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                        [self setupTabs];
    }else{
        UINavigationController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"launchNavigationController"];
        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
        
        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionNone
                        animations:nil
                        completion:nil];
    }
   

//    if (orderStatus.length < 1) {
//        [ITHelper showErrorAlert:@"Order status isn't configured"];
//        BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//        
//        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionNone
//                        animations:nil
//                        completion:nil];
//        return;
//    }
//    if (orderPaid.length < 1) {
//        [ITHelper showErrorAlert:@"Payment status isn't configured"];
//        BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//        
//        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionNone
//                        animations:nil
//                        completion:nil];
//        return;
//    }
//    if (orderDateString.length < 1) {
//        [ITHelper showErrorAlert:@"Order date isn't configured"];
//        BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//        [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//        
//        [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionNone
//                        animations:nil
//                        completion:nil];
//        return;
//    }
//    if ([[orderStatus lowercaseString] isEqualToString:@"completed"]) {
////        // NSLog(@"******** %@", orderStatus);
//        if ([orderPaid isEqualToString:@"1"]) {
//            
//            if ([dateAfterYear isLaterThan:currentDate]) {
//                
//                if ([[CACheckConnection sharedManager] isUnreachable]) {
//                    
//                    BANoInternetViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"noConnectionVC"];
//                    [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//                    
//                    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                      duration:0.3
//                                       options:UIViewAnimationOptionTransitionNone
//                                    animations:nil
//                                    completion:nil];
//                } else {
//                    
//                    if (isMain) {
//                        if ([[orderStatus lowercaseString] isEqualToString:@"completed"]) {
//                            if ([orderPaid intValue] == 1) {
//                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"leftMenuSelectedRow"];
//                                [[NSUserDefaults standardUserDefaults] synchronize];
//                                [self setupTabs];
//                            } else {
//                                NSString *checkingLicense = [key stringForKey:@"checkingLicense"];
//                                if ([checkingLicense isEqualToString:@"YES"] || checkingLicense.length < 1) {
//                                    UIViewController *fuckedVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"fuckedVC"];
//                                    [UIApplication sharedApplication].delegate.window.rootViewController = fuckedVC;
//                                    
//                                    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                      duration:0.3
//                                                       options:UIViewAnimationOptionTransitionCrossDissolve
//                                                    animations:nil
//                                                    completion:nil];
//                                    return;
//                                }
//                                [ITHelper showErrorAlert:@"Order not paid"];
//                                BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//                                [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//                                
//                                [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionTransitionNone
//                                                animations:nil
//                                                completion:nil];
//                            }
//                        } else {
//                            NSString *checkingLicense = [key stringForKey:@"checkingLicense"];
//                            if ([checkingLicense isEqualToString:@"YES"] || checkingLicense.length < 1) {
//                                UIViewController *fuckedVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"fuckedVC"];
//                                [UIApplication sharedApplication].delegate.window.rootViewController = fuckedVC;
//                                
//                                [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionTransitionCrossDissolve
//                                                animations:nil
//                                                completion:nil];
//                                return;
//                            }
//                            [ITHelper showErrorAlert:@"Order not completed"];
//                            BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//                            [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//                            
//                            [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                              duration:0.3
//                                               options:UIViewAnimationOptionTransitionNone
//                                            animations:nil
//                                            completion:nil];
//                        }
//                    } else {
//                        if ([orderStatus isEqualToString:@"completed"]) {
//                            if ([orderPaid intValue] == 1) {
//                                UINavigationController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"launchNavigationController"];
//                                [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//                                
//                                [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionTransitionNone
//                                                animations:nil
//                                                completion:nil];
//                            } else {
//                                NSString *checkingLicense = [key stringForKey:@"checkingLicense"];
//                                if ([checkingLicense isEqualToString:@"YES"] || checkingLicense.length < 1) {
//                                    UIViewController *fuckedVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"fuckedVC"];
//                                    [UIApplication sharedApplication].delegate.window.rootViewController = fuckedVC;
//                                    
//                                    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                      duration:0.3
//                                                       options:UIViewAnimationOptionTransitionCrossDissolve
//                                                    animations:nil
//                                                    completion:nil];
//                                    return;
//                                }
//                                [ITHelper showErrorAlert:@"Order not paid"];
//                                BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//                                [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//                                
//                                [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionTransitionNone
//                                                animations:nil
//                                                completion:nil];
//                            }
//                        } else {
//                            //                                BOOL checkingLicense = [[[NSUserDefaults standardUserDefaults] objectForKey:@"checkingLicense"] boolValue];
//                            NSString *checkingLicense = [key stringForKey:@"checkingLicense"];
//                            if ([checkingLicense isEqualToString:@"YES"] || checkingLicense.length < 1) {
//                                UIViewController *fuckedVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"fuckedVC"];
//                                [UIApplication sharedApplication].delegate.window.rootViewController = fuckedVC;
//                                
//                                [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionTransitionCrossDissolve
//                                                animations:nil
//                                                completion:nil];
//                                return;
//                            }
//                            [ITHelper showErrorAlert:@"Order not completed"];
//                            BALaunchViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyDeviceVC"];
//                            [UIApplication sharedApplication].delegate.window.rootViewController = launchVC;
//                            
//                            [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                              duration:0.3
//                                               options:UIViewAnimationOptionTransitionNone
//                                            animations:nil
//                                            completion:nil];
//                        }
//                        
//                    }
//                }
//            } else {
//                [key removeAllItems];
//                BARenewViewController *renewVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"renewVC"];
//                [UIApplication sharedApplication].delegate.window.rootViewController = renewVC;
//                
//                [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
//                                  duration:0.3
//                                   options:UIViewAnimationOptionTransitionCrossDissolve
//                                animations:nil
//                                completion:nil];
//            }
//        } else {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://baytapps.net"]];
//        }
//    } else {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://baytapps.net"]];
//    }
}


+ (void)setupTabs {
    
    [UIApplication sharedApplication].delegate.window.rootViewController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"slidingVC"];
    
    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionNone
                    animations:nil
                    completion:nil];
    
}

+ (NSString *)replaceSpaceToUnderscoreIfNeed:(NSString *)string {
    NSRange whiteSpaceRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        NSString *string2 = [string stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        return string2;
    }
    return string;
}

+ (UIStoryboard *)mainStoryboard {
    
    BOOL isIPhone4 = [BAHelper isIPHONE4];
    BOOL isIPhone5 = [BAHelper isIPHONE5];
    BOOL isIPhone6 = [BAHelper isIPHONE6];
    BOOL isIPhone6Plus = [BAHelper isIPHONE6PLUS];
    
    if (isIPhone4) {
        return [UIStoryboard storyboardWithName:@"Main-Plus" bundle:[NSBundle mainBundle]];
    } else if (isIPhone5) {
        return [UIStoryboard storyboardWithName:@"Main-Plus" bundle:[NSBundle mainBundle]];
    } else if (isIPhone6) {
        return [UIStoryboard storyboardWithName:@"Main-Plus" bundle:[NSBundle mainBundle]];
    } else if (isIPhone6Plus) {
        return [UIStoryboard storyboardWithName:@"Main-Plus" bundle:[NSBundle mainBundle]];
    } else {
        if ([BAHelper isIPAD]) {
            return [UIStoryboard storyboardWithName:@"Main-Plus" bundle:[NSBundle mainBundle]];
        }
    }
    return nil;
}

+ (void)loadRootViewControllerForDevice {
    ECSlidingViewController *mainViewController = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"slidingVC"];
    [UIApplication sharedApplication].delegate.window.rootViewController = mainViewController;
    
    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}
+ (void)showHudWithText:(NSString *)text inView:(UIView *)view {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showWithStatus:text
                             onView:view];
    });
    
}
+ (void)dismissHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress dismiss];
    });
    
}
+ (UIImage *)ResizeImage:(UIImage *)image withSize:(CGSize)size andScale:(CGFloat)scale
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [image drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

+ (NSDate *)addThisToDate:(NSDate *)dateTo {
    NSDate *today = dateTo;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:1];
    [offsetComponents setDay:-2];
    NSDate *nextYear = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    return nextYear;
}

+ (NSDate*)dateValueOfString:(NSString *)dateString
{
    __block NSDate *detectedDate;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil];
    [detector enumerateMatchesInString:dateString
                               options:kNilOptions
                                 range:NSMakeRange(0, [dateString length])
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     { detectedDate = result.date; }];
    return detectedDate;
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)dateFormat {
    NSString *dateString = string;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:dateFormat];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}
+ (NSString *)fileInMainBundleWithName:(NSString *)name {
    
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath  encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        // NSLog(@"********** %@", error.localizedDescription);
    }
    return fileContent;
}

+ (UIViewController *) rootViewController{
    UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if ([controller presentedViewController]) {
        controller = [controller presentedViewController];
    }
    return controller;
}

+(NSDictionary*) getMobileProvisionbyPath:(NSString *)path
{
    NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = path;
        if (!provisioningPath) {
            mobileProvision = @{};
            return mobileProvision;
        }
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSISOLatin1StringEncoding error:NULL];
        if (!binaryString) {
            return nil;
        }
        NSScanner *scanner = [NSScanner scannerWithString:binaryString];
        BOOL ok = [scanner scanUpToString:@"<plist" intoString:nil];
        if (!ok) { // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return nil;
        }
    }
    return mobileProvision;
}

+ (NSString*)hardwareString {
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

//
+ (NSString *)accountType {
    NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath]) {
#if TARGET_IPHONE_SIMULATOR
        return @"ipa";
#else
        return @"isn't existe";
#endif
    }
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:provisioningPath error:nil] fileSize];
    if (fileSize != profileSize) {
        // OPS ;)
    }
    NSDictionary *profile = [ITHelper getMobileProvisionbyPath:provisioningPath];
    NSString *teamID = profile[@"UUID"];
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
    
#if TARGET_IPHONE_SIMULATOR
    return @"ipa";
#else
    return accountType;
#endif
}

+ (NSString *)push_accountID {
    NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSDictionary *profile = [ITHelper getMobileProvisionbyPath:provisioningPath];
    NSString *teamID = profile[@"UUID"];
    NSString *teamID2 = [profile[@"TeamIdentifier"] objectAtIndex:0];
    NSString *accountType = @"other";
    
    if (teamID.length > 0) {
        if ([teamID2 isEqualToString:@"USM32L424X"]) accountType = @"579a9092-23c2-4d16-b1db-543c69c135ab";
        if ([teamID2 isEqualToString:@"2R5JB2FB9E"]) accountType = @"e92e57ec-5d01-463a-a840-49f726d866c3";
        if ([teamID2 isEqualToString:@"J6D5BK3T6D"]) accountType = @"62bb24d5-d7b1-4959-bd09-0437d1068d58";
    } else {
        accountType = @"other";
    }
    
    NSLog(@"******** PUSH %@", accountType);

    return accountType;
}

+ (BOOL)deviceUDID:(NSString *)device {
    NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath]) {
        return NO;
    }
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:provisioningPath error:nil] fileSize];
    if (fileSize != profileSize) {
        // OPS ;)
    }
    NSDictionary *profile = [ITHelper getMobileProvisionbyPath:provisioningPath];
    NSArray *devicesArray = [profile objectForKey:@"ProvisionedDevices"];
    BOOL isDeviceExiste;
    if (devicesArray.count > 0) {
        if ([devicesArray containsObject:device]) {
            isDeviceExiste = YES;
        } else {
            isDeviceExiste = NO;
        }
    } else {
        isDeviceExiste = NO;
    }
    return isDeviceExiste;
}


- (CGColorSpaceModel)colorSpaceModelFromColor:(UIColor *)color  {
    return CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
}

- (BOOL)red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha fromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r,g,b,a;
    
    switch ([self colorSpaceModelFromColor:color]) {
        case kCGColorSpaceModelMonochrome:
            r = g = b = components[0];
            a = components[1];
            break;
        case kCGColorSpaceModelRGB:
            r = components[0];
            g = components[1];
            b = components[2];
            a = components[3];
            break;
        default:	// We don't know how to handle this model
            return NO;
    }
    
    if (red) *red = r;
    if (green) *green = g;
    if (blue) *blue = b;
    if (alpha) *alpha = a;
    
    return YES;
}

- (UInt32)rgbHexFromColor:(UIColor *)color {
    NSAssert(color.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
    
    CGFloat r,g,b,a;
    if (![self red:&r green:&g blue:&b alpha:&a fromColor:color]) return 0;
    
    r = MIN(MAX(r, 0.0f), 1.0f);
    g = MIN(MAX(g, 0.0f), 1.0f);
    b = MIN(MAX(b, 0.0f), 1.0f);
    
    return (((int)roundf(r * 255)) << 16)
    | (((int)roundf(g * 255)) << 8)
    | (((int)roundf(b * 255)));
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    return [NSString stringWithFormat:@"%0.6X", (unsigned int)[self rgbHexFromColor:color]];
}

+ (NSString *)groupId {
    NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath]) {
    }
    NSDictionary *profile = [self getMobileProvisionbyPath:provisioningPath];
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
    return accountType;
}


+ (NSUserDefaults *)currentDefaultsWithId:(NSString *)Id {
    
    return [[NSUserDefaults alloc] initWithSuiteName:Id];
}
@end
