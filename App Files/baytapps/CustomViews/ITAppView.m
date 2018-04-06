//
//  ITAppView.m
//  ioteam
//
//  Created by iMokhles on 02/06/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "ITAppView.h"

@implementation UILabel (Additions)

- (void)sizeToFitWithAlignmentRight {
    CGRect beforeFrame = self.frame;
    [self sizeToFit];
    CGRect afterFrame = self.frame;
    self.frame = CGRectMake(beforeFrame.origin.x + beforeFrame.size.width - afterFrame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end

@implementation ITAppView

- (id)initWithFrame:(CGRect)frame image:(NSURL *)image title:(NSString *)imageTitle subTitle:(NSString *)imageSubTitle andCydiaApp:(PFObject *)app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        self.imageSubTitle = imageSubTitle;
        self.image = image;
        self.currentCydiaApp = app;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:image placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
        imageRect = CGRectMake(0.0, 0.0, 60.0, 60.0);
        [imageView setFrame:imageRect];
        
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:15.0];
        
        UILabel *title = [[UILabel alloc] init];
        textRect = CGRectMake(0.0, imageRect.origin.y + imageRect.size.height + 4.0, 60, 20.0);
        [title setFrame:textRect];
        
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:10.0]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [title setOpaque: NO];
        [title setText:imageTitle];
        title.numberOfLines=2;
        title.lineBreakMode=NSLineBreakByWordWrapping;
        [title sizeToFit];
        [title setFrame:CGRectMake(0, textRect.origin.y, 60, title.frame.size.height)];
        
        UILabel *subTitle = [[UILabel alloc] init];
        subRect = CGRectMake(0.0, textRect.origin.y + title.frame.size.height + 3.0, 60.0, 20.0);
        [subTitle setFrame:subRect];
        
        [subTitle setBackgroundColor:[UIColor clearColor]];
        [subTitle setTextColor:[UIColor whiteColor]];
        [subTitle setFont:[UIFont systemFontOfSize:10.0]];
        [subTitle setOpaque: NO];
        [subTitle setTextAlignment:NSTextAlignmentCenter];
        [subTitle setText:[NSString stringWithFormat:@"v%@", imageSubTitle]];
        subTitle.numberOfLines=1;
        subTitle.lineBreakMode=NSLineBreakByWordWrapping;
        [subTitle sizeToFit];
        [subTitle setFrame:CGRectMake(0, subRect.origin.y, 60, subTitle.frame.size.height)];
        
        [self addSubview:imageView];
        [self addSubview:title];
        [self addSubview:subTitle];
        
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(NSURL *)image title:(NSString *)imageTitle subTitle:(NSString *)imageSubTitle andApp:(ITAppObject *)app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        self.imageSubTitle = imageSubTitle;
        self.image = image;
        self.currentApp = app;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:image placeholderImage:[UIImage imageNamed:@"square-ios-app-xxl"]];
        imageRect = CGRectMake(0.0, 0.0, 60.0, 60.0);
        [imageView setFrame:imageRect];
        
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:15.0];
        
        UILabel *title = [[UILabel alloc] init];
        textRect = CGRectMake(0.0, imageRect.origin.y + imageRect.size.height + 4.0, 60, 20.0);
        [title setFrame:textRect];
        
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:10.0]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [title setOpaque: NO];
        [title setText:imageTitle];
        title.numberOfLines=2;
        title.lineBreakMode=NSLineBreakByWordWrapping;
        [title sizeToFit];
        [title setFrame:CGRectMake(0, textRect.origin.y, 60, title.frame.size.height)];
        
        UILabel *subTitle = [[UILabel alloc] init];
        subRect = CGRectMake(0.0, textRect.origin.y + title.frame.size.height + 3.0, 60.0, 20.0);
        [subTitle setFrame:subRect];
        
        [subTitle setBackgroundColor:[UIColor clearColor]];
        [subTitle setTextColor:[UIColor whiteColor]];
        [subTitle setFont:[UIFont systemFontOfSize:10.0]];
        [subTitle setOpaque: NO];
        [subTitle setTextAlignment:NSTextAlignmentCenter];
        [subTitle setText:[NSString stringWithFormat:@"v%@", imageSubTitle]];
        subTitle.numberOfLines=1;
        subTitle.lineBreakMode=NSLineBreakByWordWrapping;
        [subTitle sizeToFit];
        [subTitle setFrame:CGRectMake(0, subRect.origin.y, 60, subTitle.frame.size.height)];
        
        [self addSubview:imageView];
        [self addSubview:title];
        [self addSubview:subTitle];
        
    }
    
    return self;
}

@end
