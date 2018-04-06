//
//  BAChooserCell.m
//  baytapps
//
//  Created by iMokhles on 08/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAChooserCell.h"
#import "UIImageView+Letters.h"
#import "BAColorsHelper.h"
#import "AppConstant.h"

@interface BAChooserCell ()
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userInformationLabel;
@property (strong, nonatomic) IBOutlet UILabel *supportUserStatus;

@end
@implementation BAChooserCell
@synthesize userImageView;
@synthesize userNameLabel, userInformationLabel;
@synthesize supportUserStatus;

- (void)configureWithUser:(PFUser *)user {
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (error == nil) {
            // date
            userNameLabel.text = user[USER_FULLNAME];
            userInformationLabel.text = user.username;
            
            PFFile *avatarFile = user[USER_AVATAR];
            [avatarFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error == nil) {
                    if (data) {
                        // NSLog(@"%u", data.length);
                        if (data.length ==  81890) {
                             [userImageView setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [userImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                            
                        } else if (data.length <= 510) {
                            [userImageView setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [userImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                        } else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [userImageView setImage:[UIImage imageWithData:data]];
                            });
                        }
                    } else {
                        [userImageView setImageWithString:user[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [userImageView fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                    }
                } else {
                    [ITHelper showErrorMessageFrom:nil withError:error];
                }
            }];
            
            if (self.isSupportCell == YES) {
                if ([user[PF_USER_SUPPORT_TEAM] isEqualToString:@"YES"]) {
                    if ([user[PF_USER_SUPPORT_STATUS] isEqualToString:@"YES"]) {
                        [supportUserStatus setTextColor:[UIColor greenColor]];
                        [supportUserStatus setText:@"Online"];
                    } else {
                        [supportUserStatus setTextColor:[UIColor redColor]];
                        [supportUserStatus setText:@"Offline"];
                    }
                }
            }
        } else {
            [ITHelper showErrorMessageFrom:nil withError:error];
        }
        
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    userImageView.layer.masksToBounds = YES;
    userImageView.layer.cornerRadius = userImageView.frame.size.width/2.0;
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
//    self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.2];
//    self.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.2];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isSupportCell == YES) {
        [supportUserStatus setHidden:NO];
    } else {
        [supportUserStatus setHidden:YES];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
