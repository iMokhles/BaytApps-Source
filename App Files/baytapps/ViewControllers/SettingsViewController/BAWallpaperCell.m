//
//  BAWallpaperCell.m
//  baytapps
//
//  Created by iMokhles on 29/10/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAWallpaperCell.h"

@implementation BAWallpaperCell
- (void)prepareForReuse {
    [super prepareForReuse];
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}
@end
