//
//  UIImage+Additions.h
//  iMDownloader
//
//  Created by Mokhlas Hussein on 09/09/15.
//  Copyright (c) 2015 iMokhles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
@end
