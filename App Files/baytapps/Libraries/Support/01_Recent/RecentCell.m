//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "utilities.h"

#import "RecentCell.h"
#import "UIImageView+Letters.h"
#import "BAColorsHelper.h"
#import "ITHelper.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentCell()
{
	PFObject *recent;
    NSTimer *timer;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentCell

@synthesize imageUser;
@synthesize labelDescription, labelLastMessage;
@synthesize labelElapsed, labelCounter;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(PFObject *)recent_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	recent = recent_;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadTimeStamp:) userInfo:nil repeats:YES];

	//---------------------------------------------------------------------------------------------------------------------------------------------
    PFQuery *contacts = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [contacts whereKey:@"fullName" equalTo:recent[@"description"]];
    [contacts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        PFUser *user2 = [objects objectAtIndex:0];
        
        if (user2[USER_AVATAR]) {
            PFFile *avatarFile = user2[USER_AVATAR];
            
            [avatarFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error == nil) {
                    if (data) {
                        if (data.length > 510) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.imageUser setImage:[UIImage imageWithData:data]];
                            });
                        } else if (data.length <= 510) {
                            [self.imageUser setImageWithString:user2[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.imageUser fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                        }
                    } else {
                        [self.imageUser setImageWithString:user2[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.imageUser fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                    }
                } else {
                    [self.imageUser setImageWithString:user2[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.imageUser fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
                }
            }];
        } else {
            [self.imageUser setImageWithString:user2[USER_FULLNAME] color:[UIColor whiteColor] circular:NO textAttributes:@{NSFontAttributeName: [self.imageUser fontForFontName:nil],NSForegroundColorAttributeName: [BAColorsHelper sideMenuCellSelectedColors]}];
        }
        
    }];
    
	
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelDescription.text = recent[PF_RECENT_DESCRIPTION];
	labelLastMessage.text = recent[PF_RECENT_LASTMESSAGE];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:recent[PF_RECENT_UPDATEDACTION]];
	labelElapsed.text = TimeElapsed(seconds);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int counter = [recent[PF_RECENT_COUNTER] intValue];
	labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}

- (void)reloadTimeStamp:(NSTimer *)timerStamp {
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:recent[PF_RECENT_UPDATEDACTION]];
    labelElapsed.text = TimeElapsed(seconds);
}
- (void)awakeFromNib {
    [super awakeFromNib];
    imageUser.layer.cornerRadius = 22.5f;
    imageUser.layer.masksToBounds = YES;
    
    self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.2];
    self.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.2];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
