//
//  BARenewViewController.m
//  baytapps
//
//  Created by iMokhles on 07/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BARenewViewController.h"

@interface BARenewViewController ()
@property (strong, nonatomic) IBOutlet UIButton *renewButton;

@end

@implementation BARenewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)renewTapped:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://baytapps.net"]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
