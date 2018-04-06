//
//  ITServerHelper.h
//  ioteam
//
//  Created by iMokhles on 29/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>
#import "BAHelper.h"

typedef void (^iMObjectBooleanResultBlock)(BOOL succeeded, NSError *error, id object);
typedef void (^iMBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^iMBooleanWithoutErrorResultBlock)(BOOL succeeded);
typedef void (^iMBooleanWithArrayResultBlock)(BOOL succeeded, NSArray *objects);
typedef void (^iMBooleanWithArrayErrorResultBlock)(BOOL succeeded, NSArray *objects, NSError *error);
typedef void (^iMIntegerResultBlock)(int number);

__attribute__((always_inline, visibility("hidden")))
NSString *ENCRYPT_TEXT_KEY();

__attribute__((always_inline, visibility("hidden")))
NSData *SECRET_DATA_KEY();

// encrypt
__attribute__((always_inline, visibility("hidden")))
NSString* EncryptText(NSString *userName, NSString *string);

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptText2(NSString *userName, NSString *string);

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptDeviceToken(NSString *userName, NSString *string);

__attribute__((always_inline, visibility("hidden")))
NSString* EncryptUserToken(NSString *userName, NSString *string);


// decrypt
__attribute__((always_inline, visibility("hidden")))
NSString* DecryptText(NSString *userName, NSString *string);

__attribute__((always_inline, visibility("hidden")))
NSString* DecryptDeviceToken(NSString *userName, NSString *string);

__attribute__((always_inline, visibility("hidden")))
NSString* DecryptUserToken(NSString *userName, NSString *string);

@interface ITServerHelper : NSObject

+ (void)setup_Server;
+ (void)twitterInit;
+ (void)facebookInitWithOptions:(NSDictionary *)options;
+ (void)test_server_Connection;

+ (void)signupUserWithInfo:(NSDictionary *)userInfo andAvatarImage:(UIImage *)userImage fromtarget:(id)target completion:(iMBooleanResultBlock)completion;

// Likes
+ (void)likePost:(PFObject *)post byUser:(PFUser *)user withBlock:(iMBooleanResultBlock)compeltion;
+ (void)disLikePost:(PFObject *)post byUser:(PFUser *)user withBlock:(iMBooleanResultBlock)compeltion;

// checks
+ (void)isAppInstalledByCurrentUser:(PFObject *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion;
+ (void)isAppFavoritedByCurrentUser:(PFObject *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion;
+ (void)isAppSharedByCurrentUser:(NSString *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion;
+ (void)isAppExisteOnServer:(ITAppObject *)app withBlock:(iMBooleanWithoutErrorResultBlock)compeltion;
+ (void)isPostLikedByCurrentUser:(PFObject *)object withBlock:(iMBooleanWithoutErrorResultBlock)compeltion;
+ (void)isThisUser:(PFUser *)firstUser followThisUser:(PFUser *)secondUser withBlock:(iMBooleanWithArrayResultBlock)compeltion;
+ (void)isThisUserExiste:(NSString *)user withBlock:(iMBooleanWithArrayResultBlock)compeltion;
+ (void)isTeamUSER:(PFUser *)user withBlock:(iMBooleanWithoutErrorResultBlock)compeltion;
+ (BOOL) array:(NSArray *)array containsPFObjectById:(PFObject *)object;
+ (NSString *)sha1:(NSString *)str;
+ (NSString *)md5:(NSString *)str;
+ (NSData *)AES128EncryptData:(NSData *)data WithKey:(NSString *)key;

// requests
+ (void)requestEmailConfirmationForUser:(PFUser *)user fromTarget:(id)target;
+ (void)requestResetPasswordForUser:(PFUser *)user fromTarget:(id)target;

// get
+ (void)getFavoritesForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion;
+ (void)getInstallationsForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion;
+ (void)getFollowersForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion;
+ (void)getFollowingForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion;
+ (void)getAllFollowersForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)compeltion;
+ (void)getAllFollowingForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)compeltion;
+ (void)getLinkFromAppID:(NSString *)appID andVersion:(NSString *)appVersion withBlock:(iMObjectBooleanResultBlock)completion;
+ (void)getAppsForUser:(PFUser *)user withBlock:(iMIntegerResultBlock)compeltion;
+ (void)getAllPostsForUser:(PFUser *)user limit:(NSNumber *)limit skip:(NSNumber *)skip withBlock:(iMBooleanWithArrayResultBlock)compeltion;
+ (void)getAllPostsForUser:(PFUser *)user withID:(NSString *)postID andSection:(NSString *)sectionName limit:(NSNumber *)limit skip:(NSNumber *)skip withBlock:(iMBooleanWithArrayResultBlock)compeltion;
+ (void)getAllPostsForUserFollowers:(PFUser *)user limit:(NSNumber *)limit skip:(NSNumber *)skip withBlock:(iMBooleanWithArrayResultBlock)compeltion;
+ (void)getActivitiesForUser:(PFUser *)user withBlock:(iMBooleanWithArrayResultBlock)compeltion;
+ (void)getAllCustomAppsForCat:(NSString *)cat withBlock:(iMBooleanWithArrayErrorResultBlock)compeltion;
+ (void)getAllManagedAppsForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)completion;
+ (void)getAllTranslatorsWithBlock:(iMBooleanWithArrayErrorResultBlock)completion;

+ (void)saveApp:(ITAppObject *)appObject toDatabaseWithBlock:(iMBooleanResultBlock)completion;
+ (void)saveAppVersion:(NSString *)appVersion forAppID:(NSString *)appID withURLString:(NSString *)downloadUrlString withBlock:(iMBooleanResultBlock)completion;
+ (void)saveManagedApp:(ITAppObject *)app forUser:(PFUser *)user andAccountType:(NSString *)accountType withBlock:(iMBooleanWithArrayErrorResultBlock)completion;
+ (void)getAllRequestedAppsForUser:(PFUser *)user withBlock:(iMBooleanWithArrayErrorResultBlock)completion;
// remove
+ (void)removeAllRequestedAppsForUser:(PFUser *)user;
+ (void)removeAllManagedAppsForUser:(PFUser *)user;
@end
