//
//  BAHelper.h
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <SafariServices/SafariServices.h>

#import "HCSStarRatingView.h"
#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "FLEXManager.h"
#import "UIImageView+WebCache.h"
#import "Definations.h"
#import "ITAppObject.h"
#import "KVNProgress.h"
#import "MMGridView.h"
#import "MMGridViewDefaultCell.h"
#import "KSToastView.h"
#import "PKBorderedButton.h"
#import "EXPhotoViewer.h"
#import "UIImageView+Letters.h"
#import "SBJson.h"

// frameworks
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <ParseUI/ParseUI.h>
#import <Bolts/Bolts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <OneSignal/OneSignal.h>

#import "BFKit/BFKit.h"

typedef void(^ImageDownloaderCompletedBlock)(UIImage *image, NSData *data, NSError *error, BOOL finished);

@interface BAHelper : NSObject

+(BAHelper *)sharedInstance;

+ (NSString*)getLibraryPath;
+ (NSString*)getDocumentsPath;

+ (BOOL)isIPHONE;
+ (BOOL)isIPHONE4;
+ (BOOL)isIPHONE5;
+ (BOOL)isIPHONE6;
+ (BOOL)isIPHONE6PLUS;
+ (BOOL)isIPAD;
+ (BOOL)systemVersionGreaterThanOrEqual:(NSString *)number;
+ (void)stayLTR;
+ (void)checkForUpdate;

+ (void)searchForString:(NSString *)searchString withCompletion:(void(^)(NSDictionary *dataDict))completion;
+ (void)searchImageForString:(NSString *)searchString withCompletion:(void(^)(NSDictionary *dataDict))completion;
+ (void)saveImageFromURL:(NSURL *)imageURL withCompletion:(ImageDownloaderCompletedBlock)completion;
+ (UIImage *)currentLocalImage;
+ (NSString *)shortDate:(NSDate *)date;
- (void)testServer;

//**********************************************************************//
//********************* GRAPHICAL ANIMATION EFFECTS ********************//
//**********************************************************************//

// 0 - Slide -> From left or right or top or bottom
// 1 - Fade In
// 2 - Fade Out
// 3 - Fade Out and when finish fade In
// 4 - Bounce
// 5 - Slide and Shake
// 6 - Fade in and Bounce
// 7 - Shake
// 8 - Rotate
// 9 - Jump

//0-
-(void)move:(UIView *)image duration:(NSTimeInterval)duration curve:(int)curve x:(CGFloat)x y:(CGFloat)y;

//1-
-(void)fadeIn: (UIView*)theView duration:(float)duration delay:(float)delay;

//2-
-(void)fadeOut: (UIView*)theView duration:(float)duration delay:(float)delay;

//3-
-(void)fadeOutIn: (UIView*)theView duration:(float)duration delay:(float)delay;

//4-
-(void)bounce: (UIView*)theView repeat:(int)repeats duration:(int)duration distance:(int)distance horizontal:(BOOL)horizontal vertical:(BOOL)vertical;

//5-
-(void)moveAndShake:(UIView *)image duration:(NSTimeInterval)duration curve:(int)curve x:(CGFloat)x y:(CGFloat)y;

//6-
-(void)fadeInAndBounce: (UIView*)theView duration:(float)duration delay:(float)delay numberOfBounces:(int)bounces;

//7-
-(void)shake: (UIView*)theView;

//8-
-(void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;

//9-
-(void)jump: (UIView*)view_ duration:(float)duration distance:(int)distance;
@end
