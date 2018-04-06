//
//  ITHelper.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "URLConnection.h"
#import "ITAppObject.h"
#import "BAHelper.h"
#import "DateTools.h"
#import <GBDeviceInfo/GBDeviceInfo.h>
#import <Intents/Intents.h>
#import <IntentsUI/IntentsUI.h>

@interface LSApplicationProxy : NSObject
+ (LSApplicationProxy *)applicationProxyForIdentifier:(id)appIdentifier;
@property(readonly) NSString * applicationIdentifier;
@property(readonly) NSString * bundleVersion;
@property(readonly) NSString * bundleExecutable;
@property(readonly) NSArray * deviceFamily;
@property(readonly) NSURL * bundleContainerURL;
@property(readonly) NSString * bundleIdentifier;
@property(readonly) NSURL * bundleURL;
@property(readonly) NSURL * containerURL;
@property(readonly) NSURL * dataContainerURL;
@property(readonly) NSString * localizedShortName;
@property(readonly) NSString * localizedName;
@property(readonly) NSString * shortVersionString;
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)installApplication:(NSURL *)path withOptions:(NSDictionary *)options;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
- (BOOL)applicationIsInstalled:(NSString *)appIdentifier;
- (NSArray *)allInstalledApplications;
- (NSArray *)allApplications;
- (NSArray *)applicationsOfType:(unsigned int)appType; // 0 for user, 1 for system
@end

@interface UIColor (GridMessages)
+ (UIColor *)gm_hex:(NSString *)hexString;
@end

@interface UIImage (GridMessages)
- (UIImage *)gm_imageTintedWithColor:(UIColor *)color;
- (UIImage *)gm_imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
@end

@interface ITHelper : NSObject

+(ITHelper *)sharedInstance;

- (void)newGetMethodWithURL:(NSString *)urlString
            completionBlock:(URLConnectionCompletionBlock)completionBlock
                 errorBlock:(URLConnectioErrorBlock)errorBlock
        uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
      downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;

- (void)newPostMethodWithURL:(NSString *)urlString
                  postString:(NSString *)postString
             completionBlock:(URLConnectionCompletionBlock)completionBlock
                  errorBlock:(URLConnectioErrorBlock)errorBlock
         uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
       downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;

+ (NSString *)translatedStringAr:(NSString *)arabic andEnglish:(NSString *)english;

+ (void)showActivityViewControllerFromSourceView:(UIView *)sourceView andViewController:(UIViewController *)vc withArray:(NSArray *)array;

+ (void)showErrorMessageFrom:(UIViewController*)vc withError:(NSError *)error;

+ (BOOL)validateEmailAddress:(NSString*)emailAddress;

+ (void)showLaunchOrMainView:(BOOL)isMain;

+ (void)setMainRootViewController:(id)target;

+ (void)showAlertViewForExtFromViewController:(UIViewController*)vc WithTitle:(NSString *)titl msg:(NSString *)msg;

+ (UIAlertController *)showAlertViewForExtFromViewController:(UIViewController*)vc WithTitle:(NSString *)titl msg:(NSString *)msg withActions:(NSArray *)actions andTextField:(BOOL)addTextField;

- (void)getAllAppsForCat:(NSString *)category withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getAllLatestAppsWithCat:(NSString *)category withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getAllAppsForOrder:(NSString *)order page:(NSUInteger)pageNumber andCat:(NSString *)category withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getAllAppsForCat:(NSString *)category page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getAllAppsForCydiaCat:(NSString *)category page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getAllPromotedContentsWithCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getAllDownloadLinksForApp:(NSString *)appTrackingID andSection:(NSString *)appSection withCompletion:(void (^)(NSDictionary *allHosts, NSError *error))completion;

- (void)getAppInfoFromItunes:(NSString *)appTrackID withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)linkNewDeviceWithEmail:(NSString *)email andScheme:(NSString *)scheme;

