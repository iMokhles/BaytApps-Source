//
//  BAAppCell.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BABrowserAppCell.h"
#import "BAHelper.h"

@interface BABrowserAppCell () {
    BOOL isAppManager;
}
@property (strong, nonatomic) IBOutlet UIImageView *appImageView;


@property (nonatomic, strong) PFObject *currentObject;

@end

@implementation BABrowserAppCell


- (void)configureWithPFObject:(PFObject *)appObject {
    isAppManager = NO;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[APP_NAME_STRING];
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
}
- (void)configureWithObject:(PFObject *)appObject {
    isAppManager = NO;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[APP_NAME_STRING];
    
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
}

- (void)configureWithManagerObject:(PFObject *)appObject {
    isAppManager = YES;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[USER_APP_MANAGER_APP_NAME];
  
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[USER_APP_MANAGER_APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
}

- (void)configureWithApp:(ITAppObject *)app {
    isAppManager = NO;
    _appNameLabel.text = app.appName;
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:app.appIcon] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupUI];
    
    
}

- (void)setupUI {
    _appImageView.layer.masksToBounds = YES;
    _appImageView.layer.cornerRadius = 15;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
          
        [self.contentView setNeedsLayout];
        [self.contentView layoutIfNeeded];
        
        _cellBackgroundImageView.layer.masksToBounds = YES;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_cellBackgroundImageView.bounds byRoundingCorners:(UIRectCornerTopRight) cornerRadii:CGSizeMake(40, 40)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.contentView.bounds;
        maskLayer.path = maskPath.CGPath;
        
        _cellBackgroundImageView.layer.mask = maskLayer;
        
        UIBezierPath *maskPathBG = [UIBezierPath bezierPathWithRoundedRect:self.selectedBackgroundView.bounds byRoundingCorners:(UIRectCornerTopRight) cornerRadii:CGSizeMake(40, 40)];
        CAShapeLayer *maskLayerBG = [CAShapeLayer layer];
        maskLayerBG.frame = self.contentView.bounds;
        maskLayerBG.path = maskPathBG.CGPath;
        self.selectedBackgroundView.layer.mask = maskLayerBG;
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
