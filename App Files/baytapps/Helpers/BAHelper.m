//
//  BAHelper.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAHelper.h"
//#import "UICKeyChainStore.h"
#import "ITHelper.h"
#import "BAUpdateLogsViewController.h"
#import "AppDelegate.h"

#define SLK_IS_IPHONE4           (SLK_IS_IPHONE && SLKKeyWindowBounds().size.height < 568.0)
#define SLK_IS_IPHONE5           (SLK_IS_IPHONE && SLKKeyWindowBounds().size.height == 568.0)
#define SLK_IS_IPHONE6           (SLK_IS_IPHONE && SLKKeyWindowBounds().size.height == 667.0)
#define SLK_IS_IPHONE6PLUS       (SLK_IS_IPHONE && SLKKeyWindowBounds().size.height == 736.0 || SLKKeyWindowBounds().size.width == 736.0) // Both orientations

#define Search_API_KEY @"AIzaSyCaxF4wbU099p0iNOgfxjcEGRZgHUD6__U"

NSString * const kGoogleSearchBaseURL = @"https://www.googleapis.com/customsearch/v1";
NSString * const kGoogleSearchEngineId = @"011387016634526722520:i-ekolo9cui";
NSString * const kGoogleSearchAPIKey = @"AIzaSyCaxF4wbU099p0iNOgfxjcEGRZgHUD6__U";

NSString* const RESPONSE_TIMEOUT_SEARCH = @"responseTimeout";

@interface BAHelper () <UIAlertViewDelegate>

@end
@implementation BAHelper

+ (BAHelper *)sharedInstance {
    
    static BAHelper *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance ==nil){
            instance = [[BAHelper alloc] init];
        }
    });
    
    return instance;
}

+ (NSString *)getLibraryPath {
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return libraryPath;
}

+ (NSString*)getDocumentsPath {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex: 0];
    return documentPath;
}

+ (CGRect)windowBounds {
    return [[UIApplication sharedApplication] keyWindow].bounds;
}
+ (BOOL)isIPHONE {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}
+ (BOOL)isIPAD {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isIPHONE4 {
    return ([BAHelper isIPHONE] && [BAHelper windowBounds].size.height < 568.0);
}
+ (BOOL)isIPHONE5 {
    return ([BAHelper isIPHONE] && [BAHelper windowBounds].size.height == 568.0);
}
+ (BOOL)isIPHONE6 {
    return ([BAHelper isIPHONE] && [BAHelper windowBounds].size.height == 667.0);
}
+ (BOOL)isIPHONE6PLUS {
    return ([BAHelper isIPHONE] && ([BAHelper windowBounds].size.height == 736.0 || [BAHelper windowBounds].size.width == 736.0));
}
+ (BOOL)systemVersionGreaterThanOrEqual:(NSString *)number {
    return  ([[[UIDevice currentDevice] systemVersion] compare:number options:NSNumericSearch] != NSOrderedAscending);
}
+ (void)stayLTR {
    
    if ([BAHelper systemVersionGreaterThanOrEqual:@"9.0"]) {
        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class], [UIAlertView class], [UIButton class], [UILabel class], [UITextField class], [UITextView class], [UIAlertController class], [UIViewController class], [UIView class], [UIImageView class], [UIScrollView class]]] setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
    }
}

