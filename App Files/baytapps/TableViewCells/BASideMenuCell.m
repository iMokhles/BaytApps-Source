//
//  BASideMenuCell.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BASideMenuCell.h"
#import "BAColorsHelper.h"

@interface BASideMenuCell ()
@property (strong, nonatomic) IBOutlet UIImageView *cellIconView;
@property (strong, nonatomic) IBOutlet UILabel *cellTitleLabel;

@property (strong, nonatomic) IBOutlet UIView *cellBadgeView;
@end


@implementation BASideMenuCell

- (void)configureWithIcon:(UIImage *)cellIcon andTitle:(NSString *)cellTitle {
    
    self.cellIconView.image = cellIcon;
    self.cellTitleLabel.text = cellTitle;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupUI];
    
    
}

- (void)setupUI {
    _cellBadgeLabel.layer.masksToBounds = YES;
    _cellBadgeLabel.layer.cornerRadius = 10.5;
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.enableBadgeView == YES) {
        [_cellBadgeLabel setHidden:NO];
    } else {
        [_cellBadgeLabel setHidden:YES];
    }
    
    if (self.isCellSelected == YES) {
        _cellTitleLabel.textColor = [BAColorsHelper sideMenuCellSelectedColors];
        
        UIImage *cellIcon_ = [self.cellIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        [self.cellIconView setImage:cellIcon_];
//        [self.cellIconView setTintColor:[BAColorsHelper sideMenuCellSelectedColors]];
    } else {
        _cellTitleLabel.textColor = [BAColorsHelper sideMenuCellColor];
        
        UIImage *cellIcon_ = [self.cellIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        [self.cellIconView setImage:cellIcon_];
//        [self.cellIconView setTintColor:[BAColorsHelper sideMenuCellSelectedColors]];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
