//
//  ITAppScreenshotsCell.h
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "ITAppScreenshotView.h"

@interface ITAppScreenshotsCell : UITableViewCell <UIScrollViewDelegate>
@property (nonatomic, copy) void (^screenShotTappedBlock)(ITAppScreenshotsCell *appCell, ITAppScreenshotView *currentScreenshot);

- (void)configureWithItems:(NSArray *)items;
@end
