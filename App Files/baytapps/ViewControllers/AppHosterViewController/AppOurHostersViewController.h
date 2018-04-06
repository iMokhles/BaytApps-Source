//
//  AppHostersViewController.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"

@interface AppOurHostersViewController : UIViewController
@property (nonatomic, strong) ITAppObject *app;
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, readwrite) Boolean isOurHost;
@property (nonatomic, readwrite) Boolean isCydia;


@end
