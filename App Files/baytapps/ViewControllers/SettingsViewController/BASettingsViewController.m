//
//  BASettingsViewController.m
//  baytapps
//
//  Created by iMokhles on 26/10/16.
//  Copyright © 2016 iMokhles. All rights reserved.


#import "BASettingsViewController.h"
#import "BAHelper.h"
#import "ITHelper.h"
#import "ITServerHelper.h"
#import "HRSampleColorPickerViewController.h"
#import "BAWallpapersViewController.h"

#import "BOTableViewController+Private.h"
#import "BOTableViewCell+Private.h"
#import "BOTableViewCell+Subclass.h"
#import "BOSetting+Private.h"
#import "BAColorsHelper.h"
#import "BOButtonTableViewCell.h"
#import "BODeveloperTableViewCell.h"
#import "BOChoiceTableViewCell.h"
//#import "UICKeyChainStore.h"
#import "converter.h"
#import "SUBLicenseViewController.h"
#import "BATranslatorsViewController.h"

typedef NS_ENUM(NSInteger, OrderStatus)
{
    OrderStatusProcessing = 0,
    OrderStatusCompleted,
    OrderStatusRefunded,
    OrderStatusCancelled,
};

typedef NS_ENUM(NSInteger, PaymentStatus)
{
    PaymentStatusFailed = 0,
    PaymentStatusDone,
};

@interface BASettingsViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSString *expiryDate;
    NSString *paymentMethod;
    NSString *teamID;
    OrderStatus orderStatus;
    PaymentStatus paymentStatus;
    
    //UICKeyChainStore *keyWrapper;
    
    NSString *licenes1String;
    NSString *licenes2String;
    NSString *licenes3String;
    NSString *licenes4String;
    NSString *licenes5String;
    NSString *licenes6String;
    NSString *licenes7String;
    NSString *licenes8String;
}

@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *footerViews;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIImageView *mainBG_ImageView;
@end

@implementation BASettingsViewController

