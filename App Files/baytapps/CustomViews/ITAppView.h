//
//  ITAppView.h
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>
#import "BAHelper.h"
#import "ITAppObject.h"

@interface ITAppView : UIView {
    CGRect textRect;
    CGRect subRect;
    CGRect imageRect;
}
@property (nonatomic, retain) NSObject *objectTag;

@property (nonatomic, retain) NSString *imageTitle;
@property (nonatomic, retain) NSString *imageSubTitle;
@property (nonatomic, retain) NSURL *image;
@property (nonatomic, strong) ITAppObject *currentApp;
@property (nonatomic, strong) PFObject *currentCydiaApp;

- (id)initWithFrame:(CGRect)frame image:(NSURL *)image title:(NSString *)imageTitle subTitle:(NSString *)imageSubTitle andApp:(ITAppObject *)app;
- (id)initWithFrame:(CGRect)frame image:(NSURL *)image title:(NSString *)imageTitle subTitle:(NSString *)imageSubTitle andCydiaApp:(PFObject *)app;
@end
