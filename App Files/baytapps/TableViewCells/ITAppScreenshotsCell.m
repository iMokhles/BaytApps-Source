//
//  ITAppScreenshotsCell.m
//  ioteam
//
//  Created by iMokhles on 11/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITAppScreenshotsCell.h"


#define DISTANCE_BETWEEN_ITEMS  15.0
#define LEFT_PADDING            15.0
#define ITEM_WIDTH              150.0

@interface ITAppScreenshotsCell ()
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@end
@implementation ITAppScreenshotsCell

- (void)configureWithItems:(NSArray *)items {
    
    CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.mainScrollView.frame.size.height);
    __block NSUInteger page = 0;
    
    [items enumerateObjectsUsingBlock:^(ITAppScreenshotView *itemImageView, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [itemImageView setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, 0, pageSize.width, pageSize.height)];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
        [itemImageView addGestureRecognizer:singleFingerTap];
        [self.mainScrollView addSubview:itemImageView];
        
    }];

    self.mainScrollView.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * [items count], pageSize.height);
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self setNeedsDisplay];
}

- (void)itemTapped:(UITapGestureRecognizer *)recognizer {
    ITAppScreenshotView *item = (ITAppScreenshotView *)recognizer.view;
    
    if (item != nil) {
        self.screenShotTappedBlock(self, item);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
