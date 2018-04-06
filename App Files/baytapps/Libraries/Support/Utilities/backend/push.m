//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>

#import "AppConstant.h"

#import "push.h"

#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserAssign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//	PFInstallation *installation = [PFInstallation currentInstallation];
//	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
//	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) // // NSLog(@"ParsePushUserAssign save error.");
//	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserResign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//	PFInstallation *installation = [PFInstallation currentInstallation];
//	[installation removeObjectForKey:PF_INSTALLATION_USER];
//	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) // // NSLog(@"ParsePushUserResign save error.");
//	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification_activity(NSString *text, PFUser *userTo)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *message = [NSString stringWithFormat:@"%@", text];
    
    if (userTo[USER_DEVICE_PLAYER_ID]) {
      //  AppDelegate *appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [OneSignal postNotification:@{
                                      @"isIos": @YES,
                                      @"ios_badgeType": @"Increase",

                                      @"contents" : @{@"en": @"Test Message"},
                                      @"include_player_ids": @[@"3009e210-3166-11e5-bc1b-db44eb02b120"]
                                      }];
//        [appDele.oneSignal postNotification:@{
//                                              @"isIos": @YES,
//                                              @"ios_badgeType": @"Increase",
//                                              @"ios_badgeCount": @1,
//                                              @"contents": @{@"en": message},
//                                              @"include_player_ids": @[userTo[USER_DEVICE_PLAYER_ID]],
//                                              
//                                              }onSuccess:^(NSDictionary *result) {
//                                                  // // NSLog(@"****** %@", result);
//                                              } onFailure:^(NSError *error) {
//                                                   // NSLog(@"****** ERROR %@", error.localizedDescription);
//                                              }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification(NSString *groupId, NSString *text, PFUser *userTo)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	NSString *message = [NSString stringWithFormat:@"%@: %@", user[PF_USER_FULLNAME], text];
    
    if (userTo[USER_DEVICE_PLAYER_ID]) {
        AppDelegate *appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [OneSignal postNotification:@{
                                     @"isIos": @YES,
                                     @"ios_badgeType": @"Increase",
                                     @"ios_badgeCount": @1,
                                     @"contents" : @{@"en": @"Test Message"},
                                     @"data": @{@"groupId": groupId,
                                                @"userObjectID": user.objectId},
                                     @"include_player_ids": @[@"3009e210-3166-11e5-bc1b-db44eb02b120"]
                                     }];
        
        
                                    
//        [appDele.oneSignal postNotification:@{
//                                              @"isIos": @YES,
//                                              @"ios_badgeType": @"Increase",
//                                              @"ios_badgeCount": @1,
//                                              @"contents": @{@"en": message},
//                                              @"data": @{@"groupId": groupId,
//                                                         @"userObjectID": user.objectId},
//                                              @"include_player_ids": @[userTo[USER_DEVICE_PLAYER_ID]],
//                                              
//                                              }onSuccess:^(NSDictionary *result) {
////                                                  // // NSLog(@"****** %@", result);
//                                              } onFailure:^(NSError *error) {
//                                                  // // NSLog(@"****** ERROR %@", error.localizedDescription);
//                                              }];
    }


//
//	PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
//	[query whereKey:PF_RECENT_GROUPID equalTo:groupId];
//	[query whereKey:PF_RECENT_USER notEqualTo:user];
//	[query includeKey:PF_RECENT_USER];
//	[query setLimit:1000];
//
//	PFQuery *queryInstallation = [PFInstallation query];
//	[queryInstallation whereKey:PF_INSTALLATION_USER matchesKey:PF_RECENT_USER inQuery:query];
//
//	PFPush *push = [[PFPush alloc] init];
//	[push setQuery:queryInstallation];
//	[push setMessage:message];
//	[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) // // NSLog(@"SendPushNotification send error.");
//	}];
}
