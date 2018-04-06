//
//  BAProgressViewController.h
//  baytapps
//
//  Created by iMokhles on 29/10/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"

@interface BAProgressViewController : UIViewController

@property (nonatomic, strong) NSString *appNameString;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *appIconLink;
@property (nonatomic, assign) NSInteger dupliNumber;

@property (nonatomic, strong) ITAppObject *requestedApp;
@property (nonatomic, strong) NSString *requestedUrlString;

- (void)startDownloadingAppFromLink:(NSString *)appLink appInfo:(ITAppObject *)appInfo;
@end