- (void)commonInit {
    
    
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.tableView action:@selector(endEditing:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    [self setup];
}

- (void)awakeFromNib {
    [self commonInit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [self commonInit];
    
}

- (void)addSection:(BOTableViewSection *)section {
    self.sections = [self.sections arrayByAddingObject:section];
}

- (void)addHeaderWithTitle:(NSString *)headerTitle andSubtitle:(NSString *)headerSubtitle {
    CGFloat width = self.view.bounds.size.width;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 114)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, width, 53)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.text = headerTitle;
    titleLabel.font = [UIFont systemFontOfSize:45];//[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45];
    titleLabel.textColor = [BAColorsHelper sideMenuCellSelectedColors];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    UILabel *creditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10 + 58, width, 34)];
    creditLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    creditLabel.text = headerSubtitle;
    creditLabel.font = [UIFont systemFontOfSize:12];
    creditLabel.textColor = [UIColor darkGrayColor];
    creditLabel.textAlignment = NSTextAlignmentCenter;
    creditLabel.numberOfLines = 0;
    [headerView addSubview:titleLabel];
    [headerView addSubview:creditLabel];
    self.tableView.tableHeaderView = headerView;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius  = 10.0f;
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];
    
    
    licenes2String = [ITHelper fileInMainBundleWithName:@"STTLicenses"];
    licenes3String = [ITHelper fileInMainBundleWithName:@"SDWLicenses"];
    licenes4String = [ITHelper fileInMainBundleWithName:@"HCSLicenses"];
    licenes5String = [ITHelper fileInMainBundleWithName:@"KVNLicenses"];
    licenes6String = [ITHelper fileInMainBundleWithName:@"EXPLicenses"];
    licenes7String = [ITHelper fileInMainBundleWithName:@"JGPLicenses"];
    licenes8String = [ITHelper fileInMainBundleWithName:@"JGALicenses"];
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    if ([BAHelper isIPHONE4] || [BAHelper isIPHONE5]) {
        self.slidingViewController.anchorRightPeekAmount  = 100.0;
    } else {
        if ([BAHelper isIPHONE6]) {
            self.slidingViewController.anchorRightPeekAmount  = 100.0;
        } else if ([BAHelper isIPHONE6PLUS]) {
            self.slidingViewController.anchorRightPeekAmount  = 150.0;
        } else if ([BAHelper isIPAD]) {
            self.slidingViewController.anchorRightPeekAmount  = 350.0;
        }
    }
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedRowIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
        
        [[self.navigationController transitionCoordinator] notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if ([context isCancelled]) {
                [self.tableView selectRowAtIndexPath:selectedRowIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }];
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRun"] boolValue] == NO)
    {
        [self.mainBG_ImageView setImage:[UIImage imageNamed:@"main_bg_6"]];
    }
    [self.mainBG_ImageView setImage:[BAHelper currentLocalImage]];
    
    NSString *provisioningPath1 = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:provisioningPath1]) {
        return;
    }
    
    NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = provisioningPath1;
        if (!provisioningPath) {
            mobileProvision = @{};
            return;
        }
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSISOLatin1StringEncoding error:NULL];
        if (!binaryString) {
            return;
        }
        NSScanner *scanner = [NSScanner scannerWithString:binaryString];
        BOOL ok = [scanner scanUpToString:@"<plist" intoString:nil];
        if (!ok) { // // NSLog(@"unable to find beginning of plist");
        }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { // // NSLog(@"unable to find end of plist");
        }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            // // NSLog(@"error parsing extracted plist — %@",error);
            if (mobileProvision) {
                mobileProvision = nil;
            }
            return;
        }
    }
    
    NSDictionary *profile = mobileProvision;
    NSString *teamID1 = profile[@"UUID"];
    NSString *teamID2 = [profile[@"TeamIdentifier"] objectAtIndex:0];
    NSString *ExpirationDate = [profile objectForKey:@"ExpirationDate"];
    // NSLog(@"%@",ExpirationDate);
    NSString *accountType;
    accountType = @"other";
    if (teamID2.length > 0) {
        if ([teamID2 isEqualToString:@"USM32L424X"]) accountType = @"ipa";
        if ([teamID2 isEqualToString:@"2R5JB2FB9E"]) accountType = @"ipa1";
        if ([teamID2 isEqualToString:@"J6D5BK3T6D"]) accountType = @"ipa2";
    } else {
        accountType = @"other";
    }
    teamID = accountType;
    
    NSString *paidStatus ;
    NSString *paymentMethodString;
    NSString *orderStatusString ;
    NSString *orderDateString ;
    NSDate *createdAtDate = Strings2Date(orderDateString);
    //NSDate *dateAfterYear = [createdAtDate dateByAddingYears:1];
    
    
    if (paidStatus.length == 0) {
        // // NSLog(@"******* !!!");
        return;
    }
    
//    if (paymentMethodString.length == 0) {
//        // // NSLog(@"******* !!! 2");
//        return;
//    }
    
    if (orderStatusString.length == 0) {
        // // NSLog(@"******* !!! 3");
        return;
    }
    
    if (orderDateString.length == 0) {
        // // NSLog(@"******* !!! 4");
        return;
    }
    
    
    if ([[orderStatusString lowercaseString] isEqualToString:@"completed"]) orderStatus = OrderStatusCompleted;
    else if ([[orderStatusString lowercaseString] isEqualToString:@"refunded"]) orderStatus = OrderStatusRefunded;
    else if ([[orderStatusString lowercaseString] isEqualToString:@"processing"]) orderStatus = OrderStatusProcessing;
    else if ([[orderStatusString lowercaseString] isEqualToString:@"cancelled"]) orderStatus = OrderStatusCancelled;
    
    paymentMethod = paymentMethodString;
    if ([paidStatus isEqualToString:@"1"]) paymentStatus = PaymentStatusDone;
    else paymentStatus = PaymentStatusFailed;
    
   
    
    //expiryDate = [BAHelper shortDate:dateAfterYear];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setup];
        [self.tableView reloadData];
    });
}

