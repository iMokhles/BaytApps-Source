//
//  Definations.h
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#ifndef Definations_h
#define Definations_h

#ifndef DEFINE_SHARED_INSTANCE_GCD_USING_BLOCK
#define DEFINE_SHARED_INSTANCE_GCD_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;
#endif


#if __has_attribute(objc_designated_initializer)
#define SLK_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#endif

// -----------------------

// twitter ids
#define TWITTER_CONSUMER_KEY  @"LtYRB2np068cp7kjnwksmzQbQ"
#define TWITTER_CONSUMER_SECRET  @"pEZk61aC0LAG5h2XkW5qeHXmnIij4OZPkmdCaSGtYm5Y98ikDN"

// onesignal id
#define ONE_SIGNAL_KEY @"e70ce7be-53d0-4ed7-92dd-a6e48222e2d2"

// ------------------------
#define App_Hoster_Page_ID @"appHostersPageID"
#define APP_NAME @"BaytApps"
#define App_OurHoster_Page_ID @"appOurHostersPageID"

// ------------------------

// social classes
#define USER_CLASS_NAME                 @"_User"
#define USER_AVATAR                     @"avatar"
#define USER_THUMBNAIL                  @"thumbnail"
#define USER_COVER_IMAGE                @"coverImage"
#define USER_USERNAME                   @"username"
#define USER_FULLNAME                   @"fullName"
#define USER_FULLNAMELOWER              @"fullnameLower"
#define USER_EMAIL                      @"email"
#define USER_EMAILCOPY                  @"emailCopy"
#define USER_FACEBOOKID                 @"facebookId"
#define USER_TWITTERID                  @"twitterId"
#define USER_EMAIL_VERIFIED             @"emailVerified"
#define USER_ABOUT_ME                   @"aboutMe"
#define USER_DEVICE_TOKEN               @"deviceToken_Push"
#define USER_DEVICE_ID                  @"user_DeviceID"
#define USER_EXPIRY_DATE                @"expiryDate"
#define USER_DEVICE_TYPE                @"deviceType"
#define USER_TEAM_ID                    @"teamID"
#define USER_BUNDLE_ID                    @"bundleID"

#define USER_DEVICE_PLAYER_ID           @"userPlayer_ID"

#define USER_DeviceName           @"DeviceName"
#define USER_PERMISSION           @"Permission"
#define USER_isJailbreak           @"isJailbreak"

#define USER_Resolution           @"Resolution"

#define USER_Deviceid           @"Deviceuuid"


#define USER_PASS_WORD                  @"user_Password"
#define USER_Vio                  @"user_vio"

#define USER_CONF_PASS_WORD             @"conf_User_Password"
#define USER_ALREADY_LOGGED             @"user_already_logged"
#define	USER_LOCATION					@"location"
#define	USER_APP_VERSION				@"bayt_Version"
#define	USER_LINKED_FACEBOOK			@"linkedToFacebook"
#define	USER_LINKED_TWITTER             @"linkedToTwitter"

#define TWEAK_APP_DB_VERSIONS_CLASSE_NAME  @"TWEAK_AppsDB_Version"

#define TWEAK_APP_DB_CLASSE_NAME  @"TWEAK_AppsDB"

#define USER_ORDER_CLASS_NAME             @"Orders"
#define USER_ORDER_DATE                   @"endDate"
#define USER_ORDER_UDID                   @"orderUdid"
#define USER_ORDER_EMAIL                  @"orderEmail"
#define USER_ORDER_USER                   @"orderUser"
#define USER_ORDER_DEVICE                 @"orderDeviceType"
#define USER_ORDER_STATUS                 @"orderStatus"
#define USER_ORDER_ID                     @"orderNumber"

#define CHECK_UPDATE_CLASS_NAME                      @"CheckUpdate"
#define CHECK_UPDATE_APP_ID                          @"app_id"
#define CHECK_UPDATE_APP_TEAM_ID                     @"teamId"
#define CHECK_UPDATE_APP_VERSION                     @"app_version"
#define CHECK_UPDATE_CHANGE_LOG                      @"changeLog"
#define CHECK_UPDATE_INSTALL_URL                     @"updateInstallURL"

// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa/plist/baytapps.plist
// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa1/plist/baytapps.plist
// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa2/plist/baytapps.plist
// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa4/plist/baytapps.plist
// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa5/plist/baytapps.plist
// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa6/plist/baytapps.plist
// itms-services://?action=download-manifest&url=https://207.254.60.211/install/ipa7/plist/baytapps.plist


