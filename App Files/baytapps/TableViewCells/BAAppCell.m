//
//  BAAppCell.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAAppCell.h"
#import "BAHelper.h"
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

#import "UIImageView+WebCache.h"

@interface BAAppCell () {
    BOOL isAppManager;
}
@property (strong, nonatomic) IBOutlet UIImageView *appImageView;

@property (strong, nonatomic) IBOutlet UILabel *appCatLabel;
@property (strong, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *appRatingLabel;
@property (strong, nonatomic) IBOutlet HCSStarRatingView *appRatingStars;

@property (nonatomic, strong) ITAppObject *currentApp;
@property (nonatomic, strong) PFObject *currentObject;

@end

@implementation BAAppCell


-(void)prepareForReuse
{
    [super prepareForReuse];
    
//    [_appImageView sd_cancelCurrentImageLoad];
//    _appImageView.image = nil;
}

- (void)configureWithPFObject:(PFObject *)appObject {

    
    
    isAppManager = NO;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[APP_NAME_STRING];
    _appCatLabel.text = appObject[APP_ID];
    _appVersionLabel.text = [NSString stringWithFormat:@"v%@",appObject[CUSTOM_APP_VERSION]];
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
}
- (void)configureWithObject:(PFObject *)appObject {
    
    
    
    isAppManager = NO;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[APP_NAME_STRING];
    
    if (!self.isTweakCell) {
        
        if (![appObject[APP_INFO_DICT][@"last_parse_itunes"] isKindOfClass:[NSNull class]]) {

            if (appObject[APP_INFO_DICT][@"last_parse_itunes"] != nil) {
                NSLog(@"**** %@", appObject[APP_INFO_DICT][@"last_parse_itunes"]);
                NSData *data = [appObject[APP_INFO_DICT][@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
                id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *ratString = [[dict objectForKey:@"ratings"] objectForKey:@"current"];
                if (ratString.length == 0) {
                    _appRatingStars.value = 0;
                } else {
                    if ([ratString containsString:@"and a half"]) {
                        NSArray *substrings = [ratString componentsSeparatedByString:@" and a half stars"];
                        NSString *starsValue = [substrings objectAtIndex:0];
                        NSString *customValue = [NSString stringWithFormat:@"%@.5", starsValue];
                        _appRatingStars.value = [customValue floatValue];
                    } else {
                        NSArray *substrings = [ratString componentsSeparatedByString:@" stars"];
                        NSString *starsValue = [substrings objectAtIndex:0];
                        _appRatingStars.value = [starsValue intValue];
                    }
                    NSArray *substrings = [ratString componentsSeparatedByString:@", "];
                    NSString *starsValueRates = [substrings objectAtIndex:1];
                    _appRatingLabel.text = [NSString stringWithFormat:@"(%@)", starsValueRates];
                }
                _appCatLabel.text = [[dict objectForKey:@"genre"] objectForKey:@"name"];
            } else {
                _appCatLabel.text = appObject[APP_ID];
            }
            
        } else {
            _appCatLabel.text = appObject[APP_ID];
        }
        
    } else {
        _appCatLabel.text = appObject[APP_ID];
    }
    
    _appVersionLabel.text = appObject[APP_INFO_DICT][@"version"];
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
//    [_appImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appObject[APP_ICON]]]]];
}

- (void)configureWithManagerObject:(PFObject *)appObject {
    
    
    
    isAppManager = YES;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[USER_APP_MANAGER_APP_NAME];
    NSData *data = [appObject[USER_APP_MANAGER_APP_INFO][@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
    id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *ratString = [[dict objectForKey:@"ratings"] objectForKey:@"current"];
    if (ratString.length == 0) {
        _appRatingStars.value = 0;
    } else {
        if ([ratString containsString:@"and a half"]) {
            NSArray *substrings = [ratString componentsSeparatedByString:@" and a half stars"];
            NSString *starsValue = [substrings objectAtIndex:0];
            NSString *customValue = [NSString stringWithFormat:@"%@.5", starsValue];
            _appRatingStars.value = [customValue floatValue];
        } else {
            NSArray *substrings = [ratString componentsSeparatedByString:@" stars"];
            NSString *starsValue = [substrings objectAtIndex:0];
            _appRatingStars.value = [starsValue intValue];
        }
        NSArray *substrings = [ratString componentsSeparatedByString:@", "];
        NSString *starsValueRates = [substrings objectAtIndex:1];
        _appRatingLabel.text = [NSString stringWithFormat:@"(%@)", starsValueRates];
    }
    _appCatLabel.text = [[dict objectForKey:@"genre"] objectForKey:@"name"];
    _appVersionLabel.text = appObject[USER_APP_MANAGER_APP_INFO][@"version"];
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[USER_APP_MANAGER_APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
}

- (void)configureWithApp:(ITAppObject *)app {
    
    isAppManager = NO;
    self.currentApp = app;
    _appNameLabel.text = app.appName;
    if (!self.isTweakCell) {
        if (![app.appInfo[@"last_parse_itunes"] isKindOfClass:[NSNull class]]) {
            NSData *data = [app.appInfo[@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
            id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *ratString = [[dict objectForKey:@"ratings"] objectForKey:@"current"];
            if (ratString.length == 0) {
                _appRatingStars.value = 0;
            } else {
                if ([ratString containsString:@"and a half"]) {
                    NSArray *substrings = [ratString componentsSeparatedByString:@" and a half stars"];
                    NSString *starsValue = [substrings objectAtIndex:0];
                    NSString *customValue = [NSString stringWithFormat:@"%@.5", starsValue];
                    _appRatingStars.value = [customValue floatValue];
                } else {
                    NSArray *substrings = [ratString componentsSeparatedByString:@" stars"];
                    NSString *starsValue = [substrings objectAtIndex:0];
                    _appRatingStars.value = [starsValue intValue];
                }
                NSArray *substrings = [ratString componentsSeparatedByString:@", "];
                NSString *starsValueRates = [substrings objectAtIndex:1];
                _appRatingLabel.text = [NSString stringWithFormat:@"(%@)", starsValueRates];
            }
            _appCatLabel.text = [[dict objectForKey:@"genre"] objectForKey:@"name"];
        }
        
    } else {
        _appCatLabel.text = app.appID;
    }
    _appVersionLabel.text = app.appVersion;
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
    if (self.isTweakCell) {
        [_appRatingStars setHidden:YES];
        [_appRatingLabel setHidden:YES];

    } else {
        [_appRatingStars setHidden:NO];
        [_appRatingLabel setHidden:NO];
        
        
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
    if (isAppManager) {
        [_appRatingStars setHidden:NO];
        [_appRatingLabel setHidden:NO];
    }
}

#pragma mark - New App Manager Cell

- (void)configureWithObjectForNewManager:(PFObject *)appObject {
    
    
    
    isAppManager = NO;
    self.currentObject = appObject;
    _appNameLabel.text = appObject[APP_NAME_STRING];
    
    if (!self.isTweakCell) {
        
        if (![appObject[APP_INFO_DICT][@"last_parse_itunes"] isKindOfClass:[NSNull class]]) {
            
            if (appObject[APP_INFO_DICT][@"last_parse_itunes"] != nil) {
                NSLog(@"**** %@", appObject[APP_INFO_DICT][@"last_parse_itunes"]);
                NSData *data = [appObject[APP_INFO_DICT][@"last_parse_itunes"] dataUsingEncoding:NSUTF8StringEncoding];
                id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *ratString = [[dict objectForKey:@"ratings"] objectForKey:@"current"];
                if (ratString.length == 0) {
                    _appRatingStars.value = 0;
                } else {
                    if ([ratString containsString:@"and a half"]) {
                        NSArray *substrings = [ratString componentsSeparatedByString:@" and a half stars"];
                        NSString *starsValue = [substrings objectAtIndex:0];
                        NSString *customValue = [NSString stringWithFormat:@"%@.5", starsValue];
                        _appRatingStars.value = [customValue floatValue];
                    } else {
                        NSArray *substrings = [ratString componentsSeparatedByString:@" stars"];
                        NSString *starsValue = [substrings objectAtIndex:0];
                        _appRatingStars.value = [starsValue intValue];
                    }
                    NSArray *substrings = [ratString componentsSeparatedByString:@", "];
                    NSString *starsValueRates = [substrings objectAtIndex:1];
                    _appRatingLabel.text = [NSString stringWithFormat:@"(%@)", starsValueRates];
                }
                _appCatLabel.text = [[dict objectForKey:@"genre"] objectForKey:@"name"];
            } else {
                _appCatLabel.text = appObject[APP_ID];
            }
            
        } else {
            _appCatLabel.text = appObject[APP_ID];
        }
        
    } else {
        _appCatLabel.text = appObject[APP_ID];
    }
    
    _appVersionLabel.text = appObject[APP_INFO_DICT][@"version"];
    [_appImageView pin_setImageFromURL:[NSURL URLWithString:appObject[APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
    //    [_appImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appObject[APP_ICON]]]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
