//
//  BAAppEditorViewController.h
//  baytapps
//
//  Created by iMokhles on 31/10/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITHelper.h"

@interface BAAppEditorViewController : UIViewController
@property (nonatomic, strong) ITAppObject *appToEdit;
@property (nonatomic, readwrite) Boolean isCydia;

@property (nonatomic, copy) void (^requestCellBlock)(BAAppEditorViewController * popupVC, NSString *icon, NSString *appName, NSString *appDuplicates);
@end
