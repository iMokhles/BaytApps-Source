//
//  BAUpdateLogsViewController.h
//  baytapps
//
//  Created by iMokhles on 18/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "ITHelper.h"
#import "BAHelper.h"
#import "Definations.h"
#import "ITServerHelper.h"
#import "JGProgressHUD.h"

@interface BAUpdateLogsViewController : UIViewController{
    JGProgressHUD *HUD;

}
@property (nonatomic, strong) PFObject *updateLog;
@end