- (void)viewDidLayoutSubviews {
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    BOTableViewSection *section = self.sections[sectionIndex];
    return section.headerTitle;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)headerView forSection:(NSInteger)sectionIndex {
    BOTableViewSection *section = self.sections[sectionIndex];
    if (section.headerTitleColor) headerView.textLabel.textColor = section.headerTitleColor;
    if (section.headerTitleFont) headerView.textLabel.font = section.headerTitleFont;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    BOTableViewSection *section = self.sections[sectionIndex];
    return section.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOTableViewSection *section = self.sections[indexPath.section];
    BOTableViewCell *cell = section.cells[indexPath.row];
//    if ([section.headerTitle isEqualToString:@"About"]) {
//        CGFloat cellHeight = MAX(self.tableView.estimatedRowHeight, [self heightForCell:cell]);
//        cell.height = cellHeight;
//        cellHeight += [cell expansionHeight];
//        return cellHeight;
//    } else {
        CGFloat cellHeight = MAX(self.tableView.estimatedRowHeight, [self heightForCell:cell]);
        cell.height = cellHeight;
        
        if ([self.expansionIndexPath isEqual:indexPath]) {
            cellHeight += [cell expansionHeight];
        }
        
        return cellHeight;
//    }
    
}

- (CGFloat)heightForCell:(BOTableViewCell *)cell {
    
    if ([cell expansionHeight] > 0) {
        UITableViewCell *cleanCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cleanCell.frame = CGRectMake(0, 0, cell.frame.size.width, 0);
        cleanCell.textLabel.numberOfLines = 0;
        cleanCell.textLabel.text = cell.textLabel.text;
        cleanCell.accessoryView = cell.accessoryView;
        cleanCell.accessoryType = cell.accessoryType;
        return [cleanCell systemLayoutSizeFittingSize:cleanCell.frame.size].height;
    }
    
    return [cell systemLayoutSizeFittingSize:cell.frame.size].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOTableViewSection *section = self.sections[indexPath.section];
    BOTableViewCell *cell = section.cells[indexPath.row];
    cell.indexPath = indexPath;
    
    if (cell.setting && !cell.setting.valueDidChangeBlock) {
        __unsafe_unretained typeof(self) weakSelf = self;
        __unsafe_unretained typeof(cell) weakCell = cell;
        cell.setting.valueDidChangeBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakCell settingValueDidChange];
                [weakSelf reloadTableView];
            });
        };
        
        [UIView performWithoutAnimation:^{
            [cell settingValueDidChange];
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BOTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell _updateAppearance];
    [cell updateAppearance];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOTableViewSection *section = self.sections[indexPath.section];
    BOTableViewCell *cell = (BOTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
//    if ([section.headerTitle isEqualToString:@"About"]) {
//        if (cell.destinationViewController) {
//            [self.navigationController pushViewController:cell.destinationViewController animated:YES];
//        }
//    } else {
        if ([cell expansionHeight] > 0) {
            self.expansionIndexPath = ![indexPath isEqual:self.expansionIndexPath] ? indexPath : nil;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        } else if (cell.destinationViewController) {
            [self.navigationController pushViewController:cell.destinationViewController animated:YES];
        } else if ([cell respondsToSelector:@selector(wasSelectedFromViewController:)]) {
            [cell wasSelectedFromViewController:self];
        }
        
        if (cell.accessoryType != UITableViewCellAccessoryDisclosureIndicator) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
//    }
    
}

#pragma mark Dynamic options

- (void)reloadTableView {
    
    NSMutableIndexSet *affectedIndexes = [NSMutableIndexSet new];
    
    for (NSInteger s = 0; s < self.sections.count; s++) {
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:s];
        
        if (numberOfRows != [self.sections[s] cells].count) {
            [affectedIndexes addIndex:s];
        } else {
            for (NSInteger r = 0; r < numberOfRows; r++) {
                UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                if ([self.tableView.visibleCells containsObject:lastCell] && ![[self.sections[s] cells] containsObject:lastCell]) {
                    [affectedIndexes addIndex:s];
                }
            }
        }
    }
    
    if (affectedIndexes.count > 0) {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:affectedIndexes withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    [UIView performWithoutAnimation:^{
        CGPoint previousContentOffset = self.tableView.contentOffset;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        self.tableView.contentOffset = previousContentOffset;
    }];
}

#pragma mark Dynamic footers

- (NSArray *)footerViews {
    if (!_footerViews) {
        _footerViews = [NSArray new];
        
        for (NSInteger i = 0; i < [self.tableView numberOfSections]; i++) {
            UITableViewHeaderFooterView *footerView = [UITableViewHeaderFooterView new];
            _footerViews = [_footerViews arrayByAddingObject:footerView];
        }
    }
    
    return _footerViews;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *footerView = self.footerViews[section];
    footerView.textLabel.text = [self tableView:tableView titleForFooterInSection:section];
    // Super hacky code for iOS 9 support.
    footerView.textLabel.numberOfLines = 0;
    CGPoint previousOrigin = footerView.textLabel.frame.origin;
    [footerView sizeToFit];
    footerView.textLabel.frame = CGRectMake(previousOrigin.x, previousOrigin.y, footerView.textLabel.frame.size.width, footerView.textLabel.frame.size.height);
    
    return footerView.intrinsicContentSize.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex {
    
    // First, we get the section value, and if it's nil we set it to an empty string (this is the lowest priority for dynamic footers).
    BOTableViewSection *section = self.sections[sectionIndex];
    NSString *footerTitle = section.footerTitle;
    
    // Next, we try to find an existing footer in the last cell of the section (this is the medium priority for dynamic footers).
    BOTableViewCell *lastCell = [section.cells lastObject];
    if ([lastCell footerTitle]) footerTitle = [lastCell footerTitle];
    
    // Finally, we try to find an existing footer in any cell that has a checkmark accessory on it (this is the top priority for dynamic footers).
    for (BOTableViewCell *cell in section.cells) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            footerTitle = cell.footerTitle;
        }
    }
    
    return footerTitle ? footerTitle : @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionIndex {
    UITableViewHeaderFooterView *footerView = self.footerViews[sectionIndex];
    if (![[self tableView:tableView titleForFooterInSection:sectionIndex] isEqualToString:@""]) {
        return footerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UITableViewHeaderFooterView *)footerView forSection:(NSInteger)sectionIndex {
    BOTableViewSection *section = self.sections[sectionIndex];
    if (section.footerTitleColor) footerView.textLabel.textColor = section.footerTitleColor;
    if (section.footerTitleFont) footerView.textLabel.font = section.footerTitleFont;
}


#pragma mark Subclassing

- (void)setup {
    NSString* dateAvaiable =  [[NSUserDefaults standardUserDefaults]  objectForKey:@"RegisteredDate"];
    // convert to date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // ignore +11 and use timezone name instead of seconds from gmt
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *dte = [dateFormat dateFromString:dateAvaiable];
    // NSLog(@"Date: %@", dte);
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 366;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:dte options:0];
    
    // NSLog(@"nextDate: %@ ...", nextDate);
    expiryDate = [dateFormat stringFromDate:nextDate];

    self.sections = [NSArray new];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"License", @"") handler:^(BOTableViewSection *section) {
        [section addCell:[BOChoiceTableViewCell cellWithTitle:NSLocalizedString(@"Order Status", @"") key:@"choice_1" handler:^(BOChoiceTableViewCell *cell) {
            
            cell.options = @[@"Completed"];
            cell.mainColor = [UIColor whiteColor];
//            if (orderStatus == 0) {
//                cell.options = @[@"Processing"];
               cell.secondaryColor = [UIColor greenColor];
//            }
//            else if (orderStatus == 1) {
//                cell.options = @[@"Completed"];
//                cell.secondaryColor = [UIColor hex:@"88c057"];
//            }
//            else if (orderStatus == 2) {
//                cell.options = @[@"Refunded"];
//                cell.secondaryColor = [UIColor lightGrayColor];
//            }
//            else if (orderStatus == 3) {
//                cell.options = @[@"Cancelled"];
//                cell.secondaryColor = [UIColor redColor];
//            }
            
        }]];
        [section addCell:[BOChoiceTableViewCell cellWithTitle:NSLocalizedString(@"Paid Status", @"") key:@"choice_2" handler:^(BOChoiceTableViewCell *cell) {
            
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            if (paymentStatus == 0) cell.options = @[@"not Paid 😞"];
            else if (paymentStatus == 1) cell.options = @[@"Paid 👍"];
            
            cell.options = @[@"Paid 👍"];
            
        }]];
        [section addCell:[BOChoiceTableViewCell cellWithTitle:NSLocalizedString(@"Expiry Date", @"") key:@"choice_3" handler:^(BOChoiceTableViewCell *cell) {
            
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            
            if (expiryDate.length > 0) cell.options = @[expiryDate];
            if (expiryDate.length == 0) cell.options = @[@"Date"];
            
            cell.options = @[expiryDate];
            
        }]];
        [section addCell:[BOChoiceTableViewCell cellWithTitle:NSLocalizedString(@"Payment Method", @"") key:@"choice_4" handler:^(BOChoiceTableViewCell *cell) {
            
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            
            if (paymentMethod.length > 0) cell.options = @[paymentMethod];
            if (paymentMethod.length == 0) cell.options = @[@"Method"];
            NSString* PaymentMethod1 =  [[NSUserDefaults standardUserDefaults]  objectForKey:@"PaymentMethod"];
            cell.options = @[PaymentMethod1];
        }]];
        [section addCell:[BOChoiceTableViewCell cellWithTitle:NSLocalizedString(@"Team ID", @"") key:@"choice_5" handler:^(BOChoiceTableViewCell *cell) {
            
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            NSString* RegisteredTEAMID =  [[NSUserDefaults standardUserDefaults]  objectForKey:@"RegisteredTEAMID"];
            if (teamID.length > 0) cell.options = @[teamID];
            if (teamID.length == 0) cell.options = @[@"Team"];
            cell.options = @[RegisteredTEAMID];

        }]];
        [section addCell:[BOChoiceTableViewCell cellWithTitle:NSLocalizedString(@"Version", @"") key:@"choice_6" handler:^(BOChoiceTableViewCell *cell) {
            
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            cell.options = @[[NSString stringWithFormat:@"%@ (%@)",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]]];
        }]];
    }]];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Settings", @"") handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOButtonTableViewCell cellWithTitle:NSLocalizedString(@"Customize Background", @"") key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            cell.actionBlock = ^{
                [self showImagesPicker];
            };
        }]];
