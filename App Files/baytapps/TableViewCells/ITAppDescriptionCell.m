//
//  ITAppDescriptionCell.m
//  ioteam
//
//  Created by iMokhles on 12/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITAppDescriptionCell.h"

@interface ITAppDescriptionCell ()

@end
@implementation ITAppDescriptionCell

- (void)configureWithAppDescription:(NSAttributedString *)appDescription andTitle:(NSString *)title {
    _appDescriptionLabel.textColor = [UIColor whiteColor];
    _appDescriptionLabel.attributedText = appDescription;
    _titleLabel.text = title;
}
- (void)configureWithTweakedAppDescription:(NSString *)appDescription andTitle:(NSString *)title {
    _appDescriptionLabel.textColor = [UIColor whiteColor];
    _appDescriptionLabel.text = appDescription;
    _titleLabel.text = title;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_appDescriptionLabel setContentOffset:CGPointZero animated:YES];
    [_appDescriptionLabel scrollRangeToVisible:NSMakeRange(0, 1)];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isMoreButton) {
        [self.appDescriptionLabel setScrollEnabled:NO];
        [_moreButton setHidden:NO];
    } else {
        if (self.isInformation) {
            [self.appDescriptionLabel setScrollEnabled:NO];
        } else {
            [self.appDescriptionLabel setScrollEnabled:YES];
        }
        [_moreButton setHidden:YES];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)moreTapped:(UIButton *)sender {
    self.moreButtonTappedBlock(self, sender);
}

@end
