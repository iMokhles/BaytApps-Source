//
//  BAUserAppCell.m
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAUserAppCell.h"
#import "ITHelper.h"
#import "Definations.h"
#import "ITServerHelper.h"
#import "BAColorsHelper.h"

@interface BAUserAppCell ()
@property (strong, nonatomic) IBOutlet UIImageView *appImageView;
@property (strong, nonatomic) IBOutlet UILabel *appNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *appCatLabel;
@property (strong, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *appRatingLabel;
@property (strong, nonatomic) IBOutlet HCSStarRatingView *appRatingStars;
@property (nonatomic, strong) PFObject *currentObject;

@property (strong, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userFullName;
@property (strong, nonatomic) IBOutlet UILabel *userUserName;
@end
@implementation BAUserAppCell

- (void)configureWithObject:(PFObject *)appObject {
    self.currentObject = appObject;
    PFUser *user = [appObject objectForKey:APP_USER_POINTER];
    do {
        @try {
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if (error == nil) {
                    // date
                    self.userFullName.text = user[USER_FULLNAME];
                    self.userUserName.text = user.username;
                    
                    [self.userProfileImage setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.userProfileImage fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                    
                    PFFile *avatarFile = user[USER_AVATAR];
                    [avatarFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                        if (error == nil) {
                            if (data) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (data.length > 510) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.userProfileImage setImage:[UIImage imageWithData:data]];
                                        });
                                    } else if (data.length <= 510) {
                                        [self.userProfileImage setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.userProfileImage fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                                    }
                                });
                                
                            }
                        } else {
                            [self.userProfileImage setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.userProfileImage fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                            
                            NSData *imageAvatarData = UIImagePNGRepresentation(self.userProfileImage.image);
                            if (imageAvatarData) {
                                user[USER_AVATAR] = [PFFile fileWithData:imageAvatarData];
                                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if (succeeded) {
                                        if (error == nil ) {
                                            
                                        }
                                    }
                                }];
                            }
                        }
                    }];
                    
                    _appNameLabel.text = appObject[APP_NAME_STRING];
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
                    _appVersionLabel.text = appObject[APP_INFO_DICT][@"version"];
                    [_appImageView sd_setImageWithURL:[NSURL URLWithString:appObject[APP_ICON]] placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
                }
            }];
        } @catch (NSException *e) {}
    } while (user == nil);
}

- (void)layoutSubviews {
    [super layoutSubviews];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _appImageView.layer.masksToBounds = YES;
    _appImageView.layer.cornerRadius = 15;
    
    _userProfileImage.layer.cornerRadius = 11;
    _userProfileImage.layer.masksToBounds = YES;
    [[_userProfileImage layer] setBorderWidth:0.6f];
    [[_userProfileImage layer] setBorderColor:[BAColorsHelper sideMenuCellSelectedColors].CGColor];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
