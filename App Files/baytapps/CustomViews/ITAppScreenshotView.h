//
//  ITAppScreenshotView.h
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITAppDescrip.h"

@interface ITAppScreenshotView : UIView {
    CGRect imageRect;
}
@property ITAppDescrip *currentApp;
@property ITAppObject *currentCydiaApp;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImageView *currentImageView;
- (id)initWithFrame:(CGRect)frame image:(NSURL *)image andApp:(ITAppDescrip *)app;
- (id)initWithFrame:(CGRect)frame image:(NSURL *)image andCydiaApp:(ITAppObject *)app;
@end
