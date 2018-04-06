//
//  BAChooserViewController.h
//  baytapps
//
//  Created by iMokhles on 08/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "LGRefreshView.h"
#import "DGActivityIndicatorView.h"
#import "ITHelper.h"
#import "BAHelper.h"
#import "BAColorsHelper.h"
#import "Definations.h"
#import "AppConstant.h"
#import "PFUser+Util.h"

@interface BAChooserViewController : UIViewController
@property (nonatomic, assign) BOOL loadSupportOnly;

@property (nonatomic, copy) void (^userTappedBlock)(BAChooserViewController *chooserViewController, PFUser *selectedUser);
@end
