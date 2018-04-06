//
//  BAListSearchViewController.h
//  baytapps
//
//  Created by iMokhles on 25/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import <UIKit/UIKit.h>

@interface BABrowserViewController : UIViewController

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger previousPage;
@property (nonatomic) NSUInteger currentPageSearch;

@property (nonatomic, assign) BOOL isCydiaApps;
@property (nonatomic, assign) BOOL isLatestApps;
@property (nonatomic, assign) BOOL isRandomApps;
@property (nonatomic, assign) BOOL isMostPopularApps;
- (void) loadedLinkProcess: (NSString*)link;
@end
