//
//  ITTableScrollAppsCell.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITAppView.h"

@interface ITTableScrollAppsCell : UITableViewCell <UIScrollViewDelegate> {
    CGFloat scale;
}
- (void)configureWithAppsArray:(NSArray *)array;
- (void)configureWithTitle:(NSString *)title items:(NSArray *)items;
@property (strong, nonatomic) IBOutlet UILabel *sectionLabel;
@property (strong, nonatomic) IBOutlet UIView *mainBackView;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (nonatomic, copy) void (^appTappedBlock)(ITTableScrollAppsCell *appCell, ITAppView *currentApp);
@property (nonatomic, copy) void (^showAllTappedBlock)(ITTableScrollAppsCell *appCell, UIButton *currentButton);
@end
