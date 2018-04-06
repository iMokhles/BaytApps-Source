//
//  ITAppScreenshotView.m
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITAppScreenshotView.h"
#import <PINCache.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINRemoteImage/PINRemoteImageManager.h>

@implementation ITAppScreenshotView

- (id)initWithFrame:(CGRect)frame image:(NSURL *)image andCydiaApp:(ITAppObject *)app {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        self.currentCydiaApp = app;
        self.imageURL = image;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView pin_setImageFromURL:image placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        imageRect = CGRectMake(0, 0, 150, 202);
        [imageView setFrame:imageRect];
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:12.0];
        roundCorner.borderColor = [UIColor lightGrayColor].CGColor;
        roundCorner.borderWidth = 0.5;
        
        [self addSubview:imageView];
        self.currentImageView = imageView;
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame image:(NSURL *)image andApp:(ITAppDescrip *)app {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        self.currentApp = app;
        self.imageURL = image;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:image placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        imageRect = CGRectMake(0, 0, 150, 202);
        [imageView setFrame:imageRect];
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:12.0];
        roundCorner.borderColor = [UIColor lightGrayColor].CGColor;
        roundCorner.borderWidth = 0.5;
        
        [self addSubview:imageView];
        self.currentImageView = imageView;
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
