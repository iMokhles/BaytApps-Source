//
//  BAProfileViewController.h
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"

@interface BAProfileViewController : UIViewController
@property (nonatomic, strong) PFUser *mainUser;

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger previousPage;
@end
