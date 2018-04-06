//
//  BODeveloperTableViewCell.m
//  TotoaSU
//
//  Created by iMokhles on 30/09/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BODeveloperTableViewCell.h"
#import "BOTableViewCell+Subclass.h"
#import "BOTableViewCell+Private.h"

@interface BODeveloperTableViewCell () {
    UIView *devView;
    UIImageView *imageView;
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
}

@end
@implementation BODeveloperTableViewCell

- (void)setup {
    [super setup];
    
    self.expansionView = [self developerView];
}

- (UIView *)developerView {
    
    CGFloat width = self.bounds.size.width;
    devView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 80)];
    
    imageView = [[UIImageView alloc] init];
    CGRect imageRect = CGRectMake(10.0, 10.0, 60.0, 60.0);
//    imageView.image = self.profileImage;
    [imageView setFrame:imageRect];
    CALayer *roundCorner = [imageView layer];
    [roundCorner setMasksToBounds:YES];
    [roundCorner setCornerRadius:30.0];
    [devView addSubview:imageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 18.0, width-78.0, 25.0)];
    _titleLabel.font = [UIFont systemFontOfSize:17.0f];
    _titleLabel.textColor = [UIColor whiteColor];
//    _titleLabel.text = self.profileName;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 1;
    [devView addSubview:_titleLabel];
    
    _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 43.0, width-78.0, 15.0)];
    _subTitleLabel.font = [UIFont systemFontOfSize:10.0f];
    _subTitleLabel.textColor = [UIColor whiteColor];
    [_subTitleLabel setAdjustsFontSizeToFitWidth:YES];
//    _subTitleLabel.text = self.profileDescription;
    _subTitleLabel.textAlignment = NSTextAlignmentLeft;
    _subTitleLabel.numberOfLines = 1;
    [devView addSubview:_subTitleLabel];
    
    
    return devView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    imageView.image = self.profileImage;
    _titleLabel.text = self.profileName;
    _subTitleLabel.text = self.profileDescription;
}
- (CGFloat)expansionHeight {
    return 80;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