//        [section addCell:[BOButtonTableViewCell cellWithTitle:@"Customize Color" key:nil handler:^(BOButtonTableViewCell *cell) {
//            cell.mainColor = [UIColor whiteColor];
//            cell.secondaryColor = [UIColor lightGrayColor];
//            cell.actionBlock = ^{
//                [self showColorsPicker];
//            };
//        }]];
        
    }]];
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"About", @"") handler:^(BOTableViewSection *section) {
        [section addCell:[BODeveloperTableViewCell cellWithTitle:NSLocalizedString(@"Sponsor", @"") key:@"sponsor_key" handler:^(BODeveloperTableViewCell *cell) {
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            cell.profileImage = [UIImage imageNamed:@"ebqfYVnz"];
            cell.profileName = @"Ahmed AlNeaimy";
            cell.profileDescription = @"Co-Founder of BaytApps ";
        }]];
        [section addCell:[BODeveloperTableViewCell cellWithTitle:@"Original Developer" key:@"developer_key" handler:^(BODeveloperTableViewCell *cell) {
            cell.mainColor = [UIColor whiteColor];
            cell.secondaryColor = [UIColor lightGrayColor];
            cell.profileImage = [UIImage imageNamed:@"imokhles"];
            cell.profileName = @"Mokhlas Hussein (iMokhles)";
            cell.profileDescription = @"Software Engineer, Creator of @Bayt_Apps";
        }]];
       
    }]];
    
