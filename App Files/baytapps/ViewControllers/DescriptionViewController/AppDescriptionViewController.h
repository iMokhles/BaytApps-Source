//
//  AppDescriptionViewController.h
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITAppObject.h"

@interface AppDescriptionViewController : UIViewController
@property (nonatomic, strong) ITAppObject *object;
@property (nonatomic, assign) BOOL isCydiaApp;

@end
