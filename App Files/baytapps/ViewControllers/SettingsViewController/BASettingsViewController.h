//
//  BASettingsViewController.h
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BOTableViewSection.h"

@interface BASettingsViewController : UIViewController

/// The array of BOTableViewSections of the controller.
@property (nonatomic, readonly) NSArray *sections;

/// The setup method for the controller.
- (void)setup NS_REQUIRES_SUPER;

/// Adds a new section to the controller.
- (void)addSection:(BOTableViewSection *)section;

/// Add header to the controller
- (void)addHeaderWithTitle:(NSString *)headerTitle andSubtitle:(NSString *)headerSubtitle;

/// change colors
+ (instancetype)sharedInstance;
- (void)updateUIAppearnce;


@end
