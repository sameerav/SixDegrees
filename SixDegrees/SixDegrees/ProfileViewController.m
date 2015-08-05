//
//  ProfileViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/9/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseAPI.h"
#import "User.h"
#import "iCarousel.h"
#import "ParseAPI.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SixDegreesLoginViewController.h"
#import "OtherUserViewController.h"
#import "SuggestionsAPI.h"
#import "Suggestion.h"
#import "BlockedUserViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UILabel *userName;

@property (nonatomic) BOOL wrap;
@property (strong, nonatomic) IBOutlet iCarousel *friendsCarousel;
@property (nonatomic) NSMutableArray *suggestionsArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) User *user;
@property (assign) int offset;
@end

@implementation ProfileViewController

- (IBAction)settingsButtonClicked:(id)sender {
    // go to table view of blocked people
    if (self.user) {
        BlockedUserViewController *buvc = [[BlockedUserViewController alloc] initWithUser:self.user];
        [self presentViewController:buvc animated:YES completion:nil];
    } else {
        [ParseAPI doBlockForCurrentUser:^(User *me) {
            BlockedUserViewController *buvc = [[BlockedUserViewController alloc] initWithUser:me];
            [self presentViewController:buvc animated:YES completion:nil];
        }];
    }
}

- (instancetype) init {
    self = [super init];
    [self.friendsCarousel reloadData];
    if (self) {
        self.cache = [NSMutableDictionary dictionary];
        self.friendProfilePictures = [NSMutableArray array];
        self.suggestionsArray = [NSMutableArray array];
        [ParseAPI doBlockForCurrentUser:^(User *me) {
            self.user = me;
            [SuggestionsAPI queryForSuggestionWithLocation:me.currentLocation withOffset:self.offset  withBlock:^(PFGeoPoint *location, NSString *description, NSString *name, NSNumber *rating, NSString *pictureURL) {
                Suggestion *sug = [[Suggestion alloc] initWithLocation:location andDescription:description andName:name andRating:rating andPictureURL:pictureURL];
                [self.suggestionsArray addObject:sug];
            }];
        }];
    }

    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.loginButton.delegate = self;
    self.friendsCarousel.perspective = iCarouselTypeLinear;
    self.scrollView.contentSize = CGSizeMake(375, 700);
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.layer.borderWidth = 1.0;
    self.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profilePic.clipsToBounds = YES;
    self.loginButton.delegate = self;    

    if ([[self.cache allKeys] count] < 3) {
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
    } else {
        self.spinner.hidden = YES;
    }
    
    self.background.image = self.cache[@"cover"];
    self.userName.text = self.cache[@"name"];
    self.hometown.text = self.cache[@"hometown"];
    
    [self.view setNeedsDisplay];
}

- (void)setValues {
    if ([[self.cache allKeys] count] > 1) {
        self.spinner.hidden = YES;
        [self.spinner stopAnimating];
        [self.view setNeedsDisplay];
    }
    self.background.image = self.cache[@"cover"];
    self.userName.text = self.cache[@"name"];
    self.hometown.text = self.cache[@"hometown"];
    [self.view setNeedsDisplay];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return  [self.friendProfilePictures count];
    //return the total number of items in the carousel
}

- (NSInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    //wrap all carousels
    return self.wrap;

}


-(CGFloat) carouselItemWidth:(iCarousel *)carousel{
    return 260;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return 7;
}


- (IBAction)menuButtonTapped:(id)sender {
    
    if (self.revealViewController){
        [self.revealViewController revealToggle:self];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    NSLog(@"This won't happen");
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create a numbered view
    return self.friendProfilePictures[index];
}

-(void) carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
    UIView *currentView = self.friendsCarousel.currentItemView;
    NSArray *subviews = currentView.subviews;
    FBSDKProfilePictureView *pp = (FBSDKProfilePictureView *) subviews[0];
    NSString *fbid = pp.profileID;
    [ParseAPI getUserFromFBID:fbid withBlock:^(User *other) {
        OtherUserViewController *ouvc = [[OtherUserViewController alloc] initWithFBID: fbid andConnection:nil andURL:other.url andSuggestions:self.suggestionsArray];
        [self presentViewController:ouvc animated:YES completion:nil];
    }];
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    SixDegreesLoginViewController *lvc = [[SixDegreesLoginViewController alloc] init];
    self.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:lvc animated:YES completion:nil];
}


@end