#define USER_APP_MANAGER_CLASS_NAME       @"AppManager"
#define USER_APP_MANAGER_USER_POINTER     @"appUser"
#define USER_APP_MANAGER_APP_NAME         @"appName"
#define USER_APP_MANAGER_APP_ID           @"appID"
#define USER_APP_MANAGER_APP_INFO         @"appInfo"
#define USER_APP_MANAGER_APP_LINK         @"appLink"
#define USER_APP_MANAGER_APP_ICON         @"appIcon"
#define USER_APP_Reuqested_CLASS_NAME       @"AppRequestedManager"

#define TRANSLATORS_CLASS_NAME       @"Translators"
#define TRANSLATORS_NAME         @"tanslatorName"
#define TRANSLATORS_ID           @"twitterID"
#define TRANSLATORS_LANG           @"language"
#define TRANSLATORS_VERIFIED         @"isVerified"

#define USER_PURCHASED_ADS @"purchasedAds"
#define USER_PURCHASED_OR @"purchasedOR"
#define USER_PURCHASED_OR_DATE @"purchasedOR_Date"
#define USER_PURCHASED_LIM @"purchasedLim"
#define USER_PURCHASED_LIM_DATE @"purchasedLim_Date"

#define TEAM_USERS_CLASS_NAME   @"TEAM"
#define TEAM_USERS_USER_POINTER @"teamUser"


#define FOLLOW_CLASS_NAME  @"Follow"
#define FOLLOW_A_USER  @"aUser"
#define FOLLOW_IS_FOLLOWING  @"isFollowing"

#define APP_CLASSE_NAME  @"Apps"
#define APP_ICON  @"appIcon"
#define APP_URL_LOWERCASE  @"appUrlLowercase"
#define APP_USER_POINTER  @"appUser"
#define APP_LIKES  @"likes"
#define APP_ID  @"appID"
#define APP_SECTION_ID  @"sectionID"
#define APP_TRACK_ID @"appTrackID"
#define APP_NAME_STRING @"appName"
#define APP_VERSION @"appVersion"
#define APP_INFO_DICT @"appInfo"
#define APP_DATE  @"createdAt"
#define APP_DOWNLOAD_LINK  @"downloadLink"
#define APP_DOWNLOAD_HOST @"linkHost"

#define APP_DB_CLASSE_NAME  @"AppsDB"
#define APP_DB_ICON  @"appIcon"
#define APP_DB_ID  @"appID"
#define APP_DB_NAME_STRING @"appName"
#define APP_DB_INFO_DICT @"appInfo"

#define APP_DB_VERSIONS_CLASSE_NAME  @"AppsDB_Version"
#define APP_DB_VERSIONS_APP_ID  @"appID"
#define APP_DB_VERSIONS_VERSION_STRING @"appVersion"
#define APP_DB_VERSIONS_URL_LOWERCASE  @"downloadUrlLowercase"

#define CUSTOM_APP_CLASSE_NAME  @"CustomApps"
#define CUSTOM_APP_ICON  @"appIcon"
#define CUSTOM_APP_INSTALL_URL_LOWERCASE  @"installAppUrlLowercase"
#define CUSTOM_APP_ID  @"appID"
#define CUSTOM_APP_SECTION_ID  @"sectionID"
#define CUSTOM_APP_NAME_STRING @"appName"
#define CUSTOM_APP_VERSION @"appVersion"
#define CUSTOM_APP_INFO_DICT @"appInfo"


#define LIKES_CLASS_NAME  @"Likes"
#define LIKES_LIKED_BY  @"likedBy"
#define LIKES_APP_LIKED  @"appLiked"

#define FAVORITES_CLASS_NAME  @"Favorites"
#define FAVORITES_FAVORITED_BY  @"favoritedBy"
#define FAVORITES_APP_FAVORITED  @"appFavorited"

#define CLOUD_APPS_CLASS_NAME  @"Cloud"
#define CLOUD_APP_INFO  @"appInfo"
#define CLOUD_APP_VERSION  @"appVersion"
#define CLOUD_APP_ID  @"appID"
#define CLOUD_APP_TRACK_ID @"appTrackID"
#define CLOUD_APP_NAME_STRING @"appName"

#define INSTALLATIONS_CLASS_NAME  @"Installations"
#define INSTALLATIONS_INSTALLED_BY  @"installedBy"
#define INSTALLATIONS_APP_INSTALLED  @"appInstalled"

#define ACTIVITY_CLASS_NAME  @"Activity"
#define ACTIVITY_CURRENT_USER  @"currentUser"
#define ACTIVITY_OTHER_USER  @"otherUser"
#define ACTIVITY_TYPE  @"type"
#define ACTIVITY_TEXT  @"text"


#endif /* Definations_h */
