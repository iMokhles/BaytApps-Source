//
//  BAColorsHelper.m
//  baytapps
//
//  Created by iMokhles on 24/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAColorsHelper.h"
#import "Colours.h"

@implementation BAColorsHelper

+ (UIColor *)sideMenuCellColor {
    
    return [UIColor colorFromHexString:[@"1D1D26" lowercaseString]];
}
+ (UIColor *)sideMenuCellSelectedColors {
    return [UIColor colorFromHexString:[@"FF3366" lowercaseString]];
}
+ (UIColor *)sideMenuLabelsColor {
    return [UIColor lightGrayColor];
}
+ (UIColor *)ba_whiteColor {
    return [UIColor whiteColor];
}
+ (UIColor *)seconderyColor {
    return [UIColor colorFromHexString:[@"BA77FF" lowercaseString]];
}
@end
