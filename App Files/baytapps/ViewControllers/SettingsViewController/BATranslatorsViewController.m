//
//  BATranslatorsViewController.m
//  baytapps
//
//  Created by iMokhles on 18/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BATranslatorsViewController.h"
#import "ITHostCell.h"
#import "AppDelegate.h"
#import "BAProgressViewController.h"
#import "BAAppEditorViewController.h"
#import "ITServerHelper.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "ITHelper.h"

@interface BATranslatorsViewController () <UIWebViewDelegate, LGRefreshViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate> {
    NSArray *translatorsArray;
    DGActivityIndicatorView *activityIndicator;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIImageView *topTitleImageView;
@property (strong, nonatomic) IBOutlet UIButton *topBackBtn;
- (IBAction)topBackBtnTapped:(UIButton *)sender;

@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;

@end

@implementation BATranslatorsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAllTranslators];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Translators", @"Translators page title");
    
    activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:[UIColor whiteColor] size:70.0f];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    [self loadAllTranslators];
    [refreshView endRefreshing];
}

- (void)loadAllTranslators {
    [ITServerHelper getAllTranslatorsWithBlock:^(BOOL succeeded, NSArray *objects, NSError *error) {
        if (error == nil) {
            if (succeeded) {
                translatorsArray = objects;
                [self.mainTableView reloadData];
            }
        } else {
            [ITHelper showErrorMessageFrom:self withError:error];
        }
    }];
}

#pragma mark - UITableView Delegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([translatorsArray count] == 0) {
        activityIndicator.frame = CGRectMake(0, 0, self.mainTableView.bounds.size.width, self.mainTableView.bounds.size.height);
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.mainTableView setBackgroundView:activityIndicator];
        [activityIndicator startAnimating];
        return 0;
    } else {
        [activityIndicator stopAnimating];
        [self.mainTableView setBackgroundView:nil];
        [self.mainTableView setBackgroundColor:[UIColor clearColor]];
        [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return [translatorsArray count];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ITHostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ITHostCell"];
    PFObject *translator = [translatorsArray objectAtIndex:indexPath.section];
    ITAppHoster *host = [ITAppHoster new];
    
    host.hosterCracker = [NSString stringWithFormat:@"Follow @%@ on twitter", translator[TRANSLATORS_ID]];
    host.hosterName = [NSString stringWithFormat:@"%@ for %@", translator[TRANSLATORS_NAME], translator[TRANSLATORS_LANG]];
    host.isVerified = YES;
    
    [cell configureWithHoster:host];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *translator = [translatorsArray objectAtIndex:indexPath.section];
    
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", translator[TRANSLATORS_ID]]]];
        sfvc.delegate = self;
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", translator[TRANSLATORS_ID]]]]) {

        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)topBackBtnTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
