//
//  BASideMenuCell.h
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>

@interface BASideMenuCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *cellBadgeLabel;

- (void)configureWithIcon:(UIImage *)cellIcon andTitle:(NSString *)cellTitle;

// if has badge
@property (assign, nonatomic) BOOL enableBadgeView;

@property (assign, nonatomic) BOOL isCellSelected;
@end
