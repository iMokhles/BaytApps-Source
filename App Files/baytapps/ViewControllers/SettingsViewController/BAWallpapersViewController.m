//
//  BAWallpapersViewController.m
//  baytapps
//
//  Created by iMokhles on 29/10/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BAWallpapersViewController.h"
#import "BAHelper.h"
#import "BAColorsHelper.h"
#import "ITHelper.h"
#import "BAWallpaperCell.h"
#import "DGActivityIndicatorView.h"
#import "LGRefreshView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "JGActionSheet.h"
//#import "UICKeyChainStore.h"


@interface BAWallpapersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LGRefreshViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate> {
    NSArray *wallpapersArray;
    DGActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (nonatomic,strong) IBOutlet UISearchBar        *searchBar;

@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) LGRefreshView *refreshView;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation BAWallpapersViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    [self setup_SearchBar];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
}

- (void)setup_SearchBar {
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.placeholder = NSLocalizedString(@"Search Image", @"");
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[BAColorsHelper ba_whiteColor]];
    NSDictionary *placeholderAttributes = @{
                                            NSForegroundColorAttributeName: [BAColorsHelper ba_whiteColor],
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
                                            };
    
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.searchBar.placeholder
                                                                                attributes:placeholderAttributes];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAttributedPlaceholder:attributedPlaceholder];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor clearColor]];
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    // To change background color
    searchField.backgroundColor = [UIColor clearColor];
    searchField.textColor = [BAColorsHelper ba_whiteColor];
    //    UIImage *searchIcon = [self.searchBar imageForSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    //    searchIcon = [searchIcon imageTintedWithColor:[UIColor whiteColor]];
    
    UIImageView *leftImageView = (UIImageView *)searchField.leftView;
    leftImageView.image = [leftImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    leftImageView.tintColor = [BAColorsHelper ba_whiteColor];

}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    wallpapersArray = nil;
    [refreshView endRefreshing];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return wallpapersArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BAWallpaperCell *cell =
    (BAWallpaperCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"BAWallpaperCell"
                                                            forIndexPath:indexPath];
    
    NSDictionary *resultDict = [wallpapersArray objectAtIndex:indexPath.row];
    
    
    [cell.wallpaperImageView setImageWithURL:[NSURL URLWithString:resultDict[@"link"]] placeholderImage:[UIImage imageNamed:@"chat_blank"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *resultDict = [wallpapersArray objectAtIndex:indexPath.row];
    [BAHelper saveImageFromURL:[NSURL URLWithString:resultDict[@"link"]] withCompletion:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (finished == YES) {
             [ITHelper showSuccessAlert:NSLocalizedString(@"Wallpaper saved ( you need to set it )", @"")];
        } else {
            [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"Failed to save wallpaper", @"")];
        }
    }];
   
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(100, 160);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 20.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5.0;
}

#pragma mark - search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
    [self.mainCollectionView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    [BAHelper searchImageForString:searchBar.text.lowercaseString withCompletion:^(NSDictionary *dataDict) {
        NSArray*wallpapersItems = [dataDict objectForKey:@"items"];
        wallpapersArray = wallpapersItems;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainCollectionView reloadData];
        });
    }];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (IBAction)backButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    
    //
    NSString *localFilePath = [[BAHelper getDocumentsPath] stringByAppendingPathComponent:@"savedImage.png"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:NSLocalizedString(@"Set Wallpaper", @"") message:nil buttonTitles:@[NSLocalizedString(@"Set choosen wallpaper", @""), NSLocalizedString(@"Reset Background", @"")] buttonStyle:JGActionSheetButtonStyleDefault];
        JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", @"")] buttonStyle:JGActionSheetButtonStyleCancel];
        
        NSArray *sections = @[section1, cancelSection];
        
        JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
        
        [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    
//                    UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isChangingPaper"];
                    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
                } else {
//                    UICKeyChainStore *key = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
//                    [key setString:@"NO" forKey:@"isChangingPaper"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isChangingPaper"];
                    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
                }
                [sheet dismissAnimated:YES];
            } else {
                [sheet dismissAnimated:YES];
            }
            
        }];
        if ([BAHelper isIPAD]) {
            [sheet showFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0) inView:self.view animated:YES];
        } else {
            [sheet showInView:self.view animated:YES];
        }
    } else {
        [ITHelper showAlertViewForExtFromViewController:self WithTitle:@"" msg:NSLocalizedString(@"You didn't choose any wallpaper yet.", @"")];
    }
    
    
    
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
