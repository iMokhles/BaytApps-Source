//
//  BAChooserCell.h
//  baytapps
//
//  Created by iMokhles on 08/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "ITHelper.h"
#import "BAHelper.h"

@interface BAChooserCell : UITableViewCell
@property (nonatomic, assign) BOOL isSupportCell;
- (void)configureWithUser:(PFUser *)user;
@end
