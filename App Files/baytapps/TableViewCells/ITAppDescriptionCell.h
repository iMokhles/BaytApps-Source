//
//  ITAppDescriptionCell.h
//  ioteam
//
//  Created by iMokhles on 12/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"

@interface ITAppDescriptionCell : UITableViewCell
@property (nonatomic, assign) BOOL isMoreButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (nonatomic, strong) IBOutlet UITextView *appDescriptionLabel;

@property (assign, nonatomic) BOOL isInformation;
@property (nonatomic, copy) void (^moreButtonTappedBlock)(ITAppDescriptionCell *appCell, UIButton *moreBtn);

- (void)configureWithTweakedAppDescription:(NSString *)appDescription andTitle:(NSString *)title;
- (void)configureWithAppDescription:(NSAttributedString *)appDescription andTitle:(NSString *)title;
@end