//    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Thanks To" handler:^(BOTableViewSection *section) {
//        [section addCell:[BOButtonTableViewCell cellWithTitle:@"Translators" key:nil handler:^(BOButtonTableViewCell *cell) {
//            cell.mainColor = [UIColor whiteColor];
//            cell.secondaryColor = [UIColor lightGrayColor];
//            cell.actionBlock = ^{
//                [self openTranslatorsPage];
//            };
//        }]];
//    }]];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Copyrights" handler:^(BOTableViewSection *section) {
//        [section addCell:[BOButtonTableViewCell cellWithTitle:@"Licenses" key:nil handler:^(BOButtonTableViewCell *cell) {
//            cell.mainColor = [UIColor whiteColor];
//            cell.secondaryColor = [UIColor lightGrayColor];
//            cell.actionBlock = ^{
//                [self openLicensesPage];
//            };
//        }]];
        section.footerTitle = @"Copyrights 2016 - 2017, BaytApps.net All Rights Reserved";
    }]];
    
}

- (void)openTranslatorsPage {
    BATranslatorsViewController *translators = [self.storyboard instantiateViewControllerWithIdentifier:@"translatorsPageID"];
    [self.navigationController pushViewController:translators animated:YES];
}

- (void)openLicensesPage {
    SUBLicenseViewController *liceVC = [[SUBLicenseViewController alloc] init];
    liceVC.sectionHeaderBackgroundColor = [BAColorsHelper ba_whiteColor];
    liceVC.cellTextColor = [BAColorsHelper ba_whiteColor];
    liceVC.sectionHeaderTextColor = [BAColorsHelper sideMenuCellSelectedColors];
    liceVC.backgroundImage = nil;
    
    SUBLicense *license1 = [SUBLicense licenseWithTitle:@"SUBLicenseViewController" body:@"Copyright (C) 2015 Julian (insanj) Weiss\n\nThis program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.\n\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.\n\nYou should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>."];
    
    SUBLicense *license2 = [SUBLicense licenseWithTitle:@"STTWitter" body:licenes2String];
    
    SUBLicense *license3 = [SUBLicense licenseWithTitle:@"SDWebImage" body:licenes3String];
    
    SUBLicense *license4 = [SUBLicense licenseWithTitle:@"HCSStarRatingView" body:licenes4String];
    
    SUBLicense *license5 = [SUBLicense licenseWithTitle:@"KVNProgress" body:licenes5String];
    
    SUBLicense *license6 = [SUBLicense licenseWithTitle:@"EXPhotoViewer" body:licenes6String];
    
    SUBLicense *license7 = [SUBLicense licenseWithTitle:@"JGProgressHUD" body:licenes7String];
    
    SUBLicense *license8 = [SUBLicense licenseWithTitle:@"JGActionSheet" body:licenes8String];
    
    
    
    [liceVC addLicenses:@[license1, license2, license3, license4, license5, license6, license7, license8]];
    [self.navigationController pushViewController:liceVC animated:YES];
}
#pragma mark - Buttons Actions
- (IBAction)menuButtonTapped:(UIButton *)sender {
    if ([self.slidingViewController.topViewController isEqual:self.navigationController] && self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}
- (IBAction)twitterButtonTapped:(UIButton *)sender {
    
    NSString *shareingString = [NSString stringWithFormat:NSLocalizedString(@"I'm using the amazing @Bayt_Apps the first apps social network ever and powerfull signing cloud utility", @"")];
    NSURL *siteURL = [NSURL URLWithString:@"https://baytapps.net/"];
    [ITHelper showActivityViewControllerFromSourceView:self.view andViewController:self withArray:@[shareingString, siteURL]];
}

- (void)showColorsPicker {
    HRSampleColorPickerViewController *colorPicker = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"colorPicker"];
    [self.navigationController pushViewController:colorPicker animated:YES];
}
- (void)showImagesPicker {
    BASettingsViewController *wallpapersSearch = [[ITHelper mainStoryboard] instantiateViewControllerWithIdentifier:@"wallpapersPageID"];
    [self.navigationController pushViewController:wallpapersSearch animated:YES];
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
