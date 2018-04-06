//
//  ITTableScrollAppsCell.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITTableScrollAppsCell.h"


#define DISTANCE_BETWEEN_ITEMS  15.0
#define LEFT_PADDING            15.0
#define ITEM_WIDTH              60.0
#define TITLE_HEIGHT            40.0

@interface ITTableScrollAppsCell ()
@property (nonatomic, strong) NSArray *appsArray;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@end

@implementation ITTableScrollAppsCell

- (void)configureWithAppsArray:(NSArray *)array {
    _appsArray = array;
}

- (void)configureWithTitle:(NSString *)title items:(NSMutableArray *)items {
    
    _sectionLabel.text = title;
    
    CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.mainScrollView.frame.size.height);
    NSUInteger page = 0;
    
    for(ITAppView *item in items) {
        [item setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, 0, pageSize.width, pageSize.height)];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
        [item addGestureRecognizer:singleFingerTap];
        if (![self.mainScrollView.subviews containsObject:item]) {
            [self.mainScrollView addSubview:item];
        }
    }
    
    self.mainScrollView.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * [items count], pageSize.height);
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _moreButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    _moreButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [_moreButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    _moreButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    _mainBackView.layer.cornerRadius = 12;//half of the width
    _mainBackView.layer.masksToBounds = NO;
    _mainBackView.layer.shadowOffset = CGSizeMake(0, 0);
    _mainBackView.layer.shadowRadius = 2;
    _mainBackView.layer.shadowOpacity = 1;
    _mainBackView.layer.shadowColor = [UIColor clearColor].CGColor;
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)itemTapped:(UITapGestureRecognizer *)recognizer {
    ITAppView *item = (ITAppView *)recognizer.view;
    
    if (item != nil) {
        self.appTappedBlock(self, item);
    }
}

- (IBAction)moreButtonTapped:(UIButton *)sender {
    self.showAllTappedBlock(self, sender);
}

@end
