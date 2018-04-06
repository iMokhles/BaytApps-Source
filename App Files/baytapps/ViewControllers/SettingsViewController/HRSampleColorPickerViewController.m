/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

#import "HRSampleColorPickerViewController.h"
#import "HRColorPickerView.h"
#import "BAHelper.h"
#import "ITHelper.h"
#import "BAColorsHelper.h"
#import "Definations.h"

@interface HRSampleColorPickerViewController () {
    id <HRColorPickerViewControllerDelegate> __weak delegate;
}

@property (nonatomic, weak) IBOutlet HRColorPickerView *colorPickerView;

@property (strong, nonatomic) IBOutlet UIButton *topRightButton;
@property (strong, nonatomic) IBOutlet UIImageView *topTitleImageView;
@property (nonatomic, strong) IBOutlet UIButton *topLeftButton;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation HRSampleColorPickerViewController {
    UIColor *_color;
}

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    self.colorPickerView.color = _color;
    [self.colorPickerView addTarget:self
                             action:@selector(colorDidChange:)
                   forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.delegate) {
        [self.delegate setSelectedColor:self.color];
    }
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)colorDidChange:(HRColorPickerView *)colorPickerView {
    _color = colorPickerView.color;
    
    NSString *colorHex = [[[ITHelper sharedInstance] hexStringFromColor:_color] lowercaseString];
    [[NSUserDefaults standardUserDefaults] setObject:colorHex forKey:@"appMain_Color"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [[UIView appearance] setTintColor:_color];
//    [[UIImageView appearance] setTintColor:_color];
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           _color, NSForegroundColorAttributeName,
//                                                           [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0], NSFontAttributeName, nil]];
//    [[UINavigationBar appearance] setTintColor:_color];
//    [[UITabBar appearance] setBarTintColor:_color];
//    [[UIButton appearance] setTintColor:_color];
//    [[UIWindow appearance] setTintColor:_color];
}
- (IBAction)saveTapped:(UIButton *)sender {
}
- (IBAction)backTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)chooseCustomColors:(UITapGestureRecognizer *)sender {
    
    NSArray *colorsTitles = @[NSLocalizedString(@"White", @""), NSLocalizedString(@"Black", @""), NSLocalizedString(@"Red", @""), NSLocalizedString(@"Blue", @""), NSLocalizedString(@"Green", @""), NSLocalizedString(@"Cancel", @"")];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME message:@"Choose Color" preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSString *actionTitle in colorsTitles) {
        [alert addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *title = action.title;
            if ([title isEqualToString:@"Cancel"]) {
                // // NSLog(@"Cancelled");
            }
            if ([title isEqualToString:NSLocalizedString(@"White", @"")]) {
                self.colorPickerView.color = [UIColor whiteColor];
                [self colorDidChange:self.colorPickerView];
            }
            if ([title isEqualToString:NSLocalizedString(@"Black", @"")]) {
                self.colorPickerView.color = [UIColor blackColor];
                [self colorDidChange:self.colorPickerView];
            }
            if ([title isEqualToString:NSLocalizedString(@"Red", @"")]) {
                self.colorPickerView.color = [UIColor redColor];
                [self colorDidChange:self.colorPickerView];
            }
            if ([title isEqualToString:NSLocalizedString(@"Blue", @"")]) {
                self.colorPickerView.color = [UIColor blueColor];
                [self colorDidChange:self.colorPickerView];
            }
            if ([title isEqualToString:NSLocalizedString(@"Green", @"")]) {
                self.colorPickerView.color = [UIColor greenColor];
                [self colorDidChange:self.colorPickerView];
            }
            
        }]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:alert animated:YES completion:^{
            //
        }];
    });
}

@end

