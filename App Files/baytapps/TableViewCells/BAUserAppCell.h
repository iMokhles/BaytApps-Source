//
//  BAUserAppCell.h
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"

@interface BAUserAppCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cellBackgroundImageView;

- (void)configureWithObject:(PFObject *)appObject;
@end
