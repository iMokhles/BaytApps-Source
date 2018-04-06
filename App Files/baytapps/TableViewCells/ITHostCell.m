//
//  ITHostCell.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITHostCell.h"

@interface ITHostCell ()
@property (strong, nonatomic) IBOutlet UIView *verifiedView;
@property (strong, nonatomic) IBOutlet UILabel *hostNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *crackerNameLabel;
@property (nonatomic, strong) ITAppHoster *currentHost;
@end

@implementation ITHostCell

- (void)configureWithHoster:(ITAppHoster *)appHoster {
    self.currentHost = appHoster;
    _hostNameLabel.text = appHoster.hosterName;
    _crackerNameLabel.text = appHoster.hosterCracker;
    if ([appHoster isVerified]) {
        _verifiedView.backgroundColor = [UIColor greenColor];
    } else {
        _verifiedView.backgroundColor = [UIColor orangeColor];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _verifiedView.layer.masksToBounds = YES;
    _verifiedView.layer.cornerRadius = _verifiedView.frame.size.width/2.0;
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
