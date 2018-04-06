//
//  BASupportViewController.h
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITHelper.h"
#import "ITServerHelper.h"
#import "BAColorsHelper.h"

@interface BASupportViewController : UIViewController

@property (nonatomic, assign) BOOL isNotificationAction;
@property (nonatomic, strong) PFUser *chatWithUser;
@property (nonatomic, strong) NSString *chatId;

@end
