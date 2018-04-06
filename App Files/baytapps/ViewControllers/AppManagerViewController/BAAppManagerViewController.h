//
//  BAAppManagerViewController.h
//  baytapps
//
//  Created by iMokhles on 03/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITHelper.h"

@interface BAAppManagerViewController : UIViewController

@property (nonatomic, strong) NSString *appNameString;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *appIconLink;
@property (nonatomic, assign) NSInteger dupliNumber;
@property (nonatomic, readwrite) Boolean isCydia;
@property (nonatomic, strong) ITAppObject *requestedApp;
@property (nonatomic, strong) NSString *requestedUrlString;


@end
