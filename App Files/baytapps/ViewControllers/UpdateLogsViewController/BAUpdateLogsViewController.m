//
//  BAUpdateLogsViewController.m
//  baytapps
//
//  Created by iMokhles on 18/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAUpdateLogsViewController.h"

#import "BAUpdateCell.h"
#import "AppDelegate.h"

@interface BAUpdateLogsViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    NSString *currentChangeLogArray;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@end

@implementation BAUpdateLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
     HUD.textLabel.text = @"Checking Update";
     [HUD showInView:self.view];
    self.headerLabel.hidden = YES;
    self.mainTableView.hidden = YES;
    self.updateButton.hidden = YES;
    
    AppDelegate *app =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    app.isUpdateExist = NO;
    [app changeBadge];
    
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    PFQuery *checkUpdate = [PFQuery queryWithClassName:CHECK_UPDATE_CLASS_NAME];
    // NSLog(@"%@",[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]);
    [checkUpdate whereKey:CHECK_UPDATE_APP_ID equalTo:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    [checkUpdate whereKey:CHECK_UPDATE_APP_TEAM_ID equalTo:[[ITHelper accountType] lowercaseString]];
    [checkUpdate findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [HUD dismiss];

        if (error == nil) {
            if (objects.count == 1) {
                PFObject *currentUpdate = [objects objectAtIndex:0];
                NSString *versionInServer = currentUpdate[CHECK_UPDATE_APP_VERSION];
                NSString *localAppVersion = infoDictionary[@"CFBundleShortVersionString"];
                
                if ([versionInServer compare:localAppVersion options:NSNumericSearch] == NSOrderedDescending) {
//                    BAUpdateLogsViewController *updateLogVC = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"updateLogVC"];
                    self.headerLabel.hidden = NO    ;
                    self.mainTableView.hidden = NO;
                    self.updateButton.hidden = NO;
                    self.updateLog = currentUpdate;
                    NSString *headerString = [NSString stringWithFormat:NSLocalizedString(@"Whats's New in Version: %@", @""), self.updateLog[CHECK_UPDATE_APP_VERSION]];
                    self.headerLabel.text = headerString;
                    currentChangeLogArray = self.updateLog[CHECK_UPDATE_CHANGE_LOG];
                    [self.mainTableView reloadData];
                    
//                    updateLogVC.modalPresentationStyle = UIModalPresentationFormSheet;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[ITHelper rootViewController] presentViewController:updateLogVC animated:YES completion:^{
//                            
//                        }];
//                    });
                    
                }else{
                    self.headerLabel.hidden = NO    ;
                    NSString *headerString = [NSString stringWithFormat:@"You have already Latest Version."];
                    self.headerLabel.text = headerString;
                }
            }
        } else {
            self.headerLabel.hidden = NO    ;
            NSString *headerString = [NSString stringWithFormat:@"Checking Error"];
            self.headerLabel.text = headerString;
            // // NSLog(@"ERROR UPDATE: %@", error.localizedDescription);
        }
    }];

    
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BAUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAUpdateCell"];
    //NSString *logString = [currentChangeLogArray objectAtIndex:indexPath.section];
    cell.updateLogLabel.text = currentChangeLogArray;
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)updateButtonTapped:(UIButton *)sender {
    //// NSLog(@"%@", self.updateLog[CHECK_UPDATE_INSTALL_URL]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", @"https://cloud.baytapps.net/app/install"]]];
}
- (IBAction)closeButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
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
