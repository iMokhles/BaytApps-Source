//
//  BAWebViewController.m
//  baytapps
//
//  Created by iMokhles on 17/12/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAWebViewController.h"

@interface BAWebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *mainWebView;

@end

@implementation BAWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F70 Safari/600.1.4
    
//    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: @"https://207.254.60.211/baapi/"]];
//    [urlRequest setValue: @"iPhone" forHTTPHeaderField: @"User-Agent"];
//    [self.mainWebView loadRequest:urlRequest.copy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