+ (void)checkForUpdate {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    PFQuery *checkUpdate = [PFQuery queryWithClassName:CHECK_UPDATE_CLASS_NAME];
    // NSLog(@"%@",[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]);
    [checkUpdate whereKey:CHECK_UPDATE_APP_ID equalTo:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    [checkUpdate whereKey:CHECK_UPDATE_APP_TEAM_ID equalTo:[[ITHelper accountType] lowercaseString]];
    [checkUpdate findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count == 1) {
                PFObject *currentUpdate = [objects objectAtIndex:0];
                NSString *versionInServer = currentUpdate[CHECK_UPDATE_APP_VERSION];
                NSString *localAppVersion = infoDictionary[@"CFBundleShortVersionString"];
               
                if ([versionInServer compare:localAppVersion options:NSNumericSearch] == NSOrderedDescending) {
                    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                  
                    app.isUpdateExist = YES;
                    [app changeBadge];

//                    BAUpdateLogsViewController *updateLogVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"updateLogVC"];
//                    updateLogVC.updateLog = currentUpdate;
//                    updateLogVC.modalPresentationStyle = UIModalPresentationFormSheet;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[ITHelper rootViewController] presentViewController:updateLogVC animated:YES completion:^{
//                            
//                        }];
//                    });
                    
                }
            }
        } else {
            // // NSLog(@"ERROR UPDATE: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Google Search

+ (void)searchImageForString:(NSString *)searchString withCompletion:(void(^)(NSDictionary *dataDict))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"%@?q=%@&cx=%@&num=9&key=%@&searchType=image", kGoogleSearchBaseURL, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], kGoogleSearchEngineId, kGoogleSearchAPIKey];
    [self getMethodWithURL:urlString withCompletion:^(NSData *data, NSError *error) {
        completion([NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]);
    }];
}

+ (void)searchForString:(NSString *)searchString withCompletion:(void(^)(NSDictionary *dataDict))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@?q=%@&cx=%@&num=9&key=%@", kGoogleSearchBaseURL, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], kGoogleSearchEngineId, kGoogleSearchAPIKey];
    [self getMethodWithURL:urlString withCompletion:^(NSData *data, NSError *error) {
        completion([NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]);
    }];
}

+ (void)getMethodWithURL:(NSString *)urlString withCompletion:(void (^)(NSData *data, NSError *error))completion {
    
    NSString *methodURL = [NSString stringWithFormat:@"%@",urlString];
    NSString *urlEscaped = methodURL;
    NSURL *url = [NSURL URLWithString:urlEscaped];
    NSString *method = @"GET";
    NSMutableURLRequest * request = nil;
    
    // initialize request
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    [request setTimeoutInterval:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT_SEARCH]];
    NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
    [headersDictionary setObject:@"application/json" forKey:@"Content-Type"];
    [headersDictionary setObject:@"com.imokhles.IMSearch.MessagesExtension" forKey:@"X-Ios-Bundle-Identifier"];
    [request setAllHTTPHeaderFields:headersDictionary];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data, error);
    }];
    [task resume];
    
}

+ (void)saveImageFromURL:(NSURL *)imageURL withCompletion:(ImageDownloaderCompletedBlock)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismissWithCompletion:^{
                NSString *localFilePath = [[self getDocumentsPath] stringByAppendingPathComponent:@"savedImage.png"];
                if ([data writeToFile:localFilePath atomically:YES]) {
                    completion(image, data, error, YES);
                } else {
                    completion(image, data, error, NO);
                }
            }];
        });
    }];
    
}

+ (UIImage *)currentLocalImage {
    NSString *localFilePath = [[self getDocumentsPath] stringByAppendingPathComponent:@"savedImage.png"];
    
//    UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    NSString *changingStatus = [[NSUserDefaults standardUserDefaults] stringForKey:@"isChangingPaper"];

    NSData *thedata = [NSData dataWithContentsOfFile:localFilePath];
    UIImage *currentImage = [UIImage imageWithData:thedata];
    if ([changingStatus isEqualToString:@"NO"] || changingStatus.length < 1) {
        currentImage = [UIImage imageNamed:@"main_bg_6"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isChangingPaper"]) {
        return [UIImage imageNamed:@"main_bg_6"];
    }
    return currentImage;
}
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    exit(EXIT_FAILURE);
}
+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(EXIT_FAILURE);
}
+ (NSString *)shortDate:(NSDate *)date {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    return dateString;
}