- (void)getAllPlistsFromOwnServer;

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
        downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock ;

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
        downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock ;




- (void)searchTweakedAppsWithKeyword:(NSString *)keyword page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;
- (void)searchWithKeyword:(NSString *)keyword page:(NSUInteger)pageNumber withCompletion:(void (^)(NSArray *allApps, NSError *error))completion;

- (void)getCustomerOrderWithNumber:(NSString *)ordersNumber isTotoaShop:(BOOL)totoashop withCompletion:(void (^)(NSDictionary *dict, NSError *error))completion;

+ (void)showHudFromView:(UIView *)view;

+ (void)hideHUD;

+ (void)showHudWithText:(NSString *)text inView:(UIView *)view dismissAfterDelay:(NSInteger)delay;
+ (UIImage *) makeImage:(UIImage *)thisImage toThumbnailOfSize:(CGSize)size;

+ (UIImage *)gridButtonImage;
+ (UIImage *)gridButtonImageOff;
+ (UIImage *)listButtonImage;
+ (UIImage *)listButtonImageOff;
+ (UIBarButtonItem *)gridButtonForTarget:(id)target;
+ (UIBarButtonItem *)listButtonForTarget:(id)target;

+ (NSString *)abbreviateNumber:(int)num;
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength;
+ (NSString *)calculateUnit:(unsigned long long)contentLength;

+ (CGFloat)getHeightForTextView:(UITextView *)textView;
+ (CGFloat)heightForText:(NSString*)bodyText;
+ (CGRect)getFrameForText:(NSString*)text withY:(float)Y;

+ (void)ensureFileAt:(NSURL *)path;
+ (void)ensurePathAt:(NSString *)path;
+ (void)createFileAtPath:(NSString *)path withData:(NSData *)data;
+ (BOOL)deleteFileAtPath:(NSString *)filePath;

+ (NSString*)getUnzipPath;
+ (NSString*)getInboxPath;
+ (NSString*)getCachesPath;
+ (NSString*)getLibraryPath;
+ (NSString*)getDocumentsPath;
+ (NSString*)getDownloadsPath;
+ (NSString*)getReceivedFilesPath;
+ (NSString*)getVideosPath;
+ (NSString*)getThumbsPath;
+ (NSString*)getFileFromCachesWithName:(NSString*)fileName andExt:(NSString*)ext;
+ (UIImage*)getThumbForVideoName:(NSString*)videoName;
+ (NSArray*)getContentsOfDir:(NSString*)directory withExtension:(NSString*)extention;
+ (NSArray*)getContentsOfDir:(NSString*)directory;
+ (BOOL)fileIsDirectory:(NSString *)file;

+ (UIViewController *) rootViewController;

+ (UIStoryboard *)mainStoryboard;
+ (void)showHudWithText:(NSString *)text inView:(UIView *)view;
+ (void)dismissHUD;
+ (UIImage *)ResizeImage:(UIImage *)image withSize:(CGSize)size andScale:(CGFloat)scale;
+ (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2;
+ (NSDate *)addThisToDate:(NSDate *)dateTo;
+ (NSDate*)dateValueOfString:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)dateFormat;
+ (NSString *)fileInMainBundleWithName:(NSString *)name;
+ (NSString *)accountType;
+ (NSString *)push_accountID;
+ (NSString*)hardwareString;
+ (UIColor *)currentMain;
- (NSString *)hexStringFromColor:(UIColor *)color;
- (void)testApps:(NSString *)ipaString;
+ (void)loadRootViewControllerForDevice;
+ (void)showSuccessAlert:(NSString *)alertString;
+ (void)showErrorAlert:(NSString *)alertString;
+ (NSString *)replaceSpaceToUnderscoreIfNeed:(NSString *)string;

+ (NSString *)groupId;
+ (NSUserDefaults *)currentDefaultsWithId:(NSString *)Id;
@end
