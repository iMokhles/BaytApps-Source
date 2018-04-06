//
//  ITHostCell.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITAppHoster.h"

@interface ITHostCell : UITableViewCell
- (void)configureWithHoster:(ITAppHoster *)appHoster;
@end
