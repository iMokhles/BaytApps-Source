//
//  BAAppCell.h
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"

@interface BAAppCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *appAvailableView;
@property (strong, nonatomic) IBOutlet UIImageView *cellBackgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *appNameLabel;

- (void)configureWithPFObject:(PFObject *)object;
- (void)configureWithApp:(ITAppObject *)app;
- (void)configureWithObject:(PFObject *)appObject;
- (void)configureWithManagerObject:(PFObject *)appObject;
- (void)configureWithObjectForNewManager:(PFObject *)appObject;

// if tweaked app cell
@property (assign, nonatomic) BOOL isTweakCell;
@end