- (void)move:(UIView *)image duration:(NSTimeInterval)duration curve:(int)curve x:(CGFloat)x y:(CGFloat)y
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
    
}
-(void)fadeIn: (UIView*)theView duration:(float)duration delay:(float)delay {
    theView.alpha = 0;
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         theView.alpha = 1;
                     }
                     completion:^(BOOL finished){
//                         // // NSLog(@"[Mobile Builder]---> Fade In Finished");
                     }];
}
-(void)fadeOut: (UIView*)theView duration:(float)duration delay:(float)delay {
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         theView.alpha = 0;
                     }
                     completion:^(BOOL finished){
//                         // // NSLog(@"[Mobile Builder]---> Fade Out Finished");
                     }];
}
-(void)fadeOutIn: (UIView*)theView duration:(float)duration delay:(float)delay {
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         theView.alpha = 0;
                     }
                     completion:^(BOOL finished){
//                         // // NSLog(@"[Mobile Builder]---> Fade Out Finished");
                         [UIView animateWithDuration:duration
                                               delay:delay
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              theView.alpha = 1;
                                          }
                                          completion:^(BOOL finished){
//                                              // // NSLog(@"[Mobile Builder]---> Fade In Finished");
                                          }];
                         
                     }];
    
    
}

-(void)bounce: (UIView*)theView repeat:(int)repeats duration:(int)duration distance:(int)distance horizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    if(horizontal == YES) {
        CGPoint origin = theView.center;
        CGPoint target = CGPointMake(theView.center.x- distance, theView.center.y);
        CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.x"]; //Animations for y axis
        bounce.duration = duration;
        bounce.fromValue = [NSNumber numberWithInt:origin.x];
        bounce.toValue = [NSNumber numberWithInt:target.x];
        bounce.repeatCount = repeats;
        bounce.autoreverses = YES; // undo changes after Animations.
        [theView.layer addAnimation: bounce forKey:@"position"];
    }
    if(vertical == YES) {
        CGPoint origin = theView.center;
        CGPoint target = CGPointMake(theView.center.x, theView.center.y-distance);
        CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.y"]; //Animations for y axis
        bounce.duration = duration;
        bounce.fromValue = [NSNumber numberWithInt:origin.y];
        bounce.toValue = [NSNumber numberWithInt:target.y];
        bounce.repeatCount = repeats;
        bounce.autoreverses = YES; // undo changes after Animations.
        [theView.layer addAnimation: bounce forKey:@"position"];
    }
}
- (void)moveAndShake:(UIView *)image duration:(NSTimeInterval)duration curve:(int)curve x:(CGFloat)x y:(CGFloat)y
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:4];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(image.center.x - 5,image.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(image.center.x + 5, image.center.y)]];
    [image.layer addAnimation:shake forKey:@"position"];
}
-(void)fadeInAndBounce: (UIView*)theView duration:(float)duration delay:(float)delay numberOfBounces:(int)bounces {
    theView.alpha = 0;
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         theView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         CGPoint origin = theView.center;
                         CGPoint target = CGPointMake(theView.center.x- 5, theView.center.y);
                         CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.x"]; //Animations for y axis
                         bounce.duration = 0.1;
                         bounce.fromValue = [NSNumber numberWithInt:origin.x];
                         bounce.toValue = [NSNumber numberWithInt:target.x];
                         bounce.repeatCount = bounces;
                         bounce.autoreverses = YES; // undo changes after Animations.
                         [theView.layer addAnimation: bounce forKey:@"position"];
                         
                     }];
}
-(void)shake: (UIView*)theView {
    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
    anim.autoreverses = YES ;
    anim.repeatCount = 2.0f ;
    anim.duration = 0.07f ;
    
    [ theView.layer addAnimation:anim forKey:nil ] ;
}
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
-(void)jump: (UIView*)view_ duration:(float)duration distance:(int)distance {
    NSTimeInterval durationUp = duration;
    
    [UIView animateWithDuration:durationUp delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect f = view_.frame;
                         f.origin.y -= distance;
                         view_.frame = f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:durationUp delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGRect f = view_.frame;
                                              f.origin.y += distance;
                                              view_.frame = f;
                                          }
                                          completion:nil];
                         
                         
                     }];
}

- (void)testServer {
    //UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isFirstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[keyWrapper removeAllItems];
    [ITHelper showLaunchOrMainView:NO];
}
@end
